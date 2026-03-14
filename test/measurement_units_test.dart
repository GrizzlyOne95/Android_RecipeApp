import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/src/core/measurement_units.dart';

void main() {
  test('measurement units convert U.S., metric, and imperial aliases', () {
    final usToMetric = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: 16,
      ingredientUnit: 'tbsp',
      referenceUnit: 'cup',
    );
    final metricToMetric = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: 1,
      ingredientUnit: 'l',
      referenceUnit: 'ml',
    );
    final imperialToMetric = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: 1,
      ingredientUnit: 'imperial pint',
      referenceUnit: 'ml',
    );

    expect(usToMetric.referenceUnits, closeTo(1, 0.000001));
    expect(metricToMetric.referenceUnits, closeTo(1000, 0.000001));
    expect(imperialToMetric.referenceUnits, closeTo(568.26125, 0.000001));
  });

  test('measurement units use pantry overrides for serving-based links', () {
    final byVolume = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: 12,
      ingredientUnit: 'tbsp',
      referenceUnit: 'serving',
      referenceUnitEquivalentQuantity: 0.75,
      referenceUnitEquivalentUnit: 'cup',
      referenceUnitWeightGrams: 170,
    );
    final byWeight = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: 170,
      ingredientUnit: 'g',
      referenceUnit: 'serving',
      referenceUnitEquivalentQuantity: 0.75,
      referenceUnitEquivalentUnit: 'cup',
      referenceUnitWeightGrams: 170,
    );

    expect(byVolume.referenceUnits, closeTo(1, 0.000001));
    expect(byWeight.referenceUnits, closeTo(1, 0.000001));
  });

  test('measurement units support multi-unit pantry nutrition bases', () {
    final halfOfHundredGrams = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: 50,
      ingredientUnit: 'g',
      referenceUnit: 'g',
      referenceUnitQuantity: 100,
    );
    final halfOfTwoTablespoons = MeasurementUnits.resolveLinkedReferenceUnits(
      quantity: 1,
      ingredientUnit: 'tbsp',
      referenceUnit: 'tbsp',
      referenceUnitQuantity: 2,
      referenceUnitWeightGrams: 32,
    );

    expect(halfOfHundredGrams.referenceUnits, closeTo(0.5, 0.000001));
    expect(halfOfTwoTablespoons.referenceUnits, closeTo(0.5, 0.000001));
    expect(
      MeasurementUnits.describeReferenceUnit(
        referenceUnit: 'g',
        referenceUnitQuantity: 100,
      ),
      '100 g',
    );
  });
}
