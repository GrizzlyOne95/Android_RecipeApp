import 'dart:io';

import 'package:flutter/widgets.dart';

ImageProvider<Object>? pantryLocalImageProviderForPath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  return FileImage(File(trimmed));
}
