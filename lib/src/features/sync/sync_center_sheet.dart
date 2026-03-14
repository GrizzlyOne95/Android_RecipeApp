import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../firebase_options.dart';
import '../../app/recipe_app_scope.dart';
import '../../core/sync_models.dart';

Future<void> showSyncCenterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => const _SyncCenterSheet(),
  );
}

class _SyncCenterSheet extends StatelessWidget {
  const _SyncCenterSheet();

  @override
  Widget build(BuildContext context) {
    final repositories = RecipeAppScope.of(context).repositories;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return StreamBuilder<SyncStatus>(
      stream: repositories.sync.watchStatus(),
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data ?? SyncStatus.initial;

        return StreamBuilder<List<SyncQueueItem>>(
          stream: repositories.sync.watchQueueItems(),
          builder: (context, queueSnapshot) {
            final queueItems = queueSnapshot.data ?? const <SyncQueueItem>[];

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + viewInsets.bottom),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sync Center',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The app stays local-first. This build is already pointed at Firebase project ${DefaultFirebaseOptions.projectId}, and the remaining console setup will unlock Google sign-in plus Firestore backup.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    _SyncStatusCard(
                      status: status,
                      onConnect: () => _runAction(
                        context,
                        repositories.sync.connectGoogleAccount,
                      ),
                      onDisconnect: () =>
                          _runAction(context, repositories.sync.disconnect),
                      onSyncNow: () =>
                          _runAction(context, repositories.sync.syncNow),
                      onShowSetup: () => _openSetupSheet(context),
                    ),
                    const SizedBox(height: 16),
                    if (!status.isCloudConfigured) ...[
                      _SetupHintCard(onTap: () => _openSetupSheet(context)),
                      const SizedBox(height: 16),
                      const _SetupStatusCard(),
                      const SizedBox(height: 16),
                    ],
                    if (status.lastErrorMessage case final error?) ...[
                      _StatusNoticeCard(
                        tone: _NoticeTone.error,
                        title: 'Last Sync Error',
                        body: error,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (status.pendingItems.isNotEmpty) ...[
                      Text(
                        'Pending Cloud Queue',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: status.pendingItems
                            .map(
                              (item) => _CountPill(
                                label: item.entityType.label,
                                value: item.count.toString(),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Recent Queue Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (queueItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0E6D7),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Text(
                          'No pending cloud changes yet. Local edits will appear here automatically.',
                        ),
                      )
                    else
                      ...queueItems
                          .take(8)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _QueueItemCard(item: item),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _runAction(
    BuildContext context,
    Future<SyncActionResult> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await action();
    if (!context.mounted) {
      return;
    }

    messenger.showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _openSetupSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => const _SyncSetupSheet(),
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({
    required this.status,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSyncNow,
    required this.onShowSetup,
  });

  final SyncStatus status;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onSyncNow;
  final VoidCallback onShowSetup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('MMM d, h:mm a');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      status.isCloudConfigured
                          ? status.isConnected
                                ? '${status.providerLabel ?? 'Google'} connected for ${status.accountEmail ?? 'local profile'}.'
                                : 'Firebase is configured. Connect Google when you want cloud backup.'
                          : 'Cloud sync is still optional. Finish Firebase setup to unlock Google sign-in and Firestore backup.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                children: [
                  if (!status.isCloudConfigured)
                    OutlinedButton.icon(
                      onPressed: onShowSetup,
                      icon: const Icon(Icons.settings_suggest_outlined),
                      label: const Text('Setup'),
                    )
                  else if (status.isConnected) ...[
                    FilledButton.tonalIcon(
                      onPressed: status.canSync ? onSyncNow : null,
                      icon: status.isSyncing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload_outlined),
                      label: Text(status.isSyncing ? 'Syncing' : 'Sync Now'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: onDisconnect,
                      icon: const Icon(Icons.logout),
                      label: const Text('Disconnect'),
                    ),
                  ] else
                    FilledButton.tonalIcon(
                      onPressed: status.canConnect ? onConnect : null,
                      icon: const Icon(Icons.login),
                      label: const Text('Connect Google'),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CountPill(
                label: 'Pending',
                value: status.pendingChangeCount.toString(),
              ),
              if (status.connectedAt case final connectedAt?)
                _CountPill(
                  label: 'Connected',
                  value: formatter.format(connectedAt),
                ),
              if (status.lastSyncedAt case final syncedAt?)
                _CountPill(
                  label: 'Last cloud sync',
                  value: formatter.format(syncedAt),
                ),
              if (status.lastLocalChangeAt case final changedAt?)
                _CountPill(
                  label: 'Last local change',
                  value: formatter.format(changedAt),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(status.cloudStatusMessage, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _QueueItemCard extends StatelessWidget {
  const _QueueItemCard({required this.item});

  final SyncQueueItem item;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE7D9BF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.cloud_upload_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.displayLabel ?? item.entityId),
                const SizedBox(height: 4),
                Text(
                  '${item.entityType.label} • ${item.changeType.label} • ${formatter.format(item.changedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _SetupHintCard extends StatelessWidget {
  const _SetupHintCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _StatusNoticeCard(
      tone: _NoticeTone.info,
      title: 'Setup Needed',
      body:
          'The app can already queue local changes for Firestore. Finish Firebase config once, then Google sign-in and Sync Now will light up here.',
      actionLabel: 'View setup steps',
      onAction: onTap,
    );
  }
}

class _StatusNoticeCard extends StatelessWidget {
  const _StatusNoticeCard({
    required this.tone,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final _NoticeTone tone;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _NoticeTone.info => const Color(0xFFF0E6D7),
      _NoticeTone.error => const Color(0xFFF7DED8),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

enum _NoticeTone { info, error }

class _SyncSetupSheet extends StatelessWidget {
  const _SyncSetupSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firebase Setup',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '1. The repo is already linked to ${DefaultFirebaseOptions.projectId}.\n'
              '2. In Firebase Auth, enable Google sign-in for the existing app ids:\n'
              'Android: ${DefaultFirebaseOptions.androidApplicationId}\n'
              'iOS: ${DefaultFirebaseOptions.iosBundleId}\n'
              '3. Add the Android SHA fingerprints so Firebase can mint Google ID tokens for this debug build.\n'
              '4. Enable Cloud Firestore for the project, then deploy this repo\'s rules and indexes.\n'
              '5. If Firebase later exposes the missing OAuth client ids, relaunch with the command below or regenerate firebase_options.dart.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _SetupStatusCard(),
            const SizedBox(height: 16),
            const _CommandCard(
              title: 'Android debug fingerprints',
              command:
                  'SHA1: E3:2E:1A:D2:99:0F:0F:6C:14:36:27:53:5F:2B:49:F1:52:85:01:BC\n'
                  'SHA256: A0:49:56:43:91:17:5E:D6:D5:B9:5C:20:5C:05:84:25:07:76:8F:A6:3F:C8:32:62:0C:B1:80:87:F6:46:C4:7A',
            ),
            const SizedBox(height: 16),
            _CommandCard(
              title: 'Example launch command',
              command: DefaultFirebaseOptions.exampleFlutterRunCommand,
            ),
            const SizedBox(height: 16),
            const _CommandCard(
              title: 'Deploy Firestore config',
              command:
                  'firebase use nutrichef-recipeapp-6d24f\n'
                  'firebase deploy --only firestore:rules,firestore:indexes',
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupStatusCard extends StatelessWidget {
  const _SetupStatusCard();

  @override
  Widget build(BuildContext context) {
    final report = DefaultFirebaseOptions.setupStatus;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Config Checklist',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            DefaultFirebaseOptions.missingKeys.isEmpty
                ? 'All required Firebase values are present for this build.'
                : 'Still missing ${DefaultFirebaseOptions.missingKeys.length} required value${DefaultFirebaseOptions.missingKeys.length == 1 ? '' : 's'}.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          for (final platform in report) ...[
            Text(
              '${platform.platformLabel} • ${platform.appIdentifier}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final field in platform.fields)
                  _FieldPill(
                    label: field.key,
                    statusLabel: field.isProvided ? 'Ready' : 'Missing',
                    isReady: field.isProvided,
                  ),
              ],
            ),
            if (platform != report.last) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _FieldPill extends StatelessWidget {
  const _FieldPill({
    required this.label,
    required this.statusLabel,
    required this.isReady,
  });

  final String label;
  final String statusLabel;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isReady ? const Color(0xFFE6F1E0) : const Color(0xFFF7DED8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(statusLabel, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _CommandCard extends StatelessWidget {
  const _CommandCard({required this.title, required this.command});

  final String title;
  final String command;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SelectableText(
            command,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
