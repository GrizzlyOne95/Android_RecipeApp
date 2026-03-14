import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/recipe_app_scope.dart';
import '../../core/measurement_units.dart';
import '../../core/mock_data.dart';
import '../../data/repositories/app_repositories.dart';
import '../shell/app_shell.dart';

Future<FoodLogEntryDraft?> showFoodLogEntryEditorSheet(
  BuildContext context,
  FoodLogRepository repository, {
  FoodLogMealSlot initialMealSlot = FoodLogMealSlot.breakfast,
}) {
  return showModalBottomSheet<FoodLogEntryDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _FoodLogEntryEditorSheet(
      repository: repository,
      initialMealSlot: initialMealSlot,
    ),
  );
}

class FoodLogPage extends StatefulWidget {
  const FoodLogPage({super.key});

  @override
  State<FoodLogPage> createState() => _FoodLogPageState();
}

class _FoodLogPageState extends State<FoodLogPage> {
  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, MMMM d').format(SeedData.todayDate);
    final repositories = RecipeAppScope.of(context).repositories;

    return ShellScaffold(
      title: 'Food Log',
      subtitle:
          'Track meals by day, reuse saved meals with adjustable ingredient quantities, and compare what you ate against calorie and macro goals.',
      trailing: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          Chip(label: Text(date)),
          OutlinedButton.icon(
            onPressed: () => _openEntryEditor(context, repositories.foodLog),
            icon: const Icon(Icons.post_add_outlined),
            label: const Text('Log entry'),
          ),
          FilledButton.icon(
            onPressed: () => _openMealEditor(
              context,
              repositories.foodLog,
              repositories.recipes,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Saved meal'),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Daily Targets',
            caption:
                'Calories, macros, fiber, sodium, and sugar are modeled now so the later persistence layer has a concrete target shape.',
          ),
          StreamBuilder<FoodLogSnapshot>(
            stream: repositories.foodLog.watchSnapshot(),
            builder: (context, snapshot) {
              final data =
                  snapshot.data ??
                  const FoodLogSnapshot(
                    goals: <DailyGoal>[],
                    savedMeals: <SavedMeal>[],
                    entries: <FoodLogEntry>[],
                  );

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 920;

                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _GoalPanel(goals: data.goals)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  _DailyEntriesPanel(
                                    entries: data.entries,
                                    onDelete: (entry) => _deleteEntry(
                                      context,
                                      repositories.foodLog,
                                      entry,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _SavedMealsPanel(
                                    meals: data.savedMeals,
                                    onEdit: (meal) => _openMealEditor(
                                      context,
                                      repositories.foodLog,
                                      repositories.recipes,
                                      meal: meal,
                                    ),
                                    onDelete: (meal) => _deleteMeal(
                                      context,
                                      repositories.foodLog,
                                      meal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _GoalPanel(goals: data.goals),
                            const SizedBox(height: 16),
                            _DailyEntriesPanel(
                              entries: data.entries,
                              onDelete: (entry) => _deleteEntry(
                                context,
                                repositories.foodLog,
                                entry,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SavedMealsPanel(
                              meals: data.savedMeals,
                              onEdit: (meal) => _openMealEditor(
                                context,
                                repositories.foodLog,
                                repositories.recipes,
                                meal: meal,
                              ),
                              onDelete: (meal) => _deleteMeal(
                                context,
                                repositories.foodLog,
                                meal,
                              ),
                            ),
                          ],
                        );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openEntryEditor(
    BuildContext context,
    FoodLogRepository repository,
  ) async {
    final result = await showFoodLogEntryEditorSheet(context, repository);

    if (result == null || !context.mounted) {
      return;
    }

    await repository.saveFoodLogEntry(result);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Food log entry added.')));
  }

  Future<void> _openMealEditor(
    BuildContext context,
    FoodLogRepository repository,
    RecipesRepository recipesRepository, {
    SavedMeal? meal,
  }) async {
    final draft = meal == null
        ? null
        : await repository.getSavedMealDraft(meal.id);
    if (!context.mounted) {
      return;
    }

    final result = await showModalBottomSheet<SavedMealDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _SavedMealEditorSheet(
        recipesRepository: recipesRepository,
        initialDraft: draft,
        existingMealName: meal?.name,
      ),
    );

    if (result == null || !context.mounted) {
      return;
    }

    await repository.saveSavedMeal(result, existingId: meal?.id);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          meal == null
              ? 'Saved meal added locally.'
              : 'Saved meal updated locally.',
        ),
      ),
    );
  }

  Future<void> _deleteMeal(
    BuildContext context,
    FoodLogRepository repository,
    SavedMeal meal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete saved meal?'),
        content: Text(
          'Remove "${meal.name}" from the local food log shortcuts?',
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

    await repository.deleteSavedMeal(meal.id);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${meal.name}" deleted.')));
  }

  Future<void> _deleteEntry(
    BuildContext context,
    FoodLogRepository repository,
    FoodLogEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete food log entry?'),
        content: Text('Remove "${entry.title}" from today\'s log?'),
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

    await repository.deleteFoodLogEntry(entry.id);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${entry.title}" removed.')));
  }
}

class _GoalPanel extends StatelessWidget {
  const _GoalPanel({required this.goals});

  final List<DailyGoal> goals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goal Progress', style: theme.textTheme.titleLarge),
            const SizedBox(height: 18),
            ...goals.map((goal) {
              final ratio = goal.target == 0
                  ? 0.0
                  : goal.consumed / goal.target;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.label,
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        Text(
                          '${goal.consumed}/${goal.target}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        value: ratio.clamp(0, 1.2),
                        backgroundColor: const Color(0xFFE7D9BF),
                        color: ratio > 1
                            ? const Color(0xFFB34F3F)
                            : const Color(0xFF4F6B44),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DailyEntriesPanel extends StatelessWidget {
  const _DailyEntriesPanel({required this.entries, required this.onDelete});

  final List<FoodLogEntry> entries;
  final ValueChanged<FoodLogEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s Entries', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Daily goal progress is recalculated from these logged meals and items.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            if (entries.isEmpty)
              Text(
                'No meals logged yet for today.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...FoodLogMealSlot.values.map(
                (slot) => _MealSlotSection(
                  slot: slot,
                  entries: entries
                      .where((entry) => entry.mealSlot == slot)
                      .toList(growable: false),
                  onDelete: onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MealSlotSection extends StatelessWidget {
  const _MealSlotSection({
    required this.slot,
    required this.entries,
    required this.onDelete,
  });

  final FoodLogMealSlot slot;
  final List<FoodLogEntry> entries;
  final ValueChanged<FoodLogEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(slot.label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LoggedEntryCard(
                entry: entry,
                onDelete: () => onDelete(entry),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoggedEntryCard extends StatelessWidget {
  const _LoggedEntryCard({required this.entry, required this.onDelete});

  final FoodLogEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantityLabel = [
      if (entry.quantity.trim().isNotEmpty) entry.quantity.trim(),
      if (entry.unit.trim().isNotEmpty) entry.unit.trim(),
    ].join(' ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '${entry.sourceType.label} • $quantityLabel',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${entry.nutrition.calories} cal • ${entry.nutrition.protein}g protein • ${entry.nutrition.carbs}g carbs',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _SavedMealsPanel extends StatelessWidget {
  const _SavedMealsPanel({
    required this.meals,
    required this.onEdit,
    required this.onDelete,
  });

  final List<SavedMeal> meals;
  final ValueChanged<SavedMeal> onEdit;
  final ValueChanged<SavedMeal> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved Meals', style: theme.textTheme.titleLarge),
            const SizedBox(height: 18),
            ...meals.map(
              (meal) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _SavedMealCard(
                  meal: meal,
                  onEdit: () => onEdit(meal),
                  onDelete: () => onDelete(meal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedMealCard extends StatelessWidget {
  const _SavedMealCard({
    required this.meal,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedMeal meal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(meal.name, style: theme.textTheme.titleMedium),
              ),
              PopupMenuButton<_SavedMealAction>(
                onSelected: (action) {
                  switch (action) {
                    case _SavedMealAction.edit:
                      onEdit();
                    case _SavedMealAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _SavedMealAction.edit,
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: _SavedMealAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${meal.nutrition.calories} cal • ${meal.nutrition.protein}g protein • ${meal.nutrition.carbs}g carbs',
            style: theme.textTheme.bodyLarge,
          ),
          if (!meal.manualNutrition.isZero) ...[
            const SizedBox(height: 6),
            Text(
              'Manual base: ${meal.manualNutrition.calories} cal',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (meal.components.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...meal.components.map(
              (component) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _SavedMealFormatting.formatComponent(component),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
          if (meal.adjustments.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...meal.adjustments.map(
              (adjustment) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(adjustment, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _SavedMealAction { edit, delete }

class _FoodLogEntryEditorSheet extends StatefulWidget {
  const _FoodLogEntryEditorSheet({
    required this.repository,
    required this.initialMealSlot,
  });

  final FoodLogRepository repository;
  final FoodLogMealSlot initialMealSlot;

  @override
  State<_FoodLogEntryEditorSheet> createState() =>
      _FoodLogEntryEditorSheetState();
}

class _FoodLogEntryEditorSheetState extends State<_FoodLogEntryEditorSheet> {
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late FoodLogMealSlot _selectedMealSlot;
  String? _selectedTargetId;

  @override
  void initState() {
    super.initState();
    _selectedMealSlot = widget.initialMealSlot;
    _quantityController = TextEditingController(text: '1');
    _unitController = TextEditingController();
    _quantityController.addListener(_handleDraftChanged);
    _unitController.addListener(_handleDraftChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_handleDraftChanged);
    _unitController.removeListener(_handleDraftChanged);
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final theme = Theme.of(context);

    return StreamBuilder<List<FoodLogEntryTarget>>(
      stream: widget.repository.watchEntryTargets(),
      builder: (context, snapshot) {
        final targets = snapshot.data ?? const <FoodLogEntryTarget>[];
        final selectedTarget = targets.cast<FoodLogEntryTarget?>().firstWhere(
          (target) => target?.id == _selectedTargetId,
          orElse: () => null,
        );
        final resolution = selectedTarget == null
            ? const LinkedQuantityResolution.invalidQuantity()
            : MeasurementUnits.resolveLinkedReferenceUnits(
                quantity: MeasurementUnits.parseQuantity(
                  _quantityController.text,
                ),
                ingredientUnit: _unitController.text,
                referenceUnit: selectedTarget.referenceUnit,
                referenceUnitQuantity: selectedTarget.referenceUnitQuantity,
                referenceUnitEquivalentQuantity:
                    selectedTarget.referenceUnitEquivalentQuantity,
                referenceUnitEquivalentUnit:
                    selectedTarget.referenceUnitEquivalentUnit,
                referenceUnitWeightGrams:
                    selectedTarget.referenceUnitWeightGrams,
              );
        final previewNutrition = selectedTarget != null && resolution.isResolved
            ? selectedTarget.nutrition.scale(resolution.referenceUnits!)
            : NutritionSnapshot.zero;

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
                            'Log today\'s food',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pick a saved meal, recipe, or pantry item and snapshot what you actually ate.',
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
                _EditorSection(
                  title: 'Entry',
                  child: Column(
                    children: [
                      DropdownButtonFormField<FoodLogMealSlot>(
                        initialValue: _selectedMealSlot,
                        decoration: const InputDecoration(
                          labelText: 'Meal slot',
                        ),
                        items: FoodLogMealSlot.values
                            .map(
                              (slot) => DropdownMenuItem(
                                value: slot,
                                child: Text(slot.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedMealSlot = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey('food-log-target-$_selectedTargetId'),
                        initialValue: _selectedTargetId,
                        decoration: const InputDecoration(
                          labelText: 'Food source',
                        ),
                        items: targets
                            .map(
                              (target) => DropdownMenuItem<String>(
                                value: target.id,
                                child: Text(
                                  '${target.title} (${target.sourceType.label})',
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) => _setTarget(value, targets),
                      ),
                      if (selectedTarget != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            selectedTarget.subtitle,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                              ),
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
                const SizedBox(height: 16),
                _EditorSection(
                  title: 'Nutrition Snapshot',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NutritionPreviewGrid(nutrition: previewNutrition),
                      if (_warningText(selectedTarget, resolution)
                          case final warning?)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            warning,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFB34F3F),
                            ),
                          ),
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
                        onPressed: () => _submit(targets),
                        child: const Text('Add entry'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setTarget(String? targetId, List<FoodLogEntryTarget> targets) {
    final target = targets.cast<FoodLogEntryTarget?>().firstWhere(
      (item) => item?.id == targetId,
      orElse: () => null,
    );

    setState(() {
      _selectedTargetId = targetId;
      if (target != null) {
        _unitController.text = target.referenceUnit;
      }
    });
  }

  String? _warningText(
    FoodLogEntryTarget? target,
    LinkedQuantityResolution resolution,
  ) {
    if (target == null) {
      return 'Choose a source to calculate nutrition.';
    }
    if (resolution.issue == LinkedQuantityIssue.invalidQuantity) {
      return 'Quantity must be a positive number.';
    }
    if (resolution.issue == LinkedQuantityIssue.incompatibleUnit) {
      final unitLabel = _unitController.text.trim().isEmpty
          ? 'blank'
          : _unitController.text.trim();
      return 'Unit "$unitLabel" does not convert to ${MeasurementUnits.describeReferenceUnit(referenceUnit: target.referenceUnit, referenceUnitQuantity: target.referenceUnitQuantity, referenceUnitEquivalentQuantity: target.referenceUnitEquivalentQuantity, referenceUnitEquivalentUnit: target.referenceUnitEquivalentUnit, referenceUnitWeightGrams: target.referenceUnitWeightGrams)}.';
    }
    return null;
  }

  void _submit(List<FoodLogEntryTarget> targets) {
    final target = targets.cast<FoodLogEntryTarget?>().firstWhere(
      (item) => item?.id == _selectedTargetId,
      orElse: () => null,
    );
    if (target == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Choose a source to log.')));
      return;
    }

    final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: MeasurementUnits.parseQuantity(_quantityController.text),
      ingredientUnit: _unitController.text,
      referenceUnit: target.referenceUnit,
      referenceUnitQuantity: target.referenceUnitQuantity,
      referenceUnitEquivalentQuantity: target.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: target.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: target.referenceUnitWeightGrams,
    );
    if (!resolution.isResolved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_warningText(target, resolution)!)),
      );
      return;
    }

    Navigator.of(context).pop(
      FoodLogEntryDraft(
        date: SeedData.todayDate,
        mealSlot: _selectedMealSlot,
        sourceType: target.sourceType,
        sourceId: target.id,
        title: target.title,
        quantity: _quantityController.text.trim(),
        unit: _unitController.text.trim(),
        nutrition: target.nutrition.scale(resolution.referenceUnits!),
      ),
    );
  }

  void _handleDraftChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}

class _SavedMealEditorSheet extends StatefulWidget {
  const _SavedMealEditorSheet({
    required this.recipesRepository,
    this.initialDraft,
    this.existingMealName,
  });

  final RecipesRepository recipesRepository;
  final SavedMealDraft? initialDraft;
  final String? existingMealName;

  @override
  State<_SavedMealEditorSheet> createState() => _SavedMealEditorSheetState();
}

class _SavedMealEditorSheetState extends State<_SavedMealEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _adjustmentsController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _fiberController;
  late final TextEditingController _sodiumController;
  late final TextEditingController _sugarController;
  late final List<_MealComponentControllers> _components;

  @override
  void initState() {
    super.initState();
    final draft =
        widget.initialDraft ??
        const SavedMealDraft(
          name: '',
          manualNutrition: NutritionSnapshot.zero,
          adjustments: [],
          components: [
            SavedMealComponentDraft(quantity: '', unit: '', item: ''),
          ],
        );
    _titleController = TextEditingController(text: draft.name);
    _adjustmentsController = TextEditingController(
      text: draft.adjustments.join('\n'),
    );
    _caloriesController = TextEditingController(
      text: draft.manualNutrition.calories.toString(),
    );
    _proteinController = TextEditingController(
      text: draft.manualNutrition.protein.toString(),
    );
    _carbsController = TextEditingController(
      text: draft.manualNutrition.carbs.toString(),
    );
    _fatController = TextEditingController(
      text: draft.manualNutrition.fat.toString(),
    );
    _fiberController = TextEditingController(
      text: draft.manualNutrition.fiber.toString(),
    );
    _sodiumController = TextEditingController(
      text: draft.manualNutrition.sodium.toString(),
    );
    _sugarController = TextEditingController(
      text: draft.manualNutrition.sugar.toString(),
    );
    _components = draft.components
        .map(_MealComponentControllers.fromDraft)
        .toList(growable: true);
    if (_components.isEmpty) {
      _components.add(_MealComponentControllers.empty());
    }

    _titleController.addListener(_handleDraftChanged);
    _adjustmentsController.addListener(_handleDraftChanged);
    for (final controller in _metricControllers) {
      controller.addListener(_handleDraftChanged);
    }
    for (final component in _components) {
      component.addListener(_handleDraftChanged);
    }
  }

  Iterable<TextEditingController> get _metricControllers => [
    _caloriesController,
    _proteinController,
    _carbsController,
    _fatController,
    _fiberController,
    _sodiumController,
    _sugarController,
  ];

  @override
  void dispose() {
    _titleController.removeListener(_handleDraftChanged);
    _adjustmentsController.removeListener(_handleDraftChanged);
    _titleController.dispose();
    _adjustmentsController.dispose();
    for (final controller in _metricControllers) {
      controller.removeListener(_handleDraftChanged);
      controller.dispose();
    }
    for (final component in _components) {
      component.removeListener(_handleDraftChanged);
      component.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final theme = Theme.of(context);

    return StreamBuilder<List<IngredientLinkTarget>>(
      stream: widget.recipesRepository.watchIngredientLinkTargets(),
      builder: (context, snapshot) {
        final linkTargets = snapshot.data ?? const <IngredientLinkTarget>[];
        final linkedNutrition = _linkedNutrition(linkTargets);
        final manualNutrition = _manualNutrition;
        final totalNutrition = manualNutrition + linkedNutrition;
        final warnings = _linkedWarnings(linkTargets);

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
                              widget.existingMealName == null
                                  ? 'Add saved meal'
                                  : 'Edit saved meal',
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Saved meals can mix manual nutrition with linked pantry items and recipes.',
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
                  _EditorSection(
                    title: 'Basics',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Saved meal name',
                          ),
                          validator: _requiredText,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _adjustmentsController,
                          minLines: 2,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Adjustments / notes',
                            hintText: 'One line per adjustment',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _EditorSection(
                    title: 'Components',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Link pantry items or recipes so saved meals stay current when upstream nutrition changes.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        for (var index = 0; index < _components.length; index++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _MealComponentEditorRow(
                              index: index,
                              controllers: _components[index],
                              linkTargets: linkTargets,
                              canRemove: _components.length > 1,
                              canMoveUp: index > 0,
                              canMoveDown: index < _components.length - 1,
                              onRemove: () => _removeComponent(index),
                              onMoveUp: () => _moveComponent(index, index - 1),
                              onMoveDown: () =>
                                  _moveComponent(index, index + 1),
                              onLinkTypeChanged: (value) =>
                                  _setComponentLinkType(index, value),
                              onLinkTargetChanged: (value) =>
                                  _setComponentLinkTarget(
                                    index,
                                    value,
                                    linkTargets,
                                  ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _addComponent,
                            icon: const Icon(Icons.add),
                            label: const Text('Add component'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _EditorSection(
                    title: 'Estimated Nutrition',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Linked components are calculated live from pantry and recipe references.',
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
                          'Estimated meal total',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _NutritionPreviewGrid(nutrition: totalNutrition),
                        for (final warning in warnings) ...[
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
                  _EditorSection(
                    title: 'Manual Nutrition',
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
                        _MetricField(
                          controller: _carbsController,
                          label: 'Carbs',
                        ),
                        _MetricField(controller: _fatController, label: 'Fat'),
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
                          onPressed: () => _submit(),
                          child: Text(
                            widget.existingMealName == null
                                ? 'Add saved meal'
                                : 'Save changes',
                          ),
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

  void _addComponent() {
    setState(() {
      final component = _MealComponentControllers.empty();
      component.addListener(_handleDraftChanged);
      _components.add(component);
    });
  }

  void _removeComponent(int index) {
    setState(() {
      final removed = _components.removeAt(index);
      removed.removeListener(_handleDraftChanged);
      removed.dispose();
    });
  }

  void _moveComponent(int from, int to) {
    if (to < 0 || to >= _components.length) {
      return;
    }
    setState(() {
      final item = _components.removeAt(from);
      _components.insert(to, item);
    });
  }

  void _setComponentLinkType(int index, RecipeIngredientType value) {
    setState(() {
      final component = _components[index];
      component.linkType = value;
      if (value == RecipeIngredientType.freeform) {
        component.linkedPantryItemId = null;
        component.linkedRecipeId = null;
      } else if (value == RecipeIngredientType.pantryItem) {
        component.linkedRecipeId = null;
      } else {
        component.linkedPantryItemId = null;
      }
    });
  }

  void _setComponentLinkTarget(
    int index,
    String? targetId,
    List<IngredientLinkTarget> linkTargets,
  ) {
    final component = _components[index];
    if (targetId == null) {
      setState(() {
        component.linkedPantryItemId = null;
        component.linkedRecipeId = null;
      });
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
      component.linkType = target.type;
      component.linkedPantryItemId =
          target.type == RecipeIngredientType.pantryItem ? target.id : null;
      component.linkedRecipeId =
          target.type == RecipeIngredientType.recipeReference
          ? target.id
          : null;
      component.item.text = target.title;
      component.unit.text = target.referenceUnit;
    });
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

  NutritionSnapshot _linkedNutrition(List<IngredientLinkTarget> linkTargets) {
    var total = NutritionSnapshot.zero;

    for (final component in _components) {
      final targetId = component.linkedTargetId;
      if (component.linkType == RecipeIngredientType.freeform ||
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

      final resolution = _resolveLinkedQuantity(component, target);
      if (!resolution.isResolved) {
        continue;
      }

      total += target.nutrition.scale(resolution.referenceUnits!);
    }

    return total;
  }

  List<String> _linkedWarnings(List<IngredientLinkTarget> linkTargets) {
    final warnings = <String>[];

    for (var index = 0; index < _components.length; index++) {
      final component = _components[index];
      if (component.linkType == RecipeIngredientType.freeform) {
        continue;
      }

      final target = linkTargets.cast<IngredientLinkTarget?>().firstWhere(
        (item) => item?.id == component.linkedTargetId,
        orElse: () => null,
      );
      if (target == null) {
        warnings.add('Component ${index + 1}: linked target is missing.');
        continue;
      }

      final resolution = _resolveLinkedQuantity(component, target);
      if (resolution.issue == LinkedQuantityIssue.invalidQuantity) {
        warnings.add('Component ${index + 1}: linked qty must be numeric.');
        continue;
      }
      if (resolution.issue == LinkedQuantityIssue.incompatibleUnit) {
        final unitLabel = component.unit.text.trim().isEmpty
            ? 'blank'
            : component.unit.text.trim();
        warnings.add(
          'Component ${index + 1}: unit "$unitLabel" does not convert to ${MeasurementUnits.describeReferenceUnit(referenceUnit: target.referenceUnit, referenceUnitQuantity: target.referenceUnitQuantity, referenceUnitEquivalentQuantity: target.referenceUnitEquivalentQuantity, referenceUnitEquivalentUnit: target.referenceUnitEquivalentUnit, referenceUnitWeightGrams: target.referenceUnitWeightGrams)}.',
        );
      }
    }

    return warnings;
  }

  LinkedQuantityResolution _resolveLinkedQuantity(
    _MealComponentControllers component,
    IngredientLinkTarget target,
  ) {
    return MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: MeasurementUnits.parseQuantity(component.quantity.text),
      ingredientUnit: component.unit.text,
      referenceUnit: target.referenceUnit,
      referenceUnitQuantity: target.referenceUnitQuantity,
      referenceUnitEquivalentQuantity: target.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: target.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: target.referenceUnitWeightGrams,
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final invalidIndex = _components.indexWhere((component) {
      if (component.linkType == RecipeIngredientType.freeform) {
        return false;
      }
      if (component.linkedTargetId == null) {
        return true;
      }
      return MeasurementUnits.parseQuantity(component.quantity.text) == null;
    });
    if (invalidIndex != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Component ${invalidIndex + 1} needs a linked target and numeric quantity.',
          ),
        ),
      );
      return;
    }

    final components = _components
        .map((component) => component.toDraft())
        .where((component) => component.item.trim().isNotEmpty)
        .toList(growable: false);
    Navigator.of(context).pop(
      SavedMealDraft(
        name: _titleController.text.trim(),
        manualNutrition: _manualNutrition,
        adjustments: _adjustmentsController.text
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList(growable: false),
        components: components,
      ),
    );
  }

  void _handleDraftChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}

class _MealComponentEditorRow extends StatelessWidget {
  const _MealComponentEditorRow({
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
  final _MealComponentControllers controllers;
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
                Expanded(child: Text('Component ${index + 1}')),
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
                    decoration: const InputDecoration(labelText: 'Component'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RecipeIngredientType>(
              key: ValueKey(
                'meal-component-link-type-$index-${controllers.linkType.name}',
              ),
              initialValue: controllers.linkType,
              decoration: const InputDecoration(labelText: 'Nutrition source'),
              items: RecipeIngredientType.values
                  .map(
                    (type) => DropdownMenuItem<RecipeIngredientType>(
                      value: type,
                      child: Text(_SavedMealFormatting.linkLabel(type)),
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
                  'meal-component-link-target-$index-$selectedTargetId',
                ),
                initialValue: selectedTarget?.id,
                decoration: InputDecoration(
                  labelText: switch (controllers.linkType) {
                    RecipeIngredientType.pantryItem => 'Linked pantry item',
                    RecipeIngredientType.recipeReference => 'Linked recipe',
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

class _MealComponentControllers {
  _MealComponentControllers({
    required this.quantity,
    required this.unit,
    required this.item,
    this.linkType = RecipeIngredientType.freeform,
    this.linkedPantryItemId,
    this.linkedRecipeId,
  });

  factory _MealComponentControllers.empty() {
    return _MealComponentControllers(
      quantity: TextEditingController(),
      unit: TextEditingController(),
      item: TextEditingController(),
    );
  }

  factory _MealComponentControllers.fromDraft(SavedMealComponentDraft draft) {
    return _MealComponentControllers(
      quantity: TextEditingController(text: draft.quantity),
      unit: TextEditingController(text: draft.unit),
      item: TextEditingController(text: draft.item),
      linkType: draft.linkType,
      linkedPantryItemId: draft.linkedPantryItemId,
      linkedRecipeId: draft.linkedRecipeId,
    );
  }

  final TextEditingController quantity;
  final TextEditingController unit;
  final TextEditingController item;
  RecipeIngredientType linkType;
  String? linkedPantryItemId;
  String? linkedRecipeId;

  String? get linkedTargetId => switch (linkType) {
    RecipeIngredientType.freeform => null,
    RecipeIngredientType.pantryItem => linkedPantryItemId,
    RecipeIngredientType.recipeReference => linkedRecipeId,
  };

  SavedMealComponentDraft toDraft() {
    return SavedMealComponentDraft(
      quantity: quantity.text.trim(),
      unit: unit.text.trim(),
      item: item.text.trim(),
      linkType: linkType,
      linkedPantryItemId: linkedPantryItemId,
      linkedRecipeId: linkedRecipeId,
    );
  }

  void addListener(VoidCallback listener) {
    quantity.addListener(listener);
    unit.addListener(listener);
    item.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    quantity.removeListener(listener);
    unit.removeListener(listener);
    item.removeListener(listener);
  }

  void dispose() {
    quantity.dispose();
    unit.dispose();
    item.dispose();
  }
}

class _EditorSection extends StatelessWidget {
  const _EditorSection({required this.title, required this.child});

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

class _NutritionPreviewGrid extends StatelessWidget {
  const _NutritionPreviewGrid({required this.nutrition});

  final NutritionSnapshot nutrition;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Calories', nutrition.calories.toString()),
      ('Protein', '${nutrition.protein}g'),
      ('Carbs', '${nutrition.carbs}g'),
      ('Fat', '${nutrition.fat}g'),
      ('Fiber', '${nutrition.fiber}g'),
      ('Sodium', '${nutrition.sodium}mg'),
      ('Sugar', '${nutrition.sugar}g'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => SizedBox(
              width: 120,
              child: _MetricPill(label: item.$1, value: item.$2),
            ),
          )
          .toList(growable: false),
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

extension on FoodLogMealSlot {
  String get label => switch (this) {
    FoodLogMealSlot.breakfast => 'Breakfast',
    FoodLogMealSlot.lunch => 'Lunch',
    FoodLogMealSlot.dinner => 'Dinner',
    FoodLogMealSlot.snack => 'Snack',
  };
}

extension on FoodLogEntrySourceType {
  String get label => switch (this) {
    FoodLogEntrySourceType.savedMeal => 'Saved meal',
    FoodLogEntrySourceType.recipe => 'Recipe',
    FoodLogEntrySourceType.pantryItem => 'Pantry item',
  };
}

abstract final class _SavedMealFormatting {
  static String formatComponent(SavedMealComponentDraft component) {
    final parts = [
      if (component.quantity.trim().isNotEmpty) component.quantity.trim(),
      if (component.unit.trim().isNotEmpty) component.unit.trim(),
      component.item.trim(),
    ];
    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  static String linkLabel(RecipeIngredientType type) => switch (type) {
    RecipeIngredientType.freeform => 'Freeform only',
    RecipeIngredientType.pantryItem => 'Linked pantry item',
    RecipeIngredientType.recipeReference => 'Linked recipe',
  };
}
