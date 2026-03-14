// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionLabelMeta = const VerificationMeta(
    'versionLabel',
  );
  @override
  late final GeneratedColumn<String> versionLabel = GeneratedColumn<String>(
    'version_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortCaloriesMeta = const VerificationMeta(
    'sortCalories',
  );
  @override
  late final GeneratedColumn<int> sortCalories = GeneratedColumn<int>(
    'sort_calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<int> protein = GeneratedColumn<int>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<int> carbs = GeneratedColumn<int>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<int> fat = GeneratedColumn<int>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<int> fiber = GeneratedColumn<int>(
    'fiber',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<int> sodium = GeneratedColumn<int>(
    'sodium',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<int> sugar = GeneratedColumn<int>(
    'sugar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    versionLabel,
    notes,
    servings,
    isPinned,
    sortCalories,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sodium,
    sugar,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('version_label')) {
      context.handle(
        _versionLabelMeta,
        versionLabel.isAcceptableOrUnknown(
          data['version_label']!,
          _versionLabelMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    } else if (isInserting) {
      context.missing(_servingsMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('sort_calories')) {
      context.handle(
        _sortCaloriesMeta,
        sortCalories.isAcceptableOrUnknown(
          data['sort_calories']!,
          _sortCaloriesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sortCaloriesMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    } else if (isInserting) {
      context.missing(_fiberMeta);
    }
    if (data.containsKey('sodium')) {
      context.handle(
        _sodiumMeta,
        sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta),
      );
    } else if (isInserting) {
      context.missing(_sodiumMeta);
    }
    if (data.containsKey('sugar')) {
      context.handle(
        _sugarMeta,
        sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta),
      );
    } else if (isInserting) {
      context.missing(_sugarMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      versionLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_label'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servings'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      sortCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_calories'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carbs'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fat'],
      )!,
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fiber'],
      )!,
      sodium: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sodium'],
      )!,
      sugar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sugar'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String id;
  final String title;
  final String? versionLabel;
  final String notes;
  final int servings;
  final bool isPinned;
  final int sortCalories;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int sodium;
  final int sugar;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Recipe({
    required this.id,
    required this.title,
    this.versionLabel,
    required this.notes,
    required this.servings,
    required this.isPinned,
    required this.sortCalories,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sodium,
    required this.sugar,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || versionLabel != null) {
      map['version_label'] = Variable<String>(versionLabel);
    }
    map['notes'] = Variable<String>(notes);
    map['servings'] = Variable<int>(servings);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['sort_calories'] = Variable<int>(sortCalories);
    map['calories'] = Variable<int>(calories);
    map['protein'] = Variable<int>(protein);
    map['carbs'] = Variable<int>(carbs);
    map['fat'] = Variable<int>(fat);
    map['fiber'] = Variable<int>(fiber);
    map['sodium'] = Variable<int>(sodium);
    map['sugar'] = Variable<int>(sugar);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      title: Value(title),
      versionLabel: versionLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(versionLabel),
      notes: Value(notes),
      servings: Value(servings),
      isPinned: Value(isPinned),
      sortCalories: Value(sortCalories),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      fiber: Value(fiber),
      sodium: Value(sodium),
      sugar: Value(sugar),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      versionLabel: serializer.fromJson<String?>(json['versionLabel']),
      notes: serializer.fromJson<String>(json['notes']),
      servings: serializer.fromJson<int>(json['servings']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      sortCalories: serializer.fromJson<int>(json['sortCalories']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<int>(json['protein']),
      carbs: serializer.fromJson<int>(json['carbs']),
      fat: serializer.fromJson<int>(json['fat']),
      fiber: serializer.fromJson<int>(json['fiber']),
      sodium: serializer.fromJson<int>(json['sodium']),
      sugar: serializer.fromJson<int>(json['sugar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'versionLabel': serializer.toJson<String?>(versionLabel),
      'notes': serializer.toJson<String>(notes),
      'servings': serializer.toJson<int>(servings),
      'isPinned': serializer.toJson<bool>(isPinned),
      'sortCalories': serializer.toJson<int>(sortCalories),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<int>(protein),
      'carbs': serializer.toJson<int>(carbs),
      'fat': serializer.toJson<int>(fat),
      'fiber': serializer.toJson<int>(fiber),
      'sodium': serializer.toJson<int>(sodium),
      'sugar': serializer.toJson<int>(sugar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    Value<String?> versionLabel = const Value.absent(),
    String? notes,
    int? servings,
    bool? isPinned,
    int? sortCalories,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
    int? sodium,
    int? sugar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Recipe(
    id: id ?? this.id,
    title: title ?? this.title,
    versionLabel: versionLabel.present ? versionLabel.value : this.versionLabel,
    notes: notes ?? this.notes,
    servings: servings ?? this.servings,
    isPinned: isPinned ?? this.isPinned,
    sortCalories: sortCalories ?? this.sortCalories,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    fiber: fiber ?? this.fiber,
    sodium: sodium ?? this.sodium,
    sugar: sugar ?? this.sugar,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      versionLabel: data.versionLabel.present
          ? data.versionLabel.value
          : this.versionLabel,
      notes: data.notes.present ? data.notes.value : this.notes,
      servings: data.servings.present ? data.servings.value : this.servings,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      sortCalories: data.sortCalories.present
          ? data.sortCalories.value
          : this.sortCalories,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('versionLabel: $versionLabel, ')
          ..write('notes: $notes, ')
          ..write('servings: $servings, ')
          ..write('isPinned: $isPinned, ')
          ..write('sortCalories: $sortCalories, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('sugar: $sugar, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    versionLabel,
    notes,
    servings,
    isPinned,
    sortCalories,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sodium,
    sugar,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.title == this.title &&
          other.versionLabel == this.versionLabel &&
          other.notes == this.notes &&
          other.servings == this.servings &&
          other.isPinned == this.isPinned &&
          other.sortCalories == this.sortCalories &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.sodium == this.sodium &&
          other.sugar == this.sugar &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> versionLabel;
  final Value<String> notes;
  final Value<int> servings;
  final Value<bool> isPinned;
  final Value<int> sortCalories;
  final Value<int> calories;
  final Value<int> protein;
  final Value<int> carbs;
  final Value<int> fat;
  final Value<int> fiber;
  final Value<int> sodium;
  final Value<int> sugar;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.versionLabel = const Value.absent(),
    this.notes = const Value.absent(),
    this.servings = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.sortCalories = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.sugar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required String title,
    this.versionLabel = const Value.absent(),
    required String notes,
    required int servings,
    this.isPinned = const Value.absent(),
    required int sortCalories,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required int fiber,
    required int sodium,
    required int sugar,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       notes = Value(notes),
       servings = Value(servings),
       sortCalories = Value(sortCalories),
       calories = Value(calories),
       protein = Value(protein),
       carbs = Value(carbs),
       fat = Value(fat),
       fiber = Value(fiber),
       sodium = Value(sodium),
       sugar = Value(sugar),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Recipe> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? versionLabel,
    Expression<String>? notes,
    Expression<int>? servings,
    Expression<bool>? isPinned,
    Expression<int>? sortCalories,
    Expression<int>? calories,
    Expression<int>? protein,
    Expression<int>? carbs,
    Expression<int>? fat,
    Expression<int>? fiber,
    Expression<int>? sodium,
    Expression<int>? sugar,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (versionLabel != null) 'version_label': versionLabel,
      if (notes != null) 'notes': notes,
      if (servings != null) 'servings': servings,
      if (isPinned != null) 'is_pinned': isPinned,
      if (sortCalories != null) 'sort_calories': sortCalories,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (sodium != null) 'sodium': sodium,
      if (sugar != null) 'sugar': sugar,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? versionLabel,
    Value<String>? notes,
    Value<int>? servings,
    Value<bool>? isPinned,
    Value<int>? sortCalories,
    Value<int>? calories,
    Value<int>? protein,
    Value<int>? carbs,
    Value<int>? fat,
    Value<int>? fiber,
    Value<int>? sodium,
    Value<int>? sugar,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      versionLabel: versionLabel ?? this.versionLabel,
      notes: notes ?? this.notes,
      servings: servings ?? this.servings,
      isPinned: isPinned ?? this.isPinned,
      sortCalories: sortCalories ?? this.sortCalories,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      sugar: sugar ?? this.sugar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (versionLabel.present) {
      map['version_label'] = Variable<String>(versionLabel.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (sortCalories.present) {
      map['sort_calories'] = Variable<int>(sortCalories.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<int>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<int>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<int>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<int>(fiber.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<int>(sodium.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<int>(sugar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('versionLabel: $versionLabel, ')
          ..write('notes: $notes, ')
          ..write('servings: $servings, ')
          ..write('isPinned: $isPinned, ')
          ..write('sortCalories: $sortCalories, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('sugar: $sugar, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipeTagsTable extends RecipeTags
    with TableInfo<$RecipeTagsTable, RecipeTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, recipeId, label, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $RecipeTagsTable createAlias(String alias) {
    return $RecipeTagsTable(attachedDatabase, alias);
  }
}

class RecipeTag extends DataClass implements Insertable<RecipeTag> {
  final int id;
  final String recipeId;
  final String label;
  final int position;
  const RecipeTag({
    required this.id,
    required this.recipeId,
    required this.label,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['label'] = Variable<String>(label);
    map['position'] = Variable<int>(position);
    return map;
  }

  RecipeTagsCompanion toCompanion(bool nullToAbsent) {
    return RecipeTagsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      label: Value(label),
      position: Value(position),
    );
  }

  factory RecipeTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeTag(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      label: serializer.fromJson<String>(json['label']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'label': serializer.toJson<String>(label),
      'position': serializer.toJson<int>(position),
    };
  }

  RecipeTag copyWith({
    int? id,
    String? recipeId,
    String? label,
    int? position,
  }) => RecipeTag(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    label: label ?? this.label,
    position: position ?? this.position,
  );
  RecipeTag copyWithCompanion(RecipeTagsCompanion data) {
    return RecipeTag(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      label: data.label.present ? data.label.value : this.label,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeTag(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('label: $label, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, label, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeTag &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.label == this.label &&
          other.position == this.position);
}

class RecipeTagsCompanion extends UpdateCompanion<RecipeTag> {
  final Value<int> id;
  final Value<String> recipeId;
  final Value<String> label;
  final Value<int> position;
  const RecipeTagsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.label = const Value.absent(),
    this.position = const Value.absent(),
  });
  RecipeTagsCompanion.insert({
    this.id = const Value.absent(),
    required String recipeId,
    required String label,
    required int position,
  }) : recipeId = Value(recipeId),
       label = Value(label),
       position = Value(position);
  static Insertable<RecipeTag> custom({
    Expression<int>? id,
    Expression<String>? recipeId,
    Expression<String>? label,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (label != null) 'label': label,
      if (position != null) 'position': position,
    });
  }

  RecipeTagsCompanion copyWith({
    Value<int>? id,
    Value<String>? recipeId,
    Value<String>? label,
    Value<int>? position,
  }) {
    return RecipeTagsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      label: label ?? this.label,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeTagsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('label: $label, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $RecipeIngredientsTable extends RecipeIngredients
    with TableInfo<$RecipeIngredientsTable, RecipeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<String> item = GeneratedColumn<String>(
    'item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preparationMeta = const VerificationMeta(
    'preparation',
  );
  @override
  late final GeneratedColumn<String> preparation = GeneratedColumn<String>(
    'preparation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientTypeMeta = const VerificationMeta(
    'ingredientType',
  );
  @override
  late final GeneratedColumn<String> ingredientType = GeneratedColumn<String>(
    'ingredient_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('freeform'),
  );
  static const VerificationMeta _linkedPantryItemIdMeta =
      const VerificationMeta('linkedPantryItemId');
  @override
  late final GeneratedColumn<String> linkedPantryItemId =
      GeneratedColumn<String>(
        'linked_pantry_item_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _linkedRecipeIdMeta = const VerificationMeta(
    'linkedRecipeId',
  );
  @override
  late final GeneratedColumn<String> linkedRecipeId = GeneratedColumn<String>(
    'linked_recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    position,
    quantity,
    unit,
    item,
    preparation,
    ingredientType,
    linkedPantryItemId,
    linkedRecipeId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('item')) {
      context.handle(
        _itemMeta,
        item.isAcceptableOrUnknown(data['item']!, _itemMeta),
      );
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('preparation')) {
      context.handle(
        _preparationMeta,
        preparation.isAcceptableOrUnknown(
          data['preparation']!,
          _preparationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preparationMeta);
    }
    if (data.containsKey('ingredient_type')) {
      context.handle(
        _ingredientTypeMeta,
        ingredientType.isAcceptableOrUnknown(
          data['ingredient_type']!,
          _ingredientTypeMeta,
        ),
      );
    }
    if (data.containsKey('linked_pantry_item_id')) {
      context.handle(
        _linkedPantryItemIdMeta,
        linkedPantryItemId.isAcceptableOrUnknown(
          data['linked_pantry_item_id']!,
          _linkedPantryItemIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_recipe_id')) {
      context.handle(
        _linkedRecipeIdMeta,
        linkedRecipeId.isAcceptableOrUnknown(
          data['linked_recipe_id']!,
          _linkedRecipeIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      item: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item'],
      )!,
      preparation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preparation'],
      )!,
      ingredientType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_type'],
      )!,
      linkedPantryItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_pantry_item_id'],
      ),
      linkedRecipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_recipe_id'],
      ),
    );
  }

  @override
  $RecipeIngredientsTable createAlias(String alias) {
    return $RecipeIngredientsTable(attachedDatabase, alias);
  }
}

class RecipeIngredient extends DataClass
    implements Insertable<RecipeIngredient> {
  final int id;
  final String recipeId;
  final int position;
  final String quantity;
  final String unit;
  final String item;
  final String preparation;
  final String ingredientType;
  final String? linkedPantryItemId;
  final String? linkedRecipeId;
  const RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.quantity,
    required this.unit,
    required this.item,
    required this.preparation,
    required this.ingredientType,
    this.linkedPantryItemId,
    this.linkedRecipeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['position'] = Variable<int>(position);
    map['quantity'] = Variable<String>(quantity);
    map['unit'] = Variable<String>(unit);
    map['item'] = Variable<String>(item);
    map['preparation'] = Variable<String>(preparation);
    map['ingredient_type'] = Variable<String>(ingredientType);
    if (!nullToAbsent || linkedPantryItemId != null) {
      map['linked_pantry_item_id'] = Variable<String>(linkedPantryItemId);
    }
    if (!nullToAbsent || linkedRecipeId != null) {
      map['linked_recipe_id'] = Variable<String>(linkedRecipeId);
    }
    return map;
  }

  RecipeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return RecipeIngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      position: Value(position),
      quantity: Value(quantity),
      unit: Value(unit),
      item: Value(item),
      preparation: Value(preparation),
      ingredientType: Value(ingredientType),
      linkedPantryItemId: linkedPantryItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedPantryItemId),
      linkedRecipeId: linkedRecipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedRecipeId),
    );
  }

  factory RecipeIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeIngredient(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      item: serializer.fromJson<String>(json['item']),
      preparation: serializer.fromJson<String>(json['preparation']),
      ingredientType: serializer.fromJson<String>(json['ingredientType']),
      linkedPantryItemId: serializer.fromJson<String?>(
        json['linkedPantryItemId'],
      ),
      linkedRecipeId: serializer.fromJson<String?>(json['linkedRecipeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'position': serializer.toJson<int>(position),
      'quantity': serializer.toJson<String>(quantity),
      'unit': serializer.toJson<String>(unit),
      'item': serializer.toJson<String>(item),
      'preparation': serializer.toJson<String>(preparation),
      'ingredientType': serializer.toJson<String>(ingredientType),
      'linkedPantryItemId': serializer.toJson<String?>(linkedPantryItemId),
      'linkedRecipeId': serializer.toJson<String?>(linkedRecipeId),
    };
  }

  RecipeIngredient copyWith({
    int? id,
    String? recipeId,
    int? position,
    String? quantity,
    String? unit,
    String? item,
    String? preparation,
    String? ingredientType,
    Value<String?> linkedPantryItemId = const Value.absent(),
    Value<String?> linkedRecipeId = const Value.absent(),
  }) => RecipeIngredient(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    item: item ?? this.item,
    preparation: preparation ?? this.preparation,
    ingredientType: ingredientType ?? this.ingredientType,
    linkedPantryItemId: linkedPantryItemId.present
        ? linkedPantryItemId.value
        : this.linkedPantryItemId,
    linkedRecipeId: linkedRecipeId.present
        ? linkedRecipeId.value
        : this.linkedRecipeId,
  );
  RecipeIngredient copyWithCompanion(RecipeIngredientsCompanion data) {
    return RecipeIngredient(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      item: data.item.present ? data.item.value : this.item,
      preparation: data.preparation.present
          ? data.preparation.value
          : this.preparation,
      ingredientType: data.ingredientType.present
          ? data.ingredientType.value
          : this.ingredientType,
      linkedPantryItemId: data.linkedPantryItemId.present
          ? data.linkedPantryItemId.value
          : this.linkedPantryItemId,
      linkedRecipeId: data.linkedRecipeId.present
          ? data.linkedRecipeId.value
          : this.linkedRecipeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredient(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('item: $item, ')
          ..write('preparation: $preparation, ')
          ..write('ingredientType: $ingredientType, ')
          ..write('linkedPantryItemId: $linkedPantryItemId, ')
          ..write('linkedRecipeId: $linkedRecipeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    position,
    quantity,
    unit,
    item,
    preparation,
    ingredientType,
    linkedPantryItemId,
    linkedRecipeId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeIngredient &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.item == this.item &&
          other.preparation == this.preparation &&
          other.ingredientType == this.ingredientType &&
          other.linkedPantryItemId == this.linkedPantryItemId &&
          other.linkedRecipeId == this.linkedRecipeId);
}

class RecipeIngredientsCompanion extends UpdateCompanion<RecipeIngredient> {
  final Value<int> id;
  final Value<String> recipeId;
  final Value<int> position;
  final Value<String> quantity;
  final Value<String> unit;
  final Value<String> item;
  final Value<String> preparation;
  final Value<String> ingredientType;
  final Value<String?> linkedPantryItemId;
  final Value<String?> linkedRecipeId;
  const RecipeIngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.item = const Value.absent(),
    this.preparation = const Value.absent(),
    this.ingredientType = const Value.absent(),
    this.linkedPantryItemId = const Value.absent(),
    this.linkedRecipeId = const Value.absent(),
  });
  RecipeIngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String recipeId,
    required int position,
    required String quantity,
    required String unit,
    required String item,
    required String preparation,
    this.ingredientType = const Value.absent(),
    this.linkedPantryItemId = const Value.absent(),
    this.linkedRecipeId = const Value.absent(),
  }) : recipeId = Value(recipeId),
       position = Value(position),
       quantity = Value(quantity),
       unit = Value(unit),
       item = Value(item),
       preparation = Value(preparation);
  static Insertable<RecipeIngredient> custom({
    Expression<int>? id,
    Expression<String>? recipeId,
    Expression<int>? position,
    Expression<String>? quantity,
    Expression<String>? unit,
    Expression<String>? item,
    Expression<String>? preparation,
    Expression<String>? ingredientType,
    Expression<String>? linkedPantryItemId,
    Expression<String>? linkedRecipeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (item != null) 'item': item,
      if (preparation != null) 'preparation': preparation,
      if (ingredientType != null) 'ingredient_type': ingredientType,
      if (linkedPantryItemId != null)
        'linked_pantry_item_id': linkedPantryItemId,
      if (linkedRecipeId != null) 'linked_recipe_id': linkedRecipeId,
    });
  }

  RecipeIngredientsCompanion copyWith({
    Value<int>? id,
    Value<String>? recipeId,
    Value<int>? position,
    Value<String>? quantity,
    Value<String>? unit,
    Value<String>? item,
    Value<String>? preparation,
    Value<String>? ingredientType,
    Value<String?>? linkedPantryItemId,
    Value<String?>? linkedRecipeId,
  }) {
    return RecipeIngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      item: item ?? this.item,
      preparation: preparation ?? this.preparation,
      ingredientType: ingredientType ?? this.ingredientType,
      linkedPantryItemId: linkedPantryItemId ?? this.linkedPantryItemId,
      linkedRecipeId: linkedRecipeId ?? this.linkedRecipeId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (preparation.present) {
      map['preparation'] = Variable<String>(preparation.value);
    }
    if (ingredientType.present) {
      map['ingredient_type'] = Variable<String>(ingredientType.value);
    }
    if (linkedPantryItemId.present) {
      map['linked_pantry_item_id'] = Variable<String>(linkedPantryItemId.value);
    }
    if (linkedRecipeId.present) {
      map['linked_recipe_id'] = Variable<String>(linkedRecipeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('item: $item, ')
          ..write('preparation: $preparation, ')
          ..write('ingredientType: $ingredientType, ')
          ..write('linkedPantryItemId: $linkedPantryItemId, ')
          ..write('linkedRecipeId: $linkedRecipeId')
          ..write(')'))
        .toString();
  }
}

class $RecipeDirectionsTable extends RecipeDirections
    with TableInfo<$RecipeDirectionsTable, RecipeDirection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipeDirectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recipes (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionMeta = const VerificationMeta(
    'instruction',
  );
  @override
  late final GeneratedColumn<String> instruction = GeneratedColumn<String>(
    'instruction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, recipeId, position, instruction];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipe_directions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeDirection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('instruction')) {
      context.handle(
        _instructionMeta,
        instruction.isAcceptableOrUnknown(
          data['instruction']!,
          _instructionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeDirection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeDirection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      instruction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instruction'],
      )!,
    );
  }

  @override
  $RecipeDirectionsTable createAlias(String alias) {
    return $RecipeDirectionsTable(attachedDatabase, alias);
  }
}

class RecipeDirection extends DataClass implements Insertable<RecipeDirection> {
  final int id;
  final String recipeId;
  final int position;
  final String instruction;
  const RecipeDirection({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.instruction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['position'] = Variable<int>(position);
    map['instruction'] = Variable<String>(instruction);
    return map;
  }

  RecipeDirectionsCompanion toCompanion(bool nullToAbsent) {
    return RecipeDirectionsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      position: Value(position),
      instruction: Value(instruction),
    );
  }

  factory RecipeDirection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeDirection(
      id: serializer.fromJson<int>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      instruction: serializer.fromJson<String>(json['instruction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'position': serializer.toJson<int>(position),
      'instruction': serializer.toJson<String>(instruction),
    };
  }

  RecipeDirection copyWith({
    int? id,
    String? recipeId,
    int? position,
    String? instruction,
  }) => RecipeDirection(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    instruction: instruction ?? this.instruction,
  );
  RecipeDirection copyWithCompanion(RecipeDirectionsCompanion data) {
    return RecipeDirection(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      instruction: data.instruction.present
          ? data.instruction.value
          : this.instruction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeDirection(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('instruction: $instruction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, recipeId, position, instruction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeDirection &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.instruction == this.instruction);
}

class RecipeDirectionsCompanion extends UpdateCompanion<RecipeDirection> {
  final Value<int> id;
  final Value<String> recipeId;
  final Value<int> position;
  final Value<String> instruction;
  const RecipeDirectionsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.instruction = const Value.absent(),
  });
  RecipeDirectionsCompanion.insert({
    this.id = const Value.absent(),
    required String recipeId,
    required int position,
    required String instruction,
  }) : recipeId = Value(recipeId),
       position = Value(position),
       instruction = Value(instruction);
  static Insertable<RecipeDirection> custom({
    Expression<int>? id,
    Expression<String>? recipeId,
    Expression<int>? position,
    Expression<String>? instruction,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (instruction != null) 'instruction': instruction,
    });
  }

  RecipeDirectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? recipeId,
    Value<int>? position,
    Value<String>? instruction,
  }) {
    return RecipeDirectionsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      instruction: instruction ?? this.instruction,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (instruction.present) {
      map['instruction'] = Variable<String>(instruction.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipeDirectionsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('instruction: $instruction')
          ..write(')'))
        .toString();
  }
}

class $PantryItemsTableTable extends PantryItemsTable
    with TableInfo<$PantryItemsTableTable, PantryItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PantryItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityLabelMeta = const VerificationMeta(
    'quantityLabel',
  );
  @override
  late final GeneratedColumn<String> quantityLabel = GeneratedColumn<String>(
    'quantity_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceUnitQuantityMeta =
      const VerificationMeta('referenceUnitQuantity');
  @override
  late final GeneratedColumn<double> referenceUnitQuantity =
      GeneratedColumn<double>(
        'reference_unit_quantity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1),
      );
  static const VerificationMeta _referenceUnitMeta = const VerificationMeta(
    'referenceUnit',
  );
  @override
  late final GeneratedColumn<String> referenceUnit = GeneratedColumn<String>(
    'reference_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('serving'),
  );
  static const VerificationMeta _referenceUnitEquivalentQuantityMeta =
      const VerificationMeta('referenceUnitEquivalentQuantity');
  @override
  late final GeneratedColumn<double> referenceUnitEquivalentQuantity =
      GeneratedColumn<double>(
        'reference_unit_equivalent_quantity',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _referenceUnitEquivalentUnitMeta =
      const VerificationMeta('referenceUnitEquivalentUnit');
  @override
  late final GeneratedColumn<String> referenceUnitEquivalentUnit =
      GeneratedColumn<String>(
        'reference_unit_equivalent_unit',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _referenceUnitWeightGramsMeta =
      const VerificationMeta('referenceUnitWeightGrams');
  @override
  late final GeneratedColumn<double> referenceUnitWeightGrams =
      GeneratedColumn<double>(
        'reference_unit_weight_grams',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentHexMeta = const VerificationMeta(
    'accentHex',
  );
  @override
  late final GeneratedColumn<int> accentHex = GeneratedColumn<int>(
    'accent_hex',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<int> protein = GeneratedColumn<int>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<int> carbs = GeneratedColumn<int>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<int> fat = GeneratedColumn<int>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<int> fiber = GeneratedColumn<int>(
    'fiber',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<int> sodium = GeneratedColumn<int>(
    'sodium',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<int> sugar = GeneratedColumn<int>(
    'sugar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    quantityLabel,
    referenceUnitQuantity,
    referenceUnit,
    referenceUnitEquivalentQuantity,
    referenceUnitEquivalentUnit,
    referenceUnitWeightGrams,
    source,
    accentHex,
    barcode,
    brand,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sodium,
    sugar,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pantry_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PantryItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('quantity_label')) {
      context.handle(
        _quantityLabelMeta,
        quantityLabel.isAcceptableOrUnknown(
          data['quantity_label']!,
          _quantityLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityLabelMeta);
    }
    if (data.containsKey('reference_unit_quantity')) {
      context.handle(
        _referenceUnitQuantityMeta,
        referenceUnitQuantity.isAcceptableOrUnknown(
          data['reference_unit_quantity']!,
          _referenceUnitQuantityMeta,
        ),
      );
    }
    if (data.containsKey('reference_unit')) {
      context.handle(
        _referenceUnitMeta,
        referenceUnit.isAcceptableOrUnknown(
          data['reference_unit']!,
          _referenceUnitMeta,
        ),
      );
    }
    if (data.containsKey('reference_unit_equivalent_quantity')) {
      context.handle(
        _referenceUnitEquivalentQuantityMeta,
        referenceUnitEquivalentQuantity.isAcceptableOrUnknown(
          data['reference_unit_equivalent_quantity']!,
          _referenceUnitEquivalentQuantityMeta,
        ),
      );
    }
    if (data.containsKey('reference_unit_equivalent_unit')) {
      context.handle(
        _referenceUnitEquivalentUnitMeta,
        referenceUnitEquivalentUnit.isAcceptableOrUnknown(
          data['reference_unit_equivalent_unit']!,
          _referenceUnitEquivalentUnitMeta,
        ),
      );
    }
    if (data.containsKey('reference_unit_weight_grams')) {
      context.handle(
        _referenceUnitWeightGramsMeta,
        referenceUnitWeightGrams.isAcceptableOrUnknown(
          data['reference_unit_weight_grams']!,
          _referenceUnitWeightGramsMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('accent_hex')) {
      context.handle(
        _accentHexMeta,
        accentHex.isAcceptableOrUnknown(data['accent_hex']!, _accentHexMeta),
      );
    } else if (isInserting) {
      context.missing(_accentHexMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    } else if (isInserting) {
      context.missing(_fiberMeta);
    }
    if (data.containsKey('sodium')) {
      context.handle(
        _sodiumMeta,
        sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta),
      );
    } else if (isInserting) {
      context.missing(_sodiumMeta);
    }
    if (data.containsKey('sugar')) {
      context.handle(
        _sugarMeta,
        sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta),
      );
    } else if (isInserting) {
      context.missing(_sugarMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PantryItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PantryItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      quantityLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_label'],
      )!,
      referenceUnitQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reference_unit_quantity'],
      )!,
      referenceUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_unit'],
      )!,
      referenceUnitEquivalentQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reference_unit_equivalent_quantity'],
      ),
      referenceUnitEquivalentUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_unit_equivalent_unit'],
      ),
      referenceUnitWeightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reference_unit_weight_grams'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      accentHex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_hex'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carbs'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fat'],
      )!,
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fiber'],
      )!,
      sodium: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sodium'],
      )!,
      sugar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sugar'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PantryItemsTableTable createAlias(String alias) {
    return $PantryItemsTableTable(attachedDatabase, alias);
  }
}

class PantryItemsTableData extends DataClass
    implements Insertable<PantryItemsTableData> {
  final String id;
  final String title;
  final String quantityLabel;
  final double referenceUnitQuantity;
  final String referenceUnit;
  final double? referenceUnitEquivalentQuantity;
  final String? referenceUnitEquivalentUnit;
  final double? referenceUnitWeightGrams;
  final String source;
  final int accentHex;
  final String? barcode;
  final String? brand;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int sodium;
  final int sugar;
  final DateTime createdAt;
  const PantryItemsTableData({
    required this.id,
    required this.title,
    required this.quantityLabel,
    required this.referenceUnitQuantity,
    required this.referenceUnit,
    this.referenceUnitEquivalentQuantity,
    this.referenceUnitEquivalentUnit,
    this.referenceUnitWeightGrams,
    required this.source,
    required this.accentHex,
    this.barcode,
    this.brand,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sodium,
    required this.sugar,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['quantity_label'] = Variable<String>(quantityLabel);
    map['reference_unit_quantity'] = Variable<double>(referenceUnitQuantity);
    map['reference_unit'] = Variable<String>(referenceUnit);
    if (!nullToAbsent || referenceUnitEquivalentQuantity != null) {
      map['reference_unit_equivalent_quantity'] = Variable<double>(
        referenceUnitEquivalentQuantity,
      );
    }
    if (!nullToAbsent || referenceUnitEquivalentUnit != null) {
      map['reference_unit_equivalent_unit'] = Variable<String>(
        referenceUnitEquivalentUnit,
      );
    }
    if (!nullToAbsent || referenceUnitWeightGrams != null) {
      map['reference_unit_weight_grams'] = Variable<double>(
        referenceUnitWeightGrams,
      );
    }
    map['source'] = Variable<String>(source);
    map['accent_hex'] = Variable<int>(accentHex);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['calories'] = Variable<int>(calories);
    map['protein'] = Variable<int>(protein);
    map['carbs'] = Variable<int>(carbs);
    map['fat'] = Variable<int>(fat);
    map['fiber'] = Variable<int>(fiber);
    map['sodium'] = Variable<int>(sodium);
    map['sugar'] = Variable<int>(sugar);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PantryItemsTableCompanion toCompanion(bool nullToAbsent) {
    return PantryItemsTableCompanion(
      id: Value(id),
      title: Value(title),
      quantityLabel: Value(quantityLabel),
      referenceUnitQuantity: Value(referenceUnitQuantity),
      referenceUnit: Value(referenceUnit),
      referenceUnitEquivalentQuantity:
          referenceUnitEquivalentQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceUnitEquivalentQuantity),
      referenceUnitEquivalentUnit:
          referenceUnitEquivalentUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceUnitEquivalentUnit),
      referenceUnitWeightGrams: referenceUnitWeightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceUnitWeightGrams),
      source: Value(source),
      accentHex: Value(accentHex),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      fiber: Value(fiber),
      sodium: Value(sodium),
      sugar: Value(sugar),
      createdAt: Value(createdAt),
    );
  }

  factory PantryItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PantryItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      quantityLabel: serializer.fromJson<String>(json['quantityLabel']),
      referenceUnitQuantity: serializer.fromJson<double>(
        json['referenceUnitQuantity'],
      ),
      referenceUnit: serializer.fromJson<String>(json['referenceUnit']),
      referenceUnitEquivalentQuantity: serializer.fromJson<double?>(
        json['referenceUnitEquivalentQuantity'],
      ),
      referenceUnitEquivalentUnit: serializer.fromJson<String?>(
        json['referenceUnitEquivalentUnit'],
      ),
      referenceUnitWeightGrams: serializer.fromJson<double?>(
        json['referenceUnitWeightGrams'],
      ),
      source: serializer.fromJson<String>(json['source']),
      accentHex: serializer.fromJson<int>(json['accentHex']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      brand: serializer.fromJson<String?>(json['brand']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<int>(json['protein']),
      carbs: serializer.fromJson<int>(json['carbs']),
      fat: serializer.fromJson<int>(json['fat']),
      fiber: serializer.fromJson<int>(json['fiber']),
      sodium: serializer.fromJson<int>(json['sodium']),
      sugar: serializer.fromJson<int>(json['sugar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'quantityLabel': serializer.toJson<String>(quantityLabel),
      'referenceUnitQuantity': serializer.toJson<double>(referenceUnitQuantity),
      'referenceUnit': serializer.toJson<String>(referenceUnit),
      'referenceUnitEquivalentQuantity': serializer.toJson<double?>(
        referenceUnitEquivalentQuantity,
      ),
      'referenceUnitEquivalentUnit': serializer.toJson<String?>(
        referenceUnitEquivalentUnit,
      ),
      'referenceUnitWeightGrams': serializer.toJson<double?>(
        referenceUnitWeightGrams,
      ),
      'source': serializer.toJson<String>(source),
      'accentHex': serializer.toJson<int>(accentHex),
      'barcode': serializer.toJson<String?>(barcode),
      'brand': serializer.toJson<String?>(brand),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<int>(protein),
      'carbs': serializer.toJson<int>(carbs),
      'fat': serializer.toJson<int>(fat),
      'fiber': serializer.toJson<int>(fiber),
      'sodium': serializer.toJson<int>(sodium),
      'sugar': serializer.toJson<int>(sugar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PantryItemsTableData copyWith({
    String? id,
    String? title,
    String? quantityLabel,
    double? referenceUnitQuantity,
    String? referenceUnit,
    Value<double?> referenceUnitEquivalentQuantity = const Value.absent(),
    Value<String?> referenceUnitEquivalentUnit = const Value.absent(),
    Value<double?> referenceUnitWeightGrams = const Value.absent(),
    String? source,
    int? accentHex,
    Value<String?> barcode = const Value.absent(),
    Value<String?> brand = const Value.absent(),
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
    int? sodium,
    int? sugar,
    DateTime? createdAt,
  }) => PantryItemsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    quantityLabel: quantityLabel ?? this.quantityLabel,
    referenceUnitQuantity: referenceUnitQuantity ?? this.referenceUnitQuantity,
    referenceUnit: referenceUnit ?? this.referenceUnit,
    referenceUnitEquivalentQuantity: referenceUnitEquivalentQuantity.present
        ? referenceUnitEquivalentQuantity.value
        : this.referenceUnitEquivalentQuantity,
    referenceUnitEquivalentUnit: referenceUnitEquivalentUnit.present
        ? referenceUnitEquivalentUnit.value
        : this.referenceUnitEquivalentUnit,
    referenceUnitWeightGrams: referenceUnitWeightGrams.present
        ? referenceUnitWeightGrams.value
        : this.referenceUnitWeightGrams,
    source: source ?? this.source,
    accentHex: accentHex ?? this.accentHex,
    barcode: barcode.present ? barcode.value : this.barcode,
    brand: brand.present ? brand.value : this.brand,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    fiber: fiber ?? this.fiber,
    sodium: sodium ?? this.sodium,
    sugar: sugar ?? this.sugar,
    createdAt: createdAt ?? this.createdAt,
  );
  PantryItemsTableData copyWithCompanion(PantryItemsTableCompanion data) {
    return PantryItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      quantityLabel: data.quantityLabel.present
          ? data.quantityLabel.value
          : this.quantityLabel,
      referenceUnitQuantity: data.referenceUnitQuantity.present
          ? data.referenceUnitQuantity.value
          : this.referenceUnitQuantity,
      referenceUnit: data.referenceUnit.present
          ? data.referenceUnit.value
          : this.referenceUnit,
      referenceUnitEquivalentQuantity:
          data.referenceUnitEquivalentQuantity.present
          ? data.referenceUnitEquivalentQuantity.value
          : this.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit: data.referenceUnitEquivalentUnit.present
          ? data.referenceUnitEquivalentUnit.value
          : this.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams: data.referenceUnitWeightGrams.present
          ? data.referenceUnitWeightGrams.value
          : this.referenceUnitWeightGrams,
      source: data.source.present ? data.source.value : this.source,
      accentHex: data.accentHex.present ? data.accentHex.value : this.accentHex,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      brand: data.brand.present ? data.brand.value : this.brand,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PantryItemsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('quantityLabel: $quantityLabel, ')
          ..write('referenceUnitQuantity: $referenceUnitQuantity, ')
          ..write('referenceUnit: $referenceUnit, ')
          ..write(
            'referenceUnitEquivalentQuantity: $referenceUnitEquivalentQuantity, ',
          )
          ..write('referenceUnitEquivalentUnit: $referenceUnitEquivalentUnit, ')
          ..write('referenceUnitWeightGrams: $referenceUnitWeightGrams, ')
          ..write('source: $source, ')
          ..write('accentHex: $accentHex, ')
          ..write('barcode: $barcode, ')
          ..write('brand: $brand, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('sugar: $sugar, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    quantityLabel,
    referenceUnitQuantity,
    referenceUnit,
    referenceUnitEquivalentQuantity,
    referenceUnitEquivalentUnit,
    referenceUnitWeightGrams,
    source,
    accentHex,
    barcode,
    brand,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sodium,
    sugar,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PantryItemsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.quantityLabel == this.quantityLabel &&
          other.referenceUnitQuantity == this.referenceUnitQuantity &&
          other.referenceUnit == this.referenceUnit &&
          other.referenceUnitEquivalentQuantity ==
              this.referenceUnitEquivalentQuantity &&
          other.referenceUnitEquivalentUnit ==
              this.referenceUnitEquivalentUnit &&
          other.referenceUnitWeightGrams == this.referenceUnitWeightGrams &&
          other.source == this.source &&
          other.accentHex == this.accentHex &&
          other.barcode == this.barcode &&
          other.brand == this.brand &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.sodium == this.sodium &&
          other.sugar == this.sugar &&
          other.createdAt == this.createdAt);
}

class PantryItemsTableCompanion extends UpdateCompanion<PantryItemsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> quantityLabel;
  final Value<double> referenceUnitQuantity;
  final Value<String> referenceUnit;
  final Value<double?> referenceUnitEquivalentQuantity;
  final Value<String?> referenceUnitEquivalentUnit;
  final Value<double?> referenceUnitWeightGrams;
  final Value<String> source;
  final Value<int> accentHex;
  final Value<String?> barcode;
  final Value<String?> brand;
  final Value<int> calories;
  final Value<int> protein;
  final Value<int> carbs;
  final Value<int> fat;
  final Value<int> fiber;
  final Value<int> sodium;
  final Value<int> sugar;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PantryItemsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.quantityLabel = const Value.absent(),
    this.referenceUnitQuantity = const Value.absent(),
    this.referenceUnit = const Value.absent(),
    this.referenceUnitEquivalentQuantity = const Value.absent(),
    this.referenceUnitEquivalentUnit = const Value.absent(),
    this.referenceUnitWeightGrams = const Value.absent(),
    this.source = const Value.absent(),
    this.accentHex = const Value.absent(),
    this.barcode = const Value.absent(),
    this.brand = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.sugar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PantryItemsTableCompanion.insert({
    required String id,
    required String title,
    required String quantityLabel,
    this.referenceUnitQuantity = const Value.absent(),
    this.referenceUnit = const Value.absent(),
    this.referenceUnitEquivalentQuantity = const Value.absent(),
    this.referenceUnitEquivalentUnit = const Value.absent(),
    this.referenceUnitWeightGrams = const Value.absent(),
    required String source,
    required int accentHex,
    this.barcode = const Value.absent(),
    this.brand = const Value.absent(),
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required int fiber,
    required int sodium,
    required int sugar,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       quantityLabel = Value(quantityLabel),
       source = Value(source),
       accentHex = Value(accentHex),
       calories = Value(calories),
       protein = Value(protein),
       carbs = Value(carbs),
       fat = Value(fat),
       fiber = Value(fiber),
       sodium = Value(sodium),
       sugar = Value(sugar),
       createdAt = Value(createdAt);
  static Insertable<PantryItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? quantityLabel,
    Expression<double>? referenceUnitQuantity,
    Expression<String>? referenceUnit,
    Expression<double>? referenceUnitEquivalentQuantity,
    Expression<String>? referenceUnitEquivalentUnit,
    Expression<double>? referenceUnitWeightGrams,
    Expression<String>? source,
    Expression<int>? accentHex,
    Expression<String>? barcode,
    Expression<String>? brand,
    Expression<int>? calories,
    Expression<int>? protein,
    Expression<int>? carbs,
    Expression<int>? fat,
    Expression<int>? fiber,
    Expression<int>? sodium,
    Expression<int>? sugar,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (quantityLabel != null) 'quantity_label': quantityLabel,
      if (referenceUnitQuantity != null)
        'reference_unit_quantity': referenceUnitQuantity,
      if (referenceUnit != null) 'reference_unit': referenceUnit,
      if (referenceUnitEquivalentQuantity != null)
        'reference_unit_equivalent_quantity': referenceUnitEquivalentQuantity,
      if (referenceUnitEquivalentUnit != null)
        'reference_unit_equivalent_unit': referenceUnitEquivalentUnit,
      if (referenceUnitWeightGrams != null)
        'reference_unit_weight_grams': referenceUnitWeightGrams,
      if (source != null) 'source': source,
      if (accentHex != null) 'accent_hex': accentHex,
      if (barcode != null) 'barcode': barcode,
      if (brand != null) 'brand': brand,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (sodium != null) 'sodium': sodium,
      if (sugar != null) 'sugar': sugar,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PantryItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? quantityLabel,
    Value<double>? referenceUnitQuantity,
    Value<String>? referenceUnit,
    Value<double?>? referenceUnitEquivalentQuantity,
    Value<String?>? referenceUnitEquivalentUnit,
    Value<double?>? referenceUnitWeightGrams,
    Value<String>? source,
    Value<int>? accentHex,
    Value<String?>? barcode,
    Value<String?>? brand,
    Value<int>? calories,
    Value<int>? protein,
    Value<int>? carbs,
    Value<int>? fat,
    Value<int>? fiber,
    Value<int>? sodium,
    Value<int>? sugar,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PantryItemsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      quantityLabel: quantityLabel ?? this.quantityLabel,
      referenceUnitQuantity:
          referenceUnitQuantity ?? this.referenceUnitQuantity,
      referenceUnit: referenceUnit ?? this.referenceUnit,
      referenceUnitEquivalentQuantity:
          referenceUnitEquivalentQuantity ??
          this.referenceUnitEquivalentQuantity,
      referenceUnitEquivalentUnit:
          referenceUnitEquivalentUnit ?? this.referenceUnitEquivalentUnit,
      referenceUnitWeightGrams:
          referenceUnitWeightGrams ?? this.referenceUnitWeightGrams,
      source: source ?? this.source,
      accentHex: accentHex ?? this.accentHex,
      barcode: barcode ?? this.barcode,
      brand: brand ?? this.brand,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      sugar: sugar ?? this.sugar,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (quantityLabel.present) {
      map['quantity_label'] = Variable<String>(quantityLabel.value);
    }
    if (referenceUnitQuantity.present) {
      map['reference_unit_quantity'] = Variable<double>(
        referenceUnitQuantity.value,
      );
    }
    if (referenceUnit.present) {
      map['reference_unit'] = Variable<String>(referenceUnit.value);
    }
    if (referenceUnitEquivalentQuantity.present) {
      map['reference_unit_equivalent_quantity'] = Variable<double>(
        referenceUnitEquivalentQuantity.value,
      );
    }
    if (referenceUnitEquivalentUnit.present) {
      map['reference_unit_equivalent_unit'] = Variable<String>(
        referenceUnitEquivalentUnit.value,
      );
    }
    if (referenceUnitWeightGrams.present) {
      map['reference_unit_weight_grams'] = Variable<double>(
        referenceUnitWeightGrams.value,
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (accentHex.present) {
      map['accent_hex'] = Variable<int>(accentHex.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<int>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<int>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<int>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<int>(fiber.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<int>(sodium.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<int>(sugar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PantryItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('quantityLabel: $quantityLabel, ')
          ..write('referenceUnitQuantity: $referenceUnitQuantity, ')
          ..write('referenceUnit: $referenceUnit, ')
          ..write(
            'referenceUnitEquivalentQuantity: $referenceUnitEquivalentQuantity, ',
          )
          ..write('referenceUnitEquivalentUnit: $referenceUnitEquivalentUnit, ')
          ..write('referenceUnitWeightGrams: $referenceUnitWeightGrams, ')
          ..write('source: $source, ')
          ..write('accentHex: $accentHex, ')
          ..write('barcode: $barcode, ')
          ..write('brand: $brand, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('sugar: $sugar, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GrocerySectionsTableTable extends GrocerySectionsTable
    with TableInfo<$GrocerySectionsTableTable, GrocerySectionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrocerySectionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grocery_sections_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrocerySectionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrocerySectionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrocerySectionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $GrocerySectionsTableTable createAlias(String alias) {
    return $GrocerySectionsTableTable(attachedDatabase, alias);
  }
}

class GrocerySectionsTableData extends DataClass
    implements Insertable<GrocerySectionsTableData> {
  final String id;
  final String title;
  final int position;
  const GrocerySectionsTableData({
    required this.id,
    required this.title,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['position'] = Variable<int>(position);
    return map;
  }

  GrocerySectionsTableCompanion toCompanion(bool nullToAbsent) {
    return GrocerySectionsTableCompanion(
      id: Value(id),
      title: Value(title),
      position: Value(position),
    );
  }

  factory GrocerySectionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrocerySectionsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'position': serializer.toJson<int>(position),
    };
  }

  GrocerySectionsTableData copyWith({
    String? id,
    String? title,
    int? position,
  }) => GrocerySectionsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    position: position ?? this.position,
  );
  GrocerySectionsTableData copyWithCompanion(
    GrocerySectionsTableCompanion data,
  ) {
    return GrocerySectionsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrocerySectionsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrocerySectionsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.position == this.position);
}

class GrocerySectionsTableCompanion
    extends UpdateCompanion<GrocerySectionsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> position;
  final Value<int> rowid;
  const GrocerySectionsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrocerySectionsTableCompanion.insert({
    required String id,
    required String title,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       position = Value(position);
  static Insertable<GrocerySectionsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrocerySectionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return GrocerySectionsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrocerySectionsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroceryItemsTableTable extends GroceryItemsTable
    with TableInfo<$GroceryItemsTableTable, GroceryItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroceryItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grocery_sections_table (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCheckedMeta = const VerificationMeta(
    'isChecked',
  );
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
    'is_checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sectionId,
    label,
    position,
    isChecked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grocery_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GroceryItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('is_checked')) {
      context.handle(
        _isCheckedMeta,
        isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroceryItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroceryItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      isChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_checked'],
      )!,
    );
  }

  @override
  $GroceryItemsTableTable createAlias(String alias) {
    return $GroceryItemsTableTable(attachedDatabase, alias);
  }
}

class GroceryItemsTableData extends DataClass
    implements Insertable<GroceryItemsTableData> {
  final int id;
  final String sectionId;
  final String label;
  final int position;
  final bool isChecked;
  const GroceryItemsTableData({
    required this.id,
    required this.sectionId,
    required this.label,
    required this.position,
    required this.isChecked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['section_id'] = Variable<String>(sectionId);
    map['label'] = Variable<String>(label);
    map['position'] = Variable<int>(position);
    map['is_checked'] = Variable<bool>(isChecked);
    return map;
  }

  GroceryItemsTableCompanion toCompanion(bool nullToAbsent) {
    return GroceryItemsTableCompanion(
      id: Value(id),
      sectionId: Value(sectionId),
      label: Value(label),
      position: Value(position),
      isChecked: Value(isChecked),
    );
  }

  factory GroceryItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroceryItemsTableData(
      id: serializer.fromJson<int>(json['id']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      label: serializer.fromJson<String>(json['label']),
      position: serializer.fromJson<int>(json['position']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sectionId': serializer.toJson<String>(sectionId),
      'label': serializer.toJson<String>(label),
      'position': serializer.toJson<int>(position),
      'isChecked': serializer.toJson<bool>(isChecked),
    };
  }

  GroceryItemsTableData copyWith({
    int? id,
    String? sectionId,
    String? label,
    int? position,
    bool? isChecked,
  }) => GroceryItemsTableData(
    id: id ?? this.id,
    sectionId: sectionId ?? this.sectionId,
    label: label ?? this.label,
    position: position ?? this.position,
    isChecked: isChecked ?? this.isChecked,
  );
  GroceryItemsTableData copyWithCompanion(GroceryItemsTableCompanion data) {
    return GroceryItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      label: data.label.present ? data.label.value : this.label,
      position: data.position.present ? data.position.value : this.position,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroceryItemsTableData(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('label: $label, ')
          ..write('position: $position, ')
          ..write('isChecked: $isChecked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sectionId, label, position, isChecked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroceryItemsTableData &&
          other.id == this.id &&
          other.sectionId == this.sectionId &&
          other.label == this.label &&
          other.position == this.position &&
          other.isChecked == this.isChecked);
}

class GroceryItemsTableCompanion
    extends UpdateCompanion<GroceryItemsTableData> {
  final Value<int> id;
  final Value<String> sectionId;
  final Value<String> label;
  final Value<int> position;
  final Value<bool> isChecked;
  const GroceryItemsTableCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.label = const Value.absent(),
    this.position = const Value.absent(),
    this.isChecked = const Value.absent(),
  });
  GroceryItemsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sectionId,
    required String label,
    required int position,
    this.isChecked = const Value.absent(),
  }) : sectionId = Value(sectionId),
       label = Value(label),
       position = Value(position);
  static Insertable<GroceryItemsTableData> custom({
    Expression<int>? id,
    Expression<String>? sectionId,
    Expression<String>? label,
    Expression<int>? position,
    Expression<bool>? isChecked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (label != null) 'label': label,
      if (position != null) 'position': position,
      if (isChecked != null) 'is_checked': isChecked,
    });
  }

  GroceryItemsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? sectionId,
    Value<String>? label,
    Value<int>? position,
    Value<bool>? isChecked,
  }) {
    return GroceryItemsTableCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      label: label ?? this.label,
      position: position ?? this.position,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroceryItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('label: $label, ')
          ..write('position: $position, ')
          ..write('isChecked: $isChecked')
          ..write(')'))
        .toString();
  }
}

class $SavedMealsTableTable extends SavedMealsTable
    with TableInfo<$SavedMealsTableTable, SavedMealsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedMealsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<int> protein = GeneratedColumn<int>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<int> carbs = GeneratedColumn<int>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<int> fat = GeneratedColumn<int>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<int> fiber = GeneratedColumn<int>(
    'fiber',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<int> sodium = GeneratedColumn<int>(
    'sodium',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<int> sugar = GeneratedColumn<int>(
    'sugar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sodium,
    sugar,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_meals_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedMealsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    } else if (isInserting) {
      context.missing(_fiberMeta);
    }
    if (data.containsKey('sodium')) {
      context.handle(
        _sodiumMeta,
        sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta),
      );
    } else if (isInserting) {
      context.missing(_sodiumMeta);
    }
    if (data.containsKey('sugar')) {
      context.handle(
        _sugarMeta,
        sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta),
      );
    } else if (isInserting) {
      context.missing(_sugarMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedMealsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedMealsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carbs'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fat'],
      )!,
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fiber'],
      )!,
      sodium: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sodium'],
      )!,
      sugar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sugar'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavedMealsTableTable createAlias(String alias) {
    return $SavedMealsTableTable(attachedDatabase, alias);
  }
}

class SavedMealsTableData extends DataClass
    implements Insertable<SavedMealsTableData> {
  final String id;
  final String title;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int sodium;
  final int sugar;
  final DateTime createdAt;
  const SavedMealsTableData({
    required this.id,
    required this.title,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sodium,
    required this.sugar,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['calories'] = Variable<int>(calories);
    map['protein'] = Variable<int>(protein);
    map['carbs'] = Variable<int>(carbs);
    map['fat'] = Variable<int>(fat);
    map['fiber'] = Variable<int>(fiber);
    map['sodium'] = Variable<int>(sodium);
    map['sugar'] = Variable<int>(sugar);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavedMealsTableCompanion toCompanion(bool nullToAbsent) {
    return SavedMealsTableCompanion(
      id: Value(id),
      title: Value(title),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      fiber: Value(fiber),
      sodium: Value(sodium),
      sugar: Value(sugar),
      createdAt: Value(createdAt),
    );
  }

  factory SavedMealsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedMealsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<int>(json['protein']),
      carbs: serializer.fromJson<int>(json['carbs']),
      fat: serializer.fromJson<int>(json['fat']),
      fiber: serializer.fromJson<int>(json['fiber']),
      sodium: serializer.fromJson<int>(json['sodium']),
      sugar: serializer.fromJson<int>(json['sugar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<int>(protein),
      'carbs': serializer.toJson<int>(carbs),
      'fat': serializer.toJson<int>(fat),
      'fiber': serializer.toJson<int>(fiber),
      'sodium': serializer.toJson<int>(sodium),
      'sugar': serializer.toJson<int>(sugar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavedMealsTableData copyWith({
    String? id,
    String? title,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
    int? sodium,
    int? sugar,
    DateTime? createdAt,
  }) => SavedMealsTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    fiber: fiber ?? this.fiber,
    sodium: sodium ?? this.sodium,
    sugar: sugar ?? this.sugar,
    createdAt: createdAt ?? this.createdAt,
  );
  SavedMealsTableData copyWithCompanion(SavedMealsTableCompanion data) {
    return SavedMealsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('sugar: $sugar, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sodium,
    sugar,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedMealsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.sodium == this.sodium &&
          other.sugar == this.sugar &&
          other.createdAt == this.createdAt);
}

class SavedMealsTableCompanion extends UpdateCompanion<SavedMealsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> calories;
  final Value<int> protein;
  final Value<int> carbs;
  final Value<int> fat;
  final Value<int> fiber;
  final Value<int> sodium;
  final Value<int> sugar;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavedMealsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.sugar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedMealsTableCompanion.insert({
    required String id,
    required String title,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required int fiber,
    required int sodium,
    required int sugar,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       calories = Value(calories),
       protein = Value(protein),
       carbs = Value(carbs),
       fat = Value(fat),
       fiber = Value(fiber),
       sodium = Value(sodium),
       sugar = Value(sugar),
       createdAt = Value(createdAt);
  static Insertable<SavedMealsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? calories,
    Expression<int>? protein,
    Expression<int>? carbs,
    Expression<int>? fat,
    Expression<int>? fiber,
    Expression<int>? sodium,
    Expression<int>? sugar,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (sodium != null) 'sodium': sodium,
      if (sugar != null) 'sugar': sugar,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedMealsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? calories,
    Value<int>? protein,
    Value<int>? carbs,
    Value<int>? fat,
    Value<int>? fiber,
    Value<int>? sodium,
    Value<int>? sugar,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SavedMealsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      sugar: sugar ?? this.sugar,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<int>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<int>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<int>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<int>(fiber.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<int>(sodium.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<int>(sugar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('sugar: $sugar, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedMealAdjustmentsTable extends SavedMealAdjustments
    with TableInfo<$SavedMealAdjustmentsTable, SavedMealAdjustment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedMealAdjustmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<String> mealId = GeneratedColumn<String>(
    'meal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saved_meals_table (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, mealId, label, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_meal_adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedMealAdjustment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_id')) {
      context.handle(
        _mealIdMeta,
        mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedMealAdjustment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedMealAdjustment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $SavedMealAdjustmentsTable createAlias(String alias) {
    return $SavedMealAdjustmentsTable(attachedDatabase, alias);
  }
}

class SavedMealAdjustment extends DataClass
    implements Insertable<SavedMealAdjustment> {
  final int id;
  final String mealId;
  final String label;
  final int position;
  const SavedMealAdjustment({
    required this.id,
    required this.mealId,
    required this.label,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_id'] = Variable<String>(mealId);
    map['label'] = Variable<String>(label);
    map['position'] = Variable<int>(position);
    return map;
  }

  SavedMealAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return SavedMealAdjustmentsCompanion(
      id: Value(id),
      mealId: Value(mealId),
      label: Value(label),
      position: Value(position),
    );
  }

  factory SavedMealAdjustment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedMealAdjustment(
      id: serializer.fromJson<int>(json['id']),
      mealId: serializer.fromJson<String>(json['mealId']),
      label: serializer.fromJson<String>(json['label']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealId': serializer.toJson<String>(mealId),
      'label': serializer.toJson<String>(label),
      'position': serializer.toJson<int>(position),
    };
  }

  SavedMealAdjustment copyWith({
    int? id,
    String? mealId,
    String? label,
    int? position,
  }) => SavedMealAdjustment(
    id: id ?? this.id,
    mealId: mealId ?? this.mealId,
    label: label ?? this.label,
    position: position ?? this.position,
  );
  SavedMealAdjustment copyWithCompanion(SavedMealAdjustmentsCompanion data) {
    return SavedMealAdjustment(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      label: data.label.present ? data.label.value : this.label,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealAdjustment(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('label: $label, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mealId, label, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedMealAdjustment &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.label == this.label &&
          other.position == this.position);
}

class SavedMealAdjustmentsCompanion
    extends UpdateCompanion<SavedMealAdjustment> {
  final Value<int> id;
  final Value<String> mealId;
  final Value<String> label;
  final Value<int> position;
  const SavedMealAdjustmentsCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.label = const Value.absent(),
    this.position = const Value.absent(),
  });
  SavedMealAdjustmentsCompanion.insert({
    this.id = const Value.absent(),
    required String mealId,
    required String label,
    required int position,
  }) : mealId = Value(mealId),
       label = Value(label),
       position = Value(position);
  static Insertable<SavedMealAdjustment> custom({
    Expression<int>? id,
    Expression<String>? mealId,
    Expression<String>? label,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (label != null) 'label': label,
      if (position != null) 'position': position,
    });
  }

  SavedMealAdjustmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? mealId,
    Value<String>? label,
    Value<int>? position,
  }) {
    return SavedMealAdjustmentsCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      label: label ?? this.label,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<String>(mealId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealAdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('label: $label, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $SavedMealComponentsTable extends SavedMealComponents
    with TableInfo<$SavedMealComponentsTable, SavedMealComponent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedMealComponentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<String> mealId = GeneratedColumn<String>(
    'meal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES saved_meals_table (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemMeta = const VerificationMeta('item');
  @override
  late final GeneratedColumn<String> item = GeneratedColumn<String>(
    'item',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _componentTypeMeta = const VerificationMeta(
    'componentType',
  );
  @override
  late final GeneratedColumn<String> componentType = GeneratedColumn<String>(
    'component_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('freeform'),
  );
  static const VerificationMeta _linkedPantryItemIdMeta =
      const VerificationMeta('linkedPantryItemId');
  @override
  late final GeneratedColumn<String> linkedPantryItemId =
      GeneratedColumn<String>(
        'linked_pantry_item_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _linkedRecipeIdMeta = const VerificationMeta(
    'linkedRecipeId',
  );
  @override
  late final GeneratedColumn<String> linkedRecipeId = GeneratedColumn<String>(
    'linked_recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mealId,
    position,
    quantity,
    unit,
    item,
    componentType,
    linkedPantryItemId,
    linkedRecipeId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_meal_components';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedMealComponent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('meal_id')) {
      context.handle(
        _mealIdMeta,
        mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('item')) {
      context.handle(
        _itemMeta,
        item.isAcceptableOrUnknown(data['item']!, _itemMeta),
      );
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('component_type')) {
      context.handle(
        _componentTypeMeta,
        componentType.isAcceptableOrUnknown(
          data['component_type']!,
          _componentTypeMeta,
        ),
      );
    }
    if (data.containsKey('linked_pantry_item_id')) {
      context.handle(
        _linkedPantryItemIdMeta,
        linkedPantryItemId.isAcceptableOrUnknown(
          data['linked_pantry_item_id']!,
          _linkedPantryItemIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_recipe_id')) {
      context.handle(
        _linkedRecipeIdMeta,
        linkedRecipeId.isAcceptableOrUnknown(
          data['linked_recipe_id']!,
          _linkedRecipeIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedMealComponent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedMealComponent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      item: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item'],
      )!,
      componentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}component_type'],
      )!,
      linkedPantryItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_pantry_item_id'],
      ),
      linkedRecipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_recipe_id'],
      ),
    );
  }

  @override
  $SavedMealComponentsTable createAlias(String alias) {
    return $SavedMealComponentsTable(attachedDatabase, alias);
  }
}

class SavedMealComponent extends DataClass
    implements Insertable<SavedMealComponent> {
  final int id;
  final String mealId;
  final int position;
  final String quantity;
  final String unit;
  final String item;
  final String componentType;
  final String? linkedPantryItemId;
  final String? linkedRecipeId;
  const SavedMealComponent({
    required this.id,
    required this.mealId,
    required this.position,
    required this.quantity,
    required this.unit,
    required this.item,
    required this.componentType,
    this.linkedPantryItemId,
    this.linkedRecipeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['meal_id'] = Variable<String>(mealId);
    map['position'] = Variable<int>(position);
    map['quantity'] = Variable<String>(quantity);
    map['unit'] = Variable<String>(unit);
    map['item'] = Variable<String>(item);
    map['component_type'] = Variable<String>(componentType);
    if (!nullToAbsent || linkedPantryItemId != null) {
      map['linked_pantry_item_id'] = Variable<String>(linkedPantryItemId);
    }
    if (!nullToAbsent || linkedRecipeId != null) {
      map['linked_recipe_id'] = Variable<String>(linkedRecipeId);
    }
    return map;
  }

  SavedMealComponentsCompanion toCompanion(bool nullToAbsent) {
    return SavedMealComponentsCompanion(
      id: Value(id),
      mealId: Value(mealId),
      position: Value(position),
      quantity: Value(quantity),
      unit: Value(unit),
      item: Value(item),
      componentType: Value(componentType),
      linkedPantryItemId: linkedPantryItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedPantryItemId),
      linkedRecipeId: linkedRecipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedRecipeId),
    );
  }

  factory SavedMealComponent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedMealComponent(
      id: serializer.fromJson<int>(json['id']),
      mealId: serializer.fromJson<String>(json['mealId']),
      position: serializer.fromJson<int>(json['position']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      item: serializer.fromJson<String>(json['item']),
      componentType: serializer.fromJson<String>(json['componentType']),
      linkedPantryItemId: serializer.fromJson<String?>(
        json['linkedPantryItemId'],
      ),
      linkedRecipeId: serializer.fromJson<String?>(json['linkedRecipeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mealId': serializer.toJson<String>(mealId),
      'position': serializer.toJson<int>(position),
      'quantity': serializer.toJson<String>(quantity),
      'unit': serializer.toJson<String>(unit),
      'item': serializer.toJson<String>(item),
      'componentType': serializer.toJson<String>(componentType),
      'linkedPantryItemId': serializer.toJson<String?>(linkedPantryItemId),
      'linkedRecipeId': serializer.toJson<String?>(linkedRecipeId),
    };
  }

  SavedMealComponent copyWith({
    int? id,
    String? mealId,
    int? position,
    String? quantity,
    String? unit,
    String? item,
    String? componentType,
    Value<String?> linkedPantryItemId = const Value.absent(),
    Value<String?> linkedRecipeId = const Value.absent(),
  }) => SavedMealComponent(
    id: id ?? this.id,
    mealId: mealId ?? this.mealId,
    position: position ?? this.position,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    item: item ?? this.item,
    componentType: componentType ?? this.componentType,
    linkedPantryItemId: linkedPantryItemId.present
        ? linkedPantryItemId.value
        : this.linkedPantryItemId,
    linkedRecipeId: linkedRecipeId.present
        ? linkedRecipeId.value
        : this.linkedRecipeId,
  );
  SavedMealComponent copyWithCompanion(SavedMealComponentsCompanion data) {
    return SavedMealComponent(
      id: data.id.present ? data.id.value : this.id,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      position: data.position.present ? data.position.value : this.position,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      item: data.item.present ? data.item.value : this.item,
      componentType: data.componentType.present
          ? data.componentType.value
          : this.componentType,
      linkedPantryItemId: data.linkedPantryItemId.present
          ? data.linkedPantryItemId.value
          : this.linkedPantryItemId,
      linkedRecipeId: data.linkedRecipeId.present
          ? data.linkedRecipeId.value
          : this.linkedRecipeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealComponent(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('position: $position, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('item: $item, ')
          ..write('componentType: $componentType, ')
          ..write('linkedPantryItemId: $linkedPantryItemId, ')
          ..write('linkedRecipeId: $linkedRecipeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mealId,
    position,
    quantity,
    unit,
    item,
    componentType,
    linkedPantryItemId,
    linkedRecipeId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedMealComponent &&
          other.id == this.id &&
          other.mealId == this.mealId &&
          other.position == this.position &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.item == this.item &&
          other.componentType == this.componentType &&
          other.linkedPantryItemId == this.linkedPantryItemId &&
          other.linkedRecipeId == this.linkedRecipeId);
}

class SavedMealComponentsCompanion extends UpdateCompanion<SavedMealComponent> {
  final Value<int> id;
  final Value<String> mealId;
  final Value<int> position;
  final Value<String> quantity;
  final Value<String> unit;
  final Value<String> item;
  final Value<String> componentType;
  final Value<String?> linkedPantryItemId;
  final Value<String?> linkedRecipeId;
  const SavedMealComponentsCompanion({
    this.id = const Value.absent(),
    this.mealId = const Value.absent(),
    this.position = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.item = const Value.absent(),
    this.componentType = const Value.absent(),
    this.linkedPantryItemId = const Value.absent(),
    this.linkedRecipeId = const Value.absent(),
  });
  SavedMealComponentsCompanion.insert({
    this.id = const Value.absent(),
    required String mealId,
    required int position,
    required String quantity,
    required String unit,
    required String item,
    this.componentType = const Value.absent(),
    this.linkedPantryItemId = const Value.absent(),
    this.linkedRecipeId = const Value.absent(),
  }) : mealId = Value(mealId),
       position = Value(position),
       quantity = Value(quantity),
       unit = Value(unit),
       item = Value(item);
  static Insertable<SavedMealComponent> custom({
    Expression<int>? id,
    Expression<String>? mealId,
    Expression<int>? position,
    Expression<String>? quantity,
    Expression<String>? unit,
    Expression<String>? item,
    Expression<String>? componentType,
    Expression<String>? linkedPantryItemId,
    Expression<String>? linkedRecipeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealId != null) 'meal_id': mealId,
      if (position != null) 'position': position,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (item != null) 'item': item,
      if (componentType != null) 'component_type': componentType,
      if (linkedPantryItemId != null)
        'linked_pantry_item_id': linkedPantryItemId,
      if (linkedRecipeId != null) 'linked_recipe_id': linkedRecipeId,
    });
  }

  SavedMealComponentsCompanion copyWith({
    Value<int>? id,
    Value<String>? mealId,
    Value<int>? position,
    Value<String>? quantity,
    Value<String>? unit,
    Value<String>? item,
    Value<String>? componentType,
    Value<String?>? linkedPantryItemId,
    Value<String?>? linkedRecipeId,
  }) {
    return SavedMealComponentsCompanion(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      position: position ?? this.position,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      item: item ?? this.item,
      componentType: componentType ?? this.componentType,
      linkedPantryItemId: linkedPantryItemId ?? this.linkedPantryItemId,
      linkedRecipeId: linkedRecipeId ?? this.linkedRecipeId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<String>(mealId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (componentType.present) {
      map['component_type'] = Variable<String>(componentType.value);
    }
    if (linkedPantryItemId.present) {
      map['linked_pantry_item_id'] = Variable<String>(linkedPantryItemId.value);
    }
    if (linkedRecipeId.present) {
      map['linked_recipe_id'] = Variable<String>(linkedRecipeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedMealComponentsCompanion(')
          ..write('id: $id, ')
          ..write('mealId: $mealId, ')
          ..write('position: $position, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('item: $item, ')
          ..write('componentType: $componentType, ')
          ..write('linkedPantryItemId: $linkedPantryItemId, ')
          ..write('linkedRecipeId: $linkedRecipeId')
          ..write(')'))
        .toString();
  }
}

class $FoodLogEntriesTableTable extends FoodLogEntriesTable
    with TableInfo<$FoodLogEntriesTableTable, FoodLogEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodLogEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  @override
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealSlotMeta = const VerificationMeta(
    'mealSlot',
  );
  @override
  late final GeneratedColumn<String> mealSlot = GeneratedColumn<String>(
    'meal_slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<int> protein = GeneratedColumn<int>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<int> carbs = GeneratedColumn<int>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<int> fat = GeneratedColumn<int>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<int> fiber = GeneratedColumn<int>(
    'fiber',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sodiumMeta = const VerificationMeta('sodium');
  @override
  late final GeneratedColumn<int> sodium = GeneratedColumn<int>(
    'sodium',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<int> sugar = GeneratedColumn<int>(
    'sugar',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryDate,
    mealSlot,
    sourceType,
    sourceId,
    title,
    quantity,
    unit,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sodium,
    sugar,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_log_entries_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodLogEntriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_entryDateMeta);
    }
    if (data.containsKey('meal_slot')) {
      context.handle(
        _mealSlotMeta,
        mealSlot.isAcceptableOrUnknown(data['meal_slot']!, _mealSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_mealSlotMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    } else if (isInserting) {
      context.missing(_fiberMeta);
    }
    if (data.containsKey('sodium')) {
      context.handle(
        _sodiumMeta,
        sodium.isAcceptableOrUnknown(data['sodium']!, _sodiumMeta),
      );
    } else if (isInserting) {
      context.missing(_sodiumMeta);
    }
    if (data.containsKey('sugar')) {
      context.handle(
        _sugarMeta,
        sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta),
      );
    } else if (isInserting) {
      context.missing(_sugarMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodLogEntriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodLogEntriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      )!,
      mealSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_slot'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carbs'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fat'],
      )!,
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fiber'],
      )!,
      sodium: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sodium'],
      )!,
      sugar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sugar'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoodLogEntriesTableTable createAlias(String alias) {
    return $FoodLogEntriesTableTable(attachedDatabase, alias);
  }
}

class FoodLogEntriesTableData extends DataClass
    implements Insertable<FoodLogEntriesTableData> {
  final String id;
  final String entryDate;
  final String mealSlot;
  final String sourceType;
  final String sourceId;
  final String title;
  final String quantity;
  final String unit;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int sodium;
  final int sugar;
  final DateTime createdAt;
  const FoodLogEntriesTableData({
    required this.id,
    required this.entryDate,
    required this.mealSlot,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sodium,
    required this.sugar,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entry_date'] = Variable<String>(entryDate);
    map['meal_slot'] = Variable<String>(mealSlot);
    map['source_type'] = Variable<String>(sourceType);
    map['source_id'] = Variable<String>(sourceId);
    map['title'] = Variable<String>(title);
    map['quantity'] = Variable<String>(quantity);
    map['unit'] = Variable<String>(unit);
    map['calories'] = Variable<int>(calories);
    map['protein'] = Variable<int>(protein);
    map['carbs'] = Variable<int>(carbs);
    map['fat'] = Variable<int>(fat);
    map['fiber'] = Variable<int>(fiber);
    map['sodium'] = Variable<int>(sodium);
    map['sugar'] = Variable<int>(sugar);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoodLogEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return FoodLogEntriesTableCompanion(
      id: Value(id),
      entryDate: Value(entryDate),
      mealSlot: Value(mealSlot),
      sourceType: Value(sourceType),
      sourceId: Value(sourceId),
      title: Value(title),
      quantity: Value(quantity),
      unit: Value(unit),
      calories: Value(calories),
      protein: Value(protein),
      carbs: Value(carbs),
      fat: Value(fat),
      fiber: Value(fiber),
      sodium: Value(sodium),
      sugar: Value(sugar),
      createdAt: Value(createdAt),
    );
  }

  factory FoodLogEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodLogEntriesTableData(
      id: serializer.fromJson<String>(json['id']),
      entryDate: serializer.fromJson<String>(json['entryDate']),
      mealSlot: serializer.fromJson<String>(json['mealSlot']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      quantity: serializer.fromJson<String>(json['quantity']),
      unit: serializer.fromJson<String>(json['unit']),
      calories: serializer.fromJson<int>(json['calories']),
      protein: serializer.fromJson<int>(json['protein']),
      carbs: serializer.fromJson<int>(json['carbs']),
      fat: serializer.fromJson<int>(json['fat']),
      fiber: serializer.fromJson<int>(json['fiber']),
      sodium: serializer.fromJson<int>(json['sodium']),
      sugar: serializer.fromJson<int>(json['sugar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryDate': serializer.toJson<String>(entryDate),
      'mealSlot': serializer.toJson<String>(mealSlot),
      'sourceType': serializer.toJson<String>(sourceType),
      'sourceId': serializer.toJson<String>(sourceId),
      'title': serializer.toJson<String>(title),
      'quantity': serializer.toJson<String>(quantity),
      'unit': serializer.toJson<String>(unit),
      'calories': serializer.toJson<int>(calories),
      'protein': serializer.toJson<int>(protein),
      'carbs': serializer.toJson<int>(carbs),
      'fat': serializer.toJson<int>(fat),
      'fiber': serializer.toJson<int>(fiber),
      'sodium': serializer.toJson<int>(sodium),
      'sugar': serializer.toJson<int>(sugar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FoodLogEntriesTableData copyWith({
    String? id,
    String? entryDate,
    String? mealSlot,
    String? sourceType,
    String? sourceId,
    String? title,
    String? quantity,
    String? unit,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
    int? sodium,
    int? sugar,
    DateTime? createdAt,
  }) => FoodLogEntriesTableData(
    id: id ?? this.id,
    entryDate: entryDate ?? this.entryDate,
    mealSlot: mealSlot ?? this.mealSlot,
    sourceType: sourceType ?? this.sourceType,
    sourceId: sourceId ?? this.sourceId,
    title: title ?? this.title,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    calories: calories ?? this.calories,
    protein: protein ?? this.protein,
    carbs: carbs ?? this.carbs,
    fat: fat ?? this.fat,
    fiber: fiber ?? this.fiber,
    sodium: sodium ?? this.sodium,
    sugar: sugar ?? this.sugar,
    createdAt: createdAt ?? this.createdAt,
  );
  FoodLogEntriesTableData copyWithCompanion(FoodLogEntriesTableCompanion data) {
    return FoodLogEntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      mealSlot: data.mealSlot.present ? data.mealSlot.value : this.mealSlot,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      title: data.title.present ? data.title.value : this.title,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      sodium: data.sodium.present ? data.sodium.value : this.sodium,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogEntriesTableData(')
          ..write('id: $id, ')
          ..write('entryDate: $entryDate, ')
          ..write('mealSlot: $mealSlot, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('sugar: $sugar, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryDate,
    mealSlot,
    sourceType,
    sourceId,
    title,
    quantity,
    unit,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sodium,
    sugar,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodLogEntriesTableData &&
          other.id == this.id &&
          other.entryDate == this.entryDate &&
          other.mealSlot == this.mealSlot &&
          other.sourceType == this.sourceType &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.sodium == this.sodium &&
          other.sugar == this.sugar &&
          other.createdAt == this.createdAt);
}

class FoodLogEntriesTableCompanion
    extends UpdateCompanion<FoodLogEntriesTableData> {
  final Value<String> id;
  final Value<String> entryDate;
  final Value<String> mealSlot;
  final Value<String> sourceType;
  final Value<String> sourceId;
  final Value<String> title;
  final Value<String> quantity;
  final Value<String> unit;
  final Value<int> calories;
  final Value<int> protein;
  final Value<int> carbs;
  final Value<int> fat;
  final Value<int> fiber;
  final Value<int> sodium;
  final Value<int> sugar;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FoodLogEntriesTableCompanion({
    this.id = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.mealSlot = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.sodium = const Value.absent(),
    this.sugar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodLogEntriesTableCompanion.insert({
    required String id,
    required String entryDate,
    required String mealSlot,
    required String sourceType,
    required String sourceId,
    required String title,
    required String quantity,
    required String unit,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required int fiber,
    required int sodium,
    required int sugar,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entryDate = Value(entryDate),
       mealSlot = Value(mealSlot),
       sourceType = Value(sourceType),
       sourceId = Value(sourceId),
       title = Value(title),
       quantity = Value(quantity),
       unit = Value(unit),
       calories = Value(calories),
       protein = Value(protein),
       carbs = Value(carbs),
       fat = Value(fat),
       fiber = Value(fiber),
       sodium = Value(sodium),
       sugar = Value(sugar),
       createdAt = Value(createdAt);
  static Insertable<FoodLogEntriesTableData> custom({
    Expression<String>? id,
    Expression<String>? entryDate,
    Expression<String>? mealSlot,
    Expression<String>? sourceType,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<String>? quantity,
    Expression<String>? unit,
    Expression<int>? calories,
    Expression<int>? protein,
    Expression<int>? carbs,
    Expression<int>? fat,
    Expression<int>? fiber,
    Expression<int>? sodium,
    Expression<int>? sugar,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryDate != null) 'entry_date': entryDate,
      if (mealSlot != null) 'meal_slot': mealSlot,
      if (sourceType != null) 'source_type': sourceType,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (sodium != null) 'sodium': sodium,
      if (sugar != null) 'sugar': sugar,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodLogEntriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? entryDate,
    Value<String>? mealSlot,
    Value<String>? sourceType,
    Value<String>? sourceId,
    Value<String>? title,
    Value<String>? quantity,
    Value<String>? unit,
    Value<int>? calories,
    Value<int>? protein,
    Value<int>? carbs,
    Value<int>? fat,
    Value<int>? fiber,
    Value<int>? sodium,
    Value<int>? sugar,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FoodLogEntriesTableCompanion(
      id: id ?? this.id,
      entryDate: entryDate ?? this.entryDate,
      mealSlot: mealSlot ?? this.mealSlot,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      sugar: sugar ?? this.sugar,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (mealSlot.present) {
      map['meal_slot'] = Variable<String>(mealSlot.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<int>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<int>(carbs.value);
    }
    if (fat.present) {
      map['fat'] = Variable<int>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<int>(fiber.value);
    }
    if (sodium.present) {
      map['sodium'] = Variable<int>(sodium.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<int>(sugar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodLogEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('entryDate: $entryDate, ')
          ..write('mealSlot: $mealSlot, ')
          ..write('sourceType: $sourceType, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('sodium: $sodium, ')
          ..write('sugar: $sugar, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTableTable extends AppSettingsTable
    with TableInfo<$AppSettingsTableTable, AppSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTableTable createAlias(String alias) {
    return $AppSettingsTableTable(attachedDatabase, alias);
  }
}

class AppSettingsTableData extends DataClass
    implements Insertable<AppSettingsTableData> {
  final String key;
  final String? value;
  final DateTime updatedAt;
  const AppSettingsTableData({
    required this.key,
    this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsTableCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsTableData copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
    DateTime? updatedAt,
  }) => AppSettingsTableData(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsTableData copyWithCompanion(AppSettingsTableCompanion data) {
    return AppSettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsTableData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsTableCompanion extends UpdateCompanion<AppSettingsTableData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsTableCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeTypeMeta = const VerificationMeta(
    'changeType',
  );
  @override
  late final GeneratedColumn<String> changeType = GeneratedColumn<String>(
    'change_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayLabelMeta = const VerificationMeta(
    'displayLabel',
  );
  @override
  late final GeneratedColumn<String> displayLabel = GeneratedColumn<String>(
    'display_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    changeType,
    displayLabel,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('change_type')) {
      context.handle(
        _changeTypeMeta,
        changeType.isAcceptableOrUnknown(data['change_type']!, _changeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_changeTypeMeta);
    }
    if (data.containsKey('display_label')) {
      context.handle(
        _displayLabelMeta,
        displayLabel.isAcceptableOrUnknown(
          data['display_label']!,
          _displayLabelMeta,
        ),
      );
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  SyncQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueTableData(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      changeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_type'],
      )!,
      displayLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_label'],
      ),
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueTableData extends DataClass
    implements Insertable<SyncQueueTableData> {
  final String entityType;
  final String entityId;
  final String changeType;
  final String? displayLabel;
  final DateTime changedAt;
  const SyncQueueTableData({
    required this.entityType,
    required this.entityId,
    required this.changeType,
    this.displayLabel,
    required this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['change_type'] = Variable<String>(changeType);
    if (!nullToAbsent || displayLabel != null) {
      map['display_label'] = Variable<String>(displayLabel);
    }
    map['changed_at'] = Variable<DateTime>(changedAt);
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      changeType: Value(changeType),
      displayLabel: displayLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(displayLabel),
      changedAt: Value(changedAt),
    );
  }

  factory SyncQueueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueTableData(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      changeType: serializer.fromJson<String>(json['changeType']),
      displayLabel: serializer.fromJson<String?>(json['displayLabel']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'changeType': serializer.toJson<String>(changeType),
      'displayLabel': serializer.toJson<String?>(displayLabel),
      'changedAt': serializer.toJson<DateTime>(changedAt),
    };
  }

  SyncQueueTableData copyWith({
    String? entityType,
    String? entityId,
    String? changeType,
    Value<String?> displayLabel = const Value.absent(),
    DateTime? changedAt,
  }) => SyncQueueTableData(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    changeType: changeType ?? this.changeType,
    displayLabel: displayLabel.present ? displayLabel.value : this.displayLabel,
    changedAt: changedAt ?? this.changedAt,
  );
  SyncQueueTableData copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueTableData(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      changeType: data.changeType.present
          ? data.changeType.value
          : this.changeType,
      displayLabel: data.displayLabel.present
          ? data.displayLabel.value
          : this.displayLabel,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableData(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('changeType: $changeType, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entityType, entityId, changeType, displayLabel, changedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueTableData &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.changeType == this.changeType &&
          other.displayLabel == this.displayLabel &&
          other.changedAt == this.changedAt);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueTableData> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> changeType;
  final Value<String?> displayLabel;
  final Value<DateTime> changedAt;
  final Value<int> rowid;
  const SyncQueueTableCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.changeType = const Value.absent(),
    this.displayLabel = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    required String entityType,
    required String entityId,
    required String changeType,
    this.displayLabel = const Value.absent(),
    required DateTime changedAt,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       changeType = Value(changeType),
       changedAt = Value(changedAt);
  static Insertable<SyncQueueTableData> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? changeType,
    Expression<String>? displayLabel,
    Expression<DateTime>? changedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (changeType != null) 'change_type': changeType,
      if (displayLabel != null) 'display_label': displayLabel,
      if (changedAt != null) 'changed_at': changedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueTableCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? changeType,
    Value<String?>? displayLabel,
    Value<DateTime>? changedAt,
    Value<int>? rowid,
  }) {
    return SyncQueueTableCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      changeType: changeType ?? this.changeType,
      displayLabel: displayLabel ?? this.displayLabel,
      changedAt: changedAt ?? this.changedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(changeType.value);
    }
    if (displayLabel.present) {
      map['display_label'] = Variable<String>(displayLabel.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('changeType: $changeType, ')
          ..write('displayLabel: $displayLabel, ')
          ..write('changedAt: $changedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyGoalsTableTable extends DailyGoalsTable
    with TableInfo<$DailyGoalsTableTable, DailyGoalsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyGoalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _consumedMeta = const VerificationMeta(
    'consumed',
  );
  @override
  late final GeneratedColumn<int> consumed = GeneratedColumn<int>(
    'consumed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, consumed, target];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_goals_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyGoalsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('consumed')) {
      context.handle(
        _consumedMeta,
        consumed.isAcceptableOrUnknown(data['consumed']!, _consumedMeta),
      );
    } else if (isInserting) {
      context.missing(_consumedMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyGoalsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyGoalsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      consumed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consumed'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      )!,
    );
  }

  @override
  $DailyGoalsTableTable createAlias(String alias) {
    return $DailyGoalsTableTable(attachedDatabase, alias);
  }
}

class DailyGoalsTableData extends DataClass
    implements Insertable<DailyGoalsTableData> {
  final int id;
  final String label;
  final int consumed;
  final int target;
  const DailyGoalsTableData({
    required this.id,
    required this.label,
    required this.consumed,
    required this.target,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['consumed'] = Variable<int>(consumed);
    map['target'] = Variable<int>(target);
    return map;
  }

  DailyGoalsTableCompanion toCompanion(bool nullToAbsent) {
    return DailyGoalsTableCompanion(
      id: Value(id),
      label: Value(label),
      consumed: Value(consumed),
      target: Value(target),
    );
  }

  factory DailyGoalsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyGoalsTableData(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      consumed: serializer.fromJson<int>(json['consumed']),
      target: serializer.fromJson<int>(json['target']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'consumed': serializer.toJson<int>(consumed),
      'target': serializer.toJson<int>(target),
    };
  }

  DailyGoalsTableData copyWith({
    int? id,
    String? label,
    int? consumed,
    int? target,
  }) => DailyGoalsTableData(
    id: id ?? this.id,
    label: label ?? this.label,
    consumed: consumed ?? this.consumed,
    target: target ?? this.target,
  );
  DailyGoalsTableData copyWithCompanion(DailyGoalsTableCompanion data) {
    return DailyGoalsTableData(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      consumed: data.consumed.present ? data.consumed.value : this.consumed,
      target: data.target.present ? data.target.value : this.target,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalsTableData(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('consumed: $consumed, ')
          ..write('target: $target')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, consumed, target);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyGoalsTableData &&
          other.id == this.id &&
          other.label == this.label &&
          other.consumed == this.consumed &&
          other.target == this.target);
}

class DailyGoalsTableCompanion extends UpdateCompanion<DailyGoalsTableData> {
  final Value<int> id;
  final Value<String> label;
  final Value<int> consumed;
  final Value<int> target;
  const DailyGoalsTableCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.consumed = const Value.absent(),
    this.target = const Value.absent(),
  });
  DailyGoalsTableCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required int consumed,
    required int target,
  }) : label = Value(label),
       consumed = Value(consumed),
       target = Value(target);
  static Insertable<DailyGoalsTableData> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<int>? consumed,
    Expression<int>? target,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (consumed != null) 'consumed': consumed,
      if (target != null) 'target': target,
    });
  }

  DailyGoalsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<int>? consumed,
    Value<int>? target,
  }) {
    return DailyGoalsTableCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      consumed: consumed ?? this.consumed,
      target: target ?? this.target,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (consumed.present) {
      map['consumed'] = Variable<int>(consumed.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalsTableCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('consumed: $consumed, ')
          ..write('target: $target')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $RecipeTagsTable recipeTags = $RecipeTagsTable(this);
  late final $RecipeIngredientsTable recipeIngredients =
      $RecipeIngredientsTable(this);
  late final $RecipeDirectionsTable recipeDirections = $RecipeDirectionsTable(
    this,
  );
  late final $PantryItemsTableTable pantryItemsTable = $PantryItemsTableTable(
    this,
  );
  late final $GrocerySectionsTableTable grocerySectionsTable =
      $GrocerySectionsTableTable(this);
  late final $GroceryItemsTableTable groceryItemsTable =
      $GroceryItemsTableTable(this);
  late final $SavedMealsTableTable savedMealsTable = $SavedMealsTableTable(
    this,
  );
  late final $SavedMealAdjustmentsTable savedMealAdjustments =
      $SavedMealAdjustmentsTable(this);
  late final $SavedMealComponentsTable savedMealComponents =
      $SavedMealComponentsTable(this);
  late final $FoodLogEntriesTableTable foodLogEntriesTable =
      $FoodLogEntriesTableTable(this);
  late final $AppSettingsTableTable appSettingsTable = $AppSettingsTableTable(
    this,
  );
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final $DailyGoalsTableTable dailyGoalsTable = $DailyGoalsTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recipes,
    recipeTags,
    recipeIngredients,
    recipeDirections,
    pantryItemsTable,
    grocerySectionsTable,
    groceryItemsTable,
    savedMealsTable,
    savedMealAdjustments,
    savedMealComponents,
    foodLogEntriesTable,
    appSettingsTable,
    syncQueueTable,
    dailyGoalsTable,
  ];
}

typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      required String id,
      required String title,
      Value<String?> versionLabel,
      required String notes,
      required int servings,
      Value<bool> isPinned,
      required int sortCalories,
      required int calories,
      required int protein,
      required int carbs,
      required int fat,
      required int fiber,
      required int sodium,
      required int sugar,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> versionLabel,
      Value<String> notes,
      Value<int> servings,
      Value<bool> isPinned,
      Value<int> sortCalories,
      Value<int> calories,
      Value<int> protein,
      Value<int> carbs,
      Value<int> fat,
      Value<int> fiber,
      Value<int> sodium,
      Value<int> sugar,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$RecipesTableReferences
    extends BaseReferences<_$AppDatabase, $RecipesTable, Recipe> {
  $$RecipesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecipeTagsTable, List<RecipeTag>>
  _recipeTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeTags,
    aliasName: $_aliasNameGenerator(db.recipes.id, db.recipeTags.recipeId),
  );

  $$RecipeTagsTableProcessedTableManager get recipeTagsRefs {
    final manager = $$RecipeTagsTableTableManager(
      $_db,
      $_db.recipeTags,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recipeTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeIngredientsTable, List<RecipeIngredient>>
  _recipeIngredientsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recipeIngredients,
        aliasName: $_aliasNameGenerator(
          db.recipes.id,
          db.recipeIngredients.recipeId,
        ),
      );

  $$RecipeIngredientsTableProcessedTableManager get recipeIngredientsRefs {
    final manager = $$RecipeIngredientsTableTableManager(
      $_db,
      $_db.recipeIngredients,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecipeDirectionsTable, List<RecipeDirection>>
  _recipeDirectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recipeDirections,
    aliasName: $_aliasNameGenerator(
      db.recipes.id,
      db.recipeDirections.recipeId,
    ),
  );

  $$RecipeDirectionsTableProcessedTableManager get recipeDirectionsRefs {
    final manager = $$RecipeDirectionsTableTableManager(
      $_db,
      $_db.recipeDirections,
    ).filter((f) => f.recipeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recipeDirectionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionLabel => $composableBuilder(
    column: $table.versionLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortCalories => $composableBuilder(
    column: $table.sortCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recipeTagsRefs(
    Expression<bool> Function($$RecipeTagsTableFilterComposer f) f,
  ) {
    final $$RecipeTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeTags,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeTagsTableFilterComposer(
            $db: $db,
            $table: $db.recipeTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeIngredientsRefs(
    Expression<bool> Function($$RecipeIngredientsTableFilterComposer f) f,
  ) {
    final $$RecipeIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeIngredients,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.recipeIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recipeDirectionsRefs(
    Expression<bool> Function($$RecipeDirectionsTableFilterComposer f) f,
  ) {
    final $$RecipeDirectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeDirections,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeDirectionsTableFilterComposer(
            $db: $db,
            $table: $db.recipeDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionLabel => $composableBuilder(
    column: $table.versionLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortCalories => $composableBuilder(
    column: $table.sortCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get versionLabel => $composableBuilder(
    column: $table.versionLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<int> get sortCalories => $composableBuilder(
    column: $table.sortCalories,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<int> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<int> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<int> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<int> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<int> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<int> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> recipeTagsRefs<T extends Object>(
    Expression<T> Function($$RecipeTagsTableAnnotationComposer a) f,
  ) {
    final $$RecipeTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeTags,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recipeIngredientsRefs<T extends Object>(
    Expression<T> Function($$RecipeIngredientsTableAnnotationComposer a) f,
  ) {
    final $$RecipeIngredientsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recipeIngredients,
          getReferencedColumn: (t) => t.recipeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecipeIngredientsTableAnnotationComposer(
                $db: $db,
                $table: $db.recipeIngredients,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recipeDirectionsRefs<T extends Object>(
    Expression<T> Function($$RecipeDirectionsTableAnnotationComposer a) f,
  ) {
    final $$RecipeDirectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recipeDirections,
      getReferencedColumn: (t) => t.recipeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipeDirectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.recipeDirections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          Recipe,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (Recipe, $$RecipesTableReferences),
          Recipe,
          PrefetchHooks Function({
            bool recipeTagsRefs,
            bool recipeIngredientsRefs,
            bool recipeDirectionsRefs,
          })
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> versionLabel = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> sortCalories = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<int> protein = const Value.absent(),
                Value<int> carbs = const Value.absent(),
                Value<int> fat = const Value.absent(),
                Value<int> fiber = const Value.absent(),
                Value<int> sodium = const Value.absent(),
                Value<int> sugar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                title: title,
                versionLabel: versionLabel,
                notes: notes,
                servings: servings,
                isPinned: isPinned,
                sortCalories: sortCalories,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                sugar: sugar,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> versionLabel = const Value.absent(),
                required String notes,
                required int servings,
                Value<bool> isPinned = const Value.absent(),
                required int sortCalories,
                required int calories,
                required int protein,
                required int carbs,
                required int fat,
                required int fiber,
                required int sodium,
                required int sugar,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                title: title,
                versionLabel: versionLabel,
                notes: notes,
                servings: servings,
                isPinned: isPinned,
                sortCalories: sortCalories,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                sugar: sugar,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                recipeTagsRefs = false,
                recipeIngredientsRefs = false,
                recipeDirectionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recipeTagsRefs) db.recipeTags,
                    if (recipeIngredientsRefs) db.recipeIngredients,
                    if (recipeDirectionsRefs) db.recipeDirections,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recipeTagsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeTag
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipeIngredientsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recipeDirectionsRefs)
                        await $_getPrefetchedData<
                          Recipe,
                          $RecipesTable,
                          RecipeDirection
                        >(
                          currentTable: table,
                          referencedTable: $$RecipesTableReferences
                              ._recipeDirectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecipesTableReferences(
                                db,
                                table,
                                p0,
                              ).recipeDirectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recipeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      Recipe,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (Recipe, $$RecipesTableReferences),
      Recipe,
      PrefetchHooks Function({
        bool recipeTagsRefs,
        bool recipeIngredientsRefs,
        bool recipeDirectionsRefs,
      })
    >;
typedef $$RecipeTagsTableCreateCompanionBuilder =
    RecipeTagsCompanion Function({
      Value<int> id,
      required String recipeId,
      required String label,
      required int position,
    });
typedef $$RecipeTagsTableUpdateCompanionBuilder =
    RecipeTagsCompanion Function({
      Value<int> id,
      Value<String> recipeId,
      Value<String> label,
      Value<int> position,
    });

final class $$RecipeTagsTableReferences
    extends BaseReferences<_$AppDatabase, $RecipeTagsTable, RecipeTag> {
  $$RecipeTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RecipesTable _recipeIdTable(_$AppDatabase db) => db.recipes
      .createAlias($_aliasNameGenerator(db.recipeTags.recipeId, db.recipes.id));

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<String>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeTagsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeTagsTable> {
  $$RecipeTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeTagsTable,
          RecipeTag,
          $$RecipeTagsTableFilterComposer,
          $$RecipeTagsTableOrderingComposer,
          $$RecipeTagsTableAnnotationComposer,
          $$RecipeTagsTableCreateCompanionBuilder,
          $$RecipeTagsTableUpdateCompanionBuilder,
          (RecipeTag, $$RecipeTagsTableReferences),
          RecipeTag,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeTagsTableTableManager(_$AppDatabase db, $RecipeTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => RecipeTagsCompanion(
                id: id,
                recipeId: recipeId,
                label: label,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recipeId,
                required String label,
                required int position,
              }) => RecipeTagsCompanion.insert(
                id: id,
                recipeId: recipeId,
                label: label,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recipeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeId,
                                referencedTable: $$RecipeTagsTableReferences
                                    ._recipeIdTable(db),
                                referencedColumn: $$RecipeTagsTableReferences
                                    ._recipeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeTagsTable,
      RecipeTag,
      $$RecipeTagsTableFilterComposer,
      $$RecipeTagsTableOrderingComposer,
      $$RecipeTagsTableAnnotationComposer,
      $$RecipeTagsTableCreateCompanionBuilder,
      $$RecipeTagsTableUpdateCompanionBuilder,
      (RecipeTag, $$RecipeTagsTableReferences),
      RecipeTag,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$RecipeIngredientsTableCreateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      required String recipeId,
      required int position,
      required String quantity,
      required String unit,
      required String item,
      required String preparation,
      Value<String> ingredientType,
      Value<String?> linkedPantryItemId,
      Value<String?> linkedRecipeId,
    });
typedef $$RecipeIngredientsTableUpdateCompanionBuilder =
    RecipeIngredientsCompanion Function({
      Value<int> id,
      Value<String> recipeId,
      Value<int> position,
      Value<String> quantity,
      Value<String> unit,
      Value<String> item,
      Value<String> preparation,
      Value<String> ingredientType,
      Value<String?> linkedPantryItemId,
      Value<String?> linkedRecipeId,
    });

final class $$RecipeIngredientsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient
        > {
  $$RecipeIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias(
        $_aliasNameGenerator(db.recipeIngredients.recipeId, db.recipes.id),
      );

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<String>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preparation => $composableBuilder(
    column: $table.preparation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientType => $composableBuilder(
    column: $table.ingredientType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedPantryItemId => $composableBuilder(
    column: $table.linkedPantryItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedRecipeId => $composableBuilder(
    column: $table.linkedRecipeId,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preparation => $composableBuilder(
    column: $table.preparation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientType => $composableBuilder(
    column: $table.ingredientType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedPantryItemId => $composableBuilder(
    column: $table.linkedPantryItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedRecipeId => $composableBuilder(
    column: $table.linkedRecipeId,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeIngredientsTable> {
  $$RecipeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get item =>
      $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<String> get preparation => $composableBuilder(
    column: $table.preparation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientType => $composableBuilder(
    column: $table.ingredientType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedPantryItemId => $composableBuilder(
    column: $table.linkedPantryItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedRecipeId => $composableBuilder(
    column: $table.linkedRecipeId,
    builder: (column) => column,
  );

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeIngredientsTable,
          RecipeIngredient,
          $$RecipeIngredientsTableFilterComposer,
          $$RecipeIngredientsTableOrderingComposer,
          $$RecipeIngredientsTableAnnotationComposer,
          $$RecipeIngredientsTableCreateCompanionBuilder,
          $$RecipeIngredientsTableUpdateCompanionBuilder,
          (RecipeIngredient, $$RecipeIngredientsTableReferences),
          RecipeIngredient,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeIngredientsTableTableManager(
    _$AppDatabase db,
    $RecipeIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeIngredientsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> item = const Value.absent(),
                Value<String> preparation = const Value.absent(),
                Value<String> ingredientType = const Value.absent(),
                Value<String?> linkedPantryItemId = const Value.absent(),
                Value<String?> linkedRecipeId = const Value.absent(),
              }) => RecipeIngredientsCompanion(
                id: id,
                recipeId: recipeId,
                position: position,
                quantity: quantity,
                unit: unit,
                item: item,
                preparation: preparation,
                ingredientType: ingredientType,
                linkedPantryItemId: linkedPantryItemId,
                linkedRecipeId: linkedRecipeId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recipeId,
                required int position,
                required String quantity,
                required String unit,
                required String item,
                required String preparation,
                Value<String> ingredientType = const Value.absent(),
                Value<String?> linkedPantryItemId = const Value.absent(),
                Value<String?> linkedRecipeId = const Value.absent(),
              }) => RecipeIngredientsCompanion.insert(
                id: id,
                recipeId: recipeId,
                position: position,
                quantity: quantity,
                unit: unit,
                item: item,
                preparation: preparation,
                ingredientType: ingredientType,
                linkedPantryItemId: linkedPantryItemId,
                linkedRecipeId: linkedRecipeId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recipeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeId,
                                referencedTable:
                                    $$RecipeIngredientsTableReferences
                                        ._recipeIdTable(db),
                                referencedColumn:
                                    $$RecipeIngredientsTableReferences
                                        ._recipeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeIngredientsTable,
      RecipeIngredient,
      $$RecipeIngredientsTableFilterComposer,
      $$RecipeIngredientsTableOrderingComposer,
      $$RecipeIngredientsTableAnnotationComposer,
      $$RecipeIngredientsTableCreateCompanionBuilder,
      $$RecipeIngredientsTableUpdateCompanionBuilder,
      (RecipeIngredient, $$RecipeIngredientsTableReferences),
      RecipeIngredient,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$RecipeDirectionsTableCreateCompanionBuilder =
    RecipeDirectionsCompanion Function({
      Value<int> id,
      required String recipeId,
      required int position,
      required String instruction,
    });
typedef $$RecipeDirectionsTableUpdateCompanionBuilder =
    RecipeDirectionsCompanion Function({
      Value<int> id,
      Value<String> recipeId,
      Value<int> position,
      Value<String> instruction,
    });

final class $$RecipeDirectionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RecipeDirectionsTable, RecipeDirection> {
  $$RecipeDirectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecipesTable _recipeIdTable(_$AppDatabase db) =>
      db.recipes.createAlias(
        $_aliasNameGenerator(db.recipeDirections.recipeId, db.recipes.id),
      );

  $$RecipesTableProcessedTableManager get recipeId {
    final $_column = $_itemColumn<String>('recipe_id')!;

    final manager = $$RecipesTableTableManager(
      $_db,
      $_db.recipes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recipeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecipeDirectionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecipeDirectionsTable> {
  $$RecipeDirectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => ColumnFilters(column),
  );

  $$RecipesTableFilterComposer get recipeId {
    final $$RecipesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableFilterComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeDirectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipeDirectionsTable> {
  $$RecipeDirectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecipesTableOrderingComposer get recipeId {
    final $$RecipesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableOrderingComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeDirectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipeDirectionsTable> {
  $$RecipeDirectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => column,
  );

  $$RecipesTableAnnotationComposer get recipeId {
    final $$RecipesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recipeId,
      referencedTable: $db.recipes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecipesTableAnnotationComposer(
            $db: $db,
            $table: $db.recipes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecipeDirectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipeDirectionsTable,
          RecipeDirection,
          $$RecipeDirectionsTableFilterComposer,
          $$RecipeDirectionsTableOrderingComposer,
          $$RecipeDirectionsTableAnnotationComposer,
          $$RecipeDirectionsTableCreateCompanionBuilder,
          $$RecipeDirectionsTableUpdateCompanionBuilder,
          (RecipeDirection, $$RecipeDirectionsTableReferences),
          RecipeDirection,
          PrefetchHooks Function({bool recipeId})
        > {
  $$RecipeDirectionsTableTableManager(
    _$AppDatabase db,
    $RecipeDirectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipeDirectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipeDirectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipeDirectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> instruction = const Value.absent(),
              }) => RecipeDirectionsCompanion(
                id: id,
                recipeId: recipeId,
                position: position,
                instruction: instruction,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recipeId,
                required int position,
                required String instruction,
              }) => RecipeDirectionsCompanion.insert(
                id: id,
                recipeId: recipeId,
                position: position,
                instruction: instruction,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecipeDirectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recipeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recipeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recipeId,
                                referencedTable:
                                    $$RecipeDirectionsTableReferences
                                        ._recipeIdTable(db),
                                referencedColumn:
                                    $$RecipeDirectionsTableReferences
                                        ._recipeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecipeDirectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipeDirectionsTable,
      RecipeDirection,
      $$RecipeDirectionsTableFilterComposer,
      $$RecipeDirectionsTableOrderingComposer,
      $$RecipeDirectionsTableAnnotationComposer,
      $$RecipeDirectionsTableCreateCompanionBuilder,
      $$RecipeDirectionsTableUpdateCompanionBuilder,
      (RecipeDirection, $$RecipeDirectionsTableReferences),
      RecipeDirection,
      PrefetchHooks Function({bool recipeId})
    >;
typedef $$PantryItemsTableTableCreateCompanionBuilder =
    PantryItemsTableCompanion Function({
      required String id,
      required String title,
      required String quantityLabel,
      Value<double> referenceUnitQuantity,
      Value<String> referenceUnit,
      Value<double?> referenceUnitEquivalentQuantity,
      Value<String?> referenceUnitEquivalentUnit,
      Value<double?> referenceUnitWeightGrams,
      required String source,
      required int accentHex,
      Value<String?> barcode,
      Value<String?> brand,
      required int calories,
      required int protein,
      required int carbs,
      required int fat,
      required int fiber,
      required int sodium,
      required int sugar,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PantryItemsTableTableUpdateCompanionBuilder =
    PantryItemsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> quantityLabel,
      Value<double> referenceUnitQuantity,
      Value<String> referenceUnit,
      Value<double?> referenceUnitEquivalentQuantity,
      Value<String?> referenceUnitEquivalentUnit,
      Value<double?> referenceUnitWeightGrams,
      Value<String> source,
      Value<int> accentHex,
      Value<String?> barcode,
      Value<String?> brand,
      Value<int> calories,
      Value<int> protein,
      Value<int> carbs,
      Value<int> fat,
      Value<int> fiber,
      Value<int> sodium,
      Value<int> sugar,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PantryItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PantryItemsTableTable> {
  $$PantryItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityLabel => $composableBuilder(
    column: $table.quantityLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get referenceUnitQuantity => $composableBuilder(
    column: $table.referenceUnitQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceUnit => $composableBuilder(
    column: $table.referenceUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get referenceUnitEquivalentQuantity =>
      $composableBuilder(
        column: $table.referenceUnitEquivalentQuantity,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get referenceUnitEquivalentUnit => $composableBuilder(
    column: $table.referenceUnitEquivalentUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get referenceUnitWeightGrams => $composableBuilder(
    column: $table.referenceUnitWeightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accentHex => $composableBuilder(
    column: $table.accentHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PantryItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PantryItemsTableTable> {
  $$PantryItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityLabel => $composableBuilder(
    column: $table.quantityLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get referenceUnitQuantity => $composableBuilder(
    column: $table.referenceUnitQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceUnit => $composableBuilder(
    column: $table.referenceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get referenceUnitEquivalentQuantity =>
      $composableBuilder(
        column: $table.referenceUnitEquivalentQuantity,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get referenceUnitEquivalentUnit => $composableBuilder(
    column: $table.referenceUnitEquivalentUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get referenceUnitWeightGrams => $composableBuilder(
    column: $table.referenceUnitWeightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accentHex => $composableBuilder(
    column: $table.accentHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PantryItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PantryItemsTableTable> {
  $$PantryItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get quantityLabel => $composableBuilder(
    column: $table.quantityLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get referenceUnitQuantity => $composableBuilder(
    column: $table.referenceUnitQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceUnit => $composableBuilder(
    column: $table.referenceUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get referenceUnitEquivalentQuantity =>
      $composableBuilder(
        column: $table.referenceUnitEquivalentQuantity,
        builder: (column) => column,
      );

  GeneratedColumn<String> get referenceUnitEquivalentUnit => $composableBuilder(
    column: $table.referenceUnitEquivalentUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get referenceUnitWeightGrams => $composableBuilder(
    column: $table.referenceUnitWeightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get accentHex =>
      $composableBuilder(column: $table.accentHex, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<int> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<int> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<int> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<int> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<int> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<int> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PantryItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PantryItemsTableTable,
          PantryItemsTableData,
          $$PantryItemsTableTableFilterComposer,
          $$PantryItemsTableTableOrderingComposer,
          $$PantryItemsTableTableAnnotationComposer,
          $$PantryItemsTableTableCreateCompanionBuilder,
          $$PantryItemsTableTableUpdateCompanionBuilder,
          (
            PantryItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $PantryItemsTableTable,
              PantryItemsTableData
            >,
          ),
          PantryItemsTableData,
          PrefetchHooks Function()
        > {
  $$PantryItemsTableTableTableManager(
    _$AppDatabase db,
    $PantryItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PantryItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PantryItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PantryItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> quantityLabel = const Value.absent(),
                Value<double> referenceUnitQuantity = const Value.absent(),
                Value<String> referenceUnit = const Value.absent(),
                Value<double?> referenceUnitEquivalentQuantity =
                    const Value.absent(),
                Value<String?> referenceUnitEquivalentUnit =
                    const Value.absent(),
                Value<double?> referenceUnitWeightGrams = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> accentHex = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<int> protein = const Value.absent(),
                Value<int> carbs = const Value.absent(),
                Value<int> fat = const Value.absent(),
                Value<int> fiber = const Value.absent(),
                Value<int> sodium = const Value.absent(),
                Value<int> sugar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PantryItemsTableCompanion(
                id: id,
                title: title,
                quantityLabel: quantityLabel,
                referenceUnitQuantity: referenceUnitQuantity,
                referenceUnit: referenceUnit,
                referenceUnitEquivalentQuantity:
                    referenceUnitEquivalentQuantity,
                referenceUnitEquivalentUnit: referenceUnitEquivalentUnit,
                referenceUnitWeightGrams: referenceUnitWeightGrams,
                source: source,
                accentHex: accentHex,
                barcode: barcode,
                brand: brand,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                sugar: sugar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String quantityLabel,
                Value<double> referenceUnitQuantity = const Value.absent(),
                Value<String> referenceUnit = const Value.absent(),
                Value<double?> referenceUnitEquivalentQuantity =
                    const Value.absent(),
                Value<String?> referenceUnitEquivalentUnit =
                    const Value.absent(),
                Value<double?> referenceUnitWeightGrams = const Value.absent(),
                required String source,
                required int accentHex,
                Value<String?> barcode = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                required int calories,
                required int protein,
                required int carbs,
                required int fat,
                required int fiber,
                required int sodium,
                required int sugar,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PantryItemsTableCompanion.insert(
                id: id,
                title: title,
                quantityLabel: quantityLabel,
                referenceUnitQuantity: referenceUnitQuantity,
                referenceUnit: referenceUnit,
                referenceUnitEquivalentQuantity:
                    referenceUnitEquivalentQuantity,
                referenceUnitEquivalentUnit: referenceUnitEquivalentUnit,
                referenceUnitWeightGrams: referenceUnitWeightGrams,
                source: source,
                accentHex: accentHex,
                barcode: barcode,
                brand: brand,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                sugar: sugar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PantryItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PantryItemsTableTable,
      PantryItemsTableData,
      $$PantryItemsTableTableFilterComposer,
      $$PantryItemsTableTableOrderingComposer,
      $$PantryItemsTableTableAnnotationComposer,
      $$PantryItemsTableTableCreateCompanionBuilder,
      $$PantryItemsTableTableUpdateCompanionBuilder,
      (
        PantryItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $PantryItemsTableTable,
          PantryItemsTableData
        >,
      ),
      PantryItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$GrocerySectionsTableTableCreateCompanionBuilder =
    GrocerySectionsTableCompanion Function({
      required String id,
      required String title,
      required int position,
      Value<int> rowid,
    });
typedef $$GrocerySectionsTableTableUpdateCompanionBuilder =
    GrocerySectionsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> position,
      Value<int> rowid,
    });

final class $$GrocerySectionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GrocerySectionsTableTable,
          GrocerySectionsTableData
        > {
  $$GrocerySectionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $GroceryItemsTableTable,
    List<GroceryItemsTableData>
  >
  _groceryItemsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.groceryItemsTable,
        aliasName: $_aliasNameGenerator(
          db.grocerySectionsTable.id,
          db.groceryItemsTable.sectionId,
        ),
      );

  $$GroceryItemsTableTableProcessedTableManager get groceryItemsTableRefs {
    final manager = $$GroceryItemsTableTableTableManager(
      $_db,
      $_db.groceryItemsTable,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _groceryItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GrocerySectionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GrocerySectionsTableTable> {
  $$GrocerySectionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> groceryItemsTableRefs(
    Expression<bool> Function($$GroceryItemsTableTableFilterComposer f) f,
  ) {
    final $$GroceryItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.groceryItemsTable,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GroceryItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.groceryItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GrocerySectionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GrocerySectionsTableTable> {
  $$GrocerySectionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GrocerySectionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrocerySectionsTableTable> {
  $$GrocerySectionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> groceryItemsTableRefs<T extends Object>(
    Expression<T> Function($$GroceryItemsTableTableAnnotationComposer a) f,
  ) {
    final $$GroceryItemsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.groceryItemsTable,
          getReferencedColumn: (t) => t.sectionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GroceryItemsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.groceryItemsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GrocerySectionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GrocerySectionsTableTable,
          GrocerySectionsTableData,
          $$GrocerySectionsTableTableFilterComposer,
          $$GrocerySectionsTableTableOrderingComposer,
          $$GrocerySectionsTableTableAnnotationComposer,
          $$GrocerySectionsTableTableCreateCompanionBuilder,
          $$GrocerySectionsTableTableUpdateCompanionBuilder,
          (GrocerySectionsTableData, $$GrocerySectionsTableTableReferences),
          GrocerySectionsTableData,
          PrefetchHooks Function({bool groceryItemsTableRefs})
        > {
  $$GrocerySectionsTableTableTableManager(
    _$AppDatabase db,
    $GrocerySectionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GrocerySectionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GrocerySectionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GrocerySectionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrocerySectionsTableCompanion(
                id: id,
                title: title,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => GrocerySectionsTableCompanion.insert(
                id: id,
                title: title,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GrocerySectionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({groceryItemsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (groceryItemsTableRefs) db.groceryItemsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (groceryItemsTableRefs)
                    await $_getPrefetchedData<
                      GrocerySectionsTableData,
                      $GrocerySectionsTableTable,
                      GroceryItemsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$GrocerySectionsTableTableReferences
                          ._groceryItemsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GrocerySectionsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).groceryItemsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sectionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GrocerySectionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GrocerySectionsTableTable,
      GrocerySectionsTableData,
      $$GrocerySectionsTableTableFilterComposer,
      $$GrocerySectionsTableTableOrderingComposer,
      $$GrocerySectionsTableTableAnnotationComposer,
      $$GrocerySectionsTableTableCreateCompanionBuilder,
      $$GrocerySectionsTableTableUpdateCompanionBuilder,
      (GrocerySectionsTableData, $$GrocerySectionsTableTableReferences),
      GrocerySectionsTableData,
      PrefetchHooks Function({bool groceryItemsTableRefs})
    >;
typedef $$GroceryItemsTableTableCreateCompanionBuilder =
    GroceryItemsTableCompanion Function({
      Value<int> id,
      required String sectionId,
      required String label,
      required int position,
      Value<bool> isChecked,
    });
typedef $$GroceryItemsTableTableUpdateCompanionBuilder =
    GroceryItemsTableCompanion Function({
      Value<int> id,
      Value<String> sectionId,
      Value<String> label,
      Value<int> position,
      Value<bool> isChecked,
    });

final class $$GroceryItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GroceryItemsTableTable,
          GroceryItemsTableData
        > {
  $$GroceryItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GrocerySectionsTableTable _sectionIdTable(_$AppDatabase db) =>
      db.grocerySectionsTable.createAlias(
        $_aliasNameGenerator(
          db.groceryItemsTable.sectionId,
          db.grocerySectionsTable.id,
        ),
      );

  $$GrocerySectionsTableTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<String>('section_id')!;

    final manager = $$GrocerySectionsTableTableTableManager(
      $_db,
      $_db.grocerySectionsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GroceryItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $GroceryItemsTableTable> {
  $$GroceryItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnFilters(column),
  );

  $$GrocerySectionsTableTableFilterComposer get sectionId {
    final $$GrocerySectionsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.grocerySectionsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GrocerySectionsTableTableFilterComposer(
            $db: $db,
            $table: $db.grocerySectionsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GroceryItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GroceryItemsTableTable> {
  $$GroceryItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnOrderings(column),
  );

  $$GrocerySectionsTableTableOrderingComposer get sectionId {
    final $$GrocerySectionsTableTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sectionId,
          referencedTable: $db.grocerySectionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrocerySectionsTableTableOrderingComposer(
                $db: $db,
                $table: $db.grocerySectionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GroceryItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroceryItemsTableTable> {
  $$GroceryItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  $$GrocerySectionsTableTableAnnotationComposer get sectionId {
    final $$GrocerySectionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sectionId,
          referencedTable: $db.grocerySectionsTable,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GrocerySectionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.grocerySectionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$GroceryItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroceryItemsTableTable,
          GroceryItemsTableData,
          $$GroceryItemsTableTableFilterComposer,
          $$GroceryItemsTableTableOrderingComposer,
          $$GroceryItemsTableTableAnnotationComposer,
          $$GroceryItemsTableTableCreateCompanionBuilder,
          $$GroceryItemsTableTableUpdateCompanionBuilder,
          (GroceryItemsTableData, $$GroceryItemsTableTableReferences),
          GroceryItemsTableData,
          PrefetchHooks Function({bool sectionId})
        > {
  $$GroceryItemsTableTableTableManager(
    _$AppDatabase db,
    $GroceryItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroceryItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroceryItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroceryItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
              }) => GroceryItemsTableCompanion(
                id: id,
                sectionId: sectionId,
                label: label,
                position: position,
                isChecked: isChecked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sectionId,
                required String label,
                required int position,
                Value<bool> isChecked = const Value.absent(),
              }) => GroceryItemsTableCompanion.insert(
                id: id,
                sectionId: sectionId,
                label: label,
                position: position,
                isChecked: isChecked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GroceryItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sectionId,
                                referencedTable:
                                    $$GroceryItemsTableTableReferences
                                        ._sectionIdTable(db),
                                referencedColumn:
                                    $$GroceryItemsTableTableReferences
                                        ._sectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GroceryItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroceryItemsTableTable,
      GroceryItemsTableData,
      $$GroceryItemsTableTableFilterComposer,
      $$GroceryItemsTableTableOrderingComposer,
      $$GroceryItemsTableTableAnnotationComposer,
      $$GroceryItemsTableTableCreateCompanionBuilder,
      $$GroceryItemsTableTableUpdateCompanionBuilder,
      (GroceryItemsTableData, $$GroceryItemsTableTableReferences),
      GroceryItemsTableData,
      PrefetchHooks Function({bool sectionId})
    >;
typedef $$SavedMealsTableTableCreateCompanionBuilder =
    SavedMealsTableCompanion Function({
      required String id,
      required String title,
      required int calories,
      required int protein,
      required int carbs,
      required int fat,
      required int fiber,
      required int sodium,
      required int sugar,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SavedMealsTableTableUpdateCompanionBuilder =
    SavedMealsTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> calories,
      Value<int> protein,
      Value<int> carbs,
      Value<int> fat,
      Value<int> fiber,
      Value<int> sodium,
      Value<int> sugar,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SavedMealsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SavedMealsTableTable,
          SavedMealsTableData
        > {
  $$SavedMealsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $SavedMealAdjustmentsTable,
    List<SavedMealAdjustment>
  >
  _savedMealAdjustmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.savedMealAdjustments,
        aliasName: $_aliasNameGenerator(
          db.savedMealsTable.id,
          db.savedMealAdjustments.mealId,
        ),
      );

  $$SavedMealAdjustmentsTableProcessedTableManager
  get savedMealAdjustmentsRefs {
    final manager = $$SavedMealAdjustmentsTableTableManager(
      $_db,
      $_db.savedMealAdjustments,
    ).filter((f) => f.mealId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _savedMealAdjustmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SavedMealComponentsTable,
    List<SavedMealComponent>
  >
  _savedMealComponentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.savedMealComponents,
        aliasName: $_aliasNameGenerator(
          db.savedMealsTable.id,
          db.savedMealComponents.mealId,
        ),
      );

  $$SavedMealComponentsTableProcessedTableManager get savedMealComponentsRefs {
    final manager = $$SavedMealComponentsTableTableManager(
      $_db,
      $_db.savedMealComponents,
    ).filter((f) => f.mealId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _savedMealComponentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SavedMealsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SavedMealsTableTable> {
  $$SavedMealsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> savedMealAdjustmentsRefs(
    Expression<bool> Function($$SavedMealAdjustmentsTableFilterComposer f) f,
  ) {
    final $$SavedMealAdjustmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedMealAdjustments,
      getReferencedColumn: (t) => t.mealId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedMealAdjustmentsTableFilterComposer(
            $db: $db,
            $table: $db.savedMealAdjustments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savedMealComponentsRefs(
    Expression<bool> Function($$SavedMealComponentsTableFilterComposer f) f,
  ) {
    final $$SavedMealComponentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedMealComponents,
      getReferencedColumn: (t) => t.mealId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedMealComponentsTableFilterComposer(
            $db: $db,
            $table: $db.savedMealComponents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SavedMealsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedMealsTableTable> {
  $$SavedMealsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedMealsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedMealsTableTable> {
  $$SavedMealsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<int> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<int> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<int> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<int> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<int> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<int> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> savedMealAdjustmentsRefs<T extends Object>(
    Expression<T> Function($$SavedMealAdjustmentsTableAnnotationComposer a) f,
  ) {
    final $$SavedMealAdjustmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.savedMealAdjustments,
          getReferencedColumn: (t) => t.mealId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SavedMealAdjustmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.savedMealAdjustments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> savedMealComponentsRefs<T extends Object>(
    Expression<T> Function($$SavedMealComponentsTableAnnotationComposer a) f,
  ) {
    final $$SavedMealComponentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.savedMealComponents,
          getReferencedColumn: (t) => t.mealId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SavedMealComponentsTableAnnotationComposer(
                $db: $db,
                $table: $db.savedMealComponents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SavedMealsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedMealsTableTable,
          SavedMealsTableData,
          $$SavedMealsTableTableFilterComposer,
          $$SavedMealsTableTableOrderingComposer,
          $$SavedMealsTableTableAnnotationComposer,
          $$SavedMealsTableTableCreateCompanionBuilder,
          $$SavedMealsTableTableUpdateCompanionBuilder,
          (SavedMealsTableData, $$SavedMealsTableTableReferences),
          SavedMealsTableData,
          PrefetchHooks Function({
            bool savedMealAdjustmentsRefs,
            bool savedMealComponentsRefs,
          })
        > {
  $$SavedMealsTableTableTableManager(
    _$AppDatabase db,
    $SavedMealsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedMealsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedMealsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedMealsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<int> protein = const Value.absent(),
                Value<int> carbs = const Value.absent(),
                Value<int> fat = const Value.absent(),
                Value<int> fiber = const Value.absent(),
                Value<int> sodium = const Value.absent(),
                Value<int> sugar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedMealsTableCompanion(
                id: id,
                title: title,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                sugar: sugar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required int calories,
                required int protein,
                required int carbs,
                required int fat,
                required int fiber,
                required int sodium,
                required int sugar,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SavedMealsTableCompanion.insert(
                id: id,
                title: title,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                sugar: sugar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedMealsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                savedMealAdjustmentsRefs = false,
                savedMealComponentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (savedMealAdjustmentsRefs) db.savedMealAdjustments,
                    if (savedMealComponentsRefs) db.savedMealComponents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (savedMealAdjustmentsRefs)
                        await $_getPrefetchedData<
                          SavedMealsTableData,
                          $SavedMealsTableTable,
                          SavedMealAdjustment
                        >(
                          currentTable: table,
                          referencedTable: $$SavedMealsTableTableReferences
                              ._savedMealAdjustmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavedMealsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).savedMealAdjustmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mealId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savedMealComponentsRefs)
                        await $_getPrefetchedData<
                          SavedMealsTableData,
                          $SavedMealsTableTable,
                          SavedMealComponent
                        >(
                          currentTable: table,
                          referencedTable: $$SavedMealsTableTableReferences
                              ._savedMealComponentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SavedMealsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).savedMealComponentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mealId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SavedMealsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedMealsTableTable,
      SavedMealsTableData,
      $$SavedMealsTableTableFilterComposer,
      $$SavedMealsTableTableOrderingComposer,
      $$SavedMealsTableTableAnnotationComposer,
      $$SavedMealsTableTableCreateCompanionBuilder,
      $$SavedMealsTableTableUpdateCompanionBuilder,
      (SavedMealsTableData, $$SavedMealsTableTableReferences),
      SavedMealsTableData,
      PrefetchHooks Function({
        bool savedMealAdjustmentsRefs,
        bool savedMealComponentsRefs,
      })
    >;
typedef $$SavedMealAdjustmentsTableCreateCompanionBuilder =
    SavedMealAdjustmentsCompanion Function({
      Value<int> id,
      required String mealId,
      required String label,
      required int position,
    });
typedef $$SavedMealAdjustmentsTableUpdateCompanionBuilder =
    SavedMealAdjustmentsCompanion Function({
      Value<int> id,
      Value<String> mealId,
      Value<String> label,
      Value<int> position,
    });

final class $$SavedMealAdjustmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SavedMealAdjustmentsTable,
          SavedMealAdjustment
        > {
  $$SavedMealAdjustmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavedMealsTableTable _mealIdTable(_$AppDatabase db) =>
      db.savedMealsTable.createAlias(
        $_aliasNameGenerator(
          db.savedMealAdjustments.mealId,
          db.savedMealsTable.id,
        ),
      );

  $$SavedMealsTableTableProcessedTableManager get mealId {
    final $_column = $_itemColumn<String>('meal_id')!;

    final manager = $$SavedMealsTableTableTableManager(
      $_db,
      $_db.savedMealsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mealIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavedMealAdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedMealAdjustmentsTable> {
  $$SavedMealAdjustmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$SavedMealsTableTableFilterComposer get mealId {
    final $$SavedMealsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.savedMealsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedMealsTableTableFilterComposer(
            $db: $db,
            $table: $db.savedMealsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedMealAdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedMealAdjustmentsTable> {
  $$SavedMealAdjustmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavedMealsTableTableOrderingComposer get mealId {
    final $$SavedMealsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.savedMealsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedMealsTableTableOrderingComposer(
            $db: $db,
            $table: $db.savedMealsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedMealAdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedMealAdjustmentsTable> {
  $$SavedMealAdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$SavedMealsTableTableAnnotationComposer get mealId {
    final $$SavedMealsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.savedMealsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedMealsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.savedMealsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedMealAdjustmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedMealAdjustmentsTable,
          SavedMealAdjustment,
          $$SavedMealAdjustmentsTableFilterComposer,
          $$SavedMealAdjustmentsTableOrderingComposer,
          $$SavedMealAdjustmentsTableAnnotationComposer,
          $$SavedMealAdjustmentsTableCreateCompanionBuilder,
          $$SavedMealAdjustmentsTableUpdateCompanionBuilder,
          (SavedMealAdjustment, $$SavedMealAdjustmentsTableReferences),
          SavedMealAdjustment,
          PrefetchHooks Function({bool mealId})
        > {
  $$SavedMealAdjustmentsTableTableManager(
    _$AppDatabase db,
    $SavedMealAdjustmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedMealAdjustmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedMealAdjustmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SavedMealAdjustmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mealId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => SavedMealAdjustmentsCompanion(
                id: id,
                mealId: mealId,
                label: label,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mealId,
                required String label,
                required int position,
              }) => SavedMealAdjustmentsCompanion.insert(
                id: id,
                mealId: mealId,
                label: label,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedMealAdjustmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mealId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mealId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mealId,
                                referencedTable:
                                    $$SavedMealAdjustmentsTableReferences
                                        ._mealIdTable(db),
                                referencedColumn:
                                    $$SavedMealAdjustmentsTableReferences
                                        ._mealIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavedMealAdjustmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedMealAdjustmentsTable,
      SavedMealAdjustment,
      $$SavedMealAdjustmentsTableFilterComposer,
      $$SavedMealAdjustmentsTableOrderingComposer,
      $$SavedMealAdjustmentsTableAnnotationComposer,
      $$SavedMealAdjustmentsTableCreateCompanionBuilder,
      $$SavedMealAdjustmentsTableUpdateCompanionBuilder,
      (SavedMealAdjustment, $$SavedMealAdjustmentsTableReferences),
      SavedMealAdjustment,
      PrefetchHooks Function({bool mealId})
    >;
typedef $$SavedMealComponentsTableCreateCompanionBuilder =
    SavedMealComponentsCompanion Function({
      Value<int> id,
      required String mealId,
      required int position,
      required String quantity,
      required String unit,
      required String item,
      Value<String> componentType,
      Value<String?> linkedPantryItemId,
      Value<String?> linkedRecipeId,
    });
typedef $$SavedMealComponentsTableUpdateCompanionBuilder =
    SavedMealComponentsCompanion Function({
      Value<int> id,
      Value<String> mealId,
      Value<int> position,
      Value<String> quantity,
      Value<String> unit,
      Value<String> item,
      Value<String> componentType,
      Value<String?> linkedPantryItemId,
      Value<String?> linkedRecipeId,
    });

final class $$SavedMealComponentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SavedMealComponentsTable,
          SavedMealComponent
        > {
  $$SavedMealComponentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavedMealsTableTable _mealIdTable(_$AppDatabase db) =>
      db.savedMealsTable.createAlias(
        $_aliasNameGenerator(
          db.savedMealComponents.mealId,
          db.savedMealsTable.id,
        ),
      );

  $$SavedMealsTableTableProcessedTableManager get mealId {
    final $_column = $_itemColumn<String>('meal_id')!;

    final manager = $$SavedMealsTableTableTableManager(
      $_db,
      $_db.savedMealsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mealIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavedMealComponentsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedMealComponentsTable> {
  $$SavedMealComponentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get componentType => $composableBuilder(
    column: $table.componentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedPantryItemId => $composableBuilder(
    column: $table.linkedPantryItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedRecipeId => $composableBuilder(
    column: $table.linkedRecipeId,
    builder: (column) => ColumnFilters(column),
  );

  $$SavedMealsTableTableFilterComposer get mealId {
    final $$SavedMealsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.savedMealsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedMealsTableTableFilterComposer(
            $db: $db,
            $table: $db.savedMealsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedMealComponentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedMealComponentsTable> {
  $$SavedMealComponentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get item => $composableBuilder(
    column: $table.item,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get componentType => $composableBuilder(
    column: $table.componentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedPantryItemId => $composableBuilder(
    column: $table.linkedPantryItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedRecipeId => $composableBuilder(
    column: $table.linkedRecipeId,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavedMealsTableTableOrderingComposer get mealId {
    final $$SavedMealsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.savedMealsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedMealsTableTableOrderingComposer(
            $db: $db,
            $table: $db.savedMealsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedMealComponentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedMealComponentsTable> {
  $$SavedMealComponentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get item =>
      $composableBuilder(column: $table.item, builder: (column) => column);

  GeneratedColumn<String> get componentType => $composableBuilder(
    column: $table.componentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedPantryItemId => $composableBuilder(
    column: $table.linkedPantryItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedRecipeId => $composableBuilder(
    column: $table.linkedRecipeId,
    builder: (column) => column,
  );

  $$SavedMealsTableTableAnnotationComposer get mealId {
    final $$SavedMealsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.savedMealsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedMealsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.savedMealsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedMealComponentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedMealComponentsTable,
          SavedMealComponent,
          $$SavedMealComponentsTableFilterComposer,
          $$SavedMealComponentsTableOrderingComposer,
          $$SavedMealComponentsTableAnnotationComposer,
          $$SavedMealComponentsTableCreateCompanionBuilder,
          $$SavedMealComponentsTableUpdateCompanionBuilder,
          (SavedMealComponent, $$SavedMealComponentsTableReferences),
          SavedMealComponent,
          PrefetchHooks Function({bool mealId})
        > {
  $$SavedMealComponentsTableTableManager(
    _$AppDatabase db,
    $SavedMealComponentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedMealComponentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedMealComponentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SavedMealComponentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> mealId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String> item = const Value.absent(),
                Value<String> componentType = const Value.absent(),
                Value<String?> linkedPantryItemId = const Value.absent(),
                Value<String?> linkedRecipeId = const Value.absent(),
              }) => SavedMealComponentsCompanion(
                id: id,
                mealId: mealId,
                position: position,
                quantity: quantity,
                unit: unit,
                item: item,
                componentType: componentType,
                linkedPantryItemId: linkedPantryItemId,
                linkedRecipeId: linkedRecipeId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String mealId,
                required int position,
                required String quantity,
                required String unit,
                required String item,
                Value<String> componentType = const Value.absent(),
                Value<String?> linkedPantryItemId = const Value.absent(),
                Value<String?> linkedRecipeId = const Value.absent(),
              }) => SavedMealComponentsCompanion.insert(
                id: id,
                mealId: mealId,
                position: position,
                quantity: quantity,
                unit: unit,
                item: item,
                componentType: componentType,
                linkedPantryItemId: linkedPantryItemId,
                linkedRecipeId: linkedRecipeId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedMealComponentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mealId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mealId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mealId,
                                referencedTable:
                                    $$SavedMealComponentsTableReferences
                                        ._mealIdTable(db),
                                referencedColumn:
                                    $$SavedMealComponentsTableReferences
                                        ._mealIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavedMealComponentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedMealComponentsTable,
      SavedMealComponent,
      $$SavedMealComponentsTableFilterComposer,
      $$SavedMealComponentsTableOrderingComposer,
      $$SavedMealComponentsTableAnnotationComposer,
      $$SavedMealComponentsTableCreateCompanionBuilder,
      $$SavedMealComponentsTableUpdateCompanionBuilder,
      (SavedMealComponent, $$SavedMealComponentsTableReferences),
      SavedMealComponent,
      PrefetchHooks Function({bool mealId})
    >;
typedef $$FoodLogEntriesTableTableCreateCompanionBuilder =
    FoodLogEntriesTableCompanion Function({
      required String id,
      required String entryDate,
      required String mealSlot,
      required String sourceType,
      required String sourceId,
      required String title,
      required String quantity,
      required String unit,
      required int calories,
      required int protein,
      required int carbs,
      required int fat,
      required int fiber,
      required int sodium,
      required int sugar,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FoodLogEntriesTableTableUpdateCompanionBuilder =
    FoodLogEntriesTableCompanion Function({
      Value<String> id,
      Value<String> entryDate,
      Value<String> mealSlot,
      Value<String> sourceType,
      Value<String> sourceId,
      Value<String> title,
      Value<String> quantity,
      Value<String> unit,
      Value<int> calories,
      Value<int> protein,
      Value<int> carbs,
      Value<int> fat,
      Value<int> fiber,
      Value<int> sodium,
      Value<int> sugar,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FoodLogEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTableTable> {
  $$FoodLogEntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealSlot => $composableBuilder(
    column: $table.mealSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodLogEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTableTable> {
  $$FoodLogEntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealSlot => $composableBuilder(
    column: $table.mealSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sodium => $composableBuilder(
    column: $table.sodium,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodLogEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodLogEntriesTableTable> {
  $$FoodLogEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get mealSlot =>
      $composableBuilder(column: $table.mealSlot, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<int> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<int> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<int> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<int> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<int> get sodium =>
      $composableBuilder(column: $table.sodium, builder: (column) => column);

  GeneratedColumn<int> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FoodLogEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodLogEntriesTableTable,
          FoodLogEntriesTableData,
          $$FoodLogEntriesTableTableFilterComposer,
          $$FoodLogEntriesTableTableOrderingComposer,
          $$FoodLogEntriesTableTableAnnotationComposer,
          $$FoodLogEntriesTableTableCreateCompanionBuilder,
          $$FoodLogEntriesTableTableUpdateCompanionBuilder,
          (
            FoodLogEntriesTableData,
            BaseReferences<
              _$AppDatabase,
              $FoodLogEntriesTableTable,
              FoodLogEntriesTableData
            >,
          ),
          FoodLogEntriesTableData,
          PrefetchHooks Function()
        > {
  $$FoodLogEntriesTableTableTableManager(
    _$AppDatabase db,
    $FoodLogEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodLogEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodLogEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FoodLogEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entryDate = const Value.absent(),
                Value<String> mealSlot = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> quantity = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int> calories = const Value.absent(),
                Value<int> protein = const Value.absent(),
                Value<int> carbs = const Value.absent(),
                Value<int> fat = const Value.absent(),
                Value<int> fiber = const Value.absent(),
                Value<int> sodium = const Value.absent(),
                Value<int> sugar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodLogEntriesTableCompanion(
                id: id,
                entryDate: entryDate,
                mealSlot: mealSlot,
                sourceType: sourceType,
                sourceId: sourceId,
                title: title,
                quantity: quantity,
                unit: unit,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                sugar: sugar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entryDate,
                required String mealSlot,
                required String sourceType,
                required String sourceId,
                required String title,
                required String quantity,
                required String unit,
                required int calories,
                required int protein,
                required int carbs,
                required int fat,
                required int fiber,
                required int sodium,
                required int sugar,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FoodLogEntriesTableCompanion.insert(
                id: id,
                entryDate: entryDate,
                mealSlot: mealSlot,
                sourceType: sourceType,
                sourceId: sourceId,
                title: title,
                quantity: quantity,
                unit: unit,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sodium: sodium,
                sugar: sugar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodLogEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodLogEntriesTableTable,
      FoodLogEntriesTableData,
      $$FoodLogEntriesTableTableFilterComposer,
      $$FoodLogEntriesTableTableOrderingComposer,
      $$FoodLogEntriesTableTableAnnotationComposer,
      $$FoodLogEntriesTableTableCreateCompanionBuilder,
      $$FoodLogEntriesTableTableUpdateCompanionBuilder,
      (
        FoodLogEntriesTableData,
        BaseReferences<
          _$AppDatabase,
          $FoodLogEntriesTableTable,
          FoodLogEntriesTableData
        >,
      ),
      FoodLogEntriesTableData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableTableCreateCompanionBuilder =
    AppSettingsTableCompanion Function({
      required String key,
      Value<String?> value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableTableUpdateCompanionBuilder =
    AppSettingsTableCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTableTable> {
  $$AppSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData,
          $$AppSettingsTableTableFilterComposer,
          $$AppSettingsTableTableOrderingComposer,
          $$AppSettingsTableTableAnnotationComposer,
          $$AppSettingsTableTableCreateCompanionBuilder,
          $$AppSettingsTableTableUpdateCompanionBuilder,
          (
            AppSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsTableTable,
              AppSettingsTableData
            >,
          ),
          AppSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableTableManager(
    _$AppDatabase db,
    $AppSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsTableCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTableTable,
      AppSettingsTableData,
      $$AppSettingsTableTableFilterComposer,
      $$AppSettingsTableTableOrderingComposer,
      $$AppSettingsTableTableAnnotationComposer,
      $$AppSettingsTableTableCreateCompanionBuilder,
      $$AppSettingsTableTableUpdateCompanionBuilder,
      (
        AppSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AppSettingsTableTable,
          AppSettingsTableData
        >,
      ),
      AppSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableTableCreateCompanionBuilder =
    SyncQueueTableCompanion Function({
      required String entityType,
      required String entityId,
      required String changeType,
      Value<String?> displayLabel,
      required DateTime changedAt,
      Value<int> rowid,
    });
typedef $$SyncQueueTableTableUpdateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<String> changeType,
      Value<String?> displayLabel,
      Value<DateTime> changedAt,
      Value<int> rowid,
    });

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get changeType => $composableBuilder(
    column: $table.changeType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayLabel => $composableBuilder(
    column: $table.displayLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTableTable,
          SyncQueueTableData,
          $$SyncQueueTableTableFilterComposer,
          $$SyncQueueTableTableOrderingComposer,
          $$SyncQueueTableTableAnnotationComposer,
          $$SyncQueueTableTableCreateCompanionBuilder,
          $$SyncQueueTableTableUpdateCompanionBuilder,
          (
            SyncQueueTableData,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueTableTable,
              SyncQueueTableData
            >,
          ),
          SyncQueueTableData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableTableManager(
    _$AppDatabase db,
    $SyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> changeType = const Value.absent(),
                Value<String?> displayLabel = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion(
                entityType: entityType,
                entityId: entityId,
                changeType: changeType,
                displayLabel: displayLabel,
                changedAt: changedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                required String changeType,
                Value<String?> displayLabel = const Value.absent(),
                required DateTime changedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                changeType: changeType,
                displayLabel: displayLabel,
                changedAt: changedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTableTable,
      SyncQueueTableData,
      $$SyncQueueTableTableFilterComposer,
      $$SyncQueueTableTableOrderingComposer,
      $$SyncQueueTableTableAnnotationComposer,
      $$SyncQueueTableTableCreateCompanionBuilder,
      $$SyncQueueTableTableUpdateCompanionBuilder,
      (
        SyncQueueTableData,
        BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>,
      ),
      SyncQueueTableData,
      PrefetchHooks Function()
    >;
typedef $$DailyGoalsTableTableCreateCompanionBuilder =
    DailyGoalsTableCompanion Function({
      Value<int> id,
      required String label,
      required int consumed,
      required int target,
    });
typedef $$DailyGoalsTableTableUpdateCompanionBuilder =
    DailyGoalsTableCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<int> consumed,
      Value<int> target,
    });

class $$DailyGoalsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DailyGoalsTableTable> {
  $$DailyGoalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consumed => $composableBuilder(
    column: $table.consumed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyGoalsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyGoalsTableTable> {
  $$DailyGoalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consumed => $composableBuilder(
    column: $table.consumed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyGoalsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyGoalsTableTable> {
  $$DailyGoalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get consumed =>
      $composableBuilder(column: $table.consumed, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);
}

class $$DailyGoalsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyGoalsTableTable,
          DailyGoalsTableData,
          $$DailyGoalsTableTableFilterComposer,
          $$DailyGoalsTableTableOrderingComposer,
          $$DailyGoalsTableTableAnnotationComposer,
          $$DailyGoalsTableTableCreateCompanionBuilder,
          $$DailyGoalsTableTableUpdateCompanionBuilder,
          (
            DailyGoalsTableData,
            BaseReferences<
              _$AppDatabase,
              $DailyGoalsTableTable,
              DailyGoalsTableData
            >,
          ),
          DailyGoalsTableData,
          PrefetchHooks Function()
        > {
  $$DailyGoalsTableTableTableManager(
    _$AppDatabase db,
    $DailyGoalsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyGoalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyGoalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyGoalsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> consumed = const Value.absent(),
                Value<int> target = const Value.absent(),
              }) => DailyGoalsTableCompanion(
                id: id,
                label: label,
                consumed: consumed,
                target: target,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required int consumed,
                required int target,
              }) => DailyGoalsTableCompanion.insert(
                id: id,
                label: label,
                consumed: consumed,
                target: target,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyGoalsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyGoalsTableTable,
      DailyGoalsTableData,
      $$DailyGoalsTableTableFilterComposer,
      $$DailyGoalsTableTableOrderingComposer,
      $$DailyGoalsTableTableAnnotationComposer,
      $$DailyGoalsTableTableCreateCompanionBuilder,
      $$DailyGoalsTableTableUpdateCompanionBuilder,
      (
        DailyGoalsTableData,
        BaseReferences<
          _$AppDatabase,
          $DailyGoalsTableTable,
          DailyGoalsTableData
        >,
      ),
      DailyGoalsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$RecipeTagsTableTableManager get recipeTags =>
      $$RecipeTagsTableTableManager(_db, _db.recipeTags);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(_db, _db.recipeIngredients);
  $$RecipeDirectionsTableTableManager get recipeDirections =>
      $$RecipeDirectionsTableTableManager(_db, _db.recipeDirections);
  $$PantryItemsTableTableTableManager get pantryItemsTable =>
      $$PantryItemsTableTableTableManager(_db, _db.pantryItemsTable);
  $$GrocerySectionsTableTableTableManager get grocerySectionsTable =>
      $$GrocerySectionsTableTableTableManager(_db, _db.grocerySectionsTable);
  $$GroceryItemsTableTableTableManager get groceryItemsTable =>
      $$GroceryItemsTableTableTableManager(_db, _db.groceryItemsTable);
  $$SavedMealsTableTableTableManager get savedMealsTable =>
      $$SavedMealsTableTableTableManager(_db, _db.savedMealsTable);
  $$SavedMealAdjustmentsTableTableManager get savedMealAdjustments =>
      $$SavedMealAdjustmentsTableTableManager(_db, _db.savedMealAdjustments);
  $$SavedMealComponentsTableTableManager get savedMealComponents =>
      $$SavedMealComponentsTableTableManager(_db, _db.savedMealComponents);
  $$FoodLogEntriesTableTableTableManager get foodLogEntriesTable =>
      $$FoodLogEntriesTableTableTableManager(_db, _db.foodLogEntriesTable);
  $$AppSettingsTableTableTableManager get appSettingsTable =>
      $$AppSettingsTableTableTableManager(_db, _db.appSettingsTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
  $$DailyGoalsTableTableTableManager get dailyGoalsTable =>
      $$DailyGoalsTableTableTableManager(_db, _db.dailyGoalsTable);
}
