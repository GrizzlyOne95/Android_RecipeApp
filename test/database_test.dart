import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/src/core/mock_data.dart';
import 'package:recipe_app/src/core/sync_models.dart';
import 'package:recipe_app/src/data/local/app_database.dart';
import 'package:recipe_app/src/data/repositories/app_repositories.dart';
import 'package:recipe_app/src/data/sync/cloud_sync_gateway.dart';

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

  test(
    'seedIfEmpty backfills newer tables for upgraded local installs',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime(2026, 3, 14, 8);
      await database
          .into(database.recipes)
          .insert(
            RecipesCompanion.insert(
              id: 'legacy_recipe',
              title: 'Legacy Recipe',
              versionLabel: const Value('Imported'),
              notes: 'Existing install data',
              servings: 2,
              isPinned: const Value(false),
              sortCalories: 320,
              calories: 320,
              protein: 20,
              carbs: 24,
              fat: 14,
              fiber: 3,
              sodium: 410,
              sugar: 4,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database.seedIfEmpty();
      await database.seedIfEmpty();

      final recipeRows = await database.select(database.recipes).get();
      final goalRows = await database.select(database.dailyGoalsTable).get();
      final foodLogRows = await database
          .select(database.foodLogEntriesTable)
          .get();

      expect(recipeRows, hasLength(1));
      expect(recipeRows.single.title, 'Legacy Recipe');
      expect(goalRows, hasLength(7));
      expect(foodLogRows, hasLength(SeedData.foodLogEntries.length));
    },
  );

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
    expect(quiche.ingredientCount, 7);
    expect(quiche.directionCount, 4);
  });

  test(
    'recipe repository supports calorie sorting in both directions',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repositories = AppRepositories(database);
      addTearDown(database.close);

      await repositories.initialize();

      final lowToHigh = await repositories.recipes
          .watchRecipes(sortOrder: RecipeSortOrder.caloriesLowToHigh)
          .first;
      final highToLow = await repositories.recipes
          .watchRecipes(sortOrder: RecipeSortOrder.caloriesHighToLow)
          .first;

      expect(lowToHigh.map((recipe) => recipe.name).toList(), [
        'Weeknight Turkey Chili',
        'Herbed Quiche Base',
        'Greek Yogurt Pancakes',
      ]);
      expect(highToLow.map((recipe) => recipe.name).toList(), [
        'Herbed Quiche Base',
        'Weeknight Turkey Chili',
        'Greek Yogurt Pancakes',
      ]);
    },
  );

  test(
    'recipe repository resolves linked pantry and nested recipe nutrition',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repositories = AppRepositories(database);
      addTearDown(database.close);

      await repositories.initialize();

      await repositories.recipes.saveRecipe(
        const RecipeDraft(
          name: 'Quick Sauce',
          versionLabel: 'Base',
          servings: 2,
          note: 'Child recipe for nested nutrition.',
          tags: ['Sauce'],
          isPinned: false,
          nutrition: NutritionSnapshot(
            calories: 80,
            protein: 8,
            carbs: 4,
            fat: 2,
            fiber: 1,
            sodium: 40,
            sugar: 2,
          ),
          ingredients: [],
          directions: ['Whisk and simmer.'],
        ),
      );

      final child = (await repositories.recipes.watchRecipes().first)
          .firstWhere((recipe) => recipe.name == 'Quick Sauce');

      await repositories.recipes.saveRecipe(
        RecipeDraft(
          name: 'Linked Protein Bowl',
          versionLabel: 'Auto Calculated',
          servings: 4,
          note: 'Uses pantry and recipe links.',
          tags: const ['Dinner'],
          isPinned: false,
          nutrition: NutritionSnapshot.zero,
          ingredients: [
            const RecipeIngredientDraft(
              quantity: '2',
              unit: 'servings',
              item: 'Greek yogurt',
              preparation: '',
              linkType: RecipeIngredientType.pantryItem,
              linkedPantryItemId: 'pantry_0',
            ),
            RecipeIngredientDraft(
              quantity: '1',
              unit: 'serving',
              item: 'Quick Sauce',
              preparation: '',
              linkType: RecipeIngredientType.recipeReference,
              linkedRecipeId: child.id,
            ),
          ],
          directions: const ['Stir together and serve.'],
        ),
      );

      final parent = (await repositories.recipes.watchRecipes().first)
          .firstWhere((recipe) => recipe.name == 'Linked Protein Bowl');

      expect(parent.nutrition.calories, 65);
      expect(parent.nutrition.protein, 11);
      expect(parent.nutrition.carbs, 4);
      expect(parent.nutrition.fat, 1);
      expect(parent.nutrition.sodium, 43);

      final parentDraft = await repositories.recipes.getRecipeDraft(parent.id);
      expect(parentDraft.nutrition.calories, 0);
      expect(
        parentDraft.ingredients.first.linkType,
        RecipeIngredientType.pantryItem,
      );
      expect(parentDraft.ingredients.first.linkedPantryItemId, 'pantry_0');
      expect(
        parentDraft.ingredients.last.linkType,
        RecipeIngredientType.recipeReference,
      );
      expect(parentDraft.ingredients.last.linkedRecipeId, child.id);
    },
  );

  test(
    'recipe repository recalculates parents when linked child nutrition changes',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repositories = AppRepositories(database);
      addTearDown(database.close);

      await repositories.initialize();

      await repositories.recipes.saveRecipe(
        const RecipeDraft(
          name: 'Prep Sauce',
          versionLabel: 'Child',
          servings: 2,
          note: '',
          tags: ['Sauce'],
          isPinned: false,
          nutrition: NutritionSnapshot(
            calories: 100,
            protein: 10,
            carbs: 8,
            fat: 2,
            fiber: 1,
            sodium: 100,
            sugar: 4,
          ),
          ingredients: [],
          directions: ['Mix'],
        ),
      );

      final child = (await repositories.recipes.watchRecipes().first)
          .firstWhere((recipe) => recipe.name == 'Prep Sauce');

      await repositories.recipes.saveRecipe(
        RecipeDraft(
          name: 'Sauce Bowl',
          versionLabel: 'Parent',
          servings: 2,
          note: '',
          tags: const ['Dinner'],
          isPinned: false,
          nutrition: const NutritionSnapshot(
            calories: 50,
            protein: 2,
            carbs: 6,
            fat: 1,
            fiber: 0,
            sodium: 20,
            sugar: 1,
          ),
          ingredients: [
            RecipeIngredientDraft(
              quantity: '1',
              unit: 'serving',
              item: 'Prep Sauce',
              preparation: '',
              linkType: RecipeIngredientType.recipeReference,
              linkedRecipeId: child.id,
            ),
          ],
          directions: const ['Serve'],
        ),
      );

      final parentBefore = (await repositories.recipes.watchRecipes().first)
          .firstWhere((recipe) => recipe.name == 'Sauce Bowl');
      expect(parentBefore.nutrition.calories, 100);
      expect(parentBefore.nutrition.protein, 7);

      await repositories.recipes.saveRecipe(
        const RecipeDraft(
          name: 'Prep Sauce',
          versionLabel: 'Child',
          servings: 2,
          note: '',
          tags: ['Sauce'],
          isPinned: false,
          nutrition: NutritionSnapshot(
            calories: 140,
            protein: 16,
            carbs: 8,
            fat: 4,
            fiber: 1,
            sodium: 120,
            sugar: 4,
          ),
          ingredients: [],
          directions: ['Mix'],
        ),
        existingId: child.id,
      );

      final parentAfter = (await repositories.recipes.watchRecipes().first)
          .firstWhere((recipe) => recipe.name == 'Sauce Bowl');
      expect(parentAfter.nutrition.calories, 120);
      expect(parentAfter.nutrition.protein, 10);
      expect(parentAfter.nutrition.fat, 3);
      expect(parentAfter.nutrition.sodium, 80);
    },
  );

  test(
    'recipe repository converts linked pantry quantities across common unit systems',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repositories = AppRepositories(database);
      addTearDown(database.close);

      await repositories.initialize();

      final now = DateTime(2026, 3, 13, 12);
      await database
          .into(database.pantryItemsTable)
          .insert(
            PantryItemsTableCompanion.insert(
              id: 'pantry_test_cup',
              title: 'Measured Stock',
              quantityLabel: 'Test carton',
              referenceUnit: const Value('cup'),
              source: 'test',
              accentHex: 0xFF123456,
              barcode: const Value(null),
              brand: const Value(null),
              calories: 100,
              protein: 10,
              carbs: 1,
              fat: 1,
              fiber: 1,
              sodium: 100,
              sugar: 1,
              createdAt: now,
            ),
          );
      await database
          .into(database.pantryItemsTable)
          .insert(
            PantryItemsTableCompanion.insert(
              id: 'pantry_test_kilo',
              title: 'Measured Flour',
              quantityLabel: 'Test bag',
              referenceUnit: const Value('kg'),
              source: 'test',
              accentHex: 0xFF654321,
              barcode: const Value(null),
              brand: const Value(null),
              calories: 200,
              protein: 20,
              carbs: 2,
              fat: 2,
              fiber: 2,
              sodium: 200,
              sugar: 2,
              createdAt: now,
            ),
          );
      await database
          .into(database.pantryItemsTable)
          .insert(
            PantryItemsTableCompanion.insert(
              id: 'pantry_test_serving',
              title: 'Measured Yogurt',
              quantityLabel: 'Test tub',
              referenceUnit: const Value('serving'),
              referenceUnitEquivalentQuantity: const Value(0.75),
              referenceUnitEquivalentUnit: const Value('cup'),
              referenceUnitWeightGrams: const Value(170),
              source: 'test',
              accentHex: 0xFFABCDEF,
              barcode: const Value(null),
              brand: const Value(null),
              calories: 300,
              protein: 30,
              carbs: 3,
              fat: 3,
              fiber: 3,
              sodium: 300,
              sugar: 3,
              createdAt: now,
            ),
          );

      await repositories.recipes.saveRecipe(
        const RecipeDraft(
          name: 'Converted Units Bowl',
          versionLabel: 'Normalization',
          servings: 1,
          note: '',
          tags: ['Conversion'],
          isPinned: false,
          nutrition: NutritionSnapshot.zero,
          ingredients: [
            RecipeIngredientDraft(
              quantity: '16',
              unit: 'tbsp',
              item: 'Measured Stock',
              preparation: '',
              linkType: RecipeIngredientType.pantryItem,
              linkedPantryItemId: 'pantry_test_cup',
            ),
            RecipeIngredientDraft(
              quantity: '1000',
              unit: 'g',
              item: 'Measured Flour',
              preparation: '',
              linkType: RecipeIngredientType.pantryItem,
              linkedPantryItemId: 'pantry_test_kilo',
            ),
            RecipeIngredientDraft(
              quantity: '12',
              unit: 'tbsp',
              item: 'Measured Yogurt',
              preparation: '',
              linkType: RecipeIngredientType.pantryItem,
              linkedPantryItemId: 'pantry_test_serving',
            ),
            RecipeIngredientDraft(
              quantity: '170',
              unit: 'g',
              item: 'Measured Yogurt',
              preparation: '',
              linkType: RecipeIngredientType.pantryItem,
              linkedPantryItemId: 'pantry_test_serving',
            ),
          ],
          directions: ['Mix'],
        ),
      );

      final converted = (await repositories.recipes.watchRecipes().first)
          .firstWhere((recipe) => recipe.name == 'Converted Units Bowl');

      expect(converted.nutrition.calories, 900);
      expect(converted.nutrition.protein, 90);
      expect(converted.nutrition.carbs, 9);
      expect(converted.nutrition.fat, 9);
      expect(converted.nutrition.fiber, 9);
      expect(converted.nutrition.sodium, 900);
      expect(converted.nutrition.sugar, 9);
    },
  );

  test('pantry repository can create update and delete pantry items', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repositories = AppRepositories(database);
    addTearDown(database.close);

    await repositories.initialize();

    await repositories.pantry.savePantryItem(
      const PantryItemDraft(
        name: 'Measured Cottage Cheese',
        brand: 'Good Culture',
        barcode: '012345678905',
        quantityLabel: '24 oz tub',
        referenceUnitQuantity: 0.5,
        referenceUnit: 'serving',
        source: 'Manual entry',
        nutrition: NutritionSnapshot(
          calories: 110,
          protein: 14,
          carbs: 3,
          fat: 4,
          fiber: 0,
          sodium: 360,
          sugar: 2,
        ),
        accent: Color(0xFF4A6572),
        referenceUnitEquivalentQuantity: 0.5,
        referenceUnitEquivalentUnit: 'cup',
        referenceUnitWeightGrams: 113,
      ),
    );

    var pantryItems = await repositories.pantry.watchPantryItems().first;
    final created = pantryItems.firstWhere(
      (item) => item.name == 'Measured Cottage Cheese',
    );

    expect(created.referenceUnit, 'serving');
    expect(created.referenceUnitQuantity, 0.5);
    expect(created.referenceUnitEquivalentQuantity, 0.5);
    expect(created.referenceUnitEquivalentUnit, 'cup');
    expect(created.referenceUnitWeightGrams, 113);
    expect(created.brand, 'Good Culture');
    expect(created.barcode, '012345678905');
    expect(created.nutrition.protein, 14);

    await repositories.pantry.savePantryItem(
      const PantryItemDraft(
        name: 'Measured Cottage Cheese',
        brand: null,
        barcode: null,
        quantityLabel: '24 oz tub',
        referenceUnitQuantity: 120,
        referenceUnit: 'serving',
        source: 'Manual update',
        nutrition: NutritionSnapshot(
          calories: 120,
          protein: 16,
          carbs: 4,
          fat: 4,
          fiber: 0,
          sodium: 380,
          sugar: 3,
        ),
        accent: Color(0xFF4F6B44),
        referenceUnitEquivalentQuantity: 120,
        referenceUnitEquivalentUnit: 'g',
        referenceUnitWeightGrams: 120,
      ),
      existingId: created.id,
    );

    pantryItems = await repositories.pantry.watchPantryItems().first;
    final updated = pantryItems.firstWhere((item) => item.id == created.id);

    expect(updated.source, 'Manual update');
    expect(updated.nutrition.calories, 120);
    expect(updated.nutrition.protein, 16);
    expect(updated.referenceUnitQuantity, 120);
    expect(updated.referenceUnitEquivalentQuantity, 120);
    expect(updated.referenceUnitEquivalentUnit, 'g');
    expect(updated.referenceUnitWeightGrams, 120);
    expect(updated.brand, isNull);
    expect(updated.barcode, isNull);

    await repositories.pantry.deletePantryItem(created.id);

    pantryItems = await repositories.pantry.watchPantryItems().first;
    expect(pantryItems.where((item) => item.id == created.id), isEmpty);
  });

  test(
    'sync repository connects a cloud account and flushes queued changes',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final gateway = _FakeCloudSyncGateway(isAvailable: true);
      final repositories = AppRepositories(database, cloudSyncGateway: gateway);
      addTearDown(database.close);

      await repositories.initialize();

      var status = await repositories.sync.watchStatus().first;
      expect(status.isConnected, isFalse);
      expect(status.isCloudConfigured, isTrue);
      expect(status.pendingChangeCount, 0);

      await repositories.pantry.savePantryItem(
        const PantryItemDraft(
          name: 'Sync Salsa',
          quantityLabel: '16 oz jar',
          referenceUnit: 'serving',
          source: 'Manual entry',
          nutrition: NutritionSnapshot(
            calories: 10,
            protein: 0,
            carbs: 2,
            fat: 0,
            fiber: 0,
            sodium: 180,
            sugar: 1,
          ),
          accent: Color(0xFFD87B42),
        ),
      );

      var pantryItems = await repositories.pantry.watchPantryItems().first;
      final salsa = pantryItems.firstWhere((item) => item.name == 'Sync Salsa');

      await repositories.pantry.savePantryItem(
        salsa.toDraft().copyWith(source: 'Manual update'),
        existingId: salsa.id,
      );
      await repositories.pantry.deletePantryItem(salsa.id);

      await repositories.grocery.saveManualItem(
        const GroceryManualItemDraft(
          sectionTitle: 'Quick Add',
          label: 'Limes',
          quantity: '4',
          unit: 'each',
        ),
      );

      final sections = await repositories.grocery.watchGrocerySections().first;
      final limes = sections
          .firstWhere((section) => section.title == 'Quick Add')
          .items
          .firstWhere((item) => item.label == 'Limes');
      await repositories.grocery.toggleItemChecked(limes, true);

      status = await repositories.sync.watchStatus().first;
      expect(status.pendingChangeCount, 2);
      final connectResult = await repositories.sync.connectGoogleAccount();
      expect(connectResult.isSuccess, isTrue);

      status = await repositories.sync.watchStatus().first;
      expect(status.isConnected, isTrue);
      expect(status.providerLabel, 'Google');
      expect(status.accountEmail, 'chef@example.com');
      expect(status.pendingChangeCount, 0);
      expect(status.lastSyncedAt, isNotNull);

      expect(gateway.appliedMutations, hasLength(2));
      final pantryMutation = gateway.appliedMutations.firstWhere(
        (mutation) => mutation.entityType == SyncEntityType.pantryItem,
      );
      final groceryMutation = gateway.appliedMutations.firstWhere(
        (mutation) => mutation.entityType == SyncEntityType.groceryItem,
      );
      expect(pantryMutation.changeType, SyncChangeType.delete);
      expect(groceryMutation.changeType, SyncChangeType.upsert);
      expect(gateway.lastUserId, 'firebase-user-1');
      expect(gateway.lastAccountEmail, 'chef@example.com');

      final disconnectResult = await repositories.sync.disconnect();
      expect(disconnectResult.isSuccess, isTrue);
      status = await repositories.sync.watchStatus().first;
      expect(status.isConnected, isFalse);
    },
  );

  test(
    'sync repository surfaces setup-needed state when Firebase is unavailable',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repositories = AppRepositories(
        database,
        cloudSyncGateway: _FakeCloudSyncGateway(isAvailable: false),
      );
      addTearDown(database.close);

      await repositories.initialize();

      final status = await repositories.sync.watchStatus().first;
      expect(status.isCloudConfigured, isFalse);
      expect(status.cloudStatusMessage, contains('not configured'));

      final connectResult = await repositories.sync.connectGoogleAccount();
      expect(connectResult.isSuccess, isFalse);
      expect(connectResult.message, contains('not configured'));

      final failedStatus = await repositories.sync.watchStatus().first;
      expect(failedStatus.lastErrorMessage, contains('not configured'));
      expect(failedStatus.isConnected, isFalse);
    },
  );

  test(
    'food log repository recalculates saved meals with linked pantry and recipe components',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repositories = AppRepositories(database);
      addTearDown(database.close);

      await repositories.initialize();

      await repositories.recipes.saveRecipe(
        const RecipeDraft(
          name: 'Breakfast Protein',
          versionLabel: 'Meal component',
          servings: 1,
          note: '',
          tags: ['Breakfast'],
          isPinned: false,
          nutrition: NutritionSnapshot(
            calories: 200,
            protein: 20,
            carbs: 10,
            fat: 6,
            fiber: 1,
            sodium: 150,
            sugar: 3,
          ),
          ingredients: [],
          directions: ['Mix'],
        ),
      );

      final linkedRecipe = (await repositories.recipes.watchRecipes().first)
          .firstWhere((recipe) => recipe.name == 'Breakfast Protein');

      await repositories.foodLog.saveSavedMeal(
        SavedMealDraft(
          name: 'Breakfast Combo',
          manualNutrition: const NutritionSnapshot(
            calories: 50,
            protein: 5,
            carbs: 4,
            fat: 2,
            fiber: 1,
            sodium: 25,
            sugar: 1,
          ),
          adjustments: const ['Extra berries'],
          components: [
            SavedMealComponentDraft(
              quantity: '1',
              unit: 'serving',
              item: 'Breakfast Protein',
              linkType: RecipeIngredientType.recipeReference,
              linkedRecipeId: linkedRecipe.id,
            ),
            const SavedMealComponentDraft(
              quantity: '0.5',
              unit: 'cup',
              item: 'Nonfat Greek Yogurt',
              linkType: RecipeIngredientType.pantryItem,
              linkedPantryItemId: 'pantry_0',
            ),
          ],
        ),
      );

      var snapshot = await repositories.foodLog.watchSnapshot().first;
      final meal = snapshot.savedMeals.firstWhere(
        (savedMeal) => savedMeal.name == 'Breakfast Combo',
      );

      expect(meal.nutrition.calories, 295);
      expect(meal.nutrition.protein, 34);
      expect(meal.nutrition.carbs, 17);
      expect(meal.nutrition.fat, 8);
      expect(meal.nutrition.fiber, 2);
      expect(meal.nutrition.sodium, 208);
      expect(meal.nutrition.sugar, 7);
      expect(meal.adjustments, ['Extra berries']);
      expect(meal.components, hasLength(2));

      await repositories.recipes.saveRecipe(
        const RecipeDraft(
          name: 'Breakfast Protein',
          versionLabel: 'Meal component',
          servings: 1,
          note: '',
          tags: ['Breakfast'],
          isPinned: false,
          nutrition: NutritionSnapshot(
            calories: 260,
            protein: 24,
            carbs: 12,
            fat: 10,
            fiber: 2,
            sodium: 170,
            sugar: 4,
          ),
          ingredients: [],
          directions: ['Mix'],
        ),
        existingId: linkedRecipe.id,
      );

      snapshot = await repositories.foodLog.watchSnapshot().first;
      final updatedMeal = snapshot.savedMeals.firstWhere(
        (savedMeal) => savedMeal.name == 'Breakfast Combo',
      );

      expect(updatedMeal.nutrition.calories, 355);
      expect(updatedMeal.nutrition.protein, 38);
      expect(updatedMeal.nutrition.carbs, 19);
      expect(updatedMeal.nutrition.fat, 12);
      expect(updatedMeal.nutrition.fiber, 3);
      expect(updatedMeal.nutrition.sodium, 228);
      expect(updatedMeal.nutrition.sugar, 8);

      final savedMealDraft = await repositories.foodLog.getSavedMealDraft(
        updatedMeal.id,
      );
      expect(savedMealDraft.components, hasLength(2));
      expect(
        savedMealDraft.components.first.linkType,
        RecipeIngredientType.recipeReference,
      );

      await repositories.foodLog.deleteSavedMeal(updatedMeal.id);
      snapshot = await repositories.foodLog.watchSnapshot().first;
      expect(
        snapshot.savedMeals.where(
          (savedMeal) => savedMeal.id == updatedMeal.id,
        ),
        isEmpty,
      );
    },
  );

  test(
    'food log repository logs daily entries and recalculates goals from entry snapshots',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repositories = AppRepositories(database);
      addTearDown(database.close);

      await repositories.initialize();

      final targets = await repositories.foodLog.watchEntryTargets().first;
      final yogurt = targets.firstWhere(
        (target) =>
            target.sourceType == FoodLogEntrySourceType.pantryItem &&
            target.id == 'pantry_0',
      );

      var snapshot = await repositories.foodLog.watchSnapshot().first;
      expect(
        snapshot.goals.firstWhere((goal) => goal.label == 'Calories').consumed,
        1425,
      );
      expect(
        snapshot.goals.firstWhere((goal) => goal.label == 'Protein').consumed,
        110,
      );

      await repositories.foodLog.saveFoodLogEntry(
        FoodLogEntryDraft(
          date: SeedData.todayDate,
          mealSlot: FoodLogMealSlot.snack,
          sourceType: yogurt.sourceType,
          sourceId: yogurt.id,
          title: yogurt.title,
          quantity: '1',
          unit: 'serving',
          nutrition: yogurt.nutrition,
        ),
      );

      snapshot = await repositories.foodLog.watchSnapshot().first;
      final addedEntry = snapshot.entries.firstWhere(
        (entry) => entry.sourceId == yogurt.id && entry.quantity == '1',
      );
      expect(
        snapshot.goals.firstWhere((goal) => goal.label == 'Calories').consumed,
        1515,
      );
      expect(
        snapshot.goals.firstWhere((goal) => goal.label == 'Protein').consumed,
        128,
      );

      await repositories.foodLog.deleteFoodLogEntry(addedEntry.id);

      snapshot = await repositories.foodLog.watchSnapshot().first;
      expect(
        snapshot.entries.where((entry) => entry.id == addedEntry.id),
        isEmpty,
      );
      expect(
        snapshot.goals.firstWhere((goal) => goal.label == 'Calories').consumed,
        1425,
      );
    },
  );

  test(
    'grocery repository exports aggregated pinned recipe and saved meal ingredients',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repositories = AppRepositories(database);
      addTearDown(database.close);

      await repositories.pantry.savePantryItem(
        const PantryItemDraft(
          name: 'Diced Tomatoes',
          quantityLabel: '14.5 oz can',
          referenceUnit: 'can',
          source: 'Manual entry',
          nutrition: NutritionSnapshot.zero,
          accent: Color(0xFFD87B42),
          referenceUnitEquivalentQuantity: 14.5,
          referenceUnitEquivalentUnit: 'oz',
          referenceUnitWeightGrams: 411,
        ),
      );

      final pantryItem = await repositories.pantry
          .watchPantryItems()
          .first
          .then(
            (items) =>
                items.firstWhere((item) => item.name == 'Diced Tomatoes'),
          );

      await repositories.recipes.saveRecipe(
        RecipeDraft(
          name: 'Tomato Base',
          versionLabel: 'Child',
          servings: 2,
          note: '',
          tags: const ['Sauce'],
          isPinned: false,
          nutrition: NutritionSnapshot.zero,
          ingredients: [
            RecipeIngredientDraft(
              quantity: '2',
              unit: 'cans',
              item: 'Diced Tomatoes',
              preparation: '',
              linkType: RecipeIngredientType.pantryItem,
              linkedPantryItemId: pantryItem.id,
            ),
          ],
          directions: const ['Simmer'],
        ),
      );

      final childRecipe = await repositories.recipes.watchRecipes().first.then(
        (recipes) =>
            recipes.firstWhere((recipe) => recipe.name == 'Tomato Base'),
      );

      await repositories.recipes.saveRecipe(
        RecipeDraft(
          name: 'Pinned Pasta',
          versionLabel: 'Pinned',
          servings: 2,
          note: '',
          tags: const ['Dinner'],
          isPinned: true,
          nutrition: NutritionSnapshot.zero,
          ingredients: [
            const RecipeIngredientDraft(
              quantity: '1',
              unit: 'lb',
              item: 'Pasta',
              preparation: '',
            ),
            RecipeIngredientDraft(
              quantity: '1',
              unit: 'serving',
              item: 'Tomato Base',
              preparation: '',
              linkType: RecipeIngredientType.recipeReference,
              linkedRecipeId: childRecipe.id,
            ),
          ],
          directions: const ['Cook and toss'],
        ),
      );

      final parentRecipe = await repositories.recipes.watchRecipes().first.then(
        (recipes) =>
            recipes.firstWhere((recipe) => recipe.name == 'Pinned Pasta'),
      );

      await repositories.foodLog.saveSavedMeal(
        SavedMealDraft(
          name: 'Dinner Combo',
          manualNutrition: NutritionSnapshot.zero,
          adjustments: const [],
          components: [
            SavedMealComponentDraft(
              quantity: '2',
              unit: 'servings',
              item: 'Pinned Pasta',
              linkType: RecipeIngredientType.recipeReference,
              linkedRecipeId: parentRecipe.id,
            ),
          ],
        ),
      );

      final sections = await repositories.grocery.watchGrocerySections().first;
      final pinnedSection = sections.firstWhere(
        (section) => section.title == 'Pinned Recipes',
      );
      final savedMealsSection = sections.firstWhere(
        (section) => section.title == 'Saved Meals',
      );

      final pinnedPasta = pinnedSection.items.firstWhere(
        (item) => item.label == 'Pasta',
      );
      final pinnedTomatoes = pinnedSection.items.firstWhere(
        (item) => item.label == 'Diced Tomatoes',
      );
      final savedMealPasta = savedMealsSection.items.firstWhere(
        (item) => item.label == 'Pasta',
      );
      final savedMealTomatoes = savedMealsSection.items.firstWhere(
        (item) => item.label == 'Diced Tomatoes',
      );

      expect(pinnedPasta.detail, '1 lb');
      expect(pinnedPasta.sourceSummary, 'Pinned Pasta');
      expect(pinnedTomatoes.detail, '1 can');
      expect(pinnedTomatoes.sourceSummary, 'Pinned Pasta');

      expect(savedMealPasta.detail, '1 lb');
      expect(savedMealPasta.sourceSummary, 'Dinner Combo');
      expect(savedMealTomatoes.detail, '1 can');
      expect(savedMealTomatoes.sourceSummary, 'Dinner Combo');
    },
  );

  test(
    'grocery repository persists export settings manual items and checked state',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repositories = AppRepositories(database);
      addTearDown(database.close);

      await repositories.initialize();

      await repositories.grocery.saveManualItem(
        const GroceryManualItemDraft(
          sectionTitle: 'Quick Add',
          label: 'Bananas',
          quantity: '6',
          unit: 'each',
        ),
      );

      var sections = await repositories.grocery.watchGrocerySections().first;
      final manualSection = sections.firstWhere(
        (section) => section.title == 'Quick Add',
      );
      final bananas = manualSection.items.firstWhere(
        (item) => item.label == 'Bananas',
      );
      expect(bananas.detail, '6 each');
      expect(bananas.isGenerated, isFalse);

      await repositories.grocery.toggleItemChecked(bananas, true);
      sections = await repositories.grocery.watchGrocerySections().first;
      final checkedBananas = sections
          .firstWhere((section) => section.title == 'Quick Add')
          .items
          .firstWhere((item) => item.label == 'Bananas');
      expect(checkedBananas.isChecked, isTrue);

      final generatedItem = sections
          .firstWhere((section) => section.title == 'Pinned Recipes')
          .items
          .first;
      await repositories.grocery.toggleItemChecked(generatedItem, true);
      sections = await repositories.grocery.watchGrocerySections().first;
      final checkedGeneratedItem = sections
          .firstWhere((section) => section.title == 'Pinned Recipes')
          .items
          .firstWhere((item) => item.key == generatedItem.key);
      expect(checkedGeneratedItem.isChecked, isTrue);

      await repositories.grocery.setExportSettings(
        const GroceryExportSettings(
          includePinnedRecipes: false,
          includeSavedMeals: false,
        ),
      );

      final settings = await repositories.grocery.watchExportSettings().first;
      expect(settings.includePinnedRecipes, isFalse);
      expect(settings.includeSavedMeals, isFalse);

      sections = await repositories.grocery.watchGrocerySections().first;
      expect(
        sections.where((section) => section.title == 'Pinned Recipes'),
        isEmpty,
      );
      expect(
        sections.where((section) => section.title == 'Saved Meals'),
        isEmpty,
      );
      expect(
        sections
            .firstWhere((section) => section.title == 'Quick Add')
            .items
            .firstWhere((item) => item.label == 'Bananas')
            .isChecked,
        isTrue,
      );
    },
  );

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
        ingredients: [
          RecipeIngredientDraft(
            quantity: '4',
            unit: 'filets',
            item: 'Salmon',
            preparation: 'Pat dry',
          ),
          RecipeIngredientDraft(
            quantity: '1',
            unit: 'lb',
            item: 'Potatoes',
            preparation: 'Halved',
          ),
        ],
        directions: [
          'Toss potatoes with oil and roast.',
          'Add salmon and finish until flaky.',
        ],
      ),
    );

    var recipes = await repositories.recipes.watchRecipes().first;
    final created = recipes.firstWhere(
      (recipe) => recipe.name == 'Sheet Pan Salmon',
    );

    expect(created.isPinned, isTrue);
    expect(created.tags, contains('Dinner'));
    expect(created.ingredientCount, 2);
    expect(created.directionCount, 2);

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
        ingredients: [
          RecipeIngredientDraft(
            quantity: '1',
            unit: 'lb',
            item: 'Potatoes',
            preparation: 'Crisped first',
          ),
          RecipeIngredientDraft(
            quantity: '5',
            unit: 'filets',
            item: 'Salmon',
            preparation: 'Portioned',
          ),
        ],
        directions: [
          'Roast potatoes until browned.',
          'Season salmon.',
          'Nest salmon on the tray and roast until just cooked through.',
        ],
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
    expect(updated.ingredientCount, 2);
    expect(updated.directionCount, 3);

    final updatedDraft = await repositories.recipes.getRecipeDraft(created.id);
    expect(updatedDraft.ingredients.first.item, 'Potatoes');
    expect(updatedDraft.ingredients.last.item, 'Salmon');
    expect(updatedDraft.ingredients.last.preparation, 'Portioned');
    expect(updatedDraft.directions.first, 'Roast potatoes until browned.');
    expect(
      updatedDraft.directions.last,
      'Nest salmon on the tray and roast until just cooked through.',
    );

    await repositories.recipes.deleteRecipe(created.id);

    recipes = await repositories.recipes.watchRecipes().first;
    expect(recipes.where((recipe) => recipe.id == created.id), isEmpty);
  });
}

class _FakeCloudSyncGateway implements CloudSyncGateway {
  _FakeCloudSyncGateway({required bool isAvailable})
    : _availability = CloudSyncAvailability(
        isAvailable: isAvailable,
        message: isAvailable
            ? 'Firebase is configured for tests.'
            : 'Firebase is not configured for this test.',
      );

  final CloudSyncAvailability _availability;
  final List<CloudSyncMutation> appliedMutations = <CloudSyncMutation>[];
  CloudSyncSession _session = const CloudSyncSession(
    isConfigured: false,
    providerLabel: 'Google',
  );
  String? lastUserId;
  String? lastAccountEmail;

  @override
  CloudSyncAvailability get availability => _availability;

  @override
  Future<void> initialize() async {}

  @override
  Future<CloudSyncSession> currentSession() async => _session;

  @override
  Future<CloudSyncSession> signInWithGoogle() async {
    if (!availability.isAvailable) {
      throw StateError(availability.message);
    }
    _session = const CloudSyncSession(
      isConfigured: true,
      providerLabel: 'Google',
      userId: 'firebase-user-1',
      email: 'chef@example.com',
    );
    return _session;
  }

  @override
  Future<void> signOut() async {
    _session = CloudSyncSession(
      isConfigured: availability.isAvailable,
      providerLabel: 'Google',
    );
  }

  @override
  Future<void> applyMutations({
    required String userId,
    required String accountEmail,
    required List<CloudSyncMutation> mutations,
  }) async {
    if (!availability.isAvailable) {
      throw StateError(availability.message);
    }
    lastUserId = userId;
    lastAccountEmail = accountEmail;
    appliedMutations
      ..clear()
      ..addAll(mutations);
  }
}
