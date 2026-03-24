import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../firebase_options.dart';
import '../../core/sync_models.dart';

class CloudSyncAvailability {
  const CloudSyncAvailability({
    required this.isAvailable,
    required this.message,
  });

  final bool isAvailable;
  final String message;
}

class CloudSyncSession {
  const CloudSyncSession({
    required this.isConfigured,
    required this.providerLabel,
    this.userId,
    this.email,
  });

  final bool isConfigured;
  final String providerLabel;
  final String? userId;
  final String? email;

  bool get isConnected => userId != null && (email?.isNotEmpty ?? false);
}

class CloudSyncMutation {
  const CloudSyncMutation({
    required this.entityType,
    required this.entityId,
    required this.changeType,
    required this.changedAt,
    this.payload,
  });

  final SyncEntityType entityType;
  final String entityId;
  final SyncChangeType changeType;
  final DateTime changedAt;
  final Map<String, Object?>? payload;
}

class CloudSyncRemoteChange {
  const CloudSyncRemoteChange({
    required this.entityType,
    required this.entityId,
    required this.changeType,
    required this.changedAt,
    this.payload,
  });

  final SyncEntityType entityType;
  final String entityId;
  final SyncChangeType changeType;
  final DateTime changedAt;
  final Map<String, Object?>? payload;
}

abstract class CloudSyncGateway {
  CloudSyncAvailability get availability;

  Future<void> initialize();

  Future<CloudSyncSession> currentSession();

  Future<CloudSyncSession> signInWithGoogle();

  Future<void> signOut();

  Future<void> applyMutations({
    required String userId,
    required String accountEmail,
    required List<CloudSyncMutation> mutations,
  });

  Future<List<CloudSyncRemoteChange>> fetchRemoteChanges({
    required String userId,
  });
}

class FirebaseCloudSyncGateway implements CloudSyncGateway {
  FirebaseCloudSyncGateway({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final GoogleSignIn? _googleSignIn;

  var _initialized = false;
  var _availability = CloudSyncAvailability(
    isAvailable: false,
    message: DefaultFirebaseOptions.setupHint,
  );

  @override
  CloudSyncAvailability get availability => _availability;

  FirebaseAuth get _authInstance => _auth ?? FirebaseAuth.instance;

  FirebaseFirestore get _firestoreInstance =>
      _firestore ?? FirebaseFirestore.instance;

  GoogleSignIn get _googleSignInInstance =>
      _googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    final options = DefaultFirebaseOptions.currentPlatform;
    if (options == null) {
      _availability = CloudSyncAvailability(
        isAvailable: false,
        message: DefaultFirebaseOptions.setupHint,
      );
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      if (!DefaultFirebaseOptions.isGoogleSignInConfiguredForCurrentPlatform) {
        _availability = CloudSyncAvailability(
          isAvailable: false,
          message: DefaultFirebaseOptions.setupHint,
        );
        return;
      }
      await _googleSignInInstance.initialize(
        clientId: DefaultFirebaseOptions.googleSignInClientId,
        serverClientId: DefaultFirebaseOptions.googleServerClientId,
      );
      try {
        await _googleSignInInstance.attemptLightweightAuthentication();
      } catch (_) {}

      _availability = const CloudSyncAvailability(
        isAvailable: true,
        message: 'Firebase is configured for optional Google sign-in and sync.',
      );
    } on Object catch (error) {
      _availability = CloudSyncAvailability(
        isAvailable: false,
        message: 'Firebase setup failed: $error',
      );
    }
  }

  @override
  Future<CloudSyncSession> currentSession() async {
    await initialize();
    if (!availability.isAvailable) {
      return const CloudSyncSession(
        isConfigured: false,
        providerLabel: 'Google',
      );
    }

    final user = _authInstance.currentUser;
    return CloudSyncSession(
      isConfigured: availability.isAvailable,
      providerLabel: 'Google',
      userId: user?.uid,
      email: user?.email,
    );
  }

  @override
  Future<CloudSyncSession> signInWithGoogle() async {
    await initialize();
    if (!availability.isAvailable) {
      throw StateError(availability.message);
    }

    final account = await _googleSignInInstance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google sign-in did not return an ID token for Firebase Auth.',
      );
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential = await _authInstance.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null || user.email == null || user.email!.trim().isEmpty) {
      throw StateError('Firebase Auth did not return a usable Google account.');
    }

    return CloudSyncSession(
      isConfigured: true,
      providerLabel: 'Google',
      userId: user.uid,
      email: user.email,
    );
  }

  @override
  Future<void> signOut() async {
    await initialize();
    if (!availability.isAvailable) {
      return;
    }

    await Future.wait([
      _authInstance.signOut(),
      _googleSignInInstance.signOut(),
    ]);
  }

  @override
  Future<void> applyMutations({
    required String userId,
    required String accountEmail,
    required List<CloudSyncMutation> mutations,
  }) async {
    await initialize();
    if (!availability.isAvailable) {
      throw StateError(availability.message);
    }

    final root = _firestoreInstance.collection('users').doc(userId);
    final profileRef = root.collection('_meta').doc('profile');
    await profileRef.set({
      'email': accountEmail,
      'provider': 'Google',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mutations.isEmpty) {
      return;
    }

    for (var start = 0; start < mutations.length; start += 400) {
      final batch = _firestoreInstance.batch();
      final chunk = mutations.skip(start).take(400);

      for (final mutation in chunk) {
        final deleteMarkerRef = root
            .collection('_deleted_entities')
            .doc(_deleteMarkerId(mutation.entityType, mutation.entityId));
        final documentRef = root
            .collection(_collectionName(mutation.entityType))
            .doc(mutation.entityId);
        if (mutation.changeType == SyncChangeType.delete) {
          batch.delete(documentRef);
          batch.set(deleteMarkerRef, {
            'entityType': mutation.entityType.name,
            'entityId': mutation.entityId,
            'localChangedAt': mutation.changedAt.toIso8601String(),
            'deletedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          continue;
        }

        batch.set(documentRef, {
          ...?mutation.payload,
          'entityType': mutation.entityType.name,
          'entityId': mutation.entityId,
          'localChangedAt': mutation.changedAt.toIso8601String(),
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        batch.delete(deleteMarkerRef);
      }

      await batch.commit();
    }
  }

  @override
  Future<List<CloudSyncRemoteChange>> fetchRemoteChanges({
    required String userId,
  }) async {
    await initialize();
    if (!availability.isAvailable) {
      throw StateError(availability.message);
    }

    final root = _firestoreInstance.collection('users').doc(userId);
    final changes = <CloudSyncRemoteChange>[];
    final supportedEntities = [
      SyncEntityType.recipe,
      SyncEntityType.pantryItem,
      SyncEntityType.groceryItem,
      SyncEntityType.savedMeal,
      SyncEntityType.dayPlan,
      SyncEntityType.mealPlan,
      SyncEntityType.foodLogEntry,
    ];

    for (final entityType in supportedEntities) {
      final snapshot = await root.collection(_collectionName(entityType)).get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final changedAt =
            _dateTimeFromValue(data['localChangedAt']) ??
            _dateTimeFromValue(data['updatedAt']) ??
            _dateTimeFromValue(data['createdAt']) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        changes.add(
          CloudSyncRemoteChange(
            entityType: entityType,
            entityId: doc.id,
            changeType: SyncChangeType.upsert,
            changedAt: changedAt,
            payload: data,
          ),
        );
      }
    }

    final deletionSnapshot = await root.collection('_deleted_entities').get();
    for (final doc in deletionSnapshot.docs) {
      final data = doc.data();
      final entityTypeName = data['entityType'];
      final entityId = data['entityId'];
      if (entityTypeName is! String || entityId is! String) {
        continue;
      }
      SyncEntityType? entityType;
      for (final type in SyncEntityType.values) {
        if (type.name == entityTypeName) {
          entityType = type;
          break;
        }
      }
      if (entityType == null || !supportedEntities.contains(entityType)) {
        continue;
      }

      changes.add(
        CloudSyncRemoteChange(
          entityType: entityType,
          entityId: entityId,
          changeType: SyncChangeType.delete,
          changedAt:
              _dateTimeFromValue(data['localChangedAt']) ??
              _dateTimeFromValue(data['deletedAt']) ??
              DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }

    changes.sort((left, right) => left.changedAt.compareTo(right.changedAt));
    return changes;
  }

  String _collectionName(SyncEntityType entityType) {
    return switch (entityType) {
      SyncEntityType.recipe => 'recipes',
      SyncEntityType.pantryItem => 'pantry_items',
      SyncEntityType.groceryItem => 'grocery_items',
      SyncEntityType.savedMeal => 'saved_meals',
      SyncEntityType.dayPlan => 'day_plans',
      SyncEntityType.mealPlan => 'meal_plans',
      SyncEntityType.foodLogEntry => 'food_log_entries',
    };
  }

  String _deleteMarkerId(SyncEntityType entityType, String entityId) {
    return '${entityType.name}_$entityId';
  }

  DateTime? _dateTimeFromValue(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
