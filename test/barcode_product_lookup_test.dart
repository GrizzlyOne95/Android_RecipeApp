import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipe_app/src/data/import/barcode_product_lookup.dart';

void main() {
  test(
    'imports per-serving nutrition when serving fields are present',
    () async {
      final importer = OpenFoodFactsPantryBarcodeImporter(
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            contains('/api/v2/product/5449000000996'),
          );
          return http.Response('''
{
  "status": 1,
  "product": {
    "product_name": "Coke Original Taste",
    "brands": "Coca-Cola",
    "quantity": "0.0 kg",
    "product_quantity": 0,
    "serving_size": "1 can (330 ml)",
    "image_front_url": "https://example.com/coke.jpg",
    "nutrition_data_per": "100g",
    "nutriments": {
      "energy-kcal": 42,
      "energy-kcal_serving": 139,
      "carbohydrates": 10.6,
      "carbohydrates_serving": 35,
      "fat": 0,
      "fat_serving": 0,
      "proteins": 0,
      "proteins_serving": 0,
      "sugars": 10.6,
      "sugars_serving": 35,
      "sodium": 0,
      "sodium_serving": 0,
      "carbohydrates_unit": "g",
      "fat_unit": "g",
      "proteins_unit": "g",
      "sugars_unit": "g",
      "sodium_unit": "g"
    }
  }
}
''', 200);
        }),
      );

      final result = await importer.lookup('5449000000996');

      expect(result.draft.name, 'Coke Original Taste');
      expect(result.draft.brand, 'Coca-Cola');
      expect(result.draft.quantityLabel, '1 can (330 ml)');
      expect(result.draft.referenceUnit, 'can');
      expect(result.draft.referenceUnitQuantity, 1);
      expect(result.draft.referenceUnitEquivalentQuantity, 330);
      expect(result.draft.referenceUnitEquivalentUnit, 'ml');
      expect(result.draft.nutrition.calories, 139);
      expect(result.draft.nutrition.carbs, 35);
      expect(result.referenceSummary, '1 can = 330 ml');
    },
  );

  test(
    'falls back to per-100g nutrition when serving data is unavailable',
    () async {
      final importer = OpenFoodFactsPantryBarcodeImporter(
        client: MockClient((request) async {
          return http.Response('''
{
  "status": 1,
  "product": {
    "product_name": "Nutella",
    "brands": "Ferrero",
    "quantity": "400 g",
    "nutrition_data_per": "100g",
    "nutriments": {
      "energy-kcal_100g": 539,
      "fat_100g": 30.9,
      "carbohydrates_100g": 57.5,
      "proteins_100g": 6.3,
      "sugars_100g": 56.3,
      "salt_100g": 0.1075,
      "fat_unit": "g",
      "carbohydrates_unit": "g",
      "proteins_unit": "g",
      "sugars_unit": "g",
      "salt_unit": "g"
    }
  }
}
''', 200);
        }),
      );

      final result = await importer.lookup('3017624010701');

      expect(result.draft.referenceUnit, 'g');
      expect(result.draft.referenceUnitQuantity, 100);
      expect(result.draft.referenceUnitEquivalentQuantity, isNull);
      expect(result.draft.referenceUnitWeightGrams, isNull);
      expect(result.draft.nutrition.calories, 539);
      expect(result.draft.nutrition.protein, 6);
      expect(result.draft.nutrition.carbs, 58);
      expect(result.draft.nutrition.fat, 31);
      expect(result.draft.nutrition.sodium, 42);
      expect(result.referenceSummary, '100 g');
    },
  );

  test('throws a clear error when the barcode is unknown', () async {
    final importer = OpenFoodFactsPantryBarcodeImporter(
      client: MockClient((request) async {
        return http.Response('{"status":0}', 200);
      }),
    );

    expect(
      () => importer.lookup('0000000000000'),
      throwsA(
        isA<PantryBarcodeImportException>().having(
          (error) => error.message,
          'message',
          contains('No product'),
        ),
      ),
    );
  });
}
