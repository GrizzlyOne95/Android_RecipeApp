import 'package:flutter/widgets.dart';

import '../../core/pantry_image_refs.dart';
import 'pantry_local_image_provider_stub.dart'
    if (dart.library.io) 'pantry_local_image_provider_io.dart'
    as local_image;

ImageProvider<Object>? pantryLocalImageProvider(String? imageRef) {
  final localPath = localPantryImagePath(imageRef);
  if (localPath == null) {
    return null;
  }
  return local_image.pantryLocalImageProviderForPath(localPath);
}
