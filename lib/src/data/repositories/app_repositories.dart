import 'dart:async';

import 'package:drift/drift.dart' show OrderingMode, OrderingTerm, Value;
import 'package:flutter/material.dart';

import '../../core/mock_data.dart';
import '../local/app_database.dart';

class AppRepositories {
  AppRepositories(this.database)
    : recipes = RecipesRepository(database),
      pantry = PantryRepository(database),
      grocery = GroceryRepository(database),
      foodLog = FoodLogRepository(database);

  final AppDatabase database;
  final RecipesRepository recipes;
  final PantryRepository pantry;
  final GroceryRepository grocery;
  final FoodLogRepository foodLog;

  Future<void> initialize() => database.seedIfEmpty();
}

class RecipesRepository {
  RecipesRepository(this._database);

  final AppDatabase _database;

  Stream<List<RecipeSummary>> watchRecipes({
    RecipeSortOrder sortOrder = RecipeSortOrder.caloriesLowToHigh,
  }) {
    final recipeQuery =
        (_database.select(_database.recipes)..orderBy([
              (table) => OrderingTerm(
                expression: table.isPinned,
                mode: OrderingMode.desc,
              ),
              (table) => OrderingTerm(
                expression: table.sortCalories,
                mode: switch (sortOrder) {
                  RecipeSortOrder.caloriesLowToHigh => OrderingMode.asc,
                  RecipeSortOrder.caloriesHighToLow => OrderingMode.desc,
                },
              ),
              (table) => OrderingTerm(
                expression: table.updatedAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .watch();

    final tagQuery = _database.select(_database.recipeTags).watch();
    final ingredientQuery = _database
        .select(_database.recipeIngredients)
        .watch();
    final directionQuery = _database.select(_database.recipeDirections).watch();

    return recipeQuery
        .combineLatest3(tagQuery, ingredientQuery, (
          recipes,
          tags,
          ingredients,
        ) {
          return (recipes, tags, ingredients);
        })
        .combineLatest(directionQuery, (combined, directions) {
          final recipes = combined.$1;
          final tags = combined.$2;
          final ingredients = combined.$3;

          return recipes
              .map((recipe) {
                final recipeTags =
                    tags.where((tag) => tag.recipeId == recipe.id).toList()
                      ..sort(
                        (left, right) =>
                            left.position.compareTo(right.position),
                      );

                return RecipeSummary(
                  id: recipe.id,
                  name: recipe.title,
                  versionLabel: recipe.versionLabel ?? 'Base version',
                  servings: recipe.servings,
                  nutrition: NutritionSnapshot(
                    calories: recipe.calories,
                    protein: recipe.protein,
                    carbs: recipe.carbs,
                    fat: recipe.fat,
                    fiber: recipe.fiber,
                    sodium: recipe.sodium,
                    sugar: recipe.sugar,
                  ),
                  tags: recipeTags.map((tag) => tag.label).toList(),
                  note: recipe.notes,
                  isPinned: recipe.isPinned,
                  sortCalories: recipe.sortCalories,
                  ingredientCount: ingredients
                      .where((ingredient) => ingredient.recipeId == recipe.id)
                      .length,
                  directionCount: directions
                      .where((direction) => direction.recipeId == recipe.id)
                      .length,
                );
              })
              .toList(growable: false);
        });
  }

  Future<RecipeDraft> getRecipeDraft(String id) async {
    final recipe = await (_database.select(
      _database.recipes,
    )..where((table) => table.id.equals(id))).getSingle();
    final tags =
        await (_database.select(
            _database.recipeTags,
          )..where((table) => table.recipeId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));
    final ingredients =
        await (_database.select(
            _database.recipeIngredients,
          )..where((table) => table.recipeId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));
    final directions =
        await (_database.select(
            _database.recipeDirections,
          )..where((table) => table.recipeId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));

    return RecipeDraft(
      name: recipe.title,
      versionLabel: recipe.versionLabel ?? '',
      servings: recipe.servings,
      note: recipe.notes,
      tags: tags.map((tag) => tag.label).toList(growable: false),
      isPinned: recipe.isPinned,
      nutrition: NutritionSnapshot(
        calories: recipe.calories,
        protein: recipe.protein,
        carbs: recipe.carbs,
        fat: recipe.fat,
        fiber: recipe.fiber,
        sodium: recipe.sodium,
        sugar: recipe.sugar,
      ),
      ingredients: ingredients
          .map(
            (ingredient) => RecipeIngredientDraft(
              quantity: ingredient.quantity,
              unit: ingredient.unit,
              item: ingredient.item,
              preparation: ingredient.preparation,
            ),
          )
          .toList(growable: false),
      directions: directions
          .map((direction) => direction.instruction)
          .toList(growable: false),
    );
  }

  Future<void> saveRecipe(RecipeDraft draft, {String? existingId}) async {
    final recipeId =
        existingId ?? 'recipe_${DateTime.now().microsecondsSinceEpoch}';
    final normalizedTags = draft.tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);
    final now = DateTime.now();

    await _database.transaction(() async {
      await _database
          .into(_database.recipes)
          .insertOnConflictUpdate(
            RecipesCompanion.insert(
              id: recipeId,
              title: draft.name.trim(),
              versionLabel: Value(_normalizedVersionLabel(draft.versionLabel)),
              notes: draft.note.trim(),
              servings: draft.servings,
              isPinned: Value(draft.isPinned),
              sortCalories: draft.nutrition.calories,
              calories: draft.nutrition.calories,
              protein: draft.nutrition.protein,
              carbs: draft.nutrition.carbs,
              fat: draft.nutrition.fat,
              fiber: draft.nutrition.fiber,
              sodium: draft.nutrition.sodium,
              sugar: draft.nutrition.sugar,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await (_database.delete(
        _database.recipeTags,
      )..where((table) => table.recipeId.equals(recipeId))).go();
      await (_database.delete(
        _database.recipeIngredients,
      )..where((table) => table.recipeId.equals(recipeId))).go();
      await (_database.delete(
        _database.recipeDirections,
      )..where((table) => table.recipeId.equals(recipeId))).go();

      for (var index = 0; index < normalizedTags.length; index++) {
        await _database
            .into(_database.recipeTags)
            .insert(
              RecipeTagsCompanion.insert(
                recipeId: recipeId,
                label: normalizedTags[index],
                position: index,
              ),
            );
      }

      for (var index = 0; index < draft.ingredients.length; index++) {
        final ingredient = draft.ingredients[index];
        await _database
            .into(_database.recipeIngredients)
            .insert(
              RecipeIngredientsCompanion.insert(
                recipeId: recipeId,
                position: index,
                quantity: ingredient.quantity.trim(),
                unit: ingredient.unit.trim(),
                item: ingredient.item.trim(),
                preparation: ingredient.preparation.trim(),
              ),
            );
      }

      for (var index = 0; index < draft.directions.length; index++) {
        final direction = draft.directions[index].trim();
        if (direction.isEmpty) {
          continue;
        }

        await _database
            .into(_database.recipeDirections)
            .insert(
              RecipeDirectionsCompanion.insert(
                recipeId: recipeId,
                position: index,
                instruction: direction,
              ),
            );
      }
    });
  }

  Future<void> deleteRecipe(String id) {
    return (_database.delete(
      _database.recipes,
    )..where((table) => table.id.equals(id))).go();
  }

  String? _normalizedVersionLabel(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class PantryRepository {
  PantryRepository(this._database);

  final AppDatabase _database;

  Stream<List<PantryItem>> watchPantryItems() {
    return (_database.select(
      _database.pantryItemsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.title)])).watch().map(
      (items) => items
          .map(
            (item) => PantryItem(
              name: item.title,
              quantityLabel: item.quantityLabel,
              source: item.source,
              nutrition: NutritionSnapshot(
                calories: item.calories,
                protein: item.protein,
                carbs: item.carbs,
                fat: item.fat,
                fiber: item.fiber,
                sodium: item.sodium,
                sugar: item.sugar,
              ),
              accent: Color(item.accentHex),
            ),
          )
          .toList(growable: false),
    );
  }
}

class GroceryRepository {
  GroceryRepository(this._database);

  final AppDatabase _database;

  Stream<List<GrocerySection>> watchGrocerySections() {
    final sectionsQuery = (_database.select(
      _database.grocerySectionsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();
    final itemsQuery = (_database.select(
      _database.groceryItemsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();

    return sectionsQuery.combineLatest(itemsQuery, (sections, items) {
      return sections
          .map(
            (section) => GrocerySection(
              title: section.title,
              items: items
                  .where((item) => item.sectionId == section.id)
                  .map((item) => item.label)
                  .toList(growable: false),
            ),
          )
          .toList(growable: false);
    });
  }
}

class FoodLogRepository {
  FoodLogRepository(this._database);

  final AppDatabase _database;

  Stream<FoodLogSnapshot> watchSnapshot() {
    final goalsQuery = (_database.select(
      _database.dailyGoalsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.id)])).watch();
    final mealsQuery = (_database.select(
      _database.savedMealsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.createdAt)])).watch();
    final adjustmentsQuery = (_database.select(
      _database.savedMealAdjustments,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();

    return goalsQuery.combineLatest3(mealsQuery, adjustmentsQuery, (
      goals,
      meals,
      adjustments,
    ) {
      return FoodLogSnapshot(
        goals: goals
            .map(
              (goal) => DailyGoal(
                label: goal.label,
                consumed: goal.consumed,
                target: goal.target,
              ),
            )
            .toList(growable: false),
        savedMeals: meals
            .map(
              (meal) => SavedMeal(
                name: meal.title,
                nutrition: NutritionSnapshot(
                  calories: meal.calories,
                  protein: meal.protein,
                  carbs: meal.carbs,
                  fat: meal.fat,
                  fiber: meal.fiber,
                  sodium: meal.sodium,
                  sugar: meal.sugar,
                ),
                adjustments: adjustments
                    .where((adjustment) => adjustment.mealId == meal.id)
                    .map((adjustment) => adjustment.label)
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
      );
    });
  }
}

extension _CombineLatestExtension<T> on Stream<T> {
  Stream<R> combineLatest<U, R>(
    Stream<U> other,
    R Function(T left, U right) combiner,
  ) {
    late T latestLeft;
    late U latestRight;
    var hasLeft = false;
    var hasRight = false;

    final controller = StreamController<R>.broadcast();

    void emitIfReady() {
      if (hasLeft && hasRight) {
        controller.add(combiner(latestLeft, latestRight));
      }
    }

    final leftSubscription = listen(
      (value) {
        latestLeft = value;
        hasLeft = true;
        emitIfReady();
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    final rightSubscription = other.listen((value) {
      latestRight = value;
      hasRight = true;
      emitIfReady();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await leftSubscription.cancel();
      await rightSubscription.cancel();
    };

    return controller.stream;
  }

  Stream<R> combineLatest3<U, V, R>(
    Stream<U> second,
    Stream<V> third,
    R Function(T first, U second, V third) combiner,
  ) {
    return combineLatest(
      second.combineLatest(third, (right, last) => (right, last)),
      (first, combined) => combiner(first, combined.$1, combined.$2),
    );
  }
}
