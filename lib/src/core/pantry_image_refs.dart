String? normalizedNetworkImageUrl(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
    return null;
  }
  return trimmed;
}

const _localPantryImagePrefix = 'local-image:';

String createLocalPantryImageRef(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(
      path,
      'path',
      'Local pantry image path is empty.',
    );
  }
  return '$_localPantryImagePrefix$trimmed';
}

bool isLocalPantryImageRef(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.startsWith(_localPantryImagePrefix);
}

String? localPantryImagePath(String? value) {
  if (!isLocalPantryImageRef(value)) {
    return null;
  }
  final trimmed = value!.trim();
  final path = trimmed.substring(_localPantryImagePrefix.length).trim();
  return path.isEmpty ? null : path;
}

String? pantryImageUrlForCloud(String? value) {
  return normalizedNetworkImageUrl(value);
}
