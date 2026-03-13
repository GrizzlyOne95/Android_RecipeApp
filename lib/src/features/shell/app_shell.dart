import 'package:flutter/material.dart';

import '../../core/mock_data.dart';
import '../food_log/food_log_page.dart';
import '../grocery/grocery_page.dart';
import '../pantry/pantry_page.dart';
import '../recipes/recipes_page.dart';

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
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                            child: page,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(child: page),
                        NavigationBar(
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: _onSelected,
                          destinations: _destinations
                              .map(
                                (destination) => NavigationDestination(
                                  icon: Icon(destination.icon),
                                  selectedIcon: Icon(destination.selectedIcon),
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
                  onPressed: () {},
                  backgroundColor: theme.colorScheme.tertiary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text('Quick Add'),
                )
              : null,
        );
      },
    );
  }

  void _onSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
  });

  final int selectedIndex;
  final List<_ShellDestination> destinations;
  final ValueChanged<int> onSelected;

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
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F6B44),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cloud_sync, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Local-first now. Google sync next.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
