import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/pantry_image_refs.dart';

enum PantryPhotoSource { gallery, camera }

class PantryPhotoImportException implements Exception {
  const PantryPhotoImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PickedPantryPhoto {
  const PickedPantryPhoto({
    required this.path,
    required this.label,
    required this.source,
  });

  final String path;
  final String label;
  final PantryPhotoSource source;

  String get previewRef => createLocalPantryImageRef(path);
}

abstract interface class PantryPhotoPicker {
  Future<PickedPantryPhoto?> pick(PantryPhotoSource source);
}

abstract interface class PantryPhotoStore {
  Future<String> persistPickedPhoto(PickedPantryPhoto photo);

  Future<void> deleteStoredPhoto(String imageRef);
}

class PantryPhotoImporter {
  PantryPhotoImporter({PantryPhotoPicker? picker, PantryPhotoStore? store})
    : _picker = picker ?? ImagePickerPantryPhotoPicker(),
      _store = store ?? AppDocumentsPantryPhotoStore();

  final PantryPhotoPicker _picker;
  final PantryPhotoStore _store;

  Future<PickedPantryPhoto?> pickPhoto(PantryPhotoSource source) {
    return _picker.pick(source);
  }

  Future<String> persistPickedPhoto(PickedPantryPhoto photo) {
    return _store.persistPickedPhoto(photo);
  }

  Future<void> deleteStoredPhoto(String imageRef) {
    return _store.deleteStoredPhoto(imageRef);
  }
}

class ImagePickerPantryPhotoPicker implements PantryPhotoPicker {
  ImagePickerPantryPhotoPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedPantryPhoto?> pick(PantryPhotoSource source) async {
    try {
      final image = await _picker.pickImage(
        source: switch (source) {
          PantryPhotoSource.gallery => ImageSource.gallery,
          PantryPhotoSource.camera => ImageSource.camera,
        },
        imageQuality: 88,
        maxWidth: 1800,
      );
      if (image == null) {
        return null;
      }

      final label = path.basename(image.path).trim();
      return PickedPantryPhoto(
        path: image.path,
        label: label.isEmpty ? 'pantry-photo.jpg' : label,
        source: source,
      );
    } on Exception catch (error) {
      throw PantryPhotoImportException(
        'Could not load a pantry photo right now. ${error.toString()}',
      );
    }
  }
}

class AppDocumentsPantryPhotoStore implements PantryPhotoStore {
  @override
  Future<String> persistPickedPhoto(PickedPantryPhoto photo) async {
    final sourceFile = File(photo.path);
    if (!await sourceFile.exists()) {
      throw const PantryPhotoImportException(
        'The selected pantry photo is no longer available.',
      );
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final pantryPhotoDirectory = Directory(
      path.join(documentsDirectory.path, 'pantry_photos'),
    );
    await pantryPhotoDirectory.create(recursive: true);

    final extension = path.extension(photo.path).trim().toLowerCase();
    final baseName = path
        .basenameWithoutExtension(photo.label)
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
    final safeBaseName = baseName.isEmpty ? 'pantry_photo' : baseName;
    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_$safeBaseName${extension.isEmpty ? '.jpg' : extension}';
    final destinationPath = path.join(pantryPhotoDirectory.path, fileName);

    final persistedFile = await sourceFile.copy(destinationPath);
    return createLocalPantryImageRef(persistedFile.path);
  }

  @override
  Future<void> deleteStoredPhoto(String imageRef) async {
    final localPath = localPantryImagePath(imageRef);
    if (localPath == null) {
      return;
    }

    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
