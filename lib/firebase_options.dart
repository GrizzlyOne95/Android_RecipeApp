import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseSetupField {
  const FirebaseSetupField({
    required this.key,
    required this.description,
    required this.isProvided,
  });

  final String key;
  final String description;
  final bool isProvided;
}

class FirebaseSetupPlatformStatus {
  const FirebaseSetupPlatformStatus({
    required this.platformLabel,
    required this.appIdentifier,
    required this.fields,
  });

  final String platformLabel;
  final String appIdentifier;
  final List<FirebaseSetupField> fields;

  bool get isComplete => fields.every((field) => field.isProvided);

  List<FirebaseSetupField> get missingFields =>
      fields.where((field) => !field.isProvided).toList(growable: false);
}

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static String get projectId => _projectId;

  static String get androidApplicationId => 'com.istuart.recipeapp';

  static String get iosBundleId => _iosBundleId;

  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return null;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _androidOptions,
      TargetPlatform.iOS => _iosOptions,
      TargetPlatform.macOS => _macosOptions,
      _ => null,
    };
  }

  static bool get isConfigured => currentPlatform != null;

  static bool get isFirebaseCoreConfigured =>
      _projectId.isNotEmpty &&
      _messagingSenderId.isNotEmpty &&
      _storageBucket.isNotEmpty &&
      _androidAppId.isNotEmpty &&
      _iosAppId.isNotEmpty;

  static bool get isGoogleSignInConfiguredForCurrentPlatform =>
      missingGoogleSignInKeysForCurrentPlatform.isEmpty;

  static String? get googleSignInClientId {
    if (kIsWeb) {
      return _nonEmpty(_webClientId);
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => _nonEmpty(_iosClientId),
      _ => null,
    };
  }

  static String? get googleServerClientId => _nonEmpty(_webClientId);

  static List<String> get missingCoreKeys => [
    if (_projectId.isEmpty) 'FIREBASE_PROJECT_ID',
    if (_messagingSenderId.isEmpty) 'FIREBASE_MESSAGING_SENDER_ID',
    if (_storageBucket.isEmpty) 'FIREBASE_STORAGE_BUCKET',
    if (_androidAppId.isEmpty) 'FIREBASE_ANDROID_APP_ID',
    if (_iosAppId.isEmpty) 'FIREBASE_IOS_APP_ID',
    if (_iosBundleId.isEmpty) 'FIREBASE_IOS_BUNDLE_ID',
    if (_androidApiKey.isEmpty) 'FIREBASE_ANDROID_API_KEY',
    if (_iosApiKey.isEmpty) 'FIREBASE_IOS_API_KEY',
  ];

  static List<String> get missingGoogleSignInKeys => [
    if (_webClientId.isEmpty) 'FIREBASE_WEB_CLIENT_ID',
    if (_iosClientId.isEmpty) 'FIREBASE_IOS_CLIENT_ID',
  ];

  static List<String> get missingGoogleSignInKeysForCurrentPlatform {
    if (kIsWeb) {
      return const <String>['FIREBASE_WEB_CLIENT_ID'];
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => [
        if (_webClientId.isEmpty) 'FIREBASE_WEB_CLIENT_ID',
      ],
      TargetPlatform.iOS || TargetPlatform.macOS => [
        if (_webClientId.isEmpty) 'FIREBASE_WEB_CLIENT_ID',
        if (_iosClientId.isEmpty) 'FIREBASE_IOS_CLIENT_ID',
      ],
      _ => const <String>[],
    };
  }

  static List<FirebaseSetupPlatformStatus> get setupStatus => [
    FirebaseSetupPlatformStatus(
      platformLabel: 'Shared project',
      appIdentifier: _projectId.isEmpty ? 'Project not set yet' : _projectId,
      fields: [
        FirebaseSetupField(
          key: 'FIREBASE_PROJECT_ID',
          description: 'Firebase project id',
          isProvided: _projectId.isNotEmpty,
        ),
        FirebaseSetupField(
          key: 'FIREBASE_MESSAGING_SENDER_ID',
          description: 'Messaging sender id',
          isProvided: _messagingSenderId.isNotEmpty,
        ),
        FirebaseSetupField(
          key: 'FIREBASE_STORAGE_BUCKET',
          description: 'Storage bucket',
          isProvided: _storageBucket.isNotEmpty,
        ),
        FirebaseSetupField(
          key: 'FIREBASE_WEB_CLIENT_ID',
          description: 'Google OAuth web client id used to mint Firebase ID tokens',
          isProvided: _webClientId.isNotEmpty,
        ),
      ],
    ),
    FirebaseSetupPlatformStatus(
      platformLabel: 'Android',
      appIdentifier: androidApplicationId,
      fields: [
        FirebaseSetupField(
          key: 'FIREBASE_ANDROID_API_KEY',
          description: 'Android API key',
          isProvided: _androidApiKey.isNotEmpty,
        ),
        FirebaseSetupField(
          key: 'FIREBASE_ANDROID_APP_ID',
          description: 'Android app id',
          isProvided: _androidAppId.isNotEmpty,
        ),
      ],
    ),
    FirebaseSetupPlatformStatus(
      platformLabel: 'iOS',
      appIdentifier: iosBundleId,
      fields: [
        FirebaseSetupField(
          key: 'FIREBASE_IOS_API_KEY',
          description: 'iOS API key',
          isProvided: _iosApiKey.isNotEmpty,
        ),
        FirebaseSetupField(
          key: 'FIREBASE_IOS_APP_ID',
          description: 'iOS app id',
          isProvided: _iosAppId.isNotEmpty,
        ),
        FirebaseSetupField(
          key: 'FIREBASE_IOS_CLIENT_ID',
          description: 'iOS Google OAuth client id from GoogleService-Info.plist',
          isProvided: _iosClientId.isNotEmpty,
        ),
        FirebaseSetupField(
          key: 'FIREBASE_IOS_BUNDLE_ID',
          description: 'iOS bundle identifier override',
          isProvided: _iosBundleId.isNotEmpty,
        ),
      ],
    ),
  ];

  static List<String> get missingKeys => [
    for (final platform in setupStatus)
      for (final field in platform.missingFields) field.key,
  ];

  static String get setupHint {
    if (!isFirebaseCoreConfigured) {
      return 'Firebase setup is still missing ${_formatKeyList(missingCoreKeys)}.';
    }
    if (!isGoogleSignInConfiguredForCurrentPlatform) {
      return 'Firebase project $_projectId is wired, but Google sign-in still needs ${_formatKeyList(missingGoogleSignInKeysForCurrentPlatform)} on this device.';
    }
    return 'Firebase project $_projectId is configured for optional Google sign-in and Firestore sync.';
  }

  static String get exampleFlutterRunCommand =>
      'flutter run -d emulator-5554 '
      '--dart-define FIREBASE_PROJECT_ID=$_projectId '
      '--dart-define FIREBASE_MESSAGING_SENDER_ID=$_messagingSenderId '
      '--dart-define FIREBASE_STORAGE_BUCKET=$_storageBucket '
      '--dart-define FIREBASE_WEB_CLIENT_ID=${_valueOrPlaceholder(_webClientId, '<web-client-id>')} '
      '--dart-define FIREBASE_ANDROID_API_KEY=${_valueOrPlaceholder(_androidApiKey, '<android-api-key>')} '
      '--dart-define FIREBASE_ANDROID_APP_ID=$_androidAppId '
      '--dart-define FIREBASE_IOS_API_KEY=${_valueOrPlaceholder(_iosApiKey, '<ios-api-key>')} '
      '--dart-define FIREBASE_IOS_APP_ID=$_iosAppId '
      '--dart-define FIREBASE_IOS_CLIENT_ID=${_valueOrPlaceholder(_iosClientId, '<ios-client-id>')} '
      '--dart-define FIREBASE_IOS_BUNDLE_ID=$_iosBundleId';

  static FirebaseOptions? get _androidOptions {
    if (!_hasRequiredValues(_androidApiKey, _androidAppId)) {
      return null;
    }

    return FirebaseOptions(
      apiKey: _androidApiKey,
      appId: _androidAppId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _nonEmpty(_storageBucket),
    );
  }

  static FirebaseOptions? get _iosOptions {
    if (!_hasRequiredValues(_iosApiKey, _iosAppId)) {
      return null;
    }

    return FirebaseOptions(
      apiKey: _iosApiKey,
      appId: _iosAppId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _nonEmpty(_storageBucket),
      iosClientId: _nonEmpty(_iosClientId),
      iosBundleId: _nonEmpty(_iosBundleId),
    );
  }

  static FirebaseOptions? get _macosOptions {
    if (!_hasRequiredValues(_iosApiKey, _iosAppId)) {
      return null;
    }

    return FirebaseOptions(
      apiKey: _iosApiKey,
      appId: _iosAppId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _nonEmpty(_storageBucket),
      iosClientId: _nonEmpty(_iosClientId),
      iosBundleId: _nonEmpty(_iosBundleId),
    );
  }

  static bool _hasRequiredValues(
    String apiKey,
    String appId, [
    String? client,
  ]) {
    return apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        _messagingSenderId.isNotEmpty &&
        _projectId.isNotEmpty &&
        (client == null || client.isNotEmpty);
  }

  static String _formatKeyList(List<String> keys) {
    if (keys.isEmpty) {
      return 'nothing';
    }
    if (keys.length == 1) {
      return keys.single;
    }
    if (keys.length == 2) {
      return '${keys.first} and ${keys.last}';
    }
    return '${keys.sublist(0, keys.length - 1).join(', ')}, and ${keys.last}';
  }

  static String _valueOrPlaceholder(String value, String placeholder) {
    return value.isEmpty ? placeholder : value;
  }

  static String? _nonEmpty(String value) => value.isEmpty ? null : value;

  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'nutrichef-recipeapp-6d24f',
  );
  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '144405192913',
  );
  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'nutrichef-recipeapp-6d24f.firebasestorage.app',
  );
  static const String _webClientId = String.fromEnvironment(
    'FIREBASE_WEB_CLIENT_ID',
  );

  static const String _androidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );
  static const String _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
    defaultValue: '1:144405192913:android:0de9c5034bc37c52d9e5f0',
  );

  static const String _iosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
  );
  static const String _iosAppId = String.fromEnvironment(
    'FIREBASE_IOS_APP_ID',
    defaultValue: '1:144405192913:ios:fb8a8be93d31a042d9e5f0',
  );
  static const String _iosClientId = String.fromEnvironment(
    'FIREBASE_IOS_CLIENT_ID',
  );
  static const String _iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'com.istuart.recipeapp.recipeApp',
  );
}
