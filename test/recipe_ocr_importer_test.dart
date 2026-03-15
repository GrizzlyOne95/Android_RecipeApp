import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/src/data/import/recipe_ocr_importer.dart';

void main() {
  test('ocr importer returns null when image selection is canceled', () async {
    final importer = RecipeOcrImporter(
      imagePicker: _FakeImagePicker(),
      textRecognizer: _FakeTextRecognizer(),
    );

    final result = await importer.importFromGallery();

    expect(result, isNull);
  });

  test('ocr importer extracts recognized text and warning context', () async {
    final importer = RecipeOcrImporter(
      imagePicker: _FakeImagePicker(
        image: const PickedRecipeImage(
          path: '/tmp/recipe-shot.png',
          label: 'recipe-shot.png',
        ),
      ),
      textRecognizer: _FakeTextRecognizer(
        text: 'Skillet Pasta\r\n\r\nIngredients\n1 lb pasta',
      ),
    );

    final result = await importer.importFromGallery();

    expect(result, isNotNull);
    expect(result!.imageLabel, 'recipe-shot.png');
    expect(result.extractedText, 'Skillet Pasta\n\nIngredients\n1 lb pasta');
    expect(result.warnings.single, contains('recipe-shot.png'));
  });

  test('ocr importer throws when no readable text is detected', () async {
    final importer = RecipeOcrImporter(
      imagePicker: _FakeImagePicker(
        image: const PickedRecipeImage(
          path: '/tmp/empty-shot.png',
          label: 'empty-shot.png',
        ),
      ),
      textRecognizer: _FakeTextRecognizer(text: '   '),
    );

    expect(
      importer.importFromGallery,
      throwsA(
        isA<RecipeOcrImportException>().having(
          (error) => error.message,
          'message',
          contains('did not contain readable recipe text'),
        ),
      ),
    );
  });
}

class _FakeImagePicker implements RecipeOcrImagePicker {
  _FakeImagePicker({this.image});

  final PickedRecipeImage? image;

  @override
  Future<PickedRecipeImage?> pickFromGallery() async => image;
}

class _FakeTextRecognizer implements RecipeOcrTextRecognizer {
  _FakeTextRecognizer({this.text = ''});

  final String text;

  @override
  Future<String> recognizeText(String imagePath) async => text;
}
