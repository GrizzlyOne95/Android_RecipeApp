import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/recipe_app_scope.dart';
import '../../core/measurement_units.dart';
import '../../core/mock_data.dart';
import '../../data/import/barcode_product_lookup.dart';
import '../../data/repositories/app_repositories.dart';
import '../shell/app_shell.dart';

Future<PantryItemDraft?> showPantryItemEditorSheet(
  BuildContext context, {
  PantryItemDraft? initialDraft,
  String? existingItemName,
  PantryBarcodeImporter? barcodeImporter,
  String? initialImportSummary,
  String? initialImportImageUrl,
}) {
  return showModalBottomSheet<PantryItemDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _PantryEditorSheet(
      initialDraft: initialDraft,
      existingItemName: existingItemName,
      barcodeImporter: barcodeImporter,
      initialImportSummary: initialImportSummary,
      initialImportImageUrl: initialImportImageUrl,
    ),
  );
}

class PantryPage extends StatefulWidget {
  const PantryPage({super.key, this.barcodeImporter});

  final PantryBarcodeImporter? barcodeImporter;

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  @override
  Widget build(BuildContext context) {
    final repository = RecipeAppScope.of(context).repositories.pantry;

    return ShellScaffold(
      title: 'Pantry',
      subtitle:
          'Track the exact products you own, scan barcodes when possible, and let recipes pull nutrition from real pantry items before calculating totals.',
      trailing: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          FilledButton.icon(
            onPressed: () => _openEditor(context, repository),
            icon: const Icon(Icons.add),
            label: const Text('Manual item'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => _startBarcodeItemFlow(context, repository),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan barcode'),
          ),
          const Chip(label: Text('Paste/import works too')),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'My Pantry',
            caption:
                'These item cards model the source-of-truth nutrition records that future recipes and saved meals will reference.',
          ),
          StreamBuilder<List<PantryItem>>(
            stream: repository.watchPantryItems(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <PantryItem>[];

              return Column(
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _PantryCard(
                          item: item,
                          onEdit: () =>
                              _openEditor(context, repository, item: item),
                          onDelete: () =>
                              _deleteItem(context, repository, item),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    PantryRepository repository, {
    PantryItem? item,
    PantryItemDraft? initialDraft,
    String? initialImportSummary,
    String? initialImportImageUrl,
  }) async {
    final result = await showPantryItemEditorSheet(
      context,
      initialDraft: initialDraft ?? item?.toDraft(),
      existingItemName: item?.name,
      barcodeImporter:
          widget.barcodeImporter ?? OpenFoodFactsPantryBarcodeImporter(),
      initialImportSummary: initialImportSummary,
      initialImportImageUrl: initialImportImageUrl,
    );

    if (result == null || !context.mounted) {
      return;
    }

    await repository.savePantryItem(result, existingId: item?.id);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item == null
              ? 'Pantry item added locally.'
              : 'Pantry item updated locally.',
        ),
      ),
    );
  }

  Future<void> _deleteItem(
    BuildContext context,
    PantryRepository repository,
    PantryItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete pantry item?'),
        content: Text('Remove "${item.name}" from the local pantry catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await repository.deletePantryItem(item.id);
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${item.name}" deleted.')));
  }

  Future<void> _startBarcodeItemFlow(
    BuildContext context,
    PantryRepository repository,
  ) async {
    if (!_supportsCameraScanning) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Camera scanning is not available on this platform. Paste a barcode and tap Import in the editor.',
          ),
        ),
      );
      await _openEditor(
        context,
        repository,
        initialDraft: const PantryItemDraft(
          name: '',
          quantityLabel: '',
          referenceUnit: 'serving',
          source: 'Manual entry after barcode capture',
          nutrition: NutritionSnapshot.zero,
          accent: Color(0xFF4A6572),
        ),
      );
      return;
    }

    final barcode = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _BarcodeScannerSheet(),
    );

    if (barcode == null || !context.mounted) {
      return;
    }

    final imported = await _lookupBarcodeDraft(context, barcode);
    if (!context.mounted) {
      return;
    }

    if (imported == null) {
      await _openEditor(
        context,
        repository,
        initialDraft: PantryItemDraft(
          name: '',
          barcode: barcode,
          quantityLabel: '',
          referenceUnit: 'serving',
          source: 'Manual entry after barcode capture',
          nutrition: NutritionSnapshot.zero,
          accent: const Color(0xFF4A6572),
        ),
      );
      return;
    }

    await _openEditor(
      context,
      repository,
      initialDraft: imported.draft.copyWith(
        source: 'Barcode scan + Open Food Facts',
      ),
      initialImportSummary: imported.referenceSummary,
      initialImportImageUrl: imported.imageUrl,
    );
  }

  Future<PantryBarcodeImportResult?> _lookupBarcodeDraft(
    BuildContext context,
    String barcode,
  ) async {
    final importer =
        widget.barcodeImporter ?? OpenFoodFactsPantryBarcodeImporter();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _BarcodeLookupDialog(),
    );

    try {
      return await importer.lookup(barcode);
    } on PantryBarcodeImportException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
      return null;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Barcode lookup failed unexpectedly. You can still fill the item in manually.',
            ),
          ),
        );
      }
      return null;
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  bool get _supportsCameraScanning {
    if (kIsWeb) {
      return true;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }
}

class _PantryCard extends StatelessWidget {
  const _PantryCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final PantryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Wrap(
          runSpacing: 18,
          spacing: 18,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: item.accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(Icons.inventory_2, color: item.accent, size: 32),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      PopupMenuButton<_PantryItemAction>(
                        onSelected: (action) {
                          switch (action) {
                            case _PantryItemAction.edit:
                              onEdit();
                            case _PantryItemAction.delete:
                              onDelete();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _PantryItemAction.edit,
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: _PantryItemAction.delete,
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.quantityLabel, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(item.source, style: theme.textTheme.bodyMedium),
                  if (item.brand != null || item.barcode != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.brand case final brand?)
                          Chip(
                            avatar: const Icon(Icons.sell_outlined, size: 18),
                            label: Text(brand),
                          ),
                        if (item.barcode case final barcode?)
                          Chip(
                            avatar: const Icon(Icons.qr_code, size: 18),
                            label: Text(barcode),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Nutrition shown per ${MeasurementUnits.describeReferenceUnit(referenceUnit: item.referenceUnit, referenceUnitQuantity: item.referenceUnitQuantity, referenceUnitEquivalentQuantity: item.referenceUnitEquivalentQuantity, referenceUnitEquivalentUnit: item.referenceUnitEquivalentUnit, referenceUnitWeightGrams: item.referenceUnitWeightGrams)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricPill(
                  label: 'Calories',
                  value: '${item.nutrition.calories}',
                ),
                _MetricPill(
                  label: 'Protein',
                  value: '${item.nutrition.protein}g',
                ),
                _MetricPill(label: 'Carbs', value: '${item.nutrition.carbs}g'),
                _MetricPill(label: 'Fat', value: '${item.nutrition.fat}g'),
                _MetricPill(label: 'Fiber', value: '${item.nutrition.fiber}g'),
                _MetricPill(
                  label: 'Sodium',
                  value: '${item.nutrition.sodium}mg',
                ),
                _MetricPill(label: 'Sugar', value: '${item.nutrition.sugar}g'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _PantryItemAction { edit, delete }

class _PantryEditorSheet extends StatefulWidget {
  const _PantryEditorSheet({
    this.initialDraft,
    this.existingItemName,
    this.barcodeImporter,
    this.initialImportSummary,
    this.initialImportImageUrl,
  });

  final PantryItemDraft? initialDraft;
  final String? existingItemName;
  final PantryBarcodeImporter? barcodeImporter;
  final String? initialImportSummary;
  final String? initialImportImageUrl;

  @override
  State<_PantryEditorSheet> createState() => _PantryEditorSheetState();
}

class _PantryEditorSheetState extends State<_PantryEditorSheet> {
  static const _accentOptions = <Color>[
    Color(0xFFD87B42),
    Color(0xFF7B5138),
    Color(0xFF4F6B44),
    Color(0xFF4A6572),
    Color(0xFF8B6F47),
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _quantityLabelController;
  late final TextEditingController _referenceQuantityController;
  late final TextEditingController _referenceUnitController;
  late final TextEditingController _sourceController;
  late final TextEditingController _equivalentQuantityController;
  late final TextEditingController _equivalentUnitController;
  late final TextEditingController _weightGramsController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _fiberController;
  late final TextEditingController _sodiumController;
  late final TextEditingController _sugarController;
  late Color _selectedAccent;
  bool _isImportingBarcode = false;
  String? _importSummary;
  String? _importImageUrl;

  @override
  void initState() {
    super.initState();
    final draft =
        widget.initialDraft ??
        const PantryItemDraft(
          name: '',
          quantityLabel: '',
          referenceUnit: 'serving',
          source: 'Manual entry',
          nutrition: NutritionSnapshot.zero,
          accent: Color(0xFFD87B42),
        );
    _nameController = TextEditingController(text: draft.name);
    _brandController = TextEditingController(text: draft.brand ?? '');
    _barcodeController = TextEditingController(text: draft.barcode ?? '');
    _quantityLabelController = TextEditingController(text: draft.quantityLabel);
    _referenceQuantityController = TextEditingController(
      text: MeasurementUnits.formatDecimal(draft.referenceUnitQuantity),
    );
    _referenceUnitController = TextEditingController(text: draft.referenceUnit);
    _sourceController = TextEditingController(text: draft.source);
    _equivalentQuantityController = TextEditingController(
      text: draft.referenceUnitEquivalentQuantity == null
          ? ''
          : MeasurementUnits.formatDecimal(
              draft.referenceUnitEquivalentQuantity!,
            ),
    );
    _equivalentUnitController = TextEditingController(
      text: draft.referenceUnitEquivalentUnit ?? '',
    );
    _weightGramsController = TextEditingController(
      text: draft.referenceUnitWeightGrams == null
          ? ''
          : MeasurementUnits.formatDecimal(draft.referenceUnitWeightGrams!),
    );
    _caloriesController = TextEditingController(
      text: draft.nutrition.calories.toString(),
    );
    _proteinController = TextEditingController(
      text: draft.nutrition.protein.toString(),
    );
    _carbsController = TextEditingController(
      text: draft.nutrition.carbs.toString(),
    );
    _fatController = TextEditingController(
      text: draft.nutrition.fat.toString(),
    );
    _fiberController = TextEditingController(
      text: draft.nutrition.fiber.toString(),
    );
    _sodiumController = TextEditingController(
      text: draft.nutrition.sodium.toString(),
    );
    _sugarController = TextEditingController(
      text: draft.nutrition.sugar.toString(),
    );
    _selectedAccent = draft.accent;
    _importSummary = widget.initialImportSummary;
    _importImageUrl = widget.initialImportImageUrl;

    for (final controller in _livePreviewControllers) {
      controller.addListener(_handleDraftChanged);
    }
  }

  Iterable<TextEditingController> get _livePreviewControllers => [
    _referenceQuantityController,
    _referenceUnitController,
    _equivalentQuantityController,
    _equivalentUnitController,
    _weightGramsController,
  ];

  @override
  void dispose() {
    for (final controller in _livePreviewControllers) {
      controller.removeListener(_handleDraftChanged);
    }
    _nameController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    _quantityLabelController.dispose();
    _referenceQuantityController.dispose();
    _referenceUnitController.dispose();
    _sourceController.dispose();
    _equivalentQuantityController.dispose();
    _equivalentUnitController.dispose();
    _weightGramsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sodiumController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final theme = Theme.of(context);
    final referenceSummary = MeasurementUnits.describeReferenceUnit(
      referenceUnit: _referenceUnitController.text.trim().isEmpty
          ? 'serving'
          : _referenceUnitController.text.trim(),
      referenceUnitQuantity:
          _parsePositiveDouble(_referenceQuantityController) ?? 1,
      referenceUnitEquivalentQuantity: _parsePositiveDouble(
        _equivalentQuantityController,
      ),
      referenceUnitEquivalentUnit: _equivalentUnitController.text.trim(),
      referenceUnitWeightGrams: _parsePositiveDouble(_weightGramsController),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existingItemName == null
                              ? 'Add pantry item'
                              : 'Edit pantry item',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Manage the nutrition reference that linked recipe ingredients will use.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _EditorSection(
                title: 'Product',
                child: Column(
                  children: [
                    if (_importSummary != null || _importImageUrl != null) ...[
                      _ImportedBarcodePreview(
                        summary: _importSummary,
                        imageUrl: _importImageUrl,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Item name'),
                      validator: _requiredText,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        hintText: 'Fage, Trader Joe\'s, Kirkland',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _barcodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Barcode',
                        hintText: 'UPC / EAN / store code',
                        helperText:
                            'Paste a barcode and tap Import to pull product details.',
                        suffixIcon: IconButton(
                          onPressed: _isImportingBarcode
                              ? null
                              : _importBarcodeFromField,
                          icon: _isImportingBarcode
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download_rounded),
                          tooltip: 'Import from barcode',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityLabelController,
                      decoration: const InputDecoration(
                        labelText: 'Package label',
                        hintText: '32 oz tub, 3 cans, 1 kg bag',
                      ),
                      validator: _requiredText,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sourceController,
                      decoration: const InputDecoration(
                        labelText: 'Source',
                        hintText: 'Manual entry, barcode scan, imported, etc.',
                      ),
                      validator: _requiredText,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final accent in _accentOptions)
                          ChoiceChip(
                            selected:
                                _selectedAccent.toARGB32() == accent.toARGB32(),
                            label: Text(_accentLabel(accent)),
                            avatar: CircleAvatar(backgroundColor: accent),
                            onSelected: (_) {
                              setState(() {
                                _selectedAccent = accent;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _EditorSection(
                title: 'Reference Unit',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _referenceQuantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Reference qty',
                              hintText: '1, 2, 100',
                            ),
                            validator: _positiveDecimalRequired,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _referenceUnitController,
                            decoration: const InputDecoration(
                              labelText: 'Reference unit',
                              hintText: 'serving, cup, can, g, oz',
                            ),
                            validator: _requiredText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Optional overrides let the full nutrition basis map to common mass or volume measures.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _equivalentQuantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Equivalent qty',
                              hintText: '0.75',
                            ),
                            validator: _optionalPositiveDecimal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _equivalentUnitController,
                            decoration: const InputDecoration(
                              labelText: 'Equivalent unit',
                              hintText: 'cup, ml, oz',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _weightGramsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Weight override (g)',
                        hintText: '170',
                      ),
                      validator: _optionalPositiveDecimal,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current nutrition basis: $referenceSummary',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _EditorSection(
                title: 'Nutrition Per Reference Unit',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricField(
                      controller: _caloriesController,
                      label: 'Calories',
                    ),
                    _MetricField(
                      controller: _proteinController,
                      label: 'Protein',
                    ),
                    _MetricField(controller: _carbsController, label: 'Carbs'),
                    _MetricField(controller: _fatController, label: 'Fat'),
                    _MetricField(controller: _fiberController, label: 'Fiber'),
                    _MetricField(
                      controller: _sodiumController,
                      label: 'Sodium',
                    ),
                    _MetricField(controller: _sugarController, label: 'Sugar'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(
                        widget.existingItemName == null
                            ? 'Add pantry item'
                            : 'Save changes',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _optionalPositiveDecimal(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 'Use a positive number';
    }
    return null;
  }

  String? _positiveDecimalRequired(String? value) {
    final trimmed = value?.trim() ?? '';
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 'Use a positive number';
    }
    return null;
  }

  double? _parsePositiveDouble(TextEditingController controller) {
    final parsed = double.tryParse(controller.text.trim());
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  int _parseMetricValue(TextEditingController controller) {
    return int.tryParse(controller.text.trim()) ?? 0;
  }

  String _accentLabel(Color color) {
    if (color.toARGB32() == const Color(0xFFD87B42).toARGB32()) {
      return 'Amber';
    }
    if (color.toARGB32() == const Color(0xFF7B5138).toARGB32()) {
      return 'Cocoa';
    }
    if (color.toARGB32() == const Color(0xFF4F6B44).toARGB32()) {
      return 'Herb';
    }
    if (color.toARGB32() == const Color(0xFF4A6572).toARGB32()) {
      return 'Slate';
    }
    return 'Grain';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      PantryItemDraft(
        name: _nameController.text.trim(),
        brand: _normalizedOptionalText(_brandController.text),
        barcode: _normalizedOptionalText(_barcodeController.text),
        quantityLabel: _quantityLabelController.text.trim(),
        referenceUnitQuantity:
            _parsePositiveDouble(_referenceQuantityController) ?? 1,
        referenceUnit: _referenceUnitController.text.trim(),
        source: _sourceController.text.trim(),
        accent: _selectedAccent,
        referenceUnitEquivalentQuantity: _parsePositiveDouble(
          _equivalentQuantityController,
        ),
        referenceUnitEquivalentUnit:
            _equivalentUnitController.text.trim().isEmpty
            ? null
            : _equivalentUnitController.text.trim(),
        referenceUnitWeightGrams: _parsePositiveDouble(_weightGramsController),
        nutrition: NutritionSnapshot(
          calories: _parseMetricValue(_caloriesController),
          protein: _parseMetricValue(_proteinController),
          carbs: _parseMetricValue(_carbsController),
          fat: _parseMetricValue(_fatController),
          fiber: _parseMetricValue(_fiberController),
          sodium: _parseMetricValue(_sodiumController),
          sugar: _parseMetricValue(_sugarController),
        ),
      ),
    );
  }

  String? _normalizedOptionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _handleDraftChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _importBarcodeFromField() async {
    final importer = widget.barcodeImporter;
    if (importer == null) {
      return;
    }

    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a barcode to import first.')),
      );
      return;
    }

    setState(() {
      _isImportingBarcode = true;
    });

    try {
      final result = await importer.lookup(barcode);
      if (!mounted) {
        return;
      }
      _applyImportedDraft(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imported nutrition per ${result.referenceSummary}.'),
        ),
      );
    } on PantryBarcodeImportException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Barcode import failed unexpectedly. Try again or finish the item manually.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImportingBarcode = false;
        });
      }
    }
  }

  void _applyImportedDraft(PantryBarcodeImportResult result) {
    final draft = result.draft;
    _nameController.text = draft.name;
    _brandController.text = draft.brand ?? '';
    _barcodeController.text = draft.barcode ?? '';
    _quantityLabelController.text = draft.quantityLabel;
    _referenceQuantityController.text = MeasurementUnits.formatDecimal(
      draft.referenceUnitQuantity,
    );
    _referenceUnitController.text = draft.referenceUnit;
    _sourceController.text = draft.source;
    _equivalentQuantityController.text =
        draft.referenceUnitEquivalentQuantity == null
        ? ''
        : MeasurementUnits.formatDecimal(
            draft.referenceUnitEquivalentQuantity!,
          );
    _equivalentUnitController.text = draft.referenceUnitEquivalentUnit ?? '';
    _weightGramsController.text = draft.referenceUnitWeightGrams == null
        ? ''
        : MeasurementUnits.formatDecimal(draft.referenceUnitWeightGrams!);
    _caloriesController.text = draft.nutrition.calories.toString();
    _proteinController.text = draft.nutrition.protein.toString();
    _carbsController.text = draft.nutrition.carbs.toString();
    _fatController.text = draft.nutrition.fat.toString();
    _fiberController.text = draft.nutrition.fiber.toString();
    _sodiumController.text = draft.nutrition.sodium.toString();
    _sugarController.text = draft.nutrition.sugar.toString();

    setState(() {
      _selectedAccent = draft.accent;
      _importSummary = result.referenceSummary;
      _importImageUrl = result.imageUrl;
    });
  }
}

class _EditorSection extends StatelessWidget {
  const _EditorSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _MetricField extends StatelessWidget {
  const _MetricField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _ImportedBarcodePreview extends StatelessWidget {
  const _ImportedBarcodePreview({this.summary, this.imageUrl});

  final String? summary;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1E5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(
                  width: 64,
                  height: 64,
                  child: ColoredBox(color: Color(0xFFE6DED1)),
                ),
              ),
            )
          else
            const SizedBox(
              width: 64,
              height: 64,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE6DED1)),
                child: Icon(Icons.inventory_2_outlined),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Imported barcode match',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  summary == null
                      ? 'Product details pulled from Open Food Facts.'
                      : 'Nutrition imported per $summary from Open Food Facts.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodeLookupDialog extends StatelessWidget {
  const _BarcodeLookupDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          SizedBox(width: 180, child: Text('Looking up barcode details...')),
        ],
      ),
    );
  }
}

class _BarcodeScannerSheet extends StatefulWidget {
  const _BarcodeScannerSheet();

  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
    ],
  );
  bool _didComplete = false;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SizedBox(
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scan a pantry barcode', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Point the camera at a UPC or EAN code to pull product nutrition into the pantry editor.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: _handleDetection,
                        errorBuilder: (context, error) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                error.errorDetails?.message ??
                                    'Camera scanning is unavailable right now.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 260,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white70,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _toggleTorch,
                    icon: ValueListenableBuilder<MobileScannerState>(
                      valueListenable: _controller,
                      builder: (context, state, _) {
                        return Icon(
                          state.torchState == TorchState.on
                              ? Icons.flash_on
                              : Icons.flash_off,
                        );
                      },
                    ),
                    label: const Text('Torch'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_didComplete) {
      return;
    }

    final value = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .whereType<String>()
        .firstWhere((barcode) => barcode.isNotEmpty, orElse: () => '');
    if (value.isEmpty || !mounted) {
      return;
    }

    _didComplete = true;
    unawaited(_controller.stop());
    Navigator.of(context).pop(value);
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } catch (_) {}
  }
}
