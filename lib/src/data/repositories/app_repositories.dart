import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../core/measurement_units.dart';
import '../../core/mock_data.dart';
import '../../core/sync_models.dart';
import '../local/app_database.dart';
import '../sync/cloud_sync_gateway.dart';

class AppRepositories {
  factory AppRepositories(
    AppDatabase database, {
    CloudSyncGateway? cloudSyncGateway,
  }) {
    final sync = SyncRepository(database, cloudGateway: cloudSyncGateway);
    return AppRepositories._(
      database: database,
      sync: sync,
      recipes: RecipesRepository(database, sync),
      pantry: PantryRepository(database, sync),
      grocery: GroceryRepository(database, sync),
      foodLog: FoodLogRepository(database, sync),
    );
  }

  AppRepositories._({
    required this.database,
    required this.sync,
    required this.recipes,
    required this.pantry,
    required this.grocery,
    required this.foodLog,
  });

  final AppDatabase database;
  final SyncRepository sync;
  final RecipesRepository recipes;
  final PantryRepository pantry;
  final GroceryRepository grocery;
  final FoodLogRepository foodLog;

  Future<void> initialize() async {
    await database.seedIfEmpty();
    await sync.initialize();
  }
}

class SyncRepository {
  SyncRepository(this._database, {CloudSyncGateway? cloudGateway})
    : _cloudGateway = cloudGateway ?? FirebaseCloudSyncGateway();

  final AppDatabase _database;
  final CloudSyncGateway _cloudGateway;

  static const _authStateKey = 'sync.auth_state';
  static const _providerKey = 'sync.provider';
  static const _accountEmailKey = 'sync.account_email';
  static const _accountIdKey = 'sync.account_id';
  static const _connectedAtKey = 'sync.connected_at';
  static const _lastSyncedAtKey = 'sync.last_synced_at';
  static const _lastErrorKey = 'sync.last_error';
  static const _lastConflictKey = 'sync.last_conflict';
  static const _syncStateKey = 'sync.state';
  static const _groceryGeneratedStateSectionTitle =
      '__Generated Grocery State__';
  static const _generatedStateSectionId = '__grocery_generated_state__';
  static const _groceryManualDetailSeparator = '||';

  Future<void> initialize() async {
    await _cloudGateway.initialize();
    await _persistSession(await _cloudGateway.currentSession());
  }

  Stream<SyncStatus> watchStatus() {
    final settingsQuery = _database.select(_database.appSettingsTable).watch();
    final queueQuery = (_database.select(
      _database.syncQueueTable,
    )..orderBy([(table) => OrderingTerm.desc(table.changedAt)])).watch();

    return settingsQuery.combineLatest(queueQuery, (settings, queueRows) {
      final settingsByKey = {for (final row in settings) row.key: row.value};
      final authState = _authStateFromValue(settingsByKey[_authStateKey]);
      final countsByType = <SyncEntityType, int>{};
      DateTime? lastLocalChangeAt;

      for (final row in queueRows) {
        final entityType = _entityTypeFromName(row.entityType);
        countsByType.update(
          entityType,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
        if (lastLocalChangeAt == null ||
            row.changedAt.isAfter(lastLocalChangeAt)) {
          lastLocalChangeAt = row.changedAt;
        }
      }

      final pendingItems =
          countsByType.entries
              .map(
                (entry) =>
                    SyncEntityCount(entityType: entry.key, count: entry.value),
              )
              .toList(growable: true)
            ..sort((left, right) {
              final byCount = right.count.compareTo(left.count);
              if (byCount != 0) {
                return byCount;
              }
              return left.entityType.label.compareTo(right.entityType.label);
            });

      return SyncStatus(
        authState: authState,
        isCloudConfigured: _cloudGateway.availability.isAvailable,
        cloudStatusMessage: _cloudGateway.availability.message,
        providerLabel: settingsByKey[_providerKey],
        accountEmail: settingsByKey[_accountEmailKey],
        accountId: settingsByKey[_accountIdKey],
        connectedAt: _dateTimeFromString(settingsByKey[_connectedAtKey]),
        lastLocalChangeAt: lastLocalChangeAt,
        lastSyncedAt: _dateTimeFromString(settingsByKey[_lastSyncedAtKey]),
        lastErrorMessage: _normalizedOptionalText(settingsByKey[_lastErrorKey]),
        lastConflictMessage: _normalizedOptionalText(
          settingsByKey[_lastConflictKey],
        ),
        isSyncing: settingsByKey[_syncStateKey] == 'syncing',
        pendingItems: pendingItems,
      );
    });
  }

  Stream<List<SyncQueueItem>> watchQueueItems() {
    return (_database.select(
      _database.syncQueueTable,
    )..orderBy([(table) => OrderingTerm.desc(table.changedAt)])).watch().map(
      (rows) => rows
          .map(
            (row) => SyncQueueItem(
              entityType: _entityTypeFromName(row.entityType),
              entityId: row.entityId,
              changeType: _changeTypeFromName(row.changeType),
              changedAt: row.changedAt,
              displayLabel: row.displayLabel,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<SyncActionResult> connectGoogleAccount() async {
    await _cloudGateway.initialize();
    if (!_cloudGateway.availability.isAvailable) {
      return _fail(_cloudGateway.availability.message);
    }

    try {
      final session = await _cloudGateway.signInWithGoogle();
      await _persistSession(session);
      final syncResult = await syncNow();
      if (!syncResult.isSuccess) {
        return SyncActionResult(
          isSuccess: true,
          message: 'Google account connected. ${syncResult.message}',
        );
      }
      return const SyncActionResult(
        isSuccess: true,
        message: 'Google account connected and pending changes synced.',
      );
    } on Object catch (error) {
      await _persistSession(
        const CloudSyncSession(isConfigured: false, providerLabel: 'Google'),
      );
      return _fail(_syncErrorFrom(error));
    }
  }

  Future<SyncActionResult> disconnect() async {
    await _cloudGateway.signOut();
    await _clearSyncError();
    await _database.transaction(() async {
      await _deleteSetting(_authStateKey);
      await _deleteSetting(_providerKey);
      await _deleteSetting(_accountEmailKey);
      await _deleteSetting(_accountIdKey);
      await _deleteSetting(_connectedAtKey);
    });
    return const SyncActionResult(
      isSuccess: true,
      message: 'Google account disconnected. Local data stays on device.',
    );
  }

  Future<SyncActionResult> syncNow() async {
    await _cloudGateway.initialize();
    if (!_cloudGateway.availability.isAvailable) {
      return _fail(_cloudGateway.availability.message);
    }

    final session = await _cloudGateway.currentSession();
    await _persistSession(session);
    if (!session.isConnected ||
        session.userId == null ||
        session.email == null) {
      return _fail('Connect a Google account before running cloud sync.');
    }

    await _setSyncing(true);
    try {
      final remoteChanges = await _cloudGateway.fetchRemoteChanges(
        userId: session.userId!,
      );
      final initialQueueRows = await (_database.select(
        _database.syncQueueTable,
      )..orderBy([(table) => OrderingTerm(expression: table.changedAt)])).get();
      final mergeResult = await _mergeRemoteChanges(
        remoteChanges,
        initialQueueRows,
      );

      final queueRows = await (_database.select(
        _database.syncQueueTable,
      )..orderBy([(table) => OrderingTerm(expression: table.changedAt)])).get();

      final mutations = <CloudSyncMutation>[];
      for (final row in queueRows) {
        mutations.add(await _buildMutation(row));
      }

      await _cloudGateway.applyMutations(
        userId: session.userId!,
        accountEmail: session.email!,
        mutations: mutations,
      );
      await _clearQueueEntries(queueRows);

      final now = DateTime.now();
      await _upsertSetting(_lastSyncedAtKey, now.toIso8601String(), now);
      await _clearSyncError();

      return SyncActionResult(
        isSuccess: true,
        message: _syncSummaryMessage(
          remoteAppliedCount: mergeResult.remoteAppliedCount,
          conflictCount: mergeResult.conflictCount,
          pushedMutationCount: mutations.length,
        ),
      );
    } on Object catch (error) {
      return _fail(_syncErrorFrom(error));
    } finally {
      await _setSyncing(false);
    }
  }

  Future<void> recordChange({
    required SyncEntityType entityType,
    required String entityId,
    required SyncChangeType changeType,
    String? displayLabel,
  }) {
    final normalizedId = entityId.trim();
    if (normalizedId.isEmpty) {
      return Future.value();
    }

    return _database
        .into(_database.syncQueueTable)
        .insertOnConflictUpdate(
          SyncQueueTableCompanion.insert(
            entityType: entityType.name,
            entityId: normalizedId,
            changeType: changeType.name,
            changedAt: DateTime.now(),
            displayLabel: Value(_normalizedOptionalText(displayLabel)),
          ),
        );
  }

  Future<CloudSyncMutation> _buildMutation(SyncQueueTableData row) async {
    final entityType = _entityTypeFromName(row.entityType);
    final changeType = _changeTypeFromName(row.changeType);

    if (changeType == SyncChangeType.delete) {
      return CloudSyncMutation(
        entityType: entityType,
        entityId: row.entityId,
        changeType: changeType,
        changedAt: row.changedAt,
      );
    }

    return switch (entityType) {
      SyncEntityType.recipe => _buildRecipeMutation(row),
      SyncEntityType.pantryItem => _buildPantryMutation(row),
      SyncEntityType.groceryItem => _buildGroceryMutation(row),
      SyncEntityType.savedMeal => _buildSavedMealMutation(row),
      SyncEntityType.dayPlan => _buildDayPlanMutation(row),
      SyncEntityType.foodLogEntry => _buildFoodLogMutation(row),
    };
  }

  Future<CloudSyncMutation> _buildRecipeMutation(SyncQueueTableData row) async {
    final recipe = await (_database.select(
      _database.recipes,
    )..where((table) => table.id.equals(row.entityId))).getSingleOrNull();
    if (recipe == null) {
      return _missingEntityDelete(row, SyncEntityType.recipe);
    }

    final tags =
        await (_database.select(_database.recipeTags)
              ..where((table) => table.recipeId.equals(recipe.id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();
    final ingredients =
        await (_database.select(_database.recipeIngredients)
              ..where((table) => table.recipeId.equals(recipe.id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();
    final directions =
        await (_database.select(_database.recipeDirections)
              ..where((table) => table.recipeId.equals(recipe.id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();

    return CloudSyncMutation(
      entityType: SyncEntityType.recipe,
      entityId: recipe.id,
      changeType: SyncChangeType.upsert,
      changedAt: row.changedAt,
      payload: {
        'id': recipe.id,
        'title': recipe.title,
        'versionLabel': recipe.versionLabel,
        'notes': recipe.notes,
        'servings': recipe.servings,
        'isPinned': recipe.isPinned,
        'sortCalories': recipe.sortCalories,
        'nutrition': _nutritionPayload(
          calories: recipe.calories,
          protein: recipe.protein,
          carbs: recipe.carbs,
          fat: recipe.fat,
          fiber: recipe.fiber,
          sodium: recipe.sodium,
          sugar: recipe.sugar,
        ),
        'createdAt': recipe.createdAt.toIso8601String(),
        'updatedAt': recipe.updatedAt.toIso8601String(),
        'tags': [
          for (final tag in tags)
            {'label': tag.label, 'position': tag.position},
        ],
        'ingredients': [
          for (final ingredient in ingredients)
            {
              'position': ingredient.position,
              'quantity': ingredient.quantity,
              'unit': ingredient.unit,
              'item': ingredient.item,
              'preparation': ingredient.preparation,
              'ingredientType': ingredient.ingredientType,
              'linkedPantryItemId': ingredient.linkedPantryItemId,
              'linkedRecipeId': ingredient.linkedRecipeId,
            },
        ],
        'directions': [
          for (final direction in directions)
            {
              'position': direction.position,
              'instruction': direction.instruction,
            },
        ],
      },
    );
  }

  Future<CloudSyncMutation> _buildPantryMutation(SyncQueueTableData row) async {
    final item = await (_database.select(
      _database.pantryItemsTable,
    )..where((table) => table.id.equals(row.entityId))).getSingleOrNull();
    if (item == null) {
      return _missingEntityDelete(row, SyncEntityType.pantryItem);
    }

    return CloudSyncMutation(
      entityType: SyncEntityType.pantryItem,
      entityId: item.id,
      changeType: SyncChangeType.upsert,
      changedAt: row.changedAt,
      payload: {
        'id': item.id,
        'title': item.title,
        'quantityLabel': item.quantityLabel,
        'referenceUnitQuantity': item.referenceUnitQuantity,
        'referenceUnit': item.referenceUnit,
        'referenceUnitEquivalentQuantity': item.referenceUnitEquivalentQuantity,
        'referenceUnitEquivalentUnit': item.referenceUnitEquivalentUnit,
        'referenceUnitWeightGrams': item.referenceUnitWeightGrams,
        'source': item.source,
        'accentHex': item.accentHex,
        'barcode': item.barcode,
        'brand': item.brand,
        'imageUrl': item.imageUrl,
        'nutrition': _nutritionPayload(
          calories: item.calories,
          protein: item.protein,
          carbs: item.carbs,
          fat: item.fat,
          fiber: item.fiber,
          sodium: item.sodium,
          sugar: item.sugar,
        ),
        'createdAt': item.createdAt.toIso8601String(),
        'updatedAt': (item.updatedAt ?? item.createdAt).toIso8601String(),
      },
    );
  }

  Future<CloudSyncMutation> _buildGroceryMutation(
    SyncQueueTableData row,
  ) async {
    final manualId = int.tryParse(row.entityId);
    if (manualId != null) {
      final item = await (_database.select(
        _database.groceryItemsTable,
      )..where((table) => table.id.equals(manualId))).getSingleOrNull();
      if (item == null) {
        return _missingEntityDelete(row, SyncEntityType.groceryItem);
      }
      final section = await (_database.select(
        _database.grocerySectionsTable,
      )..where((table) => table.id.equals(item.sectionId))).getSingleOrNull();

      return CloudSyncMutation(
        entityType: SyncEntityType.groceryItem,
        entityId: row.entityId,
        changeType: SyncChangeType.upsert,
        changedAt: row.changedAt,
        payload: {
          'id': item.id.toString(),
          'sectionId': item.sectionId,
          'sectionTitle': section?.title,
          'label': item.label,
          'position': item.position,
          'isChecked': item.isChecked,
          'isGeneratedState': false,
        },
      );
    }

    final generatedState =
        await (_database.select(_database.groceryItemsTable)..where(
              (table) =>
                  table.sectionId.equals(_generatedStateSectionId) &
                  table.label.equals(row.entityId),
            ))
            .getSingleOrNull();
    if (generatedState == null) {
      return _missingEntityDelete(row, SyncEntityType.groceryItem);
    }

    return CloudSyncMutation(
      entityType: SyncEntityType.groceryItem,
      entityId: row.entityId,
      changeType: SyncChangeType.upsert,
      changedAt: row.changedAt,
      payload: {
        'id': row.entityId,
        'sectionId': generatedState.sectionId,
        'sectionTitle': 'Generated State',
        'label': generatedState.label,
        'position': generatedState.position,
        'isChecked': generatedState.isChecked,
        'isGeneratedState': true,
      },
    );
  }

  Future<CloudSyncMutation> _buildSavedMealMutation(
    SyncQueueTableData row,
  ) async {
    final meal = await (_database.select(
      _database.savedMealsTable,
    )..where((table) => table.id.equals(row.entityId))).getSingleOrNull();
    if (meal == null) {
      return _missingEntityDelete(row, SyncEntityType.savedMeal);
    }

    final adjustments =
        await (_database.select(_database.savedMealAdjustments)
              ..where((table) => table.mealId.equals(meal.id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();
    final components =
        await (_database.select(_database.savedMealComponents)
              ..where((table) => table.mealId.equals(meal.id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();

    return CloudSyncMutation(
      entityType: SyncEntityType.savedMeal,
      entityId: meal.id,
      changeType: SyncChangeType.upsert,
      changedAt: row.changedAt,
      payload: {
        'id': meal.id,
        'title': meal.title,
        'nutrition': _nutritionPayload(
          calories: meal.calories,
          protein: meal.protein,
          carbs: meal.carbs,
          fat: meal.fat,
          fiber: meal.fiber,
          sodium: meal.sodium,
          sugar: meal.sugar,
        ),
        'createdAt': meal.createdAt.toIso8601String(),
        'adjustments': [
          for (final adjustment in adjustments)
            {'label': adjustment.label, 'position': adjustment.position},
        ],
        'components': [
          for (final component in components)
            {
              'position': component.position,
              'quantity': component.quantity,
              'unit': component.unit,
              'item': component.item,
              'componentType': component.componentType,
              'linkedPantryItemId': component.linkedPantryItemId,
              'linkedRecipeId': component.linkedRecipeId,
            },
        ],
      },
    );
  }

  Future<CloudSyncMutation> _buildDayPlanMutation(
    SyncQueueTableData row,
  ) async {
    final plan = await (_database.select(
      _database.dayPlansTable,
    )..where((table) => table.id.equals(row.entityId))).getSingleOrNull();
    if (plan == null) {
      return _missingEntityDelete(row, SyncEntityType.dayPlan);
    }

    final entries =
        await (_database.select(_database.dayPlanEntriesTable)
              ..where((table) => table.planId.equals(plan.id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();

    return CloudSyncMutation(
      entityType: SyncEntityType.dayPlan,
      entityId: plan.id,
      changeType: SyncChangeType.upsert,
      changedAt: row.changedAt,
      payload: {
        'id': plan.id,
        'title': plan.title,
        'note': plan.note,
        'createdAt': plan.createdAt.toIso8601String(),
        'entries': [
          for (final entry in entries)
            {
              'position': entry.position,
              'mealSlot': entry.mealSlot,
              'sourceType': entry.sourceType,
              'sourceId': entry.sourceId,
              'title': entry.title,
              'quantity': entry.quantity,
              'unit': entry.unit,
              'nutrition': _nutritionPayload(
                calories: entry.calories,
                protein: entry.protein,
                carbs: entry.carbs,
                fat: entry.fat,
                fiber: entry.fiber,
                sodium: entry.sodium,
                sugar: entry.sugar,
              ),
            },
        ],
      },
    );
  }

  Future<CloudSyncMutation> _buildFoodLogMutation(
    SyncQueueTableData row,
  ) async {
    final entry = await (_database.select(
      _database.foodLogEntriesTable,
    )..where((table) => table.id.equals(row.entityId))).getSingleOrNull();
    if (entry == null) {
      return _missingEntityDelete(row, SyncEntityType.foodLogEntry);
    }

    return CloudSyncMutation(
      entityType: SyncEntityType.foodLogEntry,
      entityId: entry.id,
      changeType: SyncChangeType.upsert,
      changedAt: row.changedAt,
      payload: {
        'id': entry.id,
        'entryDate': entry.entryDate,
        'mealSlot': entry.mealSlot,
        'sourceType': entry.sourceType,
        'sourceId': entry.sourceId,
        'title': entry.title,
        'quantity': entry.quantity,
        'unit': entry.unit,
        'nutrition': _nutritionPayload(
          calories: entry.calories,
          protein: entry.protein,
          carbs: entry.carbs,
          fat: entry.fat,
          fiber: entry.fiber,
          sodium: entry.sodium,
          sugar: entry.sugar,
        ),
        'createdAt': entry.createdAt.toIso8601String(),
      },
    );
  }

  CloudSyncMutation _missingEntityDelete(
    SyncQueueTableData row,
    SyncEntityType entityType,
  ) {
    return CloudSyncMutation(
      entityType: entityType,
      entityId: row.entityId,
      changeType: SyncChangeType.delete,
      changedAt: row.changedAt,
    );
  }

  Map<String, Object?> _nutritionPayload({
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required int fiber,
    required int sodium,
    required int sugar,
  }) {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sodium': sodium,
      'sugar': sugar,
    };
  }

  Future<void> _clearQueueEntries(List<SyncQueueTableData> rows) async {
    for (final row in rows) {
      await (_database.delete(_database.syncQueueTable)..where(
            (table) =>
                table.entityType.equals(row.entityType) &
                table.entityId.equals(row.entityId),
          ))
          .go();
    }
  }

  Future<SyncActionResult> _fail(String message) async {
    final normalizedMessage =
        _normalizedOptionalText(message) ?? 'Sync failed.';
    await _upsertSetting(_lastErrorKey, normalizedMessage, DateTime.now());
    return SyncActionResult(isSuccess: false, message: normalizedMessage);
  }

  Future<void> _persistSession(CloudSyncSession session) async {
    final now = DateTime.now();
    if (!session.isConnected ||
        session.userId == null ||
        session.email == null) {
      await _database.transaction(() async {
        await _deleteSetting(_authStateKey);
        await _deleteSetting(_providerKey);
        await _deleteSetting(_accountEmailKey);
        await _deleteSetting(_accountIdKey);
        await _deleteSetting(_connectedAtKey);
      });
      return;
    }

    await _database.transaction(() async {
      await _upsertSetting(_authStateKey, SyncAuthState.connected.name, now);
      await _upsertSetting(_providerKey, session.providerLabel.trim(), now);
      await _upsertSetting(_accountEmailKey, session.email!.trim(), now);
      await _upsertSetting(_accountIdKey, session.userId!.trim(), now);
      await _upsertSetting(_connectedAtKey, now.toIso8601String(), now);
    });
  }

  Future<void> _setSyncing(bool isSyncing) {
    final value = isSyncing ? 'syncing' : 'idle';
    return _upsertSetting(_syncStateKey, value, DateTime.now());
  }

  Future<void> _clearSyncError() {
    return _upsertSetting(_lastErrorKey, null, DateTime.now());
  }

  Future<void> _setConflictSummary(String? message) {
    return _upsertSetting(_lastConflictKey, message, DateTime.now());
  }

  Future<_RemoteMergeResult> _mergeRemoteChanges(
    List<CloudSyncRemoteChange> remoteChanges,
    List<SyncQueueTableData> pendingQueueRows,
  ) async {
    final pendingByKey = {
      for (final row in pendingQueueRows)
        _queueKey(row.entityType, row.entityId): row,
    };
    final conflicts = <String>[];
    var remoteAppliedCount = 0;

    for (final change in remoteChanges) {
      final pendingRow =
          pendingByKey[_queueKey(change.entityType.name, change.entityId)];

      switch (change.entityType) {
        case SyncEntityType.recipe:
          final resolution = await _mergeRemoteRecipe(change, pendingRow);
          if (resolution.appliedRemote) {
            remoteAppliedCount += 1;
          }
          if (resolution.conflictMessage case final message?) {
            conflicts.add(message);
          }
        case SyncEntityType.pantryItem:
          final resolution = await _mergeRemotePantryItem(change, pendingRow);
          if (resolution.appliedRemote) {
            remoteAppliedCount += 1;
          }
          if (resolution.conflictMessage case final message?) {
            conflicts.add(message);
          }
        case SyncEntityType.groceryItem:
          final resolution = await _mergeRemoteGroceryItem(change, pendingRow);
          if (resolution.appliedRemote) {
            remoteAppliedCount += 1;
          }
          if (resolution.conflictMessage case final message?) {
            conflicts.add(message);
          }
        case SyncEntityType.savedMeal:
          final resolution = await _mergeRemoteSavedMeal(change, pendingRow);
          if (resolution.appliedRemote) {
            remoteAppliedCount += 1;
          }
          if (resolution.conflictMessage case final message?) {
            conflicts.add(message);
          }
        case SyncEntityType.dayPlan:
          final resolution = await _mergeRemoteDayPlan(change, pendingRow);
          if (resolution.appliedRemote) {
            remoteAppliedCount += 1;
          }
          if (resolution.conflictMessage case final message?) {
            conflicts.add(message);
          }
        case SyncEntityType.foodLogEntry:
          final resolution = await _mergeRemoteFoodLogEntry(change, pendingRow);
          if (resolution.appliedRemote) {
            remoteAppliedCount += 1;
          }
          if (resolution.conflictMessage case final message?) {
            conflicts.add(message);
          }
      }
    }

    await _setConflictSummary(
      conflicts.isEmpty
          ? null
          : conflicts.length == 1
          ? conflicts.single
          : '${conflicts.length} sync conflicts were resolved during merge. ${conflicts.first}',
    );

    return _RemoteMergeResult(
      remoteAppliedCount: remoteAppliedCount,
      conflictCount: conflicts.length,
    );
  }

  Future<_RemoteResolution> _mergeRemoteRecipe(
    CloudSyncRemoteChange change,
    SyncQueueTableData? pendingRow,
  ) async {
    final localRecipe = await (_database.select(
      _database.recipes,
    )..where((table) => table.id.equals(change.entityId))).getSingleOrNull();
    final localChangedAt = localRecipe?.updatedAt ?? localRecipe?.createdAt;
    final localTitle =
        localRecipe?.title ?? change.payload?['title'] as String?;

    if (pendingRow != null) {
      if (change.changedAt.isAfter(pendingRow.changedAt)) {
        if (change.changeType == SyncChangeType.delete) {
          await _deleteRecipeLocally(change.entityId);
        } else {
          await _applyRemoteRecipe(change);
        }
        await _removeQueueEntry(SyncEntityType.recipe, change.entityId);
        return _RemoteResolution(
          appliedRemote: true,
          conflictMessage:
              'Cloud recipe change won over an older local edit for ${localTitle ?? change.entityId}.',
        );
      }

      return _RemoteResolution(
        conflictMessage:
            'Kept newer local recipe edits for ${localTitle ?? change.entityId}.',
      );
    }

    if (change.changeType == SyncChangeType.delete) {
      if (localRecipe == null) {
        return const _RemoteResolution();
      }
      if (localChangedAt != null && localChangedAt.isAfter(change.changedAt)) {
        return const _RemoteResolution();
      }
      await _deleteRecipeLocally(change.entityId);
      return const _RemoteResolution(appliedRemote: true);
    }

    if (localChangedAt != null && !change.changedAt.isAfter(localChangedAt)) {
      return const _RemoteResolution();
    }

    await _applyRemoteRecipe(change);
    return const _RemoteResolution(appliedRemote: true);
  }

  Future<_RemoteResolution> _mergeRemotePantryItem(
    CloudSyncRemoteChange change,
    SyncQueueTableData? pendingRow,
  ) async {
    final localItem = await (_database.select(
      _database.pantryItemsTable,
    )..where((table) => table.id.equals(change.entityId))).getSingleOrNull();
    final localChangedAt = localItem?.updatedAt ?? localItem?.createdAt;
    final localTitle = localItem?.title ?? change.payload?['title'] as String?;

    if (pendingRow != null) {
      if (change.changedAt.isAfter(pendingRow.changedAt)) {
        if (change.changeType == SyncChangeType.delete) {
          await _deletePantryItemLocally(change.entityId);
        } else {
          await _applyRemotePantryItem(change);
        }
        await _removeQueueEntry(SyncEntityType.pantryItem, change.entityId);
        return _RemoteResolution(
          appliedRemote: true,
          conflictMessage:
              'Cloud pantry change won over an older local edit for ${localTitle ?? change.entityId}.',
        );
      }

      return _RemoteResolution(
        conflictMessage:
            'Kept newer local pantry edits for ${localTitle ?? change.entityId}.',
      );
    }

    if (change.changeType == SyncChangeType.delete) {
      if (localItem == null) {
        return const _RemoteResolution();
      }
      if (localChangedAt != null && localChangedAt.isAfter(change.changedAt)) {
        return const _RemoteResolution();
      }
      await _deletePantryItemLocally(change.entityId);
      return const _RemoteResolution(appliedRemote: true);
    }

    if (localChangedAt != null && !change.changedAt.isAfter(localChangedAt)) {
      return const _RemoteResolution();
    }

    await _applyRemotePantryItem(change);
    return const _RemoteResolution(appliedRemote: true);
  }

  Future<_RemoteResolution> _mergeRemoteGroceryItem(
    CloudSyncRemoteChange change,
    SyncQueueTableData? pendingRow,
  ) async {
    final localLabel = await _localGroceryLabel(change.entityId);
    final displayLabel = _remoteGroceryDisplayLabel(change.payload, localLabel);

    if (pendingRow != null) {
      if (change.changedAt.isAfter(pendingRow.changedAt)) {
        if (change.changeType == SyncChangeType.delete) {
          await _deleteGroceryItemLocally(change.entityId);
        } else {
          await _applyRemoteGroceryItem(change);
        }
        await _removeQueueEntry(SyncEntityType.groceryItem, change.entityId);
        return _RemoteResolution(
          appliedRemote: true,
          conflictMessage:
              'Cloud grocery change won over an older local edit for $displayLabel.',
        );
      }

      return _RemoteResolution(
        conflictMessage: 'Kept newer local grocery edits for $displayLabel.',
      );
    }

    if (change.changeType == SyncChangeType.delete) {
      final deleted = await _deleteGroceryItemLocally(change.entityId);
      return _RemoteResolution(appliedRemote: deleted);
    }

    await _applyRemoteGroceryItem(change);
    return const _RemoteResolution(appliedRemote: true);
  }

  Future<_RemoteResolution> _mergeRemoteSavedMeal(
    CloudSyncRemoteChange change,
    SyncQueueTableData? pendingRow,
  ) async {
    final localMeal = await (_database.select(
      _database.savedMealsTable,
    )..where((table) => table.id.equals(change.entityId))).getSingleOrNull();
    final displayLabel =
        localMeal?.title ??
        _stringValue(change.payload?['title']) ??
        change.entityId;

    if (pendingRow != null) {
      if (change.changedAt.isAfter(pendingRow.changedAt)) {
        if (change.changeType == SyncChangeType.delete) {
          await _deleteSavedMealLocally(change.entityId);
        } else {
          await _applyRemoteSavedMeal(change);
        }
        await _removeQueueEntry(SyncEntityType.savedMeal, change.entityId);
        return _RemoteResolution(
          appliedRemote: true,
          conflictMessage:
              'Cloud saved meal change won over an older local edit for $displayLabel.',
        );
      }

      return _RemoteResolution(
        conflictMessage: 'Kept newer local saved meal edits for $displayLabel.',
      );
    }

    if (change.changeType == SyncChangeType.delete) {
      final deleted = await _deleteSavedMealLocally(change.entityId);
      return _RemoteResolution(appliedRemote: deleted);
    }

    await _applyRemoteSavedMeal(change);
    return const _RemoteResolution(appliedRemote: true);
  }

  Future<_RemoteResolution> _mergeRemoteDayPlan(
    CloudSyncRemoteChange change,
    SyncQueueTableData? pendingRow,
  ) async {
    final localPlan = await (_database.select(
      _database.dayPlansTable,
    )..where((table) => table.id.equals(change.entityId))).getSingleOrNull();
    final displayLabel =
        localPlan?.title ??
        _stringValue(change.payload?['title']) ??
        change.entityId;

    if (pendingRow != null) {
      if (change.changedAt.isAfter(pendingRow.changedAt)) {
        if (change.changeType == SyncChangeType.delete) {
          await _deleteDayPlanLocally(change.entityId);
        } else {
          await _applyRemoteDayPlan(change);
        }
        await _removeQueueEntry(SyncEntityType.dayPlan, change.entityId);
        return _RemoteResolution(
          appliedRemote: true,
          conflictMessage:
              'Cloud day plan change won over an older local edit for $displayLabel.',
        );
      }

      return _RemoteResolution(
        conflictMessage: 'Kept newer local day plan edits for $displayLabel.',
      );
    }

    if (change.changeType == SyncChangeType.delete) {
      final deleted = await _deleteDayPlanLocally(change.entityId);
      return _RemoteResolution(appliedRemote: deleted);
    }

    await _applyRemoteDayPlan(change);
    return const _RemoteResolution(appliedRemote: true);
  }

  Future<_RemoteResolution> _mergeRemoteFoodLogEntry(
    CloudSyncRemoteChange change,
    SyncQueueTableData? pendingRow,
  ) async {
    final localEntry = await (_database.select(
      _database.foodLogEntriesTable,
    )..where((table) => table.id.equals(change.entityId))).getSingleOrNull();
    final displayLabel =
        localEntry?.title ??
        _stringValue(change.payload?['title']) ??
        change.entityId;

    if (pendingRow != null) {
      if (change.changedAt.isAfter(pendingRow.changedAt)) {
        if (change.changeType == SyncChangeType.delete) {
          await _deleteFoodLogEntryLocally(change.entityId);
        } else {
          await _applyRemoteFoodLogEntry(change);
        }
        await _removeQueueEntry(SyncEntityType.foodLogEntry, change.entityId);
        return _RemoteResolution(
          appliedRemote: true,
          conflictMessage:
              'Cloud food log change won over an older local edit for $displayLabel.',
        );
      }

      return _RemoteResolution(
        conflictMessage: 'Kept newer local food log edits for $displayLabel.',
      );
    }

    if (change.changeType == SyncChangeType.delete) {
      final deleted = await _deleteFoodLogEntryLocally(change.entityId);
      return _RemoteResolution(appliedRemote: deleted);
    }

    await _applyRemoteFoodLogEntry(change);
    return const _RemoteResolution(appliedRemote: true);
  }

  Future<void> _applyRemoteRecipe(CloudSyncRemoteChange change) async {
    final payload = change.payload;
    if (payload == null) {
      return;
    }

    final title = _stringValue(payload['title'])?.trim();
    if (title == null || title.isEmpty) {
      return;
    }

    final nutrition = _nutritionFromPayload(payload['nutrition']);
    final createdAt =
        _dateTimeFromDynamic(payload['createdAt']) ?? change.changedAt;
    final updatedAt =
        _dateTimeFromDynamic(payload['updatedAt']) ?? change.changedAt;
    final tags = _stringListFromPositionList(payload['tags'], key: 'label');
    final ingredients = _ingredientPayloads(payload['ingredients']);
    final directions = _stringListFromPositionList(
      payload['directions'],
      key: 'instruction',
    );

    await _database.transaction(() async {
      await _database
          .into(_database.recipes)
          .insertOnConflictUpdate(
            RecipesCompanion.insert(
              id: change.entityId,
              title: title,
              versionLabel: Value(
                _normalizedOptionalText(_stringValue(payload['versionLabel'])),
              ),
              notes: _stringValue(payload['notes'])?.trim() ?? '',
              servings: _intValue(payload['servings']) ?? 1,
              isPinned: Value(payload['isPinned'] == true),
              sortCalories: nutrition.calories,
              calories: nutrition.calories,
              protein: nutrition.protein,
              carbs: nutrition.carbs,
              fat: nutrition.fat,
              fiber: nutrition.fiber,
              sodium: nutrition.sodium,
              sugar: nutrition.sugar,
              createdAt: createdAt,
              updatedAt: updatedAt,
            ),
          );

      await (_database.delete(
        _database.recipeTags,
      )..where((table) => table.recipeId.equals(change.entityId))).go();
      await (_database.delete(
        _database.recipeIngredients,
      )..where((table) => table.recipeId.equals(change.entityId))).go();
      await (_database.delete(
        _database.recipeDirections,
      )..where((table) => table.recipeId.equals(change.entityId))).go();

      for (var index = 0; index < tags.length; index++) {
        await _database
            .into(_database.recipeTags)
            .insert(
              RecipeTagsCompanion.insert(
                recipeId: change.entityId,
                label: tags[index],
                position: index,
              ),
            );
      }

      for (var index = 0; index < ingredients.length; index++) {
        final ingredient = ingredients[index];
        await _database
            .into(_database.recipeIngredients)
            .insert(
              RecipeIngredientsCompanion.insert(
                recipeId: change.entityId,
                position: index,
                quantity: _stringValue(ingredient['quantity'])?.trim() ?? '',
                unit: _stringValue(ingredient['unit'])?.trim() ?? '',
                item: _stringValue(ingredient['item'])?.trim() ?? '',
                preparation:
                    _stringValue(ingredient['preparation'])?.trim() ?? '',
                ingredientType: Value(
                  _stringValue(ingredient['ingredientType'])?.trim() ??
                      'freeform',
                ),
                linkedPantryItemId: Value(
                  _normalizedOptionalText(
                    _stringValue(ingredient['linkedPantryItemId']),
                  ),
                ),
                linkedRecipeId: Value(
                  _normalizedOptionalText(
                    _stringValue(ingredient['linkedRecipeId']),
                  ),
                ),
              ),
            );
      }

      for (var index = 0; index < directions.length; index++) {
        await _database
            .into(_database.recipeDirections)
            .insert(
              RecipeDirectionsCompanion.insert(
                recipeId: change.entityId,
                position: index,
                instruction: directions[index],
              ),
            );
      }
    });
  }

  Future<void> _applyRemotePantryItem(CloudSyncRemoteChange change) async {
    final payload = change.payload;
    if (payload == null) {
      return;
    }

    final title = _stringValue(payload['title'])?.trim();
    if (title == null || title.isEmpty) {
      return;
    }

    final nutrition = _nutritionFromPayload(payload['nutrition']);
    final createdAt =
        _dateTimeFromDynamic(payload['createdAt']) ?? change.changedAt;
    final updatedAt =
        _dateTimeFromDynamic(payload['updatedAt']) ?? change.changedAt;

    await _database
        .into(_database.pantryItemsTable)
        .insertOnConflictUpdate(
          PantryItemsTableCompanion.insert(
            id: change.entityId,
            title: title,
            quantityLabel: _stringValue(payload['quantityLabel'])?.trim() ?? '',
            referenceUnitQuantity: Value(
              _doubleValue(payload['referenceUnitQuantity']) ?? 1,
            ),
            referenceUnit: Value(
              _stringValue(payload['referenceUnit'])?.trim() ?? 'serving',
            ),
            referenceUnitEquivalentQuantity: Value(
              _doubleValue(payload['referenceUnitEquivalentQuantity']),
            ),
            referenceUnitEquivalentUnit: Value(
              _normalizedOptionalText(
                _stringValue(payload['referenceUnitEquivalentUnit']),
              ),
            ),
            referenceUnitWeightGrams: Value(
              _doubleValue(payload['referenceUnitWeightGrams']),
            ),
            source: _stringValue(payload['source'])?.trim() ?? 'Cloud import',
            accentHex:
                _intValue(payload['accentHex']) ??
                const Color(0xFF4A6572).toARGB32(),
            barcode: Value(
              _normalizedOptionalText(_stringValue(payload['barcode'])),
            ),
            brand: Value(
              _normalizedOptionalText(_stringValue(payload['brand'])),
            ),
            imageUrl: Value(
              _normalizedOptionalText(_stringValue(payload['imageUrl'])),
            ),
            calories: nutrition.calories,
            protein: nutrition.protein,
            carbs: nutrition.carbs,
            fat: nutrition.fat,
            fiber: nutrition.fiber,
            sodium: nutrition.sodium,
            sugar: nutrition.sugar,
            createdAt: createdAt,
            updatedAt: Value(updatedAt),
          ),
        );
  }

  Future<void> _applyRemoteGroceryItem(CloudSyncRemoteChange change) async {
    final payload = change.payload;
    if (payload == null) {
      return;
    }

    final isGeneratedState = payload['isGeneratedState'] == true;
    final label = _stringValue(payload['label'])?.trim();
    if (label == null || label.isEmpty) {
      return;
    }

    final position = _intValue(payload['position']) ?? 0;
    final isChecked = payload['isChecked'] == true;

    if (isGeneratedState) {
      await _ensureGrocerySection(
        _generatedStateSectionId,
        _groceryGeneratedStateSectionTitle,
      );
      final existingRow =
          await (_database.select(_database.groceryItemsTable)..where(
                (table) =>
                    table.sectionId.equals(_generatedStateSectionId) &
                    table.label.equals(change.entityId),
              ))
              .getSingleOrNull();

      if (existingRow == null) {
        await _database
            .into(_database.groceryItemsTable)
            .insert(
              GroceryItemsTableCompanion.insert(
                sectionId: _generatedStateSectionId,
                label: change.entityId,
                position: position,
                isChecked: Value(isChecked),
              ),
            );
        return;
      }

      await (_database.update(
        _database.groceryItemsTable,
      )..where((table) => table.id.equals(existingRow.id))).write(
        GroceryItemsTableCompanion(
          label: Value(change.entityId),
          position: Value(position),
          isChecked: Value(isChecked),
        ),
      );
      return;
    }

    final sectionId =
        _normalizedOptionalText(_stringValue(payload['sectionId'])) ??
        'grocery_section_${DateTime.now().microsecondsSinceEpoch}';
    final sectionTitle =
        _normalizedOptionalText(_stringValue(payload['sectionTitle'])) ??
        'Imported';
    await _ensureGrocerySection(sectionId, sectionTitle);

    final itemId = _intValue(payload['id']) ?? int.tryParse(change.entityId);
    if (itemId == null) {
      return;
    }

    await _database
        .into(_database.groceryItemsTable)
        .insertOnConflictUpdate(
          GroceryItemsTableCompanion(
            id: Value(itemId),
            sectionId: Value(sectionId),
            label: Value(label),
            position: Value(position),
            isChecked: Value(isChecked),
          ),
        );
  }

  Future<void> _applyRemoteSavedMeal(CloudSyncRemoteChange change) async {
    final payload = change.payload;
    if (payload == null) {
      return;
    }

    final title = _stringValue(payload['title'])?.trim();
    if (title == null || title.isEmpty) {
      return;
    }

    final nutrition = _nutritionFromPayload(payload['nutrition']);
    final createdAt =
        _dateTimeFromDynamic(payload['createdAt']) ?? change.changedAt;
    final adjustments = _stringListFromPositionList(
      payload['adjustments'],
      key: 'label',
    );
    final components = _ingredientPayloads(payload['components']);

    await _database.transaction(() async {
      await _database
          .into(_database.savedMealsTable)
          .insertOnConflictUpdate(
            SavedMealsTableCompanion.insert(
              id: change.entityId,
              title: title,
              calories: nutrition.calories,
              protein: nutrition.protein,
              carbs: nutrition.carbs,
              fat: nutrition.fat,
              fiber: nutrition.fiber,
              sodium: nutrition.sodium,
              sugar: nutrition.sugar,
              createdAt: createdAt,
            ),
          );

      await (_database.delete(
        _database.savedMealAdjustments,
      )..where((table) => table.mealId.equals(change.entityId))).go();
      await (_database.delete(
        _database.savedMealComponents,
      )..where((table) => table.mealId.equals(change.entityId))).go();

      for (var index = 0; index < adjustments.length; index++) {
        await _database
            .into(_database.savedMealAdjustments)
            .insert(
              SavedMealAdjustmentsCompanion.insert(
                mealId: change.entityId,
                label: adjustments[index],
                position: index,
              ),
            );
      }

      for (var index = 0; index < components.length; index++) {
        final component = components[index];
        await _database
            .into(_database.savedMealComponents)
            .insert(
              SavedMealComponentsCompanion.insert(
                mealId: change.entityId,
                position: index,
                quantity: _stringValue(component['quantity'])?.trim() ?? '',
                unit: _stringValue(component['unit'])?.trim() ?? '',
                item: _stringValue(component['item'])?.trim() ?? '',
                componentType: Value(
                  _stringValue(component['componentType'])?.trim() ??
                      'freeform',
                ),
                linkedPantryItemId: Value(
                  _normalizedOptionalText(
                    _stringValue(component['linkedPantryItemId']),
                  ),
                ),
                linkedRecipeId: Value(
                  _normalizedOptionalText(
                    _stringValue(component['linkedRecipeId']),
                  ),
                ),
              ),
            );
      }
    });
  }

  Future<void> _applyRemoteDayPlan(CloudSyncRemoteChange change) async {
    final payload = change.payload;
    if (payload == null) {
      return;
    }

    final title = _stringValue(payload['title'])?.trim();
    if (title == null || title.isEmpty) {
      return;
    }

    final createdAt =
        _dateTimeFromDynamic(payload['createdAt']) ?? change.changedAt;
    final note = _stringValue(payload['note'])?.trim() ?? '';
    final entries = _ingredientPayloads(payload['entries']);

    await _database.transaction(() async {
      await _database
          .into(_database.dayPlansTable)
          .insertOnConflictUpdate(
            DayPlansTableCompanion.insert(
              id: change.entityId,
              title: title,
              note: note,
              createdAt: createdAt,
            ),
          );

      await (_database.delete(
        _database.dayPlanEntriesTable,
      )..where((table) => table.planId.equals(change.entityId))).go();

      for (var index = 0; index < entries.length; index++) {
        final entry = entries[index];
        final nutrition = _nutritionFromPayload(entry['nutrition']);
        await _database
            .into(_database.dayPlanEntriesTable)
            .insert(
              DayPlanEntriesTableCompanion.insert(
                planId: change.entityId,
                position: index,
                mealSlot:
                    _stringValue(entry['mealSlot'])?.trim() ??
                    FoodLogMealSlot.snack.name,
                sourceType:
                    _stringValue(entry['sourceType'])?.trim() ??
                    FoodLogEntrySourceType.savedMeal.name,
                sourceId: _stringValue(entry['sourceId'])?.trim() ?? '',
                title: _stringValue(entry['title'])?.trim() ?? '',
                quantity: _stringValue(entry['quantity'])?.trim() ?? '',
                unit: _stringValue(entry['unit'])?.trim() ?? '',
                calories: nutrition.calories,
                protein: nutrition.protein,
                carbs: nutrition.carbs,
                fat: nutrition.fat,
                fiber: nutrition.fiber,
                sodium: nutrition.sodium,
                sugar: nutrition.sugar,
              ),
            );
      }
    });
  }

  Future<void> _applyRemoteFoodLogEntry(CloudSyncRemoteChange change) async {
    final payload = change.payload;
    if (payload == null) {
      return;
    }

    final title = _stringValue(payload['title'])?.trim();
    if (title == null || title.isEmpty) {
      return;
    }

    final nutrition = _nutritionFromPayload(payload['nutrition']);
    final createdAt =
        _dateTimeFromDynamic(payload['createdAt']) ?? change.changedAt;

    await _database
        .into(_database.foodLogEntriesTable)
        .insertOnConflictUpdate(
          FoodLogEntriesTableCompanion.insert(
            id: change.entityId,
            entryDate: _stringValue(payload['entryDate'])?.trim() ?? '',
            mealSlot:
                _stringValue(payload['mealSlot'])?.trim() ??
                FoodLogMealSlot.snack.name,
            sourceType:
                _stringValue(payload['sourceType'])?.trim() ??
                FoodLogEntrySourceType.savedMeal.name,
            sourceId: _stringValue(payload['sourceId'])?.trim() ?? '',
            title: title,
            quantity: _stringValue(payload['quantity'])?.trim() ?? '',
            unit: _stringValue(payload['unit'])?.trim() ?? '',
            calories: nutrition.calories,
            protein: nutrition.protein,
            carbs: nutrition.carbs,
            fat: nutrition.fat,
            fiber: nutrition.fiber,
            sodium: nutrition.sodium,
            sugar: nutrition.sugar,
            createdAt: createdAt,
          ),
        );
  }

  Future<void> _deleteRecipeLocally(String id) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.recipeTags,
      )..where((table) => table.recipeId.equals(id))).go();
      await (_database.delete(
        _database.recipeIngredients,
      )..where((table) => table.recipeId.equals(id))).go();
      await (_database.delete(
        _database.recipeDirections,
      )..where((table) => table.recipeId.equals(id))).go();
      await (_database.delete(
        _database.recipes,
      )..where((table) => table.id.equals(id))).go();
    });
  }

  Future<void> _deletePantryItemLocally(String id) async {
    await (_database.delete(
      _database.pantryItemsTable,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<bool> _deleteGroceryItemLocally(String entityId) async {
    final manualId = int.tryParse(entityId);
    if (manualId != null) {
      final deletedCount = await (_database.delete(
        _database.groceryItemsTable,
      )..where((table) => table.id.equals(manualId))).go();
      return deletedCount > 0;
    }

    final deletedCount =
        await (_database.delete(_database.groceryItemsTable)..where(
              (table) =>
                  table.sectionId.equals(_generatedStateSectionId) &
                  table.label.equals(entityId),
            ))
            .go();
    return deletedCount > 0;
  }

  Future<bool> _deleteSavedMealLocally(String id) async {
    var deletedCount = 0;
    await _database.transaction(() async {
      await (_database.delete(
        _database.savedMealAdjustments,
      )..where((table) => table.mealId.equals(id))).go();
      await (_database.delete(
        _database.savedMealComponents,
      )..where((table) => table.mealId.equals(id))).go();
      deletedCount = await (_database.delete(
        _database.savedMealsTable,
      )..where((table) => table.id.equals(id))).go();
    });
    return deletedCount > 0;
  }

  Future<bool> _deleteDayPlanLocally(String id) async {
    var deletedCount = 0;
    await _database.transaction(() async {
      await (_database.delete(
        _database.dayPlanEntriesTable,
      )..where((table) => table.planId.equals(id))).go();
      deletedCount = await (_database.delete(
        _database.dayPlansTable,
      )..where((table) => table.id.equals(id))).go();
    });
    return deletedCount > 0;
  }

  Future<bool> _deleteFoodLogEntryLocally(String id) async {
    final deletedCount = await (_database.delete(
      _database.foodLogEntriesTable,
    )..where((table) => table.id.equals(id))).go();
    return deletedCount > 0;
  }

  Future<void> _removeQueueEntry(SyncEntityType entityType, String entityId) {
    return (_database.delete(_database.syncQueueTable)..where(
          (table) =>
              table.entityType.equals(entityType.name) &
              table.entityId.equals(entityId),
        ))
        .go();
  }

  String _queueKey(String entityTypeName, String entityId) {
    return '$entityTypeName::$entityId';
  }

  NutritionSnapshot _nutritionFromPayload(Object? payload) {
    if (payload is! Map<String, Object?>) {
      return NutritionSnapshot.zero;
    }
    return NutritionSnapshot(
      calories: _intValue(payload['calories']) ?? 0,
      protein: _intValue(payload['protein']) ?? 0,
      carbs: _intValue(payload['carbs']) ?? 0,
      fat: _intValue(payload['fat']) ?? 0,
      fiber: _intValue(payload['fiber']) ?? 0,
      sodium: _intValue(payload['sodium']) ?? 0,
      sugar: _intValue(payload['sugar']) ?? 0,
    );
  }

  List<String> _stringListFromPositionList(
    Object? value, {
    required String key,
  }) {
    if (value is! List) {
      return const [];
    }
    final rows = value.whereType<Map<String, Object?>>().toList(growable: false)
      ..sort((left, right) {
        return (_intValue(left['position']) ?? 0).compareTo(
          _intValue(right['position']) ?? 0,
        );
      });
    return rows
        .map((row) => _stringValue(row[key])?.trim() ?? '')
        .where((row) => row.isNotEmpty)
        .toList(growable: false);
  }

  List<Map<String, Object?>> _ingredientPayloads(Object? value) {
    if (value is! List) {
      return const [];
    }
    final rows = value.whereType<Map<String, Object?>>().toList(growable: false)
      ..sort((left, right) {
        return (_intValue(left['position']) ?? 0).compareTo(
          _intValue(right['position']) ?? 0,
        );
      });
    return rows;
  }

  Future<String?> _localGroceryLabel(String entityId) async {
    final manualId = int.tryParse(entityId);
    if (manualId != null) {
      final row = await (_database.select(
        _database.groceryItemsTable,
      )..where((table) => table.id.equals(manualId))).getSingleOrNull();
      if (row == null) {
        return null;
      }
      return _decodeGroceryLabel(row.label);
    }

    return entityId;
  }

  String _remoteGroceryDisplayLabel(
    Map<String, Object?>? payload,
    String? fallback,
  ) {
    final rawLabel = _stringValue(payload?['label'])?.trim();
    if (rawLabel != null && rawLabel.isNotEmpty) {
      return _decodeGroceryLabel(rawLabel);
    }
    return fallback ?? 'grocery item';
  }

  String _decodeGroceryLabel(String rawValue) {
    final separatorIndex = rawValue.indexOf(_groceryManualDetailSeparator);
    final encodedValue = separatorIndex < 0
        ? rawValue
        : rawValue.substring(0, separatorIndex);
    try {
      return Uri.decodeComponent(encodedValue.trim());
    } on FormatException {
      return encodedValue.trim().isEmpty ? 'grocery item' : encodedValue.trim();
    }
  }

  Future<void> _ensureGrocerySection(String id, String title) async {
    final existing = await (_database.select(
      _database.grocerySectionsTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (existing != null) {
      if (existing.title != title) {
        await (_database.update(_database.grocerySectionsTable)
              ..where((table) => table.id.equals(id)))
            .write(GrocerySectionsTableCompanion(title: Value(title)));
      }
      return;
    }

    final sections = await _database
        .select(_database.grocerySectionsTable)
        .get();
    await _database
        .into(_database.grocerySectionsTable)
        .insert(
          GrocerySectionsTableCompanion.insert(
            id: id,
            title: title,
            position: sections.length,
          ),
        );
  }

  String? _stringValue(Object? value) {
    return value is String ? value : null;
  }

  int? _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  double? _doubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  DateTime? _dateTimeFromDynamic(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String _syncSummaryMessage({
    required int remoteAppliedCount,
    required int conflictCount,
    required int pushedMutationCount,
  }) {
    if (remoteAppliedCount == 0 &&
        conflictCount == 0 &&
        pushedMutationCount == 0) {
      return 'Cloud sync is already current.';
    }

    final parts = <String>[
      if (remoteAppliedCount > 0)
        'Pulled $remoteAppliedCount remote change${remoteAppliedCount == 1 ? '' : 's'}',
      if (pushedMutationCount > 0)
        'pushed $pushedMutationCount local change${pushedMutationCount == 1 ? '' : 's'}',
      if (conflictCount > 0)
        'resolved $conflictCount conflict${conflictCount == 1 ? '' : 's'}',
    ];

    return '${parts.join(', ')}.';
  }

  Future<void> _upsertSetting(String key, String? value, DateTime updatedAt) {
    return _database
        .into(_database.appSettingsTable)
        .insertOnConflictUpdate(
          AppSettingsTableCompanion.insert(
            key: key,
            value: Value(value),
            updatedAt: updatedAt,
          ),
        );
  }

  Future<void> _deleteSetting(String key) {
    return (_database.delete(
      _database.appSettingsTable,
    )..where((table) => table.key.equals(key))).go();
  }

  SyncAuthState _authStateFromValue(String? value) {
    return switch (value) {
      'connected' => SyncAuthState.connected,
      _ => SyncAuthState.signedOut,
    };
  }

  SyncEntityType _entityTypeFromName(String value) {
    return SyncEntityType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => SyncEntityType.recipe,
    );
  }

  SyncChangeType _changeTypeFromName(String value) {
    return SyncChangeType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => SyncChangeType.upsert,
    );
  }

  DateTime? _dateTimeFromString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  String _syncErrorFrom(Object error) {
    final message = error.toString().trim();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    if (message.startsWith('StateError: ')) {
      return message.substring('StateError: '.length);
    }
    return message;
  }

  String? _normalizedOptionalText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _RemoteMergeResult {
  const _RemoteMergeResult({
    required this.remoteAppliedCount,
    required this.conflictCount,
  });

  final int remoteAppliedCount;
  final int conflictCount;
}

class _RemoteResolution {
  const _RemoteResolution({this.appliedRemote = false, this.conflictMessage});

  final bool appliedRemote;
  final String? conflictMessage;
}

class RecipesRepository {
  RecipesRepository(this._database, [SyncRepository? syncRepository])
    : _sync = syncRepository ?? SyncRepository(_database);

  final AppDatabase _database;
  final SyncRepository _sync;

  Stream<List<RecipeSummary>> watchRecipes({
    RecipeSortOrder sortOrder = RecipeSortOrder.caloriesLowToHigh,
  }) {
    final recipeQuery = _database.select(_database.recipes).watch();

    final tagQuery = _database.select(_database.recipeTags).watch();
    final ingredientQuery = _database
        .select(_database.recipeIngredients)
        .watch();
    final directionQuery = _database.select(_database.recipeDirections).watch();
    final pantryQuery = _database.select(_database.pantryItemsTable).watch();

    return recipeQuery
        .combineLatest3(tagQuery, ingredientQuery, (
          recipes,
          tags,
          ingredients,
        ) {
          return (recipes, tags, ingredients);
        })
        .combineLatest(directionQuery, (combined, directions) {
          return (combined.$1, combined.$2, combined.$3, directions);
        })
        .combineLatest(pantryQuery, (combined, pantryItems) {
          final recipes = combined.$1;
          final tags = combined.$2;
          final ingredients = combined.$3;
          final directions = combined.$4;
          final recipesById = {for (final recipe in recipes) recipe.id: recipe};
          final pantryById = {
            for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
          };
          final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
          for (final ingredient in ingredients) {
            ingredientsByRecipeId
                .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
                .add(ingredient);
          }
          for (final ingredientList in ingredientsByRecipeId.values) {
            ingredientList.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final tagsByRecipeId = <String, List<RecipeTag>>{};
          for (final tag in tags) {
            tagsByRecipeId
                .putIfAbsent(tag.recipeId, () => <RecipeTag>[])
                .add(tag);
          }
          for (final recipeTags in tagsByRecipeId.values) {
            recipeTags.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final directionsByRecipeId = <String, List<RecipeDirection>>{};
          for (final direction in directions) {
            directionsByRecipeId
                .putIfAbsent(direction.recipeId, () => <RecipeDirection>[])
                .add(direction);
          }

          final nutritionCache = <String, NutritionSnapshot>{};
          final computedRecipes = recipes
              .map((recipe) {
                final nutrition = _resolveRecipeNutrition(
                  recipeId: recipe.id,
                  recipesById: recipesById,
                  ingredientsByRecipeId: ingredientsByRecipeId,
                  pantryById: pantryById,
                  nutritionCache: nutritionCache,
                );
                final recipeTags =
                    tagsByRecipeId[recipe.id] ?? const <RecipeTag>[];

                return _SortableRecipeSummary(
                  updatedAt: recipe.updatedAt,
                  summary: RecipeSummary(
                    id: recipe.id,
                    name: recipe.title,
                    versionLabel: recipe.versionLabel ?? 'Base version',
                    servings: recipe.servings,
                    nutrition: nutrition,
                    tags: recipeTags.map((tag) => tag.label).toList(),
                    note: recipe.notes,
                    isPinned: recipe.isPinned,
                    sortCalories: nutrition.calories,
                    ingredientCount:
                        ingredientsByRecipeId[recipe.id]?.length ?? 0,
                    directionCount:
                        directionsByRecipeId[recipe.id]?.length ?? 0,
                  ),
                );
              })
              .toList(growable: true);

          computedRecipes.sort((left, right) {
            final pinnedComparison = (right.summary.isPinned ? 1 : 0).compareTo(
              left.summary.isPinned ? 1 : 0,
            );
            if (pinnedComparison != 0) {
              return pinnedComparison;
            }

            final calorieComparison = switch (sortOrder) {
              RecipeSortOrder.caloriesLowToHigh =>
                left.summary.sortCalories.compareTo(right.summary.sortCalories),
              RecipeSortOrder.caloriesHighToLow =>
                right.summary.sortCalories.compareTo(left.summary.sortCalories),
            };
            if (calorieComparison != 0) {
              return calorieComparison;
            }

            return right.updatedAt.compareTo(left.updatedAt);
          });

          return computedRecipes
              .map((recipe) => recipe.summary)
              .toList(growable: false);
        });
  }

  Future<RecipeDraft> getRecipeDraft(String id) async {
    final recipe = await (_database.select(
      _database.recipes,
    )..where((table) => table.id.equals(id))).getSingle();
    final tags =
        await (_database.select(
            _database.recipeTags,
          )..where((table) => table.recipeId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));
    final ingredients =
        await (_database.select(
            _database.recipeIngredients,
          )..where((table) => table.recipeId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));
    final directions =
        await (_database.select(
            _database.recipeDirections,
          )..where((table) => table.recipeId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));

    return RecipeDraft(
      name: recipe.title,
      versionLabel: recipe.versionLabel ?? '',
      servings: recipe.servings,
      note: recipe.notes,
      tags: tags.map((tag) => tag.label).toList(growable: false),
      isPinned: recipe.isPinned,
      nutrition: NutritionSnapshot(
        calories: recipe.calories,
        protein: recipe.protein,
        carbs: recipe.carbs,
        fat: recipe.fat,
        fiber: recipe.fiber,
        sodium: recipe.sodium,
        sugar: recipe.sugar,
      ),
      ingredients: ingredients
          .map(
            (ingredient) => RecipeIngredientDraft(
              quantity: ingredient.quantity,
              unit: ingredient.unit,
              item: ingredient.item,
              preparation: ingredient.preparation,
              linkType: _ingredientTypeFromName(ingredient.ingredientType),
              linkedPantryItemId: ingredient.linkedPantryItemId,
              linkedRecipeId: ingredient.linkedRecipeId,
            ),
          )
          .toList(growable: false),
      directions: directions
          .map((direction) => direction.instruction)
          .toList(growable: false),
    );
  }

  Future<void> saveRecipe(RecipeDraft draft, {String? existingId}) async {
    final recipeId =
        existingId ?? 'recipe_${DateTime.now().microsecondsSinceEpoch}';
    final normalizedTags = draft.tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
    final now = DateTime.now();

    await _database.transaction(() async {
      await _database
          .into(_database.recipes)
          .insertOnConflictUpdate(
            RecipesCompanion.insert(
              id: recipeId,
              title: draft.name.trim(),
              versionLabel: Value(_normalizedVersionLabel(draft.versionLabel)),
              notes: draft.note.trim(),
              servings: draft.servings,
              isPinned: Value(draft.isPinned),
              sortCalories: draft.nutrition.calories,
              calories: draft.nutrition.calories,
              protein: draft.nutrition.protein,
              carbs: draft.nutrition.carbs,
              fat: draft.nutrition.fat,
              fiber: draft.nutrition.fiber,
              sodium: draft.nutrition.sodium,
              sugar: draft.nutrition.sugar,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await (_database.delete(
        _database.recipeTags,
      )..where((table) => table.recipeId.equals(recipeId))).go();
      await (_database.delete(
        _database.recipeIngredients,
      )..where((table) => table.recipeId.equals(recipeId))).go();
      await (_database.delete(
        _database.recipeDirections,
      )..where((table) => table.recipeId.equals(recipeId))).go();

      for (var index = 0; index < normalizedTags.length; index++) {
        await _database
            .into(_database.recipeTags)
            .insert(
              RecipeTagsCompanion.insert(
                recipeId: recipeId,
                label: normalizedTags[index],
                position: index,
              ),
            );
      }

      for (var index = 0; index < draft.ingredients.length; index++) {
        final ingredient = draft.ingredients[index];
        await _database
            .into(_database.recipeIngredients)
            .insert(
              RecipeIngredientsCompanion.insert(
                recipeId: recipeId,
                position: index,
                quantity: ingredient.quantity.trim(),
                unit: ingredient.unit.trim(),
                item: ingredient.item.trim(),
                preparation: ingredient.preparation.trim(),
                ingredientType: Value(ingredient.linkType.name),
                linkedPantryItemId: Value(ingredient.linkedPantryItemId),
                linkedRecipeId: Value(ingredient.linkedRecipeId),
              ),
            );
      }

      for (var index = 0; index < draft.directions.length; index++) {
        final direction = draft.directions[index].trim();
        if (direction.isEmpty) {
          continue;
        }

        await _database
            .into(_database.recipeDirections)
            .insert(
              RecipeDirectionsCompanion.insert(
                recipeId: recipeId,
                position: index,
                instruction: direction,
              ),
            );
      }
    });

    await _sync.recordChange(
      entityType: SyncEntityType.recipe,
      entityId: recipeId,
      changeType: SyncChangeType.upsert,
      displayLabel: draft.name.trim(),
    );
  }

  Future<void> deleteRecipe(String id) async {
    await (_database.delete(
      _database.recipes,
    )..where((table) => table.id.equals(id))).go();
    await _sync.recordChange(
      entityType: SyncEntityType.recipe,
      entityId: id,
      changeType: SyncChangeType.delete,
    );
  }

  String? _normalizedVersionLabel(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Stream<List<IngredientLinkTarget>> watchIngredientLinkTargets({
    String? excludingRecipeId,
  }) {
    final recipeQuery = (_database.select(
      _database.recipes,
    )..orderBy([(table) => OrderingTerm(expression: table.title)])).watch();
    final pantryQuery = (_database.select(
      _database.pantryItemsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.title)])).watch();
    final ingredientQuery = _database
        .select(_database.recipeIngredients)
        .watch();

    return recipeQuery.combineLatest3(pantryQuery, ingredientQuery, (
      recipes,
      pantryItems,
      ingredients,
    ) {
      final recipesById = {for (final recipe in recipes) recipe.id: recipe};
      final pantryById = {
        for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
      };
      final nutritionCache = <String, NutritionSnapshot>{};
      final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
      for (final ingredient in ingredients) {
        ingredientsByRecipeId
            .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
            .add(ingredient);
      }
      for (final ingredientList in ingredientsByRecipeId.values) {
        ingredientList.sort(
          (left, right) => left.position.compareTo(right.position),
        );
      }

      final pantryTargets = pantryItems
          .map(
            (item) => IngredientLinkTarget(
              id: item.id,
              type: RecipeIngredientType.pantryItem,
              title: item.title,
              referenceUnit: item.referenceUnit,
              referenceUnitQuantity: item.referenceUnitQuantity,
              nutrition: _nutritionFromPantryItem(item),
              referenceUnitEquivalentQuantity:
                  item.referenceUnitEquivalentQuantity,
              referenceUnitEquivalentUnit: item.referenceUnitEquivalentUnit,
              referenceUnitWeightGrams: item.referenceUnitWeightGrams,
              subtitle:
                  'Pantry item • ${item.quantityLabel} • nutrition per ${_referenceUnitSummary(item.referenceUnit, referenceUnitQuantity: item.referenceUnitQuantity, referenceUnitEquivalentQuantity: item.referenceUnitEquivalentQuantity, referenceUnitEquivalentUnit: item.referenceUnitEquivalentUnit, referenceUnitWeightGrams: item.referenceUnitWeightGrams)}',
            ),
          )
          .toList(growable: false);
      final recipeTargets = recipes
          .where((recipe) => recipe.id != excludingRecipeId)
          .map(
            (recipe) => IngredientLinkTarget(
              id: recipe.id,
              type: RecipeIngredientType.recipeReference,
              title: recipe.title,
              referenceUnit: 'serving',
              nutrition: _resolveRecipeNutrition(
                recipeId: recipe.id,
                recipesById: recipesById,
                ingredientsByRecipeId: ingredientsByRecipeId,
                pantryById: pantryById,
                nutritionCache: nutritionCache,
              ),
              subtitle:
                  'Nested recipe • ${recipe.versionLabel ?? 'Base version'} • nutrition per 1 serving',
            ),
          )
          .toList(growable: false);

      return [...pantryTargets, ...recipeTargets];
    });
  }

  Stream<List<ResolvedRecipeIngredient>> watchResolvedIngredients(
    String recipeId,
  ) {
    final ingredientQuery =
        (_database.select(_database.recipeIngredients)
              ..where((table) => table.recipeId.equals(recipeId))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .watch();
    final recipeQuery = _database.select(_database.recipes).watch();
    final allIngredientsQuery = _database
        .select(_database.recipeIngredients)
        .watch();
    final pantryQuery = _database.select(_database.pantryItemsTable).watch();

    return ingredientQuery
        .combineLatest3(recipeQuery, allIngredientsQuery, (
          ingredients,
          recipes,
          allIngredients,
        ) {
          return (ingredients, recipes, allIngredients);
        })
        .combineLatest(pantryQuery, (combined, pantryItems) {
          final ingredients = combined.$1;
          final recipes = combined.$2;
          final allIngredients = combined.$3;
          final recipesById = {for (final recipe in recipes) recipe.id: recipe};
          final pantryById = {
            for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
          };
          final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
          for (final ingredient in allIngredients) {
            ingredientsByRecipeId
                .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
                .add(ingredient);
          }
          for (final ingredientList in ingredientsByRecipeId.values) {
            ingredientList.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final nutritionCache = <String, NutritionSnapshot>{};

          return ingredients
              .map((ingredient) {
                final ingredientType = _ingredientTypeFromName(
                  ingredient.ingredientType,
                );
                final draft = RecipeIngredientDraft(
                  quantity: ingredient.quantity,
                  unit: ingredient.unit,
                  item: ingredient.item,
                  preparation: ingredient.preparation,
                  linkType: ingredientType,
                  linkedPantryItemId: ingredient.linkedPantryItemId,
                  linkedRecipeId: ingredient.linkedRecipeId,
                );

                return switch (ingredientType) {
                  RecipeIngredientType.freeform => ResolvedRecipeIngredient(
                    draft: draft,
                    linkTitle: null,
                    linkSubtitle: '',
                    batchNutrition: NutritionSnapshot.zero,
                  ),
                  RecipeIngredientType.pantryItem => () {
                    final pantryItem =
                        pantryById[ingredient.linkedPantryItemId];
                    return ResolvedRecipeIngredient(
                      draft: draft,
                      linkTitle: pantryItem?.title,
                      linkSubtitle: pantryItem == null
                          ? 'Pantry item missing'
                          : 'Pantry item • per ${_referenceUnitSummary(pantryItem.referenceUnit, referenceUnitQuantity: pantryItem.referenceUnitQuantity, referenceUnitEquivalentQuantity: pantryItem.referenceUnitEquivalentQuantity, referenceUnitEquivalentUnit: pantryItem.referenceUnitEquivalentUnit, referenceUnitWeightGrams: pantryItem.referenceUnitWeightGrams)}',
                      batchNutrition: _resolveIngredientBatchNutrition(
                        ingredient: ingredient,
                        currentRecipeId: recipeId,
                        recipesById: recipesById,
                        ingredientsByRecipeId: ingredientsByRecipeId,
                        pantryById: pantryById,
                        nutritionCache: nutritionCache,
                      ),
                    );
                  }(),
                  RecipeIngredientType.recipeReference => () {
                    final linkedRecipe = recipesById[ingredient.linkedRecipeId];
                    return ResolvedRecipeIngredient(
                      draft: draft,
                      linkTitle: linkedRecipe?.title,
                      linkSubtitle: linkedRecipe == null
                          ? 'Nested recipe missing'
                          : 'Nested recipe • per 1 serving',
                      batchNutrition: _resolveIngredientBatchNutrition(
                        ingredient: ingredient,
                        currentRecipeId: recipeId,
                        recipesById: recipesById,
                        ingredientsByRecipeId: ingredientsByRecipeId,
                        pantryById: pantryById,
                        nutritionCache: nutritionCache,
                      ),
                    );
                  }(),
                };
              })
              .toList(growable: false);
        });
  }

  NutritionSnapshot _resolveRecipeNutrition({
    required String recipeId,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, NutritionSnapshot> nutritionCache,
    Set<String> trail = const <String>{},
  }) {
    final cached = nutritionCache[recipeId];
    if (cached != null) {
      return cached;
    }

    final recipe = recipesById[recipeId];
    if (recipe == null) {
      return NutritionSnapshot.zero;
    }
    if (trail.contains(recipeId)) {
      return _nutritionFromRecipeRow(recipe);
    }

    final servings = recipe.servings <= 0 ? 1 : recipe.servings;
    final manualBatchNutrition = _nutritionFromRecipeRow(
      recipe,
    ).scale(servings.toDouble());
    final linkedBatchNutrition =
        (ingredientsByRecipeId[recipeId] ?? const <RecipeIngredient>[])
            .map(
              (ingredient) => _resolveIngredientBatchNutrition(
                ingredient: ingredient,
                currentRecipeId: recipeId,
                recipesById: recipesById,
                ingredientsByRecipeId: ingredientsByRecipeId,
                pantryById: pantryById,
                nutritionCache: nutritionCache,
                trail: {...trail, recipeId},
              ),
            )
            .fold(NutritionSnapshot.zero, (total, item) => total + item);
    final totalNutrition = (manualBatchNutrition + linkedBatchNutrition).divide(
      servings,
    );
    nutritionCache[recipeId] = totalNutrition;
    return totalNutrition;
  }

  NutritionSnapshot _resolveIngredientBatchNutrition({
    required RecipeIngredient ingredient,
    required String currentRecipeId,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, NutritionSnapshot> nutritionCache,
    Set<String> trail = const <String>{},
  }) {
    final quantity = _parseLinkedQuantity(ingredient.quantity);
    final linkedPantryItem = pantryById[ingredient.linkedPantryItemId];

    return switch (_ingredientTypeFromName(ingredient.ingredientType)) {
      RecipeIngredientType.freeform => NutritionSnapshot.zero,
      RecipeIngredientType.pantryItem =>
        linkedPantryItem == null
            ? NutritionSnapshot.zero
            : () {
                final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
                  quantity: quantity,
                  ingredientUnit: ingredient.unit,
                  referenceUnit: linkedPantryItem.referenceUnit,
                  referenceUnitQuantity: linkedPantryItem.referenceUnitQuantity,
                  referenceUnitEquivalentQuantity:
                      linkedPantryItem.referenceUnitEquivalentQuantity,
                  referenceUnitEquivalentUnit:
                      linkedPantryItem.referenceUnitEquivalentUnit,
                  referenceUnitWeightGrams:
                      linkedPantryItem.referenceUnitWeightGrams,
                );
                if (!resolution.isResolved) {
                  return NutritionSnapshot.zero;
                }
                return _nutritionFromPantryItem(
                  linkedPantryItem,
                ).scale(resolution.referenceUnits!);
              }(),
      RecipeIngredientType.recipeReference =>
        ingredient.linkedRecipeId == null ||
                ingredient.linkedRecipeId == currentRecipeId
            ? NutritionSnapshot.zero
            : () {
                final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
                  quantity: quantity,
                  ingredientUnit: ingredient.unit,
                  referenceUnit: 'serving',
                );
                if (!resolution.isResolved) {
                  return NutritionSnapshot.zero;
                }
                return _resolveRecipeNutrition(
                  recipeId: ingredient.linkedRecipeId!,
                  recipesById: recipesById,
                  ingredientsByRecipeId: ingredientsByRecipeId,
                  pantryById: pantryById,
                  nutritionCache: nutritionCache,
                  trail: trail,
                ).scale(resolution.referenceUnits!);
              }(),
    };
  }

  NutritionSnapshot _nutritionFromRecipeRow(Recipe recipe) {
    return NutritionSnapshot(
      calories: recipe.calories,
      protein: recipe.protein,
      carbs: recipe.carbs,
      fat: recipe.fat,
      fiber: recipe.fiber,
      sodium: recipe.sodium,
      sugar: recipe.sugar,
    );
  }

  NutritionSnapshot _nutritionFromPantryItem(PantryItemsTableData pantryItem) {
    return NutritionSnapshot(
      calories: pantryItem.calories,
      protein: pantryItem.protein,
      carbs: pantryItem.carbs,
      fat: pantryItem.fat,
      fiber: pantryItem.fiber,
      sodium: pantryItem.sodium,
      sugar: pantryItem.sugar,
    );
  }

  String _referenceUnitSummary(
    String referenceUnit, {
    double referenceUnitQuantity = 1,
    double? referenceUnitEquivalentQuantity,
    String? referenceUnitEquivalentUnit,
    double? referenceUnitWeightGrams,
  }) {
    return MeasurementUnits.describeReferenceUnit(
      referenceUnit: referenceUnit,
      referenceUnitQuantity: referenceUnitQuantity,
      referenceUnitEquivalentQuantity: referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: referenceUnitWeightGrams,
    );
  }

  RecipeIngredientType _ingredientTypeFromName(String value) {
    return RecipeIngredientType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => RecipeIngredientType.freeform,
    );
  }

  double? _parseLinkedQuantity(String rawQuantity) {
    return MeasurementUnits.parseQuantity(rawQuantity);
  }
}

class _SortableRecipeSummary {
  const _SortableRecipeSummary({
    required this.summary,
    required this.updatedAt,
  });

  final RecipeSummary summary;
  final DateTime updatedAt;
}

class PantryRepository {
  PantryRepository(this._database, [SyncRepository? syncRepository])
    : _sync = syncRepository ?? SyncRepository(_database);

  final AppDatabase _database;
  final SyncRepository _sync;

  Stream<List<PantryItem>> watchPantryItems() {
    return (_database.select(
      _database.pantryItemsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.title)])).watch().map(
      (items) => items
          .map(
            (item) => PantryItem(
              id: item.id,
              name: item.title,
              quantityLabel: item.quantityLabel,
              referenceUnit: item.referenceUnit,
              referenceUnitQuantity: item.referenceUnitQuantity,
              referenceUnitEquivalentQuantity:
                  item.referenceUnitEquivalentQuantity,
              referenceUnitEquivalentUnit: item.referenceUnitEquivalentUnit,
              referenceUnitWeightGrams: item.referenceUnitWeightGrams,
              source: item.source,
              nutrition: NutritionSnapshot(
                calories: item.calories,
                protein: item.protein,
                carbs: item.carbs,
                fat: item.fat,
                fiber: item.fiber,
                sodium: item.sodium,
                sugar: item.sugar,
              ),
              accent: Color(item.accentHex),
              barcode: item.barcode,
              brand: item.brand,
              imageUrl: item.imageUrl,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> savePantryItem(
    PantryItemDraft draft, {
    String? existingId,
  }) async {
    final itemId =
        existingId ?? 'pantry_${DateTime.now().microsecondsSinceEpoch}';
    final normalizedReferenceUnitQuantity = draft.referenceUnitQuantity > 0
        ? draft.referenceUnitQuantity
        : 1.0;
    final normalizedEquivalentQuantity = draft.referenceUnitEquivalentQuantity;
    final normalizedEquivalentUnit = draft.referenceUnitEquivalentUnit?.trim();
    final normalizedBarcode = _normalizedOptionalText(draft.barcode);
    final normalizedBrand = _normalizedOptionalText(draft.brand);
    final normalizedImageUrl = _normalizedOptionalText(draft.imageUrl);
    final now = DateTime.now();
    final existingCreatedAt = existingId == null
        ? null
        : await (_database.select(_database.pantryItemsTable)
                ..where((table) => table.id.equals(existingId)))
              .map((row) => row.createdAt)
              .getSingleOrNull();

    await _database
        .into(_database.pantryItemsTable)
        .insertOnConflictUpdate(
          PantryItemsTableCompanion.insert(
            id: itemId,
            title: draft.name.trim(),
            quantityLabel: draft.quantityLabel.trim(),
            referenceUnitQuantity: Value(normalizedReferenceUnitQuantity),
            referenceUnit: Value(draft.referenceUnit.trim()),
            referenceUnitEquivalentQuantity: Value(
              normalizedEquivalentQuantity != null &&
                      normalizedEquivalentQuantity > 0
                  ? normalizedEquivalentQuantity
                  : null,
            ),
            referenceUnitEquivalentUnit: Value(
              normalizedEquivalentUnit != null &&
                      normalizedEquivalentUnit.isNotEmpty
                  ? normalizedEquivalentUnit
                  : null,
            ),
            referenceUnitWeightGrams: Value(
              draft.referenceUnitWeightGrams != null &&
                      draft.referenceUnitWeightGrams! > 0
                  ? draft.referenceUnitWeightGrams
                  : null,
            ),
            source: draft.source.trim(),
            accentHex: draft.accent.toARGB32(),
            barcode: Value(normalizedBarcode),
            brand: Value(normalizedBrand),
            imageUrl: Value(normalizedImageUrl),
            calories: draft.nutrition.calories,
            protein: draft.nutrition.protein,
            carbs: draft.nutrition.carbs,
            fat: draft.nutrition.fat,
            fiber: draft.nutrition.fiber,
            sodium: draft.nutrition.sodium,
            sugar: draft.nutrition.sugar,
            createdAt: existingCreatedAt ?? now,
            updatedAt: Value(now),
          ),
        );

    await _sync.recordChange(
      entityType: SyncEntityType.pantryItem,
      entityId: itemId,
      changeType: SyncChangeType.upsert,
      displayLabel: draft.name.trim(),
    );
  }

  Future<void> deletePantryItem(String id) async {
    await (_database.delete(
      _database.pantryItemsTable,
    )..where((table) => table.id.equals(id))).go();
    await _sync.recordChange(
      entityType: SyncEntityType.pantryItem,
      entityId: id,
      changeType: SyncChangeType.delete,
    );
  }

  String? _normalizedOptionalText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

class GroceryRepository {
  GroceryRepository(this._database, [SyncRepository? syncRepository])
    : _sync = syncRepository ?? SyncRepository(_database);

  final AppDatabase _database;
  final SyncRepository _sync;
  static const _settingsSectionId = '__grocery_settings__';
  static const _generatedStateSectionId = '__grocery_generated_state__';
  static const _settingsSectionTitle = '__Grocery Settings__';
  static const _generatedStateSectionTitle = '__Generated Grocery State__';
  static const _settingPinnedRecipes = 'include_pinned_recipes';
  static const _settingSavedMeals = 'include_saved_meals';
  static const _settingDayPlans = 'include_day_plans';
  static const _manualDetailSeparator = '||';

  Stream<List<GrocerySection>> watchGrocerySections() {
    final recipesRepository = RecipesRepository(_database);
    final sectionsQuery = (_database.select(
      _database.grocerySectionsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();
    final itemsQuery = (_database.select(
      _database.groceryItemsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();
    final recipesQuery = _database.select(_database.recipes).watch();
    final recipeIngredientsQuery = _database
        .select(_database.recipeIngredients)
        .watch();
    final pantryQuery = _database.select(_database.pantryItemsTable).watch();
    final savedMealsQuery = _database.select(_database.savedMealsTable).watch();
    final savedMealComponentsQuery = _database
        .select(_database.savedMealComponents)
        .watch();
    final dayPlansQuery = _database.select(_database.dayPlansTable).watch();
    final dayPlanEntriesQuery = _database
        .select(_database.dayPlanEntriesTable)
        .watch();

    return sectionsQuery
        .combineLatest(itemsQuery, (sections, items) => (sections, items))
        .combineLatest3(recipesQuery, recipeIngredientsQuery, (
          manualData,
          recipes,
          recipeIngredients,
        ) {
          return (manualData.$1, manualData.$2, recipes, recipeIngredients);
        })
        .combineLatest3(pantryQuery, savedMealsQuery, (
          combined,
          pantryItems,
          savedMeals,
        ) {
          return (
            combined.$1,
            combined.$2,
            combined.$3,
            combined.$4,
            pantryItems,
            savedMeals,
          );
        })
        .combineLatest(savedMealComponentsQuery, (
          combined,
          savedMealComponents,
        ) {
          final manualSections = combined.$1;
          final manualItems = combined.$2;
          final recipes = combined.$3;
          final recipeIngredients = combined.$4;
          final pantryItems = combined.$5;
          final savedMeals = combined.$6;
          final recipesById = {for (final recipe in recipes) recipe.id: recipe};
          final pantryById = {
            for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
          };
          final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
          for (final ingredient in recipeIngredients) {
            ingredientsByRecipeId
                .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
                .add(ingredient);
          }
          for (final ingredientList in ingredientsByRecipeId.values) {
            ingredientList.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final savedMealComponentsByMealId =
              <String, List<SavedMealComponent>>{};
          for (final component in savedMealComponents) {
            savedMealComponentsByMealId
                .putIfAbsent(component.mealId, () => <SavedMealComponent>[])
                .add(component);
          }
          for (final components in savedMealComponentsByMealId.values) {
            components.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }

          return (
            manualSections,
            manualItems,
            recipes,
            recipesRepository,
            recipesById,
            ingredientsByRecipeId,
            pantryById,
            savedMeals,
            savedMealComponentsByMealId,
          );
        })
        .combineLatest(dayPlansQuery, (combined, dayPlans) {
          return (
            combined.$1,
            combined.$2,
            combined.$3,
            combined.$4,
            combined.$5,
            combined.$6,
            combined.$7,
            combined.$8,
            combined.$9,
            dayPlans,
          );
        })
        .combineLatest(dayPlanEntriesQuery, (combined, dayPlanEntries) {
          return (
            combined.$1,
            combined.$2,
            combined.$3,
            combined.$4,
            combined.$5,
            combined.$6,
            combined.$7,
            combined.$8,
            combined.$9,
            combined.$10,
            dayPlanEntries,
          );
        })
        .map((combined) {
          final itemsBySectionId = <String, List<GroceryItemsTableData>>{};
          for (final item in combined.$2) {
            itemsBySectionId
                .putIfAbsent(item.sectionId, () => <GroceryItemsTableData>[])
                .add(item);
          }
          final settings = _settingsFromRows(
            itemsBySectionId[_settingsSectionId] ??
                const <GroceryItemsTableData>[],
          );
          final generatedStateByKey = _generatedStateFromRows(
            itemsBySectionId[_generatedStateSectionId] ??
                const <GroceryItemsTableData>[],
          );

          final exportSections = <GrocerySection>[
            if (settings.includePinnedRecipes)
              _buildPinnedRecipesSection(
                recipesRepository: combined.$4,
                recipes: combined.$3
                    .where((recipe) => recipe.isPinned)
                    .toList(),
                recipesById: combined.$5,
                ingredientsByRecipeId: combined.$6,
                pantryById: combined.$7,
                generatedStateByKey: generatedStateByKey,
              ),
            if (settings.includeSavedMeals)
              _buildSavedMealsSection(
                recipesRepository: combined.$4,
                meals: combined.$8,
                recipesById: combined.$5,
                ingredientsByRecipeId: combined.$6,
                pantryById: combined.$7,
                componentsByMealId: combined.$9,
                generatedStateByKey: generatedStateByKey,
              ),
          ].where((section) => section.items.isNotEmpty).toList(growable: true);

          final savedMealsById = {
            for (final meal in combined.$8) meal.id: meal,
          };
          final dayPlanEntriesByPlanId =
              <String, List<DayPlanEntriesTableData>>{};
          for (final entry in combined.$11) {
            dayPlanEntriesByPlanId
                .putIfAbsent(entry.planId, () => <DayPlanEntriesTableData>[])
                .add(entry);
          }
          if (settings.includeDayPlans) {
            exportSections.add(
              _buildDayPlansSection(
                recipesRepository: combined.$4,
                plans: combined.$10,
                entriesByPlanId: dayPlanEntriesByPlanId,
                savedMealsById: savedMealsById,
                recipesById: combined.$5,
                ingredientsByRecipeId: combined.$6,
                pantryById: combined.$7,
                componentsByMealId: combined.$9,
                generatedStateByKey: generatedStateByKey,
              ),
            );
            exportSections.removeWhere((section) => section.items.isEmpty);
          }

          final manualGrocerySections = combined.$1
              .where((section) => !_isHiddenSection(section.id))
              .map(
                (section) => GrocerySection(
                  title: section.title,
                  items:
                      (itemsBySectionId[section.id] ??
                              const <GroceryItemsTableData>[])
                          .map(
                            (item) => GroceryListItem(
                              key: 'manual:${item.id}',
                              label: _manualItemLabel(item.label),
                              detail: _manualItemDetail(item.label),
                              isChecked: item.isChecked,
                            ),
                          )
                          .toList(growable: false),
                ),
              )
              .where((section) => section.items.isNotEmpty)
              .toList(growable: false);

          return [...exportSections, ...manualGrocerySections];
        });
  }

  Stream<GroceryExportSettings> watchExportSettings() {
    final sectionsQuery = _database
        .select(_database.grocerySectionsTable)
        .watch();
    final itemsQuery = _database.select(_database.groceryItemsTable).watch();

    return sectionsQuery.combineLatest(itemsQuery, (sections, items) {
      final hasSettingsSection = sections.any(
        (section) => section.id == _settingsSectionId,
      );
      if (!hasSettingsSection) {
        return GroceryExportSettings.defaults;
      }

      final settingRows = items
          .where((item) => item.sectionId == _settingsSectionId)
          .toList(growable: false);
      return _settingsFromRows(settingRows);
    });
  }

  Future<void> setExportSettings(GroceryExportSettings settings) async {
    await _ensureHiddenSection(_settingsSectionId, _settingsSectionTitle);
    await (_database.delete(
      _database.groceryItemsTable,
    )..where((table) => table.sectionId.equals(_settingsSectionId))).go();
    await _database
        .into(_database.groceryItemsTable)
        .insert(
          GroceryItemsTableCompanion.insert(
            sectionId: _settingsSectionId,
            label: _settingPinnedRecipes,
            position: 0,
            isChecked: Value(settings.includePinnedRecipes),
          ),
        );
    await _database
        .into(_database.groceryItemsTable)
        .insert(
          GroceryItemsTableCompanion.insert(
            sectionId: _settingsSectionId,
            label: _settingSavedMeals,
            position: 1,
            isChecked: Value(settings.includeSavedMeals),
          ),
        );
    await _database
        .into(_database.groceryItemsTable)
        .insert(
          GroceryItemsTableCompanion.insert(
            sectionId: _settingsSectionId,
            label: _settingDayPlans,
            position: 2,
            isChecked: Value(settings.includeDayPlans),
          ),
        );
  }

  Future<void> saveManualItem(GroceryManualItemDraft draft) async {
    final sectionTitle = draft.sectionTitle.trim();
    final normalizedSectionTitle = sectionTitle.isEmpty
        ? 'Quick Add'
        : sectionTitle;
    final sections = await (_database.select(
      _database.grocerySectionsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).get();
    final existingSection = sections
        .cast<GrocerySectionsTableData?>()
        .firstWhere(
          (section) =>
              section != null &&
              !_isHiddenSection(section.id) &&
              section.title.toLowerCase() ==
                  normalizedSectionTitle.toLowerCase(),
          orElse: () => null,
        );
    final sectionId =
        existingSection?.id ??
        'grocery_section_${DateTime.now().microsecondsSinceEpoch}';
    if (existingSection == null) {
      await _database
          .into(_database.grocerySectionsTable)
          .insert(
            GrocerySectionsTableCompanion.insert(
              id: sectionId,
              title: normalizedSectionTitle,
              position: sections.length,
            ),
          );
    }

    final currentItems = await (_database.select(
      _database.groceryItemsTable,
    )..where((table) => table.sectionId.equals(sectionId))).get();
    final insertedId = await _database
        .into(_database.groceryItemsTable)
        .insert(
          GroceryItemsTableCompanion.insert(
            sectionId: sectionId,
            label: _encodeManualItemLabel(
              label: draft.label,
              quantity: draft.quantity,
              unit: draft.unit,
            ),
            position: currentItems.length,
          ),
        );
    await _sync.recordChange(
      entityType: SyncEntityType.groceryItem,
      entityId: insertedId.toString(),
      changeType: SyncChangeType.upsert,
      displayLabel: draft.label.trim(),
    );
  }

  Future<void> deleteManualItem(int id) async {
    await (_database.delete(
      _database.groceryItemsTable,
    )..where((table) => table.id.equals(id))).go();
    await _sync.recordChange(
      entityType: SyncEntityType.groceryItem,
      entityId: id.toString(),
      changeType: SyncChangeType.delete,
    );
  }

  Future<void> toggleItemChecked(GroceryListItem item, bool isChecked) async {
    if (item.isGenerated) {
      await _toggleGeneratedItemChecked(item, isChecked);
      await _sync.recordChange(
        entityType: SyncEntityType.groceryItem,
        entityId: item.key,
        changeType: SyncChangeType.upsert,
        displayLabel: item.label,
      );
      return;
    }

    final manualId = int.tryParse(item.key.replaceFirst('manual:', ''));
    if (manualId == null) {
      return;
    }
    await (_database.update(_database.groceryItemsTable)
          ..where((table) => table.id.equals(manualId)))
        .write(GroceryItemsTableCompanion(isChecked: Value(isChecked)));
    await _sync.recordChange(
      entityType: SyncEntityType.groceryItem,
      entityId: manualId.toString(),
      changeType: SyncChangeType.upsert,
      displayLabel: item.label,
    );
  }

  GrocerySection _buildPinnedRecipesSection({
    required RecipesRepository recipesRepository,
    required List<Recipe> recipes,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, bool> generatedStateByKey,
  }) {
    final aggregate = _GroceryAggregate();
    for (final recipe in recipes) {
      _appendRecipeIngredients(
        aggregate: aggregate,
        recipesRepository: recipesRepository,
        recipeId: recipe.id,
        recipeLabel: recipe.title,
        servingsScale: recipe.servings <= 0 ? 1 : recipe.servings.toDouble(),
        recipesById: recipesById,
        ingredientsByRecipeId: ingredientsByRecipeId,
        pantryById: pantryById,
        generatedStateByKey: generatedStateByKey,
      );
    }
    return GrocerySection(title: 'Pinned Recipes', items: aggregate.toList());
  }

  GrocerySection _buildSavedMealsSection({
    required RecipesRepository recipesRepository,
    required List<SavedMealsTableData> meals,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, List<SavedMealComponent>> componentsByMealId,
    required Map<String, bool> generatedStateByKey,
  }) {
    final aggregate = _GroceryAggregate();
    for (final meal in meals) {
      final mealComponents =
          componentsByMealId[meal.id] ?? const <SavedMealComponent>[];
      for (final component in mealComponents) {
        _appendSavedMealComponent(
          aggregate: aggregate,
          recipesRepository: recipesRepository,
          component: component,
          mealLabel: meal.title,
          recipesById: recipesById,
          ingredientsByRecipeId: ingredientsByRecipeId,
          pantryById: pantryById,
          generatedStateByKey: generatedStateByKey,
        );
      }
    }
    return GrocerySection(title: 'Saved Meals', items: aggregate.toList());
  }

  GrocerySection _buildDayPlansSection({
    required RecipesRepository recipesRepository,
    required List<DayPlansTableData> plans,
    required Map<String, List<DayPlanEntriesTableData>> entriesByPlanId,
    required Map<String, SavedMealsTableData> savedMealsById,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, List<SavedMealComponent>> componentsByMealId,
    required Map<String, bool> generatedStateByKey,
  }) {
    final aggregate = _GroceryAggregate();
    for (final plan in plans) {
      final planEntries =
          entriesByPlanId[plan.id] ?? const <DayPlanEntriesTableData>[];
      for (final entry in planEntries) {
        _appendDayPlanEntry(
          aggregate: aggregate,
          recipesRepository: recipesRepository,
          entry: entry,
          planLabel: plan.title,
          savedMealsById: savedMealsById,
          recipesById: recipesById,
          ingredientsByRecipeId: ingredientsByRecipeId,
          pantryById: pantryById,
          componentsByMealId: componentsByMealId,
          generatedStateByKey: generatedStateByKey,
        );
      }
    }
    return GrocerySection(title: 'Day Plans', items: aggregate.toList());
  }

  void _appendRecipeIngredients({
    required _GroceryAggregate aggregate,
    required RecipesRepository recipesRepository,
    required String recipeId,
    required String recipeLabel,
    required double servingsScale,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, bool> generatedStateByKey,
    Set<String> trail = const <String>{},
  }) {
    if (trail.contains(recipeId)) {
      return;
    }

    final recipe = recipesById[recipeId];
    if (recipe == null) {
      return;
    }
    final batchScale = recipe.servings <= 0
        ? servingsScale
        : servingsScale / recipe.servings;

    for (final ingredient
        in ingredientsByRecipeId[recipeId] ?? const <RecipeIngredient>[]) {
      _appendRecipeIngredient(
        aggregate: aggregate,
        recipesRepository: recipesRepository,
        ingredient: ingredient,
        sourceLabel: recipeLabel,
        batchScale: batchScale,
        recipesById: recipesById,
        ingredientsByRecipeId: ingredientsByRecipeId,
        pantryById: pantryById,
        generatedStateByKey: generatedStateByKey,
        trail: {...trail, recipeId},
      );
    }
  }

  void _appendRecipeIngredient({
    required _GroceryAggregate aggregate,
    required RecipesRepository recipesRepository,
    required RecipeIngredient ingredient,
    required String sourceLabel,
    required double batchScale,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, bool> generatedStateByKey,
    required Set<String> trail,
  }) {
    final quantity = recipesRepository._parseLinkedQuantity(
      ingredient.quantity,
    );
    final scaledQuantity = quantity == null || quantity <= 0
        ? null
        : quantity * batchScale;
    final ingredientType = recipesRepository._ingredientTypeFromName(
      ingredient.ingredientType,
    );

    switch (ingredientType) {
      case RecipeIngredientType.freeform:
        _addDirectContribution(
          aggregate: aggregate,
          label: ingredient.item.trim(),
          quantity: scaledQuantity,
          unit: ingredient.unit.trim(),
          rawQuantity: ingredient.quantity.trim(),
          sourceLabel: sourceLabel,
          isGenerated: true,
          checkedByKey: generatedStateByKey,
        );
        return;
      case RecipeIngredientType.pantryItem:
        final pantryItem = pantryById[ingredient.linkedPantryItemId];
        if (pantryItem == null) {
          _addDirectContribution(
            aggregate: aggregate,
            label: ingredient.item.trim(),
            quantity: scaledQuantity,
            unit: ingredient.unit.trim(),
            rawQuantity: ingredient.quantity.trim(),
            sourceLabel: sourceLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _addPantryContribution(
          aggregate: aggregate,
          pantryItem: pantryItem,
          quantity: scaledQuantity,
          ingredientUnit: ingredient.unit.trim(),
          rawQuantity: ingredient.quantity.trim(),
          sourceLabel: sourceLabel,
          generatedStateByKey: generatedStateByKey,
        );
        return;
      case RecipeIngredientType.recipeReference:
        if (ingredient.linkedRecipeId == null || scaledQuantity == null) {
          _addDirectContribution(
            aggregate: aggregate,
            label: ingredient.item.trim(),
            quantity: scaledQuantity,
            unit: ingredient.unit.trim(),
            rawQuantity: ingredient.quantity.trim(),
            sourceLabel: sourceLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
          quantity: scaledQuantity,
          ingredientUnit: ingredient.unit,
          referenceUnit: 'serving',
        );
        if (!resolution.isResolved) {
          _addDirectContribution(
            aggregate: aggregate,
            label: ingredient.item.trim(),
            quantity: scaledQuantity,
            unit: ingredient.unit.trim(),
            rawQuantity: ingredient.quantity.trim(),
            sourceLabel: sourceLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _appendRecipeIngredients(
          aggregate: aggregate,
          recipesRepository: recipesRepository,
          recipeId: ingredient.linkedRecipeId!,
          recipeLabel: sourceLabel,
          servingsScale: resolution.referenceUnits!,
          recipesById: recipesById,
          ingredientsByRecipeId: ingredientsByRecipeId,
          pantryById: pantryById,
          generatedStateByKey: generatedStateByKey,
          trail: trail,
        );
        return;
    }
  }

  void _appendSavedMealComponent({
    required _GroceryAggregate aggregate,
    required RecipesRepository recipesRepository,
    required SavedMealComponent component,
    required String mealLabel,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, bool> generatedStateByKey,
    double quantityScale = 1,
  }) {
    final baseQuantity = recipesRepository._parseLinkedQuantity(
      component.quantity,
    );
    final quantity = baseQuantity == null ? null : baseQuantity * quantityScale;
    final ingredientType = recipesRepository._ingredientTypeFromName(
      component.componentType,
    );

    switch (ingredientType) {
      case RecipeIngredientType.freeform:
        _addDirectContribution(
          aggregate: aggregate,
          label: component.item.trim(),
          quantity: quantity,
          unit: component.unit.trim(),
          rawQuantity: component.quantity.trim(),
          sourceLabel: mealLabel,
          isGenerated: true,
          checkedByKey: generatedStateByKey,
        );
        return;
      case RecipeIngredientType.pantryItem:
        final pantryItem = pantryById[component.linkedPantryItemId];
        if (pantryItem == null) {
          _addDirectContribution(
            aggregate: aggregate,
            label: component.item.trim(),
            quantity: quantity,
            unit: component.unit.trim(),
            rawQuantity: component.quantity.trim(),
            sourceLabel: mealLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _addPantryContribution(
          aggregate: aggregate,
          pantryItem: pantryItem,
          quantity: quantity,
          ingredientUnit: component.unit.trim(),
          rawQuantity: component.quantity.trim(),
          sourceLabel: mealLabel,
          generatedStateByKey: generatedStateByKey,
        );
        return;
      case RecipeIngredientType.recipeReference:
        if (component.linkedRecipeId == null ||
            quantity == null ||
            quantity <= 0) {
          _addDirectContribution(
            aggregate: aggregate,
            label: component.item.trim(),
            quantity: quantity,
            unit: component.unit.trim(),
            rawQuantity: component.quantity.trim(),
            sourceLabel: mealLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
          quantity: quantity,
          ingredientUnit: component.unit,
          referenceUnit: 'serving',
        );
        if (!resolution.isResolved) {
          _addDirectContribution(
            aggregate: aggregate,
            label: component.item.trim(),
            quantity: quantity,
            unit: component.unit.trim(),
            rawQuantity: component.quantity.trim(),
            sourceLabel: mealLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _appendRecipeIngredients(
          aggregate: aggregate,
          recipesRepository: recipesRepository,
          recipeId: component.linkedRecipeId!,
          recipeLabel: mealLabel,
          servingsScale: resolution.referenceUnits!,
          recipesById: recipesById,
          ingredientsByRecipeId: ingredientsByRecipeId,
          pantryById: pantryById,
          generatedStateByKey: generatedStateByKey,
        );
        return;
    }
  }

  void _appendDayPlanEntry({
    required _GroceryAggregate aggregate,
    required RecipesRepository recipesRepository,
    required DayPlanEntriesTableData entry,
    required String planLabel,
    required Map<String, SavedMealsTableData> savedMealsById,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, List<SavedMealComponent>> componentsByMealId,
    required Map<String, bool> generatedStateByKey,
  }) {
    final quantity = recipesRepository._parseLinkedQuantity(entry.quantity);
    final sourceLabel = '$planLabel • ${_mealSlotLabel(entry.mealSlot)}';
    final sourceType = FoodLogEntrySourceType.values.firstWhere(
      (type) => type.name == entry.sourceType,
      orElse: () => FoodLogEntrySourceType.recipe,
    );

    switch (sourceType) {
      case FoodLogEntrySourceType.savedMeal:
        final meal = savedMealsById[entry.sourceId];
        final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
          quantity: quantity,
          ingredientUnit: entry.unit,
          referenceUnit: 'meal',
        );
        if (meal == null || !resolution.isResolved) {
          _addDirectContribution(
            aggregate: aggregate,
            label: entry.title.trim(),
            quantity: quantity,
            unit: entry.unit.trim(),
            rawQuantity: entry.quantity.trim(),
            sourceLabel: sourceLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        final components =
            componentsByMealId[meal.id] ?? const <SavedMealComponent>[];
        for (final component in components) {
          _appendSavedMealComponent(
            aggregate: aggregate,
            recipesRepository: recipesRepository,
            component: component,
            mealLabel: sourceLabel,
            recipesById: recipesById,
            ingredientsByRecipeId: ingredientsByRecipeId,
            pantryById: pantryById,
            generatedStateByKey: generatedStateByKey,
            quantityScale: resolution.referenceUnits!,
          );
        }
        return;
      case FoodLogEntrySourceType.recipe:
        final recipe = recipesById[entry.sourceId];
        final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
          quantity: quantity,
          ingredientUnit: entry.unit,
          referenceUnit: 'serving',
        );
        if (recipe == null || !resolution.isResolved) {
          _addDirectContribution(
            aggregate: aggregate,
            label: entry.title.trim(),
            quantity: quantity,
            unit: entry.unit.trim(),
            rawQuantity: entry.quantity.trim(),
            sourceLabel: sourceLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _appendRecipeIngredients(
          aggregate: aggregate,
          recipesRepository: recipesRepository,
          recipeId: recipe.id,
          recipeLabel: sourceLabel,
          servingsScale: resolution.referenceUnits!,
          recipesById: recipesById,
          ingredientsByRecipeId: ingredientsByRecipeId,
          pantryById: pantryById,
          generatedStateByKey: generatedStateByKey,
        );
        return;
      case FoodLogEntrySourceType.pantryItem:
        final pantryItem = pantryById[entry.sourceId];
        if (pantryItem == null) {
          _addDirectContribution(
            aggregate: aggregate,
            label: entry.title.trim(),
            quantity: quantity,
            unit: entry.unit.trim(),
            rawQuantity: entry.quantity.trim(),
            sourceLabel: sourceLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _addPantryContribution(
          aggregate: aggregate,
          pantryItem: pantryItem,
          quantity: quantity,
          ingredientUnit: entry.unit.trim(),
          rawQuantity: entry.quantity.trim(),
          sourceLabel: sourceLabel,
          generatedStateByKey: generatedStateByKey,
        );
        return;
    }
  }

  void _addPantryContribution({
    required _GroceryAggregate aggregate,
    required PantryItemsTableData pantryItem,
    required double? quantity,
    required String ingredientUnit,
    required String rawQuantity,
    required String sourceLabel,
    required Map<String, bool> generatedStateByKey,
  }) {
    final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: quantity,
      ingredientUnit: ingredientUnit,
      referenceUnit: pantryItem.referenceUnit,
      referenceUnitQuantity: pantryItem.referenceUnitQuantity,
      referenceUnitEquivalentQuantity:
          pantryItem.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: pantryItem.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: pantryItem.referenceUnitWeightGrams,
    );
    if (!resolution.isResolved) {
      _addDirectContribution(
        aggregate: aggregate,
        label: pantryItem.title,
        quantity: quantity,
        unit: ingredientUnit,
        rawQuantity: rawQuantity,
        sourceLabel: sourceLabel,
        isGenerated: true,
        checkedByKey: generatedStateByKey,
      );
      return;
    }
    aggregate.add(
      _GroceryContribution(
        key: 'pantry:${pantryItem.id}',
        label: pantryItem.title,
        quantity: resolution.referenceUnits!,
        unit: pantryItem.referenceUnit,
        sourceLabel: sourceLabel,
        isGenerated: true,
        checkedByKey: generatedStateByKey,
      ),
    );
  }

  void _addDirectContribution({
    required _GroceryAggregate aggregate,
    required String label,
    required double? quantity,
    required String unit,
    required String rawQuantity,
    required String sourceLabel,
    required bool isGenerated,
    required Map<String, bool> checkedByKey,
  }) {
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) {
      return;
    }
    aggregate.add(
      _GroceryContribution(
        key: 'label:${trimmedLabel.toLowerCase()}',
        label: trimmedLabel,
        quantity: quantity,
        unit: unit,
        rawQuantity: rawQuantity,
        sourceLabel: sourceLabel,
        isGenerated: isGenerated,
        checkedByKey: checkedByKey,
      ),
    );
  }

  Future<void> _toggleGeneratedItemChecked(
    GroceryListItem item,
    bool isChecked,
  ) async {
    await _ensureHiddenSection(
      _generatedStateSectionId,
      _generatedStateSectionTitle,
    );
    final existingRows =
        await (_database.select(_database.groceryItemsTable)..where(
              (table) =>
                  table.sectionId.equals(_generatedStateSectionId) &
                  table.label.equals(item.key),
            ))
            .get();
    if (existingRows.isNotEmpty) {
      await (_database.update(_database.groceryItemsTable)..where(
            (table) =>
                table.sectionId.equals(_generatedStateSectionId) &
                table.label.equals(item.key),
          ))
          .write(GroceryItemsTableCompanion(isChecked: Value(isChecked)));
      return;
    }

    final currentItems =
        await (_database.select(_database.groceryItemsTable)..where(
              (table) => table.sectionId.equals(_generatedStateSectionId),
            ))
            .get();
    await _database
        .into(_database.groceryItemsTable)
        .insert(
          GroceryItemsTableCompanion.insert(
            sectionId: _generatedStateSectionId,
            label: item.key,
            position: currentItems.length,
            isChecked: Value(isChecked),
          ),
        );
  }

  GroceryExportSettings _settingsFromRows(List<GroceryItemsTableData> rows) {
    var includePinnedRecipes =
        GroceryExportSettings.defaults.includePinnedRecipes;
    var includeSavedMeals = GroceryExportSettings.defaults.includeSavedMeals;
    var includeDayPlans = GroceryExportSettings.defaults.includeDayPlans;
    for (final row in rows) {
      switch (row.label) {
        case _settingPinnedRecipes:
          includePinnedRecipes = row.isChecked;
          break;
        case _settingSavedMeals:
          includeSavedMeals = row.isChecked;
          break;
        case _settingDayPlans:
          includeDayPlans = row.isChecked;
          break;
      }
    }
    return GroceryExportSettings(
      includePinnedRecipes: includePinnedRecipes,
      includeSavedMeals: includeSavedMeals,
      includeDayPlans: includeDayPlans,
    );
  }

  Map<String, bool> _generatedStateFromRows(List<GroceryItemsTableData> rows) {
    return {
      for (final row in rows)
        if (row.label.trim().isNotEmpty) row.label: row.isChecked,
    };
  }

  bool _isHiddenSection(String sectionId) {
    return sectionId == _settingsSectionId ||
        sectionId == _generatedStateSectionId;
  }

  String _encodeManualItemLabel({
    required String label,
    required String quantity,
    required String unit,
  }) {
    final normalizedLabel = label.trim();
    final detail = [
      if (quantity.trim().isNotEmpty) quantity.trim(),
      if (unit.trim().isNotEmpty) unit.trim(),
    ].join(' ').trim();
    if (detail.isEmpty) {
      return Uri.encodeComponent(normalizedLabel);
    }
    return '${Uri.encodeComponent(normalizedLabel)}$_manualDetailSeparator${Uri.encodeComponent(detail)}';
  }

  String _manualItemLabel(String encodedLabel) {
    final separatorIndex = encodedLabel.indexOf(_manualDetailSeparator);
    if (separatorIndex < 0) {
      return _decodeManualValue(encodedLabel.trim());
    }
    return _decodeManualValue(encodedLabel.substring(0, separatorIndex).trim());
  }

  String? _manualItemDetail(String encodedLabel) {
    final separatorIndex = encodedLabel.indexOf(_manualDetailSeparator);
    if (separatorIndex < 0) {
      return null;
    }
    final detail = encodedLabel
        .substring(separatorIndex + _manualDetailSeparator.length)
        .trim();
    if (detail.isEmpty) {
      return null;
    }
    return _decodeManualValue(detail);
  }

  String _decodeManualValue(String value) {
    try {
      return Uri.decodeComponent(value);
    } on FormatException {
      return value;
    }
  }

  String _mealSlotLabel(String mealSlot) {
    return switch (mealSlot.trim().toLowerCase()) {
      'breakfast' => 'Breakfast',
      'lunch' => 'Lunch',
      'dinner' => 'Dinner',
      'snack' => 'Snack',
      _ => 'Plan',
    };
  }

  Future<void> _ensureHiddenSection(String id, String title) async {
    final existing = await (_database.select(
      _database.grocerySectionsTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (existing != null) {
      return;
    }

    final sections = await (_database.select(
      _database.grocerySectionsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).get();
    await _database
        .into(_database.grocerySectionsTable)
        .insert(
          GrocerySectionsTableCompanion.insert(
            id: id,
            title: title,
            position: sections.length,
          ),
        );
  }
}

class FoodLogRepository {
  FoodLogRepository(this._database, [SyncRepository? syncRepository])
    : _sync = syncRepository ?? SyncRepository(_database);

  final AppDatabase _database;
  final SyncRepository _sync;

  Stream<List<SavedMeal>> watchSavedMeals() {
    final recipeRepository = RecipesRepository(_database);
    final mealsQuery = (_database.select(
      _database.savedMealsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.createdAt)])).watch();
    final adjustmentsQuery = (_database.select(
      _database.savedMealAdjustments,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();
    final componentsQuery = (_database.select(
      _database.savedMealComponents,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();
    final recipeQuery = _database.select(_database.recipes).watch();
    final recipeIngredientsQuery = _database
        .select(_database.recipeIngredients)
        .watch();
    final pantryQuery = _database.select(_database.pantryItemsTable).watch();

    return mealsQuery
        .combineLatest(adjustmentsQuery, (meals, adjustments) {
          return (meals, adjustments);
        })
        .combineLatest3(componentsQuery, recipeQuery, (
          combined,
          components,
          recipes,
        ) {
          return (combined.$1, combined.$2, components, recipes);
        })
        .combineLatest(recipeIngredientsQuery, (combined, recipeIngredients) {
          return (
            combined.$1,
            combined.$2,
            combined.$3,
            combined.$4,
            recipeIngredients,
          );
        })
        .combineLatest(pantryQuery, (combined, pantryItems) {
          final meals = combined.$1;
          final adjustments = combined.$2;
          final components = combined.$3;
          final recipes = combined.$4;
          final recipeIngredients = combined.$5;
          final recipesById = {for (final recipe in recipes) recipe.id: recipe};
          final pantryById = {
            for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
          };
          final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
          for (final ingredient in recipeIngredients) {
            ingredientsByRecipeId
                .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
                .add(ingredient);
          }
          for (final ingredientList in ingredientsByRecipeId.values) {
            ingredientList.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final adjustmentsByMealId = <String, List<SavedMealAdjustment>>{};
          for (final adjustment in adjustments) {
            adjustmentsByMealId
                .putIfAbsent(adjustment.mealId, () => <SavedMealAdjustment>[])
                .add(adjustment);
          }
          final componentsByMealId = <String, List<SavedMealComponent>>{};
          for (final component in components) {
            componentsByMealId
                .putIfAbsent(component.mealId, () => <SavedMealComponent>[])
                .add(component);
          }
          final nutritionCache = <String, NutritionSnapshot>{};

          return meals
              .map((meal) {
                final manualNutrition = _nutritionFromSavedMealRow(meal);
                final mealComponents =
                    componentsByMealId[meal.id] ?? const <SavedMealComponent>[];
                final linkedNutrition = mealComponents
                    .map(
                      (component) => _resolveSavedMealComponentNutrition(
                        component: component,
                        recipeRepository: recipeRepository,
                        recipesById: recipesById,
                        ingredientsByRecipeId: ingredientsByRecipeId,
                        pantryById: pantryById,
                        nutritionCache: nutritionCache,
                      ),
                    )
                    .fold(
                      NutritionSnapshot.zero,
                      (total, item) => total + item,
                    );
                return SavedMeal(
                  id: meal.id,
                  name: meal.title,
                  nutrition: manualNutrition + linkedNutrition,
                  manualNutrition: manualNutrition,
                  adjustments:
                      (adjustmentsByMealId[meal.id] ??
                              const <SavedMealAdjustment>[])
                          .map((adjustment) => adjustment.label)
                          .toList(growable: false),
                  components: mealComponents
                      .map(
                        (component) => SavedMealComponentDraft(
                          quantity: component.quantity,
                          unit: component.unit,
                          item: component.item,
                          linkType: recipeRepository._ingredientTypeFromName(
                            component.componentType,
                          ),
                          linkedPantryItemId: component.linkedPantryItemId,
                          linkedRecipeId: component.linkedRecipeId,
                        ),
                      )
                      .toList(growable: false),
                );
              })
              .toList(growable: false);
        });
  }

  Stream<List<DayPlan>> watchDayPlans() {
    final plansQuery = (_database.select(
      _database.dayPlansTable,
    )..orderBy([(table) => OrderingTerm.desc(table.createdAt)])).watch();
    final entriesQuery = (_database.select(
      _database.dayPlanEntriesTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();

    return plansQuery.combineLatest(entriesQuery, (plans, entries) {
      final entriesByPlanId = <String, List<DayPlanEntriesTableData>>{};
      for (final entry in entries) {
        entriesByPlanId
            .putIfAbsent(entry.planId, () => <DayPlanEntriesTableData>[])
            .add(entry);
      }

      return plans
          .map(
            (plan) => DayPlan(
              id: plan.id,
              name: plan.title,
              note: plan.note,
              createdAt: plan.createdAt,
              entries:
                  (entriesByPlanId[plan.id] ??
                          const <DayPlanEntriesTableData>[])
                      .map(
                        (entry) => DayPlanEntryDraft(
                          mealSlot: _mealSlotFromName(entry.mealSlot),
                          sourceType: _entrySourceTypeFromName(
                            entry.sourceType,
                          ),
                          sourceId: entry.sourceId,
                          title: entry.title,
                          quantity: entry.quantity,
                          unit: entry.unit,
                          nutrition: _nutritionFromDayPlanEntryRow(entry),
                        ),
                      )
                      .toList(growable: false),
            ),
          )
          .toList(growable: false);
    });
  }

  Stream<List<FoodLogEntryTarget>> watchEntryTargets() {
    final recipesRepository = RecipesRepository(_database);
    final pantryRepository = PantryRepository(_database);

    return watchSavedMeals().combineLatest3(
      recipesRepository.watchRecipes(),
      pantryRepository.watchPantryItems(),
      (savedMeals, recipes, pantryItems) {
        final savedMealTargets = savedMeals
            .map(
              (meal) => FoodLogEntryTarget(
                id: meal.id,
                sourceType: FoodLogEntrySourceType.savedMeal,
                title: meal.name,
                referenceUnit: 'meal',
                nutrition: meal.nutrition,
                subtitle: 'Saved meal • per 1 meal',
              ),
            )
            .toList(growable: false);
        final recipeTargets = recipes
            .map(
              (recipe) => FoodLogEntryTarget(
                id: recipe.id,
                sourceType: FoodLogEntrySourceType.recipe,
                title: recipe.name,
                referenceUnit: 'serving',
                nutrition: recipe.nutrition,
                subtitle: 'Recipe • ${recipe.versionLabel} • per 1 serving',
              ),
            )
            .toList(growable: false);
        final pantryTargets = pantryItems
            .map(
              (item) => FoodLogEntryTarget(
                id: item.id,
                sourceType: FoodLogEntrySourceType.pantryItem,
                title: item.name,
                referenceUnit: item.referenceUnit,
                referenceUnitQuantity: item.referenceUnitQuantity,
                nutrition: item.nutrition,
                referenceUnitEquivalentQuantity:
                    item.referenceUnitEquivalentQuantity,
                referenceUnitEquivalentUnit: item.referenceUnitEquivalentUnit,
                referenceUnitWeightGrams: item.referenceUnitWeightGrams,
                subtitle:
                    'Pantry item • ${item.quantityLabel} • per ${MeasurementUnits.describeReferenceUnit(referenceUnit: item.referenceUnit, referenceUnitQuantity: item.referenceUnitQuantity, referenceUnitEquivalentQuantity: item.referenceUnitEquivalentQuantity, referenceUnitEquivalentUnit: item.referenceUnitEquivalentUnit, referenceUnitWeightGrams: item.referenceUnitWeightGrams)}',
              ),
            )
            .toList(growable: false);

        final targets =
            [...savedMealTargets, ...recipeTargets, ...pantryTargets]
              ..sort((left, right) {
                final typeComparison = left.sourceType.name.compareTo(
                  right.sourceType.name,
                );
                if (typeComparison != 0) {
                  return typeComparison;
                }
                return left.title.compareTo(right.title);
              });
        return targets;
      },
    );
  }

  Stream<FoodLogSnapshot> watchSnapshot() {
    final goalsQuery = (_database.select(
      _database.dailyGoalsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.id)])).watch();
    final entriesQuery =
        (_database.select(_database.foodLogEntriesTable)
              ..where((table) => table.entryDate.equals(_todayDateKey))
              ..orderBy([(table) => OrderingTerm(expression: table.createdAt)]))
            .watch();

    return goalsQuery
        .combineLatest(watchSavedMeals(), (goals, savedMeals) {
          return (goals, savedMeals);
        })
        .combineLatest(watchDayPlans(), (combined, dayPlans) {
          return (combined.$1, combined.$2, dayPlans);
        })
        .combineLatest(entriesQuery, (combined, entryRows) {
          final consumedNutrition = entryRows
              .map(_nutritionFromFoodLogEntryRow)
              .fold(
                NutritionSnapshot.zero,
                (total, nutrition) => total + nutrition,
              );

          return FoodLogSnapshot(
            goals: combined.$1
                .map(
                  (goal) => DailyGoal(
                    label: goal.label,
                    consumed: _goalValueForLabel(consumedNutrition, goal.label),
                    target: goal.target,
                  ),
                )
                .toList(growable: false),
            savedMeals: combined.$2,
            dayPlans: combined.$3,
            entries: entryRows
                .map(
                  (entry) => FoodLogEntry(
                    id: entry.id,
                    date: _dateFromKey(entry.entryDate),
                    mealSlot: _mealSlotFromName(entry.mealSlot),
                    sourceType: _entrySourceTypeFromName(entry.sourceType),
                    sourceId: entry.sourceId,
                    title: entry.title,
                    quantity: entry.quantity,
                    unit: entry.unit,
                    nutrition: _nutritionFromFoodLogEntryRow(entry),
                  ),
                )
                .toList(growable: false),
          );
        });
  }

  Stream<List<FoodLogSuggestion>> watchSuggestions() {
    return watchSnapshot().combineLatest(
      watchEntryTargets(),
      (snapshot, targets) =>
          _buildFoodLogSuggestions(snapshot: snapshot, targets: targets),
    );
  }

  Future<SavedMealDraft> getSavedMealDraft(String id) async {
    final meal = await (_database.select(
      _database.savedMealsTable,
    )..where((table) => table.id.equals(id))).getSingle();
    final adjustments =
        await (_database.select(
            _database.savedMealAdjustments,
          )..where((table) => table.mealId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));
    final components =
        await (_database.select(
            _database.savedMealComponents,
          )..where((table) => table.mealId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));
    final recipeRepository = RecipesRepository(_database);

    return SavedMealDraft(
      name: meal.title,
      manualNutrition: _nutritionFromSavedMealRow(meal),
      adjustments: adjustments.map((adjustment) => adjustment.label).toList(),
      components: components
          .map(
            (component) => SavedMealComponentDraft(
              quantity: component.quantity,
              unit: component.unit,
              item: component.item,
              linkType: recipeRepository._ingredientTypeFromName(
                component.componentType,
              ),
              linkedPantryItemId: component.linkedPantryItemId,
              linkedRecipeId: component.linkedRecipeId,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> saveSavedMeal(SavedMealDraft draft, {String? existingId}) async {
    final mealId =
        existingId ?? 'saved_meal_${DateTime.now().microsecondsSinceEpoch}';
    final existingCreatedAt = existingId == null
        ? null
        : await (_database.select(_database.savedMealsTable)
                ..where((table) => table.id.equals(existingId)))
              .map((row) => row.createdAt)
              .getSingleOrNull();

    await _database.transaction(() async {
      await _database
          .into(_database.savedMealsTable)
          .insertOnConflictUpdate(
            SavedMealsTableCompanion.insert(
              id: mealId,
              title: draft.name.trim(),
              calories: draft.manualNutrition.calories,
              protein: draft.manualNutrition.protein,
              carbs: draft.manualNutrition.carbs,
              fat: draft.manualNutrition.fat,
              fiber: draft.manualNutrition.fiber,
              sodium: draft.manualNutrition.sodium,
              sugar: draft.manualNutrition.sugar,
              createdAt: existingCreatedAt ?? DateTime.now(),
            ),
          );

      await (_database.delete(
        _database.savedMealAdjustments,
      )..where((table) => table.mealId.equals(mealId))).go();
      await (_database.delete(
        _database.savedMealComponents,
      )..where((table) => table.mealId.equals(mealId))).go();

      for (var index = 0; index < draft.adjustments.length; index++) {
        final adjustment = draft.adjustments[index].trim();
        if (adjustment.isEmpty) {
          continue;
        }
        await _database
            .into(_database.savedMealAdjustments)
            .insert(
              SavedMealAdjustmentsCompanion.insert(
                mealId: mealId,
                label: adjustment,
                position: index,
              ),
            );
      }

      for (var index = 0; index < draft.components.length; index++) {
        final component = draft.components[index];
        await _database
            .into(_database.savedMealComponents)
            .insert(
              SavedMealComponentsCompanion.insert(
                mealId: mealId,
                position: index,
                quantity: component.quantity.trim(),
                unit: component.unit.trim(),
                item: component.item.trim(),
                componentType: Value(component.linkType.name),
                linkedPantryItemId: Value(component.linkedPantryItemId),
                linkedRecipeId: Value(component.linkedRecipeId),
              ),
            );
      }
    });

    await _sync.recordChange(
      entityType: SyncEntityType.savedMeal,
      entityId: mealId,
      changeType: SyncChangeType.upsert,
      displayLabel: draft.name.trim(),
    );
  }

  Future<void> saveDayPlan(DayPlanDraft draft, {String? existingId}) async {
    final planId =
        existingId ?? 'day_plan_${DateTime.now().microsecondsSinceEpoch}';
    final existingCreatedAt = existingId == null
        ? null
        : await (_database.select(_database.dayPlansTable)
                ..where((table) => table.id.equals(existingId)))
              .map((row) => row.createdAt)
              .getSingleOrNull();

    await _database.transaction(() async {
      await _database
          .into(_database.dayPlansTable)
          .insertOnConflictUpdate(
            DayPlansTableCompanion.insert(
              id: planId,
              title: draft.name.trim(),
              note: draft.note.trim(),
              createdAt: existingCreatedAt ?? DateTime.now(),
            ),
          );

      await (_database.delete(
        _database.dayPlanEntriesTable,
      )..where((table) => table.planId.equals(planId))).go();

      for (var index = 0; index < draft.entries.length; index++) {
        final entry = draft.entries[index];
        await _database
            .into(_database.dayPlanEntriesTable)
            .insert(
              DayPlanEntriesTableCompanion.insert(
                planId: planId,
                position: index,
                mealSlot: entry.mealSlot.name,
                sourceType: entry.sourceType.name,
                sourceId: entry.sourceId.trim(),
                title: entry.title.trim(),
                quantity: entry.quantity.trim(),
                unit: entry.unit.trim(),
                calories: entry.nutrition.calories,
                protein: entry.nutrition.protein,
                carbs: entry.nutrition.carbs,
                fat: entry.nutrition.fat,
                fiber: entry.nutrition.fiber,
                sodium: entry.nutrition.sodium,
                sugar: entry.nutrition.sugar,
              ),
            );
      }
    });

    await _sync.recordChange(
      entityType: SyncEntityType.dayPlan,
      entityId: planId,
      changeType: SyncChangeType.upsert,
      displayLabel: draft.name.trim(),
    );
  }

  Future<DayPlanDraft> getDayPlanDraft(String id) async {
    final plan = await (_database.select(
      _database.dayPlansTable,
    )..where((table) => table.id.equals(id))).getSingle();
    final entries =
        await (_database.select(_database.dayPlanEntriesTable)
              ..where((table) => table.planId.equals(id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();

    return DayPlanDraft(
      name: plan.title,
      note: plan.note,
      entries: entries
          .map(
            (entry) => DayPlanEntryDraft(
              mealSlot: _mealSlotFromName(entry.mealSlot),
              sourceType: _entrySourceTypeFromName(entry.sourceType),
              sourceId: entry.sourceId,
              title: entry.title,
              quantity: entry.quantity,
              unit: entry.unit,
              nutrition: _nutritionFromDayPlanEntryRow(entry),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> saveDayPlanFromEntries({
    required String name,
    String note = '',
    required List<FoodLogEntry> entries,
    String? existingId,
  }) {
    return saveDayPlan(
      DayPlanDraft(
        name: name,
        note: note,
        entries: entries
            .map(
              (entry) => DayPlanEntryDraft(
                mealSlot: entry.mealSlot,
                sourceType: entry.sourceType,
                sourceId: entry.sourceId,
                title: entry.title,
                quantity: entry.quantity,
                unit: entry.unit,
                nutrition: entry.nutrition,
              ),
            )
            .toList(growable: false),
      ),
      existingId: existingId,
    );
  }

  Future<void> applyDayPlan(String id, {DateTime? date}) async {
    final planEntries =
        await (_database.select(_database.dayPlanEntriesTable)
              ..where((table) => table.planId.equals(id))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .get();
    if (planEntries.isEmpty) {
      return;
    }

    final entryIds = <String>[];
    final targetDate = date ?? SeedData.todayDate;
    final baseTimestamp = DateTime.now();

    await _database.transaction(() async {
      for (var index = 0; index < planEntries.length; index++) {
        final entry = planEntries[index];
        final entryId =
            'food_log_entry_${baseTimestamp.microsecondsSinceEpoch}_$index';
        entryIds.add(entryId);
        await _database
            .into(_database.foodLogEntriesTable)
            .insert(
              FoodLogEntriesTableCompanion.insert(
                id: entryId,
                entryDate: _dateKey(targetDate),
                mealSlot: entry.mealSlot,
                sourceType: entry.sourceType,
                sourceId: entry.sourceId,
                title: entry.title,
                quantity: entry.quantity,
                unit: entry.unit,
                calories: entry.calories,
                protein: entry.protein,
                carbs: entry.carbs,
                fat: entry.fat,
                fiber: entry.fiber,
                sodium: entry.sodium,
                sugar: entry.sugar,
                createdAt: baseTimestamp.add(Duration(milliseconds: index)),
              ),
            );
      }
    });

    for (var index = 0; index < planEntries.length; index++) {
      await _sync.recordChange(
        entityType: SyncEntityType.foodLogEntry,
        entityId: entryIds[index],
        changeType: SyncChangeType.upsert,
        displayLabel: planEntries[index].title.trim(),
      );
    }
  }

  Future<void> deleteDayPlan(String id) async {
    await (_database.delete(
      _database.dayPlanEntriesTable,
    )..where((table) => table.planId.equals(id))).go();
    await (_database.delete(
      _database.dayPlansTable,
    )..where((table) => table.id.equals(id))).go();
    await _sync.recordChange(
      entityType: SyncEntityType.dayPlan,
      entityId: id,
      changeType: SyncChangeType.delete,
    );
  }

  Future<void> deleteSavedMeal(String id) async {
    await (_database.delete(
      _database.savedMealsTable,
    )..where((table) => table.id.equals(id))).go();
    await _sync.recordChange(
      entityType: SyncEntityType.savedMeal,
      entityId: id,
      changeType: SyncChangeType.delete,
    );
  }

  Future<void> saveFoodLogEntry(
    FoodLogEntryDraft draft, {
    String? existingId,
  }) async {
    final entryId =
        existingId ?? 'food_log_entry_${DateTime.now().microsecondsSinceEpoch}';

    await _database
        .into(_database.foodLogEntriesTable)
        .insertOnConflictUpdate(
          FoodLogEntriesTableCompanion.insert(
            id: entryId,
            entryDate: _dateKey(draft.date),
            mealSlot: draft.mealSlot.name,
            sourceType: draft.sourceType.name,
            sourceId: draft.sourceId,
            title: draft.title,
            quantity: draft.quantity.trim(),
            unit: draft.unit.trim(),
            calories: draft.nutrition.calories,
            protein: draft.nutrition.protein,
            carbs: draft.nutrition.carbs,
            fat: draft.nutrition.fat,
            fiber: draft.nutrition.fiber,
            sodium: draft.nutrition.sodium,
            sugar: draft.nutrition.sugar,
            createdAt: DateTime.now(),
          ),
        );
    await _sync.recordChange(
      entityType: SyncEntityType.foodLogEntry,
      entityId: entryId,
      changeType: SyncChangeType.upsert,
      displayLabel: draft.title.trim(),
    );
  }

  Future<void> deleteFoodLogEntry(String id) async {
    await (_database.delete(
      _database.foodLogEntriesTable,
    )..where((table) => table.id.equals(id))).go();
    await _sync.recordChange(
      entityType: SyncEntityType.foodLogEntry,
      entityId: id,
      changeType: SyncChangeType.delete,
    );
  }

  NutritionSnapshot _nutritionFromSavedMealRow(SavedMealsTableData meal) {
    return NutritionSnapshot(
      calories: meal.calories,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      fiber: meal.fiber,
      sodium: meal.sodium,
      sugar: meal.sugar,
    );
  }

  NutritionSnapshot _nutritionFromFoodLogEntryRow(FoodLogEntriesTableData row) {
    return NutritionSnapshot(
      calories: row.calories,
      protein: row.protein,
      carbs: row.carbs,
      fat: row.fat,
      fiber: row.fiber,
      sodium: row.sodium,
      sugar: row.sugar,
    );
  }

  NutritionSnapshot _nutritionFromDayPlanEntryRow(
    DayPlanEntriesTableData entry,
  ) {
    return NutritionSnapshot(
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fat: entry.fat,
      fiber: entry.fiber,
      sodium: entry.sodium,
      sugar: entry.sugar,
    );
  }

  NutritionSnapshot _resolveSavedMealComponentNutrition({
    required SavedMealComponent component,
    required RecipesRepository recipeRepository,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, NutritionSnapshot> nutritionCache,
  }) {
    final quantity = recipeRepository._parseLinkedQuantity(component.quantity);
    final ingredientType = recipeRepository._ingredientTypeFromName(
      component.componentType,
    );
    final linkedPantryItem = pantryById[component.linkedPantryItemId];

    return switch (ingredientType) {
      RecipeIngredientType.freeform => NutritionSnapshot.zero,
      RecipeIngredientType.pantryItem =>
        linkedPantryItem == null
            ? NutritionSnapshot.zero
            : () {
                final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
                  quantity: quantity,
                  ingredientUnit: component.unit,
                  referenceUnit: linkedPantryItem.referenceUnit,
                  referenceUnitQuantity: linkedPantryItem.referenceUnitQuantity,
                  referenceUnitEquivalentQuantity:
                      linkedPantryItem.referenceUnitEquivalentQuantity,
                  referenceUnitEquivalentUnit:
                      linkedPantryItem.referenceUnitEquivalentUnit,
                  referenceUnitWeightGrams:
                      linkedPantryItem.referenceUnitWeightGrams,
                );
                if (!resolution.isResolved) {
                  return NutritionSnapshot.zero;
                }
                return recipeRepository
                    ._nutritionFromPantryItem(linkedPantryItem)
                    .scale(resolution.referenceUnits!);
              }(),
      RecipeIngredientType.recipeReference =>
        component.linkedRecipeId == null
            ? NutritionSnapshot.zero
            : () {
                final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
                  quantity: quantity,
                  ingredientUnit: component.unit,
                  referenceUnit: 'serving',
                );
                if (!resolution.isResolved) {
                  return NutritionSnapshot.zero;
                }
                return recipeRepository
                    ._resolveRecipeNutrition(
                      recipeId: component.linkedRecipeId!,
                      recipesById: recipesById,
                      ingredientsByRecipeId: ingredientsByRecipeId,
                      pantryById: pantryById,
                      nutritionCache: nutritionCache,
                    )
                    .scale(resolution.referenceUnits!);
              }(),
    };
  }

  List<FoodLogSuggestion> _buildFoodLogSuggestions({
    required FoodLogSnapshot snapshot,
    required List<FoodLogEntryTarget> targets,
  }) {
    if (targets.isEmpty) {
      return const <FoodLogSuggestion>[];
    }

    final consumedNutrition = snapshot.entries
        .map((entry) => entry.nutrition)
        .fold(NutritionSnapshot.zero, (total, item) => total + item);
    final goalsByLabel = {
      for (final goal in snapshot.goals) goal.label.trim().toLowerCase(): goal,
    };
    final recommendedSlot = _recommendedMealSlot(snapshot.entries);

    final suggestions =
        targets
            .map(
              (target) => FoodLogSuggestion(
                target: target,
                recommendedMealSlot: recommendedSlot,
                reason: _foodLogSuggestionReason(
                  target: target,
                  goalsByLabel: goalsByLabel,
                  consumedNutrition: consumedNutrition,
                ),
                score: _foodLogSuggestionScore(
                  target: target,
                  goalsByLabel: goalsByLabel,
                  consumedNutrition: consumedNutrition,
                ),
              ),
            )
            .where((suggestion) => suggestion.target.nutrition.calories > 0)
            .toList(growable: false)
          ..sort((left, right) {
            final scoreComparison = right.score.compareTo(left.score);
            if (scoreComparison != 0) {
              return scoreComparison;
            }
            final proteinComparison = right.target.nutrition.protein.compareTo(
              left.target.nutrition.protein,
            );
            if (proteinComparison != 0) {
              return proteinComparison;
            }
            return left.target.nutrition.calories.compareTo(
              right.target.nutrition.calories,
            );
          });

    return suggestions.take(4).toList(growable: false);
  }

  FoodLogMealSlot _recommendedMealSlot(List<FoodLogEntry> entries) {
    final counts = {for (final slot in FoodLogMealSlot.values) slot: 0};
    for (final entry in entries) {
      counts.update(entry.mealSlot, (count) => count + 1);
    }

    for (final slot in FoodLogMealSlot.values) {
      if (counts[slot] == 0) {
        return slot;
      }
    }

    return FoodLogMealSlot.values.reduce((best, candidate) {
      final bestCount = counts[best] ?? 0;
      final candidateCount = counts[candidate] ?? 0;
      return candidateCount < bestCount ? candidate : best;
    });
  }

  double _foodLogSuggestionScore({
    required FoodLogEntryTarget target,
    required Map<String, DailyGoal> goalsByLabel,
    required NutritionSnapshot consumedNutrition,
  }) {
    final nutrition = target.nutrition;
    final remainingCalories = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'calories',
      consumedNutrition: consumedNutrition,
    ).toDouble();
    final remainingProtein = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'protein',
      consumedNutrition: consumedNutrition,
    ).toDouble();
    final remainingCarbs = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'carbs',
      consumedNutrition: consumedNutrition,
    ).toDouble();
    final remainingFat = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'fat',
      consumedNutrition: consumedNutrition,
    ).toDouble();
    final remainingFiber = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'fiber',
      consumedNutrition: consumedNutrition,
    ).toDouble();
    final remainingSodium = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'sodium',
      consumedNutrition: consumedNutrition,
    ).toDouble();
    final remainingSugar = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'sugar',
      consumedNutrition: consumedNutrition,
    ).toDouble();

    final calories = nutrition.calories.toDouble();
    final protein = nutrition.protein.toDouble();
    final carbs = nutrition.carbs.toDouble();
    final fat = nutrition.fat.toDouble();
    final fiber = nutrition.fiber.toDouble();
    final sodium = nutrition.sodium.toDouble();
    final sugar = nutrition.sugar.toDouble();

    var score = 0.0;

    score += protein * 2.8;
    score += fiber * 1.9;
    score += math.min(protein, remainingProtein) * 1.4;
    score += math.min(fiber, remainingFiber) * 1.2;
    score += math.min(carbs, math.max(remainingCarbs, 0)) * 0.35;
    score += math.min(fat, math.max(remainingFat, 0)) * 0.2;

    if (calories > 0) {
      score += (protein / calories) * 220;
    }

    if (remainingCalories > 0) {
      if (calories <= remainingCalories) {
        final fitRatio =
            1 - ((remainingCalories - calories) / remainingCalories);
        score += 24 + (fitRatio * 18);
      } else {
        score -= math.min(48, (calories - remainingCalories) * 0.18);
      }
    } else {
      score -= calories * 0.12;
      score += protein * 0.8;
      score += fiber * 0.5;
    }

    if (remainingSodium <= 0) {
      score -= sodium * 0.012;
    } else if (sodium > remainingSodium) {
      score -= (sodium - remainingSodium) * 0.05;
    } else {
      score -= sodium * 0.003;
    }

    if (remainingSugar <= 0) {
      score -= sugar * 0.5;
    } else if (sugar > remainingSugar) {
      score -= (sugar - remainingSugar) * 1.2;
    } else {
      score -= sugar * 0.14;
    }

    return score;
  }

  String _foodLogSuggestionReason({
    required FoodLogEntryTarget target,
    required Map<String, DailyGoal> goalsByLabel,
    required NutritionSnapshot consumedNutrition,
  }) {
    final remainingCalories = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'calories',
      consumedNutrition: consumedNutrition,
    );
    final remainingProtein = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'protein',
      consumedNutrition: consumedNutrition,
    );
    final remainingCarbs = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'carbs',
      consumedNutrition: consumedNutrition,
    );
    final remainingFiber = _remainingGoalValue(
      goalsByLabel: goalsByLabel,
      label: 'fiber',
      consumedNutrition: consumedNutrition,
    );
    final nutrition = target.nutrition;

    if (remainingProtein > 0 &&
        nutrition.protein >= math.max(remainingProtein * 0.15, 12)) {
      return remainingCalories > 0 &&
              nutrition.calories <= remainingCalories + 75
          ? 'Strong protein lift that still fits today\'s calorie runway.'
          : 'Best for closing the protein gap first.';
    }

    if (remainingFiber > 0 &&
        nutrition.fiber >= math.max(remainingFiber * 0.2, 4)) {
      return 'Helps close the fiber gap while keeping the day balanced.';
    }

    if (remainingCalories > 0 && nutrition.calories <= remainingCalories) {
      return 'Fits the remaining calorie budget well for today.';
    }

    if (remainingCalories <= 0) {
      return 'Leans lighter while still adding useful nutrition.';
    }

    if (remainingCarbs > 0 &&
        nutrition.carbs >= math.max(remainingCarbs * 0.18, 12)) {
      return 'Useful if you still need energy and carbs for the day.';
    }

    return 'Balanced option based on today\'s remaining goals.';
  }

  int _remainingGoalValue({
    required Map<String, DailyGoal> goalsByLabel,
    required String label,
    required NutritionSnapshot consumedNutrition,
  }) {
    final normalizedLabel = label.trim().toLowerCase();
    final goal = goalsByLabel[normalizedLabel];
    final targetValue = goal?.target ?? 0;
    final consumedValue =
        goal?.consumed ?? _goalValueForLabel(consumedNutrition, label);
    return targetValue - consumedValue;
  }

  int _goalValueForLabel(NutritionSnapshot nutrition, String label) {
    return switch (label.trim().toLowerCase()) {
      'calories' => nutrition.calories,
      'protein' => nutrition.protein,
      'carbs' => nutrition.carbs,
      'fat' => nutrition.fat,
      'fiber' => nutrition.fiber,
      'sodium' => nutrition.sodium,
      'sugar' => nutrition.sugar,
      _ => 0,
    };
  }

  FoodLogMealSlot _mealSlotFromName(String value) {
    return FoodLogMealSlot.values.firstWhere(
      (slot) => slot.name == value,
      orElse: () => FoodLogMealSlot.snack,
    );
  }

  FoodLogEntrySourceType _entrySourceTypeFromName(String value) {
    return FoodLogEntrySourceType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => FoodLogEntrySourceType.savedMeal,
    );
  }

  String get _todayDateKey => _dateKey(SeedData.todayDate);

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _dateFromKey(String value) {
    final parts = value.split('-');
    if (parts.length != 3) {
      return SeedData.todayDate;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return SeedData.todayDate;
    }
    return DateTime(year, month, day);
  }
}

class _GroceryContribution {
  const _GroceryContribution({
    required this.key,
    required this.label,
    required this.sourceLabel,
    required this.isGenerated,
    required this.checkedByKey,
    this.quantity,
    this.unit = '',
    this.rawQuantity = '',
  });

  final String key;
  final String label;
  final double? quantity;
  final String unit;
  final String rawQuantity;
  final String sourceLabel;
  final bool isGenerated;
  final Map<String, bool> checkedByKey;
}

class _GroceryAggregate {
  final _buckets = <String, List<_AggregatedGroceryItem>>{};

  void add(_GroceryContribution contribution) {
    final buckets = _buckets.putIfAbsent(
      contribution.key,
      () => <_AggregatedGroceryItem>[],
    );
    for (final bucket in buckets) {
      if (bucket.tryAdd(contribution)) {
        return;
      }
    }
    buckets.add(_AggregatedGroceryItem.fromContribution(contribution));
  }

  List<GroceryListItem> toList() {
    final items = _buckets.values
        .expand((bucketList) => bucketList)
        .map((bucket) => bucket.toItem())
        .toList(growable: true);
    items.sort((left, right) => left.label.compareTo(right.label));
    return items;
  }
}

class _AggregatedGroceryItem {
  _AggregatedGroceryItem({
    required this.label,
    required this.key,
    required this.isGenerated,
    required this.isChecked,
    required this.quantity,
    required this.unit,
    required this.rawQuantity,
    required Set<String> sources,
  }) : _sources = sources;

  factory _AggregatedGroceryItem.fromContribution(
    _GroceryContribution contribution,
  ) {
    return _AggregatedGroceryItem(
      label: contribution.label,
      key: _stableItemKey(contribution),
      isGenerated: contribution.isGenerated,
      isChecked:
          contribution.checkedByKey[_stableItemKey(contribution)] ?? false,
      quantity: contribution.quantity,
      unit: contribution.unit.trim(),
      rawQuantity: contribution.rawQuantity.trim(),
      sources: {contribution.sourceLabel},
    );
  }

  final String label;
  final String key;
  final bool isGenerated;
  final bool isChecked;
  double? quantity;
  final String unit;
  final String rawQuantity;
  final Set<String> _sources;

  bool tryAdd(_GroceryContribution contribution) {
    if (label != contribution.label) {
      return false;
    }
    final currentUnit = unit.trim();
    final incomingUnit = contribution.unit.trim();

    if (quantity != null && contribution.quantity != null) {
      final converted = MeasurementUnits.tryConvertQuantity(
        quantity: contribution.quantity!,
        fromUnit: incomingUnit,
        toUnit: currentUnit,
      );
      if (converted != null) {
        quantity = quantity! + converted;
        _sources.add(contribution.sourceLabel);
        return true;
      }
    }

    final mergedTextOnly =
        quantity == null &&
        contribution.quantity == null &&
        currentUnit == incomingUnit &&
        rawQuantity == contribution.rawQuantity.trim();
    if (mergedTextOnly) {
      _sources.add(contribution.sourceLabel);
      return true;
    }

    return false;
  }

  GroceryListItem toItem() {
    final detail = () {
      if (quantity != null) {
        final parts = [
          MeasurementUnits.formatDecimal(quantity!),
          if (unit.trim().isNotEmpty) unit.trim(),
        ];
        return parts.join(' ');
      }

      final parts = [
        if (rawQuantity.isNotEmpty) rawQuantity,
        if (unit.trim().isNotEmpty) unit.trim(),
      ];
      final text = parts.join(' ').trim();
      return text.isEmpty ? null : text;
    }();

    final sortedSources = _sources.toList()..sort();
    return GroceryListItem(
      key: key,
      label: label,
      detail: detail,
      sourceSummary: sortedSources.join(', '),
      isChecked: isChecked,
      isGenerated: isGenerated,
    );
  }

  static String _stableItemKey(_GroceryContribution contribution) {
    final normalizedUnit = contribution.unit.trim().toLowerCase();
    if (contribution.quantity != null) {
      return '${contribution.key}|unit:$normalizedUnit';
    }
    return '${contribution.key}|raw:${contribution.rawQuantity.trim().toLowerCase()}|unit:$normalizedUnit';
  }
}

extension _CombineLatestExtension<T> on Stream<T> {
  Stream<R> combineLatest<U, R>(
    Stream<U> other,
    R Function(T left, U right) combiner,
  ) {
    late T latestLeft;
    late U latestRight;
    var hasLeft = false;
    var hasRight = false;

    final controller = StreamController<R>.broadcast();

    void emitIfReady() {
      if (hasLeft && hasRight) {
        controller.add(combiner(latestLeft, latestRight));
      }
    }

    final leftSubscription = listen(
      (value) {
        latestLeft = value;
        hasLeft = true;
        emitIfReady();
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    final rightSubscription = other.listen((value) {
      latestRight = value;
      hasRight = true;
      emitIfReady();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await leftSubscription.cancel();
      await rightSubscription.cancel();
    };

    return controller.stream;
  }

  Stream<R> combineLatest3<U, V, R>(
    Stream<U> second,
    Stream<V> third,
    R Function(T first, U second, V third) combiner,
  ) {
    return combineLatest(
      second.combineLatest(third, (right, last) => (right, last)),
      (first, combined) => combiner(first, combined.$1, combined.$2),
    );
  }
}
