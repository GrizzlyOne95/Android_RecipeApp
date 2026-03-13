import 'dart:async';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';

import '../../core/measurement_units.dart';
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
    final recipeQuery = _database.select(_database.recipes).watch();

    final tagQuery = _database.select(_database.recipeTags).watch();
    final ingredientQuery = _database
        .select(_database.recipeIngredients)
        .watch();
    final directionQuery = _database.select(_database.recipeDirections).watch();
    final pantryQuery = _database.select(_database.pantryItemsTable).watch();

    return recipeQuery
        .combineLatest3(tagQuery, ingredientQuery, (
          recipes,
          tags,
          ingredients,
        ) {
          return (recipes, tags, ingredients);
        })
        .combineLatest(directionQuery, (combined, directions) {
          return (combined.$1, combined.$2, combined.$3, directions);
        })
        .combineLatest(pantryQuery, (combined, pantryItems) {
          final recipes = combined.$1;
          final tags = combined.$2;
          final ingredients = combined.$3;
          final directions = combined.$4;
          final recipesById = {for (final recipe in recipes) recipe.id: recipe};
          final pantryById = {
            for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
          };
          final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
          for (final ingredient in ingredients) {
            ingredientsByRecipeId
                .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
                .add(ingredient);
          }
          for (final ingredientList in ingredientsByRecipeId.values) {
            ingredientList.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final tagsByRecipeId = <String, List<RecipeTag>>{};
          for (final tag in tags) {
            tagsByRecipeId
                .putIfAbsent(tag.recipeId, () => <RecipeTag>[])
                .add(tag);
          }
          for (final recipeTags in tagsByRecipeId.values) {
            recipeTags.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final directionsByRecipeId = <String, List<RecipeDirection>>{};
          for (final direction in directions) {
            directionsByRecipeId
                .putIfAbsent(direction.recipeId, () => <RecipeDirection>[])
                .add(direction);
          }

          final nutritionCache = <String, NutritionSnapshot>{};
          final computedRecipes = recipes
              .map((recipe) {
                final nutrition = _resolveRecipeNutrition(
                  recipeId: recipe.id,
                  recipesById: recipesById,
                  ingredientsByRecipeId: ingredientsByRecipeId,
                  pantryById: pantryById,
                  nutritionCache: nutritionCache,
                );
                final recipeTags =
                    tagsByRecipeId[recipe.id] ?? const <RecipeTag>[];

                return _SortableRecipeSummary(
                  updatedAt: recipe.updatedAt,
                  summary: RecipeSummary(
                    id: recipe.id,
                    name: recipe.title,
                    versionLabel: recipe.versionLabel ?? 'Base version',
                    servings: recipe.servings,
                    nutrition: nutrition,
                    tags: recipeTags.map((tag) => tag.label).toList(),
                    note: recipe.notes,
                    isPinned: recipe.isPinned,
                    sortCalories: nutrition.calories,
                    ingredientCount:
                        ingredientsByRecipeId[recipe.id]?.length ?? 0,
                    directionCount:
                        directionsByRecipeId[recipe.id]?.length ?? 0,
                  ),
                );
              })
              .toList(growable: true);

          computedRecipes.sort((left, right) {
            final pinnedComparison = (right.summary.isPinned ? 1 : 0).compareTo(
              left.summary.isPinned ? 1 : 0,
            );
            if (pinnedComparison != 0) {
              return pinnedComparison;
            }

            final calorieComparison = switch (sortOrder) {
              RecipeSortOrder.caloriesLowToHigh =>
                left.summary.sortCalories.compareTo(right.summary.sortCalories),
              RecipeSortOrder.caloriesHighToLow =>
                right.summary.sortCalories.compareTo(left.summary.sortCalories),
            };
            if (calorieComparison != 0) {
              return calorieComparison;
            }

            return right.updatedAt.compareTo(left.updatedAt);
          });

          return computedRecipes
              .map((recipe) => recipe.summary)
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
              linkType: _ingredientTypeFromName(ingredient.ingredientType),
              linkedPantryItemId: ingredient.linkedPantryItemId,
              linkedRecipeId: ingredient.linkedRecipeId,
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
                ingredientType: Value(ingredient.linkType.name),
                linkedPantryItemId: Value(ingredient.linkedPantryItemId),
                linkedRecipeId: Value(ingredient.linkedRecipeId),
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

  Stream<List<IngredientLinkTarget>> watchIngredientLinkTargets({
    String? excludingRecipeId,
  }) {
    final recipeQuery = (_database.select(
      _database.recipes,
    )..orderBy([(table) => OrderingTerm(expression: table.title)])).watch();
    final pantryQuery = (_database.select(
      _database.pantryItemsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.title)])).watch();
    final ingredientQuery = _database
        .select(_database.recipeIngredients)
        .watch();

    return recipeQuery.combineLatest3(pantryQuery, ingredientQuery, (
      recipes,
      pantryItems,
      ingredients,
    ) {
      final recipesById = {for (final recipe in recipes) recipe.id: recipe};
      final pantryById = {
        for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
      };
      final nutritionCache = <String, NutritionSnapshot>{};
      final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
      for (final ingredient in ingredients) {
        ingredientsByRecipeId
            .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
            .add(ingredient);
      }
      for (final ingredientList in ingredientsByRecipeId.values) {
        ingredientList.sort(
          (left, right) => left.position.compareTo(right.position),
        );
      }

      final pantryTargets = pantryItems
          .map(
            (item) => IngredientLinkTarget(
              id: item.id,
              type: RecipeIngredientType.pantryItem,
              title: item.title,
              referenceUnit: item.referenceUnit,
              nutrition: _nutritionFromPantryItem(item),
              referenceUnitEquivalentQuantity:
                  item.referenceUnitEquivalentQuantity,
              referenceUnitEquivalentUnit: item.referenceUnitEquivalentUnit,
              referenceUnitWeightGrams: item.referenceUnitWeightGrams,
              subtitle:
                  'Pantry item • ${item.quantityLabel} • nutrition per ${_referenceUnitSummary(item.referenceUnit, referenceUnitEquivalentQuantity: item.referenceUnitEquivalentQuantity, referenceUnitEquivalentUnit: item.referenceUnitEquivalentUnit, referenceUnitWeightGrams: item.referenceUnitWeightGrams)}',
            ),
          )
          .toList(growable: false);
      final recipeTargets = recipes
          .where((recipe) => recipe.id != excludingRecipeId)
          .map(
            (recipe) => IngredientLinkTarget(
              id: recipe.id,
              type: RecipeIngredientType.recipeReference,
              title: recipe.title,
              referenceUnit: 'serving',
              nutrition: _resolveRecipeNutrition(
                recipeId: recipe.id,
                recipesById: recipesById,
                ingredientsByRecipeId: ingredientsByRecipeId,
                pantryById: pantryById,
                nutritionCache: nutritionCache,
              ),
              subtitle:
                  'Nested recipe • ${recipe.versionLabel ?? 'Base version'} • nutrition per 1 serving',
            ),
          )
          .toList(growable: false);

      return [...pantryTargets, ...recipeTargets];
    });
  }

  Stream<List<ResolvedRecipeIngredient>> watchResolvedIngredients(
    String recipeId,
  ) {
    final ingredientQuery =
        (_database.select(_database.recipeIngredients)
              ..where((table) => table.recipeId.equals(recipeId))
              ..orderBy([(table) => OrderingTerm(expression: table.position)]))
            .watch();
    final recipeQuery = _database.select(_database.recipes).watch();
    final allIngredientsQuery = _database
        .select(_database.recipeIngredients)
        .watch();
    final pantryQuery = _database.select(_database.pantryItemsTable).watch();

    return ingredientQuery
        .combineLatest3(recipeQuery, allIngredientsQuery, (
          ingredients,
          recipes,
          allIngredients,
        ) {
          return (ingredients, recipes, allIngredients);
        })
        .combineLatest(pantryQuery, (combined, pantryItems) {
          final ingredients = combined.$1;
          final recipes = combined.$2;
          final allIngredients = combined.$3;
          final recipesById = {for (final recipe in recipes) recipe.id: recipe};
          final pantryById = {
            for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
          };
          final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
          for (final ingredient in allIngredients) {
            ingredientsByRecipeId
                .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
                .add(ingredient);
          }
          for (final ingredientList in ingredientsByRecipeId.values) {
            ingredientList.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final nutritionCache = <String, NutritionSnapshot>{};

          return ingredients
              .map((ingredient) {
                final ingredientType = _ingredientTypeFromName(
                  ingredient.ingredientType,
                );
                final draft = RecipeIngredientDraft(
                  quantity: ingredient.quantity,
                  unit: ingredient.unit,
                  item: ingredient.item,
                  preparation: ingredient.preparation,
                  linkType: ingredientType,
                  linkedPantryItemId: ingredient.linkedPantryItemId,
                  linkedRecipeId: ingredient.linkedRecipeId,
                );

                return switch (ingredientType) {
                  RecipeIngredientType.freeform => ResolvedRecipeIngredient(
                    draft: draft,
                    linkTitle: null,
                    linkSubtitle: '',
                    batchNutrition: NutritionSnapshot.zero,
                  ),
                  RecipeIngredientType.pantryItem => () {
                    final pantryItem =
                        pantryById[ingredient.linkedPantryItemId];
                    return ResolvedRecipeIngredient(
                      draft: draft,
                      linkTitle: pantryItem?.title,
                      linkSubtitle: pantryItem == null
                          ? 'Pantry item missing'
                          : 'Pantry item • per ${_referenceUnitSummary(pantryItem.referenceUnit, referenceUnitEquivalentQuantity: pantryItem.referenceUnitEquivalentQuantity, referenceUnitEquivalentUnit: pantryItem.referenceUnitEquivalentUnit, referenceUnitWeightGrams: pantryItem.referenceUnitWeightGrams)}',
                      batchNutrition: _resolveIngredientBatchNutrition(
                        ingredient: ingredient,
                        currentRecipeId: recipeId,
                        recipesById: recipesById,
                        ingredientsByRecipeId: ingredientsByRecipeId,
                        pantryById: pantryById,
                        nutritionCache: nutritionCache,
                      ),
                    );
                  }(),
                  RecipeIngredientType.recipeReference => () {
                    final linkedRecipe = recipesById[ingredient.linkedRecipeId];
                    return ResolvedRecipeIngredient(
                      draft: draft,
                      linkTitle: linkedRecipe?.title,
                      linkSubtitle: linkedRecipe == null
                          ? 'Nested recipe missing'
                          : 'Nested recipe • per 1 serving',
                      batchNutrition: _resolveIngredientBatchNutrition(
                        ingredient: ingredient,
                        currentRecipeId: recipeId,
                        recipesById: recipesById,
                        ingredientsByRecipeId: ingredientsByRecipeId,
                        pantryById: pantryById,
                        nutritionCache: nutritionCache,
                      ),
                    );
                  }(),
                };
              })
              .toList(growable: false);
        });
  }

  NutritionSnapshot _resolveRecipeNutrition({
    required String recipeId,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, NutritionSnapshot> nutritionCache,
    Set<String> trail = const <String>{},
  }) {
    final cached = nutritionCache[recipeId];
    if (cached != null) {
      return cached;
    }

    final recipe = recipesById[recipeId];
    if (recipe == null) {
      return NutritionSnapshot.zero;
    }
    if (trail.contains(recipeId)) {
      return _nutritionFromRecipeRow(recipe);
    }

    final servings = recipe.servings <= 0 ? 1 : recipe.servings;
    final manualBatchNutrition = _nutritionFromRecipeRow(
      recipe,
    ).scale(servings.toDouble());
    final linkedBatchNutrition =
        (ingredientsByRecipeId[recipeId] ?? const <RecipeIngredient>[])
            .map(
              (ingredient) => _resolveIngredientBatchNutrition(
                ingredient: ingredient,
                currentRecipeId: recipeId,
                recipesById: recipesById,
                ingredientsByRecipeId: ingredientsByRecipeId,
                pantryById: pantryById,
                nutritionCache: nutritionCache,
                trail: {...trail, recipeId},
              ),
            )
            .fold(NutritionSnapshot.zero, (total, item) => total + item);
    final totalNutrition = (manualBatchNutrition + linkedBatchNutrition).divide(
      servings,
    );
    nutritionCache[recipeId] = totalNutrition;
    return totalNutrition;
  }

  NutritionSnapshot _resolveIngredientBatchNutrition({
    required RecipeIngredient ingredient,
    required String currentRecipeId,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, NutritionSnapshot> nutritionCache,
    Set<String> trail = const <String>{},
  }) {
    final quantity = _parseLinkedQuantity(ingredient.quantity);
    final linkedPantryItem = pantryById[ingredient.linkedPantryItemId];

    return switch (_ingredientTypeFromName(ingredient.ingredientType)) {
      RecipeIngredientType.freeform => NutritionSnapshot.zero,
      RecipeIngredientType.pantryItem =>
        linkedPantryItem == null
            ? NutritionSnapshot.zero
            : () {
                final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
                  quantity: quantity,
                  ingredientUnit: ingredient.unit,
                  referenceUnit: linkedPantryItem.referenceUnit,
                  referenceUnitEquivalentQuantity:
                      linkedPantryItem.referenceUnitEquivalentQuantity,
                  referenceUnitEquivalentUnit:
                      linkedPantryItem.referenceUnitEquivalentUnit,
                  referenceUnitWeightGrams:
                      linkedPantryItem.referenceUnitWeightGrams,
                );
                if (!resolution.isResolved) {
                  return NutritionSnapshot.zero;
                }
                return _nutritionFromPantryItem(
                  linkedPantryItem,
                ).scale(resolution.referenceUnits!);
              }(),
      RecipeIngredientType.recipeReference =>
        ingredient.linkedRecipeId == null ||
                ingredient.linkedRecipeId == currentRecipeId
            ? NutritionSnapshot.zero
            : () {
                final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
                  quantity: quantity,
                  ingredientUnit: ingredient.unit,
                  referenceUnit: 'serving',
                );
                if (!resolution.isResolved) {
                  return NutritionSnapshot.zero;
                }
                return _resolveRecipeNutrition(
                  recipeId: ingredient.linkedRecipeId!,
                  recipesById: recipesById,
                  ingredientsByRecipeId: ingredientsByRecipeId,
                  pantryById: pantryById,
                  nutritionCache: nutritionCache,
                  trail: trail,
                ).scale(resolution.referenceUnits!);
              }(),
    };
  }

  NutritionSnapshot _nutritionFromRecipeRow(Recipe recipe) {
    return NutritionSnapshot(
      calories: recipe.calories,
      protein: recipe.protein,
      carbs: recipe.carbs,
      fat: recipe.fat,
      fiber: recipe.fiber,
      sodium: recipe.sodium,
      sugar: recipe.sugar,
    );
  }

  NutritionSnapshot _nutritionFromPantryItem(PantryItemsTableData pantryItem) {
    return NutritionSnapshot(
      calories: pantryItem.calories,
      protein: pantryItem.protein,
      carbs: pantryItem.carbs,
      fat: pantryItem.fat,
      fiber: pantryItem.fiber,
      sodium: pantryItem.sodium,
      sugar: pantryItem.sugar,
    );
  }

  String _referenceUnitSummary(
    String referenceUnit, {
    double? referenceUnitEquivalentQuantity,
    String? referenceUnitEquivalentUnit,
    double? referenceUnitWeightGrams,
  }) {
    return MeasurementUnits.describeReferenceUnit(
      referenceUnit: referenceUnit,
      referenceUnitEquivalentQuantity: referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: referenceUnitWeightGrams,
    );
  }

  RecipeIngredientType _ingredientTypeFromName(String value) {
    return RecipeIngredientType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => RecipeIngredientType.freeform,
    );
  }

  double? _parseLinkedQuantity(String rawQuantity) {
    return MeasurementUnits.parseQuantity(rawQuantity);
  }
}

class _SortableRecipeSummary {
  const _SortableRecipeSummary({
    required this.summary,
    required this.updatedAt,
  });

  final RecipeSummary summary;
  final DateTime updatedAt;
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
              id: item.id,
              name: item.title,
              quantityLabel: item.quantityLabel,
              referenceUnit: item.referenceUnit,
              referenceUnitEquivalentQuantity:
                  item.referenceUnitEquivalentQuantity,
              referenceUnitEquivalentUnit: item.referenceUnitEquivalentUnit,
              referenceUnitWeightGrams: item.referenceUnitWeightGrams,
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

  Future<void> savePantryItem(
    PantryItemDraft draft, {
    String? existingId,
  }) async {
    final itemId =
        existingId ?? 'pantry_${DateTime.now().microsecondsSinceEpoch}';
    final normalizedEquivalentQuantity = draft.referenceUnitEquivalentQuantity;
    final normalizedEquivalentUnit = draft.referenceUnitEquivalentUnit?.trim();
    final existingCreatedAt = existingId == null
        ? null
        : await (_database.select(_database.pantryItemsTable)
                ..where((table) => table.id.equals(existingId)))
              .map((row) => row.createdAt)
              .getSingleOrNull();

    await _database
        .into(_database.pantryItemsTable)
        .insertOnConflictUpdate(
          PantryItemsTableCompanion.insert(
            id: itemId,
            title: draft.name.trim(),
            quantityLabel: draft.quantityLabel.trim(),
            referenceUnit: Value(draft.referenceUnit.trim()),
            referenceUnitEquivalentQuantity: Value(
              normalizedEquivalentQuantity != null &&
                      normalizedEquivalentQuantity > 0
                  ? normalizedEquivalentQuantity
                  : null,
            ),
            referenceUnitEquivalentUnit: Value(
              normalizedEquivalentUnit != null &&
                      normalizedEquivalentUnit.isNotEmpty
                  ? normalizedEquivalentUnit
                  : null,
            ),
            referenceUnitWeightGrams: Value(
              draft.referenceUnitWeightGrams != null &&
                      draft.referenceUnitWeightGrams! > 0
                  ? draft.referenceUnitWeightGrams
                  : null,
            ),
            source: draft.source.trim(),
            accentHex: draft.accent.toARGB32(),
            barcode: const Value(null),
            brand: const Value(null),
            calories: draft.nutrition.calories,
            protein: draft.nutrition.protein,
            carbs: draft.nutrition.carbs,
            fat: draft.nutrition.fat,
            fiber: draft.nutrition.fiber,
            sodium: draft.nutrition.sodium,
            sugar: draft.nutrition.sugar,
            createdAt: existingCreatedAt ?? DateTime.now(),
          ),
        );
  }

  Future<void> deletePantryItem(String id) {
    return (_database.delete(
      _database.pantryItemsTable,
    )..where((table) => table.id.equals(id))).go();
  }
}

class GroceryRepository {
  GroceryRepository(this._database);

  final AppDatabase _database;
  static const _settingsSectionId = '__grocery_settings__';
  static const _generatedStateSectionId = '__grocery_generated_state__';
  static const _settingsSectionTitle = '__Grocery Settings__';
  static const _generatedStateSectionTitle = '__Generated Grocery State__';
  static const _settingPinnedRecipes = 'include_pinned_recipes';
  static const _settingSavedMeals = 'include_saved_meals';
  static const _manualDetailSeparator = '||';

  Stream<List<GrocerySection>> watchGrocerySections() {
    final recipesRepository = RecipesRepository(_database);
    final sectionsQuery = (_database.select(
      _database.grocerySectionsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();
    final itemsQuery = (_database.select(
      _database.groceryItemsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();
    final recipesQuery = _database.select(_database.recipes).watch();
    final recipeIngredientsQuery = _database
        .select(_database.recipeIngredients)
        .watch();
    final pantryQuery = _database.select(_database.pantryItemsTable).watch();
    final savedMealsQuery = _database.select(_database.savedMealsTable).watch();
    final savedMealComponentsQuery = _database
        .select(_database.savedMealComponents)
        .watch();

    return sectionsQuery
        .combineLatest(itemsQuery, (sections, items) => (sections, items))
        .combineLatest3(recipesQuery, recipeIngredientsQuery, (
          manualData,
          recipes,
          recipeIngredients,
        ) {
          return (manualData.$1, manualData.$2, recipes, recipeIngredients);
        })
        .combineLatest3(pantryQuery, savedMealsQuery, (
          combined,
          pantryItems,
          savedMeals,
        ) {
          return (
            combined.$1,
            combined.$2,
            combined.$3,
            combined.$4,
            pantryItems,
            savedMeals,
          );
        })
        .combineLatest(savedMealComponentsQuery, (
          combined,
          savedMealComponents,
        ) {
          final manualSections = combined.$1;
          final manualItems = combined.$2;
          final recipes = combined.$3;
          final recipeIngredients = combined.$4;
          final pantryItems = combined.$5;
          final savedMeals = combined.$6;
          final recipesById = {for (final recipe in recipes) recipe.id: recipe};
          final pantryById = {
            for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
          };
          final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
          for (final ingredient in recipeIngredients) {
            ingredientsByRecipeId
                .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
                .add(ingredient);
          }
          for (final ingredientList in ingredientsByRecipeId.values) {
            ingredientList.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final savedMealComponentsByMealId =
              <String, List<SavedMealComponent>>{};
          for (final component in savedMealComponents) {
            savedMealComponentsByMealId
                .putIfAbsent(component.mealId, () => <SavedMealComponent>[])
                .add(component);
          }
          for (final components in savedMealComponentsByMealId.values) {
            components.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }

          return (
            manualSections,
            manualItems,
            recipes,
            recipesRepository,
            recipesById,
            ingredientsByRecipeId,
            pantryById,
            savedMeals,
            savedMealComponentsByMealId,
          );
        })
        .map((combined) {
          final itemsBySectionId = <String, List<GroceryItemsTableData>>{};
          for (final item in combined.$2) {
            itemsBySectionId
                .putIfAbsent(item.sectionId, () => <GroceryItemsTableData>[])
                .add(item);
          }
          final settings = _settingsFromRows(
            itemsBySectionId[_settingsSectionId] ??
                const <GroceryItemsTableData>[],
          );
          final generatedStateByKey = _generatedStateFromRows(
            itemsBySectionId[_generatedStateSectionId] ??
                const <GroceryItemsTableData>[],
          );

          final exportSections =
              <GrocerySection>[
                    if (settings.includePinnedRecipes)
                      _buildPinnedRecipesSection(
                        recipesRepository: combined.$4,
                        recipes: combined.$3
                            .where((recipe) => recipe.isPinned)
                            .toList(),
                        recipesById: combined.$5,
                        ingredientsByRecipeId: combined.$6,
                        pantryById: combined.$7,
                        generatedStateByKey: generatedStateByKey,
                      ),
                    if (settings.includeSavedMeals)
                      _buildSavedMealsSection(
                        recipesRepository: combined.$4,
                        meals: combined.$8,
                        recipesById: combined.$5,
                        ingredientsByRecipeId: combined.$6,
                        pantryById: combined.$7,
                        componentsByMealId: combined.$9,
                        generatedStateByKey: generatedStateByKey,
                      ),
                  ]
                  .where((section) => section.items.isNotEmpty)
                  .toList(growable: false);

          final manualGrocerySections = combined.$1
              .where((section) => !_isHiddenSection(section.id))
              .map(
                (section) => GrocerySection(
                  title: section.title,
                  items:
                      (itemsBySectionId[section.id] ??
                              const <GroceryItemsTableData>[])
                          .map(
                            (item) => GroceryListItem(
                              key: 'manual:${item.id}',
                              label: _manualItemLabel(item.label),
                              detail: _manualItemDetail(item.label),
                              isChecked: item.isChecked,
                            ),
                          )
                          .toList(growable: false),
                ),
              )
              .where((section) => section.items.isNotEmpty)
              .toList(growable: false);

          return [...exportSections, ...manualGrocerySections];
        });
  }

  Stream<GroceryExportSettings> watchExportSettings() {
    final sectionsQuery = _database
        .select(_database.grocerySectionsTable)
        .watch();
    final itemsQuery = _database.select(_database.groceryItemsTable).watch();

    return sectionsQuery.combineLatest(itemsQuery, (sections, items) {
      final hasSettingsSection = sections.any(
        (section) => section.id == _settingsSectionId,
      );
      if (!hasSettingsSection) {
        return GroceryExportSettings.defaults;
      }

      final settingRows = items
          .where((item) => item.sectionId == _settingsSectionId)
          .toList(growable: false);
      return _settingsFromRows(settingRows);
    });
  }

  Future<void> setExportSettings(GroceryExportSettings settings) async {
    await _ensureHiddenSection(_settingsSectionId, _settingsSectionTitle);
    await (_database.delete(
      _database.groceryItemsTable,
    )..where((table) => table.sectionId.equals(_settingsSectionId))).go();
    await _database
        .into(_database.groceryItemsTable)
        .insert(
          GroceryItemsTableCompanion.insert(
            sectionId: _settingsSectionId,
            label: _settingPinnedRecipes,
            position: 0,
            isChecked: Value(settings.includePinnedRecipes),
          ),
        );
    await _database
        .into(_database.groceryItemsTable)
        .insert(
          GroceryItemsTableCompanion.insert(
            sectionId: _settingsSectionId,
            label: _settingSavedMeals,
            position: 1,
            isChecked: Value(settings.includeSavedMeals),
          ),
        );
  }

  Future<void> saveManualItem(GroceryManualItemDraft draft) async {
    final sectionTitle = draft.sectionTitle.trim();
    final normalizedSectionTitle = sectionTitle.isEmpty
        ? 'Quick Add'
        : sectionTitle;
    final sections = await (_database.select(
      _database.grocerySectionsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).get();
    final existingSection = sections
        .cast<GrocerySectionsTableData?>()
        .firstWhere(
          (section) =>
              section != null &&
              !_isHiddenSection(section.id) &&
              section?.title.toLowerCase() ==
                  normalizedSectionTitle.toLowerCase(),
          orElse: () => null,
        );
    final sectionId =
        existingSection?.id ??
        'grocery_section_${DateTime.now().microsecondsSinceEpoch}';
    if (existingSection == null) {
      await _database
          .into(_database.grocerySectionsTable)
          .insert(
            GrocerySectionsTableCompanion.insert(
              id: sectionId,
              title: normalizedSectionTitle,
              position: sections.length,
            ),
          );
    }

    final currentItems = await (_database.select(
      _database.groceryItemsTable,
    )..where((table) => table.sectionId.equals(sectionId))).get();
    await _database
        .into(_database.groceryItemsTable)
        .insert(
          GroceryItemsTableCompanion.insert(
            sectionId: sectionId,
            label: _encodeManualItemLabel(
              label: draft.label,
              quantity: draft.quantity,
              unit: draft.unit,
            ),
            position: currentItems.length,
          ),
        );
  }

  Future<void> deleteManualItem(int id) {
    return (_database.delete(
      _database.groceryItemsTable,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<void> toggleItemChecked(GroceryListItem item, bool isChecked) {
    if (item.isGenerated) {
      return _toggleGeneratedItemChecked(item, isChecked);
    }

    final manualId = int.tryParse(item.key.replaceFirst('manual:', ''));
    if (manualId == null) {
      return Future.value();
    }
    return (_database.update(_database.groceryItemsTable)
          ..where((table) => table.id.equals(manualId)))
        .write(GroceryItemsTableCompanion(isChecked: Value(isChecked)));
  }

  GrocerySection _buildPinnedRecipesSection({
    required RecipesRepository recipesRepository,
    required List<Recipe> recipes,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, bool> generatedStateByKey,
  }) {
    final aggregate = _GroceryAggregate();
    for (final recipe in recipes) {
      _appendRecipeIngredients(
        aggregate: aggregate,
        recipesRepository: recipesRepository,
        recipeId: recipe.id,
        recipeLabel: recipe.title,
        servingsScale: recipe.servings <= 0 ? 1 : recipe.servings.toDouble(),
        recipesById: recipesById,
        ingredientsByRecipeId: ingredientsByRecipeId,
        pantryById: pantryById,
        generatedStateByKey: generatedStateByKey,
      );
    }
    return GrocerySection(title: 'Pinned Recipes', items: aggregate.toList());
  }

  GrocerySection _buildSavedMealsSection({
    required RecipesRepository recipesRepository,
    required List<SavedMealsTableData> meals,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, List<SavedMealComponent>> componentsByMealId,
    required Map<String, bool> generatedStateByKey,
  }) {
    final aggregate = _GroceryAggregate();
    for (final meal in meals) {
      final mealComponents =
          componentsByMealId[meal.id] ?? const <SavedMealComponent>[];
      for (final component in mealComponents) {
        _appendSavedMealComponent(
          aggregate: aggregate,
          recipesRepository: recipesRepository,
          component: component,
          mealLabel: meal.title,
          recipesById: recipesById,
          ingredientsByRecipeId: ingredientsByRecipeId,
          pantryById: pantryById,
          generatedStateByKey: generatedStateByKey,
        );
      }
    }
    return GrocerySection(title: 'Saved Meals', items: aggregate.toList());
  }

  void _appendRecipeIngredients({
    required _GroceryAggregate aggregate,
    required RecipesRepository recipesRepository,
    required String recipeId,
    required String recipeLabel,
    required double servingsScale,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, bool> generatedStateByKey,
    Set<String> trail = const <String>{},
  }) {
    if (trail.contains(recipeId)) {
      return;
    }

    final recipe = recipesById[recipeId];
    if (recipe == null) {
      return;
    }
    final batchScale = recipe.servings <= 0
        ? servingsScale
        : servingsScale / recipe.servings;

    for (final ingredient
        in ingredientsByRecipeId[recipeId] ?? const <RecipeIngredient>[]) {
      _appendRecipeIngredient(
        aggregate: aggregate,
        recipesRepository: recipesRepository,
        ingredient: ingredient,
        sourceLabel: recipeLabel,
        batchScale: batchScale,
        recipesById: recipesById,
        ingredientsByRecipeId: ingredientsByRecipeId,
        pantryById: pantryById,
        generatedStateByKey: generatedStateByKey,
        trail: {...trail, recipeId},
      );
    }
  }

  void _appendRecipeIngredient({
    required _GroceryAggregate aggregate,
    required RecipesRepository recipesRepository,
    required RecipeIngredient ingredient,
    required String sourceLabel,
    required double batchScale,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, bool> generatedStateByKey,
    required Set<String> trail,
  }) {
    final quantity = recipesRepository._parseLinkedQuantity(
      ingredient.quantity,
    );
    final scaledQuantity = quantity == null || quantity <= 0
        ? null
        : quantity * batchScale;
    final ingredientType = recipesRepository._ingredientTypeFromName(
      ingredient.ingredientType,
    );

    switch (ingredientType) {
      case RecipeIngredientType.freeform:
        _addDirectContribution(
          aggregate: aggregate,
          label: ingredient.item.trim(),
          quantity: scaledQuantity,
          unit: ingredient.unit.trim(),
          rawQuantity: ingredient.quantity.trim(),
          sourceLabel: sourceLabel,
          isGenerated: true,
          checkedByKey: generatedStateByKey,
        );
        return;
      case RecipeIngredientType.pantryItem:
        final pantryItem = pantryById[ingredient.linkedPantryItemId];
        if (pantryItem == null) {
          _addDirectContribution(
            aggregate: aggregate,
            label: ingredient.item.trim(),
            quantity: scaledQuantity,
            unit: ingredient.unit.trim(),
            rawQuantity: ingredient.quantity.trim(),
            sourceLabel: sourceLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _addPantryContribution(
          aggregate: aggregate,
          pantryItem: pantryItem,
          quantity: scaledQuantity,
          ingredientUnit: ingredient.unit.trim(),
          rawQuantity: ingredient.quantity.trim(),
          sourceLabel: sourceLabel,
          generatedStateByKey: generatedStateByKey,
        );
        return;
      case RecipeIngredientType.recipeReference:
        if (ingredient.linkedRecipeId == null || scaledQuantity == null) {
          _addDirectContribution(
            aggregate: aggregate,
            label: ingredient.item.trim(),
            quantity: scaledQuantity,
            unit: ingredient.unit.trim(),
            rawQuantity: ingredient.quantity.trim(),
            sourceLabel: sourceLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
          quantity: scaledQuantity,
          ingredientUnit: ingredient.unit,
          referenceUnit: 'serving',
        );
        if (!resolution.isResolved) {
          _addDirectContribution(
            aggregate: aggregate,
            label: ingredient.item.trim(),
            quantity: scaledQuantity,
            unit: ingredient.unit.trim(),
            rawQuantity: ingredient.quantity.trim(),
            sourceLabel: sourceLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _appendRecipeIngredients(
          aggregate: aggregate,
          recipesRepository: recipesRepository,
          recipeId: ingredient.linkedRecipeId!,
          recipeLabel: sourceLabel,
          servingsScale: resolution.referenceUnits!,
          recipesById: recipesById,
          ingredientsByRecipeId: ingredientsByRecipeId,
          pantryById: pantryById,
          generatedStateByKey: generatedStateByKey,
          trail: trail,
        );
        return;
    }
  }

  void _appendSavedMealComponent({
    required _GroceryAggregate aggregate,
    required RecipesRepository recipesRepository,
    required SavedMealComponent component,
    required String mealLabel,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, bool> generatedStateByKey,
  }) {
    final quantity = recipesRepository._parseLinkedQuantity(component.quantity);
    final ingredientType = recipesRepository._ingredientTypeFromName(
      component.componentType,
    );

    switch (ingredientType) {
      case RecipeIngredientType.freeform:
        _addDirectContribution(
          aggregate: aggregate,
          label: component.item.trim(),
          quantity: quantity,
          unit: component.unit.trim(),
          rawQuantity: component.quantity.trim(),
          sourceLabel: mealLabel,
          isGenerated: true,
          checkedByKey: generatedStateByKey,
        );
        return;
      case RecipeIngredientType.pantryItem:
        final pantryItem = pantryById[component.linkedPantryItemId];
        if (pantryItem == null) {
          _addDirectContribution(
            aggregate: aggregate,
            label: component.item.trim(),
            quantity: quantity,
            unit: component.unit.trim(),
            rawQuantity: component.quantity.trim(),
            sourceLabel: mealLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _addPantryContribution(
          aggregate: aggregate,
          pantryItem: pantryItem,
          quantity: quantity,
          ingredientUnit: component.unit.trim(),
          rawQuantity: component.quantity.trim(),
          sourceLabel: mealLabel,
          generatedStateByKey: generatedStateByKey,
        );
        return;
      case RecipeIngredientType.recipeReference:
        if (component.linkedRecipeId == null ||
            quantity == null ||
            quantity <= 0) {
          _addDirectContribution(
            aggregate: aggregate,
            label: component.item.trim(),
            quantity: quantity,
            unit: component.unit.trim(),
            rawQuantity: component.quantity.trim(),
            sourceLabel: mealLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
          quantity: quantity,
          ingredientUnit: component.unit,
          referenceUnit: 'serving',
        );
        if (!resolution.isResolved) {
          _addDirectContribution(
            aggregate: aggregate,
            label: component.item.trim(),
            quantity: quantity,
            unit: component.unit.trim(),
            rawQuantity: component.quantity.trim(),
            sourceLabel: mealLabel,
            isGenerated: true,
            checkedByKey: generatedStateByKey,
          );
          return;
        }
        _appendRecipeIngredients(
          aggregate: aggregate,
          recipesRepository: recipesRepository,
          recipeId: component.linkedRecipeId!,
          recipeLabel: mealLabel,
          servingsScale: resolution.referenceUnits!,
          recipesById: recipesById,
          ingredientsByRecipeId: ingredientsByRecipeId,
          pantryById: pantryById,
          generatedStateByKey: generatedStateByKey,
        );
        return;
    }
  }

  void _addPantryContribution({
    required _GroceryAggregate aggregate,
    required PantryItemsTableData pantryItem,
    required double? quantity,
    required String ingredientUnit,
    required String rawQuantity,
    required String sourceLabel,
    required Map<String, bool> generatedStateByKey,
  }) {
    final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: quantity,
      ingredientUnit: ingredientUnit,
      referenceUnit: pantryItem.referenceUnit,
      referenceUnitEquivalentQuantity:
          pantryItem.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: pantryItem.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: pantryItem.referenceUnitWeightGrams,
    );
    if (!resolution.isResolved) {
      _addDirectContribution(
        aggregate: aggregate,
        label: pantryItem.title,
        quantity: quantity,
        unit: ingredientUnit,
        rawQuantity: rawQuantity,
        sourceLabel: sourceLabel,
        isGenerated: true,
        checkedByKey: generatedStateByKey,
      );
      return;
    }
    aggregate.add(
      _GroceryContribution(
        key: 'pantry:${pantryItem.id}',
        label: pantryItem.title,
        quantity: resolution.referenceUnits!,
        unit: pantryItem.referenceUnit,
        sourceLabel: sourceLabel,
        isGenerated: true,
        checkedByKey: generatedStateByKey,
      ),
    );
  }

  void _addDirectContribution({
    required _GroceryAggregate aggregate,
    required String label,
    required double? quantity,
    required String unit,
    required String rawQuantity,
    required String sourceLabel,
    required bool isGenerated,
    required Map<String, bool> checkedByKey,
  }) {
    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) {
      return;
    }
    aggregate.add(
      _GroceryContribution(
        key: 'label:${trimmedLabel.toLowerCase()}',
        label: trimmedLabel,
        quantity: quantity,
        unit: unit,
        rawQuantity: rawQuantity,
        sourceLabel: sourceLabel,
        isGenerated: isGenerated,
        checkedByKey: checkedByKey,
      ),
    );
  }

  Future<void> _toggleGeneratedItemChecked(
    GroceryListItem item,
    bool isChecked,
  ) async {
    await _ensureHiddenSection(
      _generatedStateSectionId,
      _generatedStateSectionTitle,
    );
    final existingRows =
        await (_database.select(_database.groceryItemsTable)..where(
              (table) =>
                  table.sectionId.equals(_generatedStateSectionId) &
                  table.label.equals(item.key),
            ))
            .get();
    if (existingRows.isNotEmpty) {
      await (_database.update(_database.groceryItemsTable)..where(
            (table) =>
                table.sectionId.equals(_generatedStateSectionId) &
                table.label.equals(item.key),
          ))
          .write(GroceryItemsTableCompanion(isChecked: Value(isChecked)));
      return;
    }

    final currentItems =
        await (_database.select(_database.groceryItemsTable)..where(
              (table) => table.sectionId.equals(_generatedStateSectionId),
            ))
            .get();
    await _database
        .into(_database.groceryItemsTable)
        .insert(
          GroceryItemsTableCompanion.insert(
            sectionId: _generatedStateSectionId,
            label: item.key,
            position: currentItems.length,
            isChecked: Value(isChecked),
          ),
        );
  }

  GroceryExportSettings _settingsFromRows(List<GroceryItemsTableData> rows) {
    var includePinnedRecipes =
        GroceryExportSettings.defaults.includePinnedRecipes;
    var includeSavedMeals = GroceryExportSettings.defaults.includeSavedMeals;
    for (final row in rows) {
      switch (row.label) {
        case _settingPinnedRecipes:
          includePinnedRecipes = row.isChecked;
          break;
        case _settingSavedMeals:
          includeSavedMeals = row.isChecked;
          break;
      }
    }
    return GroceryExportSettings(
      includePinnedRecipes: includePinnedRecipes,
      includeSavedMeals: includeSavedMeals,
    );
  }

  Map<String, bool> _generatedStateFromRows(List<GroceryItemsTableData> rows) {
    return {
      for (final row in rows)
        if (row.label.trim().isNotEmpty) row.label: row.isChecked,
    };
  }

  bool _isHiddenSection(String sectionId) {
    return sectionId == _settingsSectionId ||
        sectionId == _generatedStateSectionId;
  }

  String _encodeManualItemLabel({
    required String label,
    required String quantity,
    required String unit,
  }) {
    final normalizedLabel = label.trim();
    final detail = [
      if (quantity.trim().isNotEmpty) quantity.trim(),
      if (unit.trim().isNotEmpty) unit.trim(),
    ].join(' ').trim();
    if (detail.isEmpty) {
      return Uri.encodeComponent(normalizedLabel);
    }
    return '${Uri.encodeComponent(normalizedLabel)}$_manualDetailSeparator${Uri.encodeComponent(detail)}';
  }

  String _manualItemLabel(String encodedLabel) {
    final separatorIndex = encodedLabel.indexOf(_manualDetailSeparator);
    if (separatorIndex < 0) {
      return _decodeManualValue(encodedLabel.trim());
    }
    return _decodeManualValue(encodedLabel.substring(0, separatorIndex).trim());
  }

  String? _manualItemDetail(String encodedLabel) {
    final separatorIndex = encodedLabel.indexOf(_manualDetailSeparator);
    if (separatorIndex < 0) {
      return null;
    }
    final detail = encodedLabel
        .substring(separatorIndex + _manualDetailSeparator.length)
        .trim();
    if (detail.isEmpty) {
      return null;
    }
    return _decodeManualValue(detail);
  }

  String _decodeManualValue(String value) {
    try {
      return Uri.decodeComponent(value);
    } on FormatException {
      return value;
    }
  }

  Future<void> _ensureHiddenSection(String id, String title) async {
    final existing = await (_database.select(
      _database.grocerySectionsTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (existing != null) {
      return;
    }

    final sections = await (_database.select(
      _database.grocerySectionsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).get();
    await _database
        .into(_database.grocerySectionsTable)
        .insert(
          GrocerySectionsTableCompanion.insert(
            id: id,
            title: title,
            position: sections.length,
          ),
        );
  }
}

class FoodLogRepository {
  FoodLogRepository(this._database);

  final AppDatabase _database;

  Stream<FoodLogSnapshot> watchSnapshot() {
    final recipeRepository = RecipesRepository(_database);
    final goalsQuery = (_database.select(
      _database.dailyGoalsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.id)])).watch();
    final mealsQuery = (_database.select(
      _database.savedMealsTable,
    )..orderBy([(table) => OrderingTerm(expression: table.createdAt)])).watch();
    final adjustmentsQuery = (_database.select(
      _database.savedMealAdjustments,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();
    final componentsQuery = (_database.select(
      _database.savedMealComponents,
    )..orderBy([(table) => OrderingTerm(expression: table.position)])).watch();
    final recipeQuery = _database.select(_database.recipes).watch();
    final recipeIngredientsQuery = _database
        .select(_database.recipeIngredients)
        .watch();
    final pantryQuery = _database.select(_database.pantryItemsTable).watch();

    return goalsQuery
        .combineLatest3(mealsQuery, adjustmentsQuery, (
          goals,
          meals,
          adjustments,
        ) {
          return (goals, meals, adjustments);
        })
        .combineLatest3(componentsQuery, recipeQuery, (
          combined,
          components,
          recipes,
        ) {
          return (combined.$1, combined.$2, combined.$3, components, recipes);
        })
        .combineLatest(recipeIngredientsQuery, (combined, recipeIngredients) {
          return (
            combined.$1,
            combined.$2,
            combined.$3,
            combined.$4,
            combined.$5,
            recipeIngredients,
          );
        })
        .combineLatest(pantryQuery, (combined, pantryItems) {
          final goals = combined.$1;
          final meals = combined.$2;
          final adjustments = combined.$3;
          final components = combined.$4;
          final recipes = combined.$5;
          final recipeIngredients = combined.$6;
          final recipesById = {for (final recipe in recipes) recipe.id: recipe};
          final pantryById = {
            for (final pantryItem in pantryItems) pantryItem.id: pantryItem,
          };
          final ingredientsByRecipeId = <String, List<RecipeIngredient>>{};
          for (final ingredient in recipeIngredients) {
            ingredientsByRecipeId
                .putIfAbsent(ingredient.recipeId, () => <RecipeIngredient>[])
                .add(ingredient);
          }
          for (final ingredientList in ingredientsByRecipeId.values) {
            ingredientList.sort(
              (left, right) => left.position.compareTo(right.position),
            );
          }
          final adjustmentsByMealId = <String, List<SavedMealAdjustment>>{};
          for (final adjustment in adjustments) {
            adjustmentsByMealId
                .putIfAbsent(adjustment.mealId, () => <SavedMealAdjustment>[])
                .add(adjustment);
          }
          final componentsByMealId = <String, List<SavedMealComponent>>{};
          for (final component in components) {
            componentsByMealId
                .putIfAbsent(component.mealId, () => <SavedMealComponent>[])
                .add(component);
          }
          final nutritionCache = <String, NutritionSnapshot>{};

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
                .map((meal) {
                  final manualNutrition = _nutritionFromSavedMealRow(meal);
                  final mealComponents =
                      componentsByMealId[meal.id] ??
                      const <SavedMealComponent>[];
                  final linkedNutrition = mealComponents
                      .map(
                        (component) => _resolveSavedMealComponentNutrition(
                          component: component,
                          recipeRepository: recipeRepository,
                          recipesById: recipesById,
                          ingredientsByRecipeId: ingredientsByRecipeId,
                          pantryById: pantryById,
                          nutritionCache: nutritionCache,
                        ),
                      )
                      .fold(
                        NutritionSnapshot.zero,
                        (total, item) => total + item,
                      );
                  return SavedMeal(
                    id: meal.id,
                    name: meal.title,
                    nutrition: manualNutrition + linkedNutrition,
                    manualNutrition: manualNutrition,
                    adjustments:
                        (adjustmentsByMealId[meal.id] ??
                                const <SavedMealAdjustment>[])
                            .map((adjustment) => adjustment.label)
                            .toList(growable: false),
                    components: mealComponents
                        .map(
                          (component) => SavedMealComponentDraft(
                            quantity: component.quantity,
                            unit: component.unit,
                            item: component.item,
                            linkType: recipeRepository._ingredientTypeFromName(
                              component.componentType,
                            ),
                            linkedPantryItemId: component.linkedPantryItemId,
                            linkedRecipeId: component.linkedRecipeId,
                          ),
                        )
                        .toList(growable: false),
                  );
                })
                .toList(growable: false),
          );
        });
  }

  Future<SavedMealDraft> getSavedMealDraft(String id) async {
    final meal = await (_database.select(
      _database.savedMealsTable,
    )..where((table) => table.id.equals(id))).getSingle();
    final adjustments =
        await (_database.select(
            _database.savedMealAdjustments,
          )..where((table) => table.mealId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));
    final components =
        await (_database.select(
            _database.savedMealComponents,
          )..where((table) => table.mealId.equals(id))).get()
          ..sort((left, right) => left.position.compareTo(right.position));
    final recipeRepository = RecipesRepository(_database);

    return SavedMealDraft(
      name: meal.title,
      manualNutrition: _nutritionFromSavedMealRow(meal),
      adjustments: adjustments.map((adjustment) => adjustment.label).toList(),
      components: components
          .map(
            (component) => SavedMealComponentDraft(
              quantity: component.quantity,
              unit: component.unit,
              item: component.item,
              linkType: recipeRepository._ingredientTypeFromName(
                component.componentType,
              ),
              linkedPantryItemId: component.linkedPantryItemId,
              linkedRecipeId: component.linkedRecipeId,
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> saveSavedMeal(SavedMealDraft draft, {String? existingId}) async {
    final mealId =
        existingId ?? 'saved_meal_${DateTime.now().microsecondsSinceEpoch}';
    final existingCreatedAt = existingId == null
        ? null
        : await (_database.select(_database.savedMealsTable)
                ..where((table) => table.id.equals(existingId)))
              .map((row) => row.createdAt)
              .getSingleOrNull();

    await _database.transaction(() async {
      await _database
          .into(_database.savedMealsTable)
          .insertOnConflictUpdate(
            SavedMealsTableCompanion.insert(
              id: mealId,
              title: draft.name.trim(),
              calories: draft.manualNutrition.calories,
              protein: draft.manualNutrition.protein,
              carbs: draft.manualNutrition.carbs,
              fat: draft.manualNutrition.fat,
              fiber: draft.manualNutrition.fiber,
              sodium: draft.manualNutrition.sodium,
              sugar: draft.manualNutrition.sugar,
              createdAt: existingCreatedAt ?? DateTime.now(),
            ),
          );

      await (_database.delete(
        _database.savedMealAdjustments,
      )..where((table) => table.mealId.equals(mealId))).go();
      await (_database.delete(
        _database.savedMealComponents,
      )..where((table) => table.mealId.equals(mealId))).go();

      for (var index = 0; index < draft.adjustments.length; index++) {
        final adjustment = draft.adjustments[index].trim();
        if (adjustment.isEmpty) {
          continue;
        }
        await _database
            .into(_database.savedMealAdjustments)
            .insert(
              SavedMealAdjustmentsCompanion.insert(
                mealId: mealId,
                label: adjustment,
                position: index,
              ),
            );
      }

      for (var index = 0; index < draft.components.length; index++) {
        final component = draft.components[index];
        await _database
            .into(_database.savedMealComponents)
            .insert(
              SavedMealComponentsCompanion.insert(
                mealId: mealId,
                position: index,
                quantity: component.quantity.trim(),
                unit: component.unit.trim(),
                item: component.item.trim(),
                componentType: Value(component.linkType.name),
                linkedPantryItemId: Value(component.linkedPantryItemId),
                linkedRecipeId: Value(component.linkedRecipeId),
              ),
            );
      }
    });
  }

  Future<void> deleteSavedMeal(String id) {
    return (_database.delete(
      _database.savedMealsTable,
    )..where((table) => table.id.equals(id))).go();
  }

  NutritionSnapshot _nutritionFromSavedMealRow(SavedMealsTableData meal) {
    return NutritionSnapshot(
      calories: meal.calories,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      fiber: meal.fiber,
      sodium: meal.sodium,
      sugar: meal.sugar,
    );
  }

  NutritionSnapshot _resolveSavedMealComponentNutrition({
    required SavedMealComponent component,
    required RecipesRepository recipeRepository,
    required Map<String, Recipe> recipesById,
    required Map<String, List<RecipeIngredient>> ingredientsByRecipeId,
    required Map<String, PantryItemsTableData> pantryById,
    required Map<String, NutritionSnapshot> nutritionCache,
  }) {
    final quantity = recipeRepository._parseLinkedQuantity(component.quantity);
    final ingredientType = recipeRepository._ingredientTypeFromName(
      component.componentType,
    );
    final linkedPantryItem = pantryById[component.linkedPantryItemId];

    return switch (ingredientType) {
      RecipeIngredientType.freeform => NutritionSnapshot.zero,
      RecipeIngredientType.pantryItem =>
        linkedPantryItem == null
            ? NutritionSnapshot.zero
            : () {
                final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
                  quantity: quantity,
                  ingredientUnit: component.unit,
                  referenceUnit: linkedPantryItem.referenceUnit,
                  referenceUnitEquivalentQuantity:
                      linkedPantryItem.referenceUnitEquivalentQuantity,
                  referenceUnitEquivalentUnit:
                      linkedPantryItem.referenceUnitEquivalentUnit,
                  referenceUnitWeightGrams:
                      linkedPantryItem.referenceUnitWeightGrams,
                );
                if (!resolution.isResolved) {
                  return NutritionSnapshot.zero;
                }
                return recipeRepository
                    ._nutritionFromPantryItem(linkedPantryItem)
                    .scale(resolution.referenceUnits!);
              }(),
      RecipeIngredientType.recipeReference =>
        component.linkedRecipeId == null
            ? NutritionSnapshot.zero
            : () {
                final resolution = MeasurementUnits.resolveLinkedReferenceUnits(
                  quantity: quantity,
                  ingredientUnit: component.unit,
                  referenceUnit: 'serving',
                );
                if (!resolution.isResolved) {
                  return NutritionSnapshot.zero;
                }
                return recipeRepository
                    ._resolveRecipeNutrition(
                      recipeId: component.linkedRecipeId!,
                      recipesById: recipesById,
                      ingredientsByRecipeId: ingredientsByRecipeId,
                      pantryById: pantryById,
                      nutritionCache: nutritionCache,
                    )
                    .scale(resolution.referenceUnits!);
              }(),
    };
  }
}

class _GroceryContribution {
  const _GroceryContribution({
    required this.key,
    required this.label,
    required this.sourceLabel,
    required this.isGenerated,
    required this.checkedByKey,
    this.quantity,
    this.unit = '',
    this.rawQuantity = '',
  });

  final String key;
  final String label;
  final double? quantity;
  final String unit;
  final String rawQuantity;
  final String sourceLabel;
  final bool isGenerated;
  final Map<String, bool> checkedByKey;
}

class _GroceryAggregate {
  final _buckets = <String, List<_AggregatedGroceryItem>>{};

  void add(_GroceryContribution contribution) {
    final buckets = _buckets.putIfAbsent(
      contribution.key,
      () => <_AggregatedGroceryItem>[],
    );
    for (final bucket in buckets) {
      if (bucket.tryAdd(contribution)) {
        return;
      }
    }
    buckets.add(_AggregatedGroceryItem.fromContribution(contribution));
  }

  List<GroceryListItem> toList() {
    final items = _buckets.values
        .expand((bucketList) => bucketList)
        .map((bucket) => bucket.toItem())
        .toList(growable: true);
    items.sort((left, right) => left.label.compareTo(right.label));
    return items;
  }
}

class _AggregatedGroceryItem {
  _AggregatedGroceryItem({
    required this.label,
    required this.key,
    required this.isGenerated,
    required this.isChecked,
    required this.quantity,
    required this.unit,
    required this.rawQuantity,
    required Set<String> sources,
  }) : _sources = sources;

  factory _AggregatedGroceryItem.fromContribution(
    _GroceryContribution contribution,
  ) {
    return _AggregatedGroceryItem(
      label: contribution.label,
      key: _stableItemKey(contribution),
      isGenerated: contribution.isGenerated,
      isChecked:
          contribution.checkedByKey[_stableItemKey(contribution)] ?? false,
      quantity: contribution.quantity,
      unit: contribution.unit.trim(),
      rawQuantity: contribution.rawQuantity.trim(),
      sources: {contribution.sourceLabel},
    );
  }

  final String label;
  final String key;
  final bool isGenerated;
  final bool isChecked;
  double? quantity;
  final String unit;
  final String rawQuantity;
  final Set<String> _sources;

  bool tryAdd(_GroceryContribution contribution) {
    if (label != contribution.label) {
      return false;
    }
    final currentUnit = unit.trim();
    final incomingUnit = contribution.unit.trim();

    if (quantity != null && contribution.quantity != null) {
      final converted = MeasurementUnits.tryConvertQuantity(
        quantity: contribution.quantity!,
        fromUnit: incomingUnit,
        toUnit: currentUnit,
      );
      if (converted != null) {
        quantity = quantity! + converted;
        _sources.add(contribution.sourceLabel);
        return true;
      }
    }

    final mergedTextOnly =
        quantity == null &&
        contribution.quantity == null &&
        currentUnit == incomingUnit &&
        rawQuantity == contribution.rawQuantity.trim();
    if (mergedTextOnly) {
      _sources.add(contribution.sourceLabel);
      return true;
    }

    return false;
  }

  GroceryListItem toItem() {
    final detail = () {
      if (quantity != null) {
        final parts = [
          MeasurementUnits.formatDecimal(quantity!),
          if (unit.trim().isNotEmpty) unit.trim(),
        ];
        return parts.join(' ');
      }

      final parts = [
        if (rawQuantity.isNotEmpty) rawQuantity,
        if (unit.trim().isNotEmpty) unit.trim(),
      ];
      final text = parts.join(' ').trim();
      return text.isEmpty ? null : text;
    }();

    final sortedSources = _sources.toList()..sort();
    return GroceryListItem(
      key: key,
      label: label,
      detail: detail,
      sourceSummary: sortedSources.join(', '),
      isChecked: isChecked,
      isGenerated: isGenerated,
    );
  }

  static String _stableItemKey(_GroceryContribution contribution) {
    final normalizedUnit = contribution.unit.trim().toLowerCase();
    if (contribution.quantity != null) {
      return '${contribution.key}|unit:$normalizedUnit';
    }
    return '${contribution.key}|raw:${contribution.rawQuantity.trim().toLowerCase()}|unit:$normalizedUnit';
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
