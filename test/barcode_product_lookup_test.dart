import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipe_app/src/core/mock_data.dart';
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
      expect(result.draft.imageUrl, 'https://example.com/coke.jpg');
      expect(result.draft.quantityLabel, '1 can (330 ml)');
      expect(result.draft.referenceUnit, 'can');
      expect(result.draft.referenceUnitQuantity, 1);
      expect(result.draft.referenceUnitEquivalentQuantity, 330);
      expect(result.draft.referenceUnitEquivalentUnit, 'ml');
      expect(result.draft.nutrition.calories, 139);
      expect(result.draft.nutrition.carbs, 35);
      expect(result.referenceSummary, '1 can = 330 ml');
      expect(
        result.sourceLabel,
        OpenFoodFactsPantryBarcodeImporter.providerLabel,
      );
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
      expect(
        result.sourceLabel,
        OpenFoodFactsPantryBarcodeImporter.providerLabel,
      );
    },
  );

  test(
    'imports USDA branded nutrition and converts per-100g values to the serving basis',
    () async {
      final importer = UsdaFoodDataCentralPantryBarcodeImporter(
        apiKey: 'test-key',
        client: MockClient((request) async {
          expect(request.url.host, 'api.nal.usda.gov');
          expect(request.url.path, '/fdc/v1/foods/search');
          expect(request.url.queryParameters['query'], '3017620422003');
          expect(request.url.queryParameters['api_key'], 'test-key');
          return http.Response('''
{
  "foods": [
    {
      "description": "Hazelnut Spread with Cocoa",
      "brandOwner": "Ferrero U.S.A., Incorporated",
      "brandName": "Nutella",
      "gtinUpc": "03017620422003",
      "packageWeight": "26.5 oz/750 g",
      "servingSize": 37,
      "servingSizeUnit": "g",
      "householdServingFullText": "2 tbsp",
      "foodNutrients": [
        {"nutrientNumber": "208", "value": 539, "unitName": "KCAL"},
        {"nutrientNumber": "203", "value": 6.3, "unitName": "G"},
        {"nutrientNumber": "204", "value": 30.9, "unitName": "G"},
        {"nutrientNumber": "205", "value": 57.5, "unitName": "G"},
        {"nutrientNumber": "269", "value": 56.3, "unitName": "G"},
        {"nutrientNumber": "291", "value": 3.8, "unitName": "G"},
        {"nutrientNumber": "307", "value": 42, "unitName": "MG"}
      ]
    }
  ]
}
''', 200);
        }),
      );

      final result = await importer.lookup('3017620422003');

      expect(result.draft.name, 'Hazelnut Spread with Cocoa');
      expect(result.draft.brand, 'Nutella');
      expect(result.draft.quantityLabel, '26.5 oz/750 g');
      expect(result.draft.referenceUnit, 'tbsp');
      expect(result.draft.referenceUnitQuantity, 2);
      expect(result.draft.referenceUnitWeightGrams, 37);
      expect(result.draft.nutrition.calories, 199);
      expect(result.draft.nutrition.protein, 2);
      expect(result.draft.nutrition.carbs, 21);
      expect(result.draft.nutrition.fat, 11);
      expect(result.draft.nutrition.sodium, 16);
      expect(result.referenceSummary, '2 tbsp = 37 g');
      expect(
        result.sourceLabel,
        UsdaFoodDataCentralPantryBarcodeImporter.providerLabel,
      );
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

  test(
    'falls back to USDA when Open Food Facts does not find a product',
    () async {
      final importer = CompositePantryBarcodeImporter(
        importers: [
          _ThrowingImporter(
            const PantryBarcodeImportException(
              'No product was found for that barcode.',
            ),
          ),
          _SuccessfulImporter(
            const PantryBarcodeImportResult(
              draft: PantryItemDraft(
                name: 'Fallback granola bar',
                brand: 'USDA Brand',
                barcode: '012345678905',
                quantityLabel: '6 bars',
                referenceUnit: 'bar',
                referenceUnitQuantity: 1,
                source: 'Barcode import + USDA FoodData Central',
                nutrition: NutritionSnapshot(
                  calories: 190,
                  protein: 6,
                  carbs: 24,
                  fat: 8,
                  fiber: 3,
                  sodium: 140,
                  sugar: 9,
                ),
                accent: Color(0xFF4A6572),
              ),
              referenceSummary: '1 bar',
              sourceLabel: 'USDA FoodData Central',
            ),
          ),
        ],
      );

      final result = await importer.lookup('012345678905');

      expect(result.draft.name, 'Fallback granola bar');
      expect(result.sourceLabel, 'USDA FoodData Central');
    },
  );
}

class _ThrowingImporter implements PantryBarcodeImporter {
  _ThrowingImporter(this.error);

  final PantryBarcodeImportException error;

  @override
  Future<PantryBarcodeImportResult> lookup(String barcode) async => throw error;
}

class _SuccessfulImporter implements PantryBarcodeImporter {
  _SuccessfulImporter(this.result);

  final PantryBarcodeImportResult result;

  @override
  Future<PantryBarcodeImportResult> lookup(String barcode) async => result;
}
