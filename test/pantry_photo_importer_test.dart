import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/src/core/pantry_image_refs.dart';
import 'package:recipe_app/src/data/import/pantry_photo_importer.dart';

void main() {
  test(
    'pantry photo importer returns null when selection is canceled',
    () async {
      final importer = PantryPhotoImporter(
        picker: _FakePantryPhotoPicker(),
        store: _FakePantryPhotoStore(),
      );

      final result = await importer.pickPhoto(PantryPhotoSource.gallery);

      expect(result, isNull);
    },
  );

  test(
    'pantry photo importer persists a picked photo as a local image ref',
    () async {
      final importer = PantryPhotoImporter(
        picker: _FakePantryPhotoPicker(
          pickedPhoto: const PickedPantryPhoto(
            path: '/tmp/pantry/apple.jpg',
            label: 'apple.jpg',
            source: PantryPhotoSource.gallery,
          ),
        ),
        store: _FakePantryPhotoStore(
          persistedRef: createLocalPantryImageRef(
            '/app/pantry_photos/apple.jpg',
          ),
        ),
      );

      final picked = await importer.pickPhoto(PantryPhotoSource.gallery);
      final persisted = await importer.persistPickedPhoto(picked!);

      expect(localPantryImagePath(persisted), '/app/pantry_photos/apple.jpg');
      expect(
        picked.previewRef,
        createLocalPantryImageRef('/tmp/pantry/apple.jpg'),
      );
    },
  );
}

class _FakePantryPhotoPicker implements PantryPhotoPicker {
  _FakePantryPhotoPicker({this.pickedPhoto});

  final PickedPantryPhoto? pickedPhoto;

  @override
  Future<PickedPantryPhoto?> pick(PantryPhotoSource source) async =>
      pickedPhoto;
}

class _FakePantryPhotoStore implements PantryPhotoStore {
  _FakePantryPhotoStore({
    this.persistedRef = 'local-image:/app/pantry_photos/default.jpg',
  });

  final String persistedRef;

  @override
  Future<void> deleteStoredPhoto(String imageRef) async {}

  @override
  Future<String> persistPickedPhoto(PickedPantryPhoto photo) async {
    return persistedRef;
  }
}
