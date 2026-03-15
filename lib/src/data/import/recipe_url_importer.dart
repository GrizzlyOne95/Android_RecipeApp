import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../../core/mock_data.dart';

class RecipeUrlImportFetchResult {
  const RecipeUrlImportFetchResult({
    required this.extractedText,
    required this.warnings,
    required this.usedStructuredData,
  });

  final String extractedText;
  final List<String> warnings;
  final bool usedStructuredData;
}

class RecipeUrlImportException implements Exception {
  const RecipeUrlImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RecipeUrlImporter {
  RecipeUrlImporter({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<RecipeUrlImportFetchResult> fetch(String rawUrl) async {
    final normalizedUrl = rawUrl.trim();
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.trim().isEmpty) {
      throw const RecipeUrlImportException(
        'Enter a valid recipe URL before fetching.',
      );
    }

    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (compatible; KitchenLedgerRecipeImporter/1.0)',
          'Accept':
              'text/html,application/xhtml+xml,application/json;q=0.9,*/*;q=0.8',
        },
      );
    } on Object {
      throw const RecipeUrlImportException(
        'Could not reach that recipe page right now.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RecipeUrlImportException(
        'The recipe page responded with status ${response.statusCode}.',
      );
    }

    final document = html_parser.parse(response.body);
    final warnings = <String>[];

    final structuredRecipe = _findRecipeSchema(document);
    if (structuredRecipe != null) {
      final structuredText = _renderStructuredRecipeText(
        structuredRecipe,
        sourceUrl: normalizedUrl,
      );
      if (structuredText.trim().isNotEmpty) {
        return RecipeUrlImportFetchResult(
          extractedText: structuredText,
          warnings: const [
            'Structured recipe data was detected and converted into an editable draft.',
          ],
          usedStructuredData: true,
        );
      }
    }

    final extractedText = _extractReadableText(
      document,
      sourceUrl: normalizedUrl,
    );
    if (extractedText.trim().isEmpty) {
      throw const RecipeUrlImportException(
        'The recipe page loaded, but no readable recipe text could be extracted.',
      );
    }

    warnings.add(
      'Structured recipe data was not found. Review the extracted page text before saving.',
    );

    return RecipeUrlImportFetchResult(
      extractedText: extractedText,
      warnings: warnings,
      usedStructuredData: false,
    );
  }

  Map<String, Object?>? _findRecipeSchema(dynamic root) {
    if (root == null) {
      return null;
    }

    if (root is Map<String, Object?>) {
      final type = root['@type'];
      if (_isRecipeType(type)) {
        return root;
      }

      for (final key in const ['@graph', 'mainEntity', 'itemListElement']) {
        final nested = _findRecipeSchema(root[key]);
        if (nested != null) {
          return nested;
        }
      }

      for (final value in root.values) {
        final nested = _findRecipeSchema(value);
        if (nested != null) {
          return nested;
        }
      }
    }

    if (root is List) {
      for (final item in root) {
        final nested = _findRecipeSchema(item);
        if (nested != null) {
          return nested;
        }
      }
    }

    if (root.runtimeType.toString().contains('Document')) {
      final scripts = root.querySelectorAll(
        'script[type="application/ld+json"]',
      );
      for (final script in scripts) {
        final raw = script.text.trim();
        if (raw.isEmpty) {
          continue;
        }

        final decoded = _tryDecodeJson(raw);
        final nested = _findRecipeSchema(decoded);
        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  dynamic _tryDecodeJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      final cleaned = raw
          .replaceAll(RegExp(r'<!--|-->'), '')
          .replaceAll('\u0000', '')
          .trim();
      try {
        return jsonDecode(cleaned);
      } on FormatException {
        return null;
      }
    }
  }

  bool _isRecipeType(Object? value) {
    if (value is String) {
      return value.toLowerCase() == 'recipe';
    }
    if (value is List) {
      return value.any(
        (item) => item is String && item.toLowerCase() == 'recipe',
      );
    }
    return false;
  }

  String _renderStructuredRecipeText(
    Map<String, Object?> recipe, {
    required String sourceUrl,
  }) {
    final title = _normalizedText(recipe['name']) ?? 'Imported Recipe';
    final servings = _extractServings(recipe['recipeYield']);
    final ingredients = _stringList(recipe['recipeIngredient']);
    final directions = _extractInstructions(recipe['recipeInstructions']);
    final description = _normalizedText(recipe['description']);
    final nutrition = _extractNutrition(recipe['nutrition']);
    final tags = _extractStructuredTags(recipe);

    final lines = <String>[
      title,
      if (servings case final servings?) 'Servings: $servings',
      ?description,
      '',
      if (ingredients.isNotEmpty) ...['Ingredients', ...ingredients, ''],
      if (directions.isNotEmpty) ...[
        'Directions',
        for (var index = 0; index < directions.length; index++)
          '${index + 1}. ${directions[index]}',
        '',
      ],
      if (nutrition != NutritionSnapshot.zero) _nutritionLine(nutrition),
      'Notes',
      'Imported from: $sourceUrl',
      'Imported from structured recipe schema.',
      if (tags.isNotEmpty) 'Tags: ${tags.join(', ')}',
    ];

    return lines.join('\n').trim();
  }

  String _extractReadableText(dynamic document, {required String sourceUrl}) {
    final root =
        document.querySelector('article') ??
        document.querySelector('main') ??
        document.body;
    if (root == null) {
      return '';
    }

    final lines = <String>[];
    final seen = <String>{};
    for (final element in root.querySelectorAll('h1, h2, h3, p, li')) {
      final text = _collapseWhitespace(element.text);
      if (text.isEmpty || text.length < 2) {
        continue;
      }
      if (!seen.add(text.toLowerCase())) {
        continue;
      }
      lines.add(text);
      if (lines.length >= 120) {
        break;
      }
    }

    if (lines.isEmpty) {
      final fallback = _collapseWhitespace(root.text);
      if (fallback.isEmpty) {
        return '';
      }
      lines.addAll(
        fallback
            .split(RegExp(r'(?<=[.!?])\s+'))
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .take(80),
      );
    }

    return [
      ...lines,
      '',
      'Notes',
      'Imported from: $sourceUrl',
      'Imported from extracted page text. Review before saving.',
    ].join('\n');
  }

  int? _extractServings(Object? value) {
    if (value is num) {
      final rounded = value.round();
      return rounded > 0 ? rounded : null;
    }

    if (value is String) {
      final match = RegExp(r'(\d+)').firstMatch(value);
      if (match != null) {
        final parsed = int.tryParse(match.group(1)!);
        if (parsed != null && parsed > 0) {
          return parsed;
        }
      }
    }

    if (value is List) {
      for (final item in value) {
        final servings = _extractServings(item);
        if (servings != null) {
          return servings;
        }
      }
    }

    return null;
  }

  List<String> _extractInstructions(Object? value) {
    if (value == null) {
      return const [];
    }

    if (value is String) {
      return value
          .split(RegExp(r'(?:(?<=\.)\s+|\n+)'))
          .map(_collapseWhitespace)
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
    }

    if (value is List) {
      return value
          .expand(_extractInstructions)
          .map(_collapseWhitespace)
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
    }

    if (value is Map<String, Object?>) {
      for (final key in const ['text', 'name']) {
        final text = _normalizedText(value[key]);
        if (text != null && text.isNotEmpty) {
          return [text];
        }
      }

      final nested = value['itemListElement'];
      if (nested != null) {
        return _extractInstructions(nested);
      }
    }

    return const [];
  }

  NutritionSnapshot _extractNutrition(Object? value) {
    if (value is! Map<String, Object?>) {
      return NutritionSnapshot.zero;
    }

    return NutritionSnapshot(
      calories: _extractLeadingInt(value['calories']),
      protein: _extractLeadingInt(value['proteinContent']),
      carbs: _extractLeadingInt(value['carbohydrateContent']),
      fat: _extractLeadingInt(value['fatContent']),
      fiber: _extractLeadingInt(value['fiberContent']),
      sodium: _extractLeadingInt(value['sodiumContent']),
      sugar: _extractLeadingInt(value['sugarContent']),
    );
  }

  List<String> _extractStructuredTags(Map<String, Object?> recipe) {
    final tags = <String>{};

    for (final key in const ['keywords', 'recipeCategory', 'recipeCuisine']) {
      final value = recipe[key];
      if (value is String) {
        tags.addAll(
          value
              .split(RegExp(r'[,;]'))
              .map((tag) => _collapseWhitespace(tag))
              .where((tag) => tag.isNotEmpty),
        );
      } else if (value is List) {
        tags.addAll(
          value
              .whereType<String>()
              .map(_collapseWhitespace)
              .where((tag) => tag.isNotEmpty),
        );
      }
    }

    return tags.toList(growable: false);
  }

  List<String> _stringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item is String ? _collapseWhitespace(item) : '')
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    if (value is String) {
      final collapsed = _collapseWhitespace(value);
      return collapsed.isEmpty ? const [] : [collapsed];
    }

    return const [];
  }

  int _extractLeadingInt(Object? value) {
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(value);
      if (match != null) {
        final parsed = double.tryParse(match.group(1)!);
        if (parsed != null) {
          return parsed.round();
        }
      }
    }
    return 0;
  }

  String _nutritionLine(NutritionSnapshot nutrition) {
    final parts = <String>[
      'Nutrition:',
      if (nutrition.calories > 0) 'Calories ${nutrition.calories}',
      if (nutrition.protein > 0) 'Protein ${nutrition.protein}g',
      if (nutrition.carbs > 0) 'Carbs ${nutrition.carbs}g',
      if (nutrition.fat > 0) 'Fat ${nutrition.fat}g',
      if (nutrition.fiber > 0) 'Fiber ${nutrition.fiber}g',
      if (nutrition.sodium > 0) 'Sodium ${nutrition.sodium}mg',
      if (nutrition.sugar > 0) 'Sugar ${nutrition.sugar}g',
    ];
    return parts.join(' ');
  }

  String? _normalizedText(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = _collapseWhitespace(value);
    return trimmed.isEmpty ? null : trimmed;
  }

  String _collapseWhitespace(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
