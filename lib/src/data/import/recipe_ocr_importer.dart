import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class RecipeOcrImportResult {
  const RecipeOcrImportResult({
    required this.extractedText,
    required this.imageLabel,
    required this.warnings,
  });

  final String extractedText;
  final String imageLabel;
  final List<String> warnings;
}

class PickedRecipeImage {
  const PickedRecipeImage({required this.path, required this.label});

  final String path;
  final String label;
}

class RecipeOcrImportException implements Exception {
  const RecipeOcrImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class RecipeOcrImagePicker {
  Future<PickedRecipeImage?> pickFromGallery();
}

abstract interface class RecipeOcrTextRecognizer {
  Future<String> recognizeText(String imagePath);
}

class RecipeOcrImporter {
  RecipeOcrImporter({
    RecipeOcrImagePicker? imagePicker,
    RecipeOcrTextRecognizer? textRecognizer,
  }) : _imagePicker = imagePicker ?? ImagePickerRecipeOcrImagePicker(),
       _textRecognizer = textRecognizer ?? MlKitRecipeOcrTextRecognizer();

  final RecipeOcrImagePicker _imagePicker;
  final RecipeOcrTextRecognizer _textRecognizer;

  Future<RecipeOcrImportResult?> importFromGallery() async {
    final image = await _imagePicker.pickFromGallery();
    if (image == null) {
      return null;
    }

    final rawText = await _textRecognizer.recognizeText(image.path);
    final extractedText = _normalizeRecognizedText(rawText);
    if (extractedText.isEmpty) {
      throw const RecipeOcrImportException(
        'The selected screenshot did not contain readable recipe text.',
      );
    }

    return RecipeOcrImportResult(
      extractedText: extractedText,
      imageLabel: image.label,
      warnings: [
        'OCR text was extracted from ${image.label}. Review quantities, units, and directions before saving.',
      ],
    );
  }

  String _normalizeRecognizedText(String rawText) {
    return rawText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u00a0', ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

class ImagePickerRecipeOcrImagePicker implements RecipeOcrImagePicker {
  ImagePickerRecipeOcrImagePicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedRecipeImage?> pickFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }

    final label = path.basename(image.path).trim();
    return PickedRecipeImage(
      path: image.path,
      label: label.isEmpty ? 'selected screenshot' : label,
    );
  }
}

class MlKitRecipeOcrTextRecognizer implements RecipeOcrTextRecognizer {
  MlKitRecipeOcrTextRecognizer({
    TextRecognitionScript script = TextRecognitionScript.latin,
  }) : _script = script;

  final TextRecognitionScript _script;

  @override
  Future<String> recognizeText(String imagePath) async {
    final recognizer = TextRecognizer(script: _script);
    try {
      final recognizedText = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      return recognizedText.text;
    } finally {
      await recognizer.close();
    }
  }
}
