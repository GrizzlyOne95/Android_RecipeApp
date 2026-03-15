import 'mock_data.dart';

enum RecipeImportMode { textPaste, urlPaste, ocrPaste }

class RecipeImportResult {
  const RecipeImportResult({required this.draft, required this.warnings});

  final RecipeDraft draft;
  final List<String> warnings;
}

abstract final class RecipeImportParser {
  static RecipeImportResult parse({
    required RecipeImportMode mode,
    String rawText = '',
    String sourceUrl = '',
  }) {
    final normalizedText = _normalizeText(rawText);
    final lines = normalizedText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    final warnings = <String>[];
    final sections = _collectSections(lines);

    final title = _extractTitle(lines, sourceUrl);
    final servings = _extractServings(lines) ?? 1;
    if (_extractServings(lines) == null) {
      warnings.add('Servings were not found. Defaulted to 1.');
    }

    final ingredients = _extractIngredients(sections, lines);
    if (ingredients.isEmpty) {
      warnings.add('No ingredients were detected. Add them in the editor.');
    }

    final directions = _extractDirections(sections, lines);
    if (directions.isEmpty) {
      warnings.add('No directions were detected. Add them in the editor.');
    }

    final nutrition = _extractNutrition(lines);
    final metadataNotes = _extractMetadataNotes(lines);
    final noteLines = <String>[
      if (sourceUrl.trim().isNotEmpty) 'Imported from: ${sourceUrl.trim()}',
      if (mode == RecipeImportMode.ocrPaste)
        'Imported from OCR text. Double-check quantities and instructions.',
      ...metadataNotes,
      ...?sections['notes'],
    ];
    final tags = <String>{
      'Imported',
      switch (mode) {
        RecipeImportMode.textPaste => 'Text import',
        RecipeImportMode.urlPaste => 'URL import',
        RecipeImportMode.ocrPaste => 'OCR import',
      },
      ..._extractTags(lines),
    }.toList(growable: false);

    return RecipeImportResult(
      draft: RecipeDraft(
        name: title,
        versionLabel: switch (mode) {
          RecipeImportMode.textPaste => 'Imported Text Draft',
          RecipeImportMode.urlPaste => 'Imported URL Draft',
          RecipeImportMode.ocrPaste => 'Imported OCR Draft',
        },
        servings: servings,
        note: noteLines.join('\n').trim(),
        tags: tags,
        isPinned: false,
        nutrition: nutrition,
        ingredients: ingredients,
        directions: directions,
      ),
      warnings: warnings,
    );
  }

  static String _normalizeText(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('½', '1/2')
        .replaceAll('¼', '1/4')
        .replaceAll('¾', '3/4')
        .replaceAll('⅓', '1/3')
        .replaceAll('⅔', '2/3')
        .replaceAll('⅛', '1/8');
  }

  static Map<String, List<String>> _collectSections(List<String> lines) {
    final sections = <String, List<String>>{};
    var currentSection = 'body';

    for (final line in lines) {
      final detectedSection = _sectionForLine(line);
      if (detectedSection != null) {
        currentSection = detectedSection;
        sections.putIfAbsent(currentSection, () => <String>[]);
        continue;
      }
      sections.putIfAbsent(currentSection, () => <String>[]).add(line);
    }

    return sections;
  }

  static String? _sectionForLine(String line) {
    final normalized = line
        .toLowerCase()
        .replaceAll(':', '')
        .replaceAll(RegExp(r'[^a-z\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized == 'ingredients' || normalized == 'ingredient') {
      return 'ingredients';
    }
    if ({
      'what you ll need',
      'what youll need',
      'you will need',
      'for the recipe',
      'ingredient list',
    }.contains(normalized)) {
      return 'ingredients';
    }
    if ({
      'instructions',
      'instruction',
      'directions',
      'method',
      'steps',
      'preparation',
      'how to make it',
      'method of preparation',
    }.contains(normalized)) {
      return 'directions';
    }
    if (normalized == 'notes' || normalized == 'note') {
      return 'notes';
    }
    if (normalized == 'nutrition' ||
        normalized == 'nutrition facts' ||
        normalized.startsWith('nutrition ')) {
      return 'nutrition';
    }
    return null;
  }

  static String _extractTitle(List<String> lines, String sourceUrl) {
    for (final line in lines) {
      if (_sectionForLine(line) != null) {
        continue;
      }
      if (_looksLikeMetadata(line)) {
        continue;
      }
      return _cleanTitle(line);
    }

    final parsedUrl = Uri.tryParse(sourceUrl.trim());
    final slug = parsedUrl?.pathSegments.reversed.firstWhere(
      (segment) => segment.trim().isNotEmpty,
      orElse: () => '',
    );
    if (slug != null && slug.trim().isNotEmpty) {
      return _cleanTitle(
        slug
            .replaceAll('-', ' ')
            .replaceAll('_', ' ')
            .replaceAllMapped(
              RegExp(r'\b[a-z]'),
              (match) => match.group(0)!.toUpperCase(),
            ),
      );
    }

    return 'Imported Recipe';
  }

  static String _cleanTitle(String line) {
    return line.replaceAll(RegExp(r'^[#*\-\d\.\)\s]+'), '').trim();
  }

  static bool _looksLikeMetadata(String line) {
    final normalized = line.toLowerCase();
    return normalized.startsWith('serves') ||
        normalized.startsWith('servings') ||
        normalized.startsWith('yield') ||
        normalized.startsWith('makes') ||
        normalized.startsWith('prep time') ||
        normalized.startsWith('cook time') ||
        normalized.startsWith('total time') ||
        normalized.startsWith('active time') ||
        normalized.startsWith('http://') ||
        normalized.startsWith('https://');
  }

  static int? _extractServings(List<String> lines) {
    for (final line in lines) {
      final match = RegExp(
        r'(serves|servings|yield|makes)\s*:?\s*(\d+)',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) {
        return int.tryParse(match.group(2)!);
      }
    }
    return null;
  }

  static List<RecipeIngredientDraft> _extractIngredients(
    Map<String, List<String>> sections,
    List<String> lines,
  ) {
    final ingredientLines = sections['ingredients'] ?? <String>[];
    if (ingredientLines.isNotEmpty) {
      return ingredientLines
          .map(_parseIngredientLine)
          .whereType<RecipeIngredientDraft>()
          .toList(growable: false);
    }

    return lines
        .where(_looksLikeIngredientLine)
        .map(_parseIngredientLine)
        .whereType<RecipeIngredientDraft>()
        .toList(growable: false);
  }

  static bool _looksLikeIngredientLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || _sectionForLine(trimmed) != null) {
      return false;
    }

    return RegExp(
          r'^(\d+|\d+/\d+|\d+\s+\d+/\d+)',
          caseSensitive: false,
        ).hasMatch(trimmed) ||
        RegExp(r'^\d+\s*x\s+\d+', caseSensitive: false).hasMatch(trimmed) ||
        trimmed.startsWith('- ') ||
        trimmed.startsWith('* ') ||
        trimmed.startsWith('• ');
  }

  static RecipeIngredientDraft? _parseIngredientLine(String line) {
    final cleaned = line.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim();
    if (cleaned.isEmpty) {
      return null;
    }

    final commaIndex = cleaned.indexOf(',');
    final parenthetical = RegExp(r'\(([^)]+)\)\s*$').firstMatch(cleaned);
    final preparation = commaIndex >= 0
        ? cleaned.substring(commaIndex + 1).trim()
        : parenthetical?.group(1)?.trim() ?? '';
    final working = commaIndex >= 0
        ? cleaned.substring(0, commaIndex).trim()
        : cleaned.replaceFirst(RegExp(r'\s*\([^)]+\)\s*$'), '').trim();

    final tokens = working.split(RegExp(r'\s+'));
    String quantity = '';
    var consumed = 0;

    if (tokens.isNotEmpty && _isQuantityToken(tokens.first)) {
      quantity = tokens.first;
      consumed = 1;
      if (tokens.length > 1 && _isFractionToken(tokens[1])) {
        quantity = '$quantity ${tokens[1]}';
        consumed = 2;
      }
    }

    var unit = '';
    if (tokens.length > consumed) {
      final candidate = tokens[consumed];
      if (_looksLikeUnit(candidate)) {
        unit = candidate;
        consumed += 1;
      }
    }

    final item = tokens.skip(consumed).join(' ').trim();
    return RecipeIngredientDraft(
      quantity: quantity,
      unit: unit,
      item: item.isEmpty ? working : item,
      preparation: preparation,
    );
  }

  static bool _isQuantityToken(String token) {
    return RegExp(r'^\d+([./]\d+)?$').hasMatch(token);
  }

  static bool _isFractionToken(String token) {
    return RegExp(r'^\d+/\d+$').hasMatch(token);
  }

  static bool _looksLikeUnit(String token) {
    final normalized = token.toLowerCase().replaceAll('.', '');
    const commonUnits = {
      'tsp',
      'teaspoon',
      'teaspoons',
      'tbsp',
      'tablespoon',
      'tablespoons',
      'cup',
      'cups',
      'oz',
      'ounce',
      'ounces',
      'lb',
      'pound',
      'pounds',
      'g',
      'gram',
      'grams',
      'kg',
      'ml',
      'l',
      'can',
      'cans',
      'clove',
      'cloves',
      'slice',
      'slices',
      'large',
      'small',
      'medium',
      'serving',
      'servings',
      'each',
    };
    return commonUnits.contains(normalized);
  }

  static List<String> _extractDirections(
    Map<String, List<String>> sections,
    List<String> lines,
  ) {
    final directionLines = sections['directions'] ?? <String>[];
    if (directionLines.isNotEmpty) {
      return directionLines
          .expand(_splitDirectionLine)
          .map(_cleanDirectionLine)
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
    }

    return lines
        .where(
          (line) =>
              RegExp(r'^\d+[\).\s]').hasMatch(line) ||
              RegExp(r'^step\s*\d+', caseSensitive: false).hasMatch(line) ||
              line.startsWith('- '),
        )
        .expand(_splitDirectionLine)
        .map(_cleanDirectionLine)
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  static String _cleanDirectionLine(String line) {
    return line
        .replaceFirst(
          RegExp(r'^(step\s*)?\d+[:\.\)\-\s]*', caseSensitive: false),
          '',
        )
        .replaceFirst(RegExp(r'^[-*\s]+'), '')
        .trim();
  }

  static List<String> _splitDirectionLine(String line) {
    final normalized = line.trim();
    if (normalized.isEmpty) {
      return const [];
    }

    final matches = RegExp(
      r'(?:step\s*\d+|\b\d+)[:\.\)]',
      caseSensitive: false,
    ).allMatches(normalized).toList(growable: false);
    if (matches.length <= 1) {
      return [normalized];
    }

    final segments = <String>[];
    for (var index = 0; index < matches.length; index++) {
      final start = matches.elementAt(index).start;
      final end = index + 1 < matches.length
          ? matches.elementAt(index + 1).start
          : normalized.length;
      final segment = normalized.substring(start, end).trim();
      if (segment.isNotEmpty) {
        segments.add(segment);
      }
    }
    return segments;
  }

  static NutritionSnapshot _extractNutrition(List<String> lines) {
    final combined = lines.join(' ').toLowerCase();
    int valueFor(String label) {
      final match = RegExp(
        '(?:$label)\\s*[:\\-]?\\s*(\\d+)',
        caseSensitive: false,
      ).firstMatch(combined);
      return match == null ? 0 : int.tryParse(match.group(1)!) ?? 0;
    }

    return NutritionSnapshot(
      calories: valueFor('calories|cal'),
      protein: valueFor('protein'),
      carbs: valueFor('carbs|carbohydrates'),
      fat: valueFor('fat'),
      fiber: valueFor('fiber|fibre'),
      sodium: valueFor('sodium'),
      sugar: valueFor('sugar'),
    );
  }

  static Set<String> _extractTags(List<String> lines) {
    final combined = lines.join(' ').toLowerCase();
    final tags = <String>{};
    for (final line in lines) {
      final match = RegExp(
        r'^tags?\s*:\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) {
        tags.addAll(
          match
              .group(1)!
              .split(RegExp(r'[,;]'))
              .map((tag) => _toTitleCase(tag.trim()))
              .where((tag) => tag.isNotEmpty),
        );
      }
    }
    if (combined.contains('breakfast')) {
      tags.add('Breakfast');
    }
    if (combined.contains('lunch')) {
      tags.add('Lunch');
    }
    if (combined.contains('dinner')) {
      tags.add('Dinner');
    }
    if (combined.contains('snack')) {
      tags.add('Snack');
    }
    if (combined.contains('high protein')) {
      tags.add('High protein');
    }
    if (combined.contains('low sugar')) {
      tags.add('Low sugar');
    }
    if (combined.contains('meal prep')) {
      tags.add('Meal prep');
    }
    return tags;
  }

  static List<String> _extractMetadataNotes(List<String> lines) {
    final notes = <String>[];
    for (final line in lines) {
      final normalized = line.trim();
      final lower = normalized.toLowerCase();
      if (lower.startsWith('prep time') ||
          lower.startsWith('cook time') ||
          lower.startsWith('total time') ||
          lower.startsWith('active time')) {
        notes.add(normalized);
      }
    }
    return notes;
  }

  static String _toTitleCase(String value) {
    return value
        .split(RegExp(r'\s+'))
        .map((part) {
          if (part.isEmpty) {
            return part;
          }
          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ')
        .trim();
  }
}
