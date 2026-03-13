import 'package:flutter/material.dart';

import '../../app/recipe_app_scope.dart';
import '../../core/mock_data.dart';
import '../../data/repositories/app_repositories.dart';
import '../shell/app_shell.dart';

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key});

  @override
  State<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
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
        children: [
          FilledButton.icon(
            onPressed: () => _openQuickAdd(context, repository),
            icon: const Icon(Icons.add),
            label: const Text('Add single item'),
          ),
          StreamBuilder<GroceryExportSettings>(
            stream: repository.watchExportSettings(),
            builder: (context, snapshot) {
              final settings = snapshot.data ?? GroceryExportSettings.defaults;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilterChip(
                    selected: settings.includePinnedRecipes,
                    label: const Text('Pinned recipes'),
                    onSelected: (value) {
                      repository.setExportSettings(
                        settings.copyWith(includePinnedRecipes: value),
                      );
                    },
                  ),
                  FilterChip(
                    selected: settings.includeSavedMeals,
                    label: const Text('Saved meals'),
                    onSelected: (value) {
                      repository.setExportSettings(
                        settings.copyWith(includeSavedMeals: value),
                      );
                    },
                  ),
                ],
              );
            },
          ),
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
                    .map(
                      (section) => _GrocerySectionCard(
                        section: section,
                        repository: repository,
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openQuickAdd(
    BuildContext context,
    GroceryRepository repository,
  ) async {
    final result = await showModalBottomSheet<GroceryManualItemDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _QuickAddSheet(),
    );

    if (result == null || !context.mounted) {
      return;
    }

    await repository.saveManualItem(result);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grocery item added locally.')),
    );
  }
}

class _GrocerySectionCard extends StatelessWidget {
  const _GrocerySectionCard({required this.section, required this.repository});

  final GrocerySection section;
  final GroceryRepository repository;

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          repository.toggleItemChecked(item, !item.isChecked);
                        },
                        icon: Icon(
                          item.isChecked
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: theme.textTheme.bodyLarge,
                              ),
                              if (item.detail != null ||
                                  item.sourceSummary != null)
                                const SizedBox(height: 2),
                              if (item.detail != null)
                                Text(
                                  item.detail!,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              if (item.sourceSummary != null)
                                Text(
                                  item.sourceSummary!,
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!item.isGenerated)
                        IconButton(
                          onPressed: () async {
                            final manualId = int.tryParse(
                              item.key.replaceFirst('manual:', ''),
                            );
                            if (manualId == null) {
                              return;
                            }
                            await repository.deleteManualItem(manualId);
                          },
                          icon: const Icon(Icons.delete_outline),
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

class _QuickAddSheet extends StatefulWidget {
  const _QuickAddSheet();

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sectionController;
  late final TextEditingController _labelController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _sectionController = TextEditingController(text: 'Quick Add');
    _labelController = TextEditingController();
    _quantityController = TextEditingController();
    _unitController = TextEditingController();
  }

  @override
  void dispose() {
    _sectionController.dispose();
    _labelController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add grocery item',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Use this for one-off items that do not come from a recipe or saved meal export.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _QuickAddSection(
                title: 'Item',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _sectionController,
                      decoration: const InputDecoration(
                        labelText: 'Section',
                        hintText: 'Quick Add, Produce, Pantry Refill',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        labelText: 'Label',
                        hintText: 'Bananas, Sour cream, Tortilla chips',
                      ),
                      validator: _requiredText,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(labelText: 'Qty'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Add item'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      GroceryManualItemDraft(
        sectionTitle: _sectionController.text.trim(),
        label: _labelController.text.trim(),
        quantity: _quantityController.text.trim(),
        unit: _unitController.text.trim(),
      ),
    );
  }
}

class _QuickAddSection extends StatelessWidget {
  const _QuickAddSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
