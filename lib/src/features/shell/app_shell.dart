import 'package:flutter/material.dart';

import '../../app/recipe_app_scope.dart';
import '../../core/mock_data.dart';
import '../../core/sync_models.dart';
import '../food_log/food_log_page.dart';
import '../grocery/grocery_page.dart';
import '../pantry/pantry_page.dart';
import '../recipes/recipes_page.dart';
import '../sync/sync_center_sheet.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    _ShellDestination(
      label: 'Recipes',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      page: RecipesPage(),
    ),
    _ShellDestination(
      label: 'Grocery',
      icon: Icons.shopping_basket_outlined,
      selectedIcon: Icons.shopping_basket,
      page: GroceryPage(),
    ),
    _ShellDestination(
      label: 'Pantry',
      icon: Icons.kitchen_outlined,
      selectedIcon: Icons.kitchen,
      page: PantryPage(),
    ),
    _ShellDestination(
      label: 'Food Log',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      page: FoodLogPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final page = _destinations[_selectedIndex].page;
    final repositories = RecipeAppScope.of(context).repositories;

    return StreamBuilder<SyncStatus>(
      stream: repositories.sync.watchStatus(),
      builder: (context, snapshot) {
        final syncStatus = snapshot.data ?? SyncStatus.initial;

        return LayoutBuilder(
          builder: (context, constraints) {
            final useRail = constraints.maxWidth >= 900;

            return Scaffold(
              body: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFF8EC),
                      Color(0xFFF6F0E4),
                      Color(0xFFEFE4D2),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: useRail
                      ? Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: _AppRail(
                                selectedIndex: _selectedIndex,
                                destinations: _destinations,
                                onSelected: _onSelected,
                                syncStatus: syncStatus,
                                onOpenSync: () => _openSyncCenter(context),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  24,
                                  24,
                                  24,
                                ),
                                child: page,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(child: page),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.tonalIcon(
                                      onPressed: () => _openSyncCenter(context),
                                      icon: const Icon(
                                        Icons.cloud_sync_outlined,
                                      ),
                                      label: Text(
                                        syncStatus.pendingChangeCount == 0
                                            ? 'Sync'
                                            : 'Sync (${syncStatus.pendingChangeCount})',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () =>
                                          _openUniversalQuickAdd(context),
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.tertiary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Quick Add'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            NavigationBar(
                              selectedIndex: _selectedIndex,
                              onDestinationSelected: _onSelected,
                              destinations: _destinations
                                  .map(
                                    (destination) => NavigationDestination(
                                      icon: Icon(destination.icon),
                                      selectedIcon: Icon(
                                        destination.selectedIcon,
                                      ),
                                      label: destination.label,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                ),
              ),
              floatingActionButton: useRail
                  ? FloatingActionButton.extended(
                      onPressed: () => _openUniversalQuickAdd(context),
                      backgroundColor: theme.colorScheme.tertiary,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.add),
                      label: const Text('Quick Add'),
                    )
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            );
          },
        );
      },
    );
  }

  Future<void> _openSyncCenter(BuildContext context) {
    return showSyncCenterSheet(context);
  }

  void _onSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openUniversalQuickAdd(BuildContext context) async {
    final action = await showModalBottomSheet<_QuickAddAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => const _UniversalQuickAddSheet(),
    );
    if (action == null || !context.mounted) {
      return;
    }

    final repositories = RecipeAppScope.of(context).repositories;

    switch (action) {
      case _QuickAddAction.grocery:
        final draft = await showGroceryQuickAddSheet(context);
        if (draft == null || !context.mounted) {
          return;
        }
        await repositories.grocery.saveManualItem(draft);
        if (!context.mounted) {
          return;
        }
        _onSelected(1);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grocery item added locally.')),
        );
      case _QuickAddAction.pantry:
        final draft = await showPantryItemEditorSheet(context);
        if (draft == null || !context.mounted) {
          return;
        }
        await repositories.pantry.savePantryItem(draft);
        if (!context.mounted) {
          return;
        }
        _onSelected(2);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pantry item added locally.')),
        );
      case _QuickAddAction.foodLog:
        final draft = await showFoodLogEntryEditorSheet(
          context,
          repositories.foodLog,
        );
        if (draft == null || !context.mounted) {
          return;
        }
        await repositories.foodLog.saveFoodLogEntry(draft);
        if (!context.mounted) {
          return;
        }
        _onSelected(3);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Food log entry added.')));
    }
  }
}

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Wrap(
                    runSpacing: 20,
                    spacing: 20,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: theme.textTheme.displaySmall),
                            const SizedBox(height: 12),
                            Text(subtitle, style: theme.textTheme.bodyLarge),
                          ],
                        ),
                      ),
                      trailing ??
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Today',
                                  style: theme.textTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  SeedData.todayLabel,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(caption, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _AppRail extends StatelessWidget {
  const _AppRail({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
    required this.syncStatus,
    required this.onOpenSync,
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onSelected;
  final SyncStatus syncStatus;
  final VoidCallback onOpenSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: SizedBox(
        width: 240,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kitchen Ledger', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Recipes, pantry math, groceries, and daily nutrition in one place.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.9,
              destinations: destinations
                  .map(
                    (destination) => NavigationRailDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: Text(destination.label),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Material(
                color: const Color(0xFF4F6B44),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: onOpenSync,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.cloud_sync, color: Colors.white),
                        const SizedBox(height: 10),
                        Text(
                          syncStatus.isConnected
                              ? 'Cloud account connected'
                              : 'Local-first now. Google sync next.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          syncStatus.pendingChangeCount == 0
                              ? 'No pending cloud changes'
                              : '${syncStatus.pendingChangeCount} pending cloud changes',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}

enum _QuickAddAction { grocery, pantry, foodLog }

class _UniversalQuickAddSheet extends StatelessWidget {
  const _UniversalQuickAddSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.82),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + mediaQuery.padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Add', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Capture the next thing you need to shop, stock, or log without leaving your current screen.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            _QuickAddOptionCard(
              icon: Icons.shopping_basket_outlined,
              title: 'Grocery item',
              subtitle: 'Drop a one-off shopping item into any section.',
              onTap: () => Navigator.of(context).pop(_QuickAddAction.grocery),
            ),
            const SizedBox(height: 12),
            _QuickAddOptionCard(
              icon: Icons.kitchen_outlined,
              title: 'Pantry item',
              subtitle: 'Capture brand, barcode, package size, and nutrition.',
              onTap: () => Navigator.of(context).pop(_QuickAddAction.pantry),
            ),
            const SizedBox(height: 12),
            _QuickAddOptionCard(
              icon: Icons.insights_outlined,
              title: 'Food log entry',
              subtitle:
                  'Snapshot what you ate from a meal, recipe, or pantry item.',
              onTap: () => Navigator.of(context).pop(_QuickAddAction.foodLog),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddOptionCard extends StatelessWidget {
  const _QuickAddOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: const Color(0xFFF0E6D7),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
