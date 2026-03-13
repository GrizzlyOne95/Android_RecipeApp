import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/src/core/mock_data.dart';
import 'package:recipe_app/src/data/local/app_database.dart';
import 'package:recipe_app/src/data/repositories/app_repositories.dart';

void main() {
  test('seeds the local database once and exposes recipe records', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await database.seedIfEmpty();
    await database.seedIfEmpty();

    final recipeRows = await database.select(database.recipes).get();
    final pantryRows = await database.select(database.pantryItemsTable).get();
    final goalRows = await database.select(database.dailyGoalsTable).get();

    expect(recipeRows, hasLength(3));
    expect(pantryRows, hasLength(3));
    expect(goalRows, hasLength(7));
  });

  test('recipe repository reads seeded summaries from the database', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repositories = AppRepositories(database);
    addTearDown(database.close);

    await repositories.initialize();
    final recipes = await repositories.recipes.watchRecipes().first;

    final quiche = recipes.firstWhere(
      (recipe) => recipe.name == 'Herbed Quiche Base',
    );

    expect(quiche.tags, contains('Nested recipe'));
    expect(quiche.nutrition.calories, 412);
  });

  test('recipe repository can create update and delete recipes', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repositories = AppRepositories(database);
    addTearDown(database.close);

    await repositories.initialize();

    await repositories.recipes.saveRecipe(
      const RecipeDraft(
        name: 'Sheet Pan Salmon',
        versionLabel: 'Weeknight',
        servings: 4,
        note: 'Simple local CRUD recipe.',
        tags: ['Dinner', 'Low sugar'],
        isPinned: true,
        nutrition: NutritionSnapshot(
          calories: 460,
          protein: 36,
          carbs: 14,
          fat: 28,
          fiber: 4,
          sodium: 520,
          sugar: 6,
        ),
      ),
    );

    var recipes = await repositories.recipes.watchRecipes().first;
    final created = recipes.firstWhere(
      (recipe) => recipe.name == 'Sheet Pan Salmon',
    );

    expect(created.isPinned, isTrue);
    expect(created.tags, contains('Dinner'));

    await repositories.recipes.saveRecipe(
      const RecipeDraft(
        name: 'Sheet Pan Salmon',
        versionLabel: 'Meal Prep',
        servings: 5,
        note: 'Updated locally.',
        tags: ['Dinner', 'Meal prep'],
        isPinned: false,
        nutrition: NutritionSnapshot(
          calories: 430,
          protein: 35,
          carbs: 12,
          fat: 24,
          fiber: 4,
          sodium: 480,
          sugar: 5,
        ),
      ),
      existingId: created.id,
    );

    recipes = await repositories.recipes.watchRecipes().first;
    final updated = recipes.firstWhere((recipe) => recipe.id == created.id);

    expect(updated.versionLabel, 'Meal Prep');
    expect(updated.servings, 5);
    expect(updated.isPinned, isFalse);
    expect(updated.nutrition.calories, 430);
    expect(updated.tags, contains('Meal prep'));

    await repositories.recipes.deleteRecipe(created.id);

    recipes = await repositories.recipes.watchRecipes().first;
    expect(recipes.where((recipe) => recipe.id == created.id), isEmpty);
  });
}
