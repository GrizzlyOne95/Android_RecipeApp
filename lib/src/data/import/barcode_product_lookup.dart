import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/measurement_units.dart';
import '../../core/mock_data.dart';

abstract interface class PantryBarcodeImporter {
  Future<PantryBarcodeImportResult> lookup(String barcode);
}

class PantryBarcodeImportResult {
  const PantryBarcodeImportResult({
    required this.draft,
    required this.referenceSummary,
    required this.sourceLabel,
    this.imageUrl,
  });

  final PantryItemDraft draft;
  final String referenceSummary;
  final String sourceLabel;
  final String? imageUrl;
}

class PantryBarcodeImportException implements Exception {
  const PantryBarcodeImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CompositePantryBarcodeImporter implements PantryBarcodeImporter {
  CompositePantryBarcodeImporter({List<PantryBarcodeImporter>? importers})
    : _importers =
          importers ??
          [
            OpenFoodFactsPantryBarcodeImporter(),
            UsdaFoodDataCentralPantryBarcodeImporter(),
          ];

  final List<PantryBarcodeImporter> _importers;

  @override
  Future<PantryBarcodeImportResult> lookup(String barcode) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) {
      throw const PantryBarcodeImportException('Enter a barcode first.');
    }

    final failures = <String>[];
    for (final importer in _importers) {
      try {
        return await importer.lookup(normalizedBarcode);
      } on PantryBarcodeImportException catch (error) {
        failures.add(error.message);
      }
    }

    final uniqueFailures = failures.toSet().toList(growable: false);
    if (uniqueFailures.every((message) => message.contains('No product'))) {
      throw const PantryBarcodeImportException(
        'No product was found for that barcode in Open Food Facts or USDA FoodData Central.',
      );
    }

    throw PantryBarcodeImportException(
      uniqueFailures.isEmpty
          ? 'Barcode lookup failed unexpectedly.'
          : uniqueFailures.last,
    );
  }
}

class OpenFoodFactsPantryBarcodeImporter implements PantryBarcodeImporter {
  OpenFoodFactsPantryBarcodeImporter({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static const providerLabel = 'Open Food Facts';

  static const _accentOptions = <Color>[
    Color(0xFFD87B42),
    Color(0xFF7B5138),
    Color(0xFF4F6B44),
    Color(0xFF4A6572),
    Color(0xFF8B6F47),
  ];

  @override
  Future<PantryBarcodeImportResult> lookup(String barcode) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) {
      throw const PantryBarcodeImportException('Enter a barcode first.');
    }

    final uri = Uri.https(
      'world.openfoodfacts.net',
      '/api/v2/product/$normalizedBarcode',
      {
        'fields':
            'product_name,brands,quantity,serving_size,image_front_url,nutrition_data,nutrition_data_per,nutriments',
      },
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw const PantryBarcodeImportException(
        'Open Food Facts is not responding right now. Try again in a moment.',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, Object?>) {
      throw const PantryBarcodeImportException(
        'Open Food Facts returned an unreadable product response.',
      );
    }

    if (payload['status'] != 1) {
      throw const PantryBarcodeImportException(
        'No product was found for that barcode.',
      );
    }

    final product = payload['product'];
    if (product is! Map<String, Object?>) {
      throw const PantryBarcodeImportException(
        'Open Food Facts did not include product details for that barcode.',
      );
    }

    final nutriments = product['nutriments'];
    if (nutriments is! Map<String, Object?>) {
      throw const PantryBarcodeImportException(
        'This product does not include nutrition data yet.',
      );
    }

    final basis = _selectBasis(product, nutriments);
    final nutrition = _buildNutrition(nutriments, basis);
    if (nutrition == NutritionSnapshot.zero) {
      throw const PantryBarcodeImportException(
        'This product does not include enough nutrition data to import.',
      );
    }

    final title = _normalizedText(product['product_name']) ?? 'Scanned item';
    final quantityLabel = _resolvePackageLabel(product);
    final imageUrl = _normalizedText(product['image_front_url']);

    final draft = PantryItemDraft(
      name: title,
      brand: _normalizedText(product['brands']),
      barcode: normalizedBarcode,
      imageUrl: imageUrl,
      quantityLabel: quantityLabel,
      referenceUnit: basis.referenceUnit,
      referenceUnitQuantity: basis.referenceUnitQuantity,
      source: 'Barcode import + Open Food Facts',
      nutrition: nutrition,
      accent:
          _accentOptions[normalizedBarcode.hashCode.abs() %
              _accentOptions.length],
      referenceUnitEquivalentQuantity: basis.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: basis.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: basis.referenceUnitWeightGrams,
    );

    return PantryBarcodeImportResult(
      draft: draft,
      referenceSummary: MeasurementUnits.describeReferenceUnit(
        referenceUnit: draft.referenceUnit,
        referenceUnitQuantity: draft.referenceUnitQuantity,
        referenceUnitEquivalentQuantity: draft.referenceUnitEquivalentQuantity,
        referenceUnitEquivalentUnit: draft.referenceUnitEquivalentUnit,
        referenceUnitWeightGrams: draft.referenceUnitWeightGrams,
      ),
      sourceLabel: providerLabel,
      imageUrl: imageUrl,
    );
  }

  String _resolvePackageLabel(Map<String, Object?> product) {
    final quantity = _normalizedText(product['quantity']);
    final servingSize = _normalizedText(product['serving_size']);
    final productQuantity = _numericValue(product['product_quantity']);

    if (quantity != null &&
        !_looksLikePlaceholderQuantity(
          quantity,
          productQuantity: productQuantity,
        )) {
      return quantity;
    }

    if (servingSize != null) {
      return servingSize;
    }

    return quantity ?? 'Imported package';
  }

  _NutritionBasis _selectBasis(
    Map<String, Object?> product,
    Map<String, Object?> nutriments,
  ) {
    final servingSize = _normalizedText(product['serving_size']);
    final nutritionDataPer = _normalizedText(
      product['nutrition_data_per'],
    )?.toLowerCase();
    final servingBasis = servingSize == null
        ? null
        : _basisFromServingSize(servingSize);

    if (servingBasis != null && _hasServingNutrition(nutriments)) {
      return servingBasis.copyWith(nutrimentSuffix: 'serving');
    }

    if (servingBasis != null && nutritionDataPer == 'serving') {
      return servingBasis.copyWith(nutrimentSuffix: null);
    }

    if (nutritionDataPer == '100ml') {
      return const _NutritionBasis(
        referenceUnit: 'ml',
        referenceUnitQuantity: 100,
        nutrimentSuffix: '100ml',
      );
    }

    if (nutritionDataPer == 'serving' && servingBasis == null) {
      return const _NutritionBasis(
        referenceUnit: 'serving',
        referenceUnitQuantity: 1,
        nutrimentSuffix: null,
      );
    }

    return const _NutritionBasis(
      referenceUnit: 'g',
      referenceUnitQuantity: 100,
      nutrimentSuffix: '100g',
    );
  }

  bool _hasServingNutrition(Map<String, Object?> nutriments) {
    return [
      'energy-kcal_serving',
      'proteins_serving',
      'carbohydrates_serving',
      'fat_serving',
      'sugars_serving',
    ].any(nutriments.containsKey);
  }

  _NutritionBasis _basisFromServingSize(String servingSize) {
    final outer = _parseSimpleSize(servingSize.split('(').first.trim());
    final innerMatch = RegExp(r'\(([^)]+)\)').firstMatch(servingSize);
    final inner = innerMatch == null
        ? null
        : _parseSimpleSize(innerMatch.group(1)!);
    final primary = outer ?? inner;

    if (primary == null) {
      return const _NutritionBasis(
        referenceUnit: 'serving',
        referenceUnitQuantity: 1,
        nutrimentSuffix: 'serving',
      );
    }

    double? equivalentQuantity;
    String? equivalentUnit;
    double? weightGrams;

    if (inner != null && inner != primary) {
      if (_normalizedUnit(inner.unit) == 'g') {
        weightGrams = inner.quantity;
      } else {
        equivalentQuantity = inner.quantity;
        equivalentUnit = inner.unit;
      }
    }

    if (_normalizedUnit(primary.unit) == 'g') {
      weightGrams = null;
    } else if (_normalizedUnit(primary.unit) != 'ml' &&
        equivalentQuantity == null &&
        inner == null) {
      equivalentQuantity = null;
      equivalentUnit = null;
    }

    return _NutritionBasis(
      referenceUnit: primary.unit,
      referenceUnitQuantity: primary.quantity,
      referenceUnitEquivalentQuantity: equivalentQuantity,
      referenceUnitEquivalentUnit: equivalentUnit,
      referenceUnitWeightGrams: weightGrams,
      nutrimentSuffix: 'serving',
    );
  }

  NutritionSnapshot _buildNutrition(
    Map<String, Object?> nutriments,
    _NutritionBasis basis,
  ) {
    final calories =
        _readNutrimentValue(
          nutriments,
          'energy-kcal',
          suffix: basis.nutrimentSuffix,
        )?.round() ??
        (_readNutrimentValue(
                  nutriments,
                  'energy',
                  suffix: basis.nutrimentSuffix,
                ) ==
                null
            ? null
            : (_readNutrimentValue(
                        nutriments,
                        'energy',
                        suffix: basis.nutrimentSuffix,
                      )! /
                      4.184)
                  .round());
    final sodium =
        _massToMilligrams(
          _readNutrimentValue(
            nutriments,
            'sodium',
            suffix: basis.nutrimentSuffix,
          ),
          unit: _readNutrimentUnit(nutriments, 'sodium'),
        ) ??
        (() {
          final saltGrams = _massToGrams(
            _readNutrimentValue(
              nutriments,
              'salt',
              suffix: basis.nutrimentSuffix,
            ),
            unit: _readNutrimentUnit(nutriments, 'salt'),
          );
          if (saltGrams == null) {
            return null;
          }
          return (saltGrams * 393.4).round();
        })();

    return NutritionSnapshot(
      calories: calories ?? 0,
      protein:
          (_massToGrams(
                    _readNutrimentValue(
                      nutriments,
                      'proteins',
                      suffix: basis.nutrimentSuffix,
                    ),
                    unit: _readNutrimentUnit(nutriments, 'proteins'),
                  ) ??
                  0)
              .round(),
      carbs:
          (_massToGrams(
                    _readNutrimentValue(
                      nutriments,
                      'carbohydrates',
                      suffix: basis.nutrimentSuffix,
                    ),
                    unit: _readNutrimentUnit(nutriments, 'carbohydrates'),
                  ) ??
                  0)
              .round(),
      fat:
          (_massToGrams(
                    _readNutrimentValue(
                      nutriments,
                      'fat',
                      suffix: basis.nutrimentSuffix,
                    ),
                    unit: _readNutrimentUnit(nutriments, 'fat'),
                  ) ??
                  0)
              .round(),
      fiber:
          (_massToGrams(
                    _readNutrimentValue(
                      nutriments,
                      'fiber',
                      suffix: basis.nutrimentSuffix,
                    ),
                    unit: _readNutrimentUnit(nutriments, 'fiber'),
                  ) ??
                  0)
              .round(),
      sodium: sodium ?? 0,
      sugar:
          (_massToGrams(
                    _readNutrimentValue(
                      nutriments,
                      'sugars',
                      suffix: basis.nutrimentSuffix,
                    ),
                    unit: _readNutrimentUnit(nutriments, 'sugars'),
                  ) ??
                  0)
              .round(),
    );
  }

  double? _readNutrimentValue(
    Map<String, Object?> nutriments,
    String key, {
    String? suffix,
  }) {
    final keys = <String>[
      if (suffix != null) '${key}_$suffix',
      key,
      '${key}_value',
    ];

    for (final candidate in keys) {
      final value = nutriments[candidate];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value.trim());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }

  String? _readNutrimentUnit(Map<String, Object?> nutriments, String key) {
    final unit = nutriments['${key}_unit'];
    return unit is String ? unit.trim() : null;
  }

  double? _massToGrams(double? value, {String? unit}) {
    if (value == null) {
      return null;
    }

    return switch (_normalizedUnit(unit)) {
      'mg' => value / 1000,
      'kg' => value * 1000,
      _ => value,
    };
  }

  int? _massToMilligrams(double? value, {String? unit}) {
    final grams = _massToGrams(value, unit: unit);
    if (grams == null) {
      return null;
    }
    return (grams * 1000).round();
  }

  _ParsedSize? _parseSimpleSize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final normalized = trimmed
        .replaceAll(RegExp(r'[,;]'), ' ')
        .replaceAllMapped(
          RegExp(r'(?<=\d)(?=[A-Za-z])|(?<=[A-Za-z])(?=\d)'),
          (_) => ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final tokens = normalized.split(' ');
    for (final quantityTokenCount in [3, 2, 1]) {
      if (tokens.length <= quantityTokenCount) {
        continue;
      }
      final quantity = MeasurementUnits.parseQuantity(
        tokens.take(quantityTokenCount).join(' '),
      );
      if (quantity == null || quantity <= 0) {
        continue;
      }
      final unit = tokens.skip(quantityTokenCount).join(' ').trim();
      if (unit.isEmpty) {
        continue;
      }
      return _ParsedSize(quantity: quantity, unit: unit);
    }
    return null;
  }

  String? _normalizedText(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  double? _numericValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  bool _looksLikePlaceholderQuantity(
    String quantity, {
    double? productQuantity,
  }) {
    final leadingValue = RegExp(r'^([0-9]+(?:\.[0-9]+)?)').firstMatch(quantity);
    final parsedLeadingValue = leadingValue == null
        ? null
        : double.tryParse(leadingValue.group(1)!);
    if (parsedLeadingValue != null && parsedLeadingValue <= 0) {
      return true;
    }

    if (productQuantity != null && productQuantity <= 0) {
      final parsed = _parseSimpleSize(quantity);
      if (parsed != null) {
        return parsed.quantity <= 0;
      }
    }

    return false;
  }

  String _normalizedUnit(String? value) {
    return value?.trim().toLowerCase().replaceAll('.', '') ?? '';
  }
}

class UsdaFoodDataCentralPantryBarcodeImporter
    implements PantryBarcodeImporter {
  UsdaFoodDataCentralPantryBarcodeImporter({
    http.Client? client,
    String? apiKey,
  }) : _client = client ?? http.Client(),
       _apiKey = (apiKey == null || apiKey.trim().isEmpty)
           ? _defaultApiKey
           : apiKey.trim();

  final http.Client _client;
  final String _apiKey;

  static const providerLabel = 'USDA FoodData Central';
  static const _defaultApiKey = String.fromEnvironment(
    'USDA_API_KEY',
    defaultValue: 'DEMO_KEY',
  );
  static const _accentOptions = <Color>[
    Color(0xFFD87B42),
    Color(0xFF7B5138),
    Color(0xFF4F6B44),
    Color(0xFF4A6572),
    Color(0xFF8B6F47),
  ];

  @override
  Future<PantryBarcodeImportResult> lookup(String barcode) async {
    final normalizedBarcode = barcode.trim();
    if (normalizedBarcode.isEmpty) {
      throw const PantryBarcodeImportException('Enter a barcode first.');
    }

    late final http.Response response;
    final uri = Uri.https('api.nal.usda.gov', '/fdc/v1/foods/search', {
      'api_key': _apiKey,
      'query': normalizedBarcode,
      'dataType': 'Branded',
      'pageSize': '10',
    });
    try {
      response = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );
    } on Object {
      throw const PantryBarcodeImportException(
        'USDA FoodData Central is not responding right now. Try again in a moment.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const PantryBarcodeImportException(
        'USDA FoodData Central is not responding right now. Try again in a moment.',
      );
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, Object?>) {
      throw const PantryBarcodeImportException(
        'USDA FoodData Central returned an unreadable product response.',
      );
    }

    final foods = payload['foods'];
    if (foods is! List) {
      throw const PantryBarcodeImportException(
        'USDA FoodData Central returned an unreadable product response.',
      );
    }

    final product = foods
        .whereType<Map<String, Object?>>()
        .cast<Map<String, Object?>>()
        .where(
          (food) => _barcodeMatches(
            _normalizedText(food['gtinUpc']),
            normalizedBarcode,
          ),
        )
        .firstOrNull;
    if (product == null) {
      throw const PantryBarcodeImportException(
        'No product was found for that barcode.',
      );
    }

    final nutrients = _readNutrients(product['foodNutrients']);
    if (nutrients.isEmpty) {
      throw const PantryBarcodeImportException(
        'This product does not include nutrition data yet.',
      );
    }

    final basis = _selectBasis(product);
    final nutrition = _buildNutrition(
      nutrients,
      scaleFactor: basis.scaleFactor,
    );
    if (nutrition == NutritionSnapshot.zero) {
      throw const PantryBarcodeImportException(
        'This product does not include enough nutrition data to import.',
      );
    }

    final title = _normalizedText(product['description']) ?? 'Scanned item';
    final brand =
        _normalizedText(product['brandName']) ??
        _normalizedText(product['brandOwner']);
    final quantityLabel =
        _normalizedText(product['packageWeight']) ??
        _normalizedText(product['householdServingFullText']) ??
        'Imported package';

    final draft = PantryItemDraft(
      name: title,
      brand: brand,
      barcode: normalizedBarcode,
      quantityLabel: quantityLabel,
      referenceUnit: basis.referenceUnit,
      referenceUnitQuantity: basis.referenceUnitQuantity,
      source: 'Barcode import + $providerLabel',
      nutrition: nutrition,
      accent:
          _accentOptions[normalizedBarcode.hashCode.abs() %
              _accentOptions.length],
      referenceUnitEquivalentQuantity: basis.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: basis.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: basis.referenceUnitWeightGrams,
    );

    return PantryBarcodeImportResult(
      draft: draft,
      referenceSummary: MeasurementUnits.describeReferenceUnit(
        referenceUnit: draft.referenceUnit,
        referenceUnitQuantity: draft.referenceUnitQuantity,
        referenceUnitEquivalentQuantity: draft.referenceUnitEquivalentQuantity,
        referenceUnitEquivalentUnit: draft.referenceUnitEquivalentUnit,
        referenceUnitWeightGrams: draft.referenceUnitWeightGrams,
      ),
      sourceLabel: providerLabel,
    );
  }

  Map<String, _UsdaNutrientValue> _readNutrients(Object? rawNutrients) {
    if (rawNutrients is! List) {
      return const {};
    }

    final nutrients = <String, _UsdaNutrientValue>{};
    for (final item in rawNutrients.whereType<Map<String, Object?>>()) {
      final number = _normalizedText(item['nutrientNumber']);
      final value = _numericValue(item['value']);
      if (number == null || value == null) {
        continue;
      }
      nutrients[number] = _UsdaNutrientValue(
        value: value,
        unit: _normalizedText(item['unitName']),
      );
    }
    return nutrients;
  }

  _UsdaNutritionBasis _selectBasis(Map<String, Object?> product) {
    final servingSize = _numericValue(product['servingSize']);
    final servingSizeUnit = _normalizedUnit(
      _normalizedText(product['servingSizeUnit']),
    );
    final householdServing = _normalizedText(
      product['householdServingFullText'],
    );
    final parsedHousehold = householdServing == null
        ? null
        : _parseSimpleSize(householdServing);

    if (servingSize != null && servingSize > 0) {
      final scaleFactor = servingSize / 100;
      if (parsedHousehold != null) {
        double? equivalentQuantity;
        String? equivalentUnit;
        double? weightGrams;
        if (_normalizedUnit(parsedHousehold.unit) != servingSizeUnit &&
            servingSizeUnit.isNotEmpty) {
          if (servingSizeUnit == 'g') {
            weightGrams = servingSize;
          } else {
            equivalentQuantity = servingSize;
            equivalentUnit = servingSizeUnit;
          }
        }

        return _UsdaNutritionBasis(
          referenceUnit: parsedHousehold.unit,
          referenceUnitQuantity: parsedHousehold.quantity,
          referenceUnitEquivalentQuantity: equivalentQuantity,
          referenceUnitEquivalentUnit: equivalentUnit,
          referenceUnitWeightGrams: weightGrams,
          scaleFactor: scaleFactor,
        );
      }

      return _UsdaNutritionBasis(
        referenceUnit: 'serving',
        referenceUnitQuantity: 1,
        referenceUnitEquivalentQuantity: servingSizeUnit == 'ml'
            ? servingSize
            : null,
        referenceUnitEquivalentUnit: servingSizeUnit == 'ml' ? 'ml' : null,
        referenceUnitWeightGrams: servingSizeUnit == 'g' ? servingSize : null,
        scaleFactor: scaleFactor,
      );
    }

    return const _UsdaNutritionBasis(
      referenceUnit: 'g',
      referenceUnitQuantity: 100,
      scaleFactor: 1,
    );
  }

  NutritionSnapshot _buildNutrition(
    Map<String, _UsdaNutrientValue> nutrients, {
    required double scaleFactor,
  }) {
    int nutrientValue(String nutrientNumber, {String? expectedUnit}) {
      final nutrient = nutrients[nutrientNumber];
      if (nutrient == null) {
        return 0;
      }

      final scaledValue = nutrient.value * scaleFactor;
      if (expectedUnit == null) {
        return scaledValue.round();
      }

      return switch (_normalizedUnit(nutrient.unit)) {
        'mg' when expectedUnit == 'g' => (scaledValue / 1000).round(),
        'kg' when expectedUnit == 'g' => (scaledValue * 1000).round(),
        'g' when expectedUnit == 'mg' => (scaledValue * 1000).round(),
        _ => scaledValue.round(),
      };
    }

    return NutritionSnapshot(
      calories: nutrientValue('208'),
      protein: nutrientValue('203', expectedUnit: 'g'),
      carbs: nutrientValue('205', expectedUnit: 'g'),
      fat: nutrientValue('204', expectedUnit: 'g'),
      fiber: nutrientValue('291', expectedUnit: 'g'),
      sodium: nutrientValue('307', expectedUnit: 'mg'),
      sugar: nutrientValue('269', expectedUnit: 'g'),
    );
  }

  _ParsedSize? _parseSimpleSize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final normalized = trimmed
        .replaceAll(RegExp(r'[,;]'), ' ')
        .replaceAllMapped(
          RegExp(r'(?<=\d)(?=[A-Za-z])|(?<=[A-Za-z])(?=\d)'),
          (_) => ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final tokens = normalized.split(' ');
    for (final quantityTokenCount in [3, 2, 1]) {
      if (tokens.length <= quantityTokenCount) {
        continue;
      }
      final quantity = MeasurementUnits.parseQuantity(
        tokens.take(quantityTokenCount).join(' '),
      );
      if (quantity == null || quantity <= 0) {
        continue;
      }
      final unit = tokens.skip(quantityTokenCount).join(' ').trim();
      if (unit.isEmpty) {
        continue;
      }
      return _ParsedSize(quantity: quantity, unit: unit.toLowerCase());
    }
    return null;
  }

  String? _normalizedText(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  double? _numericValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }

  String _normalizedUnit(String? value) {
    return value?.trim().toLowerCase().replaceAll('.', '') ?? '';
  }

  bool _barcodeMatches(String? gtinUpc, String barcode) {
    if (gtinUpc == null) {
      return false;
    }

    final normalizedCandidate = gtinUpc.replaceAll(RegExp(r'\D'), '');
    final normalizedBarcode = barcode.replaceAll(RegExp(r'\D'), '');
    if (normalizedCandidate == normalizedBarcode) {
      return true;
    }

    return normalizedCandidate.replaceFirst(RegExp(r'^0+(?=\d)'), '') ==
        normalizedBarcode.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  }
}

class _NutritionBasis {
  const _NutritionBasis({
    required this.referenceUnit,
    required this.referenceUnitQuantity,
    required this.nutrimentSuffix,
    this.referenceUnitEquivalentQuantity,
    this.referenceUnitEquivalentUnit,
    this.referenceUnitWeightGrams,
  });

  final String referenceUnit;
  final double referenceUnitQuantity;
  final double? referenceUnitEquivalentQuantity;
  final String? referenceUnitEquivalentUnit;
  final double? referenceUnitWeightGrams;
  final String? nutrimentSuffix;

  _NutritionBasis copyWith({String? nutrimentSuffix}) {
    return _NutritionBasis(
      referenceUnit: referenceUnit,
      referenceUnitQuantity: referenceUnitQuantity,
      referenceUnitEquivalentQuantity: referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: referenceUnitWeightGrams,
      nutrimentSuffix: nutrimentSuffix,
    );
  }
}

class _UsdaNutritionBasis {
  const _UsdaNutritionBasis({
    required this.referenceUnit,
    required this.referenceUnitQuantity,
    required this.scaleFactor,
    this.referenceUnitEquivalentQuantity,
    this.referenceUnitEquivalentUnit,
    this.referenceUnitWeightGrams,
  });

  final String referenceUnit;
  final double referenceUnitQuantity;
  final double? referenceUnitEquivalentQuantity;
  final String? referenceUnitEquivalentUnit;
  final double? referenceUnitWeightGrams;
  final double scaleFactor;
}

class _UsdaNutrientValue {
  const _UsdaNutrientValue({required this.value, this.unit});

  final double value;
  final String? unit;
}

class _ParsedSize {
  const _ParsedSize({required this.quantity, required this.unit});

  final double quantity;
  final String unit;

  @override
  bool operator ==(Object other) {
    return other is _ParsedSize &&
        other.quantity == quantity &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(quantity, unit);
}
