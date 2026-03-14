import 'package:flutter/material.dart';

import '../../app/recipe_app_scope.dart';
import '../../core/measurement_units.dart';
import '../../core/mock_data.dart';
import '../../core/recipe_import.dart';
import '../../data/repositories/app_repositories.dart';
import '../shell/app_shell.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  RecipeSortOrder _sortOrder = RecipeSortOrder.caloriesLowToHigh;

  @override
  Widget build(BuildContext context) {
    final repository = RecipeAppScope.of(context).repositories.recipes;

    return ShellScaffold(
      title: 'Recipes',
      subtitle:
          'Save full recipes, create variations, scale them for real cooking, and keep nutrition organized per serving.',
      trailing: _RecipeActions(
        sortOrder: _sortOrder,
        onAddPressed: () => _openEditor(context, repository),
        onImportSelected: (mode) => _openImport(context, repository, mode),
        onSortSelected: (sortOrder) {
          setState(() {
            _sortOrder = sortOrder;
          });
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Pinned and Recent',
            caption:
                'Open a recipe to scale ingredients, review directions, or duplicate it into a variation. Sorted ${_sortOrder.label.toLowerCase()}.',
          ),
          StreamBuilder<List<RecipeSummary>>(
            stream: repository.watchRecipes(sortOrder: _sortOrder),
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
                              onTap: () => _openRecipeDetail(
                                context,
                                repository,
                                recipe,
                              ),
                              onEdit: () => _openEditor(
                                context,
                                repository,
                                recipe: recipe,
                              ),
                              onDuplicate: () =>
                                  _duplicateRecipe(context, repository, recipe),
                              onDelete: () =>
                                  _deleteRecipe(context, repository, recipe),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openRecipeDetail(
    BuildContext context,
    RecipesRepository repository,
    RecipeSummary recipe,
  ) async {
    final draft = await repository.getRecipeDraft(recipe.id);
    if (!context.mounted) {
      return;
    }

    final action = await showModalBottomSheet<_RecipeDetailAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => RecipeDetailSheet(summary: recipe, draft: draft),
    );

    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case _RecipeDetailAction.edit:
        await _openEditor(
          context,
          repository,
          recipe: recipe,
          initialDraft: draft,
        );
      case _RecipeDetailAction.duplicate:
        await _openEditor(
          context,
          repository,
          initialDraft: _duplicateDraft(draft),
          saveAsNew: true,
        );
    }
  }

  Future<void> _openEditor(
    BuildContext context,
    RecipesRepository repository, {
    RecipeSummary? recipe,
    RecipeDraft? initialDraft,
    bool saveAsNew = false,
  }) async {
    final draft =
        initialDraft ??
        (recipe == null ? null : await repository.getRecipeDraft(recipe.id));
    if (!context.mounted) {
      return;
    }

    final result = await showModalBottomSheet<RecipeDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => RecipeEditorSheet(
        initialDraft: draft,
        existingRecipeName: saveAsNew ? null : recipe?.name,
        existingRecipeId: saveAsNew ? null : recipe?.id,
      ),
    );

    if (result == null || !context.mounted) {
      return;
    }

    await repository.saveRecipe(
      result,
      existingId: saveAsNew ? null : recipe?.id,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(switch ((recipe != null, saveAsNew)) {
            (false, _) => 'Recipe added locally.',
            (true, true) => 'Recipe variation added locally.',
            (true, false) => 'Recipe updated locally.',
          }),
        ),
      );
    }
  }

  Future<void> _duplicateRecipe(
    BuildContext context,
    RecipesRepository repository,
    RecipeSummary recipe,
  ) async {
    final draft = await repository.getRecipeDraft(recipe.id);
    if (!context.mounted) {
      return;
    }

    await _openEditor(
      context,
      repository,
      initialDraft: _duplicateDraft(draft),
      saveAsNew: true,
    );
  }

  Future<void> _openImport(
    BuildContext context,
    RecipesRepository repository,
    RecipeImportMode mode,
  ) async {
    final draft = await showModalBottomSheet<RecipeDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _RecipeImportSheet(mode: mode),
    );

    if (draft == null || !context.mounted) {
      return;
    }

    await _openEditor(
      context,
      repository,
      initialDraft: draft,
      saveAsNew: true,
    );
  }

  RecipeDraft _duplicateDraft(RecipeDraft draft) {
    final versionLabel = draft.versionLabel.trim();
    final duplicateLabel = versionLabel.isEmpty
        ? 'Variation Copy'
        : '$versionLabel Copy';

    return draft.copyWith(
      versionLabel: duplicateLabel,
      tags: [...draft.tags, 'Variation']
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList(growable: false),
    );
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
  const _RecipeActions({
    required this.sortOrder,
    required this.onAddPressed,
    required this.onImportSelected,
    required this.onSortSelected,
  });

  final RecipeSortOrder sortOrder;
  final VoidCallback onAddPressed;
  final ValueChanged<RecipeImportMode> onImportSelected;
  final ValueChanged<RecipeSortOrder> onSortSelected;

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
        PopupMenuButton<RecipeSortOrder>(
          initialValue: sortOrder,
          onSelected: onSortSelected,
          itemBuilder: (context) => RecipeSortOrder.values
              .map(
                (value) => PopupMenuItem<RecipeSortOrder>(
                  value: value,
                  child: Text(value.label),
                ),
              )
              .toList(growable: false),
          child: Chip(
            avatar: const Icon(Icons.sort, size: 18),
            label: Text('Sort: ${sortOrder.shortLabel}'),
          ),
        ),
        PopupMenuButton<RecipeImportMode>(
          onSelected: onImportSelected,
          itemBuilder: (context) => RecipeImportMode.values
              .map(
                (mode) => PopupMenuItem<RecipeImportMode>(
                  value: mode,
                  child: Text(mode.actionLabel),
                ),
              )
              .toList(growable: false),
          child: const Chip(
            avatar: Icon(Icons.file_download_outlined, size: 18),
            label: Text('Import recipe'),
          ),
        ),
      ],
    );
  }
}

class _RecipeImportSheet extends StatefulWidget {
  const _RecipeImportSheet({required this.mode});

  final RecipeImportMode mode;

  @override
  State<_RecipeImportSheet> createState() => _RecipeImportSheetState();
}

class _RecipeImportSheetState extends State<_RecipeImportSheet> {
  late final TextEditingController _sourceController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController();
    _urlController = TextEditingController();
    _sourceController.addListener(_handleChanged);
    _urlController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _sourceController.removeListener(_handleChanged);
    _urlController.removeListener(_handleChanged);
    _sourceController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final theme = Theme.of(context);
    final result = RecipeImportParser.parse(
      mode: widget.mode,
      rawText: _sourceController.text,
      sourceUrl: _urlController.text,
    );
    final hasInput =
        _sourceController.text.trim().isNotEmpty ||
        _urlController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: SingleChildScrollView(
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
                        widget.mode.sheetTitle,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.mode.sheetSubtitle,
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
            _FormSection(
              title: 'Source',
              child: Column(
                children: [
                  if (widget.mode == RecipeImportMode.urlPaste) ...[
                    TextFormField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Recipe URL',
                        hintText: 'https://example.com/recipe-name',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _sourceController,
                    minLines: widget.mode == RecipeImportMode.urlPaste ? 6 : 12,
                    maxLines: widget.mode == RecipeImportMode.urlPaste
                        ? 10
                        : 18,
                    decoration: InputDecoration(
                      labelText: widget.mode.sourceLabel,
                      hintText: widget.mode.sourceHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _FormSection(
              title: 'Parsed Draft',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.draft.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '${result.draft.servings} servings • ${result.draft.ingredients.length} ingredients • ${result.draft.directions.length} directions',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  _NutritionPreviewGrid(nutrition: result.draft.nutrition),
                  if (result.draft.note.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(result.draft.note, style: theme.textTheme.bodyMedium),
                  ],
                  if (result.warnings.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    ...result.warnings.map(
                      (warning) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          warning,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFB34F3F),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                    onPressed: hasInput ? () => _submit(result.draft) : null,
                    child: const Text('Review in editor'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit(RecipeDraft draft) {
    Navigator.of(context).pop(draft);
  }

  void _handleChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final RecipeSummary recipe;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                        case _RecipeMenuAction.duplicate:
                          onDuplicate();
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
                        value: _RecipeMenuAction.duplicate,
                        child: Text('Duplicate variation'),
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
              const SizedBox(height: 8),
              Text(
                '${recipe.ingredientCount} ingredients • ${recipe.directionCount} directions',
                style: theme.textTheme.bodyMedium,
              ),
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
      ),
    );
  }
}

enum _RecipeMenuAction { edit, duplicate, delete }

enum _RecipeDetailAction { edit, duplicate }

class RecipeDetailSheet extends StatefulWidget {
  const RecipeDetailSheet({
    super.key,
    required this.summary,
    required this.draft,
  });

  final RecipeSummary summary;
  final RecipeDraft draft;

  @override
  State<RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<RecipeDetailSheet> {
  double _scaleFactor = 1;

  @override
  Widget build(BuildContext context) {
    final repository = RecipeAppScope.of(context).repositories.recipes;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final theme = Theme.of(context);
    final scaledServings = widget.summary.servings * _scaleFactor;
    final batchNutrition = _scaledBatchNutrition();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: SingleChildScrollView(
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
                        widget.summary.name,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.summary.versionLabel,
                        style: theme.textTheme.titleMedium,
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
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.summary.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(_RecipeDetailAction.duplicate),
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Duplicate variation'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pop(_RecipeDetailAction.edit),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit recipe'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FormSection(
              title: 'Scale',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [0.5, 1.0, 2.0, 3.0]
                        .map((factor) => _ScaleChip(factor: factor))
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => _adjustScale(-0.25),
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_RecipeScaling.formatDecimal(_scaleFactor)}x batch • ${_RecipeScaling.formatDecimal(scaledServings)} servings',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => _adjustScale(0.25),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Per-serving nutrition includes linked pantry items and nested recipes. Batch totals scale automatically.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _FormSection(
              title: 'Nutrition',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Per serving', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _NutritionGrid(
                    nutrition: widget.summary.nutrition,
                    servings: widget.summary.servings,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Scaled batch total',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _BatchNutritionGrid(
                    nutrition: batchNutrition,
                    servingsLabel:
                        '${_RecipeScaling.formatDecimal(scaledServings)} servings',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _FormSection(
              title: 'Ingredients',
              child: StreamBuilder<List<ResolvedRecipeIngredient>>(
                stream: repository.watchResolvedIngredients(widget.summary.id),
                builder: (context, snapshot) {
                  final ingredients =
                      snapshot.data ?? _fallbackResolvedIngredients();

                  return Column(
                    children: [
                      for (var index = 0; index < ingredients.length; index++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DetailListCard(
                            indexLabel: '${index + 1}',
                            title: _RecipeScaling.formatIngredient(
                              ingredients[index].draft,
                              _scaleFactor,
                            ),
                            subtitle: _ingredientDetailSubtitle(
                              ingredients[index],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _FormSection(
              title: 'Directions',
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < widget.draft.directions.length;
                    index++
                  )
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DetailListCard(
                        indexLabel: '${index + 1}',
                        title: widget.draft.directions[index],
                      ),
                    ),
                ],
              ),
            ),
            if (widget.draft.note.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _FormSection(
                title: 'Notes',
                child: Text(
                  widget.draft.note,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  NutritionSnapshot _scaledBatchNutrition() {
    final totalMultiplier = widget.summary.servings * _scaleFactor;
    final base = widget.summary.nutrition;

    int scale(int value) => (value * totalMultiplier).round();

    return NutritionSnapshot(
      calories: scale(base.calories),
      protein: scale(base.protein),
      carbs: scale(base.carbs),
      fat: scale(base.fat),
      fiber: scale(base.fiber),
      sodium: scale(base.sodium),
      sugar: scale(base.sugar),
    );
  }

  void _adjustScale(double delta) {
    _setScale(_scaleFactor + delta);
  }

  void _setScale(double next) {
    setState(() {
      _scaleFactor = next.clamp(0.25, 8.0);
    });
  }

  List<ResolvedRecipeIngredient> _fallbackResolvedIngredients() {
    return widget.draft.ingredients
        .map(
          (ingredient) => ResolvedRecipeIngredient(
            draft: ingredient,
            linkTitle: null,
            linkSubtitle: '',
            batchNutrition: NutritionSnapshot.zero,
          ),
        )
        .toList(growable: false);
  }

  String _ingredientDetailSubtitle(ResolvedRecipeIngredient ingredient) {
    final scaledNutrition = ingredient.batchNutrition.scale(_scaleFactor);
    final lines = <String>[
      if (ingredient.draft.preparation.trim().isNotEmpty)
        ingredient.draft.preparation.trim(),
      if (ingredient.linkTitle != null)
        'Linked to ${ingredient.linkTitle} (${ingredient.linkSubtitle})',
      if (!scaledNutrition.isZero)
        '${scaledNutrition.calories} cal • ${scaledNutrition.protein}g protein • ${scaledNutrition.carbs}g carbs',
    ];

    return lines.join('\n');
  }
}

class _ScaleChip extends StatelessWidget {
  const _ScaleChip({required this.factor});

  final double factor;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_RecipeDetailSheetState>();
    final isSelected = state?._scaleFactor == factor;

    return ChoiceChip(
      label: Text('${_RecipeScaling.formatDecimal(factor)}x'),
      selected: isSelected,
      onSelected: (_) => state?._setScale(factor),
    );
  }
}

class _DetailListCard extends StatelessWidget {
  const _DetailListCard({
    required this.indexLabel,
    required this.title,
    this.subtitle = '',
  });

  final String indexLabel;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFD87B42),
              foregroundColor: Colors.white,
              child: Text(indexLabel),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          .map((entry) => _MetricCard(label: entry.$1, value: entry.$2))
          .toList(growable: false),
    );
  }
}

class _BatchNutritionGrid extends StatelessWidget {
  const _BatchNutritionGrid({
    required this.nutrition,
    required this.servingsLabel,
  });

  final NutritionSnapshot nutrition;
  final String servingsLabel;

  @override
  Widget build(BuildContext context) {
    final values = [
      ('Calories', nutrition.calories.toString()),
      ('Protein', '${nutrition.protein}g'),
      ('Carbs', '${nutrition.carbs}g'),
      ('Fat', '${nutrition.fat}g'),
      ('Fiber', '${nutrition.fiber}g'),
      ('Yield', servingsLabel),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: values
          .map((entry) => _MetricCard(label: entry.$1, value: entry.$2))
          .toList(growable: false),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _NutritionPreviewGrid extends StatelessWidget {
  const _NutritionPreviewGrid({required this.nutrition});

  final NutritionSnapshot nutrition;

  @override
  Widget build(BuildContext context) {
    final values = [
      ('Calories', nutrition.calories.toString()),
      ('Protein', '${nutrition.protein}g'),
      ('Carbs', '${nutrition.carbs}g'),
      ('Fat', '${nutrition.fat}g'),
      ('Fiber', '${nutrition.fiber}g'),
      ('Sodium', '${nutrition.sodium}mg'),
      ('Sugar', '${nutrition.sugar}g'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: values
          .map((entry) => _MetricCard(label: entry.$1, value: entry.$2))
          .toList(growable: false),
    );
  }
}

class RecipeEditorSheet extends StatefulWidget {
  const RecipeEditorSheet({
    super.key,
    this.initialDraft,
    this.existingRecipeName,
    this.existingRecipeId,
  });

  final RecipeDraft? initialDraft;
  final String? existingRecipeName;
  final String? existingRecipeId;

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
  late final List<_IngredientControllers> _ingredients;
  late final List<TextEditingController> _directions;
  late final List<TextEditingController> _previewControllers;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    _titleController = TextEditingController(text: draft?.name ?? '');
    _versionController = TextEditingController(text: draft?.versionLabel ?? '');
    _servingsController = TextEditingController(
      text: draft?.servings.toString() ?? '1',
    );
    _tagsController = TextEditingController(text: draft?.tags.join(', ') ?? '');
    _notesController = TextEditingController(text: draft?.note ?? '');
    _caloriesController = TextEditingController(
      text: draft?.nutrition.calories.toString() ?? '0',
    );
    _proteinController = TextEditingController(
      text: draft?.nutrition.protein.toString() ?? '0',
    );
    _carbsController = TextEditingController(
      text: draft?.nutrition.carbs.toString() ?? '0',
    );
    _fatController = TextEditingController(
      text: draft?.nutrition.fat.toString() ?? '0',
    );
    _fiberController = TextEditingController(
      text: draft?.nutrition.fiber.toString() ?? '0',
    );
    _sodiumController = TextEditingController(
      text: draft?.nutrition.sodium.toString() ?? '0',
    );
    _sugarController = TextEditingController(
      text: draft?.nutrition.sugar.toString() ?? '0',
    );
    _isPinned = draft?.isPinned ?? false;
    _ingredients = (draft?.ingredients ?? const <RecipeIngredientDraft>[])
        .map(_IngredientControllers.fromDraft)
        .toList(growable: true);
    _directions = (draft?.directions ?? const <String>[])
        .map((direction) => TextEditingController(text: direction))
        .toList(growable: true);
    _previewControllers = [
      _titleController,
      _versionController,
      _servingsController,
      _tagsController,
      _notesController,
      _caloriesController,
      _proteinController,
      _carbsController,
      _fatController,
      _fiberController,
      _sodiumController,
      _sugarController,
    ];
    for (final controller in _previewControllers) {
      controller.addListener(_handleDraftChanged);
    }
    for (final ingredient in _ingredients) {
      ingredient.addListener(_handleDraftChanged);
    }

    if (_ingredients.isEmpty) {
      _ingredients.add(_IngredientControllers.empty());
      _ingredients.last.addListener(_handleDraftChanged);
    }
    if (_directions.isEmpty) {
      _directions.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final controller in _previewControllers) {
      controller.removeListener(_handleDraftChanged);
    }
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
    for (final ingredient in _ingredients) {
      ingredient.dispose();
    }
    for (final direction in _directions) {
      direction.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = RecipeAppScope.of(context).repositories.recipes;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final theme = Theme.of(context);

    return StreamBuilder<List<IngredientLinkTarget>>(
      stream: repository.watchIngredientLinkTargets(
        excludingRecipeId: widget.existingRecipeId,
      ),
      builder: (context, snapshot) {
        final linkTargets = snapshot.data ?? const <IngredientLinkTarget>[];
        final servings = _parsedServings;
        final linkedNutrition = _linkedNutrition(linkTargets, servings);
        final manualNutrition = _manualNutrition;
        final estimatedNutrition = manualNutrition + linkedNutrition;
        final previewWarnings = _linkedPreviewWarnings(linkTargets);

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
                          widget.initialDraft == null
                              ? 'Add Recipe'
                              : 'Edit Recipe',
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
                    widget.existingRecipeName == null
                        ? 'Create a full recipe entry with ingredients, directions, nutrition, and variation labels.'
                        : 'Updating ${widget.existingRecipeName} in the local Drift database.',
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
                          decoration: const InputDecoration(
                            labelText: 'Servings',
                          ),
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
                          onChanged: (value) =>
                              setState(() => _isPinned = value),
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
                    title: 'Ingredients',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Link rows to pantry items or other recipes so their nutrition rolls up automatically. Qty must be numeric, and linked units can use common U.S./metric measures when the target has a compatible reference or override.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        for (
                          var index = 0;
                          index < _ingredients.length;
                          index++
                        )
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _IngredientEditorRow(
                              index: index,
                              controllers: _ingredients[index],
                              linkTargets: linkTargets,
                              canRemove: _ingredients.length > 1,
                              canMoveUp: index > 0,
                              canMoveDown: index < _ingredients.length - 1,
                              onRemove: () => _removeIngredient(index),
                              onMoveUp: () => _moveIngredient(index, index - 1),
                              onMoveDown: () =>
                                  _moveIngredient(index, index + 1),
                              onLinkTypeChanged: (value) =>
                                  _setIngredientLinkType(
                                    index,
                                    value,
                                    linkTargets,
                                  ),
                              onLinkTargetChanged: (value) =>
                                  _setIngredientLinkTarget(
                                    index,
                                    value,
                                    linkTargets,
                                  ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addIngredient,
                            icon: const Icon(Icons.add),
                            label: const Text('Add ingredient'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormSection(
                    title: 'Directions',
                    child: Column(
                      children: [
                        for (var index = 0; index < _directions.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _DirectionEditorRow(
                              index: index,
                              controller: _directions[index],
                              canRemove: _directions.length > 1,
                              canMoveUp: index > 0,
                              canMoveDown: index < _directions.length - 1,
                              onRemove: () => _removeDirection(index),
                              onMoveUp: () => _moveDirection(index, index - 1),
                              onMoveDown: () =>
                                  _moveDirection(index, index + 1),
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addDirection,
                            icon: const Icon(Icons.add),
                            label: const Text('Add direction'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormSection(
                    title: 'Estimated Nutrition',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Linked rows are calculated live from pantry and nested recipe references before save.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Linked contribution',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _NutritionPreviewGrid(nutrition: linkedNutrition),
                        const SizedBox(height: 16),
                        Text(
                          'Manual entry',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _NutritionPreviewGrid(nutrition: manualNutrition),
                        const SizedBox(height: 16),
                        Text(
                          'Estimated total per serving',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _NutritionPreviewGrid(nutrition: estimatedNutrition),
                        const SizedBox(height: 10),
                        Text(
                          'Based on $servings serving${servings == 1 ? '' : 's'}. Linked rows accept matching count units plus common mass and volume conversions when the target exposes compatible reference data.',
                          style: theme.textTheme.bodySmall,
                        ),
                        for (final warning in previewWarnings) ...[
                          const SizedBox(height: 6),
                          Text(
                            warning,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FormSection(
                    title: 'Manual Nutrition Per Serving',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use these fields only for anything not covered by linked ingredients. Linked pantry items and nested recipes are added automatically.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
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
                            _MetricField(
                              controller: _carbsController,
                              label: 'Carbs',
                            ),
                            _MetricField(
                              controller: _fatController,
                              label: 'Fat',
                            ),
                            _MetricField(
                              controller: _fiberController,
                              label: 'Fiber',
                            ),
                            _MetricField(
                              controller: _sodiumController,
                              label: 'Sodium',
                            ),
                            _MetricField(
                              controller: _sugarController,
                              label: 'Sugar',
                            ),
                          ],
                        ),
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
      },
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

  void _addIngredient() {
    setState(() {
      final ingredient = _IngredientControllers.empty();
      ingredient.addListener(_handleDraftChanged);
      _ingredients.add(ingredient);
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      final removed = _ingredients.removeAt(index);
      removed.removeListener(_handleDraftChanged);
      removed.dispose();
    });
  }

  void _moveIngredient(int from, int to) {
    if (to < 0 || to >= _ingredients.length) {
      return;
    }

    setState(() {
      final item = _ingredients.removeAt(from);
      _ingredients.insert(to, item);
    });
  }

  void _setIngredientLinkType(
    int index,
    RecipeIngredientType value,
    List<IngredientLinkTarget> linkTargets,
  ) {
    setState(() {
      final ingredient = _ingredients[index];
      ingredient.linkType = value;
      ingredient.linkedPantryItemId = null;
      ingredient.linkedRecipeId = null;

      if (value == RecipeIngredientType.freeform) {
        return;
      }

      final firstMatch = linkTargets.cast<IngredientLinkTarget?>().firstWhere(
        (target) => target?.type == value,
        orElse: () => null,
      );
      if (firstMatch != null) {
        _applyIngredientTarget(ingredient, firstMatch);
      }
    });
  }

  void _setIngredientLinkTarget(
    int index,
    String? targetId,
    List<IngredientLinkTarget> linkTargets,
  ) {
    if (targetId == null) {
      return;
    }

    final target = linkTargets.cast<IngredientLinkTarget?>().firstWhere(
      (item) => item?.id == targetId,
      orElse: () => null,
    );
    if (target == null) {
      return;
    }

    setState(() {
      _applyIngredientTarget(_ingredients[index], target);
    });
  }

  void _applyIngredientTarget(
    _IngredientControllers ingredient,
    IngredientLinkTarget target,
  ) {
    ingredient.linkType = target.type;
    ingredient.linkedPantryItemId =
        target.type == RecipeIngredientType.pantryItem ? target.id : null;
    ingredient.linkedRecipeId =
        target.type == RecipeIngredientType.recipeReference ? target.id : null;
    ingredient.item.text = target.title;
    ingredient.unit.text = target.referenceUnit;
  }

  void _addDirection() {
    setState(() {
      _directions.add(TextEditingController());
    });
  }

  void _removeDirection(int index) {
    setState(() {
      final removed = _directions.removeAt(index);
      removed.dispose();
    });
  }

  void _moveDirection(int from, int to) {
    if (to < 0 || to >= _directions.length) {
      return;
    }

    setState(() {
      final item = _directions.removeAt(from);
      _directions.insert(to, item);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final linkedIngredientIndex = _ingredients.indexWhere(
      (ingredient) =>
          ingredient.linkType != RecipeIngredientType.freeform &&
          (ingredient.linkedTargetId == null ||
              _RecipeScaling.tryParseQuantity(ingredient.quantity.text) ==
                  null),
    );
    if (linkedIngredientIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ingredient ${linkedIngredientIndex + 1} needs a linked target and numeric quantity.',
          ),
        ),
      );
      return;
    }

    final ingredients = _ingredients
        .map((ingredient) => ingredient.toDraft())
        .where((ingredient) => ingredient.item.trim().isNotEmpty)
        .toList(growable: false);
    final directions = _directions
        .map((controller) => controller.text.trim())
        .where((instruction) => instruction.isNotEmpty)
        .toList(growable: false);

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
        ingredients: ingredients,
        directions: directions,
      ),
    );
  }

  void _handleDraftChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  int get _parsedServings {
    final servings = int.tryParse(_servingsController.text);
    if (servings == null || servings <= 0) {
      return 1;
    }
    return servings;
  }

  NutritionSnapshot get _manualNutrition {
    int valueOf(TextEditingController controller) =>
        int.tryParse(controller.text.trim()) ?? 0;

    return NutritionSnapshot(
      calories: valueOf(_caloriesController),
      protein: valueOf(_proteinController),
      carbs: valueOf(_carbsController),
      fat: valueOf(_fatController),
      fiber: valueOf(_fiberController),
      sodium: valueOf(_sodiumController),
      sugar: valueOf(_sugarController),
    );
  }

  NutritionSnapshot _linkedNutrition(
    List<IngredientLinkTarget> linkTargets,
    int servings,
  ) {
    var batchNutrition = NutritionSnapshot.zero;

    for (final ingredient in _ingredients) {
      final targetId = ingredient.linkedTargetId;
      if (ingredient.linkType == RecipeIngredientType.freeform ||
          targetId == null) {
        continue;
      }

      final target = linkTargets.cast<IngredientLinkTarget?>().firstWhere(
        (item) => item?.id == targetId,
        orElse: () => null,
      );
      if (target == null) {
        continue;
      }

      final resolution = _resolveLinkedQuantity(ingredient, target);
      if (!resolution.isResolved) {
        continue;
      }

      batchNutrition += target.nutrition.scale(resolution.referenceUnits!);
    }

    return batchNutrition.divide(servings);
  }

  List<String> _linkedPreviewWarnings(List<IngredientLinkTarget> linkTargets) {
    final warnings = <String>[];

    for (var index = 0; index < _ingredients.length; index++) {
      final ingredient = _ingredients[index];
      if (ingredient.linkType == RecipeIngredientType.freeform) {
        continue;
      }

      final target = linkTargets.cast<IngredientLinkTarget?>().firstWhere(
        (item) => item?.id == ingredient.linkedTargetId,
        orElse: () => null,
      );

      if (target == null) {
        warnings.add('Ingredient ${index + 1}: linked target is missing.');
        continue;
      }

      final resolution = _resolveLinkedQuantity(ingredient, target);
      if (resolution.issue == LinkedQuantityIssue.invalidQuantity) {
        warnings.add('Ingredient ${index + 1}: linked qty must be numeric.');
        continue;
      }
      if (resolution.issue == LinkedQuantityIssue.incompatibleUnit) {
        final unitLabel = ingredient.unit.text.trim().isEmpty
            ? 'blank'
            : ingredient.unit.text.trim();
        warnings.add(
          'Ingredient ${index + 1}: unit "$unitLabel" does not convert to ${MeasurementUnits.describeReferenceUnit(referenceUnit: target.referenceUnit, referenceUnitQuantity: target.referenceUnitQuantity, referenceUnitEquivalentQuantity: target.referenceUnitEquivalentQuantity, referenceUnitEquivalentUnit: target.referenceUnitEquivalentUnit, referenceUnitWeightGrams: target.referenceUnitWeightGrams)}.',
        );
      }
    }

    return warnings;
  }

  LinkedQuantityResolution _resolveLinkedQuantity(
    _IngredientControllers ingredient,
    IngredientLinkTarget target,
  ) {
    return MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: MeasurementUnits.parseQuantity(ingredient.quantity.text),
      ingredientUnit: ingredient.unit.text,
      referenceUnit: target.referenceUnit,
      referenceUnitQuantity: target.referenceUnitQuantity,
      referenceUnitEquivalentQuantity: target.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: target.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: target.referenceUnitWeightGrams,
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

class _IngredientEditorRow extends StatelessWidget {
  const _IngredientEditorRow({
    required this.index,
    required this.controllers,
    required this.linkTargets,
    required this.canRemove,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onLinkTypeChanged,
    required this.onLinkTargetChanged,
  });

  final int index;
  final _IngredientControllers controllers;
  final List<IngredientLinkTarget> linkTargets;
  final bool canRemove;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<RecipeIngredientType> onLinkTypeChanged;
  final ValueChanged<String?> onLinkTargetChanged;

  @override
  Widget build(BuildContext context) {
    final pantryTargets = linkTargets
        .where((target) => target.type == RecipeIngredientType.pantryItem)
        .toList(growable: false);
    final recipeTargets = linkTargets
        .where((target) => target.type == RecipeIngredientType.recipeReference)
        .toList(growable: false);
    final selectedTargetId = controllers.linkedTargetId;
    final selectedTarget = linkTargets.cast<IngredientLinkTarget?>().firstWhere(
      (target) => target?.id == selectedTargetId,
      orElse: () => null,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Ingredient ${index + 1}')),
                IconButton(
                  onPressed: canMoveUp ? onMoveUp : null,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  onPressed: canMoveDown ? onMoveDown : null,
                  icon: const Icon(Icons.arrow_downward),
                ),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: controllers.quantity,
                    decoration: const InputDecoration(labelText: 'Qty'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: controllers.unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: controllers.item,
                    decoration: const InputDecoration(labelText: 'Ingredient'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controllers.preparation,
              decoration: const InputDecoration(
                labelText: 'Preparation note',
                hintText: 'Diced, softened, drained, etc.',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RecipeIngredientType>(
              key: ValueKey(
                'ingredient-link-type-$index-${controllers.linkType.name}',
              ),
              initialValue: controllers.linkType,
              decoration: const InputDecoration(labelText: 'Nutrition source'),
              items: RecipeIngredientType.values
                  .map(
                    (type) => DropdownMenuItem<RecipeIngredientType>(
                      value: type,
                      child: Text(type.label),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  onLinkTypeChanged(value);
                }
              },
            ),
            if (controllers.linkType != RecipeIngredientType.freeform) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(
                  'ingredient-link-target-$index-$selectedTargetId',
                ),
                initialValue: selectedTarget?.id,
                decoration: InputDecoration(
                  labelText: switch (controllers.linkType) {
                    RecipeIngredientType.pantryItem => 'Linked pantry item',
                    RecipeIngredientType.recipeReference =>
                      'Linked nested recipe',
                    RecipeIngredientType.freeform => 'Linked target',
                  },
                ),
                items:
                    (controllers.linkType == RecipeIngredientType.pantryItem
                            ? pantryTargets
                            : recipeTargets)
                        .map(
                          (target) => DropdownMenuItem<String>(
                            value: target.id,
                            child: Text(target.title),
                          ),
                        )
                        .toList(growable: false),
                onChanged: onLinkTargetChanged,
              ),
              if (selectedTarget != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedTarget.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DirectionEditorRow extends StatelessWidget {
  const _DirectionEditorRow({
    required this.index,
    required this.controller,
    required this.canRemove,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final int index;
  final TextEditingController controller;
  final bool canRemove;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Step ${index + 1}')),
                IconButton(
                  onPressed: canMoveUp ? onMoveUp : null,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  onPressed: canMoveDown ? onMoveDown : null,
                  icon: const Icon(Icons.arrow_downward),
                ),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            TextFormField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Instruction'),
            ),
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

class _IngredientControllers {
  _IngredientControllers({
    required this.quantity,
    required this.unit,
    required this.item,
    required this.preparation,
    this.linkType = RecipeIngredientType.freeform,
    this.linkedPantryItemId,
    this.linkedRecipeId,
  });

  factory _IngredientControllers.empty() {
    return _IngredientControllers(
      quantity: TextEditingController(),
      unit: TextEditingController(),
      item: TextEditingController(),
      preparation: TextEditingController(),
    );
  }

  factory _IngredientControllers.fromDraft(RecipeIngredientDraft draft) {
    return _IngredientControllers(
      quantity: TextEditingController(text: draft.quantity),
      unit: TextEditingController(text: draft.unit),
      item: TextEditingController(text: draft.item),
      preparation: TextEditingController(text: draft.preparation),
      linkType: draft.linkType,
      linkedPantryItemId: draft.linkedPantryItemId,
      linkedRecipeId: draft.linkedRecipeId,
    );
  }

  final TextEditingController quantity;
  final TextEditingController unit;
  final TextEditingController item;
  final TextEditingController preparation;
  RecipeIngredientType linkType;
  String? linkedPantryItemId;
  String? linkedRecipeId;

  String? get linkedTargetId => switch (linkType) {
    RecipeIngredientType.freeform => null,
    RecipeIngredientType.pantryItem => linkedPantryItemId,
    RecipeIngredientType.recipeReference => linkedRecipeId,
  };

  RecipeIngredientDraft toDraft() {
    return RecipeIngredientDraft(
      quantity: quantity.text.trim(),
      unit: unit.text.trim(),
      item: item.text.trim(),
      preparation: preparation.text.trim(),
      linkType: linkType,
      linkedPantryItemId: linkedPantryItemId,
      linkedRecipeId: linkedRecipeId,
    );
  }

  void addListener(VoidCallback listener) {
    quantity.addListener(listener);
    unit.addListener(listener);
    item.addListener(listener);
    preparation.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    quantity.removeListener(listener);
    unit.removeListener(listener);
    item.removeListener(listener);
    preparation.removeListener(listener);
  }

  void dispose() {
    quantity.dispose();
    unit.dispose();
    item.dispose();
    preparation.dispose();
  }
}

extension on RecipeSortOrder {
  String get label => switch (this) {
    RecipeSortOrder.caloriesLowToHigh => 'Calories: Low to High',
    RecipeSortOrder.caloriesHighToLow => 'Calories: High to Low',
  };

  String get shortLabel => switch (this) {
    RecipeSortOrder.caloriesLowToHigh => 'Low to High',
    RecipeSortOrder.caloriesHighToLow => 'High to Low',
  };
}

extension on RecipeImportMode {
  String get actionLabel => switch (this) {
    RecipeImportMode.textPaste => 'Paste recipe text',
    RecipeImportMode.urlPaste => 'Paste recipe URL',
    RecipeImportMode.ocrPaste => 'Paste OCR text',
  };

  String get sheetTitle => switch (this) {
    RecipeImportMode.textPaste => 'Import From Text',
    RecipeImportMode.urlPaste => 'Import From URL',
    RecipeImportMode.ocrPaste => 'Import From OCR',
  };

  String get sheetSubtitle => switch (this) {
    RecipeImportMode.textPaste =>
      'Paste a recipe article, note, or copied ingredients and directions to draft a recipe locally.',
    RecipeImportMode.urlPaste =>
      'Paste the source URL and optionally the page text or excerpt for a stronger draft import.',
    RecipeImportMode.ocrPaste =>
      'Paste OCR output from a screenshot or scanned cookbook page, then review the parsed draft.',
  };

  String get sourceLabel => switch (this) {
    RecipeImportMode.textPaste => 'Recipe text',
    RecipeImportMode.urlPaste => 'Page text or excerpt',
    RecipeImportMode.ocrPaste => 'OCR text',
  };

  String get sourceHint => switch (this) {
    RecipeImportMode.textPaste =>
      'Title, servings, ingredients, directions, and nutrition if available.',
    RecipeImportMode.urlPaste =>
      'Optional but recommended: paste the visible recipe text so the draft can infer ingredients and directions.',
    RecipeImportMode.ocrPaste =>
      'Paste the recognized screenshot text here. Quantities and units can be cleaned up in the editor.',
  };
}

extension on RecipeIngredientType {
  String get label => switch (this) {
    RecipeIngredientType.freeform => 'Freeform only',
    RecipeIngredientType.pantryItem => 'Linked pantry item',
    RecipeIngredientType.recipeReference => 'Linked nested recipe',
  };
}

abstract final class _RecipeScaling {
  static String formatIngredient(
    RecipeIngredientDraft ingredient,
    double factor,
  ) {
    final scaledQuantity = formatQuantity(ingredient.quantity, factor);
    final parts = [
      if (scaledQuantity.isNotEmpty) scaledQuantity,
      if (ingredient.unit.trim().isNotEmpty) ingredient.unit.trim(),
      ingredient.item.trim(),
    ];

    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  static String formatQuantity(String rawQuantity, double factor) {
    final trimmed = rawQuantity.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final parsed = tryParseQuantity(trimmed);
    if (parsed == null) {
      return trimmed;
    }

    return formatDecimal(parsed * factor);
  }

  static double? tryParseQuantity(String rawQuantity) {
    return MeasurementUnits.parseQuantity(rawQuantity);
  }

  static String formatDecimal(double value) {
    return MeasurementUnits.formatDecimal(value);
  }
}
