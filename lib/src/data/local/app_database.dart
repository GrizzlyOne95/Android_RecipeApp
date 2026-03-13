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
    DailyGoalsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

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
    },
  );

  Future<void> seedIfEmpty() async {
    final existingRecipes = await select(recipes).get();
    if (existingRecipes.isNotEmpty) {
      return;
    }

    await transaction(() async {
      final now = DateTime(2026, 3, 13, 9, 30);

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

      for (var index = 0; index < SeedData.pantryItems.length; index++) {
        final item = SeedData.pantryItems[index];

        await into(pantryItemsTable).insert(
          PantryItemsTableCompanion.insert(
            id: 'pantry_$index',
            title: item.name,
            quantityLabel: item.quantityLabel,
            source: item.source,
            accentHex: item.accent.toARGB32(),
            barcode: const Value(null),
            brand: const Value(null),
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
          await into(groceryItemsTable).insert(
            GroceryItemsTableCompanion.insert(
              sectionId: sectionId,
              label: section.items[itemIndex],
              position: itemIndex,
            ),
          );
        }
      }

      for (
        var mealIndex = 0;
        mealIndex < SeedData.savedMeals.length;
        mealIndex++
      ) {
        final meal = SeedData.savedMeals[mealIndex];
        final mealId = 'saved_meal_$mealIndex';

        await into(savedMealsTable).insert(
          SavedMealsTableCompanion.insert(
            id: mealId,
            title: meal.name,
            calories: meal.nutrition.calories,
            protein: meal.nutrition.protein,
            carbs: meal.nutrition.carbs,
            fat: meal.nutrition.fat,
            fiber: meal.nutrition.fiber,
            sodium: meal.nutrition.sodium,
            sugar: meal.nutrition.sugar,
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
      }

      for (final goal in SeedData.dailyGoals) {
        await into(dailyGoalsTable).insert(
          DailyGoalsTableCompanion.insert(
            label: goal.label,
            consumed: goal.consumed,
            target: goal.target,
          ),
        );
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'recipe_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
