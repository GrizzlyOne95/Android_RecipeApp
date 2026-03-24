enum SyncEntityType {
  recipe,
  pantryItem,
  groceryItem,
  savedMeal,
  dayPlan,
  mealPlan,
  foodLogEntry,
}

enum SyncChangeType { upsert, delete }

enum SyncAuthState { signedOut, connected }

class SyncActionResult {
  const SyncActionResult({required this.isSuccess, required this.message});

  final bool isSuccess;
  final String message;
}

class SyncQueueItem {
  const SyncQueueItem({
    required this.entityType,
    required this.entityId,
    required this.changeType,
    required this.changedAt,
    this.displayLabel,
  });

  final SyncEntityType entityType;
  final String entityId;
  final SyncChangeType changeType;
  final DateTime changedAt;
  final String? displayLabel;
}

class SyncEntityCount {
  const SyncEntityCount({required this.entityType, required this.count});

  final SyncEntityType entityType;
  final int count;
}

class SyncDiagnosticEntry {
  const SyncDiagnosticEntry({required this.message, required this.recordedAt});

  final String message;
  final DateTime recordedAt;
}

class SyncStatus {
  const SyncStatus({
    required this.authState,
    required this.pendingItems,
    required this.isCloudConfigured,
    required this.cloudStatusMessage,
    this.providerLabel,
    this.accountEmail,
    this.accountId,
    this.connectedAt,
    this.lastLocalChangeAt,
    this.oldestPendingChangeAt,
    this.lastSyncedAt,
    this.lastSyncSummary,
    this.lastErrorMessage,
    this.lastConflictMessage,
    this.recentErrors = const <SyncDiagnosticEntry>[],
    this.recentConflicts = const <SyncDiagnosticEntry>[],
    this.isSyncing = false,
  });

  static const initial = SyncStatus(
    authState: SyncAuthState.signedOut,
    pendingItems: <SyncEntityCount>[],
    isCloudConfigured: false,
    cloudStatusMessage: 'Cloud sync is not configured yet.',
  );

  final SyncAuthState authState;
  final bool isCloudConfigured;
  final String cloudStatusMessage;
  final String? providerLabel;
  final String? accountEmail;
  final String? accountId;
  final DateTime? connectedAt;
  final DateTime? lastLocalChangeAt;
  final DateTime? oldestPendingChangeAt;
  final DateTime? lastSyncedAt;
  final String? lastSyncSummary;
  final String? lastErrorMessage;
  final String? lastConflictMessage;
  final List<SyncDiagnosticEntry> recentErrors;
  final List<SyncDiagnosticEntry> recentConflicts;
  final bool isSyncing;
  final List<SyncEntityCount> pendingItems;

  int get pendingChangeCount =>
      pendingItems.fold(0, (total, item) => total + item.count);

  bool get isConnected => authState == SyncAuthState.connected;

  bool get canConnect => isCloudConfigured && !isConnected && !isSyncing;

  bool get canSync => isCloudConfigured && isConnected && !isSyncing;
}

extension SyncEntityTypeLabel on SyncEntityType {
  String get label => switch (this) {
    SyncEntityType.recipe => 'Recipes',
    SyncEntityType.pantryItem => 'Pantry',
    SyncEntityType.groceryItem => 'Grocery',
    SyncEntityType.savedMeal => 'Saved Meals',
    SyncEntityType.dayPlan => 'Day Plans',
    SyncEntityType.mealPlan => 'Meal Plans',
    SyncEntityType.foodLogEntry => 'Food Log',
  };
}

extension SyncChangeTypeLabel on SyncChangeType {
  String get label => switch (this) {
    SyncChangeType.upsert => 'Upsert',
    SyncChangeType.delete => 'Delete',
  };
}
