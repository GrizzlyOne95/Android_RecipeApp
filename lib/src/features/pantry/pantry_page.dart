import 'package:flutter/material.dart';

import '../../app/recipe_app_scope.dart';
import '../../core/mock_data.dart';
import '../shell/app_shell.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RecipeAppScope.of(context).repositories.pantry;

    return ShellScaffold(
      title: 'Pantry',
      subtitle:
          'Track the exact products you own, scan barcodes when possible, and let recipes pull nutrition from real pantry items before calculating totals.',
      trailing: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: const [
          Chip(label: Text('Scan barcode')),
          Chip(label: Text('Manual item')),
          Chip(label: Text('Import photo')),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'My Pantry',
            caption:
                'These item cards model the source-of-truth nutrition records that future recipes and saved meals will reference.',
          ),
          StreamBuilder<List<PantryItem>>(
            stream: repository.watchPantryItems(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <PantryItem>[];

              return Column(
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _PantryCard(item: item),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PantryCard extends StatelessWidget {
  const _PantryCard({required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Wrap(
          runSpacing: 18,
          spacing: 18,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: item.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(Icons.inventory_2, color: item.accent, size: 32),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(item.quantityLabel, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(item.source, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricPill(
                  label: 'Calories',
                  value: '${item.nutrition.calories}',
                ),
                _MetricPill(
                  label: 'Protein',
                  value: '${item.nutrition.protein}g',
                ),
                _MetricPill(label: 'Fiber', value: '${item.nutrition.fiber}g'),
                _MetricPill(
                  label: 'Sodium',
                  value: '${item.nutrition.sodium}mg',
                ),
                _MetricPill(label: 'Sugar', value: '${item.nutrition.sugar}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
