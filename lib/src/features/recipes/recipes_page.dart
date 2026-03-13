import 'package:flutter/material.dart';

import '../../app/recipe_app_scope.dart';
import '../../core/mock_data.dart';
import '../../data/repositories/app_repositories.dart';
import '../shell/app_shell.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RecipeAppScope.of(context).repositories.recipes;

    return ShellScaffold(
      title: 'Recipes',
      subtitle:
          'Save full recipes, create variations, nest recipes inside recipes, and keep nutrition updated per serving.',
      trailing: _RecipeActions(
        onAddPressed: () => _openEditor(context, repository),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Pinned and Recent',
            caption:
                'Recipes now load from the local database and can be added, edited, and deleted from this screen.',
          ),
          StreamBuilder<List<RecipeSummary>>(
            stream: repository.watchRecipes(),
            builder: (context, snapshot) {
              final recipes = snapshot.data ?? const <RecipeSummary>[];

              return LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 1100
                      ? 3
                      : constraints.maxWidth >= 680
                      ? 2
                      : 1;
                  final itemWidth =
                      (constraints.maxWidth - ((columns - 1) * 16)) / columns;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: recipes
                        .map(
                          (recipe) => SizedBox(
                            width: itemWidth,
                            child: _RecipeCard(
                              recipe: recipe,
                              onEdit: () => _openEditor(
                                context,
                                repository,
                                recipe: recipe,
                              ),
                              onDelete: () =>
                                  _deleteRecipe(context, repository, recipe),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    RecipesRepository repository, {
    RecipeSummary? recipe,
  }) async {
    final draft = await showModalBottomSheet<RecipeDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => RecipeEditorSheet(recipe: recipe),
    );

    if (draft == null || !context.mounted) {
      return;
    }

    await repository.saveRecipe(draft, existingId: recipe?.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            recipe == null
                ? 'Recipe added locally.'
                : 'Recipe updated locally.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteRecipe(
    BuildContext context,
    RecipesRepository repository,
    RecipeSummary recipe,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text(
          'Remove "${recipe.name}" from the local recipe database?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await repository.deleteRecipe(recipe.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"${recipe.name}" deleted.')));
    }
  }
}

class _RecipeActions extends StatelessWidget {
  const _RecipeActions({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add),
          label: const Text('Add recipe'),
        ),
        const Chip(label: Text('Sort: Low to high')),
        const Chip(label: Text('Import URL')),
        const Chip(label: Text('OCR screenshot')),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onEdit,
    required this.onDelete,
  });

  final RecipeSummary recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(recipe.name, style: theme.textTheme.titleLarge),
                ),
                if (recipe.isPinned)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.push_pin, color: Color(0xFFD87B42)),
                  ),
                PopupMenuButton<_RecipeMenuAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _RecipeMenuAction.edit:
                        onEdit();
                      case _RecipeMenuAction.delete:
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _RecipeMenuAction.edit,
                      child: Text('Edit'),
                    ),
                    PopupMenuItem(
                      value: _RecipeMenuAction.delete,
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(recipe.versionLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recipe.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(growable: false),
            ),
            const SizedBox(height: 18),
            _NutritionGrid(
              nutrition: recipe.nutrition,
              servings: recipe.servings,
            ),
            const SizedBox(height: 18),
            Text(recipe.note, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

enum _RecipeMenuAction { edit, delete }

class _NutritionGrid extends StatelessWidget {
  const _NutritionGrid({required this.nutrition, required this.servings});

  final NutritionSnapshot nutrition;
  final int servings;

  @override
  Widget build(BuildContext context) {
    final values = [
      ('Calories', nutrition.calories.toString()),
      ('Protein', '${nutrition.protein}g'),
      ('Carbs', '${nutrition.carbs}g'),
      ('Fat', '${nutrition.fat}g'),
      ('Fiber', '${nutrition.fiber}g'),
      ('Servings', servings.toString()),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: values
          .map(
            (entry) => Container(
              width: 112,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0E6D7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.$1, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    entry.$2,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class RecipeEditorSheet extends StatefulWidget {
  const RecipeEditorSheet({super.key, this.recipe});

  final RecipeSummary? recipe;

  @override
  State<RecipeEditorSheet> createState() => _RecipeEditorSheetState();
}

class _RecipeEditorSheetState extends State<RecipeEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _versionController;
  late final TextEditingController _servingsController;
  late final TextEditingController _tagsController;
  late final TextEditingController _notesController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _fiberController;
  late final TextEditingController _sodiumController;
  late final TextEditingController _sugarController;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _titleController = TextEditingController(text: recipe?.name ?? '');
    _versionController = TextEditingController(
      text: recipe?.versionLabel ?? '',
    );
    _servingsController = TextEditingController(
      text: recipe?.servings.toString() ?? '1',
    );
    _tagsController = TextEditingController(
      text: recipe?.tags.join(', ') ?? '',
    );
    _notesController = TextEditingController(text: recipe?.note ?? '');
    _caloriesController = TextEditingController(
      text: recipe?.nutrition.calories.toString() ?? '0',
    );
    _proteinController = TextEditingController(
      text: recipe?.nutrition.protein.toString() ?? '0',
    );
    _carbsController = TextEditingController(
      text: recipe?.nutrition.carbs.toString() ?? '0',
    );
    _fatController = TextEditingController(
      text: recipe?.nutrition.fat.toString() ?? '0',
    );
    _fiberController = TextEditingController(
      text: recipe?.nutrition.fiber.toString() ?? '0',
    );
    _sodiumController = TextEditingController(
      text: recipe?.nutrition.sodium.toString() ?? '0',
    );
    _sugarController = TextEditingController(
      text: recipe?.nutrition.sugar.toString() ?? '0',
    );
    _isPinned = recipe?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _versionController.dispose();
    _servingsController.dispose();
    _tagsController.dispose();
    _notesController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sodiumController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.recipe == null ? 'Add Recipe' : 'Edit Recipe',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'This editor writes directly to the local Drift database.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _FormSection(
                title: 'Details',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe title',
                      ),
                      validator: _requiredText,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _versionController,
                      decoration: const InputDecoration(
                        labelText: 'Version label',
                        hintText: 'Master, Single Serve, Deep Dish',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _servingsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Servings'),
                      validator: _positiveInteger,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags',
                        hintText: 'Meal plan, Favorite scale, High protein',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: _isPinned,
                      onChanged: (value) => setState(() => _isPinned = value),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Pin this recipe'),
                    ),
                    TextFormField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _FormSection(
                title: 'Nutrition Per Serving',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricField(
                      controller: _caloriesController,
                      label: 'Calories',
                    ),
                    _MetricField(
                      controller: _proteinController,
                      label: 'Protein',
                    ),
                    _MetricField(controller: _carbsController, label: 'Carbs'),
                    _MetricField(controller: _fatController, label: 'Fat'),
                    _MetricField(controller: _fiberController, label: 'Fiber'),
                    _MetricField(
                      controller: _sodiumController,
                      label: 'Sodium',
                    ),
                    _MetricField(controller: _sugarController, label: 'Sugar'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                      child: const Text('Save'),
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

  String? _positiveInteger(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter a number greater than 0';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      RecipeDraft(
        name: _titleController.text.trim(),
        versionLabel: _versionController.text.trim(),
        servings: int.parse(_servingsController.text),
        note: _notesController.text.trim(),
        tags: _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(growable: false),
        isPinned: _isPinned,
        nutrition: NutritionSnapshot(
          calories: int.tryParse(_caloriesController.text) ?? 0,
          protein: int.tryParse(_proteinController.text) ?? 0,
          carbs: int.tryParse(_carbsController.text) ?? 0,
          fat: int.tryParse(_fatController.text) ?? 0,
          fiber: int.tryParse(_fiberController.text) ?? 0,
          sodium: int.tryParse(_sodiumController.text) ?? 0,
          sugar: int.tryParse(_sugarController.text) ?? 0,
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

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

class _MetricField extends StatelessWidget {
  const _MetricField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
