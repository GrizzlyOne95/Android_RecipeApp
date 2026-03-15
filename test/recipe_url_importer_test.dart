import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipe_app/src/core/recipe_import.dart';
import 'package:recipe_app/src/data/import/recipe_url_importer.dart';

void main() {
  test('url importer converts recipe schema into importable text', () async {
    final importer = RecipeUrlImporter(
      client: MockClient((request) async {
        return http.Response('''
<html>
  <head>
    <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "Recipe",
        "name": "Sheet Pan Gnocchi",
        "recipeYield": "4 servings",
        "recipeIngredient": [
          "1 lb shelf-stable gnocchi",
          "2 cups broccoli florets",
          "3 tbsp olive oil"
        ],
        "recipeInstructions": [
          {"@type":"HowToStep","text":"Toss everything on a sheet pan."},
          {"@type":"HowToStep","text":"Roast until the gnocchi is crisp."}
        ],
        "nutrition": {
          "@type": "NutritionInformation",
          "calories": "410 calories",
          "proteinContent": "12 g",
          "carbohydrateContent": "58 g",
          "fatContent": "15 g"
        }
      }
    </script>
  </head>
  <body></body>
</html>
''', 200);
      }),
    );

    final fetched = await importer.fetch(
      'https://example.com/sheet-pan-gnocchi',
    );

    expect(fetched.usedStructuredData, isTrue);
    expect(
      fetched.warnings.single,
      contains('Structured recipe data was detected'),
    );

    final parsed = RecipeImportParser.parse(
      mode: RecipeImportMode.urlPaste,
      rawText: fetched.extractedText,
      sourceUrl: 'https://example.com/sheet-pan-gnocchi',
    );

    expect(parsed.draft.name, 'Sheet Pan Gnocchi');
    expect(parsed.draft.servings, 4);
    expect(parsed.draft.ingredients, hasLength(3));
    expect(parsed.draft.directions, [
      'Toss everything on a sheet pan.',
      'Roast until the gnocchi is crisp.',
    ]);
    expect(parsed.draft.nutrition.calories, 410);
    expect(parsed.draft.nutrition.carbs, 58);
  });

  test('url importer falls back to readable article text', () async {
    final importer = RecipeUrlImporter(
      client: MockClient((request) async {
        return http.Response('''
<html>
  <body>
    <article>
      <h1>Skillet Pasta</h1>
      <p>Servings: 3</p>
      <h2>Ingredients</h2>
      <ul>
        <li>8 oz pasta</li>
        <li>2 cups broth</li>
      </ul>
      <h2>Directions</h2>
      <ol>
        <li>Boil the pasta in broth.</li>
        <li>Finish until glossy.</li>
      </ol>
    </article>
  </body>
</html>
''', 200);
      }),
    );

    final fetched = await importer.fetch('https://example.com/skillet-pasta');

    expect(fetched.usedStructuredData, isFalse);
    expect(fetched.extractedText, contains('Skillet Pasta'));
    expect(fetched.extractedText, contains('8 oz pasta'));

    final parsed = RecipeImportParser.parse(
      mode: RecipeImportMode.urlPaste,
      rawText: fetched.extractedText,
      sourceUrl: 'https://example.com/skillet-pasta',
    );

    expect(parsed.draft.name, 'Skillet Pasta');
    expect(parsed.draft.ingredients, isNotEmpty);
    expect(parsed.draft.directions, isNotEmpty);
  });
}
