import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/src/core/recipe_import.dart';

void main() {
  test(
    'recipe import parser extracts a structured recipe from pasted text',
    () {
      final result = RecipeImportParser.parse(
        mode: RecipeImportMode.textPaste,
        rawText: '''
Best Overnight Oats
Servings: 2

Ingredients
1 cup rolled oats
1 1/2 cups milk
2 tbsp chia seeds
1 tbsp maple syrup, optional

Directions
1. Stir everything together.
2. Refrigerate overnight.

Nutrition: Calories 320 Protein 12g Carbs 44g Fat 9g Fiber 8g Sugar 11g
''',
      );

      expect(result.draft.name, 'Best Overnight Oats');
      expect(result.draft.servings, 2);
      expect(result.draft.ingredients, hasLength(4));
      expect(result.draft.ingredients.first.quantity, '1');
      expect(result.draft.ingredients.first.unit, 'cup');
      expect(result.draft.ingredients.first.item, 'rolled oats');
      expect(result.draft.directions, [
        'Stir everything together.',
        'Refrigerate overnight.',
      ]);
      expect(result.draft.nutrition.calories, 320);
      expect(result.draft.nutrition.protein, 12);
      expect(result.draft.tags, contains('Imported'));
    },
  );

  test('recipe import parser falls back to the url slug for title', () {
    final result = RecipeImportParser.parse(
      mode: RecipeImportMode.urlPaste,
      sourceUrl: 'https://example.com/recipes/skillet-lasagna',
    );

    expect(result.draft.name, 'Skillet Lasagna');
    expect(
      result.draft.note,
      contains('https://example.com/recipes/skillet-lasagna'),
    );
    expect(result.draft.versionLabel, 'Imported URL Draft');
    expect(
      result.warnings,
      contains('No ingredients were detected. Add them in the editor.'),
    );
  });

  test(
    'recipe import parser splits OCR-style step lines and preserves time notes',
    () {
      final result = RecipeImportParser.parse(
        mode: RecipeImportMode.ocrPaste,
        rawText: '''
Weeknight Fried Rice
Prep Time: 10 minutes
Cook Time: 12 minutes
Serves 3

Ingredients
• 2 cups cooked rice
• 1 tbsp oil
• 2 eggs

Directions
Step 1: Heat the pan. Step 2: Scramble the eggs. Step 3: Toss in rice and seasonings.
''',
      );

      expect(result.draft.name, 'Weeknight Fried Rice');
      expect(result.draft.servings, 3);
      expect(result.draft.ingredients, hasLength(3));
      expect(result.draft.directions, [
        'Heat the pan.',
        'Scramble the eggs.',
        'Toss in rice and seasonings.',
      ]);
      expect(result.draft.note, contains('Prep Time: 10 minutes'));
      expect(result.draft.note, contains('Cook Time: 12 minutes'));
      expect(result.draft.tags, contains('OCR import'));
    },
  );

  test('recipe import parser reads explicit tags lines', () {
    final result = RecipeImportParser.parse(
      mode: RecipeImportMode.textPaste,
      rawText: '''
Protein Pasta Bowl
Tags: meal prep, dinner, high protein

Ingredients
1 box pasta

Directions
1. Cook.
''',
    );

    expect(
      result.draft.tags,
      containsAll(['Meal Prep', 'Dinner', 'High Protein']),
    );
  });
}
