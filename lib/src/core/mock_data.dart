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

class RecipeIngredientDraft {
  const RecipeIngredientDraft({
    required this.quantity,
    required this.unit,
    required this.item,
    required this.preparation,
  });

  final String quantity;
  final String unit;
  final String item;
  final String preparation;

  RecipeIngredientDraft copyWith({
    String? quantity,
    String? unit,
    String? item,
    String? preparation,
  }) {
    return RecipeIngredientDraft(
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      item: item ?? this.item,
      preparation: preparation ?? this.preparation,
    );
  }
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
    required this.name,
    required this.quantityLabel,
    required this.source,
    required this.nutrition,
    required this.accent,
  });

  final String name;
  final String quantityLabel;
  final String source;
  final NutritionSnapshot nutrition;
  final Color accent;
}

class GrocerySection {
  const GrocerySection({required this.title, required this.items});

  final String title;
  final List<String> items;
}

class SavedMeal {
  const SavedMeal({
    required this.name,
    required this.nutrition,
    required this.adjustments,
  });

  final String name;
  final NutritionSnapshot nutrition;
  final List<String> adjustments;
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
  const FoodLogSnapshot({required this.goals, required this.savedMeals});

  final List<DailyGoal> goals;
  final List<SavedMeal> savedMeals;
}

abstract final class SeedData {
  static const todayLabel = 'Friday, March 13';

  static const recipes = <RecipeSummary>[
    RecipeSummary(
      id: 'recipe_0',
      name: 'Herbed Quiche Base',
      versionLabel: 'Master + Deep Dish',
      servings: 8,
      nutrition: NutritionSnapshot(
        calories: 412,
        protein: 18,
        carbs: 21,
        fat: 27,
        fiber: 2,
        sodium: 540,
        sugar: 3,
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
        calories: 336,
        protein: 29,
        carbs: 24,
        fat: 13,
        fiber: 8,
        sodium: 620,
        sugar: 6,
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
        calories: 298,
        protein: 23,
        carbs: 26,
        fat: 11,
        fiber: 2,
        sodium: 410,
        sugar: 7,
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
      name: 'Nonfat Greek Yogurt',
      quantityLabel: '32 oz tub',
      source: 'Barcode scan + Open Food Facts',
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
    ),
    PantryItem(
      name: 'Fire Roasted Tomatoes',
      quantityLabel: '3 cans',
      source: 'Manual edit after scan',
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
    ),
    PantryItem(
      name: 'Sourdough Pie Crust',
      quantityLabel: '2 recipe servings frozen',
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
        'Turkey chili onions',
        'Cornbread mix',
        'Sour cream add-on',
        'Bell peppers',
      ],
    ),
    GrocerySection(
      title: 'Pantry Refill',
      items: ['Greek yogurt', 'Low sodium broth', 'Eggs'],
    ),
  ];

  static const savedMeals = <SavedMeal>[
    SavedMeal(
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
      adjustments: [
        'Cornbread: 0.5x',
        'Sour cream: +1 tbsp',
        'Cheddar: optional',
      ],
    ),
    SavedMeal(
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
      adjustments: ['Pancakes: 1.0x', 'Yogurt bowl: 0.75x'],
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
