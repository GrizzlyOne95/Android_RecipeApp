import 'mock_data.dart';

enum RecipeImportMode { textPaste, urlPaste, ocrPaste }

enum RecipeImportConfidence { high, medium, low }

class RecipeImportCheck {
  const RecipeImportCheck({
    required this.label,
    required this.isReady,
    this.detail = '',
  });

  final String label;
  final bool isReady;
  final String detail;
}

class RecipeImportResult {
  const RecipeImportResult({
    required this.draft,
    required this.warnings,
    required this.confidence,
    required this.checks,
    required this.reviewNotes,
    required this.confidenceScore,
  });

  final RecipeDraft draft;
  final List<String> warnings;
  final RecipeImportConfidence confidence;
  final List<RecipeImportCheck> checks;
  final List<String> reviewNotes;
  final int confidenceScore;
}

abstract final class RecipeImportParser {
  static RecipeImportResult parse({
    required RecipeImportMode mode,
    String rawText = '',
    String sourceUrl = '',
  }) {
    final lines = _prepareLines(rawText);
    final warnings = <String>[];
    final sections = _collectSections(lines);

    final titleResult = _extractTitle(lines, sourceUrl);
    final title = titleResult.title;
    final servingsMatch = _extractServings(lines);
    final servings = servingsMatch ?? 1;
    if (servingsMatch == null) {
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
    final reviewNotes = <String>[
      if (titleResult.source == _RecipeImportTitleSource.urlSlug)
        'Title came from the URL slug. Confirm the recipe name in the editor.',
      if (titleResult.source == _RecipeImportTitleSource.fallback)
        'No clear title was detected. Rename this draft before saving.',
      if (mode == RecipeImportMode.ocrPaste)
        'OCR imports often need quantity, punctuation, and step cleanup.',
      if (ingredients.isNotEmpty && ingredients.length < 3)
        'Ingredient list looks short. Scan for missed lines before saving.',
      if (directions.length == 1)
        'Only one direction was detected. Split combined instructions if needed.',
    ];
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
    final checks = <RecipeImportCheck>[
      RecipeImportCheck(
        label: 'Title',
        isReady: title.trim().isNotEmpty && title != 'Imported Recipe',
        detail: switch (titleResult.source) {
          _RecipeImportTitleSource.text => 'Detected from imported text',
          _RecipeImportTitleSource.urlSlug => 'Recovered from URL slug',
          _RecipeImportTitleSource.fallback => 'Needs manual title review',
        },
      ),
      RecipeImportCheck(
        label: 'Servings',
        isReady: servingsMatch != null,
        detail: servingsMatch != null
            ? 'Detected $servings serving${servings == 1 ? '' : 's'}'
            : 'Defaulted to 1 serving',
      ),
      RecipeImportCheck(
        label: 'Ingredients',
        isReady: ingredients.isNotEmpty,
        detail: ingredients.isEmpty
            ? 'No ingredient rows detected'
            : '${ingredients.length} ingredient${ingredients.length == 1 ? '' : 's'} parsed',
      ),
      RecipeImportCheck(
        label: 'Directions',
        isReady: directions.isNotEmpty,
        detail: directions.isEmpty
            ? 'No directions detected'
            : '${directions.length} step${directions.length == 1 ? '' : 's'} parsed',
      ),
      RecipeImportCheck(
        label: 'Nutrition',
        isReady: !nutrition.isZero,
        detail: nutrition.isZero
            ? 'No nutrition detected'
            : '${nutrition.calories} cal and macros detected',
      ),
    ];
    final confidenceScore = _confidenceScore(
      titleSource: titleResult.source,
      servingsFound: servingsMatch != null,
      ingredientCount: ingredients.length,
      directionCount: directions.length,
      hasNutrition: !nutrition.isZero,
      hasIngredientSection: sections['ingredients']?.isNotEmpty ?? false,
      hasDirectionSection: sections['directions']?.isNotEmpty ?? false,
      warningCount: warnings.length,
      mode: mode,
    );
    final confidence = _confidenceFromScore(confidenceScore);

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
      confidence: confidence,
      checks: checks,
      reviewNotes: reviewNotes,
      confidenceScore: confidenceScore,
    );
  }

  static List<String> _prepareLines(String rawText) {
    final normalizedText = _normalizeText(rawText);
    final prepared = <String>[];
    String? previousLine;

    for (final rawLine in normalizedText.split('\n')) {
      final line = _normalizeLine(rawLine);
      if (line.isEmpty || _isDiscardableImportLine(line)) {
        continue;
      }
      if (previousLine != null &&
          previousLine.toLowerCase() == line.toLowerCase()) {
        continue;
      }
      prepared.add(line);
      previousLine = line;
    }

    return prepared;
  }

  static String _normalizeText(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp('[\u200B-\u200D\uFEFF]'), '')
        .replaceAll('½', '1/2')
        .replaceAll('¼', '1/4')
        .replaceAll('¾', '3/4')
        .replaceAll('⅓', '1/3')
        .replaceAll('⅔', '2/3')
        .replaceAll('⅛', '1/8');
  }

  static String _normalizeLine(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _isDiscardableImportLine(String line) {
    final normalized = line
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    const exactMatches = {
      'jump to recipe',
      'jump to video',
      'print recipe',
      'pin recipe',
      'save recipe',
      'rate recipe',
      'leave a comment',
      'leave comment',
      'share this',
      'advertisement',
      'cook mode',
      'keep screen awake',
    };
    if (exactMatches.contains(normalized)) {
      return true;
    }

    return RegExp(
          r'^\d+(?:\.\d+)?\s+from\s+\d+\s+votes?$',
        ).hasMatch(normalized) ||
        RegExp(r'^\d+\s+comments?$').hasMatch(normalized) ||
        normalized.startsWith('did you make this recipe') ||
        normalized.startsWith('made this recipe') ||
        normalized.contains('prevent your screen from going dark');
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

  static _RecipeImportTitleResult _extractTitle(
    List<String> lines,
    String sourceUrl,
  ) {
    for (final line in lines) {
      if (_sectionForLine(line) != null) {
        continue;
      }
      if (_looksLikeMetadata(line)) {
        continue;
      }
      final cleanedTitle = _cleanTitle(line, sourceUrl);
      if (cleanedTitle.isEmpty || _looksLikeMetadata(cleanedTitle)) {
        continue;
      }
      return _RecipeImportTitleResult(
        title: cleanedTitle,
        source: _RecipeImportTitleSource.text,
      );
    }

    final parsedUrl = Uri.tryParse(sourceUrl.trim());
    final slug = parsedUrl?.pathSegments.reversed.firstWhere(
      (segment) => segment.trim().isNotEmpty,
      orElse: () => '',
    );
    if (slug != null && slug.trim().isNotEmpty) {
      return _RecipeImportTitleResult(
        title: _cleanTitle(
          slug
              .replaceAll('-', ' ')
              .replaceAll('_', ' ')
              .replaceAllMapped(
                RegExp(r'\b[a-z]'),
                (match) => match.group(0)!.toUpperCase(),
              ),
          sourceUrl,
        ),
        source: _RecipeImportTitleSource.urlSlug,
      );
    }

    return const _RecipeImportTitleResult(
      title: 'Imported Recipe',
      source: _RecipeImportTitleSource.fallback,
    );
  }

  static String _cleanTitle(String line, [String sourceUrl = '']) {
    var cleaned = line.replaceAll(RegExp(r'^[#*\-\d\.\)\s]+'), '').trim();

    for (final separator in const [' | ', ' - ', ' — ', ' – ']) {
      if (!cleaned.contains(separator)) {
        continue;
      }
      final parts = cleaned
          .split(separator)
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList(growable: false);
      if (parts.length >= 2 && _looksLikeSiteSuffix(parts.last, sourceUrl)) {
        cleaned = parts.first;
        break;
      }
    }

    return cleaned;
  }

  static bool _looksLikeSiteSuffix(String candidate, String sourceUrl) {
    final host = Uri.tryParse(
      sourceUrl.trim(),
    )?.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
    if (host == null || host.isEmpty) {
      return false;
    }

    final normalizedHost = host.replaceAll(RegExp(r'[^a-z0-9]'), '');
    final normalizedCandidate = candidate.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    if (normalizedHost.isEmpty || normalizedCandidate.isEmpty) {
      return false;
    }

    return normalizedHost.contains(normalizedCandidate) ||
        normalizedCandidate.contains(normalizedHost);
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
        normalized.startsWith('course:') ||
        normalized.startsWith('cuisine:') ||
        normalized.startsWith('category:') ||
        normalized.startsWith('meal type:') ||
        normalized.startsWith('occasion:') ||
        normalized.startsWith('keywords:') ||
        normalized.startsWith('author:') ||
        normalized.startsWith('updated:') ||
        normalized.startsWith('published:') ||
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
          .where((line) => !_isIngredientSubheading(line))
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

  static bool _isIngredientSubheading(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      return true;
    }
    if (_looksLikeIngredientLine(trimmed)) {
      return false;
    }
    final normalized = trimmed.toLowerCase();
    return trimmed.endsWith(':') ||
        normalized.startsWith('for the ') ||
        normalized.startsWith('for ') ||
        normalized == 'optional toppings' ||
        normalized == 'to serve';
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
          .expand(_extractDirectionSegments)
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
        .expand(_extractDirectionSegments)
        .map(_cleanDirectionLine)
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  static Iterable<String> _extractDirectionSegments(String line) {
    final numberedSegments = _splitDirectionLine(line);
    if (numberedSegments.length > 1) {
      return numberedSegments;
    }
    return _splitSentenceDirections(line);
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

  static List<String> _splitSentenceDirections(String line) {
    final normalized = line.trim();
    if (normalized.isEmpty) {
      return const [];
    }

    final matches = RegExp(
      r'[.!?]\s+(?=[A-Z])',
    ).allMatches(normalized).toList(growable: false);
    if (matches.isEmpty) {
      return [normalized];
    }

    final segments = <String>[];
    var start = 0;
    for (final match in matches) {
      final end = match.start + 1;
      final segment = normalized.substring(start, end).trim();
      if (segment.isNotEmpty) {
        segments.add(segment);
      }
      start = match.end;
    }

    final tail = normalized.substring(start).trim();
    if (tail.isNotEmpty) {
      segments.add(tail);
    }

    if (segments.length <= 1 || segments.length > 6) {
      return [normalized];
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
        r'^(tags?|course|cuisine|category|meal type|occasion|keywords)\s*:\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) {
        tags.addAll(
          match
              .group(2)!
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
      tags.add('High Protein');
    }
    if (combined.contains('low sugar')) {
      tags.add('Low Sugar');
    }
    if (combined.contains('meal prep')) {
      tags.add('Meal Prep');
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

  static int _confidenceScore({
    required _RecipeImportTitleSource titleSource,
    required bool servingsFound,
    required int ingredientCount,
    required int directionCount,
    required bool hasNutrition,
    required bool hasIngredientSection,
    required bool hasDirectionSection,
    required int warningCount,
    required RecipeImportMode mode,
  }) {
    var score = 0;

    score += switch (titleSource) {
      _RecipeImportTitleSource.text => 25,
      _RecipeImportTitleSource.urlSlug => 15,
      _RecipeImportTitleSource.fallback => 0,
    };
    if (servingsFound) {
      score += 10;
    }
    score += switch (ingredientCount) {
      >= 5 => 30,
      >= 1 => 18,
      _ => 0,
    };
    score += switch (directionCount) {
      >= 3 => 25,
      >= 1 => 14,
      _ => 0,
    };
    if (hasNutrition) {
      score += 10;
    }
    if (hasIngredientSection) {
      score += 5;
    }
    if (hasDirectionSection) {
      score += 5;
    }
    if (warningCount >= 3) {
      score -= 10;
    } else if (warningCount == 2) {
      score -= 6;
    } else if (warningCount == 1) {
      score -= 3;
    }
    if (mode == RecipeImportMode.ocrPaste) {
      score -= 20;
    }

    return score.clamp(0, 100);
  }

  static RecipeImportConfidence _confidenceFromScore(int score) {
    if (score >= 75) {
      return RecipeImportConfidence.high;
    }
    if (score >= 45) {
      return RecipeImportConfidence.medium;
    }
    return RecipeImportConfidence.low;
  }
}

class _RecipeImportTitleResult {
  const _RecipeImportTitleResult({required this.title, required this.source});

  final String title;
  final _RecipeImportTitleSource source;
}

enum _RecipeImportTitleSource { text, urlSlug, fallback }
