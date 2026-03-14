enum LinkedQuantityIssue { invalidQuantity, incompatibleUnit }

class LinkedQuantityResolution {
  const LinkedQuantityResolution._({
    required this.referenceUnits,
    required this.issue,
  });

  const LinkedQuantityResolution.resolved(double referenceUnits)
    : this._(referenceUnits: referenceUnits, issue: null);

  const LinkedQuantityResolution.invalidQuantity()
    : this._(referenceUnits: null, issue: LinkedQuantityIssue.invalidQuantity);

  const LinkedQuantityResolution.incompatibleUnit()
    : this._(referenceUnits: null, issue: LinkedQuantityIssue.incompatibleUnit);

  final double? referenceUnits;
  final LinkedQuantityIssue? issue;

  bool get isResolved => referenceUnits != null;
}

abstract final class MeasurementUnits {
  static double? parseQuantity(String rawQuantity) {
    final trimmed = rawQuantity.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.contains(' ')) {
      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length == 2) {
        final whole = double.tryParse(parts[0]);
        final fraction = _parseFraction(parts[1]);
        if (whole != null && fraction != null) {
          return whole + fraction;
        }
      }
    }

    final fraction = _parseFraction(trimmed);
    if (fraction != null) {
      return fraction;
    }

    return double.tryParse(trimmed);
  }

  static LinkedQuantityResolution resolveLinkedReferenceUnits({
    required double? quantity,
    required String ingredientUnit,
    required String referenceUnit,
    double referenceUnitQuantity = 1,
    double? referenceUnitEquivalentQuantity,
    String? referenceUnitEquivalentUnit,
    double? referenceUnitWeightGrams,
  }) {
    if (quantity == null || quantity <= 0) {
      return const LinkedQuantityResolution.invalidQuantity();
    }

    final normalizedIngredientUnit = _normalizeComparableUnit(ingredientUnit);
    final normalizedReferenceUnit = _normalizeComparableUnit(referenceUnit);

    final normalizedReferenceUnitQuantity = referenceUnitQuantity > 0
        ? referenceUnitQuantity
        : 1.0;

    if (normalizedIngredientUnit.isEmpty ||
        _unitsMatch(normalizedIngredientUnit, normalizedReferenceUnit)) {
      return LinkedQuantityResolution.resolved(
        quantity / normalizedReferenceUnitQuantity,
      );
    }

    final convertedToReferenceUnit = _convertBetweenUnits(
      quantity: quantity,
      fromUnit: ingredientUnit,
      toUnit: referenceUnit,
    );
    if (convertedToReferenceUnit != null) {
      return LinkedQuantityResolution.resolved(
        convertedToReferenceUnit / normalizedReferenceUnitQuantity,
      );
    }

    if (referenceUnitEquivalentQuantity != null &&
        referenceUnitEquivalentQuantity > 0 &&
        referenceUnitEquivalentUnit != null &&
        referenceUnitEquivalentUnit.trim().isNotEmpty) {
      final convertedToEquivalentUnit = _convertBetweenUnits(
        quantity: quantity,
        fromUnit: ingredientUnit,
        toUnit: referenceUnitEquivalentUnit,
      );
      if (convertedToEquivalentUnit != null) {
        return LinkedQuantityResolution.resolved(
          convertedToEquivalentUnit / referenceUnitEquivalentQuantity,
        );
      }
    }

    if (referenceUnitWeightGrams != null && referenceUnitWeightGrams > 0) {
      final convertedToGrams = _convertBetweenUnits(
        quantity: quantity,
        fromUnit: ingredientUnit,
        toUnit: 'g',
      );
      if (convertedToGrams != null) {
        return LinkedQuantityResolution.resolved(
          convertedToGrams / referenceUnitWeightGrams,
        );
      }
    }

    return const LinkedQuantityResolution.incompatibleUnit();
  }

  static double? tryConvertQuantity({
    required double quantity,
    required String fromUnit,
    required String toUnit,
  }) {
    return _convertBetweenUnits(
      quantity: quantity,
      fromUnit: fromUnit,
      toUnit: toUnit,
    );
  }

  static String describeReferenceUnit({
    required String referenceUnit,
    double referenceUnitQuantity = 1,
    double? referenceUnitEquivalentQuantity,
    String? referenceUnitEquivalentUnit,
    double? referenceUnitWeightGrams,
  }) {
    final effectiveQuantity = referenceUnitQuantity > 0
        ? referenceUnitQuantity
        : 1.0;
    final normalizedReferenceUnit = _normalizeComparableUnit(referenceUnit);
    final parts = <String>[
      '${formatDecimal(effectiveQuantity)} ${referenceUnit.trim()}',
    ];

    if (referenceUnitWeightGrams != null && referenceUnitWeightGrams > 0) {
      final shouldAddWeight =
          normalizedReferenceUnit != 'g' ||
          (referenceUnitWeightGrams - effectiveQuantity).abs() >= 0.001;
      if (shouldAddWeight) {
        parts.add('${formatDecimal(referenceUnitWeightGrams)} g');
      }
    }

    if (referenceUnitEquivalentQuantity != null &&
        referenceUnitEquivalentQuantity > 0 &&
        referenceUnitEquivalentUnit != null &&
        referenceUnitEquivalentUnit.trim().isNotEmpty &&
        !_unitsMatch(
          _normalizeComparableUnit(referenceUnitEquivalentUnit),
          normalizedReferenceUnit,
        )) {
      parts.add(
        '${formatDecimal(referenceUnitEquivalentQuantity)} ${referenceUnitEquivalentUnit.trim()}',
      );
    }

    return parts.join(' = ');
  }

  static String formatDecimal(double value) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.001) {
      return rounded.toInt().toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static double? _parseFraction(String value) {
    final parts = value.split('/');
    if (parts.length != 2) {
      return null;
    }

    final numerator = double.tryParse(parts[0]);
    final denominator = double.tryParse(parts[1]);
    if (numerator == null || denominator == null || denominator == 0) {
      return null;
    }

    return numerator / denominator;
  }

  static double? _convertBetweenUnits({
    required double quantity,
    required String fromUnit,
    required String toUnit,
  }) {
    final normalizedFromUnit = _normalizeComparableUnit(fromUnit);
    final normalizedToUnit = _normalizeComparableUnit(toUnit);

    if (_unitsMatch(normalizedFromUnit, normalizedToUnit)) {
      return quantity;
    }

    final fromMassUnit = _canonicalMassUnits[normalizedFromUnit];
    final toMassUnit = _canonicalMassUnits[normalizedToUnit];
    if (fromMassUnit != null && toMassUnit != null) {
      return quantity * fromMassUnit / toMassUnit;
    }

    final fromVolumeUnit = _canonicalVolumeUnits[normalizedFromUnit];
    final toVolumeUnit = _canonicalVolumeUnits[normalizedToUnit];
    if (fromVolumeUnit != null && toVolumeUnit != null) {
      return quantity * fromVolumeUnit / toVolumeUnit;
    }

    final discreteFromGroup = _discreteUnitGroups[normalizedFromUnit];
    final discreteToGroup = _discreteUnitGroups[normalizedToUnit];
    if (discreteFromGroup != null &&
        discreteToGroup != null &&
        discreteFromGroup == discreteToGroup) {
      return quantity;
    }

    return null;
  }

  static bool _unitsMatch(String normalizedLeft, String normalizedRight) {
    if (normalizedLeft == normalizedRight) {
      return true;
    }

    return _discreteUnitGroups[normalizedLeft] != null &&
        _discreteUnitGroups[normalizedLeft] ==
            _discreteUnitGroups[normalizedRight];
  }

  static String _normalizeComparableUnit(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return '';
    }

    final withoutPunctuation = trimmed
        .replaceAll('.', '')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final alias = _unitAliases[withoutPunctuation];
    if (alias != null) {
      return alias;
    }

    final words = withoutPunctuation
        .split(' ')
        .map(_singularizeToken)
        .join(' ')
        .trim();
    return _unitAliases[words] ?? words;
  }

  static String _singularizeToken(String token) {
    if (token.length <= 3) {
      return token;
    }
    if (token.endsWith('ies')) {
      return '${token.substring(0, token.length - 3)}y';
    }
    if (token.endsWith('es') &&
        (token.endsWith('ches') ||
            token.endsWith('shes') ||
            token.endsWith('xes') ||
            token.endsWith('ses'))) {
      return token.substring(0, token.length - 2);
    }
    if (token.endsWith('s') && !token.endsWith('ss')) {
      return token.substring(0, token.length - 1);
    }
    return token;
  }

  static const _canonicalMassUnits = <String, double>{
    'mg': 0.001,
    'g': 1,
    'kg': 1000,
    'oz': 28.349523125,
    'lb': 453.59237,
  };

  static const _canonicalVolumeUnits = <String, double>{
    'ml': 1,
    'cl': 10,
    'dl': 100,
    'l': 1000,
    'tsp': 4.92892159375,
    'tbsp': 14.78676478125,
    'fl oz': 29.5735295625,
    'cup': 236.5882365,
    'pint': 473.176473,
    'quart': 946.352946,
    'gallon': 3785.411784,
    'imp tsp': 5.919388020833333,
    'imp tbsp': 17.7581640625,
    'imp fl oz': 28.4130625,
    'imp cup': 284.130625,
    'imp pint': 568.26125,
    'imp quart': 1136.5225,
    'imp gallon': 4546.09,
  };

  static const _discreteUnitGroups = <String, String>{
    'serving': 'serving',
    'portion': 'serving',
    'meal': 'meal',
    'each': 'each',
    'ea': 'each',
    'item': 'each',
    'whole': 'each',
    'unit': 'each',
    'piece': 'each',
    'pc': 'each',
    'can': 'can',
    'tin': 'can',
    'package': 'package',
    'pack': 'package',
    'packet': 'package',
    'pkg': 'package',
    'bottle': 'bottle',
    'slice': 'slice',
    'clove': 'clove',
    'filet': 'filet',
    'fillet': 'filet',
    'egg': 'egg',
  };

  static const _unitAliases = <String, String>{
    'milligram': 'mg',
    'milligrams': 'mg',
    'gram': 'g',
    'grams': 'g',
    'kilogram': 'kg',
    'kilograms': 'kg',
    'ounce': 'oz',
    'ounces': 'oz',
    'pound': 'lb',
    'pounds': 'lb',
    'milliliter': 'ml',
    'milliliters': 'ml',
    'millilitre': 'ml',
    'millilitres': 'ml',
    'cc': 'ml',
    'centiliter': 'cl',
    'centiliters': 'cl',
    'centilitre': 'cl',
    'centilitres': 'cl',
    'deciliter': 'dl',
    'deciliters': 'dl',
    'decilitre': 'dl',
    'decilitres': 'dl',
    'liter': 'l',
    'liters': 'l',
    'litre': 'l',
    'litres': 'l',
    'teaspoon': 'tsp',
    'teaspoons': 'tsp',
    'tablespoon': 'tbsp',
    'tablespoons': 'tbsp',
    'fluid ounce': 'fl oz',
    'fluid ounces': 'fl oz',
    'floz': 'fl oz',
    'cups': 'cup',
    'pt': 'pint',
    'pts': 'pint',
    'qt': 'quart',
    'qts': 'quart',
    'gal': 'gallon',
    'gals': 'gallon',
    'imperial teaspoon': 'imp tsp',
    'imperial teaspoons': 'imp tsp',
    'uk teaspoon': 'imp tsp',
    'uk teaspoons': 'imp tsp',
    'imperial tablespoon': 'imp tbsp',
    'imperial tablespoons': 'imp tbsp',
    'uk tablespoon': 'imp tbsp',
    'uk tablespoons': 'imp tbsp',
    'imperial fluid ounce': 'imp fl oz',
    'imperial fluid ounces': 'imp fl oz',
    'uk fluid ounce': 'imp fl oz',
    'uk fluid ounces': 'imp fl oz',
    'imperial cup': 'imp cup',
    'imperial cups': 'imp cup',
    'uk cup': 'imp cup',
    'uk cups': 'imp cup',
    'imperial pint': 'imp pint',
    'imperial pints': 'imp pint',
    'uk pint': 'imp pint',
    'uk pints': 'imp pint',
    'imperial quart': 'imp quart',
    'imperial quarts': 'imp quart',
    'uk quart': 'imp quart',
    'uk quarts': 'imp quart',
    'imperial gallon': 'imp gallon',
    'imperial gallons': 'imp gallon',
    'uk gallon': 'imp gallon',
    'uk gallons': 'imp gallon',
    'servings': 'serving',
    'portions': 'portion',
    'meals': 'meal',
    'eaches': 'each',
    'items': 'item',
    'wholes': 'whole',
    'units': 'unit',
    'pieces': 'piece',
    'pcs': 'pc',
    'cans': 'can',
    'tins': 'tin',
    'packages': 'package',
    'packs': 'pack',
    'packets': 'packet',
    'pkgs': 'pkg',
    'bottles': 'bottle',
    'slices': 'slice',
    'cloves': 'clove',
    'filets': 'filet',
    'fillets': 'fillet',
    'eggs': 'egg',
  };
}
