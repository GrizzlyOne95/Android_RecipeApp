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
}

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
  });

  final String name;
  final String versionLabel;
  final int servings;
  final String note;
  final List<String> tags;
  final bool isPinned;
  final NutritionSnapshot nutrition;
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
    ),
  ];

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
