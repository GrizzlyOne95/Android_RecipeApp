import 'package:flutter/material.dart';

class NutritionSnapshot {
  const NutritionSnapshot({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sodium,
    required this.sugar,
  });

  static const zero = NutritionSnapshot(
    calories: 0,
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    sodium: 0,
    sugar: 0,
  );

  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int sodium;
  final int sugar;

  NutritionSnapshot copyWith({
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
    int? sodium,
    int? sugar,
  }) {
    return NutritionSnapshot(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      sugar: sugar ?? this.sugar,
    );
  }

  NutritionSnapshot operator +(NutritionSnapshot other) {
    return NutritionSnapshot(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: fiber + other.fiber,
      sodium: sodium + other.sodium,
      sugar: sugar + other.sugar,
    );
  }

  NutritionSnapshot scale(double factor) {
    int scaleValue(int value) => (value * factor).round();

    return NutritionSnapshot(
      calories: scaleValue(calories),
      protein: scaleValue(protein),
      carbs: scaleValue(carbs),
      fat: scaleValue(fat),
      fiber: scaleValue(fiber),
      sodium: scaleValue(sodium),
      sugar: scaleValue(sugar),
    );
  }

  NutritionSnapshot divide(int divisor) {
    if (divisor <= 0) {
      return this;
    }

    int divideValue(int value) => (value / divisor).round();

    return NutritionSnapshot(
      calories: divideValue(calories),
      protein: divideValue(protein),
      carbs: divideValue(carbs),
      fat: divideValue(fat),
      fiber: divideValue(fiber),
      sodium: divideValue(sodium),
      sugar: divideValue(sugar),
    );
  }

  bool get isZero =>
      calories == 0 &&
      protein == 0 &&
      carbs == 0 &&
      fat == 0 &&
      fiber == 0 &&
      sodium == 0 &&
      sugar == 0;
}

enum RecipeSortOrder { caloriesLowToHigh, caloriesHighToLow }

class RecipeSummary {
  const RecipeSummary({
    required this.id,
    required this.name,
    required this.versionLabel,
    required this.servings,
    required this.nutrition,
    required this.tags,
    required this.note,
    required this.isPinned,
    required this.sortCalories,
    required this.ingredientCount,
    required this.directionCount,
  });

  final String id;
  final String name;
  final String versionLabel;
  final int servings;
  final NutritionSnapshot nutrition;
  final List<String> tags;
  final String note;
  final bool isPinned;
  final int sortCalories;
  final int ingredientCount;
  final int directionCount;
}

enum RecipeIngredientType { freeform, pantryItem, recipeReference }

class RecipeIngredientDraft {
  const RecipeIngredientDraft({
    required this.quantity,
    required this.unit,
    required this.item,
    required this.preparation,
    this.linkType = RecipeIngredientType.freeform,
    this.linkedPantryItemId,
    this.linkedRecipeId,
  });

  final String quantity;
  final String unit;
  final String item;
  final String preparation;
  final RecipeIngredientType linkType;
  final String? linkedPantryItemId;
  final String? linkedRecipeId;

  String? get linkedTargetId => switch (linkType) {
    RecipeIngredientType.freeform => null,
    RecipeIngredientType.pantryItem => linkedPantryItemId,
    RecipeIngredientType.recipeReference => linkedRecipeId,
  };

  RecipeIngredientDraft copyWith({
    String? quantity,
    String? unit,
    String? item,
    String? preparation,
    RecipeIngredientType? linkType,
    String? linkedPantryItemId,
    String? linkedRecipeId,
  }) {
    return RecipeIngredientDraft(
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      item: item ?? this.item,
      preparation: preparation ?? this.preparation,
      linkType: linkType ?? this.linkType,
      linkedPantryItemId: linkedPantryItemId ?? this.linkedPantryItemId,
      linkedRecipeId: linkedRecipeId ?? this.linkedRecipeId,
    );
  }
}

class IngredientLinkTarget {
  const IngredientLinkTarget({
    required this.id,
    required this.type,
    required this.title,
    required this.referenceUnit,
    this.referenceUnitQuantity = 1,
    required this.nutrition,
    this.referenceUnitEquivalentQuantity,
    this.referenceUnitEquivalentUnit,
    this.referenceUnitWeightGrams,
    this.subtitle = '',
  });

  final String id;
  final RecipeIngredientType type;
  final String title;
  final String referenceUnit;
  final double referenceUnitQuantity;
  final NutritionSnapshot nutrition;
  final double? referenceUnitEquivalentQuantity;
  final String? referenceUnitEquivalentUnit;
  final double? referenceUnitWeightGrams;
  final String subtitle;
}

class ResolvedRecipeIngredient {
  const ResolvedRecipeIngredient({
    required this.draft,
    required this.linkTitle,
    required this.linkSubtitle,
    required this.batchNutrition,
  });

  final RecipeIngredientDraft draft;
  final String? linkTitle;
  final String linkSubtitle;
  final NutritionSnapshot batchNutrition;
}

class RecipeDraft {
  const RecipeDraft({
    required this.name,
    required this.versionLabel,
    required this.servings,
    required this.note,
    required this.tags,
    required this.isPinned,
    required this.nutrition,
    required this.ingredients,
    required this.directions,
  });

  final String name;
  final String versionLabel;
  final int servings;
  final String note;
  final List<String> tags;
  final bool isPinned;
  final NutritionSnapshot nutrition;
  final List<RecipeIngredientDraft> ingredients;
  final List<String> directions;

  RecipeDraft copyWith({
    String? name,
    String? versionLabel,
    int? servings,
    String? note,
    List<String>? tags,
    bool? isPinned,
    NutritionSnapshot? nutrition,
    List<RecipeIngredientDraft>? ingredients,
    List<String>? directions,
  }) {
    return RecipeDraft(
      name: name ?? this.name,
      versionLabel: versionLabel ?? this.versionLabel,
      servings: servings ?? this.servings,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      nutrition: nutrition ?? this.nutrition,
      ingredients: ingredients ?? this.ingredients,
      directions: directions ?? this.directions,
    );
  }
}

class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.quantityLabel,
    required this.referenceUnit,
    this.referenceUnitQuantity = 1,
    required this.source,
    required this.nutrition,
    required this.accent,
    this.barcode,
    this.brand,
    this.imageUrl,
    this.referenceUnitEquivalentQuantity,
    this.referenceUnitEquivalentUnit,
    this.referenceUnitWeightGrams,
  });

  final String id;
  final String name;
  final String quantityLabel;
  final String referenceUnit;
  final double referenceUnitQuantity;
  final String source;
  final NutritionSnapshot nutrition;
  final Color accent;
  final String? barcode;
  final String? brand;
  final String? imageUrl;
  final double? referenceUnitEquivalentQuantity;
  final String? referenceUnitEquivalentUnit;
  final double? referenceUnitWeightGrams;

  PantryItemDraft toDraft() {
    return PantryItemDraft(
      name: name,
      quantityLabel: quantityLabel,
      referenceUnit: referenceUnit,
      referenceUnitQuantity: referenceUnitQuantity,
      source: source,
      nutrition: nutrition,
      accent: accent,
      barcode: barcode,
      brand: brand,
      imageUrl: imageUrl,
      referenceUnitEquivalentQuantity: referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: referenceUnitWeightGrams,
    );
  }
}

class PantryItemDraft {
  const PantryItemDraft({
    required this.name,
    required this.quantityLabel,
    required this.referenceUnit,
    this.referenceUnitQuantity = 1,
    required this.source,
    required this.nutrition,
    required this.accent,
    this.barcode,
    this.brand,
    this.imageUrl,
    this.referenceUnitEquivalentQuantity,
    this.referenceUnitEquivalentUnit,
    this.referenceUnitWeightGrams,
  });

  final String name;
  final String quantityLabel;
  final String referenceUnit;
  final double referenceUnitQuantity;
  final String source;
  final NutritionSnapshot nutrition;
  final Color accent;
  final String? barcode;
  final String? brand;
  final String? imageUrl;
  final double? referenceUnitEquivalentQuantity;
  final String? referenceUnitEquivalentUnit;
  final double? referenceUnitWeightGrams;

  PantryItemDraft copyWith({
    String? name,
    String? quantityLabel,
    String? referenceUnit,
    double? referenceUnitQuantity,
    String? source,
    NutritionSnapshot? nutrition,
    Color? accent,
    String? barcode,
    String? brand,
    String? imageUrl,
    double? referenceUnitEquivalentQuantity,
    String? referenceUnitEquivalentUnit,
    double? referenceUnitWeightGrams,
  }) {
    return PantryItemDraft(
      name: name ?? this.name,
      quantityLabel: quantityLabel ?? this.quantityLabel,
      referenceUnit: referenceUnit ?? this.referenceUnit,
      referenceUnitQuantity:
          referenceUnitQuantity ?? this.referenceUnitQuantity,
      source: source ?? this.source,
      nutrition: nutrition ?? this.nutrition,
      accent: accent ?? this.accent,
      barcode: barcode ?? this.barcode,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      referenceUnitEquivalentQuantity:
          referenceUnitEquivalentQuantity ??
          this.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit:
          referenceUnitEquivalentUnit ?? this.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams:
          referenceUnitWeightGrams ?? this.referenceUnitWeightGrams,
    );
  }
}

class GroceryListItem {
  const GroceryListItem({
    required this.key,
    required this.label,
    this.detail,
    this.sourceSummary,
    this.isChecked = false,
    this.isGenerated = false,
  });

  final String key;
  final String label;
  final String? detail;
  final String? sourceSummary;
  final bool isChecked;
  final bool isGenerated;
}

class GrocerySection {
  const GrocerySection({required this.title, required this.items});

  final String title;
  final List<GroceryListItem> items;
}

class GroceryExportSettings {
  const GroceryExportSettings({
    required this.includePinnedRecipes,
    required this.includeSavedMeals,
    required this.includeDayPlans,
    required this.includeMealPlans,
  });

  static const defaults = GroceryExportSettings(
    includePinnedRecipes: true,
    includeSavedMeals: true,
    includeDayPlans: true,
    includeMealPlans: true,
  );

  final bool includePinnedRecipes;
  final bool includeSavedMeals;
  final bool includeDayPlans;
  final bool includeMealPlans;

  GroceryExportSettings copyWith({
    bool? includePinnedRecipes,
    bool? includeSavedMeals,
    bool? includeDayPlans,
    bool? includeMealPlans,
  }) {
    return GroceryExportSettings(
      includePinnedRecipes: includePinnedRecipes ?? this.includePinnedRecipes,
      includeSavedMeals: includeSavedMeals ?? this.includeSavedMeals,
      includeDayPlans: includeDayPlans ?? this.includeDayPlans,
      includeMealPlans: includeMealPlans ?? this.includeMealPlans,
    );
  }
}

class GroceryManualItemDraft {
  const GroceryManualItemDraft({
    required this.sectionTitle,
    required this.label,
    required this.quantity,
    required this.unit,
  });

  final String sectionTitle;
  final String label;
  final String quantity;
  final String unit;
}

class SavedMealComponentDraft {
  const SavedMealComponentDraft({
    required this.quantity,
    required this.unit,
    required this.item,
    this.linkType = RecipeIngredientType.freeform,
    this.linkedPantryItemId,
    this.linkedRecipeId,
  });

  final String quantity;
  final String unit;
  final String item;
  final RecipeIngredientType linkType;
  final String? linkedPantryItemId;
  final String? linkedRecipeId;

  String? get linkedTargetId => switch (linkType) {
    RecipeIngredientType.freeform => null,
    RecipeIngredientType.pantryItem => linkedPantryItemId,
    RecipeIngredientType.recipeReference => linkedRecipeId,
  };

  SavedMealComponentDraft copyWith({
    String? quantity,
    String? unit,
    String? item,
    RecipeIngredientType? linkType,
    String? linkedPantryItemId,
    String? linkedRecipeId,
  }) {
    return SavedMealComponentDraft(
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      item: item ?? this.item,
      linkType: linkType ?? this.linkType,
      linkedPantryItemId: linkedPantryItemId ?? this.linkedPantryItemId,
      linkedRecipeId: linkedRecipeId ?? this.linkedRecipeId,
    );
  }
}

class ResolvedSavedMealComponent {
  const ResolvedSavedMealComponent({
    required this.draft,
    required this.linkTitle,
    required this.linkSubtitle,
    required this.nutrition,
  });

  final SavedMealComponentDraft draft;
  final String? linkTitle;
  final String linkSubtitle;
  final NutritionSnapshot nutrition;
}

class SavedMeal {
  const SavedMeal({
    required this.id,
    required this.name,
    required this.nutrition,
    required this.manualNutrition,
    required this.adjustments,
    required this.components,
  });

  final String id;
  final String name;
  final NutritionSnapshot nutrition;
  final NutritionSnapshot manualNutrition;
  final List<String> adjustments;
  final List<SavedMealComponentDraft> components;

  SavedMealDraft toDraft() {
    return SavedMealDraft(
      name: name,
      manualNutrition: manualNutrition,
      adjustments: adjustments,
      components: components,
    );
  }
}

class SavedMealDraft {
  const SavedMealDraft({
    required this.name,
    required this.manualNutrition,
    required this.adjustments,
    required this.components,
  });

  final String name;
  final NutritionSnapshot manualNutrition;
  final List<String> adjustments;
  final List<SavedMealComponentDraft> components;

  SavedMealDraft copyWith({
    String? name,
    NutritionSnapshot? manualNutrition,
    List<String>? adjustments,
    List<SavedMealComponentDraft>? components,
  }) {
    return SavedMealDraft(
      name: name ?? this.name,
      manualNutrition: manualNutrition ?? this.manualNutrition,
      adjustments: adjustments ?? this.adjustments,
      components: components ?? this.components,
    );
  }
}

enum FoodLogEntrySourceType { savedMeal, recipe, pantryItem }

enum FoodLogMealSlot { breakfast, lunch, dinner, snack }

class FoodLogEntryTarget {
  const FoodLogEntryTarget({
    required this.id,
    required this.sourceType,
    required this.title,
    required this.referenceUnit,
    this.referenceUnitQuantity = 1,
    required this.nutrition,
    this.referenceUnitEquivalentQuantity,
    this.referenceUnitEquivalentUnit,
    this.referenceUnitWeightGrams,
    this.subtitle = '',
  });

  final String id;
  final FoodLogEntrySourceType sourceType;
  final String title;
  final String referenceUnit;
  final double referenceUnitQuantity;
  final NutritionSnapshot nutrition;
  final double? referenceUnitEquivalentQuantity;
  final String? referenceUnitEquivalentUnit;
  final double? referenceUnitWeightGrams;
  final String subtitle;
}

class FoodLogEntryDraft {
  const FoodLogEntryDraft({
    required this.date,
    required this.mealSlot,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.nutrition,
  });

  final DateTime date;
  final FoodLogMealSlot mealSlot;
  final FoodLogEntrySourceType sourceType;
  final String sourceId;
  final String title;
  final String quantity;
  final String unit;
  final NutritionSnapshot nutrition;
}

class FoodLogEntry {
  const FoodLogEntry({
    required this.id,
    required this.date,
    required this.mealSlot,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.nutrition,
  });

  final String id;
  final DateTime date;
  final FoodLogMealSlot mealSlot;
  final FoodLogEntrySourceType sourceType;
  final String sourceId;
  final String title;
  final String quantity;
  final String unit;
  final NutritionSnapshot nutrition;
}

class DailyGoal {
  const DailyGoal({
    required this.label,
    required this.consumed,
    required this.target,
  });

  final String label;
  final int consumed;
  final int target;
}

class FoodLogSnapshot {
  const FoodLogSnapshot({
    required this.goals,
    required this.savedMeals,
    required this.dayPlans,
    required this.mealPlans,
    required this.entries,
  });

  final List<DailyGoal> goals;
  final List<SavedMeal> savedMeals;
  final List<DayPlan> dayPlans;
  final List<MealPlan> mealPlans;
  final List<FoodLogEntry> entries;
}

class FoodLogSuggestion {
  const FoodLogSuggestion({
    required this.target,
    required this.recommendedMealSlot,
    required this.reason,
    required this.score,
  });

  final FoodLogEntryTarget target;
  final FoodLogMealSlot recommendedMealSlot;
  final String reason;
  final double score;
}

class DayPlanEntryDraft {
  const DayPlanEntryDraft({
    required this.mealSlot,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.nutrition,
  });

  final FoodLogMealSlot mealSlot;
  final FoodLogEntrySourceType sourceType;
  final String sourceId;
  final String title;
  final String quantity;
  final String unit;
  final NutritionSnapshot nutrition;
}

class DayPlanDraft {
  const DayPlanDraft({
    required this.name,
    this.note = '',
    required this.entries,
  });

  final String name;
  final String note;
  final List<DayPlanEntryDraft> entries;

  DayPlanDraft copyWith({
    String? name,
    String? note,
    List<DayPlanEntryDraft>? entries,
  }) {
    return DayPlanDraft(
      name: name ?? this.name,
      note: note ?? this.note,
      entries: entries ?? this.entries,
    );
  }
}

class DayPlan {
  const DayPlan({
    required this.id,
    required this.name,
    required this.note,
    required this.entries,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String note;
  final List<DayPlanEntryDraft> entries;
  final DateTime createdAt;

  NutritionSnapshot get nutrition => entries.fold(
    NutritionSnapshot.zero,
    (total, entry) => total + entry.nutrition,
  );

  DayPlanDraft toDraft() {
    return DayPlanDraft(name: name, note: note, entries: entries);
  }
}

enum MealPlanDaySlot {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class MealPlanEntryDraft {
  const MealPlanEntryDraft({
    required this.daySlot,
    required this.mealSlot,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.nutrition,
  });

  final MealPlanDaySlot daySlot;
  final FoodLogMealSlot mealSlot;
  final FoodLogEntrySourceType sourceType;
  final String sourceId;
  final String title;
  final String quantity;
  final String unit;
  final NutritionSnapshot nutrition;
}

class MealPlanDraft {
  const MealPlanDraft({
    required this.name,
    this.note = '',
    this.folderLabel,
    this.isPinned = false,
    required this.entries,
  });

  final String name;
  final String note;
  final String? folderLabel;
  final bool isPinned;
  final List<MealPlanEntryDraft> entries;

  MealPlanDraft copyWith({
    String? name,
    String? note,
    String? folderLabel,
    bool? isPinned,
    List<MealPlanEntryDraft>? entries,
  }) {
    return MealPlanDraft(
      name: name ?? this.name,
      note: note ?? this.note,
      folderLabel: folderLabel ?? this.folderLabel,
      isPinned: isPinned ?? this.isPinned,
      entries: entries ?? this.entries,
    );
  }
}

class MealPlan {
  const MealPlan({
    required this.id,
    required this.name,
    required this.note,
    this.folderLabel,
    required this.isPinned,
    required this.entries,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String note;
  final String? folderLabel;
  final bool isPinned;
  final List<MealPlanEntryDraft> entries;
  final DateTime createdAt;

  NutritionSnapshot get nutrition => entries.fold(
    NutritionSnapshot.zero,
    (total, entry) => total + entry.nutrition,
  );

  int get scheduledDayCount =>
      entries.map((entry) => entry.daySlot).toSet().length;

  String get folderDisplayLabel {
    final trimmed = folderLabel?.trim() ?? '';
    return trimmed.isEmpty ? 'Loose Plans' : trimmed;
  }

  MealPlanDraft toDraft() {
    return MealPlanDraft(
      name: name,
      note: note,
      folderLabel: folderLabel,
      isPinned: isPinned,
      entries: entries,
    );
  }
}

abstract final class SeedData {
  static final todayDate = DateTime(2026, 3, 13);
  static const todayLabel = 'Friday, March 13';

  static const recipes = <RecipeSummary>[
    RecipeSummary(
      id: 'recipe_0',
      name: 'Herbed Quiche Base',
      versionLabel: 'Master + Deep Dish',
      servings: 8,
      nutrition: NutritionSnapshot(
        calories: 401,
        protein: 16,
        carbs: 20,
        fat: 27,
        fiber: 2,
        sodium: 532,
        sugar: 2,
      ),
      tags: ['Nested recipe', 'Favorite scale', 'Auto pantry match'],
      note: 'Uses 1 serving of pie crust recipe and prompts on upstream edits.',
      isPinned: true,
      sortCalories: 412,
      ingredientCount: 7,
      directionCount: 4,
    ),
    RecipeSummary(
      id: 'recipe_1',
      name: 'Weeknight Turkey Chili',
      versionLabel: 'Lean Batch',
      servings: 6,
      nutrition: NutritionSnapshot(
        calories: 328,
        protein: 29,
        carbs: 22,
        fat: 13,
        fiber: 8,
        sodium: 560,
        sugar: 5,
      ),
      tags: ['Meal plan', 'High protein', 'Barcode ingredients'],
      note: 'Suggested pantry pulls: black beans, tomato puree, spice blend.',
      isPinned: true,
      sortCalories: 336,
      ingredientCount: 10,
      directionCount: 5,
    ),
    RecipeSummary(
      id: 'recipe_2',
      name: 'Greek Yogurt Pancakes',
      versionLabel: 'Single Serve',
      servings: 1,
      nutrition: NutritionSnapshot(
        calories: 253,
        protein: 14,
        carbs: 23,
        fat: 11,
        fiber: 2,
        sodium: 377,
        sugar: 4,
      ),
      tags: ['Favorite scale', 'Breakfast', 'Low sugar'],
      note: 'Pinned note: perfect for the 6-inch skillet.',
      isPinned: false,
      sortCalories: 298,
      ingredientCount: 6,
      directionCount: 3,
    ),
  ];

  static const recipeIngredients = <String, List<RecipeIngredientDraft>>{
    'recipe_0': [
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'serving',
        item: 'Pie crust recipe',
        preparation: 'Blind baked',
      ),
      RecipeIngredientDraft(
        quantity: '6',
        unit: 'large',
        item: 'Eggs',
        preparation: '',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'cup',
        item: 'Greek yogurt',
        preparation: '',
        linkType: RecipeIngredientType.pantryItem,
        linkedPantryItemId: 'pantry_0',
      ),
      RecipeIngredientDraft(
        quantity: '4',
        unit: 'oz',
        item: 'Gruyere',
        preparation: 'Shredded',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'cup',
        item: 'Spinach',
        preparation: 'Wilted',
      ),
      RecipeIngredientDraft(
        quantity: '0.5',
        unit: 'cup',
        item: 'Milk',
        preparation: '',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'tbsp',
        item: 'Herb blend',
        preparation: '',
      ),
    ],
    'recipe_1': [
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'lb',
        item: 'Turkey',
        preparation: 'Lean ground',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'large',
        item: 'Onion',
        preparation: 'Diced',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'each',
        item: 'Bell pepper',
        preparation: 'Diced',
      ),
      RecipeIngredientDraft(
        quantity: '2',
        unit: 'cans',
        item: 'Fire roasted tomatoes',
        preparation: '',
        linkType: RecipeIngredientType.pantryItem,
        linkedPantryItemId: 'pantry_1',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'can',
        item: 'Black beans',
        preparation: 'Drained',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'can',
        item: 'Kidney beans',
        preparation: 'Drained',
      ),
      RecipeIngredientDraft(
        quantity: '2',
        unit: 'cups',
        item: 'Broth',
        preparation: 'Low sodium',
      ),
      RecipeIngredientDraft(
        quantity: '2',
        unit: 'tbsp',
        item: 'Chili powder',
        preparation: '',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'tbsp',
        item: 'Cumin',
        preparation: '',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'tsp',
        item: 'Salt',
        preparation: '',
      ),
    ],
    'recipe_2': [
      RecipeIngredientDraft(
        quantity: '0.5',
        unit: 'cup',
        item: 'Greek yogurt',
        preparation: '',
        linkType: RecipeIngredientType.pantryItem,
        linkedPantryItemId: 'pantry_0',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'large',
        item: 'Egg',
        preparation: '',
      ),
      RecipeIngredientDraft(
        quantity: '0.25',
        unit: 'cup',
        item: 'Oat flour',
        preparation: '',
      ),
      RecipeIngredientDraft(
        quantity: '0.5',
        unit: 'tsp',
        item: 'Baking powder',
        preparation: '',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'tsp',
        item: 'Vanilla',
        preparation: '',
      ),
      RecipeIngredientDraft(
        quantity: '1',
        unit: 'tsp',
        item: 'Butter',
        preparation: 'For skillet',
      ),
    ],
  };

  static const recipeDirections = <String, List<String>>{
    'recipe_0': [
      'Blind bake the pie crust until lightly golden.',
      'Whisk eggs, yogurt, milk, and herbs until smooth.',
      'Layer spinach and cheese into the crust, then pour over the custard.',
      'Bake until the center is just set, then rest before slicing.',
    ],
    'recipe_1': [
      'Brown the turkey with onion and bell pepper.',
      'Add spices and toast until fragrant.',
      'Stir in tomatoes, beans, and broth.',
      'Simmer until thickened and flavors combine.',
      'Taste and adjust salt before serving.',
    ],
    'recipe_2': [
      'Whisk yogurt, egg, and vanilla together.',
      'Fold in oat flour and baking powder.',
      'Cook small pancakes in a buttered skillet until golden on both sides.',
    ],
  };

  static const pantryItems = <PantryItem>[
    PantryItem(
      id: 'pantry_0',
      name: 'Nonfat Greek Yogurt',
      quantityLabel: '32 oz tub',
      referenceUnit: 'serving',
      source: 'Barcode scan + Open Food Facts',
      barcode: '085239086852',
      brand: 'Fage',
      nutrition: NutritionSnapshot(
        calories: 90,
        protein: 18,
        carbs: 6,
        fat: 0,
        fiber: 0,
        sodium: 65,
        sugar: 5,
      ),
      accent: Color(0xFFD87B42),
      referenceUnitEquivalentQuantity: 1,
      referenceUnitEquivalentUnit: 'cup',
      referenceUnitWeightGrams: 227,
    ),
    PantryItem(
      id: 'pantry_1',
      name: 'Fire Roasted Tomatoes',
      quantityLabel: '3 cans',
      referenceUnit: 'can',
      source: 'Manual edit after scan',
      barcode: '072101010616',
      brand: 'Muir Glen',
      nutrition: NutritionSnapshot(
        calories: 25,
        protein: 1,
        carbs: 5,
        fat: 0,
        fiber: 1,
        sodium: 180,
        sugar: 3,
      ),
      accent: Color(0xFF7B5138),
      referenceUnitEquivalentQuantity: 14.5,
      referenceUnitEquivalentUnit: 'oz',
      referenceUnitWeightGrams: 411,
    ),
    PantryItem(
      id: 'pantry_2',
      name: 'Sourdough Pie Crust',
      quantityLabel: '2 recipe servings frozen',
      referenceUnit: 'serving',
      source: 'Saved recipe ingredient',
      nutrition: NutritionSnapshot(
        calories: 188,
        protein: 3,
        carbs: 18,
        fat: 12,
        fiber: 1,
        sodium: 140,
        sugar: 1,
      ),
      accent: Color(0xFF4F6B44),
    ),
  ];

  static const grocerySections = <GrocerySection>[
    GrocerySection(
      title: 'Pinned Meal Plan Export',
      items: [
        GroceryListItem(
          key: 'seed-turkey-chili-onions',
          label: 'Turkey chili onions',
        ),
        GroceryListItem(key: 'seed-cornbread-mix', label: 'Cornbread mix'),
        GroceryListItem(
          key: 'seed-sour-cream-add-on',
          label: 'Sour cream add-on',
        ),
        GroceryListItem(key: 'seed-bell-peppers', label: 'Bell peppers'),
      ],
    ),
    GrocerySection(
      title: 'Pantry Refill',
      items: [
        GroceryListItem(key: 'seed-greek-yogurt', label: 'Greek yogurt'),
        GroceryListItem(
          key: 'seed-low-sodium-broth',
          label: 'Low sodium broth',
        ),
        GroceryListItem(key: 'seed-eggs', label: 'Eggs'),
      ],
    ),
  ];

  static const savedMeals = <SavedMeal>[
    SavedMeal(
      id: 'saved_meal_0',
      name: 'Chili Night',
      nutrition: NutritionSnapshot(
        calories: 642,
        protein: 37,
        carbs: 52,
        fat: 31,
        fiber: 11,
        sodium: 980,
        sugar: 8,
      ),
      manualNutrition: NutritionSnapshot(
        calories: 642,
        protein: 37,
        carbs: 52,
        fat: 31,
        fiber: 11,
        sodium: 980,
        sugar: 8,
      ),
      adjustments: [
        'Cornbread: 0.5x',
        'Sour cream: +1 tbsp',
        'Cheddar: optional',
      ],
      components: [],
    ),
    SavedMeal(
      id: 'saved_meal_1',
      name: 'High-Protein Breakfast',
      nutrition: NutritionSnapshot(
        calories: 410,
        protein: 35,
        carbs: 31,
        fat: 14,
        fiber: 4,
        sodium: 470,
        sugar: 9,
      ),
      manualNutrition: NutritionSnapshot(
        calories: 410,
        protein: 35,
        carbs: 31,
        fat: 14,
        fiber: 4,
        sodium: 470,
        sugar: 9,
      ),
      adjustments: ['Pancakes: 1.0x', 'Yogurt bowl: 0.75x'],
      components: [],
    ),
  ];

  static final foodLogEntries = <FoodLogEntryDraft>[
    FoodLogEntryDraft(
      date: todayDate,
      mealSlot: FoodLogMealSlot.breakfast,
      sourceType: FoodLogEntrySourceType.savedMeal,
      sourceId: 'saved_meal_1',
      title: 'High-Protein Breakfast',
      quantity: '1',
      unit: 'meal',
      nutrition: NutritionSnapshot(
        calories: 410,
        protein: 35,
        carbs: 31,
        fat: 14,
        fiber: 4,
        sodium: 470,
        sugar: 9,
      ),
    ),
    FoodLogEntryDraft(
      date: todayDate,
      mealSlot: FoodLogMealSlot.lunch,
      sourceType: FoodLogEntrySourceType.recipe,
      sourceId: 'recipe_1',
      title: 'Weeknight Turkey Chili',
      quantity: '1',
      unit: 'serving',
      nutrition: NutritionSnapshot(
        calories: 328,
        protein: 29,
        carbs: 22,
        fat: 13,
        fiber: 8,
        sodium: 560,
        sugar: 5,
      ),
    ),
    FoodLogEntryDraft(
      date: todayDate,
      mealSlot: FoodLogMealSlot.snack,
      sourceType: FoodLogEntrySourceType.pantryItem,
      sourceId: 'pantry_0',
      title: 'Nonfat Greek Yogurt',
      quantity: '0.5',
      unit: 'serving',
      nutrition: NutritionSnapshot(
        calories: 45,
        protein: 9,
        carbs: 3,
        fat: 0,
        fiber: 0,
        sodium: 33,
        sugar: 3,
      ),
    ),
    FoodLogEntryDraft(
      date: todayDate,
      mealSlot: FoodLogMealSlot.dinner,
      sourceType: FoodLogEntrySourceType.savedMeal,
      sourceId: 'saved_meal_0',
      title: 'Chili Night',
      quantity: '1',
      unit: 'meal',
      nutrition: NutritionSnapshot(
        calories: 642,
        protein: 37,
        carbs: 52,
        fat: 31,
        fiber: 11,
        sodium: 980,
        sugar: 8,
      ),
    ),
  ];

  static final dayPlans = <DayPlanDraft>[
    DayPlanDraft(
      name: 'High-Protein Default Day',
      note:
          'A reusable weekday structure built from the current saved meals and a yogurt snack.',
      entries: foodLogEntries
          .map(
            (entry) => DayPlanEntryDraft(
              mealSlot: entry.mealSlot,
              sourceType: entry.sourceType,
              sourceId: entry.sourceId,
              title: entry.title,
              quantity: entry.quantity,
              unit: entry.unit,
              nutrition: entry.nutrition,
            ),
          )
          .toList(growable: false),
    ),
  ];

  static final mealPlans = <MealPlanDraft>[
    MealPlanDraft(
      name: 'Weeknight Rotation Board',
      note:
          'A pinned weekly planner that mixes saved meals, standalone recipes, and pantry staples.',
      folderLabel: 'Family Week',
      isPinned: true,
      entries: const [
        MealPlanEntryDraft(
          daySlot: MealPlanDaySlot.monday,
          mealSlot: FoodLogMealSlot.breakfast,
          sourceType: FoodLogEntrySourceType.savedMeal,
          sourceId: 'saved_meal_1',
          title: 'High-Protein Breakfast',
          quantity: '1',
          unit: 'meal',
          nutrition: NutritionSnapshot(
            calories: 410,
            protein: 35,
            carbs: 31,
            fat: 14,
            fiber: 4,
            sodium: 470,
            sugar: 9,
          ),
        ),
        MealPlanEntryDraft(
          daySlot: MealPlanDaySlot.monday,
          mealSlot: FoodLogMealSlot.dinner,
          sourceType: FoodLogEntrySourceType.savedMeal,
          sourceId: 'saved_meal_0',
          title: 'Chili Night',
          quantity: '1',
          unit: 'meal',
          nutrition: NutritionSnapshot(
            calories: 642,
            protein: 37,
            carbs: 52,
            fat: 31,
            fiber: 11,
            sodium: 980,
            sugar: 8,
          ),
        ),
        MealPlanEntryDraft(
          daySlot: MealPlanDaySlot.tuesday,
          mealSlot: FoodLogMealSlot.lunch,
          sourceType: FoodLogEntrySourceType.recipe,
          sourceId: 'recipe_1',
          title: 'Weeknight Turkey Chili',
          quantity: '1',
          unit: 'serving',
          nutrition: NutritionSnapshot(
            calories: 328,
            protein: 29,
            carbs: 22,
            fat: 13,
            fiber: 8,
            sodium: 560,
            sugar: 5,
          ),
        ),
        MealPlanEntryDraft(
          daySlot: MealPlanDaySlot.wednesday,
          mealSlot: FoodLogMealSlot.snack,
          sourceType: FoodLogEntrySourceType.pantryItem,
          sourceId: 'pantry_0',
          title: 'Nonfat Greek Yogurt',
          quantity: '1',
          unit: 'serving',
          nutrition: NutritionSnapshot(
            calories: 90,
            protein: 18,
            carbs: 6,
            fat: 0,
            fiber: 0,
            sodium: 65,
            sugar: 5,
          ),
        ),
      ],
    ),
  ];

  static const dailyGoals = <DailyGoal>[
    DailyGoal(label: 'Calories', consumed: 1460, target: 1850),
    DailyGoal(label: 'Protein', consumed: 104, target: 135),
    DailyGoal(label: 'Carbs', consumed: 132, target: 180),
    DailyGoal(label: 'Fat', consumed: 58, target: 70),
    DailyGoal(label: 'Fiber', consumed: 24, target: 30),
    DailyGoal(label: 'Sodium', consumed: 1710, target: 2300),
    DailyGoal(label: 'Sugar', consumed: 38, target: 45),
  ];
}
