import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/recipe_app_scope.dart';
import '../../core/mock_data.dart';
import '../shell/app_shell.dart';

class FoodLogPage extends StatelessWidget {
  const FoodLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, MMMM d').format(DateTime(2026, 3, 13));
    final repository = RecipeAppScope.of(context).repositories.foodLog;

    return ShellScaffold(
      title: 'Food Log',
      subtitle:
          'Track meals by day, reuse saved meals with adjustable ingredient quantities, and compare what you ate against calorie and macro goals.',
      trailing: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          Chip(label: Text(date)),
          const Chip(label: Text('Saved meal dropdown')),
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
            stream: repository.watchSnapshot(),
            builder: (context, snapshot) {
              final data =
                  snapshot.data ??
                  const FoodLogSnapshot(
                    goals: <DailyGoal>[],
                    savedMeals: <SavedMeal>[],
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
                              child: _SavedMealsPanel(meals: data.savedMeals),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _GoalPanel(goals: data.goals),
                            const SizedBox(height: 16),
                            _SavedMealsPanel(meals: data.savedMeals),
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

class _SavedMealsPanel extends StatelessWidget {
  const _SavedMealsPanel({required this.meals});

  final List<SavedMeal> meals;

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
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E6D7),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        '${meal.nutrition.calories} cal • ${meal.nutrition.protein}g protein • ${meal.nutrition.carbs}g carbs',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 10),
                      ...meal.adjustments.map(
                        (adjustment) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            adjustment,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
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
