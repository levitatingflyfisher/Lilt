// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $NameEntriesTable extends NameEntries
    with TableInfo<$NameEntriesTable, NameEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NameEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayMeta = const VerificationMeta(
    'display',
  );
  @override
  late final GeneratedColumn<String> display = GeneratedColumn<String>(
    'display',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variantsMeta = const VerificationMeta(
    'variants',
  );
  @override
  late final GeneratedColumn<String> variants = GeneratedColumn<String>(
    'variants',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    display,
    gender,
    variants,
    isCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'name_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<NameEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display')) {
      context.handle(
        _displayMeta,
        display.isAcceptableOrUnknown(data['display']!, _displayMeta),
      );
    } else if (isInserting) {
      context.missing(_displayMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('variants')) {
      context.handle(
        _variantsMeta,
        variants.isAcceptableOrUnknown(data['variants']!, _variantsMeta),
      );
    } else if (isInserting) {
      context.missing(_variantsMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NameEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NameEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      display: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      variants: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variants'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $NameEntriesTable createAlias(String alias) {
    return $NameEntriesTable(attachedDatabase, alias);
  }
}

class NameEntryRow extends DataClass implements Insertable<NameEntryRow> {
  final String id;
  final String display;
  final String gender;
  final String variants;
  final bool isCustom;
  const NameEntryRow({
    required this.id,
    required this.display,
    required this.gender,
    required this.variants,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display'] = Variable<String>(display);
    map['gender'] = Variable<String>(gender);
    map['variants'] = Variable<String>(variants);
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  NameEntriesCompanion toCompanion(bool nullToAbsent) {
    return NameEntriesCompanion(
      id: Value(id),
      display: Value(display),
      gender: Value(gender),
      variants: Value(variants),
      isCustom: Value(isCustom),
    );
  }

  factory NameEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NameEntryRow(
      id: serializer.fromJson<String>(json['id']),
      display: serializer.fromJson<String>(json['display']),
      gender: serializer.fromJson<String>(json['gender']),
      variants: serializer.fromJson<String>(json['variants']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'display': serializer.toJson<String>(display),
      'gender': serializer.toJson<String>(gender),
      'variants': serializer.toJson<String>(variants),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  NameEntryRow copyWith({
    String? id,
    String? display,
    String? gender,
    String? variants,
    bool? isCustom,
  }) => NameEntryRow(
    id: id ?? this.id,
    display: display ?? this.display,
    gender: gender ?? this.gender,
    variants: variants ?? this.variants,
    isCustom: isCustom ?? this.isCustom,
  );
  NameEntryRow copyWithCompanion(NameEntriesCompanion data) {
    return NameEntryRow(
      id: data.id.present ? data.id.value : this.id,
      display: data.display.present ? data.display.value : this.display,
      gender: data.gender.present ? data.gender.value : this.gender,
      variants: data.variants.present ? data.variants.value : this.variants,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NameEntryRow(')
          ..write('id: $id, ')
          ..write('display: $display, ')
          ..write('gender: $gender, ')
          ..write('variants: $variants, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, display, gender, variants, isCustom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NameEntryRow &&
          other.id == this.id &&
          other.display == this.display &&
          other.gender == this.gender &&
          other.variants == this.variants &&
          other.isCustom == this.isCustom);
}

class NameEntriesCompanion extends UpdateCompanion<NameEntryRow> {
  final Value<String> id;
  final Value<String> display;
  final Value<String> gender;
  final Value<String> variants;
  final Value<bool> isCustom;
  final Value<int> rowid;
  const NameEntriesCompanion({
    this.id = const Value.absent(),
    this.display = const Value.absent(),
    this.gender = const Value.absent(),
    this.variants = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NameEntriesCompanion.insert({
    required String id,
    required String display,
    required String gender,
    required String variants,
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       display = Value(display),
       gender = Value(gender),
       variants = Value(variants);
  static Insertable<NameEntryRow> custom({
    Expression<String>? id,
    Expression<String>? display,
    Expression<String>? gender,
    Expression<String>? variants,
    Expression<bool>? isCustom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (display != null) 'display': display,
      if (gender != null) 'gender': gender,
      if (variants != null) 'variants': variants,
      if (isCustom != null) 'is_custom': isCustom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NameEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? display,
    Value<String>? gender,
    Value<String>? variants,
    Value<bool>? isCustom,
    Value<int>? rowid,
  }) {
    return NameEntriesCompanion(
      id: id ?? this.id,
      display: display ?? this.display,
      gender: gender ?? this.gender,
      variants: variants ?? this.variants,
      isCustom: isCustom ?? this.isCustom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (display.present) {
      map['display'] = Variable<String>(display.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (variants.present) {
      map['variants'] = Variable<String>(variants.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NameEntriesCompanion(')
          ..write('id: $id, ')
          ..write('display: $display, ')
          ..write('gender: $gender, ')
          ..write('variants: $variants, ')
          ..write('isCustom: $isCustom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _participantLabelMeta = const VerificationMeta(
    'participantLabel',
  );
  @override
  late final GeneratedColumn<String> participantLabel = GeneratedColumn<String>(
    'participant_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _poolIdsMeta = const VerificationMeta(
    'poolIds',
  );
  @override
  late final GeneratedColumn<String> poolIds = GeneratedColumn<String>(
    'pool_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderFilterMeta = const VerificationMeta(
    'genderFilter',
  );
  @override
  late final GeneratedColumn<String> genderFilter = GeneratedColumn<String>(
    'gender_filter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poolSizeMeta = const VerificationMeta(
    'poolSize',
  );
  @override
  late final GeneratedColumn<int> poolSize = GeneratedColumn<int>(
    'pool_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _resultsLockedMeta = const VerificationMeta(
    'resultsLocked',
  );
  @override
  late final GeneratedColumn<bool> resultsLocked = GeneratedColumn<bool>(
    'results_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("results_locked" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    participantLabel,
    poolIds,
    genderFilter,
    poolSize,
    isComplete,
    resultsLocked,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('participant_label')) {
      context.handle(
        _participantLabelMeta,
        participantLabel.isAcceptableOrUnknown(
          data['participant_label']!,
          _participantLabelMeta,
        ),
      );
    }
    if (data.containsKey('pool_ids')) {
      context.handle(
        _poolIdsMeta,
        poolIds.isAcceptableOrUnknown(data['pool_ids']!, _poolIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_poolIdsMeta);
    }
    if (data.containsKey('gender_filter')) {
      context.handle(
        _genderFilterMeta,
        genderFilter.isAcceptableOrUnknown(
          data['gender_filter']!,
          _genderFilterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_genderFilterMeta);
    }
    if (data.containsKey('pool_size')) {
      context.handle(
        _poolSizeMeta,
        poolSize.isAcceptableOrUnknown(data['pool_size']!, _poolSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_poolSizeMeta);
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    if (data.containsKey('results_locked')) {
      context.handle(
        _resultsLockedMeta,
        resultsLocked.isAcceptableOrUnknown(
          data['results_locked']!,
          _resultsLockedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      participantLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}participant_label'],
      ),
      poolIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pool_ids'],
      )!,
      genderFilter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender_filter'],
      )!,
      poolSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pool_size'],
      )!,
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
      resultsLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}results_locked'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String? participantLabel;
  final String poolIds;
  final String genderFilter;
  final int poolSize;
  final bool isComplete;

  /// When true, results screen requires partner to also be complete before showing.
  /// Default true = peeking prevention on.
  final bool resultsLocked;
  final DateTime createdAt;
  final DateTime? completedAt;
  const SessionRow({
    required this.id,
    this.participantLabel,
    required this.poolIds,
    required this.genderFilter,
    required this.poolSize,
    required this.isComplete,
    required this.resultsLocked,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || participantLabel != null) {
      map['participant_label'] = Variable<String>(participantLabel);
    }
    map['pool_ids'] = Variable<String>(poolIds);
    map['gender_filter'] = Variable<String>(genderFilter);
    map['pool_size'] = Variable<int>(poolSize);
    map['is_complete'] = Variable<bool>(isComplete);
    map['results_locked'] = Variable<bool>(resultsLocked);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      participantLabel: participantLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(participantLabel),
      poolIds: Value(poolIds),
      genderFilter: Value(genderFilter),
      poolSize: Value(poolSize),
      isComplete: Value(isComplete),
      resultsLocked: Value(resultsLocked),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      participantLabel: serializer.fromJson<String?>(json['participantLabel']),
      poolIds: serializer.fromJson<String>(json['poolIds']),
      genderFilter: serializer.fromJson<String>(json['genderFilter']),
      poolSize: serializer.fromJson<int>(json['poolSize']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
      resultsLocked: serializer.fromJson<bool>(json['resultsLocked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'participantLabel': serializer.toJson<String?>(participantLabel),
      'poolIds': serializer.toJson<String>(poolIds),
      'genderFilter': serializer.toJson<String>(genderFilter),
      'poolSize': serializer.toJson<int>(poolSize),
      'isComplete': serializer.toJson<bool>(isComplete),
      'resultsLocked': serializer.toJson<bool>(resultsLocked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  SessionRow copyWith({
    String? id,
    Value<String?> participantLabel = const Value.absent(),
    String? poolIds,
    String? genderFilter,
    int? poolSize,
    bool? isComplete,
    bool? resultsLocked,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => SessionRow(
    id: id ?? this.id,
    participantLabel: participantLabel.present
        ? participantLabel.value
        : this.participantLabel,
    poolIds: poolIds ?? this.poolIds,
    genderFilter: genderFilter ?? this.genderFilter,
    poolSize: poolSize ?? this.poolSize,
    isComplete: isComplete ?? this.isComplete,
    resultsLocked: resultsLocked ?? this.resultsLocked,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      participantLabel: data.participantLabel.present
          ? data.participantLabel.value
          : this.participantLabel,
      poolIds: data.poolIds.present ? data.poolIds.value : this.poolIds,
      genderFilter: data.genderFilter.present
          ? data.genderFilter.value
          : this.genderFilter,
      poolSize: data.poolSize.present ? data.poolSize.value : this.poolSize,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
      resultsLocked: data.resultsLocked.present
          ? data.resultsLocked.value
          : this.resultsLocked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('participantLabel: $participantLabel, ')
          ..write('poolIds: $poolIds, ')
          ..write('genderFilter: $genderFilter, ')
          ..write('poolSize: $poolSize, ')
          ..write('isComplete: $isComplete, ')
          ..write('resultsLocked: $resultsLocked, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    participantLabel,
    poolIds,
    genderFilter,
    poolSize,
    isComplete,
    resultsLocked,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.participantLabel == this.participantLabel &&
          other.poolIds == this.poolIds &&
          other.genderFilter == this.genderFilter &&
          other.poolSize == this.poolSize &&
          other.isComplete == this.isComplete &&
          other.resultsLocked == this.resultsLocked &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String?> participantLabel;
  final Value<String> poolIds;
  final Value<String> genderFilter;
  final Value<int> poolSize;
  final Value<bool> isComplete;
  final Value<bool> resultsLocked;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.participantLabel = const Value.absent(),
    this.poolIds = const Value.absent(),
    this.genderFilter = const Value.absent(),
    this.poolSize = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.resultsLocked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    this.participantLabel = const Value.absent(),
    required String poolIds,
    required String genderFilter,
    required int poolSize,
    this.isComplete = const Value.absent(),
    this.resultsLocked = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       poolIds = Value(poolIds),
       genderFilter = Value(genderFilter),
       poolSize = Value(poolSize),
       createdAt = Value(createdAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? participantLabel,
    Expression<String>? poolIds,
    Expression<String>? genderFilter,
    Expression<int>? poolSize,
    Expression<bool>? isComplete,
    Expression<bool>? resultsLocked,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (participantLabel != null) 'participant_label': participantLabel,
      if (poolIds != null) 'pool_ids': poolIds,
      if (genderFilter != null) 'gender_filter': genderFilter,
      if (poolSize != null) 'pool_size': poolSize,
      if (isComplete != null) 'is_complete': isComplete,
      if (resultsLocked != null) 'results_locked': resultsLocked,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? participantLabel,
    Value<String>? poolIds,
    Value<String>? genderFilter,
    Value<int>? poolSize,
    Value<bool>? isComplete,
    Value<bool>? resultsLocked,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      participantLabel: participantLabel ?? this.participantLabel,
      poolIds: poolIds ?? this.poolIds,
      genderFilter: genderFilter ?? this.genderFilter,
      poolSize: poolSize ?? this.poolSize,
      isComplete: isComplete ?? this.isComplete,
      resultsLocked: resultsLocked ?? this.resultsLocked,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (participantLabel.present) {
      map['participant_label'] = Variable<String>(participantLabel.value);
    }
    if (poolIds.present) {
      map['pool_ids'] = Variable<String>(poolIds.value);
    }
    if (genderFilter.present) {
      map['gender_filter'] = Variable<String>(genderFilter.value);
    }
    if (poolSize.present) {
      map['pool_size'] = Variable<int>(poolSize.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (resultsLocked.present) {
      map['results_locked'] = Variable<bool>(resultsLocked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('participantLabel: $participantLabel, ')
          ..write('poolIds: $poolIds, ')
          ..write('genderFilter: $genderFilter, ')
          ..write('poolSize: $poolSize, ')
          ..write('isComplete: $isComplete, ')
          ..write('resultsLocked: $resultsLocked, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EloMatchRowsTable extends EloMatchRows
    with TableInfo<$EloMatchRowsTable, EloMatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EloMatchRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameIdAMeta = const VerificationMeta(
    'nameIdA',
  );
  @override
  late final GeneratedColumn<String> nameIdA = GeneratedColumn<String>(
    'name_id_a',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameIdBMeta = const VerificationMeta(
    'nameIdB',
  );
  @override
  late final GeneratedColumn<String> nameIdB = GeneratedColumn<String>(
    'name_id_b',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchedAtMeta = const VerificationMeta(
    'matchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> matchedAt = GeneratedColumn<DateTime>(
    'matched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    nameIdA,
    nameIdB,
    outcome,
    matchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'elo_match_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<EloMatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('name_id_a')) {
      context.handle(
        _nameIdAMeta,
        nameIdA.isAcceptableOrUnknown(data['name_id_a']!, _nameIdAMeta),
      );
    } else if (isInserting) {
      context.missing(_nameIdAMeta);
    }
    if (data.containsKey('name_id_b')) {
      context.handle(
        _nameIdBMeta,
        nameIdB.isAcceptableOrUnknown(data['name_id_b']!, _nameIdBMeta),
      );
    } else if (isInserting) {
      context.missing(_nameIdBMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('matched_at')) {
      context.handle(
        _matchedAtMeta,
        matchedAt.isAcceptableOrUnknown(data['matched_at']!, _matchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_matchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EloMatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EloMatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      nameIdA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_id_a'],
      )!,
      nameIdB: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_id_b'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      matchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}matched_at'],
      )!,
    );
  }

  @override
  $EloMatchRowsTable createAlias(String alias) {
    return $EloMatchRowsTable(attachedDatabase, alias);
  }
}

class EloMatchRow extends DataClass implements Insertable<EloMatchRow> {
  final int id;
  final String sessionId;
  final String nameIdA;
  final String nameIdB;
  final String outcome;
  final DateTime matchedAt;
  const EloMatchRow({
    required this.id,
    required this.sessionId,
    required this.nameIdA,
    required this.nameIdB,
    required this.outcome,
    required this.matchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['name_id_a'] = Variable<String>(nameIdA);
    map['name_id_b'] = Variable<String>(nameIdB);
    map['outcome'] = Variable<String>(outcome);
    map['matched_at'] = Variable<DateTime>(matchedAt);
    return map;
  }

  EloMatchRowsCompanion toCompanion(bool nullToAbsent) {
    return EloMatchRowsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      nameIdA: Value(nameIdA),
      nameIdB: Value(nameIdB),
      outcome: Value(outcome),
      matchedAt: Value(matchedAt),
    );
  }

  factory EloMatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EloMatchRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      nameIdA: serializer.fromJson<String>(json['nameIdA']),
      nameIdB: serializer.fromJson<String>(json['nameIdB']),
      outcome: serializer.fromJson<String>(json['outcome']),
      matchedAt: serializer.fromJson<DateTime>(json['matchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'nameIdA': serializer.toJson<String>(nameIdA),
      'nameIdB': serializer.toJson<String>(nameIdB),
      'outcome': serializer.toJson<String>(outcome),
      'matchedAt': serializer.toJson<DateTime>(matchedAt),
    };
  }

  EloMatchRow copyWith({
    int? id,
    String? sessionId,
    String? nameIdA,
    String? nameIdB,
    String? outcome,
    DateTime? matchedAt,
  }) => EloMatchRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    nameIdA: nameIdA ?? this.nameIdA,
    nameIdB: nameIdB ?? this.nameIdB,
    outcome: outcome ?? this.outcome,
    matchedAt: matchedAt ?? this.matchedAt,
  );
  EloMatchRow copyWithCompanion(EloMatchRowsCompanion data) {
    return EloMatchRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      nameIdA: data.nameIdA.present ? data.nameIdA.value : this.nameIdA,
      nameIdB: data.nameIdB.present ? data.nameIdB.value : this.nameIdB,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      matchedAt: data.matchedAt.present ? data.matchedAt.value : this.matchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EloMatchRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('nameIdA: $nameIdA, ')
          ..write('nameIdB: $nameIdB, ')
          ..write('outcome: $outcome, ')
          ..write('matchedAt: $matchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, nameIdA, nameIdB, outcome, matchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EloMatchRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.nameIdA == this.nameIdA &&
          other.nameIdB == this.nameIdB &&
          other.outcome == this.outcome &&
          other.matchedAt == this.matchedAt);
}

class EloMatchRowsCompanion extends UpdateCompanion<EloMatchRow> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<String> nameIdA;
  final Value<String> nameIdB;
  final Value<String> outcome;
  final Value<DateTime> matchedAt;
  const EloMatchRowsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.nameIdA = const Value.absent(),
    this.nameIdB = const Value.absent(),
    this.outcome = const Value.absent(),
    this.matchedAt = const Value.absent(),
  });
  EloMatchRowsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required String nameIdA,
    required String nameIdB,
    required String outcome,
    required DateTime matchedAt,
  }) : sessionId = Value(sessionId),
       nameIdA = Value(nameIdA),
       nameIdB = Value(nameIdB),
       outcome = Value(outcome),
       matchedAt = Value(matchedAt);
  static Insertable<EloMatchRow> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<String>? nameIdA,
    Expression<String>? nameIdB,
    Expression<String>? outcome,
    Expression<DateTime>? matchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (nameIdA != null) 'name_id_a': nameIdA,
      if (nameIdB != null) 'name_id_b': nameIdB,
      if (outcome != null) 'outcome': outcome,
      if (matchedAt != null) 'matched_at': matchedAt,
    });
  }

  EloMatchRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<String>? nameIdA,
    Value<String>? nameIdB,
    Value<String>? outcome,
    Value<DateTime>? matchedAt,
  }) {
    return EloMatchRowsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      nameIdA: nameIdA ?? this.nameIdA,
      nameIdB: nameIdB ?? this.nameIdB,
      outcome: outcome ?? this.outcome,
      matchedAt: matchedAt ?? this.matchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (nameIdA.present) {
      map['name_id_a'] = Variable<String>(nameIdA.value);
    }
    if (nameIdB.present) {
      map['name_id_b'] = Variable<String>(nameIdB.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (matchedAt.present) {
      map['matched_at'] = Variable<DateTime>(matchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EloMatchRowsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('nameIdA: $nameIdA, ')
          ..write('nameIdB: $nameIdB, ')
          ..write('outcome: $outcome, ')
          ..write('matchedAt: $matchedAt')
          ..write(')'))
        .toString();
  }
}

class $ShortlistEntriesTable extends ShortlistEntries
    with TableInfo<$ShortlistEntriesTable, ShortlistEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShortlistEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameIdMeta = const VerificationMeta('nameId');
  @override
  late final GeneratedColumn<String> nameId = GeneratedColumn<String>(
    'name_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES name_entries (id)',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nameId, note, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shortlist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShortlistEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_id')) {
      context.handle(
        _nameIdMeta,
        nameId.isAcceptableOrUnknown(data['name_id']!, _nameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nameIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShortlistEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShortlistEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $ShortlistEntriesTable createAlias(String alias) {
    return $ShortlistEntriesTable(attachedDatabase, alias);
  }
}

class ShortlistEntryRow extends DataClass
    implements Insertable<ShortlistEntryRow> {
  final String id;
  final String nameId;
  final String? note;
  final DateTime addedAt;
  const ShortlistEntryRow({
    required this.id,
    required this.nameId,
    this.note,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_id'] = Variable<String>(nameId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  ShortlistEntriesCompanion toCompanion(bool nullToAbsent) {
    return ShortlistEntriesCompanion(
      id: Value(id),
      nameId: Value(nameId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      addedAt: Value(addedAt),
    );
  }

  factory ShortlistEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShortlistEntryRow(
      id: serializer.fromJson<String>(json['id']),
      nameId: serializer.fromJson<String>(json['nameId']),
      note: serializer.fromJson<String?>(json['note']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameId': serializer.toJson<String>(nameId),
      'note': serializer.toJson<String?>(note),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  ShortlistEntryRow copyWith({
    String? id,
    String? nameId,
    Value<String?> note = const Value.absent(),
    DateTime? addedAt,
  }) => ShortlistEntryRow(
    id: id ?? this.id,
    nameId: nameId ?? this.nameId,
    note: note.present ? note.value : this.note,
    addedAt: addedAt ?? this.addedAt,
  );
  ShortlistEntryRow copyWithCompanion(ShortlistEntriesCompanion data) {
    return ShortlistEntryRow(
      id: data.id.present ? data.id.value : this.id,
      nameId: data.nameId.present ? data.nameId.value : this.nameId,
      note: data.note.present ? data.note.value : this.note,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShortlistEntryRow(')
          ..write('id: $id, ')
          ..write('nameId: $nameId, ')
          ..write('note: $note, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nameId, note, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShortlistEntryRow &&
          other.id == this.id &&
          other.nameId == this.nameId &&
          other.note == this.note &&
          other.addedAt == this.addedAt);
}

class ShortlistEntriesCompanion extends UpdateCompanion<ShortlistEntryRow> {
  final Value<String> id;
  final Value<String> nameId;
  final Value<String?> note;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const ShortlistEntriesCompanion({
    this.id = const Value.absent(),
    this.nameId = const Value.absent(),
    this.note = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShortlistEntriesCompanion.insert({
    required String id,
    required String nameId,
    this.note = const Value.absent(),
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nameId = Value(nameId),
       addedAt = Value(addedAt);
  static Insertable<ShortlistEntryRow> custom({
    Expression<String>? id,
    Expression<String>? nameId,
    Expression<String>? note,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameId != null) 'name_id': nameId,
      if (note != null) 'note': note,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShortlistEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? nameId,
    Value<String?>? note,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return ShortlistEntriesCompanion(
      id: id ?? this.id,
      nameId: nameId ?? this.nameId,
      note: note ?? this.note,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameId.present) {
      map['name_id'] = Variable<String>(nameId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShortlistEntriesCompanion(')
          ..write('id: $id, ')
          ..write('nameId: $nameId, ')
          ..write('note: $note, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NameEntriesTable nameEntries = $NameEntriesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $EloMatchRowsTable eloMatchRows = $EloMatchRowsTable(this);
  late final $ShortlistEntriesTable shortlistEntries = $ShortlistEntriesTable(
    this,
  );
  late final NamesDao namesDao = NamesDao(this as AppDatabase);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  late final EloMatchesDao eloMatchesDao = EloMatchesDao(this as AppDatabase);
  late final ShortlistDao shortlistDao = ShortlistDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    nameEntries,
    sessions,
    eloMatchRows,
    shortlistEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('elo_match_rows', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$NameEntriesTableCreateCompanionBuilder =
    NameEntriesCompanion Function({
      required String id,
      required String display,
      required String gender,
      required String variants,
      Value<bool> isCustom,
      Value<int> rowid,
    });
typedef $$NameEntriesTableUpdateCompanionBuilder =
    NameEntriesCompanion Function({
      Value<String> id,
      Value<String> display,
      Value<String> gender,
      Value<String> variants,
      Value<bool> isCustom,
      Value<int> rowid,
    });

final class $$NameEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $NameEntriesTable, NameEntryRow> {
  $$NameEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShortlistEntriesTable, List<ShortlistEntryRow>>
  _shortlistEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shortlistEntries,
    aliasName: $_aliasNameGenerator(
      db.nameEntries.id,
      db.shortlistEntries.nameId,
    ),
  );

  $$ShortlistEntriesTableProcessedTableManager get shortlistEntriesRefs {
    final manager = $$ShortlistEntriesTableTableManager(
      $_db,
      $_db.shortlistEntries,
    ).filter((f) => f.nameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _shortlistEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NameEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $NameEntriesTable> {
  $$NameEntriesTableFilterComposer({
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

  ColumnFilters<String> get display => $composableBuilder(
    column: $table.display,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variants => $composableBuilder(
    column: $table.variants,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shortlistEntriesRefs(
    Expression<bool> Function($$ShortlistEntriesTableFilterComposer f) f,
  ) {
    final $$ShortlistEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shortlistEntries,
      getReferencedColumn: (t) => t.nameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShortlistEntriesTableFilterComposer(
            $db: $db,
            $table: $db.shortlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NameEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $NameEntriesTable> {
  $$NameEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get display => $composableBuilder(
    column: $table.display,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variants => $composableBuilder(
    column: $table.variants,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NameEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NameEntriesTable> {
  $$NameEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get display =>
      $composableBuilder(column: $table.display, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get variants =>
      $composableBuilder(column: $table.variants, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  Expression<T> shortlistEntriesRefs<T extends Object>(
    Expression<T> Function($$ShortlistEntriesTableAnnotationComposer a) f,
  ) {
    final $$ShortlistEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shortlistEntries,
      getReferencedColumn: (t) => t.nameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShortlistEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.shortlistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NameEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NameEntriesTable,
          NameEntryRow,
          $$NameEntriesTableFilterComposer,
          $$NameEntriesTableOrderingComposer,
          $$NameEntriesTableAnnotationComposer,
          $$NameEntriesTableCreateCompanionBuilder,
          $$NameEntriesTableUpdateCompanionBuilder,
          (NameEntryRow, $$NameEntriesTableReferences),
          NameEntryRow,
          PrefetchHooks Function({bool shortlistEntriesRefs})
        > {
  $$NameEntriesTableTableManager(_$AppDatabase db, $NameEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NameEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NameEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NameEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> display = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> variants = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NameEntriesCompanion(
                id: id,
                display: display,
                gender: gender,
                variants: variants,
                isCustom: isCustom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String display,
                required String gender,
                required String variants,
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NameEntriesCompanion.insert(
                id: id,
                display: display,
                gender: gender,
                variants: variants,
                isCustom: isCustom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NameEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shortlistEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (shortlistEntriesRefs) db.shortlistEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shortlistEntriesRefs)
                    await $_getPrefetchedData<
                      NameEntryRow,
                      $NameEntriesTable,
                      ShortlistEntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$NameEntriesTableReferences
                          ._shortlistEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NameEntriesTableReferences(
                            db,
                            table,
                            p0,
                          ).shortlistEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.nameId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NameEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NameEntriesTable,
      NameEntryRow,
      $$NameEntriesTableFilterComposer,
      $$NameEntriesTableOrderingComposer,
      $$NameEntriesTableAnnotationComposer,
      $$NameEntriesTableCreateCompanionBuilder,
      $$NameEntriesTableUpdateCompanionBuilder,
      (NameEntryRow, $$NameEntriesTableReferences),
      NameEntryRow,
      PrefetchHooks Function({bool shortlistEntriesRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      Value<String?> participantLabel,
      required String poolIds,
      required String genderFilter,
      required int poolSize,
      Value<bool> isComplete,
      Value<bool> resultsLocked,
      required DateTime createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String?> participantLabel,
      Value<String> poolIds,
      Value<String> genderFilter,
      Value<int> poolSize,
      Value<bool> isComplete,
      Value<bool> resultsLocked,
      Value<DateTime> createdAt,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EloMatchRowsTable, List<EloMatchRow>>
  _eloMatchRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eloMatchRows,
    aliasName: $_aliasNameGenerator(db.sessions.id, db.eloMatchRows.sessionId),
  );

  $$EloMatchRowsTableProcessedTableManager get eloMatchRowsRefs {
    final manager = $$EloMatchRowsTableTableManager(
      $_db,
      $_db.eloMatchRows,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eloMatchRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get participantLabel => $composableBuilder(
    column: $table.participantLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poolIds => $composableBuilder(
    column: $table.poolIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genderFilter => $composableBuilder(
    column: $table.genderFilter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get poolSize => $composableBuilder(
    column: $table.poolSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resultsLocked => $composableBuilder(
    column: $table.resultsLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> eloMatchRowsRefs(
    Expression<bool> Function($$EloMatchRowsTableFilterComposer f) f,
  ) {
    final $$EloMatchRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eloMatchRows,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EloMatchRowsTableFilterComposer(
            $db: $db,
            $table: $db.eloMatchRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get participantLabel => $composableBuilder(
    column: $table.participantLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poolIds => $composableBuilder(
    column: $table.poolIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genderFilter => $composableBuilder(
    column: $table.genderFilter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get poolSize => $composableBuilder(
    column: $table.poolSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resultsLocked => $composableBuilder(
    column: $table.resultsLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get participantLabel => $composableBuilder(
    column: $table.participantLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get poolIds =>
      $composableBuilder(column: $table.poolIds, builder: (column) => column);

  GeneratedColumn<String> get genderFilter => $composableBuilder(
    column: $table.genderFilter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get poolSize =>
      $composableBuilder(column: $table.poolSize, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get resultsLocked => $composableBuilder(
    column: $table.resultsLocked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  Expression<T> eloMatchRowsRefs<T extends Object>(
    Expression<T> Function($$EloMatchRowsTableAnnotationComposer a) f,
  ) {
    final $$EloMatchRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eloMatchRows,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EloMatchRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.eloMatchRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({bool eloMatchRowsRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> participantLabel = const Value.absent(),
                Value<String> poolIds = const Value.absent(),
                Value<String> genderFilter = const Value.absent(),
                Value<int> poolSize = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<bool> resultsLocked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                participantLabel: participantLabel,
                poolIds: poolIds,
                genderFilter: genderFilter,
                poolSize: poolSize,
                isComplete: isComplete,
                resultsLocked: resultsLocked,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> participantLabel = const Value.absent(),
                required String poolIds,
                required String genderFilter,
                required int poolSize,
                Value<bool> isComplete = const Value.absent(),
                Value<bool> resultsLocked = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                participantLabel: participantLabel,
                poolIds: poolIds,
                genderFilter: genderFilter,
                poolSize: poolSize,
                isComplete: isComplete,
                resultsLocked: resultsLocked,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({eloMatchRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (eloMatchRowsRefs) db.eloMatchRows],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eloMatchRowsRefs)
                    await $_getPrefetchedData<
                      SessionRow,
                      $SessionsTable,
                      EloMatchRow
                    >(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._eloMatchRowsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SessionsTableReferences(
                        db,
                        table,
                        p0,
                      ).eloMatchRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({bool eloMatchRowsRefs})
    >;
typedef $$EloMatchRowsTableCreateCompanionBuilder =
    EloMatchRowsCompanion Function({
      Value<int> id,
      required String sessionId,
      required String nameIdA,
      required String nameIdB,
      required String outcome,
      required DateTime matchedAt,
    });
typedef $$EloMatchRowsTableUpdateCompanionBuilder =
    EloMatchRowsCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<String> nameIdA,
      Value<String> nameIdB,
      Value<String> outcome,
      Value<DateTime> matchedAt,
    });

final class $$EloMatchRowsTableReferences
    extends BaseReferences<_$AppDatabase, $EloMatchRowsTable, EloMatchRow> {
  $$EloMatchRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.eloMatchRows.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EloMatchRowsTableFilterComposer
    extends Composer<_$AppDatabase, $EloMatchRowsTable> {
  $$EloMatchRowsTableFilterComposer({
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

  ColumnFilters<String> get nameIdA => $composableBuilder(
    column: $table.nameIdA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameIdB => $composableBuilder(
    column: $table.nameIdB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get matchedAt => $composableBuilder(
    column: $table.matchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EloMatchRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $EloMatchRowsTable> {
  $$EloMatchRowsTableOrderingComposer({
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

  ColumnOrderings<String> get nameIdA => $composableBuilder(
    column: $table.nameIdA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameIdB => $composableBuilder(
    column: $table.nameIdB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get matchedAt => $composableBuilder(
    column: $table.matchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EloMatchRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EloMatchRowsTable> {
  $$EloMatchRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameIdA =>
      $composableBuilder(column: $table.nameIdA, builder: (column) => column);

  GeneratedColumn<String> get nameIdB =>
      $composableBuilder(column: $table.nameIdB, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<DateTime> get matchedAt =>
      $composableBuilder(column: $table.matchedAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EloMatchRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EloMatchRowsTable,
          EloMatchRow,
          $$EloMatchRowsTableFilterComposer,
          $$EloMatchRowsTableOrderingComposer,
          $$EloMatchRowsTableAnnotationComposer,
          $$EloMatchRowsTableCreateCompanionBuilder,
          $$EloMatchRowsTableUpdateCompanionBuilder,
          (EloMatchRow, $$EloMatchRowsTableReferences),
          EloMatchRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$EloMatchRowsTableTableManager(_$AppDatabase db, $EloMatchRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EloMatchRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EloMatchRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EloMatchRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> nameIdA = const Value.absent(),
                Value<String> nameIdB = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<DateTime> matchedAt = const Value.absent(),
              }) => EloMatchRowsCompanion(
                id: id,
                sessionId: sessionId,
                nameIdA: nameIdA,
                nameIdB: nameIdB,
                outcome: outcome,
                matchedAt: matchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required String nameIdA,
                required String nameIdB,
                required String outcome,
                required DateTime matchedAt,
              }) => EloMatchRowsCompanion.insert(
                id: id,
                sessionId: sessionId,
                nameIdA: nameIdA,
                nameIdB: nameIdB,
                outcome: outcome,
                matchedAt: matchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EloMatchRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
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
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$EloMatchRowsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$EloMatchRowsTableReferences
                                    ._sessionIdTable(db)
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

typedef $$EloMatchRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EloMatchRowsTable,
      EloMatchRow,
      $$EloMatchRowsTableFilterComposer,
      $$EloMatchRowsTableOrderingComposer,
      $$EloMatchRowsTableAnnotationComposer,
      $$EloMatchRowsTableCreateCompanionBuilder,
      $$EloMatchRowsTableUpdateCompanionBuilder,
      (EloMatchRow, $$EloMatchRowsTableReferences),
      EloMatchRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ShortlistEntriesTableCreateCompanionBuilder =
    ShortlistEntriesCompanion Function({
      required String id,
      required String nameId,
      Value<String?> note,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$ShortlistEntriesTableUpdateCompanionBuilder =
    ShortlistEntriesCompanion Function({
      Value<String> id,
      Value<String> nameId,
      Value<String?> note,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$ShortlistEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ShortlistEntriesTable,
          ShortlistEntryRow
        > {
  $$ShortlistEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NameEntriesTable _nameIdTable(_$AppDatabase db) =>
      db.nameEntries.createAlias(
        $_aliasNameGenerator(db.shortlistEntries.nameId, db.nameEntries.id),
      );

  $$NameEntriesTableProcessedTableManager get nameId {
    final $_column = $_itemColumn<String>('name_id')!;

    final manager = $$NameEntriesTableTableManager(
      $_db,
      $_db.nameEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_nameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShortlistEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ShortlistEntriesTable> {
  $$ShortlistEntriesTableFilterComposer({
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

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NameEntriesTableFilterComposer get nameId {
    final $$NameEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nameId,
      referencedTable: $db.nameEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NameEntriesTableFilterComposer(
            $db: $db,
            $table: $db.nameEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShortlistEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShortlistEntriesTable> {
  $$ShortlistEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NameEntriesTableOrderingComposer get nameId {
    final $$NameEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nameId,
      referencedTable: $db.nameEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NameEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.nameEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShortlistEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShortlistEntriesTable> {
  $$ShortlistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$NameEntriesTableAnnotationComposer get nameId {
    final $$NameEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nameId,
      referencedTable: $db.nameEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NameEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.nameEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShortlistEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShortlistEntriesTable,
          ShortlistEntryRow,
          $$ShortlistEntriesTableFilterComposer,
          $$ShortlistEntriesTableOrderingComposer,
          $$ShortlistEntriesTableAnnotationComposer,
          $$ShortlistEntriesTableCreateCompanionBuilder,
          $$ShortlistEntriesTableUpdateCompanionBuilder,
          (ShortlistEntryRow, $$ShortlistEntriesTableReferences),
          ShortlistEntryRow,
          PrefetchHooks Function({bool nameId})
        > {
  $$ShortlistEntriesTableTableManager(
    _$AppDatabase db,
    $ShortlistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShortlistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShortlistEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShortlistEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nameId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShortlistEntriesCompanion(
                id: id,
                nameId: nameId,
                note: note,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nameId,
                Value<String?> note = const Value.absent(),
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShortlistEntriesCompanion.insert(
                id: id,
                nameId: nameId,
                note: note,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShortlistEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({nameId = false}) {
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
                    if (nameId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.nameId,
                                referencedTable:
                                    $$ShortlistEntriesTableReferences
                                        ._nameIdTable(db),
                                referencedColumn:
                                    $$ShortlistEntriesTableReferences
                                        ._nameIdTable(db)
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

typedef $$ShortlistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShortlistEntriesTable,
      ShortlistEntryRow,
      $$ShortlistEntriesTableFilterComposer,
      $$ShortlistEntriesTableOrderingComposer,
      $$ShortlistEntriesTableAnnotationComposer,
      $$ShortlistEntriesTableCreateCompanionBuilder,
      $$ShortlistEntriesTableUpdateCompanionBuilder,
      (ShortlistEntryRow, $$ShortlistEntriesTableReferences),
      ShortlistEntryRow,
      PrefetchHooks Function({bool nameId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NameEntriesTableTableManager get nameEntries =>
      $$NameEntriesTableTableManager(_db, _db.nameEntries);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$EloMatchRowsTableTableManager get eloMatchRows =>
      $$EloMatchRowsTableTableManager(_db, _db.eloMatchRows);
  $$ShortlistEntriesTableTableManager get shortlistEntries =>
      $$ShortlistEntriesTableTableManager(_db, _db.shortlistEntries);
}
