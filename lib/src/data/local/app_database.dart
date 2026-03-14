import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/mock_data.dart';

part 'app_database.g.dart';

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get versionLabel => text().nullable()();
  TextColumn get notes => text()();
  IntColumn get servings => integer()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get sortCalories => integer()();
  IntColumn get calories => integer()();
  IntColumn get protein => integer()();
  IntColumn get carbs => integer()();
  IntColumn get fat => integer()();
  IntColumn get fiber => integer()();
  IntColumn get sodium => integer()();
  IntColumn get sugar => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class RecipeTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeId => text().references(Recipes, #id)();
  TextColumn get label => text()();
  IntColumn get position => integer()();
}

class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeId => text().references(Recipes, #id)();
  IntColumn get position => integer()();
  TextColumn get quantity => text()();
  TextColumn get unit => text()();
  TextColumn get item => text()();
  TextColumn get preparation => text()();
  TextColumn get ingredientType =>
      text().withDefault(const Constant('freeform'))();
  TextColumn get linkedPantryItemId => text().nullable()();
  TextColumn get linkedRecipeId => text().nullable()();
}

class RecipeDirections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recipeId => text().references(Recipes, #id)();
  IntColumn get position => integer()();
  TextColumn get instruction => text()();
}

class PantryItemsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get quantityLabel => text()();
  RealColumn get referenceUnitQuantity =>
      real().withDefault(const Constant(1))();
  TextColumn get referenceUnit =>
      text().withDefault(const Constant('serving'))();
  RealColumn get referenceUnitEquivalentQuantity => real().nullable()();
  TextColumn get referenceUnitEquivalentUnit => text().nullable()();
  RealColumn get referenceUnitWeightGrams => real().nullable()();
  TextColumn get source => text()();
  IntColumn get accentHex => integer()();
  TextColumn get barcode => text().nullable()();
  TextColumn get brand => text().nullable()();
  IntColumn get calories => integer()();
  IntColumn get protein => integer()();
  IntColumn get carbs => integer()();
  IntColumn get fat => integer()();
  IntColumn get fiber => integer()();
  IntColumn get sodium => integer()();
  IntColumn get sugar => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class GrocerySectionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get position => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class GroceryItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sectionId => text().references(GrocerySectionsTable, #id)();
  TextColumn get label => text()();
  IntColumn get position => integer()();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
}

class SavedMealsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get calories => integer()();
  IntColumn get protein => integer()();
  IntColumn get carbs => integer()();
  IntColumn get fat => integer()();
  IntColumn get fiber => integer()();
  IntColumn get sodium => integer()();
  IntColumn get sugar => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SavedMealAdjustments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mealId => text().references(SavedMealsTable, #id)();
  TextColumn get label => text()();
  IntColumn get position => integer()();
}

class SavedMealComponents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mealId => text().references(SavedMealsTable, #id)();
  IntColumn get position => integer()();
  TextColumn get quantity => text()();
  TextColumn get unit => text()();
  TextColumn get item => text()();
  TextColumn get componentType =>
      text().withDefault(const Constant('freeform'))();
  TextColumn get linkedPantryItemId => text().nullable()();
  TextColumn get linkedRecipeId => text().nullable()();
}

class FoodLogEntriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get entryDate => text()();
  TextColumn get mealSlot => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get title => text()();
  TextColumn get quantity => text()();
  TextColumn get unit => text()();
  IntColumn get calories => integer()();
  IntColumn get protein => integer()();
  IntColumn get carbs => integer()();
  IntColumn get fat => integer()();
  IntColumn get fiber => integer()();
  IntColumn get sodium => integer()();
  IntColumn get sugar => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class SyncQueueTable extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get changeType => text()();
  TextColumn get displayLabel => text().nullable()();
  DateTimeColumn get changedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {entityType, entityId};
}

class DailyGoalsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text().unique()();
  IntColumn get consumed => integer()();
  IntColumn get target => integer()();
}

@DriftDatabase(
  tables: [
    Recipes,
    RecipeTags,
    RecipeIngredients,
    RecipeDirections,
    PantryItemsTable,
    GrocerySectionsTable,
    GroceryItemsTable,
    SavedMealsTable,
    SavedMealAdjustments,
    SavedMealComponents,
    FoodLogEntriesTable,
    AppSettingsTable,
    SyncQueueTable,
    DailyGoalsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(recipeIngredients);
        await m.createTable(recipeDirections);
      }
      if (from < 3) {
        await m.addColumn(recipeIngredients, recipeIngredients.ingredientType);
        await m.addColumn(
          recipeIngredients,
          recipeIngredients.linkedPantryItemId,
        );
        await m.addColumn(recipeIngredients, recipeIngredients.linkedRecipeId);
      }
      if (from < 4) {
        await m.addColumn(pantryItemsTable, pantryItemsTable.referenceUnit);
      }
      if (from < 5) {
        await m.addColumn(
          pantryItemsTable,
          pantryItemsTable.referenceUnitEquivalentQuantity,
        );
        await m.addColumn(
          pantryItemsTable,
          pantryItemsTable.referenceUnitEquivalentUnit,
        );
        await m.addColumn(
          pantryItemsTable,
          pantryItemsTable.referenceUnitWeightGrams,
        );
      }
      if (from < 6) {
        await m.createTable(savedMealComponents);
      }
      if (from < 7) {
        await m.createTable(foodLogEntriesTable);
      }
      if (from < 8) {
        if (!await _tableHasColumn('pantry_items_table', 'barcode')) {
          await m.addColumn(pantryItemsTable, pantryItemsTable.barcode);
        }
        if (!await _tableHasColumn('pantry_items_table', 'brand')) {
          await m.addColumn(pantryItemsTable, pantryItemsTable.brand);
        }
      }
      if (from < 9) {
        await m.createTable(appSettingsTable);
        await m.createTable(syncQueueTable);
      }
      if (from < 10) {
        if (!await _tableHasColumn(
          'pantry_items_table',
          'reference_unit_quantity',
        )) {
          await m.addColumn(
            pantryItemsTable,
            pantryItemsTable.referenceUnitQuantity,
          );
        }
      }
    },
  );

  Future<void> seedIfEmpty() async {
    final shouldSeedRecipes = (await select(recipes).get()).isEmpty;
    final shouldSeedPantry = (await select(pantryItemsTable).get()).isEmpty;
    final shouldSeedGrocery = (await select(
      grocerySectionsTable,
    ).get()).isEmpty;
    final shouldSeedSavedMeals = (await select(savedMealsTable).get()).isEmpty;
    final shouldSeedGoals = (await select(dailyGoalsTable).get()).isEmpty;
    final shouldSeedFoodLog = (await select(foodLogEntriesTable).get()).isEmpty;

    if (!shouldSeedRecipes &&
        !shouldSeedPantry &&
        !shouldSeedGrocery &&
        !shouldSeedSavedMeals &&
        !shouldSeedGoals &&
        !shouldSeedFoodLog) {
      return;
    }

    await transaction(() async {
      final now = DateTime(2026, 3, 13, 9, 30);

      if (shouldSeedRecipes) {
        await _seedRecipes(now);
      }

      if (shouldSeedPantry) {
        await _seedPantryItems(now);
      }

      if (shouldSeedGrocery) {
        await _seedGrocerySections();
      }

      if (shouldSeedSavedMeals) {
        await _seedSavedMeals(now);
      }

      if (shouldSeedGoals) {
        await _seedDailyGoals();
      }

      if (shouldSeedFoodLog) {
        await _seedFoodLogEntries(now);
      }
    });
  }

  Future<void> _seedRecipes(DateTime now) async {
    for (var index = 0; index < SeedData.recipes.length; index++) {
      final recipe = SeedData.recipes[index];
      final recipeId = recipe.id;

      await into(recipes).insert(
        RecipesCompanion.insert(
          id: recipeId,
          title: recipe.name,
          versionLabel: Value(recipe.versionLabel),
          notes: recipe.note,
          servings: recipe.servings,
          isPinned: Value(recipe.isPinned),
          sortCalories: recipe.sortCalories,
          calories: recipe.nutrition.calories,
          protein: recipe.nutrition.protein,
          carbs: recipe.nutrition.carbs,
          fat: recipe.nutrition.fat,
          fiber: recipe.nutrition.fiber,
          sodium: recipe.nutrition.sodium,
          sugar: recipe.nutrition.sugar,
          createdAt: now,
          updatedAt: now,
        ),
      );

      for (var tagIndex = 0; tagIndex < recipe.tags.length; tagIndex++) {
        await into(recipeTags).insert(
          RecipeTagsCompanion.insert(
            recipeId: recipeId,
            label: recipe.tags[tagIndex],
            position: tagIndex,
          ),
        );
      }

      final ingredients = SeedData.recipeIngredients[recipeId] ?? const [];
      for (
        var ingredientIndex = 0;
        ingredientIndex < ingredients.length;
        ingredientIndex++
      ) {
        final ingredient = ingredients[ingredientIndex];
        await into(recipeIngredients).insert(
          RecipeIngredientsCompanion.insert(
            recipeId: recipeId,
            position: ingredientIndex,
            quantity: ingredient.quantity,
            unit: ingredient.unit,
            item: ingredient.item,
            preparation: ingredient.preparation,
            ingredientType: Value(ingredient.linkType.name),
            linkedPantryItemId: Value(ingredient.linkedPantryItemId),
            linkedRecipeId: Value(ingredient.linkedRecipeId),
          ),
        );
      }

      final directions = SeedData.recipeDirections[recipeId] ?? const [];
      for (
        var directionIndex = 0;
        directionIndex < directions.length;
        directionIndex++
      ) {
        await into(recipeDirections).insert(
          RecipeDirectionsCompanion.insert(
            recipeId: recipeId,
            position: directionIndex,
            instruction: directions[directionIndex],
          ),
        );
      }
    }
  }

  Future<void> _seedPantryItems(DateTime now) async {
    for (var index = 0; index < SeedData.pantryItems.length; index++) {
      final item = SeedData.pantryItems[index];

      await into(pantryItemsTable).insert(
        PantryItemsTableCompanion.insert(
          id: item.id,
          title: item.name,
          quantityLabel: item.quantityLabel,
          referenceUnitQuantity: Value(item.referenceUnitQuantity),
          referenceUnit: Value(item.referenceUnit),
          referenceUnitEquivalentQuantity: Value(
            item.referenceUnitEquivalentQuantity,
          ),
          referenceUnitEquivalentUnit: Value(item.referenceUnitEquivalentUnit),
          referenceUnitWeightGrams: Value(item.referenceUnitWeightGrams),
          source: item.source,
          accentHex: item.accent.toARGB32(),
          barcode: Value(item.barcode),
          brand: Value(item.brand),
          calories: item.nutrition.calories,
          protein: item.nutrition.protein,
          carbs: item.nutrition.carbs,
          fat: item.nutrition.fat,
          fiber: item.nutrition.fiber,
          sodium: item.nutrition.sodium,
          sugar: item.nutrition.sugar,
          createdAt: now,
        ),
      );
    }
  }

  Future<void> _seedGrocerySections() async {
    for (
      var sectionIndex = 0;
      sectionIndex < SeedData.grocerySections.length;
      sectionIndex++
    ) {
      final section = SeedData.grocerySections[sectionIndex];
      final sectionId = 'grocery_section_$sectionIndex';

      await into(grocerySectionsTable).insert(
        GrocerySectionsTableCompanion.insert(
          id: sectionId,
          title: section.title,
          position: sectionIndex,
        ),
      );

      for (var itemIndex = 0; itemIndex < section.items.length; itemIndex++) {
        final groceryItem = section.items[itemIndex];
        await into(groceryItemsTable).insert(
          GroceryItemsTableCompanion.insert(
            sectionId: sectionId,
            label: groceryItem.label,
            position: itemIndex,
            isChecked: Value(groceryItem.isChecked),
          ),
        );
      }
    }
  }

  Future<void> _seedSavedMeals(DateTime now) async {
    for (
      var mealIndex = 0;
      mealIndex < SeedData.savedMeals.length;
      mealIndex++
    ) {
      final meal = SeedData.savedMeals[mealIndex];
      final mealId = meal.id;

      await into(savedMealsTable).insert(
        SavedMealsTableCompanion.insert(
          id: mealId,
          title: meal.name,
          calories: meal.manualNutrition.calories,
          protein: meal.manualNutrition.protein,
          carbs: meal.manualNutrition.carbs,
          fat: meal.manualNutrition.fat,
          fiber: meal.manualNutrition.fiber,
          sodium: meal.manualNutrition.sodium,
          sugar: meal.manualNutrition.sugar,
          createdAt: now,
        ),
      );

      for (
        var adjustmentIndex = 0;
        adjustmentIndex < meal.adjustments.length;
        adjustmentIndex++
      ) {
        await into(savedMealAdjustments).insert(
          SavedMealAdjustmentsCompanion.insert(
            mealId: mealId,
            label: meal.adjustments[adjustmentIndex],
            position: adjustmentIndex,
          ),
        );
      }

      for (
        var componentIndex = 0;
        componentIndex < meal.components.length;
        componentIndex++
      ) {
        final component = meal.components[componentIndex];
        await into(savedMealComponents).insert(
          SavedMealComponentsCompanion.insert(
            mealId: mealId,
            position: componentIndex,
            quantity: component.quantity,
            unit: component.unit,
            item: component.item,
            componentType: Value(component.linkType.name),
            linkedPantryItemId: Value(component.linkedPantryItemId),
            linkedRecipeId: Value(component.linkedRecipeId),
          ),
        );
      }
    }
  }

  Future<void> _seedDailyGoals() async {
    for (final goal in SeedData.dailyGoals) {
      await into(dailyGoalsTable).insert(
        DailyGoalsTableCompanion.insert(
          label: goal.label,
          consumed: goal.consumed,
          target: goal.target,
        ),
      );
    }
  }

  Future<void> _seedFoodLogEntries(DateTime now) async {
    for (var index = 0; index < SeedData.foodLogEntries.length; index++) {
      final entry = SeedData.foodLogEntries[index];
      await into(foodLogEntriesTable).insert(
        FoodLogEntriesTableCompanion.insert(
          id: 'food_log_entry_$index',
          entryDate:
              '${entry.date.year.toString().padLeft(4, '0')}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}',
          mealSlot: entry.mealSlot.name,
          sourceType: entry.sourceType.name,
          sourceId: entry.sourceId,
          title: entry.title,
          quantity: entry.quantity,
          unit: entry.unit,
          calories: entry.nutrition.calories,
          protein: entry.nutrition.protein,
          carbs: entry.nutrition.carbs,
          fat: entry.nutrition.fat,
          fiber: entry.nutrition.fiber,
          sodium: entry.nutrition.sodium,
          sugar: entry.nutrition.sugar,
          createdAt: now.add(Duration(minutes: index)),
        ),
      );
    }
  }

  Future<bool> _tableHasColumn(String tableName, String columnName) async {
    final result = await customSelect("PRAGMA table_info('$tableName')").get();
    return result.any((row) => row.data['name'] == columnName);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'recipe_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
