import 'package:flutter/material.dart';

import '../../app/recipe_app_scope.dart';
import '../../core/mock_data.dart';
import '../shell/app_shell.dart';

class GroceryPage extends StatelessWidget {
  const GroceryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RecipeAppScope.of(context).repositories.grocery;

    return ShellScaffold(
      title: 'Grocery List',
      subtitle:
          'Export ingredients from recipes or pinned meal plans, then mix in standalone ingredients like sour cream, fruit, or snacks.',
      trailing: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: const [
          Chip(label: Text('From meal plan')),
          Chip(label: Text('Add single item')),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Shopping Flow',
            caption:
                'Meal-plan exports and one-off items live together so the shopping list matches how you actually cook.',
          ),
          StreamBuilder<List<GrocerySection>>(
            stream: repository.watchGrocerySections(),
            builder: (context, snapshot) {
              final sections = snapshot.data ?? const <GrocerySection>[];

              return Column(
                children: sections
                    .map((section) => _GrocerySectionCard(section))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GrocerySectionCard extends StatelessWidget {
  const _GrocerySectionCard(this.section);

  final GrocerySection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              ...section.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_box_outline_blank, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item, style: theme.textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
