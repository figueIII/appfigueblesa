// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class Official extends Table with TableInfo<Official, OfficialData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Official(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _federationLicenceMeta = const VerificationMeta(
    'federationLicence',
  );
  late final GeneratedColumn<String> federationLicence =
      GeneratedColumn<String>(
        'federation_licence',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _homeSocietyMeta = const VerificationMeta(
    'homeSociety',
  );
  late final GeneratedColumn<String> homeSociety = GeneratedColumn<String>(
    'home_society',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    federationLicence,
    grade,
    homeSociety,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'official';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfficialData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('federation_licence')) {
      context.handle(
        _federationLicenceMeta,
        federationLicence.isAcceptableOrUnknown(
          data['federation_licence']!,
          _federationLicenceMeta,
        ),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('home_society')) {
      context.handle(
        _homeSocietyMeta,
        homeSociety.isAcceptableOrUnknown(
          data['home_society']!,
          _homeSocietyMeta,
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
  OfficialData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfficialData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      federationLicence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}federation_licence'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      ),
      homeSociety: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_society'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Official createAlias(String alias) {
    return Official(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class OfficialData extends DataClass implements Insertable<OfficialData> {
  final String id;
  final String fullName;
  final String? federationLicence;
  final String? grade;
  final String? homeSociety;
  final String createdAt;
  final String updatedAt;
  const OfficialData({
    required this.id,
    required this.fullName,
    this.federationLicence,
    this.grade,
    this.homeSociety,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || federationLicence != null) {
      map['federation_licence'] = Variable<String>(federationLicence);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(grade);
    }
    if (!nullToAbsent || homeSociety != null) {
      map['home_society'] = Variable<String>(homeSociety);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  OfficialCompanion toCompanion(bool nullToAbsent) {
    return OfficialCompanion(
      id: Value(id),
      fullName: Value(fullName),
      federationLicence: federationLicence == null && nullToAbsent
          ? const Value.absent()
          : Value(federationLicence),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      homeSociety: homeSociety == null && nullToAbsent
          ? const Value.absent()
          : Value(homeSociety),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OfficialData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfficialData(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['full_name']),
      federationLicence: serializer.fromJson<String?>(
        json['federation_licence'],
      ),
      grade: serializer.fromJson<String?>(json['grade']),
      homeSociety: serializer.fromJson<String?>(json['home_society']),
      createdAt: serializer.fromJson<String>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'full_name': serializer.toJson<String>(fullName),
      'federation_licence': serializer.toJson<String?>(federationLicence),
      'grade': serializer.toJson<String?>(grade),
      'home_society': serializer.toJson<String?>(homeSociety),
      'created_at': serializer.toJson<String>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
    };
  }

  OfficialData copyWith({
    String? id,
    String? fullName,
    Value<String?> federationLicence = const Value.absent(),
    Value<String?> grade = const Value.absent(),
    Value<String?> homeSociety = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => OfficialData(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    federationLicence: federationLicence.present
        ? federationLicence.value
        : this.federationLicence,
    grade: grade.present ? grade.value : this.grade,
    homeSociety: homeSociety.present ? homeSociety.value : this.homeSociety,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OfficialData copyWithCompanion(OfficialCompanion data) {
    return OfficialData(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      federationLicence: data.federationLicence.present
          ? data.federationLicence.value
          : this.federationLicence,
      grade: data.grade.present ? data.grade.value : this.grade,
      homeSociety: data.homeSociety.present
          ? data.homeSociety.value
          : this.homeSociety,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfficialData(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('federationLicence: $federationLicence, ')
          ..write('grade: $grade, ')
          ..write('homeSociety: $homeSociety, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    federationLicence,
    grade,
    homeSociety,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfficialData &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.federationLicence == this.federationLicence &&
          other.grade == this.grade &&
          other.homeSociety == this.homeSociety &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OfficialCompanion extends UpdateCompanion<OfficialData> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String?> federationLicence;
  final Value<String?> grade;
  final Value<String?> homeSociety;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const OfficialCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.federationLicence = const Value.absent(),
    this.grade = const Value.absent(),
    this.homeSociety = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfficialCompanion.insert({
    required String id,
    required String fullName,
    this.federationLicence = const Value.absent(),
    this.grade = const Value.absent(),
    this.homeSociety = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fullName = Value(fullName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OfficialData> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? federationLicence,
    Expression<String>? grade,
    Expression<String>? homeSociety,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (federationLicence != null) 'federation_licence': federationLicence,
      if (grade != null) 'grade': grade,
      if (homeSociety != null) 'home_society': homeSociety,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfficialCompanion copyWith({
    Value<String>? id,
    Value<String>? fullName,
    Value<String?>? federationLicence,
    Value<String?>? grade,
    Value<String?>? homeSociety,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return OfficialCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      federationLicence: federationLicence ?? this.federationLicence,
      grade: grade ?? this.grade,
      homeSociety: homeSociety ?? this.homeSociety,
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
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (federationLicence.present) {
      map['federation_licence'] = Variable<String>(federationLicence.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (homeSociety.present) {
      map['home_society'] = Variable<String>(homeSociety.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfficialCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('federationLicence: $federationLicence, ')
          ..write('grade: $grade, ')
          ..write('homeSociety: $homeSociety, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AssessorProfile extends Table
    with TableInfo<AssessorProfile, AssessorProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AssessorProfile(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _federationLicenceMeta = const VerificationMeta(
    'federationLicence',
  );
  late final GeneratedColumn<String> federationLicence =
      GeneratedColumn<String>(
        'federation_licence',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    federationLicence,
    email,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessor_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssessorProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('federation_licence')) {
      context.handle(
        _federationLicenceMeta,
        federationLicence.isAcceptableOrUnknown(
          data['federation_licence']!,
          _federationLicenceMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssessorProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessorProfileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      federationLicence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}federation_licence'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
    );
  }

  @override
  AssessorProfile createAlias(String alias) {
    return AssessorProfile(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class AssessorProfileData extends DataClass
    implements Insertable<AssessorProfileData> {
  final String id;
  final String fullName;
  final String? federationLicence;
  final String? email;
  const AssessorProfileData({
    required this.id,
    required this.fullName,
    this.federationLicence,
    this.email,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || federationLicence != null) {
      map['federation_licence'] = Variable<String>(federationLicence);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    return map;
  }

  AssessorProfileCompanion toCompanion(bool nullToAbsent) {
    return AssessorProfileCompanion(
      id: Value(id),
      fullName: Value(fullName),
      federationLicence: federationLicence == null && nullToAbsent
          ? const Value.absent()
          : Value(federationLicence),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
    );
  }

  factory AssessorProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessorProfileData(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['full_name']),
      federationLicence: serializer.fromJson<String?>(
        json['federation_licence'],
      ),
      email: serializer.fromJson<String?>(json['email']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'full_name': serializer.toJson<String>(fullName),
      'federation_licence': serializer.toJson<String?>(federationLicence),
      'email': serializer.toJson<String?>(email),
    };
  }

  AssessorProfileData copyWith({
    String? id,
    String? fullName,
    Value<String?> federationLicence = const Value.absent(),
    Value<String?> email = const Value.absent(),
  }) => AssessorProfileData(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    federationLicence: federationLicence.present
        ? federationLicence.value
        : this.federationLicence,
    email: email.present ? email.value : this.email,
  );
  AssessorProfileData copyWithCompanion(AssessorProfileCompanion data) {
    return AssessorProfileData(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      federationLicence: data.federationLicence.present
          ? data.federationLicence.value
          : this.federationLicence,
      email: data.email.present ? data.email.value : this.email,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessorProfileData(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('federationLicence: $federationLicence, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fullName, federationLicence, email);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessorProfileData &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.federationLicence == this.federationLicence &&
          other.email == this.email);
}

class AssessorProfileCompanion extends UpdateCompanion<AssessorProfileData> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String?> federationLicence;
  final Value<String?> email;
  final Value<int> rowid;
  const AssessorProfileCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.federationLicence = const Value.absent(),
    this.email = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessorProfileCompanion.insert({
    required String id,
    required String fullName,
    this.federationLicence = const Value.absent(),
    this.email = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fullName = Value(fullName);
  static Insertable<AssessorProfileData> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? federationLicence,
    Expression<String>? email,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (federationLicence != null) 'federation_licence': federationLicence,
      if (email != null) 'email': email,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessorProfileCompanion copyWith({
    Value<String>? id,
    Value<String>? fullName,
    Value<String?>? federationLicence,
    Value<String?>? email,
    Value<int>? rowid,
  }) {
    return AssessorProfileCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      federationLicence: federationLicence ?? this.federationLicence,
      email: email ?? this.email,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (federationLicence.present) {
      map['federation_licence'] = Variable<String>(federationLicence.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessorProfileCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('federationLicence: $federationLicence, ')
          ..write('email: $email, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Rubric extends Table with TableInfo<Rubric, RubricData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Rubric(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (status IN (\'DRAFT\', \'PUBLISHED\', \'RETIRED\'))',
  );
  static const VerificationMeta _definitionJsonMeta = const VerificationMeta(
    'definitionJson',
  );
  late final GeneratedColumn<String> definitionJson = GeneratedColumn<String>(
    'definition_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (json_valid(definition_json))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    version,
    status,
    definitionJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rubric';
  @override
  VerificationContext validateIntegrity(
    Insertable<RubricData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('definition_json')) {
      context.handle(
        _definitionJsonMeta,
        definitionJson.isAcceptableOrUnknown(
          data['definition_json']!,
          _definitionJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {code, version},
  ];
  @override
  RubricData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RubricData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      definitionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_json'],
      )!,
    );
  }

  @override
  Rubric createAlias(String alias) {
    return Rubric(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const ['UNIQUE(code, version)'];
  @override
  bool get dontWriteConstraints => true;
}

class RubricData extends DataClass implements Insertable<RubricData> {
  final String id;
  final String code;
  final String version;
  final String status;
  final String definitionJson;
  const RubricData({
    required this.id,
    required this.code,
    required this.version,
    required this.status,
    required this.definitionJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['version'] = Variable<String>(version);
    map['status'] = Variable<String>(status);
    map['definition_json'] = Variable<String>(definitionJson);
    return map;
  }

  RubricCompanion toCompanion(bool nullToAbsent) {
    return RubricCompanion(
      id: Value(id),
      code: Value(code),
      version: Value(version),
      status: Value(status),
      definitionJson: Value(definitionJson),
    );
  }

  factory RubricData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RubricData(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      version: serializer.fromJson<String>(json['version']),
      status: serializer.fromJson<String>(json['status']),
      definitionJson: serializer.fromJson<String>(json['definition_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'version': serializer.toJson<String>(version),
      'status': serializer.toJson<String>(status),
      'definition_json': serializer.toJson<String>(definitionJson),
    };
  }

  RubricData copyWith({
    String? id,
    String? code,
    String? version,
    String? status,
    String? definitionJson,
  }) => RubricData(
    id: id ?? this.id,
    code: code ?? this.code,
    version: version ?? this.version,
    status: status ?? this.status,
    definitionJson: definitionJson ?? this.definitionJson,
  );
  RubricData copyWithCompanion(RubricCompanion data) {
    return RubricData(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      version: data.version.present ? data.version.value : this.version,
      status: data.status.present ? data.status.value : this.status,
      definitionJson: data.definitionJson.present
          ? data.definitionJson.value
          : this.definitionJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RubricData(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('version: $version, ')
          ..write('status: $status, ')
          ..write('definitionJson: $definitionJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, version, status, definitionJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RubricData &&
          other.id == this.id &&
          other.code == this.code &&
          other.version == this.version &&
          other.status == this.status &&
          other.definitionJson == this.definitionJson);
}

class RubricCompanion extends UpdateCompanion<RubricData> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> version;
  final Value<String> status;
  final Value<String> definitionJson;
  final Value<int> rowid;
  const RubricCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.version = const Value.absent(),
    this.status = const Value.absent(),
    this.definitionJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RubricCompanion.insert({
    required String id,
    required String code,
    required String version,
    required String status,
    required String definitionJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       version = Value(version),
       status = Value(status),
       definitionJson = Value(definitionJson);
  static Insertable<RubricData> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? version,
    Expression<String>? status,
    Expression<String>? definitionJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (version != null) 'version': version,
      if (status != null) 'status': status,
      if (definitionJson != null) 'definition_json': definitionJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RubricCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? version,
    Value<String>? status,
    Value<String>? definitionJson,
    Value<int>? rowid,
  }) {
    return RubricCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      version: version ?? this.version,
      status: status ?? this.status,
      definitionJson: definitionJson ?? this.definitionJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (definitionJson.present) {
      map['definition_json'] = Variable<String>(definitionJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RubricCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('version: $version, ')
          ..write('status: $status, ')
          ..write('definitionJson: $definitionJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Assessment extends Table with TableInfo<Assessment, AssessmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Assessment(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'SETUP\', \'READY\', \'LIVE\', \'POST_MATCH\', \'FINALIZED\', \'ARCHIVED\'))',
  );
  static const VerificationMeta _rubricIdMeta = const VerificationMeta(
    'rubricId',
  );
  late final GeneratedColumn<String> rubricId = GeneratedColumn<String>(
    'rubric_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES rubric(id)',
  );
  static const VerificationMeta _assessorIdMeta = const VerificationMeta(
    'assessorId',
  );
  late final GeneratedColumn<String> assessorId = GeneratedColumn<String>(
    'assessor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES assessor_profile(id)',
  );
  static const VerificationMeta _refereeIdMeta = const VerificationMeta(
    'refereeId',
  );
  late final GeneratedColumn<String> refereeId = GeneratedColumn<String>(
    'referee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES official(id)',
  );
  static const VerificationMeta _ar1NameMeta = const VerificationMeta(
    'ar1Name',
  );
  late final GeneratedColumn<String> ar1Name = GeneratedColumn<String>(
    'ar1_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _ar2NameMeta = const VerificationMeta(
    'ar2Name',
  );
  late final GeneratedColumn<String> ar2Name = GeneratedColumn<String>(
    'ar2_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _competitionMeta = const VerificationMeta(
    'competition',
  );
  late final GeneratedColumn<String> competition = GeneratedColumn<String>(
    'competition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  late final GeneratedColumn<String> round = GeneratedColumn<String>(
    'round',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _kickoffLocalMeta = const VerificationMeta(
    'kickoffLocal',
  );
  late final GeneratedColumn<String> kickoffLocal = GeneratedColumn<String>(
    'kickoff_local',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kickoffTzMeta = const VerificationMeta(
    'kickoffTz',
  );
  late final GeneratedColumn<String> kickoffTz = GeneratedColumn<String>(
    'kickoff_tz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
    'venue',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _homeTeamMeta = const VerificationMeta(
    'homeTeam',
  );
  late final GeneratedColumn<String> homeTeam = GeneratedColumn<String>(
    'home_team',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _awayTeamMeta = const VerificationMeta(
    'awayTeam',
  );
  late final GeneratedColumn<String> awayTeam = GeneratedColumn<String>(
    'away_team',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _observationModeMeta = const VerificationMeta(
    'observationMode',
  );
  late final GeneratedColumn<String> observationMode = GeneratedColumn<String>(
    'observation_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (observation_mode IN (\'LIVE\', \'VIDEO\', \'LIVE_AND_VIDEO\'))',
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (difficulty IN (\'LOW\', \'MEDIUM\', \'HIGH\', \'VERY_HIGH\'))',
  );
  static const VerificationMeta _categoryCodeMeta = const VerificationMeta(
    'categoryCode',
  );
  late final GeneratedColumn<String> categoryCode = GeneratedColumn<String>(
    'category_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _categoryJsonMeta = const VerificationMeta(
    'categoryJson',
  );
  late final GeneratedColumn<String> categoryJson = GeneratedColumn<String>(
    'category_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (json_valid(category_json))',
  );
  static const VerificationMeta _conditionsJsonMeta = const VerificationMeta(
    'conditionsJson',
  );
  late final GeneratedColumn<String> conditionsJson = GeneratedColumn<String>(
    'conditions_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (conditions_json IS NULL OR json_valid(conditions_json))',
  );
  static const VerificationMeta _finalScoreHomeMeta = const VerificationMeta(
    'finalScoreHome',
  );
  late final GeneratedColumn<int> finalScoreHome = GeneratedColumn<int>(
    'final_score_home',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _finalScoreAwayMeta = const VerificationMeta(
    'finalScoreAway',
  );
  late final GeneratedColumn<int> finalScoreAway = GeneratedColumn<int>(
    'final_score_away',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schemaVersion,
    status,
    rubricId,
    assessorId,
    refereeId,
    ar1Name,
    ar2Name,
    competition,
    round,
    kickoffLocal,
    kickoffTz,
    venue,
    homeTeam,
    awayTeam,
    observationMode,
    difficulty,
    categoryCode,
    categoryJson,
    conditionsJson,
    finalScoreHome,
    finalScoreAway,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessment';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssessmentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('rubric_id')) {
      context.handle(
        _rubricIdMeta,
        rubricId.isAcceptableOrUnknown(data['rubric_id']!, _rubricIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rubricIdMeta);
    }
    if (data.containsKey('assessor_id')) {
      context.handle(
        _assessorIdMeta,
        assessorId.isAcceptableOrUnknown(data['assessor_id']!, _assessorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assessorIdMeta);
    }
    if (data.containsKey('referee_id')) {
      context.handle(
        _refereeIdMeta,
        refereeId.isAcceptableOrUnknown(data['referee_id']!, _refereeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_refereeIdMeta);
    }
    if (data.containsKey('ar1_name')) {
      context.handle(
        _ar1NameMeta,
        ar1Name.isAcceptableOrUnknown(data['ar1_name']!, _ar1NameMeta),
      );
    }
    if (data.containsKey('ar2_name')) {
      context.handle(
        _ar2NameMeta,
        ar2Name.isAcceptableOrUnknown(data['ar2_name']!, _ar2NameMeta),
      );
    }
    if (data.containsKey('competition')) {
      context.handle(
        _competitionMeta,
        competition.isAcceptableOrUnknown(
          data['competition']!,
          _competitionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_competitionMeta);
    }
    if (data.containsKey('round')) {
      context.handle(
        _roundMeta,
        round.isAcceptableOrUnknown(data['round']!, _roundMeta),
      );
    }
    if (data.containsKey('kickoff_local')) {
      context.handle(
        _kickoffLocalMeta,
        kickoffLocal.isAcceptableOrUnknown(
          data['kickoff_local']!,
          _kickoffLocalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kickoffLocalMeta);
    }
    if (data.containsKey('kickoff_tz')) {
      context.handle(
        _kickoffTzMeta,
        kickoffTz.isAcceptableOrUnknown(data['kickoff_tz']!, _kickoffTzMeta),
      );
    } else if (isInserting) {
      context.missing(_kickoffTzMeta);
    }
    if (data.containsKey('venue')) {
      context.handle(
        _venueMeta,
        venue.isAcceptableOrUnknown(data['venue']!, _venueMeta),
      );
    } else if (isInserting) {
      context.missing(_venueMeta);
    }
    if (data.containsKey('home_team')) {
      context.handle(
        _homeTeamMeta,
        homeTeam.isAcceptableOrUnknown(data['home_team']!, _homeTeamMeta),
      );
    } else if (isInserting) {
      context.missing(_homeTeamMeta);
    }
    if (data.containsKey('away_team')) {
      context.handle(
        _awayTeamMeta,
        awayTeam.isAcceptableOrUnknown(data['away_team']!, _awayTeamMeta),
      );
    } else if (isInserting) {
      context.missing(_awayTeamMeta);
    }
    if (data.containsKey('observation_mode')) {
      context.handle(
        _observationModeMeta,
        observationMode.isAcceptableOrUnknown(
          data['observation_mode']!,
          _observationModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observationModeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('category_code')) {
      context.handle(
        _categoryCodeMeta,
        categoryCode.isAcceptableOrUnknown(
          data['category_code']!,
          _categoryCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryCodeMeta);
    }
    if (data.containsKey('category_json')) {
      context.handle(
        _categoryJsonMeta,
        categoryJson.isAcceptableOrUnknown(
          data['category_json']!,
          _categoryJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryJsonMeta);
    }
    if (data.containsKey('conditions_json')) {
      context.handle(
        _conditionsJsonMeta,
        conditionsJson.isAcceptableOrUnknown(
          data['conditions_json']!,
          _conditionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('final_score_home')) {
      context.handle(
        _finalScoreHomeMeta,
        finalScoreHome.isAcceptableOrUnknown(
          data['final_score_home']!,
          _finalScoreHomeMeta,
        ),
      );
    }
    if (data.containsKey('final_score_away')) {
      context.handle(
        _finalScoreAwayMeta,
        finalScoreAway.isAcceptableOrUnknown(
          data['final_score_away']!,
          _finalScoreAwayMeta,
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
  AssessmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssessmentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rubricId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rubric_id'],
      )!,
      assessorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessor_id'],
      )!,
      refereeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referee_id'],
      )!,
      ar1Name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ar1_name'],
      ),
      ar2Name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ar2_name'],
      ),
      competition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competition'],
      )!,
      round: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round'],
      ),
      kickoffLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kickoff_local'],
      )!,
      kickoffTz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kickoff_tz'],
      )!,
      venue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venue'],
      )!,
      homeTeam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_team'],
      )!,
      awayTeam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}away_team'],
      )!,
      observationMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation_mode'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
      categoryCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_code'],
      )!,
      categoryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_json'],
      )!,
      conditionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conditions_json'],
      ),
      finalScoreHome: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}final_score_home'],
      ),
      finalScoreAway: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}final_score_away'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Assessment createAlias(String alias) {
    return Assessment(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class AssessmentData extends DataClass implements Insertable<AssessmentData> {
  final String id;
  final int schemaVersion;
  final String status;
  final String rubricId;
  final String assessorId;
  final String refereeId;

  /// único oficial evaluado
  final String? ar1Name;

  /// descriptivo, no se evalúa
  final String? ar2Name;

  /// descriptivo, no se evalúa
  final String competition;
  final String? round;
  final String kickoffLocal;
  final String kickoffTz;
  final String venue;
  final String homeTeam;
  final String awayTeam;
  final String observationMode;
  final String? difficulty;

  /// solo contexto (R3)
  final String categoryCode;

  /// preset elegido (R6)
  final String categoryJson;

  /// snapshot de CategoryConfig
  final String? conditionsJson;
  final int? finalScoreHome;
  final int? finalScoreAway;
  final String createdAt;
  final String updatedAt;
  const AssessmentData({
    required this.id,
    required this.schemaVersion,
    required this.status,
    required this.rubricId,
    required this.assessorId,
    required this.refereeId,
    this.ar1Name,
    this.ar2Name,
    required this.competition,
    this.round,
    required this.kickoffLocal,
    required this.kickoffTz,
    required this.venue,
    required this.homeTeam,
    required this.awayTeam,
    required this.observationMode,
    this.difficulty,
    required this.categoryCode,
    required this.categoryJson,
    this.conditionsJson,
    this.finalScoreHome,
    this.finalScoreAway,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['status'] = Variable<String>(status);
    map['rubric_id'] = Variable<String>(rubricId);
    map['assessor_id'] = Variable<String>(assessorId);
    map['referee_id'] = Variable<String>(refereeId);
    if (!nullToAbsent || ar1Name != null) {
      map['ar1_name'] = Variable<String>(ar1Name);
    }
    if (!nullToAbsent || ar2Name != null) {
      map['ar2_name'] = Variable<String>(ar2Name);
    }
    map['competition'] = Variable<String>(competition);
    if (!nullToAbsent || round != null) {
      map['round'] = Variable<String>(round);
    }
    map['kickoff_local'] = Variable<String>(kickoffLocal);
    map['kickoff_tz'] = Variable<String>(kickoffTz);
    map['venue'] = Variable<String>(venue);
    map['home_team'] = Variable<String>(homeTeam);
    map['away_team'] = Variable<String>(awayTeam);
    map['observation_mode'] = Variable<String>(observationMode);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    map['category_code'] = Variable<String>(categoryCode);
    map['category_json'] = Variable<String>(categoryJson);
    if (!nullToAbsent || conditionsJson != null) {
      map['conditions_json'] = Variable<String>(conditionsJson);
    }
    if (!nullToAbsent || finalScoreHome != null) {
      map['final_score_home'] = Variable<int>(finalScoreHome);
    }
    if (!nullToAbsent || finalScoreAway != null) {
      map['final_score_away'] = Variable<int>(finalScoreAway);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  AssessmentCompanion toCompanion(bool nullToAbsent) {
    return AssessmentCompanion(
      id: Value(id),
      schemaVersion: Value(schemaVersion),
      status: Value(status),
      rubricId: Value(rubricId),
      assessorId: Value(assessorId),
      refereeId: Value(refereeId),
      ar1Name: ar1Name == null && nullToAbsent
          ? const Value.absent()
          : Value(ar1Name),
      ar2Name: ar2Name == null && nullToAbsent
          ? const Value.absent()
          : Value(ar2Name),
      competition: Value(competition),
      round: round == null && nullToAbsent
          ? const Value.absent()
          : Value(round),
      kickoffLocal: Value(kickoffLocal),
      kickoffTz: Value(kickoffTz),
      venue: Value(venue),
      homeTeam: Value(homeTeam),
      awayTeam: Value(awayTeam),
      observationMode: Value(observationMode),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      categoryCode: Value(categoryCode),
      categoryJson: Value(categoryJson),
      conditionsJson: conditionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionsJson),
      finalScoreHome: finalScoreHome == null && nullToAbsent
          ? const Value.absent()
          : Value(finalScoreHome),
      finalScoreAway: finalScoreAway == null && nullToAbsent
          ? const Value.absent()
          : Value(finalScoreAway),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssessmentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssessmentData(
      id: serializer.fromJson<String>(json['id']),
      schemaVersion: serializer.fromJson<int>(json['schema_version']),
      status: serializer.fromJson<String>(json['status']),
      rubricId: serializer.fromJson<String>(json['rubric_id']),
      assessorId: serializer.fromJson<String>(json['assessor_id']),
      refereeId: serializer.fromJson<String>(json['referee_id']),
      ar1Name: serializer.fromJson<String?>(json['ar1_name']),
      ar2Name: serializer.fromJson<String?>(json['ar2_name']),
      competition: serializer.fromJson<String>(json['competition']),
      round: serializer.fromJson<String?>(json['round']),
      kickoffLocal: serializer.fromJson<String>(json['kickoff_local']),
      kickoffTz: serializer.fromJson<String>(json['kickoff_tz']),
      venue: serializer.fromJson<String>(json['venue']),
      homeTeam: serializer.fromJson<String>(json['home_team']),
      awayTeam: serializer.fromJson<String>(json['away_team']),
      observationMode: serializer.fromJson<String>(json['observation_mode']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      categoryCode: serializer.fromJson<String>(json['category_code']),
      categoryJson: serializer.fromJson<String>(json['category_json']),
      conditionsJson: serializer.fromJson<String?>(json['conditions_json']),
      finalScoreHome: serializer.fromJson<int?>(json['final_score_home']),
      finalScoreAway: serializer.fromJson<int?>(json['final_score_away']),
      createdAt: serializer.fromJson<String>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'schema_version': serializer.toJson<int>(schemaVersion),
      'status': serializer.toJson<String>(status),
      'rubric_id': serializer.toJson<String>(rubricId),
      'assessor_id': serializer.toJson<String>(assessorId),
      'referee_id': serializer.toJson<String>(refereeId),
      'ar1_name': serializer.toJson<String?>(ar1Name),
      'ar2_name': serializer.toJson<String?>(ar2Name),
      'competition': serializer.toJson<String>(competition),
      'round': serializer.toJson<String?>(round),
      'kickoff_local': serializer.toJson<String>(kickoffLocal),
      'kickoff_tz': serializer.toJson<String>(kickoffTz),
      'venue': serializer.toJson<String>(venue),
      'home_team': serializer.toJson<String>(homeTeam),
      'away_team': serializer.toJson<String>(awayTeam),
      'observation_mode': serializer.toJson<String>(observationMode),
      'difficulty': serializer.toJson<String?>(difficulty),
      'category_code': serializer.toJson<String>(categoryCode),
      'category_json': serializer.toJson<String>(categoryJson),
      'conditions_json': serializer.toJson<String?>(conditionsJson),
      'final_score_home': serializer.toJson<int?>(finalScoreHome),
      'final_score_away': serializer.toJson<int?>(finalScoreAway),
      'created_at': serializer.toJson<String>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
    };
  }

  AssessmentData copyWith({
    String? id,
    int? schemaVersion,
    String? status,
    String? rubricId,
    String? assessorId,
    String? refereeId,
    Value<String?> ar1Name = const Value.absent(),
    Value<String?> ar2Name = const Value.absent(),
    String? competition,
    Value<String?> round = const Value.absent(),
    String? kickoffLocal,
    String? kickoffTz,
    String? venue,
    String? homeTeam,
    String? awayTeam,
    String? observationMode,
    Value<String?> difficulty = const Value.absent(),
    String? categoryCode,
    String? categoryJson,
    Value<String?> conditionsJson = const Value.absent(),
    Value<int?> finalScoreHome = const Value.absent(),
    Value<int?> finalScoreAway = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => AssessmentData(
    id: id ?? this.id,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    status: status ?? this.status,
    rubricId: rubricId ?? this.rubricId,
    assessorId: assessorId ?? this.assessorId,
    refereeId: refereeId ?? this.refereeId,
    ar1Name: ar1Name.present ? ar1Name.value : this.ar1Name,
    ar2Name: ar2Name.present ? ar2Name.value : this.ar2Name,
    competition: competition ?? this.competition,
    round: round.present ? round.value : this.round,
    kickoffLocal: kickoffLocal ?? this.kickoffLocal,
    kickoffTz: kickoffTz ?? this.kickoffTz,
    venue: venue ?? this.venue,
    homeTeam: homeTeam ?? this.homeTeam,
    awayTeam: awayTeam ?? this.awayTeam,
    observationMode: observationMode ?? this.observationMode,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    categoryCode: categoryCode ?? this.categoryCode,
    categoryJson: categoryJson ?? this.categoryJson,
    conditionsJson: conditionsJson.present
        ? conditionsJson.value
        : this.conditionsJson,
    finalScoreHome: finalScoreHome.present
        ? finalScoreHome.value
        : this.finalScoreHome,
    finalScoreAway: finalScoreAway.present
        ? finalScoreAway.value
        : this.finalScoreAway,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssessmentData copyWithCompanion(AssessmentCompanion data) {
    return AssessmentData(
      id: data.id.present ? data.id.value : this.id,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      status: data.status.present ? data.status.value : this.status,
      rubricId: data.rubricId.present ? data.rubricId.value : this.rubricId,
      assessorId: data.assessorId.present
          ? data.assessorId.value
          : this.assessorId,
      refereeId: data.refereeId.present ? data.refereeId.value : this.refereeId,
      ar1Name: data.ar1Name.present ? data.ar1Name.value : this.ar1Name,
      ar2Name: data.ar2Name.present ? data.ar2Name.value : this.ar2Name,
      competition: data.competition.present
          ? data.competition.value
          : this.competition,
      round: data.round.present ? data.round.value : this.round,
      kickoffLocal: data.kickoffLocal.present
          ? data.kickoffLocal.value
          : this.kickoffLocal,
      kickoffTz: data.kickoffTz.present ? data.kickoffTz.value : this.kickoffTz,
      venue: data.venue.present ? data.venue.value : this.venue,
      homeTeam: data.homeTeam.present ? data.homeTeam.value : this.homeTeam,
      awayTeam: data.awayTeam.present ? data.awayTeam.value : this.awayTeam,
      observationMode: data.observationMode.present
          ? data.observationMode.value
          : this.observationMode,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      categoryCode: data.categoryCode.present
          ? data.categoryCode.value
          : this.categoryCode,
      categoryJson: data.categoryJson.present
          ? data.categoryJson.value
          : this.categoryJson,
      conditionsJson: data.conditionsJson.present
          ? data.conditionsJson.value
          : this.conditionsJson,
      finalScoreHome: data.finalScoreHome.present
          ? data.finalScoreHome.value
          : this.finalScoreHome,
      finalScoreAway: data.finalScoreAway.present
          ? data.finalScoreAway.value
          : this.finalScoreAway,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentData(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('status: $status, ')
          ..write('rubricId: $rubricId, ')
          ..write('assessorId: $assessorId, ')
          ..write('refereeId: $refereeId, ')
          ..write('ar1Name: $ar1Name, ')
          ..write('ar2Name: $ar2Name, ')
          ..write('competition: $competition, ')
          ..write('round: $round, ')
          ..write('kickoffLocal: $kickoffLocal, ')
          ..write('kickoffTz: $kickoffTz, ')
          ..write('venue: $venue, ')
          ..write('homeTeam: $homeTeam, ')
          ..write('awayTeam: $awayTeam, ')
          ..write('observationMode: $observationMode, ')
          ..write('difficulty: $difficulty, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('categoryJson: $categoryJson, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('finalScoreHome: $finalScoreHome, ')
          ..write('finalScoreAway: $finalScoreAway, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    schemaVersion,
    status,
    rubricId,
    assessorId,
    refereeId,
    ar1Name,
    ar2Name,
    competition,
    round,
    kickoffLocal,
    kickoffTz,
    venue,
    homeTeam,
    awayTeam,
    observationMode,
    difficulty,
    categoryCode,
    categoryJson,
    conditionsJson,
    finalScoreHome,
    finalScoreAway,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssessmentData &&
          other.id == this.id &&
          other.schemaVersion == this.schemaVersion &&
          other.status == this.status &&
          other.rubricId == this.rubricId &&
          other.assessorId == this.assessorId &&
          other.refereeId == this.refereeId &&
          other.ar1Name == this.ar1Name &&
          other.ar2Name == this.ar2Name &&
          other.competition == this.competition &&
          other.round == this.round &&
          other.kickoffLocal == this.kickoffLocal &&
          other.kickoffTz == this.kickoffTz &&
          other.venue == this.venue &&
          other.homeTeam == this.homeTeam &&
          other.awayTeam == this.awayTeam &&
          other.observationMode == this.observationMode &&
          other.difficulty == this.difficulty &&
          other.categoryCode == this.categoryCode &&
          other.categoryJson == this.categoryJson &&
          other.conditionsJson == this.conditionsJson &&
          other.finalScoreHome == this.finalScoreHome &&
          other.finalScoreAway == this.finalScoreAway &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AssessmentCompanion extends UpdateCompanion<AssessmentData> {
  final Value<String> id;
  final Value<int> schemaVersion;
  final Value<String> status;
  final Value<String> rubricId;
  final Value<String> assessorId;
  final Value<String> refereeId;
  final Value<String?> ar1Name;
  final Value<String?> ar2Name;
  final Value<String> competition;
  final Value<String?> round;
  final Value<String> kickoffLocal;
  final Value<String> kickoffTz;
  final Value<String> venue;
  final Value<String> homeTeam;
  final Value<String> awayTeam;
  final Value<String> observationMode;
  final Value<String?> difficulty;
  final Value<String> categoryCode;
  final Value<String> categoryJson;
  final Value<String?> conditionsJson;
  final Value<int?> finalScoreHome;
  final Value<int?> finalScoreAway;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const AssessmentCompanion({
    this.id = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.rubricId = const Value.absent(),
    this.assessorId = const Value.absent(),
    this.refereeId = const Value.absent(),
    this.ar1Name = const Value.absent(),
    this.ar2Name = const Value.absent(),
    this.competition = const Value.absent(),
    this.round = const Value.absent(),
    this.kickoffLocal = const Value.absent(),
    this.kickoffTz = const Value.absent(),
    this.venue = const Value.absent(),
    this.homeTeam = const Value.absent(),
    this.awayTeam = const Value.absent(),
    this.observationMode = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.categoryCode = const Value.absent(),
    this.categoryJson = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.finalScoreHome = const Value.absent(),
    this.finalScoreAway = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssessmentCompanion.insert({
    required String id,
    this.schemaVersion = const Value.absent(),
    required String status,
    required String rubricId,
    required String assessorId,
    required String refereeId,
    this.ar1Name = const Value.absent(),
    this.ar2Name = const Value.absent(),
    required String competition,
    this.round = const Value.absent(),
    required String kickoffLocal,
    required String kickoffTz,
    required String venue,
    required String homeTeam,
    required String awayTeam,
    required String observationMode,
    this.difficulty = const Value.absent(),
    required String categoryCode,
    required String categoryJson,
    this.conditionsJson = const Value.absent(),
    this.finalScoreHome = const Value.absent(),
    this.finalScoreAway = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       rubricId = Value(rubricId),
       assessorId = Value(assessorId),
       refereeId = Value(refereeId),
       competition = Value(competition),
       kickoffLocal = Value(kickoffLocal),
       kickoffTz = Value(kickoffTz),
       venue = Value(venue),
       homeTeam = Value(homeTeam),
       awayTeam = Value(awayTeam),
       observationMode = Value(observationMode),
       categoryCode = Value(categoryCode),
       categoryJson = Value(categoryJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AssessmentData> custom({
    Expression<String>? id,
    Expression<int>? schemaVersion,
    Expression<String>? status,
    Expression<String>? rubricId,
    Expression<String>? assessorId,
    Expression<String>? refereeId,
    Expression<String>? ar1Name,
    Expression<String>? ar2Name,
    Expression<String>? competition,
    Expression<String>? round,
    Expression<String>? kickoffLocal,
    Expression<String>? kickoffTz,
    Expression<String>? venue,
    Expression<String>? homeTeam,
    Expression<String>? awayTeam,
    Expression<String>? observationMode,
    Expression<String>? difficulty,
    Expression<String>? categoryCode,
    Expression<String>? categoryJson,
    Expression<String>? conditionsJson,
    Expression<int>? finalScoreHome,
    Expression<int>? finalScoreAway,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (status != null) 'status': status,
      if (rubricId != null) 'rubric_id': rubricId,
      if (assessorId != null) 'assessor_id': assessorId,
      if (refereeId != null) 'referee_id': refereeId,
      if (ar1Name != null) 'ar1_name': ar1Name,
      if (ar2Name != null) 'ar2_name': ar2Name,
      if (competition != null) 'competition': competition,
      if (round != null) 'round': round,
      if (kickoffLocal != null) 'kickoff_local': kickoffLocal,
      if (kickoffTz != null) 'kickoff_tz': kickoffTz,
      if (venue != null) 'venue': venue,
      if (homeTeam != null) 'home_team': homeTeam,
      if (awayTeam != null) 'away_team': awayTeam,
      if (observationMode != null) 'observation_mode': observationMode,
      if (difficulty != null) 'difficulty': difficulty,
      if (categoryCode != null) 'category_code': categoryCode,
      if (categoryJson != null) 'category_json': categoryJson,
      if (conditionsJson != null) 'conditions_json': conditionsJson,
      if (finalScoreHome != null) 'final_score_home': finalScoreHome,
      if (finalScoreAway != null) 'final_score_away': finalScoreAway,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssessmentCompanion copyWith({
    Value<String>? id,
    Value<int>? schemaVersion,
    Value<String>? status,
    Value<String>? rubricId,
    Value<String>? assessorId,
    Value<String>? refereeId,
    Value<String?>? ar1Name,
    Value<String?>? ar2Name,
    Value<String>? competition,
    Value<String?>? round,
    Value<String>? kickoffLocal,
    Value<String>? kickoffTz,
    Value<String>? venue,
    Value<String>? homeTeam,
    Value<String>? awayTeam,
    Value<String>? observationMode,
    Value<String?>? difficulty,
    Value<String>? categoryCode,
    Value<String>? categoryJson,
    Value<String?>? conditionsJson,
    Value<int?>? finalScoreHome,
    Value<int?>? finalScoreAway,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return AssessmentCompanion(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      status: status ?? this.status,
      rubricId: rubricId ?? this.rubricId,
      assessorId: assessorId ?? this.assessorId,
      refereeId: refereeId ?? this.refereeId,
      ar1Name: ar1Name ?? this.ar1Name,
      ar2Name: ar2Name ?? this.ar2Name,
      competition: competition ?? this.competition,
      round: round ?? this.round,
      kickoffLocal: kickoffLocal ?? this.kickoffLocal,
      kickoffTz: kickoffTz ?? this.kickoffTz,
      venue: venue ?? this.venue,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      observationMode: observationMode ?? this.observationMode,
      difficulty: difficulty ?? this.difficulty,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryJson: categoryJson ?? this.categoryJson,
      conditionsJson: conditionsJson ?? this.conditionsJson,
      finalScoreHome: finalScoreHome ?? this.finalScoreHome,
      finalScoreAway: finalScoreAway ?? this.finalScoreAway,
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
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rubricId.present) {
      map['rubric_id'] = Variable<String>(rubricId.value);
    }
    if (assessorId.present) {
      map['assessor_id'] = Variable<String>(assessorId.value);
    }
    if (refereeId.present) {
      map['referee_id'] = Variable<String>(refereeId.value);
    }
    if (ar1Name.present) {
      map['ar1_name'] = Variable<String>(ar1Name.value);
    }
    if (ar2Name.present) {
      map['ar2_name'] = Variable<String>(ar2Name.value);
    }
    if (competition.present) {
      map['competition'] = Variable<String>(competition.value);
    }
    if (round.present) {
      map['round'] = Variable<String>(round.value);
    }
    if (kickoffLocal.present) {
      map['kickoff_local'] = Variable<String>(kickoffLocal.value);
    }
    if (kickoffTz.present) {
      map['kickoff_tz'] = Variable<String>(kickoffTz.value);
    }
    if (venue.present) {
      map['venue'] = Variable<String>(venue.value);
    }
    if (homeTeam.present) {
      map['home_team'] = Variable<String>(homeTeam.value);
    }
    if (awayTeam.present) {
      map['away_team'] = Variable<String>(awayTeam.value);
    }
    if (observationMode.present) {
      map['observation_mode'] = Variable<String>(observationMode.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (categoryCode.present) {
      map['category_code'] = Variable<String>(categoryCode.value);
    }
    if (categoryJson.present) {
      map['category_json'] = Variable<String>(categoryJson.value);
    }
    if (conditionsJson.present) {
      map['conditions_json'] = Variable<String>(conditionsJson.value);
    }
    if (finalScoreHome.present) {
      map['final_score_home'] = Variable<int>(finalScoreHome.value);
    }
    if (finalScoreAway.present) {
      map['final_score_away'] = Variable<int>(finalScoreAway.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentCompanion(')
          ..write('id: $id, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('status: $status, ')
          ..write('rubricId: $rubricId, ')
          ..write('assessorId: $assessorId, ')
          ..write('refereeId: $refereeId, ')
          ..write('ar1Name: $ar1Name, ')
          ..write('ar2Name: $ar2Name, ')
          ..write('competition: $competition, ')
          ..write('round: $round, ')
          ..write('kickoffLocal: $kickoffLocal, ')
          ..write('kickoffTz: $kickoffTz, ')
          ..write('venue: $venue, ')
          ..write('homeTeam: $homeTeam, ')
          ..write('awayTeam: $awayTeam, ')
          ..write('observationMode: $observationMode, ')
          ..write('difficulty: $difficulty, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('categoryJson: $categoryJson, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('finalScoreHome: $finalScoreHome, ')
          ..write('finalScoreAway: $finalScoreAway, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ClockEvent extends Table with TableInfo<ClockEvent, ClockEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ClockEvent(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assessmentIdMeta = const VerificationMeta(
    'assessmentId',
  );
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES assessment(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (type IN (\'PERIOD_START\', \'TIME_OFF\', \'TIME_ON\', \'PERIOD_END\', \'ADJUST\', \'INTEGRITY_LOST\', \'ABANDON\', \'VOID\'))',
  );
  static const VerificationMeta _tSessionMsMeta = const VerificationMeta(
    'tSessionMs',
  );
  late final GeneratedColumn<int> tSessionMs = GeneratedColumn<int>(
    't_session_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bootIdMeta = const VerificationMeta('bootId');
  late final GeneratedColumn<String> bootId = GeneratedColumn<String>(
    'boot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _monoMsMeta = const VerificationMeta('monoMs');
  late final GeneratedColumn<int> monoMs = GeneratedColumn<int>(
    'mono_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _wallUtcMeta = const VerificationMeta(
    'wallUtc',
  );
  late final GeneratedColumn<String> wallUtc = GeneratedColumn<String>(
    'wall_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'{}\' CHECK (json_valid(payload_json))',
    defaultValue: const CustomExpression('\'{}\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    assessmentId,
    seq,
    type,
    tSessionMs,
    bootId,
    monoMs,
    wallUtc,
    payloadJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clock_event';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClockEventData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assessment_id')) {
      context.handle(
        _assessmentIdMeta,
        assessmentId.isAcceptableOrUnknown(
          data['assessment_id']!,
          _assessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('t_session_ms')) {
      context.handle(
        _tSessionMsMeta,
        tSessionMs.isAcceptableOrUnknown(
          data['t_session_ms']!,
          _tSessionMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tSessionMsMeta);
    }
    if (data.containsKey('boot_id')) {
      context.handle(
        _bootIdMeta,
        bootId.isAcceptableOrUnknown(data['boot_id']!, _bootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bootIdMeta);
    }
    if (data.containsKey('mono_ms')) {
      context.handle(
        _monoMsMeta,
        monoMs.isAcceptableOrUnknown(data['mono_ms']!, _monoMsMeta),
      );
    } else if (isInserting) {
      context.missing(_monoMsMeta);
    }
    if (data.containsKey('wall_utc')) {
      context.handle(
        _wallUtcMeta,
        wallUtc.isAcceptableOrUnknown(data['wall_utc']!, _wallUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_wallUtcMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assessmentId, seq};
  @override
  ClockEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClockEventData(
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      tSessionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}t_session_ms'],
      )!,
      bootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boot_id'],
      )!,
      monoMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mono_ms'],
      )!,
      wallUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wall_utc'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
    );
  }

  @override
  ClockEvent createAlias(String alias) {
    return ClockEvent(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(assessment_id, seq)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ClockEventData extends DataClass implements Insertable<ClockEventData> {
  final String assessmentId;
  final int seq;
  final String type;
  final int tSessionMs;

  /// eje monotónico de la sesión
  final String bootId;

  /// auditoría del origen del instante
  final int monoMs;

  /// SystemClock.elapsedRealtime() crudo
  final String wallUtc;
  final String payloadJson;
  const ClockEventData({
    required this.assessmentId,
    required this.seq,
    required this.type,
    required this.tSessionMs,
    required this.bootId,
    required this.monoMs,
    required this.wallUtc,
    required this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assessment_id'] = Variable<String>(assessmentId);
    map['seq'] = Variable<int>(seq);
    map['type'] = Variable<String>(type);
    map['t_session_ms'] = Variable<int>(tSessionMs);
    map['boot_id'] = Variable<String>(bootId);
    map['mono_ms'] = Variable<int>(monoMs);
    map['wall_utc'] = Variable<String>(wallUtc);
    map['payload_json'] = Variable<String>(payloadJson);
    return map;
  }

  ClockEventCompanion toCompanion(bool nullToAbsent) {
    return ClockEventCompanion(
      assessmentId: Value(assessmentId),
      seq: Value(seq),
      type: Value(type),
      tSessionMs: Value(tSessionMs),
      bootId: Value(bootId),
      monoMs: Value(monoMs),
      wallUtc: Value(wallUtc),
      payloadJson: Value(payloadJson),
    );
  }

  factory ClockEventData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClockEventData(
      assessmentId: serializer.fromJson<String>(json['assessment_id']),
      seq: serializer.fromJson<int>(json['seq']),
      type: serializer.fromJson<String>(json['type']),
      tSessionMs: serializer.fromJson<int>(json['t_session_ms']),
      bootId: serializer.fromJson<String>(json['boot_id']),
      monoMs: serializer.fromJson<int>(json['mono_ms']),
      wallUtc: serializer.fromJson<String>(json['wall_utc']),
      payloadJson: serializer.fromJson<String>(json['payload_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assessment_id': serializer.toJson<String>(assessmentId),
      'seq': serializer.toJson<int>(seq),
      'type': serializer.toJson<String>(type),
      't_session_ms': serializer.toJson<int>(tSessionMs),
      'boot_id': serializer.toJson<String>(bootId),
      'mono_ms': serializer.toJson<int>(monoMs),
      'wall_utc': serializer.toJson<String>(wallUtc),
      'payload_json': serializer.toJson<String>(payloadJson),
    };
  }

  ClockEventData copyWith({
    String? assessmentId,
    int? seq,
    String? type,
    int? tSessionMs,
    String? bootId,
    int? monoMs,
    String? wallUtc,
    String? payloadJson,
  }) => ClockEventData(
    assessmentId: assessmentId ?? this.assessmentId,
    seq: seq ?? this.seq,
    type: type ?? this.type,
    tSessionMs: tSessionMs ?? this.tSessionMs,
    bootId: bootId ?? this.bootId,
    monoMs: monoMs ?? this.monoMs,
    wallUtc: wallUtc ?? this.wallUtc,
    payloadJson: payloadJson ?? this.payloadJson,
  );
  ClockEventData copyWithCompanion(ClockEventCompanion data) {
    return ClockEventData(
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      seq: data.seq.present ? data.seq.value : this.seq,
      type: data.type.present ? data.type.value : this.type,
      tSessionMs: data.tSessionMs.present
          ? data.tSessionMs.value
          : this.tSessionMs,
      bootId: data.bootId.present ? data.bootId.value : this.bootId,
      monoMs: data.monoMs.present ? data.monoMs.value : this.monoMs,
      wallUtc: data.wallUtc.present ? data.wallUtc.value : this.wallUtc,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClockEventData(')
          ..write('assessmentId: $assessmentId, ')
          ..write('seq: $seq, ')
          ..write('type: $type, ')
          ..write('tSessionMs: $tSessionMs, ')
          ..write('bootId: $bootId, ')
          ..write('monoMs: $monoMs, ')
          ..write('wallUtc: $wallUtc, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    assessmentId,
    seq,
    type,
    tSessionMs,
    bootId,
    monoMs,
    wallUtc,
    payloadJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClockEventData &&
          other.assessmentId == this.assessmentId &&
          other.seq == this.seq &&
          other.type == this.type &&
          other.tSessionMs == this.tSessionMs &&
          other.bootId == this.bootId &&
          other.monoMs == this.monoMs &&
          other.wallUtc == this.wallUtc &&
          other.payloadJson == this.payloadJson);
}

class ClockEventCompanion extends UpdateCompanion<ClockEventData> {
  final Value<String> assessmentId;
  final Value<int> seq;
  final Value<String> type;
  final Value<int> tSessionMs;
  final Value<String> bootId;
  final Value<int> monoMs;
  final Value<String> wallUtc;
  final Value<String> payloadJson;
  final Value<int> rowid;
  const ClockEventCompanion({
    this.assessmentId = const Value.absent(),
    this.seq = const Value.absent(),
    this.type = const Value.absent(),
    this.tSessionMs = const Value.absent(),
    this.bootId = const Value.absent(),
    this.monoMs = const Value.absent(),
    this.wallUtc = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClockEventCompanion.insert({
    required String assessmentId,
    required int seq,
    required String type,
    required int tSessionMs,
    required String bootId,
    required int monoMs,
    required String wallUtc,
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : assessmentId = Value(assessmentId),
       seq = Value(seq),
       type = Value(type),
       tSessionMs = Value(tSessionMs),
       bootId = Value(bootId),
       monoMs = Value(monoMs),
       wallUtc = Value(wallUtc);
  static Insertable<ClockEventData> custom({
    Expression<String>? assessmentId,
    Expression<int>? seq,
    Expression<String>? type,
    Expression<int>? tSessionMs,
    Expression<String>? bootId,
    Expression<int>? monoMs,
    Expression<String>? wallUtc,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (seq != null) 'seq': seq,
      if (type != null) 'type': type,
      if (tSessionMs != null) 't_session_ms': tSessionMs,
      if (bootId != null) 'boot_id': bootId,
      if (monoMs != null) 'mono_ms': monoMs,
      if (wallUtc != null) 'wall_utc': wallUtc,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClockEventCompanion copyWith({
    Value<String>? assessmentId,
    Value<int>? seq,
    Value<String>? type,
    Value<int>? tSessionMs,
    Value<String>? bootId,
    Value<int>? monoMs,
    Value<String>? wallUtc,
    Value<String>? payloadJson,
    Value<int>? rowid,
  }) {
    return ClockEventCompanion(
      assessmentId: assessmentId ?? this.assessmentId,
      seq: seq ?? this.seq,
      type: type ?? this.type,
      tSessionMs: tSessionMs ?? this.tSessionMs,
      bootId: bootId ?? this.bootId,
      monoMs: monoMs ?? this.monoMs,
      wallUtc: wallUtc ?? this.wallUtc,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (tSessionMs.present) {
      map['t_session_ms'] = Variable<int>(tSessionMs.value);
    }
    if (bootId.present) {
      map['boot_id'] = Variable<String>(bootId.value);
    }
    if (monoMs.present) {
      map['mono_ms'] = Variable<int>(monoMs.value);
    }
    if (wallUtc.present) {
      map['wall_utc'] = Variable<String>(wallUtc.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClockEventCompanion(')
          ..write('assessmentId: $assessmentId, ')
          ..write('seq: $seq, ')
          ..write('type: $type, ')
          ..write('tSessionMs: $tSessionMs, ')
          ..write('bootId: $bootId, ')
          ..write('monoMs: $monoMs, ')
          ..write('wallUtc: $wallUtc, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SessionTimeAnchor extends Table
    with TableInfo<SessionTimeAnchor, SessionTimeAnchorData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SessionTimeAnchor(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assessmentIdMeta = const VerificationMeta(
    'assessmentId',
  );
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES assessment(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _bootIdMeta = const VerificationMeta('bootId');
  late final GeneratedColumn<String> bootId = GeneratedColumn<String>(
    'boot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _monoAtAnchorMeta = const VerificationMeta(
    'monoAtAnchor',
  );
  late final GeneratedColumn<int> monoAtAnchor = GeneratedColumn<int>(
    'mono_at_anchor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sessionAtAnchorMeta = const VerificationMeta(
    'sessionAtAnchor',
  );
  late final GeneratedColumn<int> sessionAtAnchor = GeneratedColumn<int>(
    'session_at_anchor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _wallUtcAtAnchorMeta = const VerificationMeta(
    'wallUtcAtAnchor',
  );
  late final GeneratedColumn<String> wallUtcAtAnchor = GeneratedColumn<String>(
    'wall_utc_at_anchor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _estimatedMeta = const VerificationMeta(
    'estimated',
  );
  late final GeneratedColumn<int> estimated = GeneratedColumn<int>(
    'estimated',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (estimated IN (0, 1))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    assessmentId,
    bootId,
    monoAtAnchor,
    sessionAtAnchor,
    wallUtcAtAnchor,
    estimated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_time_anchor';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionTimeAnchorData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assessment_id')) {
      context.handle(
        _assessmentIdMeta,
        assessmentId.isAcceptableOrUnknown(
          data['assessment_id']!,
          _assessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('boot_id')) {
      context.handle(
        _bootIdMeta,
        bootId.isAcceptableOrUnknown(data['boot_id']!, _bootIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bootIdMeta);
    }
    if (data.containsKey('mono_at_anchor')) {
      context.handle(
        _monoAtAnchorMeta,
        monoAtAnchor.isAcceptableOrUnknown(
          data['mono_at_anchor']!,
          _monoAtAnchorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monoAtAnchorMeta);
    }
    if (data.containsKey('session_at_anchor')) {
      context.handle(
        _sessionAtAnchorMeta,
        sessionAtAnchor.isAcceptableOrUnknown(
          data['session_at_anchor']!,
          _sessionAtAnchorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionAtAnchorMeta);
    }
    if (data.containsKey('wall_utc_at_anchor')) {
      context.handle(
        _wallUtcAtAnchorMeta,
        wallUtcAtAnchor.isAcceptableOrUnknown(
          data['wall_utc_at_anchor']!,
          _wallUtcAtAnchorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wallUtcAtAnchorMeta);
    }
    if (data.containsKey('estimated')) {
      context.handle(
        _estimatedMeta,
        estimated.isAcceptableOrUnknown(data['estimated']!, _estimatedMeta),
      );
    } else if (isInserting) {
      context.missing(_estimatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assessmentId, bootId};
  @override
  SessionTimeAnchorData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionTimeAnchorData(
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
      )!,
      bootId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boot_id'],
      )!,
      monoAtAnchor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mono_at_anchor'],
      )!,
      sessionAtAnchor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_at_anchor'],
      )!,
      wallUtcAtAnchor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wall_utc_at_anchor'],
      )!,
      estimated: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated'],
      )!,
    );
  }

  @override
  SessionTimeAnchor createAlias(String alias) {
    return SessionTimeAnchor(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(assessment_id, boot_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class SessionTimeAnchorData extends DataClass
    implements Insertable<SessionTimeAnchorData> {
  final String assessmentId;
  final String bootId;
  final int monoAtAnchor;
  final int sessionAtAnchor;
  final String wallUtcAtAnchor;
  final int estimated;
  const SessionTimeAnchorData({
    required this.assessmentId,
    required this.bootId,
    required this.monoAtAnchor,
    required this.sessionAtAnchor,
    required this.wallUtcAtAnchor,
    required this.estimated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assessment_id'] = Variable<String>(assessmentId);
    map['boot_id'] = Variable<String>(bootId);
    map['mono_at_anchor'] = Variable<int>(monoAtAnchor);
    map['session_at_anchor'] = Variable<int>(sessionAtAnchor);
    map['wall_utc_at_anchor'] = Variable<String>(wallUtcAtAnchor);
    map['estimated'] = Variable<int>(estimated);
    return map;
  }

  SessionTimeAnchorCompanion toCompanion(bool nullToAbsent) {
    return SessionTimeAnchorCompanion(
      assessmentId: Value(assessmentId),
      bootId: Value(bootId),
      monoAtAnchor: Value(monoAtAnchor),
      sessionAtAnchor: Value(sessionAtAnchor),
      wallUtcAtAnchor: Value(wallUtcAtAnchor),
      estimated: Value(estimated),
    );
  }

  factory SessionTimeAnchorData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionTimeAnchorData(
      assessmentId: serializer.fromJson<String>(json['assessment_id']),
      bootId: serializer.fromJson<String>(json['boot_id']),
      monoAtAnchor: serializer.fromJson<int>(json['mono_at_anchor']),
      sessionAtAnchor: serializer.fromJson<int>(json['session_at_anchor']),
      wallUtcAtAnchor: serializer.fromJson<String>(json['wall_utc_at_anchor']),
      estimated: serializer.fromJson<int>(json['estimated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assessment_id': serializer.toJson<String>(assessmentId),
      'boot_id': serializer.toJson<String>(bootId),
      'mono_at_anchor': serializer.toJson<int>(monoAtAnchor),
      'session_at_anchor': serializer.toJson<int>(sessionAtAnchor),
      'wall_utc_at_anchor': serializer.toJson<String>(wallUtcAtAnchor),
      'estimated': serializer.toJson<int>(estimated),
    };
  }

  SessionTimeAnchorData copyWith({
    String? assessmentId,
    String? bootId,
    int? monoAtAnchor,
    int? sessionAtAnchor,
    String? wallUtcAtAnchor,
    int? estimated,
  }) => SessionTimeAnchorData(
    assessmentId: assessmentId ?? this.assessmentId,
    bootId: bootId ?? this.bootId,
    monoAtAnchor: monoAtAnchor ?? this.monoAtAnchor,
    sessionAtAnchor: sessionAtAnchor ?? this.sessionAtAnchor,
    wallUtcAtAnchor: wallUtcAtAnchor ?? this.wallUtcAtAnchor,
    estimated: estimated ?? this.estimated,
  );
  SessionTimeAnchorData copyWithCompanion(SessionTimeAnchorCompanion data) {
    return SessionTimeAnchorData(
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      bootId: data.bootId.present ? data.bootId.value : this.bootId,
      monoAtAnchor: data.monoAtAnchor.present
          ? data.monoAtAnchor.value
          : this.monoAtAnchor,
      sessionAtAnchor: data.sessionAtAnchor.present
          ? data.sessionAtAnchor.value
          : this.sessionAtAnchor,
      wallUtcAtAnchor: data.wallUtcAtAnchor.present
          ? data.wallUtcAtAnchor.value
          : this.wallUtcAtAnchor,
      estimated: data.estimated.present ? data.estimated.value : this.estimated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionTimeAnchorData(')
          ..write('assessmentId: $assessmentId, ')
          ..write('bootId: $bootId, ')
          ..write('monoAtAnchor: $monoAtAnchor, ')
          ..write('sessionAtAnchor: $sessionAtAnchor, ')
          ..write('wallUtcAtAnchor: $wallUtcAtAnchor, ')
          ..write('estimated: $estimated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    assessmentId,
    bootId,
    monoAtAnchor,
    sessionAtAnchor,
    wallUtcAtAnchor,
    estimated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionTimeAnchorData &&
          other.assessmentId == this.assessmentId &&
          other.bootId == this.bootId &&
          other.monoAtAnchor == this.monoAtAnchor &&
          other.sessionAtAnchor == this.sessionAtAnchor &&
          other.wallUtcAtAnchor == this.wallUtcAtAnchor &&
          other.estimated == this.estimated);
}

class SessionTimeAnchorCompanion
    extends UpdateCompanion<SessionTimeAnchorData> {
  final Value<String> assessmentId;
  final Value<String> bootId;
  final Value<int> monoAtAnchor;
  final Value<int> sessionAtAnchor;
  final Value<String> wallUtcAtAnchor;
  final Value<int> estimated;
  final Value<int> rowid;
  const SessionTimeAnchorCompanion({
    this.assessmentId = const Value.absent(),
    this.bootId = const Value.absent(),
    this.monoAtAnchor = const Value.absent(),
    this.sessionAtAnchor = const Value.absent(),
    this.wallUtcAtAnchor = const Value.absent(),
    this.estimated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionTimeAnchorCompanion.insert({
    required String assessmentId,
    required String bootId,
    required int monoAtAnchor,
    required int sessionAtAnchor,
    required String wallUtcAtAnchor,
    required int estimated,
    this.rowid = const Value.absent(),
  }) : assessmentId = Value(assessmentId),
       bootId = Value(bootId),
       monoAtAnchor = Value(monoAtAnchor),
       sessionAtAnchor = Value(sessionAtAnchor),
       wallUtcAtAnchor = Value(wallUtcAtAnchor),
       estimated = Value(estimated);
  static Insertable<SessionTimeAnchorData> custom({
    Expression<String>? assessmentId,
    Expression<String>? bootId,
    Expression<int>? monoAtAnchor,
    Expression<int>? sessionAtAnchor,
    Expression<String>? wallUtcAtAnchor,
    Expression<int>? estimated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (bootId != null) 'boot_id': bootId,
      if (monoAtAnchor != null) 'mono_at_anchor': monoAtAnchor,
      if (sessionAtAnchor != null) 'session_at_anchor': sessionAtAnchor,
      if (wallUtcAtAnchor != null) 'wall_utc_at_anchor': wallUtcAtAnchor,
      if (estimated != null) 'estimated': estimated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionTimeAnchorCompanion copyWith({
    Value<String>? assessmentId,
    Value<String>? bootId,
    Value<int>? monoAtAnchor,
    Value<int>? sessionAtAnchor,
    Value<String>? wallUtcAtAnchor,
    Value<int>? estimated,
    Value<int>? rowid,
  }) {
    return SessionTimeAnchorCompanion(
      assessmentId: assessmentId ?? this.assessmentId,
      bootId: bootId ?? this.bootId,
      monoAtAnchor: monoAtAnchor ?? this.monoAtAnchor,
      sessionAtAnchor: sessionAtAnchor ?? this.sessionAtAnchor,
      wallUtcAtAnchor: wallUtcAtAnchor ?? this.wallUtcAtAnchor,
      estimated: estimated ?? this.estimated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (bootId.present) {
      map['boot_id'] = Variable<String>(bootId.value);
    }
    if (monoAtAnchor.present) {
      map['mono_at_anchor'] = Variable<int>(monoAtAnchor.value);
    }
    if (sessionAtAnchor.present) {
      map['session_at_anchor'] = Variable<int>(sessionAtAnchor.value);
    }
    if (wallUtcAtAnchor.present) {
      map['wall_utc_at_anchor'] = Variable<String>(wallUtcAtAnchor.value);
    }
    if (estimated.present) {
      map['estimated'] = Variable<int>(estimated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionTimeAnchorCompanion(')
          ..write('assessmentId: $assessmentId, ')
          ..write('bootId: $bootId, ')
          ..write('monoAtAnchor: $monoAtAnchor, ')
          ..write('sessionAtAnchor: $sessionAtAnchor, ')
          ..write('wallUtcAtAnchor: $wallUtcAtAnchor, ')
          ..write('estimated: $estimated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Incident extends Table with TableInfo<Incident, IncidentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Incident(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _assessmentIdMeta = const VerificationMeta(
    'assessmentId',
  );
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES assessment(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tSessionMsMeta = const VerificationMeta(
    'tSessionMs',
  );
  late final GeneratedColumn<int> tSessionMs = GeneratedColumn<int>(
    't_session_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _wallUtcMeta = const VerificationMeta(
    'wallUtc',
  );
  late final GeneratedColumn<String> wallUtc = GeneratedColumn<String>(
    'wall_utc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (period IN (\'H1\', \'H2\', \'ET1\', \'ET2\', \'SD\'))',
  );
  static const VerificationMeta _phaseLabelMeta = const VerificationMeta(
    'phaseLabel',
  );
  late final GeneratedColumn<String> phaseLabel = GeneratedColumn<String>(
    'phase_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (phase_label IN (\'PRE_MATCH\', \'IN_PLAY\', \'TIME_OFF\', \'INTERVAL\', \'FULL_TIME\'))',
  );
  static const VerificationMeta _periodElapsedMsMeta = const VerificationMeta(
    'periodElapsedMs',
  );
  late final GeneratedColumn<int> periodElapsedMs = GeneratedColumn<int>(
    'period_elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _matchClockMsMeta = const VerificationMeta(
    'matchClockMs',
  );
  late final GeneratedColumn<int> matchClockMs = GeneratedColumn<int>(
    'match_clock_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _overtimeMsMeta = const VerificationMeta(
    'overtimeMs',
  );
  late final GeneratedColumn<int> overtimeMs = GeneratedColumn<int>(
    'overtime_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _timeIntegrityMeta = const VerificationMeta(
    'timeIntegrity',
  );
  late final GeneratedColumn<String> timeIntegrity = GeneratedColumn<String>(
    'time_integrity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (time_integrity IN (\'OK\', \'DEGRADED\'))',
  );
  static const VerificationMeta _timeManualOverrideMeta =
      const VerificationMeta('timeManualOverride');
  late final GeneratedColumn<int> timeManualOverride = GeneratedColumn<int>(
    'time_manual_override',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT 0 CHECK (time_manual_override IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _criterionCodeMeta = const VerificationMeta(
    'criterionCode',
  );
  late final GeneratedColumn<String> criterionCode = GeneratedColumn<String>(
    'criterion_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _polarityMeta = const VerificationMeta(
    'polarity',
  );
  late final GeneratedColumn<String> polarity = GeneratedColumn<String>(
    'polarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (polarity IN (\'POSITIVE\', \'NEGATIVE\', \'REVIEW\'))',
  );
  static const VerificationMeta _gamePhaseMeta = const VerificationMeta(
    'gamePhase',
  );
  late final GeneratedColumn<String> gamePhase = GeneratedColumn<String>(
    'game_phase',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _fieldZoneMeta = const VerificationMeta(
    'fieldZone',
  );
  late final GeneratedColumn<String> fieldZone = GeneratedColumn<String>(
    'field_zone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _decisionTakenJsonMeta = const VerificationMeta(
    'decisionTakenJson',
  );
  late final GeneratedColumn<String> decisionTakenJson =
      GeneratedColumn<String>(
        'decision_taken_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'CHECK (decision_taken_json IS NULL OR json_valid(decision_taken_json))',
      );
  static const VerificationMeta _decisionExpectedJsonMeta =
      const VerificationMeta('decisionExpectedJson');
  late final GeneratedColumn<String> decisionExpectedJson =
      GeneratedColumn<String>(
        'decision_expected_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'CHECK (decision_expected_json IS NULL OR json_valid(decision_expected_json))',
      );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (verdict IN (\'PENDING\', \'CORRECT\', \'INCORRECT\', \'MISSED\', \'DEBATABLE\', \'NOT_ASSESSABLE\'))',
  );
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  late final GeneratedColumn<String> impact = GeneratedColumn<String>(
    'impact',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (impact IN (\'LOW\', \'MEDIUM\', \'HIGH\', \'MATCH_DEFINING\'))',
  );
  static const VerificationMeta _impactConfirmedMeta = const VerificationMeta(
    'impactConfirmed',
  );
  late final GeneratedColumn<int> impactConfirmed = GeneratedColumn<int>(
    'impact_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (impact_confirmed IN (0, 1))',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (source IN (\'ONE_TAP\', \'MANUAL\', \'VIDEO_REVIEW\'))',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (status IN (\'QUICK\', \'ENRICHED\', \'VOID\'))',
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assessmentId,
    seq,
    tSessionMs,
    wallUtc,
    period,
    phaseLabel,
    periodElapsedMs,
    matchClockMs,
    overtimeMs,
    timeIntegrity,
    timeManualOverride,
    category,
    criterionCode,
    polarity,
    gamePhase,
    fieldZone,
    decisionTakenJson,
    decisionExpectedJson,
    verdict,
    impact,
    impactConfirmed,
    notes,
    source,
    status,
    voidReason,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incident';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncidentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assessment_id')) {
      context.handle(
        _assessmentIdMeta,
        assessmentId.isAcceptableOrUnknown(
          data['assessment_id']!,
          _assessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('t_session_ms')) {
      context.handle(
        _tSessionMsMeta,
        tSessionMs.isAcceptableOrUnknown(
          data['t_session_ms']!,
          _tSessionMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tSessionMsMeta);
    }
    if (data.containsKey('wall_utc')) {
      context.handle(
        _wallUtcMeta,
        wallUtc.isAcceptableOrUnknown(data['wall_utc']!, _wallUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_wallUtcMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('phase_label')) {
      context.handle(
        _phaseLabelMeta,
        phaseLabel.isAcceptableOrUnknown(data['phase_label']!, _phaseLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseLabelMeta);
    }
    if (data.containsKey('period_elapsed_ms')) {
      context.handle(
        _periodElapsedMsMeta,
        periodElapsedMs.isAcceptableOrUnknown(
          data['period_elapsed_ms']!,
          _periodElapsedMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodElapsedMsMeta);
    }
    if (data.containsKey('match_clock_ms')) {
      context.handle(
        _matchClockMsMeta,
        matchClockMs.isAcceptableOrUnknown(
          data['match_clock_ms']!,
          _matchClockMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_matchClockMsMeta);
    }
    if (data.containsKey('overtime_ms')) {
      context.handle(
        _overtimeMsMeta,
        overtimeMs.isAcceptableOrUnknown(data['overtime_ms']!, _overtimeMsMeta),
      );
    }
    if (data.containsKey('time_integrity')) {
      context.handle(
        _timeIntegrityMeta,
        timeIntegrity.isAcceptableOrUnknown(
          data['time_integrity']!,
          _timeIntegrityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeIntegrityMeta);
    }
    if (data.containsKey('time_manual_override')) {
      context.handle(
        _timeManualOverrideMeta,
        timeManualOverride.isAcceptableOrUnknown(
          data['time_manual_override']!,
          _timeManualOverrideMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('criterion_code')) {
      context.handle(
        _criterionCodeMeta,
        criterionCode.isAcceptableOrUnknown(
          data['criterion_code']!,
          _criterionCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_criterionCodeMeta);
    }
    if (data.containsKey('polarity')) {
      context.handle(
        _polarityMeta,
        polarity.isAcceptableOrUnknown(data['polarity']!, _polarityMeta),
      );
    } else if (isInserting) {
      context.missing(_polarityMeta);
    }
    if (data.containsKey('game_phase')) {
      context.handle(
        _gamePhaseMeta,
        gamePhase.isAcceptableOrUnknown(data['game_phase']!, _gamePhaseMeta),
      );
    }
    if (data.containsKey('field_zone')) {
      context.handle(
        _fieldZoneMeta,
        fieldZone.isAcceptableOrUnknown(data['field_zone']!, _fieldZoneMeta),
      );
    }
    if (data.containsKey('decision_taken_json')) {
      context.handle(
        _decisionTakenJsonMeta,
        decisionTakenJson.isAcceptableOrUnknown(
          data['decision_taken_json']!,
          _decisionTakenJsonMeta,
        ),
      );
    }
    if (data.containsKey('decision_expected_json')) {
      context.handle(
        _decisionExpectedJsonMeta,
        decisionExpectedJson.isAcceptableOrUnknown(
          data['decision_expected_json']!,
          _decisionExpectedJsonMeta,
        ),
      );
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    } else if (isInserting) {
      context.missing(_verdictMeta);
    }
    if (data.containsKey('impact')) {
      context.handle(
        _impactMeta,
        impact.isAcceptableOrUnknown(data['impact']!, _impactMeta),
      );
    } else if (isInserting) {
      context.missing(_impactMeta);
    }
    if (data.containsKey('impact_confirmed')) {
      context.handle(
        _impactConfirmedMeta,
        impactConfirmed.isAcceptableOrUnknown(
          data['impact_confirmed']!,
          _impactConfirmedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_impactConfirmedMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {assessmentId, seq},
  ];
  @override
  IncidentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncidentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      tSessionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}t_session_ms'],
      )!,
      wallUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wall_utc'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      ),
      phaseLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase_label'],
      )!,
      periodElapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_elapsed_ms'],
      )!,
      matchClockMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}match_clock_ms'],
      )!,
      overtimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overtime_ms'],
      )!,
      timeIntegrity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_integrity'],
      )!,
      timeManualOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_manual_override'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      criterionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criterion_code'],
      )!,
      polarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polarity'],
      )!,
      gamePhase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_phase'],
      ),
      fieldZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_zone'],
      ),
      decisionTakenJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_taken_json'],
      ),
      decisionExpectedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_expected_json'],
      ),
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      )!,
      impact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}impact'],
      )!,
      impactConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}impact_confirmed'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Incident createAlias(String alias) {
    return Incident(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const ['UNIQUE(assessment_id, seq)'];
  @override
  bool get dontWriteConstraints => true;
}

class IncidentData extends DataClass implements Insertable<IncidentData> {
  final String id;
  final String assessmentId;
  final int seq;
  final int tSessionMs;
  final String wallUtc;

  /// tiempo de partido desnormalizado en la captura
  final String? period;
  final String phaseLabel;
  final int periodElapsedMs;
  final int matchClockMs;
  final int overtimeMs;
  final String timeIntegrity;
  final int timeManualOverride;

  /// clasificación
  final String category;
  final String criterionCode;
  final String polarity;
  final String? gamePhase;
  final String? fieldZone;
  final String? decisionTakenJson;
  final String? decisionExpectedJson;
  final String verdict;
  final String impact;
  final int impactConfirmed;
  final String? notes;
  final String source;
  final String status;
  final String? voidReason;
  final String updatedAt;
  const IncidentData({
    required this.id,
    required this.assessmentId,
    required this.seq,
    required this.tSessionMs,
    required this.wallUtc,
    this.period,
    required this.phaseLabel,
    required this.periodElapsedMs,
    required this.matchClockMs,
    required this.overtimeMs,
    required this.timeIntegrity,
    required this.timeManualOverride,
    required this.category,
    required this.criterionCode,
    required this.polarity,
    this.gamePhase,
    this.fieldZone,
    this.decisionTakenJson,
    this.decisionExpectedJson,
    required this.verdict,
    required this.impact,
    required this.impactConfirmed,
    this.notes,
    required this.source,
    required this.status,
    this.voidReason,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['assessment_id'] = Variable<String>(assessmentId);
    map['seq'] = Variable<int>(seq);
    map['t_session_ms'] = Variable<int>(tSessionMs);
    map['wall_utc'] = Variable<String>(wallUtc);
    if (!nullToAbsent || period != null) {
      map['period'] = Variable<String>(period);
    }
    map['phase_label'] = Variable<String>(phaseLabel);
    map['period_elapsed_ms'] = Variable<int>(periodElapsedMs);
    map['match_clock_ms'] = Variable<int>(matchClockMs);
    map['overtime_ms'] = Variable<int>(overtimeMs);
    map['time_integrity'] = Variable<String>(timeIntegrity);
    map['time_manual_override'] = Variable<int>(timeManualOverride);
    map['category'] = Variable<String>(category);
    map['criterion_code'] = Variable<String>(criterionCode);
    map['polarity'] = Variable<String>(polarity);
    if (!nullToAbsent || gamePhase != null) {
      map['game_phase'] = Variable<String>(gamePhase);
    }
    if (!nullToAbsent || fieldZone != null) {
      map['field_zone'] = Variable<String>(fieldZone);
    }
    if (!nullToAbsent || decisionTakenJson != null) {
      map['decision_taken_json'] = Variable<String>(decisionTakenJson);
    }
    if (!nullToAbsent || decisionExpectedJson != null) {
      map['decision_expected_json'] = Variable<String>(decisionExpectedJson);
    }
    map['verdict'] = Variable<String>(verdict);
    map['impact'] = Variable<String>(impact);
    map['impact_confirmed'] = Variable<int>(impactConfirmed);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  IncidentCompanion toCompanion(bool nullToAbsent) {
    return IncidentCompanion(
      id: Value(id),
      assessmentId: Value(assessmentId),
      seq: Value(seq),
      tSessionMs: Value(tSessionMs),
      wallUtc: Value(wallUtc),
      period: period == null && nullToAbsent
          ? const Value.absent()
          : Value(period),
      phaseLabel: Value(phaseLabel),
      periodElapsedMs: Value(periodElapsedMs),
      matchClockMs: Value(matchClockMs),
      overtimeMs: Value(overtimeMs),
      timeIntegrity: Value(timeIntegrity),
      timeManualOverride: Value(timeManualOverride),
      category: Value(category),
      criterionCode: Value(criterionCode),
      polarity: Value(polarity),
      gamePhase: gamePhase == null && nullToAbsent
          ? const Value.absent()
          : Value(gamePhase),
      fieldZone: fieldZone == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldZone),
      decisionTakenJson: decisionTakenJson == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionTakenJson),
      decisionExpectedJson: decisionExpectedJson == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionExpectedJson),
      verdict: Value(verdict),
      impact: Value(impact),
      impactConfirmed: Value(impactConfirmed),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      source: Value(source),
      status: Value(status),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      updatedAt: Value(updatedAt),
    );
  }

  factory IncidentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncidentData(
      id: serializer.fromJson<String>(json['id']),
      assessmentId: serializer.fromJson<String>(json['assessment_id']),
      seq: serializer.fromJson<int>(json['seq']),
      tSessionMs: serializer.fromJson<int>(json['t_session_ms']),
      wallUtc: serializer.fromJson<String>(json['wall_utc']),
      period: serializer.fromJson<String?>(json['period']),
      phaseLabel: serializer.fromJson<String>(json['phase_label']),
      periodElapsedMs: serializer.fromJson<int>(json['period_elapsed_ms']),
      matchClockMs: serializer.fromJson<int>(json['match_clock_ms']),
      overtimeMs: serializer.fromJson<int>(json['overtime_ms']),
      timeIntegrity: serializer.fromJson<String>(json['time_integrity']),
      timeManualOverride: serializer.fromJson<int>(
        json['time_manual_override'],
      ),
      category: serializer.fromJson<String>(json['category']),
      criterionCode: serializer.fromJson<String>(json['criterion_code']),
      polarity: serializer.fromJson<String>(json['polarity']),
      gamePhase: serializer.fromJson<String?>(json['game_phase']),
      fieldZone: serializer.fromJson<String?>(json['field_zone']),
      decisionTakenJson: serializer.fromJson<String?>(
        json['decision_taken_json'],
      ),
      decisionExpectedJson: serializer.fromJson<String?>(
        json['decision_expected_json'],
      ),
      verdict: serializer.fromJson<String>(json['verdict']),
      impact: serializer.fromJson<String>(json['impact']),
      impactConfirmed: serializer.fromJson<int>(json['impact_confirmed']),
      notes: serializer.fromJson<String?>(json['notes']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      voidReason: serializer.fromJson<String?>(json['void_reason']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessment_id': serializer.toJson<String>(assessmentId),
      'seq': serializer.toJson<int>(seq),
      't_session_ms': serializer.toJson<int>(tSessionMs),
      'wall_utc': serializer.toJson<String>(wallUtc),
      'period': serializer.toJson<String?>(period),
      'phase_label': serializer.toJson<String>(phaseLabel),
      'period_elapsed_ms': serializer.toJson<int>(periodElapsedMs),
      'match_clock_ms': serializer.toJson<int>(matchClockMs),
      'overtime_ms': serializer.toJson<int>(overtimeMs),
      'time_integrity': serializer.toJson<String>(timeIntegrity),
      'time_manual_override': serializer.toJson<int>(timeManualOverride),
      'category': serializer.toJson<String>(category),
      'criterion_code': serializer.toJson<String>(criterionCode),
      'polarity': serializer.toJson<String>(polarity),
      'game_phase': serializer.toJson<String?>(gamePhase),
      'field_zone': serializer.toJson<String?>(fieldZone),
      'decision_taken_json': serializer.toJson<String?>(decisionTakenJson),
      'decision_expected_json': serializer.toJson<String?>(
        decisionExpectedJson,
      ),
      'verdict': serializer.toJson<String>(verdict),
      'impact': serializer.toJson<String>(impact),
      'impact_confirmed': serializer.toJson<int>(impactConfirmed),
      'notes': serializer.toJson<String?>(notes),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
      'void_reason': serializer.toJson<String?>(voidReason),
      'updated_at': serializer.toJson<String>(updatedAt),
    };
  }

  IncidentData copyWith({
    String? id,
    String? assessmentId,
    int? seq,
    int? tSessionMs,
    String? wallUtc,
    Value<String?> period = const Value.absent(),
    String? phaseLabel,
    int? periodElapsedMs,
    int? matchClockMs,
    int? overtimeMs,
    String? timeIntegrity,
    int? timeManualOverride,
    String? category,
    String? criterionCode,
    String? polarity,
    Value<String?> gamePhase = const Value.absent(),
    Value<String?> fieldZone = const Value.absent(),
    Value<String?> decisionTakenJson = const Value.absent(),
    Value<String?> decisionExpectedJson = const Value.absent(),
    String? verdict,
    String? impact,
    int? impactConfirmed,
    Value<String?> notes = const Value.absent(),
    String? source,
    String? status,
    Value<String?> voidReason = const Value.absent(),
    String? updatedAt,
  }) => IncidentData(
    id: id ?? this.id,
    assessmentId: assessmentId ?? this.assessmentId,
    seq: seq ?? this.seq,
    tSessionMs: tSessionMs ?? this.tSessionMs,
    wallUtc: wallUtc ?? this.wallUtc,
    period: period.present ? period.value : this.period,
    phaseLabel: phaseLabel ?? this.phaseLabel,
    periodElapsedMs: periodElapsedMs ?? this.periodElapsedMs,
    matchClockMs: matchClockMs ?? this.matchClockMs,
    overtimeMs: overtimeMs ?? this.overtimeMs,
    timeIntegrity: timeIntegrity ?? this.timeIntegrity,
    timeManualOverride: timeManualOverride ?? this.timeManualOverride,
    category: category ?? this.category,
    criterionCode: criterionCode ?? this.criterionCode,
    polarity: polarity ?? this.polarity,
    gamePhase: gamePhase.present ? gamePhase.value : this.gamePhase,
    fieldZone: fieldZone.present ? fieldZone.value : this.fieldZone,
    decisionTakenJson: decisionTakenJson.present
        ? decisionTakenJson.value
        : this.decisionTakenJson,
    decisionExpectedJson: decisionExpectedJson.present
        ? decisionExpectedJson.value
        : this.decisionExpectedJson,
    verdict: verdict ?? this.verdict,
    impact: impact ?? this.impact,
    impactConfirmed: impactConfirmed ?? this.impactConfirmed,
    notes: notes.present ? notes.value : this.notes,
    source: source ?? this.source,
    status: status ?? this.status,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  IncidentData copyWithCompanion(IncidentCompanion data) {
    return IncidentData(
      id: data.id.present ? data.id.value : this.id,
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      seq: data.seq.present ? data.seq.value : this.seq,
      tSessionMs: data.tSessionMs.present
          ? data.tSessionMs.value
          : this.tSessionMs,
      wallUtc: data.wallUtc.present ? data.wallUtc.value : this.wallUtc,
      period: data.period.present ? data.period.value : this.period,
      phaseLabel: data.phaseLabel.present
          ? data.phaseLabel.value
          : this.phaseLabel,
      periodElapsedMs: data.periodElapsedMs.present
          ? data.periodElapsedMs.value
          : this.periodElapsedMs,
      matchClockMs: data.matchClockMs.present
          ? data.matchClockMs.value
          : this.matchClockMs,
      overtimeMs: data.overtimeMs.present
          ? data.overtimeMs.value
          : this.overtimeMs,
      timeIntegrity: data.timeIntegrity.present
          ? data.timeIntegrity.value
          : this.timeIntegrity,
      timeManualOverride: data.timeManualOverride.present
          ? data.timeManualOverride.value
          : this.timeManualOverride,
      category: data.category.present ? data.category.value : this.category,
      criterionCode: data.criterionCode.present
          ? data.criterionCode.value
          : this.criterionCode,
      polarity: data.polarity.present ? data.polarity.value : this.polarity,
      gamePhase: data.gamePhase.present ? data.gamePhase.value : this.gamePhase,
      fieldZone: data.fieldZone.present ? data.fieldZone.value : this.fieldZone,
      decisionTakenJson: data.decisionTakenJson.present
          ? data.decisionTakenJson.value
          : this.decisionTakenJson,
      decisionExpectedJson: data.decisionExpectedJson.present
          ? data.decisionExpectedJson.value
          : this.decisionExpectedJson,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      impact: data.impact.present ? data.impact.value : this.impact,
      impactConfirmed: data.impactConfirmed.present
          ? data.impactConfirmed.value
          : this.impactConfirmed,
      notes: data.notes.present ? data.notes.value : this.notes,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncidentData(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('seq: $seq, ')
          ..write('tSessionMs: $tSessionMs, ')
          ..write('wallUtc: $wallUtc, ')
          ..write('period: $period, ')
          ..write('phaseLabel: $phaseLabel, ')
          ..write('periodElapsedMs: $periodElapsedMs, ')
          ..write('matchClockMs: $matchClockMs, ')
          ..write('overtimeMs: $overtimeMs, ')
          ..write('timeIntegrity: $timeIntegrity, ')
          ..write('timeManualOverride: $timeManualOverride, ')
          ..write('category: $category, ')
          ..write('criterionCode: $criterionCode, ')
          ..write('polarity: $polarity, ')
          ..write('gamePhase: $gamePhase, ')
          ..write('fieldZone: $fieldZone, ')
          ..write('decisionTakenJson: $decisionTakenJson, ')
          ..write('decisionExpectedJson: $decisionExpectedJson, ')
          ..write('verdict: $verdict, ')
          ..write('impact: $impact, ')
          ..write('impactConfirmed: $impactConfirmed, ')
          ..write('notes: $notes, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('voidReason: $voidReason, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    assessmentId,
    seq,
    tSessionMs,
    wallUtc,
    period,
    phaseLabel,
    periodElapsedMs,
    matchClockMs,
    overtimeMs,
    timeIntegrity,
    timeManualOverride,
    category,
    criterionCode,
    polarity,
    gamePhase,
    fieldZone,
    decisionTakenJson,
    decisionExpectedJson,
    verdict,
    impact,
    impactConfirmed,
    notes,
    source,
    status,
    voidReason,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncidentData &&
          other.id == this.id &&
          other.assessmentId == this.assessmentId &&
          other.seq == this.seq &&
          other.tSessionMs == this.tSessionMs &&
          other.wallUtc == this.wallUtc &&
          other.period == this.period &&
          other.phaseLabel == this.phaseLabel &&
          other.periodElapsedMs == this.periodElapsedMs &&
          other.matchClockMs == this.matchClockMs &&
          other.overtimeMs == this.overtimeMs &&
          other.timeIntegrity == this.timeIntegrity &&
          other.timeManualOverride == this.timeManualOverride &&
          other.category == this.category &&
          other.criterionCode == this.criterionCode &&
          other.polarity == this.polarity &&
          other.gamePhase == this.gamePhase &&
          other.fieldZone == this.fieldZone &&
          other.decisionTakenJson == this.decisionTakenJson &&
          other.decisionExpectedJson == this.decisionExpectedJson &&
          other.verdict == this.verdict &&
          other.impact == this.impact &&
          other.impactConfirmed == this.impactConfirmed &&
          other.notes == this.notes &&
          other.source == this.source &&
          other.status == this.status &&
          other.voidReason == this.voidReason &&
          other.updatedAt == this.updatedAt);
}

class IncidentCompanion extends UpdateCompanion<IncidentData> {
  final Value<String> id;
  final Value<String> assessmentId;
  final Value<int> seq;
  final Value<int> tSessionMs;
  final Value<String> wallUtc;
  final Value<String?> period;
  final Value<String> phaseLabel;
  final Value<int> periodElapsedMs;
  final Value<int> matchClockMs;
  final Value<int> overtimeMs;
  final Value<String> timeIntegrity;
  final Value<int> timeManualOverride;
  final Value<String> category;
  final Value<String> criterionCode;
  final Value<String> polarity;
  final Value<String?> gamePhase;
  final Value<String?> fieldZone;
  final Value<String?> decisionTakenJson;
  final Value<String?> decisionExpectedJson;
  final Value<String> verdict;
  final Value<String> impact;
  final Value<int> impactConfirmed;
  final Value<String?> notes;
  final Value<String> source;
  final Value<String> status;
  final Value<String?> voidReason;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const IncidentCompanion({
    this.id = const Value.absent(),
    this.assessmentId = const Value.absent(),
    this.seq = const Value.absent(),
    this.tSessionMs = const Value.absent(),
    this.wallUtc = const Value.absent(),
    this.period = const Value.absent(),
    this.phaseLabel = const Value.absent(),
    this.periodElapsedMs = const Value.absent(),
    this.matchClockMs = const Value.absent(),
    this.overtimeMs = const Value.absent(),
    this.timeIntegrity = const Value.absent(),
    this.timeManualOverride = const Value.absent(),
    this.category = const Value.absent(),
    this.criterionCode = const Value.absent(),
    this.polarity = const Value.absent(),
    this.gamePhase = const Value.absent(),
    this.fieldZone = const Value.absent(),
    this.decisionTakenJson = const Value.absent(),
    this.decisionExpectedJson = const Value.absent(),
    this.verdict = const Value.absent(),
    this.impact = const Value.absent(),
    this.impactConfirmed = const Value.absent(),
    this.notes = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncidentCompanion.insert({
    required String id,
    required String assessmentId,
    required int seq,
    required int tSessionMs,
    required String wallUtc,
    this.period = const Value.absent(),
    required String phaseLabel,
    required int periodElapsedMs,
    required int matchClockMs,
    this.overtimeMs = const Value.absent(),
    required String timeIntegrity,
    this.timeManualOverride = const Value.absent(),
    required String category,
    required String criterionCode,
    required String polarity,
    this.gamePhase = const Value.absent(),
    this.fieldZone = const Value.absent(),
    this.decisionTakenJson = const Value.absent(),
    this.decisionExpectedJson = const Value.absent(),
    required String verdict,
    required String impact,
    required int impactConfirmed,
    this.notes = const Value.absent(),
    required String source,
    required String status,
    this.voidReason = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assessmentId = Value(assessmentId),
       seq = Value(seq),
       tSessionMs = Value(tSessionMs),
       wallUtc = Value(wallUtc),
       phaseLabel = Value(phaseLabel),
       periodElapsedMs = Value(periodElapsedMs),
       matchClockMs = Value(matchClockMs),
       timeIntegrity = Value(timeIntegrity),
       category = Value(category),
       criterionCode = Value(criterionCode),
       polarity = Value(polarity),
       verdict = Value(verdict),
       impact = Value(impact),
       impactConfirmed = Value(impactConfirmed),
       source = Value(source),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<IncidentData> custom({
    Expression<String>? id,
    Expression<String>? assessmentId,
    Expression<int>? seq,
    Expression<int>? tSessionMs,
    Expression<String>? wallUtc,
    Expression<String>? period,
    Expression<String>? phaseLabel,
    Expression<int>? periodElapsedMs,
    Expression<int>? matchClockMs,
    Expression<int>? overtimeMs,
    Expression<String>? timeIntegrity,
    Expression<int>? timeManualOverride,
    Expression<String>? category,
    Expression<String>? criterionCode,
    Expression<String>? polarity,
    Expression<String>? gamePhase,
    Expression<String>? fieldZone,
    Expression<String>? decisionTakenJson,
    Expression<String>? decisionExpectedJson,
    Expression<String>? verdict,
    Expression<String>? impact,
    Expression<int>? impactConfirmed,
    Expression<String>? notes,
    Expression<String>? source,
    Expression<String>? status,
    Expression<String>? voidReason,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (seq != null) 'seq': seq,
      if (tSessionMs != null) 't_session_ms': tSessionMs,
      if (wallUtc != null) 'wall_utc': wallUtc,
      if (period != null) 'period': period,
      if (phaseLabel != null) 'phase_label': phaseLabel,
      if (periodElapsedMs != null) 'period_elapsed_ms': periodElapsedMs,
      if (matchClockMs != null) 'match_clock_ms': matchClockMs,
      if (overtimeMs != null) 'overtime_ms': overtimeMs,
      if (timeIntegrity != null) 'time_integrity': timeIntegrity,
      if (timeManualOverride != null)
        'time_manual_override': timeManualOverride,
      if (category != null) 'category': category,
      if (criterionCode != null) 'criterion_code': criterionCode,
      if (polarity != null) 'polarity': polarity,
      if (gamePhase != null) 'game_phase': gamePhase,
      if (fieldZone != null) 'field_zone': fieldZone,
      if (decisionTakenJson != null) 'decision_taken_json': decisionTakenJson,
      if (decisionExpectedJson != null)
        'decision_expected_json': decisionExpectedJson,
      if (verdict != null) 'verdict': verdict,
      if (impact != null) 'impact': impact,
      if (impactConfirmed != null) 'impact_confirmed': impactConfirmed,
      if (notes != null) 'notes': notes,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (voidReason != null) 'void_reason': voidReason,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncidentCompanion copyWith({
    Value<String>? id,
    Value<String>? assessmentId,
    Value<int>? seq,
    Value<int>? tSessionMs,
    Value<String>? wallUtc,
    Value<String?>? period,
    Value<String>? phaseLabel,
    Value<int>? periodElapsedMs,
    Value<int>? matchClockMs,
    Value<int>? overtimeMs,
    Value<String>? timeIntegrity,
    Value<int>? timeManualOverride,
    Value<String>? category,
    Value<String>? criterionCode,
    Value<String>? polarity,
    Value<String?>? gamePhase,
    Value<String?>? fieldZone,
    Value<String?>? decisionTakenJson,
    Value<String?>? decisionExpectedJson,
    Value<String>? verdict,
    Value<String>? impact,
    Value<int>? impactConfirmed,
    Value<String?>? notes,
    Value<String>? source,
    Value<String>? status,
    Value<String?>? voidReason,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return IncidentCompanion(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
      seq: seq ?? this.seq,
      tSessionMs: tSessionMs ?? this.tSessionMs,
      wallUtc: wallUtc ?? this.wallUtc,
      period: period ?? this.period,
      phaseLabel: phaseLabel ?? this.phaseLabel,
      periodElapsedMs: periodElapsedMs ?? this.periodElapsedMs,
      matchClockMs: matchClockMs ?? this.matchClockMs,
      overtimeMs: overtimeMs ?? this.overtimeMs,
      timeIntegrity: timeIntegrity ?? this.timeIntegrity,
      timeManualOverride: timeManualOverride ?? this.timeManualOverride,
      category: category ?? this.category,
      criterionCode: criterionCode ?? this.criterionCode,
      polarity: polarity ?? this.polarity,
      gamePhase: gamePhase ?? this.gamePhase,
      fieldZone: fieldZone ?? this.fieldZone,
      decisionTakenJson: decisionTakenJson ?? this.decisionTakenJson,
      decisionExpectedJson: decisionExpectedJson ?? this.decisionExpectedJson,
      verdict: verdict ?? this.verdict,
      impact: impact ?? this.impact,
      impactConfirmed: impactConfirmed ?? this.impactConfirmed,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      status: status ?? this.status,
      voidReason: voidReason ?? this.voidReason,
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
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (tSessionMs.present) {
      map['t_session_ms'] = Variable<int>(tSessionMs.value);
    }
    if (wallUtc.present) {
      map['wall_utc'] = Variable<String>(wallUtc.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (phaseLabel.present) {
      map['phase_label'] = Variable<String>(phaseLabel.value);
    }
    if (periodElapsedMs.present) {
      map['period_elapsed_ms'] = Variable<int>(periodElapsedMs.value);
    }
    if (matchClockMs.present) {
      map['match_clock_ms'] = Variable<int>(matchClockMs.value);
    }
    if (overtimeMs.present) {
      map['overtime_ms'] = Variable<int>(overtimeMs.value);
    }
    if (timeIntegrity.present) {
      map['time_integrity'] = Variable<String>(timeIntegrity.value);
    }
    if (timeManualOverride.present) {
      map['time_manual_override'] = Variable<int>(timeManualOverride.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (criterionCode.present) {
      map['criterion_code'] = Variable<String>(criterionCode.value);
    }
    if (polarity.present) {
      map['polarity'] = Variable<String>(polarity.value);
    }
    if (gamePhase.present) {
      map['game_phase'] = Variable<String>(gamePhase.value);
    }
    if (fieldZone.present) {
      map['field_zone'] = Variable<String>(fieldZone.value);
    }
    if (decisionTakenJson.present) {
      map['decision_taken_json'] = Variable<String>(decisionTakenJson.value);
    }
    if (decisionExpectedJson.present) {
      map['decision_expected_json'] = Variable<String>(
        decisionExpectedJson.value,
      );
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (impact.present) {
      map['impact'] = Variable<String>(impact.value);
    }
    if (impactConfirmed.present) {
      map['impact_confirmed'] = Variable<int>(impactConfirmed.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentCompanion(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('seq: $seq, ')
          ..write('tSessionMs: $tSessionMs, ')
          ..write('wallUtc: $wallUtc, ')
          ..write('period: $period, ')
          ..write('phaseLabel: $phaseLabel, ')
          ..write('periodElapsedMs: $periodElapsedMs, ')
          ..write('matchClockMs: $matchClockMs, ')
          ..write('overtimeMs: $overtimeMs, ')
          ..write('timeIntegrity: $timeIntegrity, ')
          ..write('timeManualOverride: $timeManualOverride, ')
          ..write('category: $category, ')
          ..write('criterionCode: $criterionCode, ')
          ..write('polarity: $polarity, ')
          ..write('gamePhase: $gamePhase, ')
          ..write('fieldZone: $fieldZone, ')
          ..write('decisionTakenJson: $decisionTakenJson, ')
          ..write('decisionExpectedJson: $decisionExpectedJson, ')
          ..write('verdict: $verdict, ')
          ..write('impact: $impact, ')
          ..write('impactConfirmed: $impactConfirmed, ')
          ..write('notes: $notes, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('voidReason: $voidReason, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class IncidentRevision extends Table
    with TableInfo<IncidentRevision, IncidentRevisionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  IncidentRevision(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _incidentIdMeta = const VerificationMeta(
    'incidentId',
  );
  late final GeneratedColumn<String> incidentId = GeneratedColumn<String>(
    'incident_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES incident(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _revisedAtMeta = const VerificationMeta(
    'revisedAt',
  );
  late final GeneratedColumn<String> revisedAt = GeneratedColumn<String>(
    'revised_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _previousJsonMeta = const VerificationMeta(
    'previousJson',
  );
  late final GeneratedColumn<String> previousJson = GeneratedColumn<String>(
    'previous_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (json_valid(previous_json))',
  );
  @override
  List<GeneratedColumn> get $columns => [incidentId, revisedAt, previousJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incident_revision';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncidentRevisionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('incident_id')) {
      context.handle(
        _incidentIdMeta,
        incidentId.isAcceptableOrUnknown(data['incident_id']!, _incidentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_incidentIdMeta);
    }
    if (data.containsKey('revised_at')) {
      context.handle(
        _revisedAtMeta,
        revisedAt.isAcceptableOrUnknown(data['revised_at']!, _revisedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_revisedAtMeta);
    }
    if (data.containsKey('previous_json')) {
      context.handle(
        _previousJsonMeta,
        previousJson.isAcceptableOrUnknown(
          data['previous_json']!,
          _previousJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  IncidentRevisionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncidentRevisionData(
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incident_id'],
      )!,
      revisedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revised_at'],
      )!,
      previousJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_json'],
      )!,
    );
  }

  @override
  IncidentRevision createAlias(String alias) {
    return IncidentRevision(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class IncidentRevisionData extends DataClass
    implements Insertable<IncidentRevisionData> {
  final String incidentId;
  final String revisedAt;
  final String previousJson;
  const IncidentRevisionData({
    required this.incidentId,
    required this.revisedAt,
    required this.previousJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['incident_id'] = Variable<String>(incidentId);
    map['revised_at'] = Variable<String>(revisedAt);
    map['previous_json'] = Variable<String>(previousJson);
    return map;
  }

  IncidentRevisionCompanion toCompanion(bool nullToAbsent) {
    return IncidentRevisionCompanion(
      incidentId: Value(incidentId),
      revisedAt: Value(revisedAt),
      previousJson: Value(previousJson),
    );
  }

  factory IncidentRevisionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncidentRevisionData(
      incidentId: serializer.fromJson<String>(json['incident_id']),
      revisedAt: serializer.fromJson<String>(json['revised_at']),
      previousJson: serializer.fromJson<String>(json['previous_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'incident_id': serializer.toJson<String>(incidentId),
      'revised_at': serializer.toJson<String>(revisedAt),
      'previous_json': serializer.toJson<String>(previousJson),
    };
  }

  IncidentRevisionData copyWith({
    String? incidentId,
    String? revisedAt,
    String? previousJson,
  }) => IncidentRevisionData(
    incidentId: incidentId ?? this.incidentId,
    revisedAt: revisedAt ?? this.revisedAt,
    previousJson: previousJson ?? this.previousJson,
  );
  IncidentRevisionData copyWithCompanion(IncidentRevisionCompanion data) {
    return IncidentRevisionData(
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
      revisedAt: data.revisedAt.present ? data.revisedAt.value : this.revisedAt,
      previousJson: data.previousJson.present
          ? data.previousJson.value
          : this.previousJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncidentRevisionData(')
          ..write('incidentId: $incidentId, ')
          ..write('revisedAt: $revisedAt, ')
          ..write('previousJson: $previousJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(incidentId, revisedAt, previousJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncidentRevisionData &&
          other.incidentId == this.incidentId &&
          other.revisedAt == this.revisedAt &&
          other.previousJson == this.previousJson);
}

class IncidentRevisionCompanion extends UpdateCompanion<IncidentRevisionData> {
  final Value<String> incidentId;
  final Value<String> revisedAt;
  final Value<String> previousJson;
  final Value<int> rowid;
  const IncidentRevisionCompanion({
    this.incidentId = const Value.absent(),
    this.revisedAt = const Value.absent(),
    this.previousJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncidentRevisionCompanion.insert({
    required String incidentId,
    required String revisedAt,
    required String previousJson,
    this.rowid = const Value.absent(),
  }) : incidentId = Value(incidentId),
       revisedAt = Value(revisedAt),
       previousJson = Value(previousJson);
  static Insertable<IncidentRevisionData> custom({
    Expression<String>? incidentId,
    Expression<String>? revisedAt,
    Expression<String>? previousJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (incidentId != null) 'incident_id': incidentId,
      if (revisedAt != null) 'revised_at': revisedAt,
      if (previousJson != null) 'previous_json': previousJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncidentRevisionCompanion copyWith({
    Value<String>? incidentId,
    Value<String>? revisedAt,
    Value<String>? previousJson,
    Value<int>? rowid,
  }) {
    return IncidentRevisionCompanion(
      incidentId: incidentId ?? this.incidentId,
      revisedAt: revisedAt ?? this.revisedAt,
      previousJson: previousJson ?? this.previousJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (incidentId.present) {
      map['incident_id'] = Variable<String>(incidentId.value);
    }
    if (revisedAt.present) {
      map['revised_at'] = Variable<String>(revisedAt.value);
    }
    if (previousJson.present) {
      map['previous_json'] = Variable<String>(previousJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncidentRevisionCompanion(')
          ..write('incidentId: $incidentId, ')
          ..write('revisedAt: $revisedAt, ')
          ..write('previousJson: $previousJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Attachment extends Table with TableInfo<Attachment, AttachmentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Attachment(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _incidentIdMeta = const VerificationMeta(
    'incidentId',
  );
  late final GeneratedColumn<String> incidentId = GeneratedColumn<String>(
    'incident_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES incident(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'VOICE_NOTE\', \'PHOTO\', \'VIDEO_CLIP\', \'VIDEO_LINK\'))',
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _videoPositionMsMeta = const VerificationMeta(
    'videoPositionMs',
  );
  late final GeneratedColumn<int> videoPositionMs = GeneratedColumn<int>(
    'video_position_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'PENDING_WRITE\', \'COMMITTED\', \'MISSING\'))',
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    incidentId,
    kind,
    relativePath,
    url,
    videoPositionMs,
    durationMs,
    sha256,
    status,
    transcript,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachment';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('incident_id')) {
      context.handle(
        _incidentIdMeta,
        incidentId.isAcceptableOrUnknown(data['incident_id']!, _incidentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_incidentIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('video_position_ms')) {
      context.handle(
        _videoPositionMsMeta,
        videoPositionMs.isAcceptableOrUnknown(
          data['video_position_ms']!,
          _videoPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      incidentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}incident_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      videoPositionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}video_position_ms'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Attachment createAlias(String alias) {
    return Attachment(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'CHECK((kind = \'VIDEO_LINK\' AND url IS NOT NULL)OR(kind <> \'VIDEO_LINK\' AND relative_path IS NOT NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class AttachmentData extends DataClass implements Insertable<AttachmentData> {
  final String id;
  final String incidentId;
  final String kind;
  final String? relativePath;
  final String? url;
  final int? videoPositionMs;
  final int? durationMs;
  final String? sha256;
  final String status;
  final String? transcript;
  final String createdAt;
  const AttachmentData({
    required this.id,
    required this.incidentId,
    required this.kind,
    this.relativePath,
    this.url,
    this.videoPositionMs,
    this.durationMs,
    this.sha256,
    required this.status,
    this.transcript,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['incident_id'] = Variable<String>(incidentId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || relativePath != null) {
      map['relative_path'] = Variable<String>(relativePath);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || videoPositionMs != null) {
      map['video_position_ms'] = Variable<int>(videoPositionMs);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || sha256 != null) {
      map['sha256'] = Variable<String>(sha256);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AttachmentCompanion toCompanion(bool nullToAbsent) {
    return AttachmentCompanion(
      id: Value(id),
      incidentId: Value(incidentId),
      kind: Value(kind),
      relativePath: relativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(relativePath),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      videoPositionMs: videoPositionMs == null && nullToAbsent
          ? const Value.absent()
          : Value(videoPositionMs),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      sha256: sha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(sha256),
      status: Value(status),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentData(
      id: serializer.fromJson<String>(json['id']),
      incidentId: serializer.fromJson<String>(json['incident_id']),
      kind: serializer.fromJson<String>(json['kind']),
      relativePath: serializer.fromJson<String?>(json['relative_path']),
      url: serializer.fromJson<String?>(json['url']),
      videoPositionMs: serializer.fromJson<int?>(json['video_position_ms']),
      durationMs: serializer.fromJson<int?>(json['duration_ms']),
      sha256: serializer.fromJson<String?>(json['sha256']),
      status: serializer.fromJson<String>(json['status']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      createdAt: serializer.fromJson<String>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'incident_id': serializer.toJson<String>(incidentId),
      'kind': serializer.toJson<String>(kind),
      'relative_path': serializer.toJson<String?>(relativePath),
      'url': serializer.toJson<String?>(url),
      'video_position_ms': serializer.toJson<int?>(videoPositionMs),
      'duration_ms': serializer.toJson<int?>(durationMs),
      'sha256': serializer.toJson<String?>(sha256),
      'status': serializer.toJson<String>(status),
      'transcript': serializer.toJson<String?>(transcript),
      'created_at': serializer.toJson<String>(createdAt),
    };
  }

  AttachmentData copyWith({
    String? id,
    String? incidentId,
    String? kind,
    Value<String?> relativePath = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<int?> videoPositionMs = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> sha256 = const Value.absent(),
    String? status,
    Value<String?> transcript = const Value.absent(),
    String? createdAt,
  }) => AttachmentData(
    id: id ?? this.id,
    incidentId: incidentId ?? this.incidentId,
    kind: kind ?? this.kind,
    relativePath: relativePath.present ? relativePath.value : this.relativePath,
    url: url.present ? url.value : this.url,
    videoPositionMs: videoPositionMs.present
        ? videoPositionMs.value
        : this.videoPositionMs,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    sha256: sha256.present ? sha256.value : this.sha256,
    status: status ?? this.status,
    transcript: transcript.present ? transcript.value : this.transcript,
    createdAt: createdAt ?? this.createdAt,
  );
  AttachmentData copyWithCompanion(AttachmentCompanion data) {
    return AttachmentData(
      id: data.id.present ? data.id.value : this.id,
      incidentId: data.incidentId.present
          ? data.incidentId.value
          : this.incidentId,
      kind: data.kind.present ? data.kind.value : this.kind,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      url: data.url.present ? data.url.value : this.url,
      videoPositionMs: data.videoPositionMs.present
          ? data.videoPositionMs.value
          : this.videoPositionMs,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      status: data.status.present ? data.status.value : this.status,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentData(')
          ..write('id: $id, ')
          ..write('incidentId: $incidentId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('url: $url, ')
          ..write('videoPositionMs: $videoPositionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('sha256: $sha256, ')
          ..write('status: $status, ')
          ..write('transcript: $transcript, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    incidentId,
    kind,
    relativePath,
    url,
    videoPositionMs,
    durationMs,
    sha256,
    status,
    transcript,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentData &&
          other.id == this.id &&
          other.incidentId == this.incidentId &&
          other.kind == this.kind &&
          other.relativePath == this.relativePath &&
          other.url == this.url &&
          other.videoPositionMs == this.videoPositionMs &&
          other.durationMs == this.durationMs &&
          other.sha256 == this.sha256 &&
          other.status == this.status &&
          other.transcript == this.transcript &&
          other.createdAt == this.createdAt);
}

class AttachmentCompanion extends UpdateCompanion<AttachmentData> {
  final Value<String> id;
  final Value<String> incidentId;
  final Value<String> kind;
  final Value<String?> relativePath;
  final Value<String?> url;
  final Value<int?> videoPositionMs;
  final Value<int?> durationMs;
  final Value<String?> sha256;
  final Value<String> status;
  final Value<String?> transcript;
  final Value<String> createdAt;
  final Value<int> rowid;
  const AttachmentCompanion({
    this.id = const Value.absent(),
    this.incidentId = const Value.absent(),
    this.kind = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.url = const Value.absent(),
    this.videoPositionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.status = const Value.absent(),
    this.transcript = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentCompanion.insert({
    required String id,
    required String incidentId,
    required String kind,
    this.relativePath = const Value.absent(),
    this.url = const Value.absent(),
    this.videoPositionMs = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.sha256 = const Value.absent(),
    required String status,
    this.transcript = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       incidentId = Value(incidentId),
       kind = Value(kind),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<AttachmentData> custom({
    Expression<String>? id,
    Expression<String>? incidentId,
    Expression<String>? kind,
    Expression<String>? relativePath,
    Expression<String>? url,
    Expression<int>? videoPositionMs,
    Expression<int>? durationMs,
    Expression<String>? sha256,
    Expression<String>? status,
    Expression<String>? transcript,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (incidentId != null) 'incident_id': incidentId,
      if (kind != null) 'kind': kind,
      if (relativePath != null) 'relative_path': relativePath,
      if (url != null) 'url': url,
      if (videoPositionMs != null) 'video_position_ms': videoPositionMs,
      if (durationMs != null) 'duration_ms': durationMs,
      if (sha256 != null) 'sha256': sha256,
      if (status != null) 'status': status,
      if (transcript != null) 'transcript': transcript,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentCompanion copyWith({
    Value<String>? id,
    Value<String>? incidentId,
    Value<String>? kind,
    Value<String?>? relativePath,
    Value<String?>? url,
    Value<int?>? videoPositionMs,
    Value<int?>? durationMs,
    Value<String?>? sha256,
    Value<String>? status,
    Value<String?>? transcript,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentCompanion(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      kind: kind ?? this.kind,
      relativePath: relativePath ?? this.relativePath,
      url: url ?? this.url,
      videoPositionMs: videoPositionMs ?? this.videoPositionMs,
      durationMs: durationMs ?? this.durationMs,
      sha256: sha256 ?? this.sha256,
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
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
    if (incidentId.present) {
      map['incident_id'] = Variable<String>(incidentId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (videoPositionMs.present) {
      map['video_position_ms'] = Variable<int>(videoPositionMs.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentCompanion(')
          ..write('id: $id, ')
          ..write('incidentId: $incidentId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('url: $url, ')
          ..write('videoPositionMs: $videoPositionMs, ')
          ..write('durationMs: $durationMs, ')
          ..write('sha256: $sha256, ')
          ..write('status: $status, ')
          ..write('transcript: $transcript, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Report extends Table with TableInfo<Report, ReportData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Report(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assessmentIdMeta = const VerificationMeta(
    'assessmentId',
  );
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES assessment(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _refereeIdMeta = const VerificationMeta(
    'refereeId',
  );
  late final GeneratedColumn<String> refereeId = GeneratedColumn<String>(
    'referee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES official(id)',
  );
  static const VerificationMeta _rubricIdMeta = const VerificationMeta(
    'rubricId',
  );
  late final GeneratedColumn<String> rubricId = GeneratedColumn<String>(
    'rubric_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES rubric(id)',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'DRAFT\', \'READY\', \'FINALIZED\', \'SUPERSEDED\'))',
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _bandMeta = const VerificationMeta('band');
  late final GeneratedColumn<String> band = GeneratedColumn<String>(
    'band',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (band IN (\'BELOW\', \'AT\', \'ABOVE\'))',
  );
  static const VerificationMeta _overallScoreMeta = const VerificationMeta(
    'overallScore',
  );
  late final GeneratedColumn<double> overallScore = GeneratedColumn<double>(
    'overall_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _keyCorrectMeta = const VerificationMeta(
    'keyCorrect',
  );
  late final GeneratedColumn<int> keyCorrect = GeneratedColumn<int>(
    'key_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _keyTotalMeta = const VerificationMeta(
    'keyTotal',
  );
  late final GeneratedColumn<int> keyTotal = GeneratedColumn<int>(
    'key_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _amendmentReasonMeta = const VerificationMeta(
    'amendmentReason',
  );
  late final GeneratedColumn<String> amendmentReason = GeneratedColumn<String>(
    'amendment_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _finalizedAtMeta = const VerificationMeta(
    'finalizedAt',
  );
  late final GeneratedColumn<String> finalizedAt = GeneratedColumn<String>(
    'finalized_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _canonicalJsonMeta = const VerificationMeta(
    'canonicalJson',
  );
  late final GeneratedColumn<String> canonicalJson = GeneratedColumn<String>(
    'canonical_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (canonical_json IS NULL OR json_valid(canonical_json))',
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    assessmentId,
    version,
    refereeId,
    rubricId,
    status,
    summary,
    band,
    overallScore,
    keyCorrect,
    keyTotal,
    amendmentReason,
    finalizedAt,
    canonicalJson,
    contentHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReportData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assessment_id')) {
      context.handle(
        _assessmentIdMeta,
        assessmentId.isAcceptableOrUnknown(
          data['assessment_id']!,
          _assessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('referee_id')) {
      context.handle(
        _refereeIdMeta,
        refereeId.isAcceptableOrUnknown(data['referee_id']!, _refereeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_refereeIdMeta);
    }
    if (data.containsKey('rubric_id')) {
      context.handle(
        _rubricIdMeta,
        rubricId.isAcceptableOrUnknown(data['rubric_id']!, _rubricIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rubricIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('band')) {
      context.handle(
        _bandMeta,
        band.isAcceptableOrUnknown(data['band']!, _bandMeta),
      );
    }
    if (data.containsKey('overall_score')) {
      context.handle(
        _overallScoreMeta,
        overallScore.isAcceptableOrUnknown(
          data['overall_score']!,
          _overallScoreMeta,
        ),
      );
    }
    if (data.containsKey('key_correct')) {
      context.handle(
        _keyCorrectMeta,
        keyCorrect.isAcceptableOrUnknown(data['key_correct']!, _keyCorrectMeta),
      );
    }
    if (data.containsKey('key_total')) {
      context.handle(
        _keyTotalMeta,
        keyTotal.isAcceptableOrUnknown(data['key_total']!, _keyTotalMeta),
      );
    }
    if (data.containsKey('amendment_reason')) {
      context.handle(
        _amendmentReasonMeta,
        amendmentReason.isAcceptableOrUnknown(
          data['amendment_reason']!,
          _amendmentReasonMeta,
        ),
      );
    }
    if (data.containsKey('finalized_at')) {
      context.handle(
        _finalizedAtMeta,
        finalizedAt.isAcceptableOrUnknown(
          data['finalized_at']!,
          _finalizedAtMeta,
        ),
      );
    }
    if (data.containsKey('canonical_json')) {
      context.handle(
        _canonicalJsonMeta,
        canonicalJson.isAcceptableOrUnknown(
          data['canonical_json']!,
          _canonicalJsonMeta,
        ),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assessmentId, version};
  @override
  ReportData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportData(
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      refereeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referee_id'],
      )!,
      rubricId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rubric_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      band: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}band'],
      ),
      overallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}overall_score'],
      ),
      keyCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_correct'],
      )!,
      keyTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_total'],
      )!,
      amendmentReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amendment_reason'],
      ),
      finalizedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finalized_at'],
      ),
      canonicalJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_json'],
      ),
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      ),
    );
  }

  @override
  Report createAlias(String alias) {
    return Report(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(assessment_id, version)',
    'CHECK(status <> \'FINALIZED\' OR(canonical_json IS NOT NULL AND content_hash IS NOT NULL AND finalized_at IS NOT NULL))',
    'CHECK(version = 1 OR amendment_reason IS NOT NULL)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ReportData extends DataClass implements Insertable<ReportData> {
  final String assessmentId;
  final int version;
  final String refereeId;
  final String rubricId;
  final String status;
  final String summary;
  final String? band;

  /// resultado visible
  final double? overallScore;

  /// interno (auditoría)
  final int keyCorrect;
  final int keyTotal;
  final String? amendmentReason;
  final String? finalizedAt;
  final String? canonicalJson;
  final String? contentHash;
  const ReportData({
    required this.assessmentId,
    required this.version,
    required this.refereeId,
    required this.rubricId,
    required this.status,
    required this.summary,
    this.band,
    this.overallScore,
    required this.keyCorrect,
    required this.keyTotal,
    this.amendmentReason,
    this.finalizedAt,
    this.canonicalJson,
    this.contentHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assessment_id'] = Variable<String>(assessmentId);
    map['version'] = Variable<int>(version);
    map['referee_id'] = Variable<String>(refereeId);
    map['rubric_id'] = Variable<String>(rubricId);
    map['status'] = Variable<String>(status);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || band != null) {
      map['band'] = Variable<String>(band);
    }
    if (!nullToAbsent || overallScore != null) {
      map['overall_score'] = Variable<double>(overallScore);
    }
    map['key_correct'] = Variable<int>(keyCorrect);
    map['key_total'] = Variable<int>(keyTotal);
    if (!nullToAbsent || amendmentReason != null) {
      map['amendment_reason'] = Variable<String>(amendmentReason);
    }
    if (!nullToAbsent || finalizedAt != null) {
      map['finalized_at'] = Variable<String>(finalizedAt);
    }
    if (!nullToAbsent || canonicalJson != null) {
      map['canonical_json'] = Variable<String>(canonicalJson);
    }
    if (!nullToAbsent || contentHash != null) {
      map['content_hash'] = Variable<String>(contentHash);
    }
    return map;
  }

  ReportCompanion toCompanion(bool nullToAbsent) {
    return ReportCompanion(
      assessmentId: Value(assessmentId),
      version: Value(version),
      refereeId: Value(refereeId),
      rubricId: Value(rubricId),
      status: Value(status),
      summary: Value(summary),
      band: band == null && nullToAbsent ? const Value.absent() : Value(band),
      overallScore: overallScore == null && nullToAbsent
          ? const Value.absent()
          : Value(overallScore),
      keyCorrect: Value(keyCorrect),
      keyTotal: Value(keyTotal),
      amendmentReason: amendmentReason == null && nullToAbsent
          ? const Value.absent()
          : Value(amendmentReason),
      finalizedAt: finalizedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finalizedAt),
      canonicalJson: canonicalJson == null && nullToAbsent
          ? const Value.absent()
          : Value(canonicalJson),
      contentHash: contentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHash),
    );
  }

  factory ReportData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportData(
      assessmentId: serializer.fromJson<String>(json['assessment_id']),
      version: serializer.fromJson<int>(json['version']),
      refereeId: serializer.fromJson<String>(json['referee_id']),
      rubricId: serializer.fromJson<String>(json['rubric_id']),
      status: serializer.fromJson<String>(json['status']),
      summary: serializer.fromJson<String>(json['summary']),
      band: serializer.fromJson<String?>(json['band']),
      overallScore: serializer.fromJson<double?>(json['overall_score']),
      keyCorrect: serializer.fromJson<int>(json['key_correct']),
      keyTotal: serializer.fromJson<int>(json['key_total']),
      amendmentReason: serializer.fromJson<String?>(json['amendment_reason']),
      finalizedAt: serializer.fromJson<String?>(json['finalized_at']),
      canonicalJson: serializer.fromJson<String?>(json['canonical_json']),
      contentHash: serializer.fromJson<String?>(json['content_hash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assessment_id': serializer.toJson<String>(assessmentId),
      'version': serializer.toJson<int>(version),
      'referee_id': serializer.toJson<String>(refereeId),
      'rubric_id': serializer.toJson<String>(rubricId),
      'status': serializer.toJson<String>(status),
      'summary': serializer.toJson<String>(summary),
      'band': serializer.toJson<String?>(band),
      'overall_score': serializer.toJson<double?>(overallScore),
      'key_correct': serializer.toJson<int>(keyCorrect),
      'key_total': serializer.toJson<int>(keyTotal),
      'amendment_reason': serializer.toJson<String?>(amendmentReason),
      'finalized_at': serializer.toJson<String?>(finalizedAt),
      'canonical_json': serializer.toJson<String?>(canonicalJson),
      'content_hash': serializer.toJson<String?>(contentHash),
    };
  }

  ReportData copyWith({
    String? assessmentId,
    int? version,
    String? refereeId,
    String? rubricId,
    String? status,
    String? summary,
    Value<String?> band = const Value.absent(),
    Value<double?> overallScore = const Value.absent(),
    int? keyCorrect,
    int? keyTotal,
    Value<String?> amendmentReason = const Value.absent(),
    Value<String?> finalizedAt = const Value.absent(),
    Value<String?> canonicalJson = const Value.absent(),
    Value<String?> contentHash = const Value.absent(),
  }) => ReportData(
    assessmentId: assessmentId ?? this.assessmentId,
    version: version ?? this.version,
    refereeId: refereeId ?? this.refereeId,
    rubricId: rubricId ?? this.rubricId,
    status: status ?? this.status,
    summary: summary ?? this.summary,
    band: band.present ? band.value : this.band,
    overallScore: overallScore.present ? overallScore.value : this.overallScore,
    keyCorrect: keyCorrect ?? this.keyCorrect,
    keyTotal: keyTotal ?? this.keyTotal,
    amendmentReason: amendmentReason.present
        ? amendmentReason.value
        : this.amendmentReason,
    finalizedAt: finalizedAt.present ? finalizedAt.value : this.finalizedAt,
    canonicalJson: canonicalJson.present
        ? canonicalJson.value
        : this.canonicalJson,
    contentHash: contentHash.present ? contentHash.value : this.contentHash,
  );
  ReportData copyWithCompanion(ReportCompanion data) {
    return ReportData(
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      version: data.version.present ? data.version.value : this.version,
      refereeId: data.refereeId.present ? data.refereeId.value : this.refereeId,
      rubricId: data.rubricId.present ? data.rubricId.value : this.rubricId,
      status: data.status.present ? data.status.value : this.status,
      summary: data.summary.present ? data.summary.value : this.summary,
      band: data.band.present ? data.band.value : this.band,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      keyCorrect: data.keyCorrect.present
          ? data.keyCorrect.value
          : this.keyCorrect,
      keyTotal: data.keyTotal.present ? data.keyTotal.value : this.keyTotal,
      amendmentReason: data.amendmentReason.present
          ? data.amendmentReason.value
          : this.amendmentReason,
      finalizedAt: data.finalizedAt.present
          ? data.finalizedAt.value
          : this.finalizedAt,
      canonicalJson: data.canonicalJson.present
          ? data.canonicalJson.value
          : this.canonicalJson,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportData(')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('refereeId: $refereeId, ')
          ..write('rubricId: $rubricId, ')
          ..write('status: $status, ')
          ..write('summary: $summary, ')
          ..write('band: $band, ')
          ..write('overallScore: $overallScore, ')
          ..write('keyCorrect: $keyCorrect, ')
          ..write('keyTotal: $keyTotal, ')
          ..write('amendmentReason: $amendmentReason, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('canonicalJson: $canonicalJson, ')
          ..write('contentHash: $contentHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    assessmentId,
    version,
    refereeId,
    rubricId,
    status,
    summary,
    band,
    overallScore,
    keyCorrect,
    keyTotal,
    amendmentReason,
    finalizedAt,
    canonicalJson,
    contentHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportData &&
          other.assessmentId == this.assessmentId &&
          other.version == this.version &&
          other.refereeId == this.refereeId &&
          other.rubricId == this.rubricId &&
          other.status == this.status &&
          other.summary == this.summary &&
          other.band == this.band &&
          other.overallScore == this.overallScore &&
          other.keyCorrect == this.keyCorrect &&
          other.keyTotal == this.keyTotal &&
          other.amendmentReason == this.amendmentReason &&
          other.finalizedAt == this.finalizedAt &&
          other.canonicalJson == this.canonicalJson &&
          other.contentHash == this.contentHash);
}

class ReportCompanion extends UpdateCompanion<ReportData> {
  final Value<String> assessmentId;
  final Value<int> version;
  final Value<String> refereeId;
  final Value<String> rubricId;
  final Value<String> status;
  final Value<String> summary;
  final Value<String?> band;
  final Value<double?> overallScore;
  final Value<int> keyCorrect;
  final Value<int> keyTotal;
  final Value<String?> amendmentReason;
  final Value<String?> finalizedAt;
  final Value<String?> canonicalJson;
  final Value<String?> contentHash;
  final Value<int> rowid;
  const ReportCompanion({
    this.assessmentId = const Value.absent(),
    this.version = const Value.absent(),
    this.refereeId = const Value.absent(),
    this.rubricId = const Value.absent(),
    this.status = const Value.absent(),
    this.summary = const Value.absent(),
    this.band = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.keyCorrect = const Value.absent(),
    this.keyTotal = const Value.absent(),
    this.amendmentReason = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.canonicalJson = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportCompanion.insert({
    required String assessmentId,
    required int version,
    required String refereeId,
    required String rubricId,
    required String status,
    this.summary = const Value.absent(),
    this.band = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.keyCorrect = const Value.absent(),
    this.keyTotal = const Value.absent(),
    this.amendmentReason = const Value.absent(),
    this.finalizedAt = const Value.absent(),
    this.canonicalJson = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : assessmentId = Value(assessmentId),
       version = Value(version),
       refereeId = Value(refereeId),
       rubricId = Value(rubricId),
       status = Value(status);
  static Insertable<ReportData> custom({
    Expression<String>? assessmentId,
    Expression<int>? version,
    Expression<String>? refereeId,
    Expression<String>? rubricId,
    Expression<String>? status,
    Expression<String>? summary,
    Expression<String>? band,
    Expression<double>? overallScore,
    Expression<int>? keyCorrect,
    Expression<int>? keyTotal,
    Expression<String>? amendmentReason,
    Expression<String>? finalizedAt,
    Expression<String>? canonicalJson,
    Expression<String>? contentHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (version != null) 'version': version,
      if (refereeId != null) 'referee_id': refereeId,
      if (rubricId != null) 'rubric_id': rubricId,
      if (status != null) 'status': status,
      if (summary != null) 'summary': summary,
      if (band != null) 'band': band,
      if (overallScore != null) 'overall_score': overallScore,
      if (keyCorrect != null) 'key_correct': keyCorrect,
      if (keyTotal != null) 'key_total': keyTotal,
      if (amendmentReason != null) 'amendment_reason': amendmentReason,
      if (finalizedAt != null) 'finalized_at': finalizedAt,
      if (canonicalJson != null) 'canonical_json': canonicalJson,
      if (contentHash != null) 'content_hash': contentHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportCompanion copyWith({
    Value<String>? assessmentId,
    Value<int>? version,
    Value<String>? refereeId,
    Value<String>? rubricId,
    Value<String>? status,
    Value<String>? summary,
    Value<String?>? band,
    Value<double?>? overallScore,
    Value<int>? keyCorrect,
    Value<int>? keyTotal,
    Value<String?>? amendmentReason,
    Value<String?>? finalizedAt,
    Value<String?>? canonicalJson,
    Value<String?>? contentHash,
    Value<int>? rowid,
  }) {
    return ReportCompanion(
      assessmentId: assessmentId ?? this.assessmentId,
      version: version ?? this.version,
      refereeId: refereeId ?? this.refereeId,
      rubricId: rubricId ?? this.rubricId,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      band: band ?? this.band,
      overallScore: overallScore ?? this.overallScore,
      keyCorrect: keyCorrect ?? this.keyCorrect,
      keyTotal: keyTotal ?? this.keyTotal,
      amendmentReason: amendmentReason ?? this.amendmentReason,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      canonicalJson: canonicalJson ?? this.canonicalJson,
      contentHash: contentHash ?? this.contentHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (refereeId.present) {
      map['referee_id'] = Variable<String>(refereeId.value);
    }
    if (rubricId.present) {
      map['rubric_id'] = Variable<String>(rubricId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (band.present) {
      map['band'] = Variable<String>(band.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<double>(overallScore.value);
    }
    if (keyCorrect.present) {
      map['key_correct'] = Variable<int>(keyCorrect.value);
    }
    if (keyTotal.present) {
      map['key_total'] = Variable<int>(keyTotal.value);
    }
    if (amendmentReason.present) {
      map['amendment_reason'] = Variable<String>(amendmentReason.value);
    }
    if (finalizedAt.present) {
      map['finalized_at'] = Variable<String>(finalizedAt.value);
    }
    if (canonicalJson.present) {
      map['canonical_json'] = Variable<String>(canonicalJson.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportCompanion(')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('refereeId: $refereeId, ')
          ..write('rubricId: $rubricId, ')
          ..write('status: $status, ')
          ..write('summary: $summary, ')
          ..write('band: $band, ')
          ..write('overallScore: $overallScore, ')
          ..write('keyCorrect: $keyCorrect, ')
          ..write('keyTotal: $keyTotal, ')
          ..write('amendmentReason: $amendmentReason, ')
          ..write('finalizedAt: $finalizedAt, ')
          ..write('canonicalJson: $canonicalJson, ')
          ..write('contentHash: $contentHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class CriterionScore extends Table
    with TableInfo<CriterionScore, CriterionScoreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CriterionScore(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assessmentIdMeta = const VerificationMeta(
    'assessmentId',
  );
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _criterionCodeMeta = const VerificationMeta(
    'criterionCode',
  );
  late final GeneratedColumn<String> criterionCode = GeneratedColumn<String>(
    'criterion_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _suggestedBandMeta = const VerificationMeta(
    'suggestedBand',
  );
  late final GeneratedColumn<String> suggestedBand = GeneratedColumn<String>(
    'suggested_band',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (suggested_band IN (\'BELOW\', \'AT\', \'ABOVE\'))',
  );
  static const VerificationMeta _suggestedMeta = const VerificationMeta(
    'suggested',
  );
  late final GeneratedColumn<double> suggested = GeneratedColumn<double>(
    'suggested',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _finalBandMeta = const VerificationMeta(
    'finalBand',
  );
  late final GeneratedColumn<String> finalBand = GeneratedColumn<String>(
    'final_band',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (final_band IN (\'BELOW\', \'AT\', \'ABOVE\'))',
  );
  static const VerificationMeta _notObservedMeta = const VerificationMeta(
    'notObserved',
  );
  late final GeneratedColumn<int> notObserved = GeneratedColumn<int>(
    'not_observed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (not_observed IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _justificationMeta = const VerificationMeta(
    'justification',
  );
  late final GeneratedColumn<String> justification = GeneratedColumn<String>(
    'justification',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _capBandMeta = const VerificationMeta(
    'capBand',
  );
  late final GeneratedColumn<String> capBand = GeneratedColumn<String>(
    'cap_band',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (cap_band IN (\'BELOW\', \'AT\', \'ABOVE\'))',
  );
  static const VerificationMeta _evidenceJsonMeta = const VerificationMeta(
    'evidenceJson',
  );
  late final GeneratedColumn<String> evidenceJson = GeneratedColumn<String>(
    'evidence_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'[]\' CHECK (json_valid(evidence_json))',
    defaultValue: const CustomExpression('\'[]\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    assessmentId,
    version,
    criterionCode,
    suggestedBand,
    suggested,
    finalBand,
    notObserved,
    justification,
    capBand,
    evidenceJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'criterion_score';
  @override
  VerificationContext validateIntegrity(
    Insertable<CriterionScoreData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assessment_id')) {
      context.handle(
        _assessmentIdMeta,
        assessmentId.isAcceptableOrUnknown(
          data['assessment_id']!,
          _assessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('criterion_code')) {
      context.handle(
        _criterionCodeMeta,
        criterionCode.isAcceptableOrUnknown(
          data['criterion_code']!,
          _criterionCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_criterionCodeMeta);
    }
    if (data.containsKey('suggested_band')) {
      context.handle(
        _suggestedBandMeta,
        suggestedBand.isAcceptableOrUnknown(
          data['suggested_band']!,
          _suggestedBandMeta,
        ),
      );
    }
    if (data.containsKey('suggested')) {
      context.handle(
        _suggestedMeta,
        suggested.isAcceptableOrUnknown(data['suggested']!, _suggestedMeta),
      );
    }
    if (data.containsKey('final_band')) {
      context.handle(
        _finalBandMeta,
        finalBand.isAcceptableOrUnknown(data['final_band']!, _finalBandMeta),
      );
    }
    if (data.containsKey('not_observed')) {
      context.handle(
        _notObservedMeta,
        notObserved.isAcceptableOrUnknown(
          data['not_observed']!,
          _notObservedMeta,
        ),
      );
    }
    if (data.containsKey('justification')) {
      context.handle(
        _justificationMeta,
        justification.isAcceptableOrUnknown(
          data['justification']!,
          _justificationMeta,
        ),
      );
    }
    if (data.containsKey('cap_band')) {
      context.handle(
        _capBandMeta,
        capBand.isAcceptableOrUnknown(data['cap_band']!, _capBandMeta),
      );
    }
    if (data.containsKey('evidence_json')) {
      context.handle(
        _evidenceJsonMeta,
        evidenceJson.isAcceptableOrUnknown(
          data['evidence_json']!,
          _evidenceJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    assessmentId,
    version,
    criterionCode,
  };
  @override
  CriterionScoreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CriterionScoreData(
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      criterionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criterion_code'],
      )!,
      suggestedBand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_band'],
      ),
      suggested: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}suggested'],
      ),
      finalBand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_band'],
      ),
      notObserved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}not_observed'],
      )!,
      justification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}justification'],
      )!,
      capBand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cap_band'],
      ),
      evidenceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_json'],
      )!,
    );
  }

  @override
  CriterionScore createAlias(String alias) {
    return CriterionScore(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(assessment_id, version, criterion_code)',
    'FOREIGN KEY(assessment_id, version)REFERENCES report(assessment_id, version)ON DELETE CASCADE',
    'CHECK(not_observed = 0 OR final_band IS NULL)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class CriterionScoreData extends DataClass
    implements Insertable<CriterionScoreData> {
  final String assessmentId;
  final int version;
  final String criterionCode;
  final String? suggestedBand;
  final double? suggested;

  /// interno
  final String? finalBand;

  /// lo que elige el evaluador
  final int notObserved;
  final String justification;
  final String? capBand;
  final String evidenceJson;
  const CriterionScoreData({
    required this.assessmentId,
    required this.version,
    required this.criterionCode,
    this.suggestedBand,
    this.suggested,
    this.finalBand,
    required this.notObserved,
    required this.justification,
    this.capBand,
    required this.evidenceJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assessment_id'] = Variable<String>(assessmentId);
    map['version'] = Variable<int>(version);
    map['criterion_code'] = Variable<String>(criterionCode);
    if (!nullToAbsent || suggestedBand != null) {
      map['suggested_band'] = Variable<String>(suggestedBand);
    }
    if (!nullToAbsent || suggested != null) {
      map['suggested'] = Variable<double>(suggested);
    }
    if (!nullToAbsent || finalBand != null) {
      map['final_band'] = Variable<String>(finalBand);
    }
    map['not_observed'] = Variable<int>(notObserved);
    map['justification'] = Variable<String>(justification);
    if (!nullToAbsent || capBand != null) {
      map['cap_band'] = Variable<String>(capBand);
    }
    map['evidence_json'] = Variable<String>(evidenceJson);
    return map;
  }

  CriterionScoreCompanion toCompanion(bool nullToAbsent) {
    return CriterionScoreCompanion(
      assessmentId: Value(assessmentId),
      version: Value(version),
      criterionCode: Value(criterionCode),
      suggestedBand: suggestedBand == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedBand),
      suggested: suggested == null && nullToAbsent
          ? const Value.absent()
          : Value(suggested),
      finalBand: finalBand == null && nullToAbsent
          ? const Value.absent()
          : Value(finalBand),
      notObserved: Value(notObserved),
      justification: Value(justification),
      capBand: capBand == null && nullToAbsent
          ? const Value.absent()
          : Value(capBand),
      evidenceJson: Value(evidenceJson),
    );
  }

  factory CriterionScoreData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CriterionScoreData(
      assessmentId: serializer.fromJson<String>(json['assessment_id']),
      version: serializer.fromJson<int>(json['version']),
      criterionCode: serializer.fromJson<String>(json['criterion_code']),
      suggestedBand: serializer.fromJson<String?>(json['suggested_band']),
      suggested: serializer.fromJson<double?>(json['suggested']),
      finalBand: serializer.fromJson<String?>(json['final_band']),
      notObserved: serializer.fromJson<int>(json['not_observed']),
      justification: serializer.fromJson<String>(json['justification']),
      capBand: serializer.fromJson<String?>(json['cap_band']),
      evidenceJson: serializer.fromJson<String>(json['evidence_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assessment_id': serializer.toJson<String>(assessmentId),
      'version': serializer.toJson<int>(version),
      'criterion_code': serializer.toJson<String>(criterionCode),
      'suggested_band': serializer.toJson<String?>(suggestedBand),
      'suggested': serializer.toJson<double?>(suggested),
      'final_band': serializer.toJson<String?>(finalBand),
      'not_observed': serializer.toJson<int>(notObserved),
      'justification': serializer.toJson<String>(justification),
      'cap_band': serializer.toJson<String?>(capBand),
      'evidence_json': serializer.toJson<String>(evidenceJson),
    };
  }

  CriterionScoreData copyWith({
    String? assessmentId,
    int? version,
    String? criterionCode,
    Value<String?> suggestedBand = const Value.absent(),
    Value<double?> suggested = const Value.absent(),
    Value<String?> finalBand = const Value.absent(),
    int? notObserved,
    String? justification,
    Value<String?> capBand = const Value.absent(),
    String? evidenceJson,
  }) => CriterionScoreData(
    assessmentId: assessmentId ?? this.assessmentId,
    version: version ?? this.version,
    criterionCode: criterionCode ?? this.criterionCode,
    suggestedBand: suggestedBand.present
        ? suggestedBand.value
        : this.suggestedBand,
    suggested: suggested.present ? suggested.value : this.suggested,
    finalBand: finalBand.present ? finalBand.value : this.finalBand,
    notObserved: notObserved ?? this.notObserved,
    justification: justification ?? this.justification,
    capBand: capBand.present ? capBand.value : this.capBand,
    evidenceJson: evidenceJson ?? this.evidenceJson,
  );
  CriterionScoreData copyWithCompanion(CriterionScoreCompanion data) {
    return CriterionScoreData(
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      version: data.version.present ? data.version.value : this.version,
      criterionCode: data.criterionCode.present
          ? data.criterionCode.value
          : this.criterionCode,
      suggestedBand: data.suggestedBand.present
          ? data.suggestedBand.value
          : this.suggestedBand,
      suggested: data.suggested.present ? data.suggested.value : this.suggested,
      finalBand: data.finalBand.present ? data.finalBand.value : this.finalBand,
      notObserved: data.notObserved.present
          ? data.notObserved.value
          : this.notObserved,
      justification: data.justification.present
          ? data.justification.value
          : this.justification,
      capBand: data.capBand.present ? data.capBand.value : this.capBand,
      evidenceJson: data.evidenceJson.present
          ? data.evidenceJson.value
          : this.evidenceJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CriterionScoreData(')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('criterionCode: $criterionCode, ')
          ..write('suggestedBand: $suggestedBand, ')
          ..write('suggested: $suggested, ')
          ..write('finalBand: $finalBand, ')
          ..write('notObserved: $notObserved, ')
          ..write('justification: $justification, ')
          ..write('capBand: $capBand, ')
          ..write('evidenceJson: $evidenceJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    assessmentId,
    version,
    criterionCode,
    suggestedBand,
    suggested,
    finalBand,
    notObserved,
    justification,
    capBand,
    evidenceJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CriterionScoreData &&
          other.assessmentId == this.assessmentId &&
          other.version == this.version &&
          other.criterionCode == this.criterionCode &&
          other.suggestedBand == this.suggestedBand &&
          other.suggested == this.suggested &&
          other.finalBand == this.finalBand &&
          other.notObserved == this.notObserved &&
          other.justification == this.justification &&
          other.capBand == this.capBand &&
          other.evidenceJson == this.evidenceJson);
}

class CriterionScoreCompanion extends UpdateCompanion<CriterionScoreData> {
  final Value<String> assessmentId;
  final Value<int> version;
  final Value<String> criterionCode;
  final Value<String?> suggestedBand;
  final Value<double?> suggested;
  final Value<String?> finalBand;
  final Value<int> notObserved;
  final Value<String> justification;
  final Value<String?> capBand;
  final Value<String> evidenceJson;
  final Value<int> rowid;
  const CriterionScoreCompanion({
    this.assessmentId = const Value.absent(),
    this.version = const Value.absent(),
    this.criterionCode = const Value.absent(),
    this.suggestedBand = const Value.absent(),
    this.suggested = const Value.absent(),
    this.finalBand = const Value.absent(),
    this.notObserved = const Value.absent(),
    this.justification = const Value.absent(),
    this.capBand = const Value.absent(),
    this.evidenceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CriterionScoreCompanion.insert({
    required String assessmentId,
    required int version,
    required String criterionCode,
    this.suggestedBand = const Value.absent(),
    this.suggested = const Value.absent(),
    this.finalBand = const Value.absent(),
    this.notObserved = const Value.absent(),
    this.justification = const Value.absent(),
    this.capBand = const Value.absent(),
    this.evidenceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : assessmentId = Value(assessmentId),
       version = Value(version),
       criterionCode = Value(criterionCode);
  static Insertable<CriterionScoreData> custom({
    Expression<String>? assessmentId,
    Expression<int>? version,
    Expression<String>? criterionCode,
    Expression<String>? suggestedBand,
    Expression<double>? suggested,
    Expression<String>? finalBand,
    Expression<int>? notObserved,
    Expression<String>? justification,
    Expression<String>? capBand,
    Expression<String>? evidenceJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (version != null) 'version': version,
      if (criterionCode != null) 'criterion_code': criterionCode,
      if (suggestedBand != null) 'suggested_band': suggestedBand,
      if (suggested != null) 'suggested': suggested,
      if (finalBand != null) 'final_band': finalBand,
      if (notObserved != null) 'not_observed': notObserved,
      if (justification != null) 'justification': justification,
      if (capBand != null) 'cap_band': capBand,
      if (evidenceJson != null) 'evidence_json': evidenceJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CriterionScoreCompanion copyWith({
    Value<String>? assessmentId,
    Value<int>? version,
    Value<String>? criterionCode,
    Value<String?>? suggestedBand,
    Value<double?>? suggested,
    Value<String?>? finalBand,
    Value<int>? notObserved,
    Value<String>? justification,
    Value<String?>? capBand,
    Value<String>? evidenceJson,
    Value<int>? rowid,
  }) {
    return CriterionScoreCompanion(
      assessmentId: assessmentId ?? this.assessmentId,
      version: version ?? this.version,
      criterionCode: criterionCode ?? this.criterionCode,
      suggestedBand: suggestedBand ?? this.suggestedBand,
      suggested: suggested ?? this.suggested,
      finalBand: finalBand ?? this.finalBand,
      notObserved: notObserved ?? this.notObserved,
      justification: justification ?? this.justification,
      capBand: capBand ?? this.capBand,
      evidenceJson: evidenceJson ?? this.evidenceJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (criterionCode.present) {
      map['criterion_code'] = Variable<String>(criterionCode.value);
    }
    if (suggestedBand.present) {
      map['suggested_band'] = Variable<String>(suggestedBand.value);
    }
    if (suggested.present) {
      map['suggested'] = Variable<double>(suggested.value);
    }
    if (finalBand.present) {
      map['final_band'] = Variable<String>(finalBand.value);
    }
    if (notObserved.present) {
      map['not_observed'] = Variable<int>(notObserved.value);
    }
    if (justification.present) {
      map['justification'] = Variable<String>(justification.value);
    }
    if (capBand.present) {
      map['cap_band'] = Variable<String>(capBand.value);
    }
    if (evidenceJson.present) {
      map['evidence_json'] = Variable<String>(evidenceJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CriterionScoreCompanion(')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('criterionCode: $criterionCode, ')
          ..write('suggestedBand: $suggestedBand, ')
          ..write('suggested: $suggested, ')
          ..write('finalBand: $finalBand, ')
          ..write('notObserved: $notObserved, ')
          ..write('justification: $justification, ')
          ..write('capBand: $capBand, ')
          ..write('evidenceJson: $evidenceJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Finding extends Table with TableInfo<Finding, FindingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Finding(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _assessmentIdMeta = const VerificationMeta(
    'assessmentId',
  );
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (kind IN (\'STRENGTH\', \'DEVELOPMENT\'))',
  );
  static const VerificationMeta _criterionCodeMeta = const VerificationMeta(
    'criterionCode',
  );
  late final GeneratedColumn<String> criterionCode = GeneratedColumn<String>(
    'criterion_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bodyTextMeta = const VerificationMeta(
    'bodyText',
  );
  late final GeneratedColumn<String> bodyText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _evidenceJsonMeta = const VerificationMeta(
    'evidenceJson',
  );
  late final GeneratedColumn<String> evidenceJson = GeneratedColumn<String>(
    'evidence_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'[]\' CHECK (json_valid(evidence_json))',
    defaultValue: const CustomExpression('\'[]\''),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assessmentId,
    version,
    kind,
    criterionCode,
    bodyText,
    evidenceJson,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'finding';
  @override
  VerificationContext validateIntegrity(
    Insertable<FindingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assessment_id')) {
      context.handle(
        _assessmentIdMeta,
        assessmentId.isAcceptableOrUnknown(
          data['assessment_id']!,
          _assessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('criterion_code')) {
      context.handle(
        _criterionCodeMeta,
        criterionCode.isAcceptableOrUnknown(
          data['criterion_code']!,
          _criterionCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_criterionCodeMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyTextMeta,
        bodyText.isAcceptableOrUnknown(data['text']!, _bodyTextMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyTextMeta);
    }
    if (data.containsKey('evidence_json')) {
      context.handle(
        _evidenceJsonMeta,
        evidenceJson.isAcceptableOrUnknown(
          data['evidence_json']!,
          _evidenceJsonMeta,
        ),
      );
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
  FindingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FindingData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      criterionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criterion_code'],
      )!,
      bodyText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      evidenceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_json'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  Finding createAlias(String alias) {
    return Finding(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY(assessment_id, version)REFERENCES report(assessment_id, version)ON DELETE CASCADE',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class FindingData extends DataClass implements Insertable<FindingData> {
  final String id;
  final String assessmentId;
  final int version;
  final String kind;
  final String criterionCode;
  final String bodyText;

  /// drift: nombre Dart (choca con Table.text)
  final String evidenceJson;
  final int position;
  const FindingData({
    required this.id,
    required this.assessmentId,
    required this.version,
    required this.kind,
    required this.criterionCode,
    required this.bodyText,
    required this.evidenceJson,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['assessment_id'] = Variable<String>(assessmentId);
    map['version'] = Variable<int>(version);
    map['kind'] = Variable<String>(kind);
    map['criterion_code'] = Variable<String>(criterionCode);
    map['text'] = Variable<String>(bodyText);
    map['evidence_json'] = Variable<String>(evidenceJson);
    map['position'] = Variable<int>(position);
    return map;
  }

  FindingCompanion toCompanion(bool nullToAbsent) {
    return FindingCompanion(
      id: Value(id),
      assessmentId: Value(assessmentId),
      version: Value(version),
      kind: Value(kind),
      criterionCode: Value(criterionCode),
      bodyText: Value(bodyText),
      evidenceJson: Value(evidenceJson),
      position: Value(position),
    );
  }

  factory FindingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FindingData(
      id: serializer.fromJson<String>(json['id']),
      assessmentId: serializer.fromJson<String>(json['assessment_id']),
      version: serializer.fromJson<int>(json['version']),
      kind: serializer.fromJson<String>(json['kind']),
      criterionCode: serializer.fromJson<String>(json['criterion_code']),
      bodyText: serializer.fromJson<String>(json['text']),
      evidenceJson: serializer.fromJson<String>(json['evidence_json']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessment_id': serializer.toJson<String>(assessmentId),
      'version': serializer.toJson<int>(version),
      'kind': serializer.toJson<String>(kind),
      'criterion_code': serializer.toJson<String>(criterionCode),
      'text': serializer.toJson<String>(bodyText),
      'evidence_json': serializer.toJson<String>(evidenceJson),
      'position': serializer.toJson<int>(position),
    };
  }

  FindingData copyWith({
    String? id,
    String? assessmentId,
    int? version,
    String? kind,
    String? criterionCode,
    String? bodyText,
    String? evidenceJson,
    int? position,
  }) => FindingData(
    id: id ?? this.id,
    assessmentId: assessmentId ?? this.assessmentId,
    version: version ?? this.version,
    kind: kind ?? this.kind,
    criterionCode: criterionCode ?? this.criterionCode,
    bodyText: bodyText ?? this.bodyText,
    evidenceJson: evidenceJson ?? this.evidenceJson,
    position: position ?? this.position,
  );
  FindingData copyWithCompanion(FindingCompanion data) {
    return FindingData(
      id: data.id.present ? data.id.value : this.id,
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      version: data.version.present ? data.version.value : this.version,
      kind: data.kind.present ? data.kind.value : this.kind,
      criterionCode: data.criterionCode.present
          ? data.criterionCode.value
          : this.criterionCode,
      bodyText: data.bodyText.present ? data.bodyText.value : this.bodyText,
      evidenceJson: data.evidenceJson.present
          ? data.evidenceJson.value
          : this.evidenceJson,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FindingData(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('criterionCode: $criterionCode, ')
          ..write('bodyText: $bodyText, ')
          ..write('evidenceJson: $evidenceJson, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assessmentId,
    version,
    kind,
    criterionCode,
    bodyText,
    evidenceJson,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FindingData &&
          other.id == this.id &&
          other.assessmentId == this.assessmentId &&
          other.version == this.version &&
          other.kind == this.kind &&
          other.criterionCode == this.criterionCode &&
          other.bodyText == this.bodyText &&
          other.evidenceJson == this.evidenceJson &&
          other.position == this.position);
}

class FindingCompanion extends UpdateCompanion<FindingData> {
  final Value<String> id;
  final Value<String> assessmentId;
  final Value<int> version;
  final Value<String> kind;
  final Value<String> criterionCode;
  final Value<String> bodyText;
  final Value<String> evidenceJson;
  final Value<int> position;
  final Value<int> rowid;
  const FindingCompanion({
    this.id = const Value.absent(),
    this.assessmentId = const Value.absent(),
    this.version = const Value.absent(),
    this.kind = const Value.absent(),
    this.criterionCode = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.evidenceJson = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FindingCompanion.insert({
    required String id,
    required String assessmentId,
    required int version,
    required String kind,
    required String criterionCode,
    required String bodyText,
    this.evidenceJson = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assessmentId = Value(assessmentId),
       version = Value(version),
       kind = Value(kind),
       criterionCode = Value(criterionCode),
       bodyText = Value(bodyText),
       position = Value(position);
  static Insertable<FindingData> custom({
    Expression<String>? id,
    Expression<String>? assessmentId,
    Expression<int>? version,
    Expression<String>? kind,
    Expression<String>? criterionCode,
    Expression<String>? bodyText,
    Expression<String>? evidenceJson,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (version != null) 'version': version,
      if (kind != null) 'kind': kind,
      if (criterionCode != null) 'criterion_code': criterionCode,
      if (bodyText != null) 'text': bodyText,
      if (evidenceJson != null) 'evidence_json': evidenceJson,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FindingCompanion copyWith({
    Value<String>? id,
    Value<String>? assessmentId,
    Value<int>? version,
    Value<String>? kind,
    Value<String>? criterionCode,
    Value<String>? bodyText,
    Value<String>? evidenceJson,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return FindingCompanion(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
      version: version ?? this.version,
      kind: kind ?? this.kind,
      criterionCode: criterionCode ?? this.criterionCode,
      bodyText: bodyText ?? this.bodyText,
      evidenceJson: evidenceJson ?? this.evidenceJson,
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
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (criterionCode.present) {
      map['criterion_code'] = Variable<String>(criterionCode.value);
    }
    if (bodyText.present) {
      map['text'] = Variable<String>(bodyText.value);
    }
    if (evidenceJson.present) {
      map['evidence_json'] = Variable<String>(evidenceJson.value);
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
    return (StringBuffer('FindingCompanion(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('criterionCode: $criterionCode, ')
          ..write('bodyText: $bodyText, ')
          ..write('evidenceJson: $evidenceJson, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ActionPoint extends Table with TableInfo<ActionPoint, ActionPointData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ActionPoint(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _refereeIdMeta = const VerificationMeta(
    'refereeId',
  );
  late final GeneratedColumn<String> refereeId = GeneratedColumn<String>(
    'referee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES official(id)',
  );
  static const VerificationMeta _originAssessmentIdMeta =
      const VerificationMeta('originAssessmentId');
  late final GeneratedColumn<String> originAssessmentId =
      GeneratedColumn<String>(
        'origin_assessment_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL REFERENCES assessment(id)',
      );
  static const VerificationMeta _originVersionMeta = const VerificationMeta(
    'originVersion',
  );
  late final GeneratedColumn<int> originVersion = GeneratedColumn<int>(
    'origin_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _criterionCodeMeta = const VerificationMeta(
    'criterionCode',
  );
  late final GeneratedColumn<String> criterionCode = GeneratedColumn<String>(
    'criterion_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bodyTextMeta = const VerificationMeta(
    'bodyText',
  );
  late final GeneratedColumn<String> bodyText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _successIndicatorMeta = const VerificationMeta(
    'successIndicator',
  );
  late final GeneratedColumn<String> successIndicator = GeneratedColumn<String>(
    'success_indicator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (status IN (\'DRAFT\', \'OPEN\', \'CLOSED\'))',
  );
  static const VerificationMeta _closedByAssessmentIdMeta =
      const VerificationMeta('closedByAssessmentId');
  late final GeneratedColumn<String> closedByAssessmentId =
      GeneratedColumn<String>(
        'closed_by_assessment_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'REFERENCES assessment(id)',
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    refereeId,
    originAssessmentId,
    originVersion,
    criterionCode,
    bodyText,
    successIndicator,
    status,
    closedByAssessmentId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'action_point';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionPointData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('referee_id')) {
      context.handle(
        _refereeIdMeta,
        refereeId.isAcceptableOrUnknown(data['referee_id']!, _refereeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_refereeIdMeta);
    }
    if (data.containsKey('origin_assessment_id')) {
      context.handle(
        _originAssessmentIdMeta,
        originAssessmentId.isAcceptableOrUnknown(
          data['origin_assessment_id']!,
          _originAssessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originAssessmentIdMeta);
    }
    if (data.containsKey('origin_version')) {
      context.handle(
        _originVersionMeta,
        originVersion.isAcceptableOrUnknown(
          data['origin_version']!,
          _originVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originVersionMeta);
    }
    if (data.containsKey('criterion_code')) {
      context.handle(
        _criterionCodeMeta,
        criterionCode.isAcceptableOrUnknown(
          data['criterion_code']!,
          _criterionCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_criterionCodeMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyTextMeta,
        bodyText.isAcceptableOrUnknown(data['text']!, _bodyTextMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyTextMeta);
    }
    if (data.containsKey('success_indicator')) {
      context.handle(
        _successIndicatorMeta,
        successIndicator.isAcceptableOrUnknown(
          data['success_indicator']!,
          _successIndicatorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_successIndicatorMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('closed_by_assessment_id')) {
      context.handle(
        _closedByAssessmentIdMeta,
        closedByAssessmentId.isAcceptableOrUnknown(
          data['closed_by_assessment_id']!,
          _closedByAssessmentIdMeta,
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActionPointData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionPointData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      refereeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referee_id'],
      )!,
      originAssessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_assessment_id'],
      )!,
      originVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}origin_version'],
      )!,
      criterionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criterion_code'],
      )!,
      bodyText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      successIndicator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}success_indicator'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      closedByAssessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_by_assessment_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  ActionPoint createAlias(String alias) {
    return ActionPoint(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class ActionPointData extends DataClass implements Insertable<ActionPointData> {
  final String id;
  final String refereeId;
  final String originAssessmentId;
  final int originVersion;
  final String criterionCode;
  final String bodyText;

  /// drift: nombre Dart (choca con Table.text)
  final String successIndicator;
  final String status;

  /// DRAFT hasta finalizar el informe de origen
  final String? closedByAssessmentId;
  final String createdAt;
  const ActionPointData({
    required this.id,
    required this.refereeId,
    required this.originAssessmentId,
    required this.originVersion,
    required this.criterionCode,
    required this.bodyText,
    required this.successIndicator,
    required this.status,
    this.closedByAssessmentId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['referee_id'] = Variable<String>(refereeId);
    map['origin_assessment_id'] = Variable<String>(originAssessmentId);
    map['origin_version'] = Variable<int>(originVersion);
    map['criterion_code'] = Variable<String>(criterionCode);
    map['text'] = Variable<String>(bodyText);
    map['success_indicator'] = Variable<String>(successIndicator);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || closedByAssessmentId != null) {
      map['closed_by_assessment_id'] = Variable<String>(closedByAssessmentId);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ActionPointCompanion toCompanion(bool nullToAbsent) {
    return ActionPointCompanion(
      id: Value(id),
      refereeId: Value(refereeId),
      originAssessmentId: Value(originAssessmentId),
      originVersion: Value(originVersion),
      criterionCode: Value(criterionCode),
      bodyText: Value(bodyText),
      successIndicator: Value(successIndicator),
      status: Value(status),
      closedByAssessmentId: closedByAssessmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(closedByAssessmentId),
      createdAt: Value(createdAt),
    );
  }

  factory ActionPointData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionPointData(
      id: serializer.fromJson<String>(json['id']),
      refereeId: serializer.fromJson<String>(json['referee_id']),
      originAssessmentId: serializer.fromJson<String>(
        json['origin_assessment_id'],
      ),
      originVersion: serializer.fromJson<int>(json['origin_version']),
      criterionCode: serializer.fromJson<String>(json['criterion_code']),
      bodyText: serializer.fromJson<String>(json['text']),
      successIndicator: serializer.fromJson<String>(json['success_indicator']),
      status: serializer.fromJson<String>(json['status']),
      closedByAssessmentId: serializer.fromJson<String?>(
        json['closed_by_assessment_id'],
      ),
      createdAt: serializer.fromJson<String>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'referee_id': serializer.toJson<String>(refereeId),
      'origin_assessment_id': serializer.toJson<String>(originAssessmentId),
      'origin_version': serializer.toJson<int>(originVersion),
      'criterion_code': serializer.toJson<String>(criterionCode),
      'text': serializer.toJson<String>(bodyText),
      'success_indicator': serializer.toJson<String>(successIndicator),
      'status': serializer.toJson<String>(status),
      'closed_by_assessment_id': serializer.toJson<String?>(
        closedByAssessmentId,
      ),
      'created_at': serializer.toJson<String>(createdAt),
    };
  }

  ActionPointData copyWith({
    String? id,
    String? refereeId,
    String? originAssessmentId,
    int? originVersion,
    String? criterionCode,
    String? bodyText,
    String? successIndicator,
    String? status,
    Value<String?> closedByAssessmentId = const Value.absent(),
    String? createdAt,
  }) => ActionPointData(
    id: id ?? this.id,
    refereeId: refereeId ?? this.refereeId,
    originAssessmentId: originAssessmentId ?? this.originAssessmentId,
    originVersion: originVersion ?? this.originVersion,
    criterionCode: criterionCode ?? this.criterionCode,
    bodyText: bodyText ?? this.bodyText,
    successIndicator: successIndicator ?? this.successIndicator,
    status: status ?? this.status,
    closedByAssessmentId: closedByAssessmentId.present
        ? closedByAssessmentId.value
        : this.closedByAssessmentId,
    createdAt: createdAt ?? this.createdAt,
  );
  ActionPointData copyWithCompanion(ActionPointCompanion data) {
    return ActionPointData(
      id: data.id.present ? data.id.value : this.id,
      refereeId: data.refereeId.present ? data.refereeId.value : this.refereeId,
      originAssessmentId: data.originAssessmentId.present
          ? data.originAssessmentId.value
          : this.originAssessmentId,
      originVersion: data.originVersion.present
          ? data.originVersion.value
          : this.originVersion,
      criterionCode: data.criterionCode.present
          ? data.criterionCode.value
          : this.criterionCode,
      bodyText: data.bodyText.present ? data.bodyText.value : this.bodyText,
      successIndicator: data.successIndicator.present
          ? data.successIndicator.value
          : this.successIndicator,
      status: data.status.present ? data.status.value : this.status,
      closedByAssessmentId: data.closedByAssessmentId.present
          ? data.closedByAssessmentId.value
          : this.closedByAssessmentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionPointData(')
          ..write('id: $id, ')
          ..write('refereeId: $refereeId, ')
          ..write('originAssessmentId: $originAssessmentId, ')
          ..write('originVersion: $originVersion, ')
          ..write('criterionCode: $criterionCode, ')
          ..write('bodyText: $bodyText, ')
          ..write('successIndicator: $successIndicator, ')
          ..write('status: $status, ')
          ..write('closedByAssessmentId: $closedByAssessmentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    refereeId,
    originAssessmentId,
    originVersion,
    criterionCode,
    bodyText,
    successIndicator,
    status,
    closedByAssessmentId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionPointData &&
          other.id == this.id &&
          other.refereeId == this.refereeId &&
          other.originAssessmentId == this.originAssessmentId &&
          other.originVersion == this.originVersion &&
          other.criterionCode == this.criterionCode &&
          other.bodyText == this.bodyText &&
          other.successIndicator == this.successIndicator &&
          other.status == this.status &&
          other.closedByAssessmentId == this.closedByAssessmentId &&
          other.createdAt == this.createdAt);
}

class ActionPointCompanion extends UpdateCompanion<ActionPointData> {
  final Value<String> id;
  final Value<String> refereeId;
  final Value<String> originAssessmentId;
  final Value<int> originVersion;
  final Value<String> criterionCode;
  final Value<String> bodyText;
  final Value<String> successIndicator;
  final Value<String> status;
  final Value<String?> closedByAssessmentId;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ActionPointCompanion({
    this.id = const Value.absent(),
    this.refereeId = const Value.absent(),
    this.originAssessmentId = const Value.absent(),
    this.originVersion = const Value.absent(),
    this.criterionCode = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.successIndicator = const Value.absent(),
    this.status = const Value.absent(),
    this.closedByAssessmentId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionPointCompanion.insert({
    required String id,
    required String refereeId,
    required String originAssessmentId,
    required int originVersion,
    required String criterionCode,
    required String bodyText,
    required String successIndicator,
    required String status,
    this.closedByAssessmentId = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       refereeId = Value(refereeId),
       originAssessmentId = Value(originAssessmentId),
       originVersion = Value(originVersion),
       criterionCode = Value(criterionCode),
       bodyText = Value(bodyText),
       successIndicator = Value(successIndicator),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<ActionPointData> custom({
    Expression<String>? id,
    Expression<String>? refereeId,
    Expression<String>? originAssessmentId,
    Expression<int>? originVersion,
    Expression<String>? criterionCode,
    Expression<String>? bodyText,
    Expression<String>? successIndicator,
    Expression<String>? status,
    Expression<String>? closedByAssessmentId,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (refereeId != null) 'referee_id': refereeId,
      if (originAssessmentId != null)
        'origin_assessment_id': originAssessmentId,
      if (originVersion != null) 'origin_version': originVersion,
      if (criterionCode != null) 'criterion_code': criterionCode,
      if (bodyText != null) 'text': bodyText,
      if (successIndicator != null) 'success_indicator': successIndicator,
      if (status != null) 'status': status,
      if (closedByAssessmentId != null)
        'closed_by_assessment_id': closedByAssessmentId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionPointCompanion copyWith({
    Value<String>? id,
    Value<String>? refereeId,
    Value<String>? originAssessmentId,
    Value<int>? originVersion,
    Value<String>? criterionCode,
    Value<String>? bodyText,
    Value<String>? successIndicator,
    Value<String>? status,
    Value<String?>? closedByAssessmentId,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return ActionPointCompanion(
      id: id ?? this.id,
      refereeId: refereeId ?? this.refereeId,
      originAssessmentId: originAssessmentId ?? this.originAssessmentId,
      originVersion: originVersion ?? this.originVersion,
      criterionCode: criterionCode ?? this.criterionCode,
      bodyText: bodyText ?? this.bodyText,
      successIndicator: successIndicator ?? this.successIndicator,
      status: status ?? this.status,
      closedByAssessmentId: closedByAssessmentId ?? this.closedByAssessmentId,
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
    if (refereeId.present) {
      map['referee_id'] = Variable<String>(refereeId.value);
    }
    if (originAssessmentId.present) {
      map['origin_assessment_id'] = Variable<String>(originAssessmentId.value);
    }
    if (originVersion.present) {
      map['origin_version'] = Variable<int>(originVersion.value);
    }
    if (criterionCode.present) {
      map['criterion_code'] = Variable<String>(criterionCode.value);
    }
    if (bodyText.present) {
      map['text'] = Variable<String>(bodyText.value);
    }
    if (successIndicator.present) {
      map['success_indicator'] = Variable<String>(successIndicator.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (closedByAssessmentId.present) {
      map['closed_by_assessment_id'] = Variable<String>(
        closedByAssessmentId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionPointCompanion(')
          ..write('id: $id, ')
          ..write('refereeId: $refereeId, ')
          ..write('originAssessmentId: $originAssessmentId, ')
          ..write('originVersion: $originVersion, ')
          ..write('criterionCode: $criterionCode, ')
          ..write('bodyText: $bodyText, ')
          ..write('successIndicator: $successIndicator, ')
          ..write('status: $status, ')
          ..write('closedByAssessmentId: $closedByAssessmentId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ActionPointReview extends Table
    with TableInfo<ActionPointReview, ActionPointReviewData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ActionPointReview(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assessmentIdMeta = const VerificationMeta(
    'assessmentId',
  );
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _actionPointIdMeta = const VerificationMeta(
    'actionPointId',
  );
  late final GeneratedColumn<String> actionPointId = GeneratedColumn<String>(
    'action_point_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES action_point(id)',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (status IN (\'ACHIEVED\', \'PARTIAL\', \'NOT_ACHIEVED\', \'NOT_OBSERVED\'))',
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _evidenceJsonMeta = const VerificationMeta(
    'evidenceJson',
  );
  late final GeneratedColumn<String> evidenceJson = GeneratedColumn<String>(
    'evidence_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'[]\' CHECK (json_valid(evidence_json))',
    defaultValue: const CustomExpression('\'[]\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    assessmentId,
    version,
    actionPointId,
    status,
    comment,
    evidenceJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'action_point_review';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionPointReviewData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('assessment_id')) {
      context.handle(
        _assessmentIdMeta,
        assessmentId.isAcceptableOrUnknown(
          data['assessment_id']!,
          _assessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('action_point_id')) {
      context.handle(
        _actionPointIdMeta,
        actionPointId.isAcceptableOrUnknown(
          data['action_point_id']!,
          _actionPointIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actionPointIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    } else if (isInserting) {
      context.missing(_commentMeta);
    }
    if (data.containsKey('evidence_json')) {
      context.handle(
        _evidenceJsonMeta,
        evidenceJson.isAcceptableOrUnknown(
          data['evidence_json']!,
          _evidenceJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    assessmentId,
    version,
    actionPointId,
  };
  @override
  ActionPointReviewData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionPointReviewData(
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      actionPointId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_point_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      evidenceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_json'],
      )!,
    );
  }

  @override
  ActionPointReview createAlias(String alias) {
    return ActionPointReview(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(assessment_id, version, action_point_id)',
    'FOREIGN KEY(assessment_id, version)REFERENCES report(assessment_id, version)ON DELETE CASCADE',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ActionPointReviewData extends DataClass
    implements Insertable<ActionPointReviewData> {
  final String assessmentId;
  final int version;
  final String actionPointId;
  final String status;
  final String comment;
  final String evidenceJson;
  const ActionPointReviewData({
    required this.assessmentId,
    required this.version,
    required this.actionPointId,
    required this.status,
    required this.comment,
    required this.evidenceJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['assessment_id'] = Variable<String>(assessmentId);
    map['version'] = Variable<int>(version);
    map['action_point_id'] = Variable<String>(actionPointId);
    map['status'] = Variable<String>(status);
    map['comment'] = Variable<String>(comment);
    map['evidence_json'] = Variable<String>(evidenceJson);
    return map;
  }

  ActionPointReviewCompanion toCompanion(bool nullToAbsent) {
    return ActionPointReviewCompanion(
      assessmentId: Value(assessmentId),
      version: Value(version),
      actionPointId: Value(actionPointId),
      status: Value(status),
      comment: Value(comment),
      evidenceJson: Value(evidenceJson),
    );
  }

  factory ActionPointReviewData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionPointReviewData(
      assessmentId: serializer.fromJson<String>(json['assessment_id']),
      version: serializer.fromJson<int>(json['version']),
      actionPointId: serializer.fromJson<String>(json['action_point_id']),
      status: serializer.fromJson<String>(json['status']),
      comment: serializer.fromJson<String>(json['comment']),
      evidenceJson: serializer.fromJson<String>(json['evidence_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assessment_id': serializer.toJson<String>(assessmentId),
      'version': serializer.toJson<int>(version),
      'action_point_id': serializer.toJson<String>(actionPointId),
      'status': serializer.toJson<String>(status),
      'comment': serializer.toJson<String>(comment),
      'evidence_json': serializer.toJson<String>(evidenceJson),
    };
  }

  ActionPointReviewData copyWith({
    String? assessmentId,
    int? version,
    String? actionPointId,
    String? status,
    String? comment,
    String? evidenceJson,
  }) => ActionPointReviewData(
    assessmentId: assessmentId ?? this.assessmentId,
    version: version ?? this.version,
    actionPointId: actionPointId ?? this.actionPointId,
    status: status ?? this.status,
    comment: comment ?? this.comment,
    evidenceJson: evidenceJson ?? this.evidenceJson,
  );
  ActionPointReviewData copyWithCompanion(ActionPointReviewCompanion data) {
    return ActionPointReviewData(
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      version: data.version.present ? data.version.value : this.version,
      actionPointId: data.actionPointId.present
          ? data.actionPointId.value
          : this.actionPointId,
      status: data.status.present ? data.status.value : this.status,
      comment: data.comment.present ? data.comment.value : this.comment,
      evidenceJson: data.evidenceJson.present
          ? data.evidenceJson.value
          : this.evidenceJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionPointReviewData(')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('actionPointId: $actionPointId, ')
          ..write('status: $status, ')
          ..write('comment: $comment, ')
          ..write('evidenceJson: $evidenceJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    assessmentId,
    version,
    actionPointId,
    status,
    comment,
    evidenceJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionPointReviewData &&
          other.assessmentId == this.assessmentId &&
          other.version == this.version &&
          other.actionPointId == this.actionPointId &&
          other.status == this.status &&
          other.comment == this.comment &&
          other.evidenceJson == this.evidenceJson);
}

class ActionPointReviewCompanion
    extends UpdateCompanion<ActionPointReviewData> {
  final Value<String> assessmentId;
  final Value<int> version;
  final Value<String> actionPointId;
  final Value<String> status;
  final Value<String> comment;
  final Value<String> evidenceJson;
  final Value<int> rowid;
  const ActionPointReviewCompanion({
    this.assessmentId = const Value.absent(),
    this.version = const Value.absent(),
    this.actionPointId = const Value.absent(),
    this.status = const Value.absent(),
    this.comment = const Value.absent(),
    this.evidenceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionPointReviewCompanion.insert({
    required String assessmentId,
    required int version,
    required String actionPointId,
    required String status,
    required String comment,
    this.evidenceJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : assessmentId = Value(assessmentId),
       version = Value(version),
       actionPointId = Value(actionPointId),
       status = Value(status),
       comment = Value(comment);
  static Insertable<ActionPointReviewData> custom({
    Expression<String>? assessmentId,
    Expression<int>? version,
    Expression<String>? actionPointId,
    Expression<String>? status,
    Expression<String>? comment,
    Expression<String>? evidenceJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (version != null) 'version': version,
      if (actionPointId != null) 'action_point_id': actionPointId,
      if (status != null) 'status': status,
      if (comment != null) 'comment': comment,
      if (evidenceJson != null) 'evidence_json': evidenceJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionPointReviewCompanion copyWith({
    Value<String>? assessmentId,
    Value<int>? version,
    Value<String>? actionPointId,
    Value<String>? status,
    Value<String>? comment,
    Value<String>? evidenceJson,
    Value<int>? rowid,
  }) {
    return ActionPointReviewCompanion(
      assessmentId: assessmentId ?? this.assessmentId,
      version: version ?? this.version,
      actionPointId: actionPointId ?? this.actionPointId,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      evidenceJson: evidenceJson ?? this.evidenceJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (actionPointId.present) {
      map['action_point_id'] = Variable<String>(actionPointId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (evidenceJson.present) {
      map['evidence_json'] = Variable<String>(evidenceJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionPointReviewCompanion(')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('actionPointId: $actionPointId, ')
          ..write('status: $status, ')
          ..write('comment: $comment, ')
          ..write('evidenceJson: $evidenceJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Outbox extends Table with TableInfo<Outbox, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Outbox(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _aggregateIdMeta = const VerificationMeta(
    'aggregateId',
  );
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
    'aggregate_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (json_valid(payload_json))',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  late final GeneratedColumn<String> sentAt = GeneratedColumn<String>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    aggregateId,
    kind,
    payloadJson,
    createdAt,
    sentAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
        _aggregateIdMeta,
        aggregateId.isAcceptableOrUnknown(
          data['aggregate_id']!,
          _aggregateIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      aggregateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aggregate_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sent_at'],
      ),
    );
  }

  @override
  Outbox createAlias(String alias) {
    return Outbox(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int id;
  final String aggregateId;
  final String kind;

  /// 'REPORT_FINALIZED', 'INCIDENT_UPSERTED'…
  final String payloadJson;
  final String createdAt;
  final String? sentAt;
  const OutboxData({
    required this.id,
    required this.aggregateId,
    required this.kind,
    required this.payloadJson,
    required this.createdAt,
    this.sentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<String>(sentAt);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      aggregateId: Value(aggregateId),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<int>(json['id']),
      aggregateId: serializer.fromJson<String>(json['aggregate_id']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payload_json']),
      createdAt: serializer.fromJson<String>(json['created_at']),
      sentAt: serializer.fromJson<String?>(json['sent_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aggregate_id': serializer.toJson<String>(aggregateId),
      'kind': serializer.toJson<String>(kind),
      'payload_json': serializer.toJson<String>(payloadJson),
      'created_at': serializer.toJson<String>(createdAt),
      'sent_at': serializer.toJson<String?>(sentAt),
    };
  }

  OutboxData copyWith({
    int? id,
    String? aggregateId,
    String? kind,
    String? payloadJson,
    String? createdAt,
    Value<String?> sentAt = const Value.absent(),
  }) => OutboxData(
    id: id ?? this.id,
    aggregateId: aggregateId ?? this.aggregateId,
    kind: kind ?? this.kind,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      aggregateId: data.aggregateId.present
          ? data.aggregateId.value
          : this.aggregateId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, aggregateId, kind, payloadJson, createdAt, sentAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.aggregateId == this.aggregateId &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.sentAt == this.sentAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> id;
  final Value<String> aggregateId;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<String> createdAt;
  final Value<String?> sentAt;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sentAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.id = const Value.absent(),
    required String aggregateId,
    required String kind,
    required String payloadJson,
    required String createdAt,
    this.sentAt = const Value.absent(),
  }) : aggregateId = Value(aggregateId),
       kind = Value(kind),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxData> custom({
    Expression<int>? id,
    Expression<String>? aggregateId,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<String>? createdAt,
    Expression<String>? sentAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (sentAt != null) 'sent_at': sentAt,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? id,
    Value<String>? aggregateId,
    Value<String>? kind,
    Value<String>? payloadJson,
    Value<String>? createdAt,
    Value<String?>? sentAt,
  }) {
    return OutboxCompanion(
      id: id ?? this.id,
      aggregateId: aggregateId ?? this.aggregateId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<String>(sentAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }
}

class ExportLog extends Table with TableInfo<ExportLog, ExportLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ExportLog(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _assessmentIdMeta = const VerificationMeta(
    'assessmentId',
  );
  late final GeneratedColumn<String> assessmentId = GeneratedColumn<String>(
    'assessment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES assessment(id)',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (format IN (\'JSON\', \'PDF\'))',
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assessmentId,
    version,
    format,
    relativePath,
    sha256,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('assessment_id')) {
      context.handle(
        _assessmentIdMeta,
        assessmentId.isAcceptableOrUnknown(
          data['assessment_id']!,
          _assessmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assessmentIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
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
  ExportLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      assessmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  ExportLog createAlias(String alias) {
    return ExportLog(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class ExportLogData extends DataClass implements Insertable<ExportLogData> {
  final String id;
  final String assessmentId;
  final int version;
  final String format;
  final String relativePath;
  final String sha256;
  final String createdAt;
  const ExportLogData({
    required this.id,
    required this.assessmentId,
    required this.version,
    required this.format,
    required this.relativePath,
    required this.sha256,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['assessment_id'] = Variable<String>(assessmentId);
    map['version'] = Variable<int>(version);
    map['format'] = Variable<String>(format);
    map['relative_path'] = Variable<String>(relativePath);
    map['sha256'] = Variable<String>(sha256);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  ExportLogCompanion toCompanion(bool nullToAbsent) {
    return ExportLogCompanion(
      id: Value(id),
      assessmentId: Value(assessmentId),
      version: Value(version),
      format: Value(format),
      relativePath: Value(relativePath),
      sha256: Value(sha256),
      createdAt: Value(createdAt),
    );
  }

  factory ExportLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportLogData(
      id: serializer.fromJson<String>(json['id']),
      assessmentId: serializer.fromJson<String>(json['assessment_id']),
      version: serializer.fromJson<int>(json['version']),
      format: serializer.fromJson<String>(json['format']),
      relativePath: serializer.fromJson<String>(json['relative_path']),
      sha256: serializer.fromJson<String>(json['sha256']),
      createdAt: serializer.fromJson<String>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'assessment_id': serializer.toJson<String>(assessmentId),
      'version': serializer.toJson<int>(version),
      'format': serializer.toJson<String>(format),
      'relative_path': serializer.toJson<String>(relativePath),
      'sha256': serializer.toJson<String>(sha256),
      'created_at': serializer.toJson<String>(createdAt),
    };
  }

  ExportLogData copyWith({
    String? id,
    String? assessmentId,
    int? version,
    String? format,
    String? relativePath,
    String? sha256,
    String? createdAt,
  }) => ExportLogData(
    id: id ?? this.id,
    assessmentId: assessmentId ?? this.assessmentId,
    version: version ?? this.version,
    format: format ?? this.format,
    relativePath: relativePath ?? this.relativePath,
    sha256: sha256 ?? this.sha256,
    createdAt: createdAt ?? this.createdAt,
  );
  ExportLogData copyWithCompanion(ExportLogCompanion data) {
    return ExportLogData(
      id: data.id.present ? data.id.value : this.id,
      assessmentId: data.assessmentId.present
          ? data.assessmentId.value
          : this.assessmentId,
      version: data.version.present ? data.version.value : this.version,
      format: data.format.present ? data.format.value : this.format,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportLogData(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('format: $format, ')
          ..write('relativePath: $relativePath, ')
          ..write('sha256: $sha256, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assessmentId,
    version,
    format,
    relativePath,
    sha256,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportLogData &&
          other.id == this.id &&
          other.assessmentId == this.assessmentId &&
          other.version == this.version &&
          other.format == this.format &&
          other.relativePath == this.relativePath &&
          other.sha256 == this.sha256 &&
          other.createdAt == this.createdAt);
}

class ExportLogCompanion extends UpdateCompanion<ExportLogData> {
  final Value<String> id;
  final Value<String> assessmentId;
  final Value<int> version;
  final Value<String> format;
  final Value<String> relativePath;
  final Value<String> sha256;
  final Value<String> createdAt;
  final Value<int> rowid;
  const ExportLogCompanion({
    this.id = const Value.absent(),
    this.assessmentId = const Value.absent(),
    this.version = const Value.absent(),
    this.format = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExportLogCompanion.insert({
    required String id,
    required String assessmentId,
    required int version,
    required String format,
    required String relativePath,
    required String sha256,
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       assessmentId = Value(assessmentId),
       version = Value(version),
       format = Value(format),
       relativePath = Value(relativePath),
       sha256 = Value(sha256),
       createdAt = Value(createdAt);
  static Insertable<ExportLogData> custom({
    Expression<String>? id,
    Expression<String>? assessmentId,
    Expression<int>? version,
    Expression<String>? format,
    Expression<String>? relativePath,
    Expression<String>? sha256,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assessmentId != null) 'assessment_id': assessmentId,
      if (version != null) 'version': version,
      if (format != null) 'format': format,
      if (relativePath != null) 'relative_path': relativePath,
      if (sha256 != null) 'sha256': sha256,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExportLogCompanion copyWith({
    Value<String>? id,
    Value<String>? assessmentId,
    Value<int>? version,
    Value<String>? format,
    Value<String>? relativePath,
    Value<String>? sha256,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return ExportLogCompanion(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
      version: version ?? this.version,
      format: format ?? this.format,
      relativePath: relativePath ?? this.relativePath,
      sha256: sha256 ?? this.sha256,
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
    if (assessmentId.present) {
      map['assessment_id'] = Variable<String>(assessmentId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportLogCompanion(')
          ..write('id: $id, ')
          ..write('assessmentId: $assessmentId, ')
          ..write('version: $version, ')
          ..write('format: $format, ')
          ..write('relativePath: $relativePath, ')
          ..write('sha256: $sha256, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Official official = Official(this);
  late final AssessorProfile assessorProfile = AssessorProfile(this);
  late final Rubric rubric = Rubric(this);
  late final Trigger rubricPublishedImmutable = Trigger(
    'CREATE TRIGGER rubric_published_immutable BEFORE UPDATE OF definition_json, code, version ON rubric WHEN OLD.status <> \'DRAFT\' BEGIN SELECT RAISE (ABORT, \'RUBRIC_IMMUTABLE\');END',
    'rubric_published_immutable',
  );
  late final Assessment assessment = Assessment(this);
  late final Index assessmentKickoff = Index(
    'assessment_kickoff',
    'CREATE INDEX assessment_kickoff ON assessment (kickoff_local)',
  );
  late final Index assessmentByReferee = Index(
    'assessment_by_referee',
    'CREATE INDEX assessment_by_referee ON assessment (referee_id)',
  );
  late final ClockEvent clockEvent = ClockEvent(this);
  late final Trigger clockEventNoUpdate = Trigger(
    'CREATE TRIGGER clock_event_no_update BEFORE UPDATE ON clock_event BEGIN SELECT RAISE (ABORT, \'CLOCK_LOG_APPEND_ONLY\');END',
    'clock_event_no_update',
  );
  late final Trigger clockEventNoDelete = Trigger(
    'CREATE TRIGGER clock_event_no_delete BEFORE DELETE ON clock_event WHEN (SELECT status FROM assessment WHERE id = OLD.assessment_id) IS NOT NULL BEGIN SELECT RAISE (ABORT, \'CLOCK_LOG_APPEND_ONLY\');END',
    'clock_event_no_delete',
  );
  late final SessionTimeAnchor sessionTimeAnchor = SessionTimeAnchor(this);
  late final Incident incident = Incident(this);
  late final Index incidentByCriterion = Index(
    'incident_by_criterion',
    'CREATE INDEX incident_by_criterion ON incident (assessment_id, criterion_code) WHERE status <> \'VOID\'',
  );
  late final Index incidentPending = Index(
    'incident_pending',
    'CREATE INDEX incident_pending ON incident (assessment_id) WHERE verdict = \'PENDING\' AND status <> \'VOID\'',
  );
  late final IncidentRevision incidentRevision = IncidentRevision(this);
  late final Trigger incidentAudit = Trigger(
    'CREATE TRIGGER incident_audit AFTER UPDATE ON incident BEGIN INSERT INTO incident_revision (incident_id, revised_at, previous_json) VALUES (OLD.id, NEW.updated_at, json_object(\'category\', OLD.category, \'criterion_code\', OLD.criterion_code, \'verdict\', OLD.verdict, \'impact\', OLD.impact, \'impact_confirmed\', OLD.impact_confirmed, \'notes\', OLD.notes, \'decision_taken\', json(OLD.decision_taken_json), \'decision_expected\', json(OLD.decision_expected_json), \'match_clock_ms\', OLD.match_clock_ms, \'status\', OLD.status, \'updated_at\', OLD.updated_at));END',
    'incident_audit',
  );
  late final Trigger incidentLockedAfterFinalize = Trigger(
    'CREATE TRIGGER incident_locked_after_finalize BEFORE UPDATE ON incident WHEN (SELECT status FROM assessment WHERE id = OLD.assessment_id) IN (\'FINALIZED\', \'ARCHIVED\') BEGIN SELECT RAISE (ABORT, \'ASSESSMENT_LOCKED\');END',
    'incident_locked_after_finalize',
  );
  late final Attachment attachment = Attachment(this);
  late final Report report = Report(this);
  late final Trigger reportFinalizedImmutable = Trigger(
    'CREATE TRIGGER report_finalized_immutable BEFORE UPDATE ON report WHEN OLD.status = \'FINALIZED\' AND NOT(NEW.status = \'SUPERSEDED\' AND NEW.content_hash IS OLD.content_hash AND NEW.canonical_json IS OLD.canonical_json AND NEW.overall_score IS OLD.overall_score AND NEW.band IS OLD.band AND NEW.summary IS OLD.summary)BEGIN SELECT RAISE (ABORT, \'REPORT_LOCKED\');END',
    'report_finalized_immutable',
  );
  late final Trigger reportSupersededImmutable = Trigger(
    'CREATE TRIGGER report_superseded_immutable BEFORE UPDATE ON report WHEN OLD.status = \'SUPERSEDED\' BEGIN SELECT RAISE (ABORT, \'REPORT_LOCKED\');END',
    'report_superseded_immutable',
  );
  late final CriterionScore criterionScore = CriterionScore(this);
  late final Finding finding = Finding(this);
  late final ActionPoint actionPoint = ActionPoint(this);
  late final Index actionPointOpen = Index(
    'action_point_open',
    'CREATE INDEX action_point_open ON action_point (referee_id) WHERE status = \'OPEN\'',
  );
  late final ActionPointReview actionPointReview = ActionPointReview(this);
  late final Outbox outbox = Outbox(this);
  late final ExportLog exportLog = ExportLog(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    official,
    assessorProfile,
    rubric,
    rubricPublishedImmutable,
    assessment,
    assessmentKickoff,
    assessmentByReferee,
    clockEvent,
    clockEventNoUpdate,
    clockEventNoDelete,
    sessionTimeAnchor,
    incident,
    incidentByCriterion,
    incidentPending,
    incidentRevision,
    incidentAudit,
    incidentLockedAfterFinalize,
    attachment,
    report,
    reportFinalizedImmutable,
    reportSupersededImmutable,
    criterionScore,
    finding,
    actionPoint,
    actionPointOpen,
    actionPointReview,
    outbox,
    exportLog,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rubric',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assessment',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('clock_event', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clock_event',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clock_event',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assessment',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_time_anchor', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assessment',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('incident', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'incident',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('incident_revision', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'incident',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('incident_revision', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'incident',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'incident',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachment', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assessment',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('report', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'report',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'report',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'report',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('criterion_score', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'report',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('finding', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'report',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('action_point_review', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $OfficialCreateCompanionBuilder = OfficialCompanion Function({
  required String id,
  required String fullName,
  Value<String?> federationLicence,
  Value<String?> grade,
  Value<String?> homeSociety,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $OfficialUpdateCompanionBuilder = OfficialCompanion Function({
  Value<String> id,
  Value<String> fullName,
  Value<String?> federationLicence,
  Value<String?> grade,
  Value<String?> homeSociety,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

final class $OfficialReferences
    extends BaseReferences<_$AppDatabase, Official, OfficialData> {
  $OfficialReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Assessment, List<AssessmentData>>
  _assessmentRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessment,
    aliasName: 'official__id__assessment__referee_id',
  );

  $AssessmentProcessedTableManager get assessmentRefs {
    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.refereeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assessmentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Report, List<ReportData>> _reportRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.report,
    aliasName: 'official__id__report__referee_id',
  );

  $ReportProcessedTableManager get reportRefs {
    final manager = $ReportTableManager(
      $_db,
      $_db.report,
    ).filter((f) => f.refereeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reportRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ActionPoint, List<ActionPointData>>
  _actionPointRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.actionPoint,
    aliasName: 'official__id__action_point__referee_id',
  );

  $ActionPointProcessedTableManager get actionPointRefs {
    final manager = $ActionPointTableManager(
      $_db,
      $_db.actionPoint,
    ).filter((f) => f.refereeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_actionPointRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $OfficialFilterComposer extends Composer<_$AppDatabase, Official> {
  $OfficialFilterComposer({
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

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get federationLicence => $composableBuilder(
    column: $table.federationLicence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeSociety => $composableBuilder(
    column: $table.homeSociety,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assessmentRefs(
    Expression<bool> Function($AssessmentFilterComposer f) f,
  ) {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.refereeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reportRefs(
    Expression<bool> Function($ReportFilterComposer f) f,
  ) {
    final $ReportFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.report,
      getReferencedColumn: (t) => t.refereeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReportFilterComposer(
            $db: $db,
            $table: $db.report,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> actionPointRefs(
    Expression<bool> Function($ActionPointFilterComposer f) f,
  ) {
    final $ActionPointFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actionPoint,
      getReferencedColumn: (t) => t.refereeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActionPointFilterComposer(
            $db: $db,
            $table: $db.actionPoint,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $OfficialOrderingComposer extends Composer<_$AppDatabase, Official> {
  $OfficialOrderingComposer({
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

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get federationLicence => $composableBuilder(
    column: $table.federationLicence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeSociety => $composableBuilder(
    column: $table.homeSociety,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $OfficialAnnotationComposer extends Composer<_$AppDatabase, Official> {
  $OfficialAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get federationLicence => $composableBuilder(
    column: $table.federationLicence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get homeSociety => $composableBuilder(
    column: $table.homeSociety,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> assessmentRefs<T extends Object>(
    Expression<T> Function($AssessmentAnnotationComposer a) f,
  ) {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.refereeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reportRefs<T extends Object>(
    Expression<T> Function($ReportAnnotationComposer a) f,
  ) {
    final $ReportAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.report,
      getReferencedColumn: (t) => t.refereeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReportAnnotationComposer(
            $db: $db,
            $table: $db.report,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> actionPointRefs<T extends Object>(
    Expression<T> Function($ActionPointAnnotationComposer a) f,
  ) {
    final $ActionPointAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actionPoint,
      getReferencedColumn: (t) => t.refereeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActionPointAnnotationComposer(
            $db: $db,
            $table: $db.actionPoint,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $OfficialTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Official,
          OfficialData,
          $OfficialFilterComposer,
          $OfficialOrderingComposer,
          $OfficialAnnotationComposer,
          $OfficialCreateCompanionBuilder,
          $OfficialUpdateCompanionBuilder,
          (OfficialData, $OfficialReferences),
          OfficialData,
          PrefetchHooks Function({
            bool assessmentRefs,
            bool reportRefs,
            bool actionPointRefs,
          })
        > {
  $OfficialTableManager(_$AppDatabase db, Official table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $OfficialFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $OfficialOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $OfficialAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> federationLicence = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<String?> homeSociety = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfficialCompanion(
                id: id,
                fullName: fullName,
                federationLicence: federationLicence,
                grade: grade,
                homeSociety: homeSociety,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fullName,
                Value<String?> federationLicence = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<String?> homeSociety = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OfficialCompanion.insert(
                id: id,
                fullName: fullName,
                federationLicence: federationLicence,
                grade: grade,
                homeSociety: homeSociety,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Official, OfficialData>(table),
                  $OfficialReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                assessmentRefs = false,
                reportRefs = false,
                actionPointRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (assessmentRefs) db.assessment,
                    if (reportRefs) db.report,
                    if (actionPointRefs) db.actionPoint,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (assessmentRefs)
                        await $_getPrefetchedData<
                          OfficialData,
                          Official,
                          AssessmentData
                        >(
                          currentTable: table,
                          referencedTable: $OfficialReferences
                              ._assessmentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $OfficialReferences(db, table, p0).assessmentRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.refereeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reportRefs)
                        await $_getPrefetchedData<
                          OfficialData,
                          Official,
                          ReportData
                        >(
                          currentTable: table,
                          referencedTable: $OfficialReferences._reportRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $OfficialReferences(db, table, p0).reportRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.refereeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (actionPointRefs)
                        await $_getPrefetchedData<
                          OfficialData,
                          Official,
                          ActionPointData
                        >(
                          currentTable: table,
                          referencedTable: $OfficialReferences
                              ._actionPointRefsTable(db),
                          managerFromTypedResult: (p0) => $OfficialReferences(
                            db,
                            table,
                            p0,
                          ).actionPointRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.refereeId == item.id,
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

typedef $OfficialProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Official,
      OfficialData,
      $OfficialFilterComposer,
      $OfficialOrderingComposer,
      $OfficialAnnotationComposer,
      $OfficialCreateCompanionBuilder,
      $OfficialUpdateCompanionBuilder,
      (OfficialData, $OfficialReferences),
      OfficialData,
      PrefetchHooks Function({
        bool assessmentRefs,
        bool reportRefs,
        bool actionPointRefs,
      })
    >;
typedef $AssessorProfileCreateCompanionBuilder =
    AssessorProfileCompanion Function({
      required String id,
      required String fullName,
      Value<String?> federationLicence,
      Value<String?> email,
      Value<int> rowid,
    });
typedef $AssessorProfileUpdateCompanionBuilder =
    AssessorProfileCompanion Function({
      Value<String> id,
      Value<String> fullName,
      Value<String?> federationLicence,
      Value<String?> email,
      Value<int> rowid,
    });

final class $AssessorProfileReferences
    extends
        BaseReferences<_$AppDatabase, AssessorProfile, AssessorProfileData> {
  $AssessorProfileReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Assessment, List<AssessmentData>>
  _assessmentRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessment,
    aliasName: 'assessor_profile__id__assessment__assessor_id',
  );

  $AssessmentProcessedTableManager get assessmentRefs {
    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.assessorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assessmentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $AssessorProfileFilterComposer
    extends Composer<_$AppDatabase, AssessorProfile> {
  $AssessorProfileFilterComposer({
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

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get federationLicence => $composableBuilder(
    column: $table.federationLicence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assessmentRefs(
    Expression<bool> Function($AssessmentFilterComposer f) f,
  ) {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.assessorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $AssessorProfileOrderingComposer
    extends Composer<_$AppDatabase, AssessorProfile> {
  $AssessorProfileOrderingComposer({
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

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get federationLicence => $composableBuilder(
    column: $table.federationLicence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AssessorProfileAnnotationComposer
    extends Composer<_$AppDatabase, AssessorProfile> {
  $AssessorProfileAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get federationLicence => $composableBuilder(
    column: $table.federationLicence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  Expression<T> assessmentRefs<T extends Object>(
    Expression<T> Function($AssessmentAnnotationComposer a) f,
  ) {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.assessorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $AssessorProfileTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          AssessorProfile,
          AssessorProfileData,
          $AssessorProfileFilterComposer,
          $AssessorProfileOrderingComposer,
          $AssessorProfileAnnotationComposer,
          $AssessorProfileCreateCompanionBuilder,
          $AssessorProfileUpdateCompanionBuilder,
          (AssessorProfileData, $AssessorProfileReferences),
          AssessorProfileData,
          PrefetchHooks Function({bool assessmentRefs})
        > {
  $AssessorProfileTableManager(_$AppDatabase db, AssessorProfile table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AssessorProfileFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AssessorProfileOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AssessorProfileAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> federationLicence = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessorProfileCompanion(
                id: id,
                fullName: fullName,
                federationLicence: federationLicence,
                email: email,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fullName,
                Value<String?> federationLicence = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessorProfileCompanion.insert(
                id: id,
                fullName: fullName,
                federationLicence: federationLicence,
                email: email,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AssessorProfile, AssessorProfileData>(table),
                  $AssessorProfileReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assessmentRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (assessmentRefs) db.assessment],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentRefs)
                    await $_getPrefetchedData<
                      AssessorProfileData,
                      AssessorProfile,
                      AssessmentData
                    >(
                      currentTable: table,
                      referencedTable: $AssessorProfileReferences
                          ._assessmentRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $AssessorProfileReferences(
                            db,
                            table,
                            p0,
                          ).assessmentRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.assessorId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $AssessorProfileProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      AssessorProfile,
      AssessorProfileData,
      $AssessorProfileFilterComposer,
      $AssessorProfileOrderingComposer,
      $AssessorProfileAnnotationComposer,
      $AssessorProfileCreateCompanionBuilder,
      $AssessorProfileUpdateCompanionBuilder,
      (AssessorProfileData, $AssessorProfileReferences),
      AssessorProfileData,
      PrefetchHooks Function({bool assessmentRefs})
    >;
typedef $RubricCreateCompanionBuilder = RubricCompanion Function({
  required String id,
  required String code,
  required String version,
  required String status,
  required String definitionJson,
  Value<int> rowid,
});
typedef $RubricUpdateCompanionBuilder = RubricCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<String> version,
  Value<String> status,
  Value<String> definitionJson,
  Value<int> rowid,
});

final class $RubricReferences
    extends BaseReferences<_$AppDatabase, Rubric, RubricData> {
  $RubricReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Assessment, List<AssessmentData>>
  _assessmentRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessment,
    aliasName: 'rubric__id__assessment__rubric_id',
  );

  $AssessmentProcessedTableManager get assessmentRefs {
    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.rubricId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assessmentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Report, List<ReportData>> _reportRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.report,
    aliasName: 'rubric__id__report__rubric_id',
  );

  $ReportProcessedTableManager get reportRefs {
    final manager = $ReportTableManager(
      $_db,
      $_db.report,
    ).filter((f) => f.rubricId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reportRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $RubricFilterComposer extends Composer<_$AppDatabase, Rubric> {
  $RubricFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get definitionJson => $composableBuilder(
    column: $table.definitionJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assessmentRefs(
    Expression<bool> Function($AssessmentFilterComposer f) f,
  ) {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.rubricId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reportRefs(
    Expression<bool> Function($ReportFilterComposer f) f,
  ) {
    final $ReportFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.report,
      getReferencedColumn: (t) => t.rubricId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReportFilterComposer(
            $db: $db,
            $table: $db.report,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $RubricOrderingComposer extends Composer<_$AppDatabase, Rubric> {
  $RubricOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get definitionJson => $composableBuilder(
    column: $table.definitionJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $RubricAnnotationComposer extends Composer<_$AppDatabase, Rubric> {
  $RubricAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get definitionJson => $composableBuilder(
    column: $table.definitionJson,
    builder: (column) => column,
  );

  Expression<T> assessmentRefs<T extends Object>(
    Expression<T> Function($AssessmentAnnotationComposer a) f,
  ) {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.rubricId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reportRefs<T extends Object>(
    Expression<T> Function($ReportAnnotationComposer a) f,
  ) {
    final $ReportAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.report,
      getReferencedColumn: (t) => t.rubricId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReportAnnotationComposer(
            $db: $db,
            $table: $db.report,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $RubricTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Rubric,
          RubricData,
          $RubricFilterComposer,
          $RubricOrderingComposer,
          $RubricAnnotationComposer,
          $RubricCreateCompanionBuilder,
          $RubricUpdateCompanionBuilder,
          (RubricData, $RubricReferences),
          RubricData,
          PrefetchHooks Function({bool assessmentRefs, bool reportRefs})
        > {
  $RubricTableManager(_$AppDatabase db, Rubric table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $RubricFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $RubricOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $RubricAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> definitionJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RubricCompanion(
                id: id,
                code: code,
                version: version,
                status: status,
                definitionJson: definitionJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String version,
                required String status,
                required String definitionJson,
                Value<int> rowid = const Value.absent(),
              }) => RubricCompanion.insert(
                id: id,
                code: code,
                version: version,
                status: status,
                definitionJson: definitionJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Rubric, RubricData>(table),
                  $RubricReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({assessmentRefs = false, reportRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (assessmentRefs) db.assessment,
                    if (reportRefs) db.report,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (assessmentRefs)
                        await $_getPrefetchedData<
                          RubricData,
                          Rubric,
                          AssessmentData
                        >(
                          currentTable: table,
                          referencedTable: $RubricReferences
                              ._assessmentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $RubricReferences(db, table, p0).assessmentRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rubricId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reportRefs)
                        await $_getPrefetchedData<
                          RubricData,
                          Rubric,
                          ReportData
                        >(
                          currentTable: table,
                          referencedTable: $RubricReferences._reportRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $RubricReferences(db, table, p0).reportRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rubricId == item.id,
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

typedef $RubricProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Rubric,
      RubricData,
      $RubricFilterComposer,
      $RubricOrderingComposer,
      $RubricAnnotationComposer,
      $RubricCreateCompanionBuilder,
      $RubricUpdateCompanionBuilder,
      (RubricData, $RubricReferences),
      RubricData,
      PrefetchHooks Function({bool assessmentRefs, bool reportRefs})
    >;
typedef $AssessmentCreateCompanionBuilder = AssessmentCompanion Function({
  required String id,
  Value<int> schemaVersion,
  required String status,
  required String rubricId,
  required String assessorId,
  required String refereeId,
  Value<String?> ar1Name,
  Value<String?> ar2Name,
  required String competition,
  Value<String?> round,
  required String kickoffLocal,
  required String kickoffTz,
  required String venue,
  required String homeTeam,
  required String awayTeam,
  required String observationMode,
  Value<String?> difficulty,
  required String categoryCode,
  required String categoryJson,
  Value<String?> conditionsJson,
  Value<int?> finalScoreHome,
  Value<int?> finalScoreAway,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $AssessmentUpdateCompanionBuilder = AssessmentCompanion Function({
  Value<String> id,
  Value<int> schemaVersion,
  Value<String> status,
  Value<String> rubricId,
  Value<String> assessorId,
  Value<String> refereeId,
  Value<String?> ar1Name,
  Value<String?> ar2Name,
  Value<String> competition,
  Value<String?> round,
  Value<String> kickoffLocal,
  Value<String> kickoffTz,
  Value<String> venue,
  Value<String> homeTeam,
  Value<String> awayTeam,
  Value<String> observationMode,
  Value<String?> difficulty,
  Value<String> categoryCode,
  Value<String> categoryJson,
  Value<String?> conditionsJson,
  Value<int?> finalScoreHome,
  Value<int?> finalScoreAway,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

final class $AssessmentReferences
    extends BaseReferences<_$AppDatabase, Assessment, AssessmentData> {
  $AssessmentReferences(super.$_db, super.$_table, super.$_typedResult);

  static Rubric _rubricIdTable(_$AppDatabase db) =>
      db.rubric.createAlias('assessment__rubric_id__rubric__id');

  $RubricProcessedTableManager get rubricId {
    final $_column = $_itemColumn<String>('rubric_id')!;

    final manager = $RubricTableManager(
      $_db,
      $_db.rubric,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rubricIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static AssessorProfile _assessorIdTable(_$AppDatabase db) => db
      .assessorProfile
      .createAlias('assessment__assessor_id__assessor_profile__id');

  $AssessorProfileProcessedTableManager get assessorId {
    final $_column = $_itemColumn<String>('assessor_id')!;

    final manager = $AssessorProfileTableManager(
      $_db,
      $_db.assessorProfile,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assessorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Official _refereeIdTable(_$AppDatabase db) =>
      db.official.createAlias('assessment__referee_id__official__id');

  $OfficialProcessedTableManager get refereeId {
    final $_column = $_itemColumn<String>('referee_id')!;

    final manager = $OfficialTableManager(
      $_db,
      $_db.official,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_refereeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<ClockEvent, List<ClockEventData>>
  _clockEventRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.clockEvent,
    aliasName: 'assessment__id__clock_event__assessment_id',
  );

  $ClockEventProcessedTableManager get clockEventRefs {
    final manager = $ClockEventTableManager(
      $_db,
      $_db.clockEvent,
    ).filter((f) => f.assessmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_clockEventRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<SessionTimeAnchor, List<SessionTimeAnchorData>>
  _sessionTimeAnchorRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionTimeAnchor,
        aliasName: 'assessment__id__session_time_anchor__assessment_id',
      );

  $SessionTimeAnchorProcessedTableManager get sessionTimeAnchorRefs {
    final manager = $SessionTimeAnchorTableManager(
      $_db,
      $_db.sessionTimeAnchor,
    ).filter((f) => f.assessmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionTimeAnchorRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Incident, List<IncidentData>> _incidentRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.incident,
    aliasName: 'assessment__id__incident__assessment_id',
  );

  $IncidentProcessedTableManager get incidentRefs {
    final manager = $IncidentTableManager(
      $_db,
      $_db.incident,
    ).filter((f) => f.assessmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incidentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Report, List<ReportData>> _reportRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.report,
    aliasName: 'assessment__id__report__assessment_id',
  );

  $ReportProcessedTableManager get reportRefs {
    final manager = $ReportTableManager(
      $_db,
      $_db.report,
    ).filter((f) => f.assessmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reportRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<ExportLog, List<ExportLogData>>
  _exportLogRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exportLog,
    aliasName: 'assessment__id__export_log__assessment_id',
  );

  $ExportLogProcessedTableManager get exportLogRefs {
    final manager = $ExportLogTableManager(
      $_db,
      $_db.exportLog,
    ).filter((f) => f.assessmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exportLogRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $AssessmentFilterComposer extends Composer<_$AppDatabase, Assessment> {
  $AssessmentFilterComposer({
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

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ar1Name => $composableBuilder(
    column: $table.ar1Name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ar2Name => $composableBuilder(
    column: $table.ar2Name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competition => $composableBuilder(
    column: $table.competition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kickoffLocal => $composableBuilder(
    column: $table.kickoffLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kickoffTz => $composableBuilder(
    column: $table.kickoffTz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get venue => $composableBuilder(
    column: $table.venue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeTeam => $composableBuilder(
    column: $table.homeTeam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awayTeam => $composableBuilder(
    column: $table.awayTeam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observationMode => $composableBuilder(
    column: $table.observationMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryCode => $composableBuilder(
    column: $table.categoryCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryJson => $composableBuilder(
    column: $table.categoryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionsJson => $composableBuilder(
    column: $table.conditionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finalScoreHome => $composableBuilder(
    column: $table.finalScoreHome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finalScoreAway => $composableBuilder(
    column: $table.finalScoreAway,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $RubricFilterComposer get rubricId {
    final $RubricFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rubricId,
      referencedTable: $db.rubric,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RubricFilterComposer(
            $db: $db,
            $table: $db.rubric,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AssessorProfileFilterComposer get assessorId {
    final $AssessorProfileFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessorId,
      referencedTable: $db.assessorProfile,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessorProfileFilterComposer(
            $db: $db,
            $table: $db.assessorProfile,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $OfficialFilterComposer get refereeId {
    final $OfficialFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refereeId,
      referencedTable: $db.official,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $OfficialFilterComposer(
            $db: $db,
            $table: $db.official,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> clockEventRefs(
    Expression<bool> Function($ClockEventFilterComposer f) f,
  ) {
    final $ClockEventFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clockEvent,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClockEventFilterComposer(
            $db: $db,
            $table: $db.clockEvent,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionTimeAnchorRefs(
    Expression<bool> Function($SessionTimeAnchorFilterComposer f) f,
  ) {
    final $SessionTimeAnchorFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionTimeAnchor,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionTimeAnchorFilterComposer(
            $db: $db,
            $table: $db.sessionTimeAnchor,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incidentRefs(
    Expression<bool> Function($IncidentFilterComposer f) f,
  ) {
    final $IncidentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incident,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentFilterComposer(
            $db: $db,
            $table: $db.incident,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reportRefs(
    Expression<bool> Function($ReportFilterComposer f) f,
  ) {
    final $ReportFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.report,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReportFilterComposer(
            $db: $db,
            $table: $db.report,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exportLogRefs(
    Expression<bool> Function($ExportLogFilterComposer f) f,
  ) {
    final $ExportLogFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportLog,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExportLogFilterComposer(
            $db: $db,
            $table: $db.exportLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $AssessmentOrderingComposer extends Composer<_$AppDatabase, Assessment> {
  $AssessmentOrderingComposer({
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

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ar1Name => $composableBuilder(
    column: $table.ar1Name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ar2Name => $composableBuilder(
    column: $table.ar2Name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competition => $composableBuilder(
    column: $table.competition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get round => $composableBuilder(
    column: $table.round,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kickoffLocal => $composableBuilder(
    column: $table.kickoffLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kickoffTz => $composableBuilder(
    column: $table.kickoffTz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get venue => $composableBuilder(
    column: $table.venue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeTeam => $composableBuilder(
    column: $table.homeTeam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awayTeam => $composableBuilder(
    column: $table.awayTeam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observationMode => $composableBuilder(
    column: $table.observationMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryCode => $composableBuilder(
    column: $table.categoryCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryJson => $composableBuilder(
    column: $table.categoryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionsJson => $composableBuilder(
    column: $table.conditionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalScoreHome => $composableBuilder(
    column: $table.finalScoreHome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalScoreAway => $composableBuilder(
    column: $table.finalScoreAway,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $RubricOrderingComposer get rubricId {
    final $RubricOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rubricId,
      referencedTable: $db.rubric,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RubricOrderingComposer(
            $db: $db,
            $table: $db.rubric,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AssessorProfileOrderingComposer get assessorId {
    final $AssessorProfileOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessorId,
      referencedTable: $db.assessorProfile,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessorProfileOrderingComposer(
            $db: $db,
            $table: $db.assessorProfile,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $OfficialOrderingComposer get refereeId {
    final $OfficialOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refereeId,
      referencedTable: $db.official,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $OfficialOrderingComposer(
            $db: $db,
            $table: $db.official,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AssessmentAnnotationComposer
    extends Composer<_$AppDatabase, Assessment> {
  $AssessmentAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get ar1Name =>
      $composableBuilder(column: $table.ar1Name, builder: (column) => column);

  GeneratedColumn<String> get ar2Name =>
      $composableBuilder(column: $table.ar2Name, builder: (column) => column);

  GeneratedColumn<String> get competition => $composableBuilder(
    column: $table.competition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<String> get kickoffLocal => $composableBuilder(
    column: $table.kickoffLocal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kickoffTz =>
      $composableBuilder(column: $table.kickoffTz, builder: (column) => column);

  GeneratedColumn<String> get venue =>
      $composableBuilder(column: $table.venue, builder: (column) => column);

  GeneratedColumn<String> get homeTeam =>
      $composableBuilder(column: $table.homeTeam, builder: (column) => column);

  GeneratedColumn<String> get awayTeam =>
      $composableBuilder(column: $table.awayTeam, builder: (column) => column);

  GeneratedColumn<String> get observationMode => $composableBuilder(
    column: $table.observationMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryCode => $composableBuilder(
    column: $table.categoryCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryJson => $composableBuilder(
    column: $table.categoryJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conditionsJson => $composableBuilder(
    column: $table.conditionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finalScoreHome => $composableBuilder(
    column: $table.finalScoreHome,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finalScoreAway => $composableBuilder(
    column: $table.finalScoreAway,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $RubricAnnotationComposer get rubricId {
    final $RubricAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rubricId,
      referencedTable: $db.rubric,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RubricAnnotationComposer(
            $db: $db,
            $table: $db.rubric,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AssessorProfileAnnotationComposer get assessorId {
    final $AssessorProfileAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessorId,
      referencedTable: $db.assessorProfile,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessorProfileAnnotationComposer(
            $db: $db,
            $table: $db.assessorProfile,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $OfficialAnnotationComposer get refereeId {
    final $OfficialAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refereeId,
      referencedTable: $db.official,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $OfficialAnnotationComposer(
            $db: $db,
            $table: $db.official,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> clockEventRefs<T extends Object>(
    Expression<T> Function($ClockEventAnnotationComposer a) f,
  ) {
    final $ClockEventAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clockEvent,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ClockEventAnnotationComposer(
            $db: $db,
            $table: $db.clockEvent,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionTimeAnchorRefs<T extends Object>(
    Expression<T> Function($SessionTimeAnchorAnnotationComposer a) f,
  ) {
    final $SessionTimeAnchorAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionTimeAnchor,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $SessionTimeAnchorAnnotationComposer(
            $db: $db,
            $table: $db.sessionTimeAnchor,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incidentRefs<T extends Object>(
    Expression<T> Function($IncidentAnnotationComposer a) f,
  ) {
    final $IncidentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incident,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentAnnotationComposer(
            $db: $db,
            $table: $db.incident,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reportRefs<T extends Object>(
    Expression<T> Function($ReportAnnotationComposer a) f,
  ) {
    final $ReportAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.report,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ReportAnnotationComposer(
            $db: $db,
            $table: $db.report,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exportLogRefs<T extends Object>(
    Expression<T> Function($ExportLogAnnotationComposer a) f,
  ) {
    final $ExportLogAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportLog,
      getReferencedColumn: (t) => t.assessmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ExportLogAnnotationComposer(
            $db: $db,
            $table: $db.exportLog,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $AssessmentTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Assessment,
          AssessmentData,
          $AssessmentFilterComposer,
          $AssessmentOrderingComposer,
          $AssessmentAnnotationComposer,
          $AssessmentCreateCompanionBuilder,
          $AssessmentUpdateCompanionBuilder,
          (AssessmentData, $AssessmentReferences),
          AssessmentData,
          PrefetchHooks Function({
            bool rubricId,
            bool assessorId,
            bool refereeId,
            bool clockEventRefs,
            bool sessionTimeAnchorRefs,
            bool incidentRefs,
            bool reportRefs,
            bool exportLogRefs,
          })
        > {
  $AssessmentTableManager(_$AppDatabase db, Assessment table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AssessmentFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AssessmentOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AssessmentAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> rubricId = const Value.absent(),
                Value<String> assessorId = const Value.absent(),
                Value<String> refereeId = const Value.absent(),
                Value<String?> ar1Name = const Value.absent(),
                Value<String?> ar2Name = const Value.absent(),
                Value<String> competition = const Value.absent(),
                Value<String?> round = const Value.absent(),
                Value<String> kickoffLocal = const Value.absent(),
                Value<String> kickoffTz = const Value.absent(),
                Value<String> venue = const Value.absent(),
                Value<String> homeTeam = const Value.absent(),
                Value<String> awayTeam = const Value.absent(),
                Value<String> observationMode = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<String> categoryCode = const Value.absent(),
                Value<String> categoryJson = const Value.absent(),
                Value<String?> conditionsJson = const Value.absent(),
                Value<int?> finalScoreHome = const Value.absent(),
                Value<int?> finalScoreAway = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssessmentCompanion(
                id: id,
                schemaVersion: schemaVersion,
                status: status,
                rubricId: rubricId,
                assessorId: assessorId,
                refereeId: refereeId,
                ar1Name: ar1Name,
                ar2Name: ar2Name,
                competition: competition,
                round: round,
                kickoffLocal: kickoffLocal,
                kickoffTz: kickoffTz,
                venue: venue,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                observationMode: observationMode,
                difficulty: difficulty,
                categoryCode: categoryCode,
                categoryJson: categoryJson,
                conditionsJson: conditionsJson,
                finalScoreHome: finalScoreHome,
                finalScoreAway: finalScoreAway,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> schemaVersion = const Value.absent(),
                required String status,
                required String rubricId,
                required String assessorId,
                required String refereeId,
                Value<String?> ar1Name = const Value.absent(),
                Value<String?> ar2Name = const Value.absent(),
                required String competition,
                Value<String?> round = const Value.absent(),
                required String kickoffLocal,
                required String kickoffTz,
                required String venue,
                required String homeTeam,
                required String awayTeam,
                required String observationMode,
                Value<String?> difficulty = const Value.absent(),
                required String categoryCode,
                required String categoryJson,
                Value<String?> conditionsJson = const Value.absent(),
                Value<int?> finalScoreHome = const Value.absent(),
                Value<int?> finalScoreAway = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AssessmentCompanion.insert(
                id: id,
                schemaVersion: schemaVersion,
                status: status,
                rubricId: rubricId,
                assessorId: assessorId,
                refereeId: refereeId,
                ar1Name: ar1Name,
                ar2Name: ar2Name,
                competition: competition,
                round: round,
                kickoffLocal: kickoffLocal,
                kickoffTz: kickoffTz,
                venue: venue,
                homeTeam: homeTeam,
                awayTeam: awayTeam,
                observationMode: observationMode,
                difficulty: difficulty,
                categoryCode: categoryCode,
                categoryJson: categoryJson,
                conditionsJson: conditionsJson,
                finalScoreHome: finalScoreHome,
                finalScoreAway: finalScoreAway,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Assessment, AssessmentData>(table),
                  $AssessmentReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                rubricId = false,
                assessorId = false,
                refereeId = false,
                clockEventRefs = false,
                sessionTimeAnchorRefs = false,
                incidentRefs = false,
                reportRefs = false,
                exportLogRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (clockEventRefs) db.clockEvent,
                    if (sessionTimeAnchorRefs) db.sessionTimeAnchor,
                    if (incidentRefs) db.incident,
                    if (reportRefs) db.report,
                    if (exportLogRefs) db.exportLog,
                  ],
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
                        if (rubricId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.rubricId,
                            referencedTable: $AssessmentReferences
                                ._rubricIdTable(db),
                            referencedColumn: $AssessmentReferences
                                ._rubricIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (assessorId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.assessorId,
                            referencedTable: $AssessmentReferences
                                ._assessorIdTable(db),
                            referencedColumn: $AssessmentReferences
                                ._assessorIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (refereeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.refereeId,
                            referencedTable: $AssessmentReferences
                                ._refereeIdTable(db),
                            referencedColumn: $AssessmentReferences
                                ._refereeIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (clockEventRefs)
                        await $_getPrefetchedData<
                          AssessmentData,
                          Assessment,
                          ClockEventData
                        >(
                          currentTable: table,
                          referencedTable: $AssessmentReferences
                              ._clockEventRefsTable(db),
                          managerFromTypedResult: (p0) => $AssessmentReferences(
                            db,
                            table,
                            p0,
                          ).clockEventRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assessmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionTimeAnchorRefs)
                        await $_getPrefetchedData<
                          AssessmentData,
                          Assessment,
                          SessionTimeAnchorData
                        >(
                          currentTable: table,
                          referencedTable: $AssessmentReferences
                              ._sessionTimeAnchorRefsTable(db),
                          managerFromTypedResult: (p0) => $AssessmentReferences(
                            db,
                            table,
                            p0,
                          ).sessionTimeAnchorRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assessmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (incidentRefs)
                        await $_getPrefetchedData<
                          AssessmentData,
                          Assessment,
                          IncidentData
                        >(
                          currentTable: table,
                          referencedTable: $AssessmentReferences
                              ._incidentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $AssessmentReferences(db, table, p0).incidentRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assessmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reportRefs)
                        await $_getPrefetchedData<
                          AssessmentData,
                          Assessment,
                          ReportData
                        >(
                          currentTable: table,
                          referencedTable: $AssessmentReferences
                              ._reportRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $AssessmentReferences(db, table, p0).reportRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assessmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exportLogRefs)
                        await $_getPrefetchedData<
                          AssessmentData,
                          Assessment,
                          ExportLogData
                        >(
                          currentTable: table,
                          referencedTable: $AssessmentReferences
                              ._exportLogRefsTable(db),
                          managerFromTypedResult: (p0) => $AssessmentReferences(
                            db,
                            table,
                            p0,
                          ).exportLogRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assessmentId == item.id,
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

typedef $AssessmentProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Assessment,
      AssessmentData,
      $AssessmentFilterComposer,
      $AssessmentOrderingComposer,
      $AssessmentAnnotationComposer,
      $AssessmentCreateCompanionBuilder,
      $AssessmentUpdateCompanionBuilder,
      (AssessmentData, $AssessmentReferences),
      AssessmentData,
      PrefetchHooks Function({
        bool rubricId,
        bool assessorId,
        bool refereeId,
        bool clockEventRefs,
        bool sessionTimeAnchorRefs,
        bool incidentRefs,
        bool reportRefs,
        bool exportLogRefs,
      })
    >;
typedef $ClockEventCreateCompanionBuilder = ClockEventCompanion Function({
  required String assessmentId,
  required int seq,
  required String type,
  required int tSessionMs,
  required String bootId,
  required int monoMs,
  required String wallUtc,
  Value<String> payloadJson,
  Value<int> rowid,
});
typedef $ClockEventUpdateCompanionBuilder = ClockEventCompanion Function({
  Value<String> assessmentId,
  Value<int> seq,
  Value<String> type,
  Value<int> tSessionMs,
  Value<String> bootId,
  Value<int> monoMs,
  Value<String> wallUtc,
  Value<String> payloadJson,
  Value<int> rowid,
});

final class $ClockEventReferences
    extends BaseReferences<_$AppDatabase, ClockEvent, ClockEventData> {
  $ClockEventReferences(super.$_db, super.$_table, super.$_typedResult);

  static Assessment _assessmentIdTable(_$AppDatabase db) =>
      db.assessment.createAlias('clock_event__assessment_id__assessment__id');

  $AssessmentProcessedTableManager get assessmentId {
    final $_column = $_itemColumn<String>('assessment_id')!;

    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assessmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ClockEventFilterComposer extends Composer<_$AppDatabase, ClockEvent> {
  $ClockEventFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tSessionMs => $composableBuilder(
    column: $table.tSessionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bootId => $composableBuilder(
    column: $table.bootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monoMs => $composableBuilder(
    column: $table.monoMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wallUtc => $composableBuilder(
    column: $table.wallUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  $AssessmentFilterComposer get assessmentId {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ClockEventOrderingComposer extends Composer<_$AppDatabase, ClockEvent> {
  $ClockEventOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tSessionMs => $composableBuilder(
    column: $table.tSessionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bootId => $composableBuilder(
    column: $table.bootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monoMs => $composableBuilder(
    column: $table.monoMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wallUtc => $composableBuilder(
    column: $table.wallUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  $AssessmentOrderingComposer get assessmentId {
    final $AssessmentOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentOrderingComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ClockEventAnnotationComposer
    extends Composer<_$AppDatabase, ClockEvent> {
  $ClockEventAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get tSessionMs => $composableBuilder(
    column: $table.tSessionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bootId =>
      $composableBuilder(column: $table.bootId, builder: (column) => column);

  GeneratedColumn<int> get monoMs =>
      $composableBuilder(column: $table.monoMs, builder: (column) => column);

  GeneratedColumn<String> get wallUtc =>
      $composableBuilder(column: $table.wallUtc, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  $AssessmentAnnotationComposer get assessmentId {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ClockEventTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ClockEvent,
          ClockEventData,
          $ClockEventFilterComposer,
          $ClockEventOrderingComposer,
          $ClockEventAnnotationComposer,
          $ClockEventCreateCompanionBuilder,
          $ClockEventUpdateCompanionBuilder,
          (ClockEventData, $ClockEventReferences),
          ClockEventData,
          PrefetchHooks Function({bool assessmentId})
        > {
  $ClockEventTableManager(_$AppDatabase db, ClockEvent table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ClockEventFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ClockEventOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ClockEventAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> assessmentId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> tSessionMs = const Value.absent(),
                Value<String> bootId = const Value.absent(),
                Value<int> monoMs = const Value.absent(),
                Value<String> wallUtc = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClockEventCompanion(
                assessmentId: assessmentId,
                seq: seq,
                type: type,
                tSessionMs: tSessionMs,
                bootId: bootId,
                monoMs: monoMs,
                wallUtc: wallUtc,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assessmentId,
                required int seq,
                required String type,
                required int tSessionMs,
                required String bootId,
                required int monoMs,
                required String wallUtc,
                Value<String> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClockEventCompanion.insert(
                assessmentId: assessmentId,
                seq: seq,
                type: type,
                tSessionMs: tSessionMs,
                bootId: bootId,
                monoMs: monoMs,
                wallUtc: wallUtc,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ClockEvent, ClockEventData>(table),
                  $ClockEventReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assessmentId = false}) {
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
                    if (assessmentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assessmentId,
                        referencedTable: $ClockEventReferences
                            ._assessmentIdTable(db),
                        referencedColumn: $ClockEventReferences
                            ._assessmentIdTable(db)
                            .id,
                      ) as T;
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

typedef $ClockEventProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ClockEvent,
      ClockEventData,
      $ClockEventFilterComposer,
      $ClockEventOrderingComposer,
      $ClockEventAnnotationComposer,
      $ClockEventCreateCompanionBuilder,
      $ClockEventUpdateCompanionBuilder,
      (ClockEventData, $ClockEventReferences),
      ClockEventData,
      PrefetchHooks Function({bool assessmentId})
    >;
typedef $SessionTimeAnchorCreateCompanionBuilder =
    SessionTimeAnchorCompanion Function({
      required String assessmentId,
      required String bootId,
      required int monoAtAnchor,
      required int sessionAtAnchor,
      required String wallUtcAtAnchor,
      required int estimated,
      Value<int> rowid,
    });
typedef $SessionTimeAnchorUpdateCompanionBuilder =
    SessionTimeAnchorCompanion Function({
      Value<String> assessmentId,
      Value<String> bootId,
      Value<int> monoAtAnchor,
      Value<int> sessionAtAnchor,
      Value<String> wallUtcAtAnchor,
      Value<int> estimated,
      Value<int> rowid,
    });

final class $SessionTimeAnchorReferences
    extends
        BaseReferences<
          _$AppDatabase,
          SessionTimeAnchor,
          SessionTimeAnchorData
        > {
  $SessionTimeAnchorReferences(super.$_db, super.$_table, super.$_typedResult);

  static Assessment _assessmentIdTable(_$AppDatabase db) => db.assessment
      .createAlias('session_time_anchor__assessment_id__assessment__id');

  $AssessmentProcessedTableManager get assessmentId {
    final $_column = $_itemColumn<String>('assessment_id')!;

    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assessmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $SessionTimeAnchorFilterComposer
    extends Composer<_$AppDatabase, SessionTimeAnchor> {
  $SessionTimeAnchorFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bootId => $composableBuilder(
    column: $table.bootId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monoAtAnchor => $composableBuilder(
    column: $table.monoAtAnchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionAtAnchor => $composableBuilder(
    column: $table.sessionAtAnchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wallUtcAtAnchor => $composableBuilder(
    column: $table.wallUtcAtAnchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimated => $composableBuilder(
    column: $table.estimated,
    builder: (column) => ColumnFilters(column),
  );

  $AssessmentFilterComposer get assessmentId {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SessionTimeAnchorOrderingComposer
    extends Composer<_$AppDatabase, SessionTimeAnchor> {
  $SessionTimeAnchorOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bootId => $composableBuilder(
    column: $table.bootId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monoAtAnchor => $composableBuilder(
    column: $table.monoAtAnchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionAtAnchor => $composableBuilder(
    column: $table.sessionAtAnchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wallUtcAtAnchor => $composableBuilder(
    column: $table.wallUtcAtAnchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimated => $composableBuilder(
    column: $table.estimated,
    builder: (column) => ColumnOrderings(column),
  );

  $AssessmentOrderingComposer get assessmentId {
    final $AssessmentOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentOrderingComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SessionTimeAnchorAnnotationComposer
    extends Composer<_$AppDatabase, SessionTimeAnchor> {
  $SessionTimeAnchorAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bootId =>
      $composableBuilder(column: $table.bootId, builder: (column) => column);

  GeneratedColumn<int> get monoAtAnchor => $composableBuilder(
    column: $table.monoAtAnchor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionAtAnchor => $composableBuilder(
    column: $table.sessionAtAnchor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wallUtcAtAnchor => $composableBuilder(
    column: $table.wallUtcAtAnchor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimated =>
      $composableBuilder(column: $table.estimated, builder: (column) => column);

  $AssessmentAnnotationComposer get assessmentId {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SessionTimeAnchorTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SessionTimeAnchor,
          SessionTimeAnchorData,
          $SessionTimeAnchorFilterComposer,
          $SessionTimeAnchorOrderingComposer,
          $SessionTimeAnchorAnnotationComposer,
          $SessionTimeAnchorCreateCompanionBuilder,
          $SessionTimeAnchorUpdateCompanionBuilder,
          (SessionTimeAnchorData, $SessionTimeAnchorReferences),
          SessionTimeAnchorData,
          PrefetchHooks Function({bool assessmentId})
        > {
  $SessionTimeAnchorTableManager(_$AppDatabase db, SessionTimeAnchor table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SessionTimeAnchorFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SessionTimeAnchorOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SessionTimeAnchorAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> assessmentId = const Value.absent(),
                Value<String> bootId = const Value.absent(),
                Value<int> monoAtAnchor = const Value.absent(),
                Value<int> sessionAtAnchor = const Value.absent(),
                Value<String> wallUtcAtAnchor = const Value.absent(),
                Value<int> estimated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionTimeAnchorCompanion(
                assessmentId: assessmentId,
                bootId: bootId,
                monoAtAnchor: monoAtAnchor,
                sessionAtAnchor: sessionAtAnchor,
                wallUtcAtAnchor: wallUtcAtAnchor,
                estimated: estimated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assessmentId,
                required String bootId,
                required int monoAtAnchor,
                required int sessionAtAnchor,
                required String wallUtcAtAnchor,
                required int estimated,
                Value<int> rowid = const Value.absent(),
              }) => SessionTimeAnchorCompanion.insert(
                assessmentId: assessmentId,
                bootId: bootId,
                monoAtAnchor: monoAtAnchor,
                sessionAtAnchor: sessionAtAnchor,
                wallUtcAtAnchor: wallUtcAtAnchor,
                estimated: estimated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SessionTimeAnchor, SessionTimeAnchorData>(table),
                  $SessionTimeAnchorReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assessmentId = false}) {
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
                    if (assessmentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assessmentId,
                        referencedTable: $SessionTimeAnchorReferences
                            ._assessmentIdTable(db),
                        referencedColumn: $SessionTimeAnchorReferences
                            ._assessmentIdTable(db)
                            .id,
                      ) as T;
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

typedef $SessionTimeAnchorProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SessionTimeAnchor,
      SessionTimeAnchorData,
      $SessionTimeAnchorFilterComposer,
      $SessionTimeAnchorOrderingComposer,
      $SessionTimeAnchorAnnotationComposer,
      $SessionTimeAnchorCreateCompanionBuilder,
      $SessionTimeAnchorUpdateCompanionBuilder,
      (SessionTimeAnchorData, $SessionTimeAnchorReferences),
      SessionTimeAnchorData,
      PrefetchHooks Function({bool assessmentId})
    >;
typedef $IncidentCreateCompanionBuilder = IncidentCompanion Function({
  required String id,
  required String assessmentId,
  required int seq,
  required int tSessionMs,
  required String wallUtc,
  Value<String?> period,
  required String phaseLabel,
  required int periodElapsedMs,
  required int matchClockMs,
  Value<int> overtimeMs,
  required String timeIntegrity,
  Value<int> timeManualOverride,
  required String category,
  required String criterionCode,
  required String polarity,
  Value<String?> gamePhase,
  Value<String?> fieldZone,
  Value<String?> decisionTakenJson,
  Value<String?> decisionExpectedJson,
  required String verdict,
  required String impact,
  required int impactConfirmed,
  Value<String?> notes,
  required String source,
  required String status,
  Value<String?> voidReason,
  required String updatedAt,
  Value<int> rowid,
});
typedef $IncidentUpdateCompanionBuilder = IncidentCompanion Function({
  Value<String> id,
  Value<String> assessmentId,
  Value<int> seq,
  Value<int> tSessionMs,
  Value<String> wallUtc,
  Value<String?> period,
  Value<String> phaseLabel,
  Value<int> periodElapsedMs,
  Value<int> matchClockMs,
  Value<int> overtimeMs,
  Value<String> timeIntegrity,
  Value<int> timeManualOverride,
  Value<String> category,
  Value<String> criterionCode,
  Value<String> polarity,
  Value<String?> gamePhase,
  Value<String?> fieldZone,
  Value<String?> decisionTakenJson,
  Value<String?> decisionExpectedJson,
  Value<String> verdict,
  Value<String> impact,
  Value<int> impactConfirmed,
  Value<String?> notes,
  Value<String> source,
  Value<String> status,
  Value<String?> voidReason,
  Value<String> updatedAt,
  Value<int> rowid,
});

final class $IncidentReferences
    extends BaseReferences<_$AppDatabase, Incident, IncidentData> {
  $IncidentReferences(super.$_db, super.$_table, super.$_typedResult);

  static Assessment _assessmentIdTable(_$AppDatabase db) =>
      db.assessment.createAlias('incident__assessment_id__assessment__id');

  $AssessmentProcessedTableManager get assessmentId {
    final $_column = $_itemColumn<String>('assessment_id')!;

    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assessmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<IncidentRevision, List<IncidentRevisionData>>
  _incidentRevisionRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.incidentRevision,
    aliasName: 'incident__id__incident_revision__incident_id',
  );

  $IncidentRevisionProcessedTableManager get incidentRevisionRefs {
    final manager = $IncidentRevisionTableManager(
      $_db,
      $_db.incidentRevision,
    ).filter((f) => f.incidentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _incidentRevisionRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Attachment, List<AttachmentData>>
  _attachmentRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attachment,
    aliasName: 'incident__id__attachment__incident_id',
  );

  $AttachmentProcessedTableManager get attachmentRefs {
    final manager = $AttachmentTableManager(
      $_db,
      $_db.attachment,
    ).filter((f) => f.incidentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $IncidentFilterComposer extends Composer<_$AppDatabase, Incident> {
  $IncidentFilterComposer({
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

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tSessionMs => $composableBuilder(
    column: $table.tSessionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wallUtc => $composableBuilder(
    column: $table.wallUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phaseLabel => $composableBuilder(
    column: $table.phaseLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodElapsedMs => $composableBuilder(
    column: $table.periodElapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get matchClockMs => $composableBuilder(
    column: $table.matchClockMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overtimeMs => $composableBuilder(
    column: $table.overtimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeIntegrity => $composableBuilder(
    column: $table.timeIntegrity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeManualOverride => $composableBuilder(
    column: $table.timeManualOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polarity => $composableBuilder(
    column: $table.polarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gamePhase => $composableBuilder(
    column: $table.gamePhase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldZone => $composableBuilder(
    column: $table.fieldZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionTakenJson => $composableBuilder(
    column: $table.decisionTakenJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionExpectedJson => $composableBuilder(
    column: $table.decisionExpectedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get impactConfirmed => $composableBuilder(
    column: $table.impactConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $AssessmentFilterComposer get assessmentId {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> incidentRevisionRefs(
    Expression<bool> Function($IncidentRevisionFilterComposer f) f,
  ) {
    final $IncidentRevisionFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incidentRevision,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentRevisionFilterComposer(
            $db: $db,
            $table: $db.incidentRevision,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentRefs(
    Expression<bool> Function($AttachmentFilterComposer f) f,
  ) {
    final $AttachmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachment,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttachmentFilterComposer(
            $db: $db,
            $table: $db.attachment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $IncidentOrderingComposer extends Composer<_$AppDatabase, Incident> {
  $IncidentOrderingComposer({
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

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tSessionMs => $composableBuilder(
    column: $table.tSessionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wallUtc => $composableBuilder(
    column: $table.wallUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phaseLabel => $composableBuilder(
    column: $table.phaseLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodElapsedMs => $composableBuilder(
    column: $table.periodElapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matchClockMs => $composableBuilder(
    column: $table.matchClockMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overtimeMs => $composableBuilder(
    column: $table.overtimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeIntegrity => $composableBuilder(
    column: $table.timeIntegrity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeManualOverride => $composableBuilder(
    column: $table.timeManualOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polarity => $composableBuilder(
    column: $table.polarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gamePhase => $composableBuilder(
    column: $table.gamePhase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldZone => $composableBuilder(
    column: $table.fieldZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionTakenJson => $composableBuilder(
    column: $table.decisionTakenJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionExpectedJson => $composableBuilder(
    column: $table.decisionExpectedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get impact => $composableBuilder(
    column: $table.impact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get impactConfirmed => $composableBuilder(
    column: $table.impactConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $AssessmentOrderingComposer get assessmentId {
    final $AssessmentOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentOrderingComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $IncidentAnnotationComposer extends Composer<_$AppDatabase, Incident> {
  $IncidentAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<int> get tSessionMs => $composableBuilder(
    column: $table.tSessionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wallUtc =>
      $composableBuilder(column: $table.wallUtc, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get phaseLabel => $composableBuilder(
    column: $table.phaseLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodElapsedMs => $composableBuilder(
    column: $table.periodElapsedMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get matchClockMs => $composableBuilder(
    column: $table.matchClockMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get overtimeMs => $composableBuilder(
    column: $table.overtimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeIntegrity => $composableBuilder(
    column: $table.timeIntegrity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeManualOverride => $composableBuilder(
    column: $table.timeManualOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get polarity =>
      $composableBuilder(column: $table.polarity, builder: (column) => column);

  GeneratedColumn<String> get gamePhase =>
      $composableBuilder(column: $table.gamePhase, builder: (column) => column);

  GeneratedColumn<String> get fieldZone =>
      $composableBuilder(column: $table.fieldZone, builder: (column) => column);

  GeneratedColumn<String> get decisionTakenJson => $composableBuilder(
    column: $table.decisionTakenJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decisionExpectedJson => $composableBuilder(
    column: $table.decisionExpectedJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<String> get impact =>
      $composableBuilder(column: $table.impact, builder: (column) => column);

  GeneratedColumn<int> get impactConfirmed => $composableBuilder(
    column: $table.impactConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $AssessmentAnnotationComposer get assessmentId {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> incidentRevisionRefs<T extends Object>(
    Expression<T> Function($IncidentRevisionAnnotationComposer a) f,
  ) {
    final $IncidentRevisionAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incidentRevision,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentRevisionAnnotationComposer(
            $db: $db,
            $table: $db.incidentRevision,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attachmentRefs<T extends Object>(
    Expression<T> Function($AttachmentAnnotationComposer a) f,
  ) {
    final $AttachmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachment,
      getReferencedColumn: (t) => t.incidentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AttachmentAnnotationComposer(
            $db: $db,
            $table: $db.attachment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $IncidentTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Incident,
          IncidentData,
          $IncidentFilterComposer,
          $IncidentOrderingComposer,
          $IncidentAnnotationComposer,
          $IncidentCreateCompanionBuilder,
          $IncidentUpdateCompanionBuilder,
          (IncidentData, $IncidentReferences),
          IncidentData,
          PrefetchHooks Function({
            bool assessmentId,
            bool incidentRevisionRefs,
            bool attachmentRefs,
          })
        > {
  $IncidentTableManager(_$AppDatabase db, Incident table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $IncidentFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $IncidentOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $IncidentAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assessmentId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<int> tSessionMs = const Value.absent(),
                Value<String> wallUtc = const Value.absent(),
                Value<String?> period = const Value.absent(),
                Value<String> phaseLabel = const Value.absent(),
                Value<int> periodElapsedMs = const Value.absent(),
                Value<int> matchClockMs = const Value.absent(),
                Value<int> overtimeMs = const Value.absent(),
                Value<String> timeIntegrity = const Value.absent(),
                Value<int> timeManualOverride = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> criterionCode = const Value.absent(),
                Value<String> polarity = const Value.absent(),
                Value<String?> gamePhase = const Value.absent(),
                Value<String?> fieldZone = const Value.absent(),
                Value<String?> decisionTakenJson = const Value.absent(),
                Value<String?> decisionExpectedJson = const Value.absent(),
                Value<String> verdict = const Value.absent(),
                Value<String> impact = const Value.absent(),
                Value<int> impactConfirmed = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncidentCompanion(
                id: id,
                assessmentId: assessmentId,
                seq: seq,
                tSessionMs: tSessionMs,
                wallUtc: wallUtc,
                period: period,
                phaseLabel: phaseLabel,
                periodElapsedMs: periodElapsedMs,
                matchClockMs: matchClockMs,
                overtimeMs: overtimeMs,
                timeIntegrity: timeIntegrity,
                timeManualOverride: timeManualOverride,
                category: category,
                criterionCode: criterionCode,
                polarity: polarity,
                gamePhase: gamePhase,
                fieldZone: fieldZone,
                decisionTakenJson: decisionTakenJson,
                decisionExpectedJson: decisionExpectedJson,
                verdict: verdict,
                impact: impact,
                impactConfirmed: impactConfirmed,
                notes: notes,
                source: source,
                status: status,
                voidReason: voidReason,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assessmentId,
                required int seq,
                required int tSessionMs,
                required String wallUtc,
                Value<String?> period = const Value.absent(),
                required String phaseLabel,
                required int periodElapsedMs,
                required int matchClockMs,
                Value<int> overtimeMs = const Value.absent(),
                required String timeIntegrity,
                Value<int> timeManualOverride = const Value.absent(),
                required String category,
                required String criterionCode,
                required String polarity,
                Value<String?> gamePhase = const Value.absent(),
                Value<String?> fieldZone = const Value.absent(),
                Value<String?> decisionTakenJson = const Value.absent(),
                Value<String?> decisionExpectedJson = const Value.absent(),
                required String verdict,
                required String impact,
                required int impactConfirmed,
                Value<String?> notes = const Value.absent(),
                required String source,
                required String status,
                Value<String?> voidReason = const Value.absent(),
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => IncidentCompanion.insert(
                id: id,
                assessmentId: assessmentId,
                seq: seq,
                tSessionMs: tSessionMs,
                wallUtc: wallUtc,
                period: period,
                phaseLabel: phaseLabel,
                periodElapsedMs: periodElapsedMs,
                matchClockMs: matchClockMs,
                overtimeMs: overtimeMs,
                timeIntegrity: timeIntegrity,
                timeManualOverride: timeManualOverride,
                category: category,
                criterionCode: criterionCode,
                polarity: polarity,
                gamePhase: gamePhase,
                fieldZone: fieldZone,
                decisionTakenJson: decisionTakenJson,
                decisionExpectedJson: decisionExpectedJson,
                verdict: verdict,
                impact: impact,
                impactConfirmed: impactConfirmed,
                notes: notes,
                source: source,
                status: status,
                voidReason: voidReason,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Incident, IncidentData>(table),
                  $IncidentReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                assessmentId = false,
                incidentRevisionRefs = false,
                attachmentRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (incidentRevisionRefs) db.incidentRevision,
                    if (attachmentRefs) db.attachment,
                  ],
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
                        if (assessmentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.assessmentId,
                            referencedTable: $IncidentReferences
                                ._assessmentIdTable(db),
                            referencedColumn: $IncidentReferences
                                ._assessmentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (incidentRevisionRefs)
                        await $_getPrefetchedData<
                          IncidentData,
                          Incident,
                          IncidentRevisionData
                        >(
                          currentTable: table,
                          referencedTable: $IncidentReferences
                              ._incidentRevisionRefsTable(db),
                          managerFromTypedResult: (p0) => $IncidentReferences(
                            db,
                            table,
                            p0,
                          ).incidentRevisionRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.incidentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attachmentRefs)
                        await $_getPrefetchedData<
                          IncidentData,
                          Incident,
                          AttachmentData
                        >(
                          currentTable: table,
                          referencedTable: $IncidentReferences
                              ._attachmentRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $IncidentReferences(db, table, p0).attachmentRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.incidentId == item.id,
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

typedef $IncidentProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Incident,
      IncidentData,
      $IncidentFilterComposer,
      $IncidentOrderingComposer,
      $IncidentAnnotationComposer,
      $IncidentCreateCompanionBuilder,
      $IncidentUpdateCompanionBuilder,
      (IncidentData, $IncidentReferences),
      IncidentData,
      PrefetchHooks Function({
        bool assessmentId,
        bool incidentRevisionRefs,
        bool attachmentRefs,
      })
    >;
typedef $IncidentRevisionCreateCompanionBuilder =
    IncidentRevisionCompanion Function({
      required String incidentId,
      required String revisedAt,
      required String previousJson,
      Value<int> rowid,
    });
typedef $IncidentRevisionUpdateCompanionBuilder =
    IncidentRevisionCompanion Function({
      Value<String> incidentId,
      Value<String> revisedAt,
      Value<String> previousJson,
      Value<int> rowid,
    });

final class $IncidentRevisionReferences
    extends
        BaseReferences<_$AppDatabase, IncidentRevision, IncidentRevisionData> {
  $IncidentRevisionReferences(super.$_db, super.$_table, super.$_typedResult);

  static Incident _incidentIdTable(_$AppDatabase db) =>
      db.incident.createAlias('incident_revision__incident_id__incident__id');

  $IncidentProcessedTableManager get incidentId {
    final $_column = $_itemColumn<String>('incident_id')!;

    final manager = $IncidentTableManager(
      $_db,
      $_db.incident,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_incidentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $IncidentRevisionFilterComposer
    extends Composer<_$AppDatabase, IncidentRevision> {
  $IncidentRevisionFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get revisedAt => $composableBuilder(
    column: $table.revisedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousJson => $composableBuilder(
    column: $table.previousJson,
    builder: (column) => ColumnFilters(column),
  );

  $IncidentFilterComposer get incidentId {
    final $IncidentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incident,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentFilterComposer(
            $db: $db,
            $table: $db.incident,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $IncidentRevisionOrderingComposer
    extends Composer<_$AppDatabase, IncidentRevision> {
  $IncidentRevisionOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get revisedAt => $composableBuilder(
    column: $table.revisedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousJson => $composableBuilder(
    column: $table.previousJson,
    builder: (column) => ColumnOrderings(column),
  );

  $IncidentOrderingComposer get incidentId {
    final $IncidentOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incident,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentOrderingComposer(
            $db: $db,
            $table: $db.incident,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $IncidentRevisionAnnotationComposer
    extends Composer<_$AppDatabase, IncidentRevision> {
  $IncidentRevisionAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get revisedAt =>
      $composableBuilder(column: $table.revisedAt, builder: (column) => column);

  GeneratedColumn<String> get previousJson => $composableBuilder(
    column: $table.previousJson,
    builder: (column) => column,
  );

  $IncidentAnnotationComposer get incidentId {
    final $IncidentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incident,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentAnnotationComposer(
            $db: $db,
            $table: $db.incident,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $IncidentRevisionTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          IncidentRevision,
          IncidentRevisionData,
          $IncidentRevisionFilterComposer,
          $IncidentRevisionOrderingComposer,
          $IncidentRevisionAnnotationComposer,
          $IncidentRevisionCreateCompanionBuilder,
          $IncidentRevisionUpdateCompanionBuilder,
          (IncidentRevisionData, $IncidentRevisionReferences),
          IncidentRevisionData,
          PrefetchHooks Function({bool incidentId})
        > {
  $IncidentRevisionTableManager(_$AppDatabase db, IncidentRevision table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $IncidentRevisionFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $IncidentRevisionOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $IncidentRevisionAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> incidentId = const Value.absent(),
                Value<String> revisedAt = const Value.absent(),
                Value<String> previousJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncidentRevisionCompanion(
                incidentId: incidentId,
                revisedAt: revisedAt,
                previousJson: previousJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String incidentId,
                required String revisedAt,
                required String previousJson,
                Value<int> rowid = const Value.absent(),
              }) => IncidentRevisionCompanion.insert(
                incidentId: incidentId,
                revisedAt: revisedAt,
                previousJson: previousJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<IncidentRevision, IncidentRevisionData>(table),
                  $IncidentRevisionReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({incidentId = false}) {
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
                    if (incidentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.incidentId,
                        referencedTable: $IncidentRevisionReferences
                            ._incidentIdTable(db),
                        referencedColumn: $IncidentRevisionReferences
                            ._incidentIdTable(db)
                            .id,
                      ) as T;
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

typedef $IncidentRevisionProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      IncidentRevision,
      IncidentRevisionData,
      $IncidentRevisionFilterComposer,
      $IncidentRevisionOrderingComposer,
      $IncidentRevisionAnnotationComposer,
      $IncidentRevisionCreateCompanionBuilder,
      $IncidentRevisionUpdateCompanionBuilder,
      (IncidentRevisionData, $IncidentRevisionReferences),
      IncidentRevisionData,
      PrefetchHooks Function({bool incidentId})
    >;
typedef $AttachmentCreateCompanionBuilder = AttachmentCompanion Function({
  required String id,
  required String incidentId,
  required String kind,
  Value<String?> relativePath,
  Value<String?> url,
  Value<int?> videoPositionMs,
  Value<int?> durationMs,
  Value<String?> sha256,
  required String status,
  Value<String?> transcript,
  required String createdAt,
  Value<int> rowid,
});
typedef $AttachmentUpdateCompanionBuilder = AttachmentCompanion Function({
  Value<String> id,
  Value<String> incidentId,
  Value<String> kind,
  Value<String?> relativePath,
  Value<String?> url,
  Value<int?> videoPositionMs,
  Value<int?> durationMs,
  Value<String?> sha256,
  Value<String> status,
  Value<String?> transcript,
  Value<String> createdAt,
  Value<int> rowid,
});

final class $AttachmentReferences
    extends BaseReferences<_$AppDatabase, Attachment, AttachmentData> {
  $AttachmentReferences(super.$_db, super.$_table, super.$_typedResult);

  static Incident _incidentIdTable(_$AppDatabase db) =>
      db.incident.createAlias('attachment__incident_id__incident__id');

  $IncidentProcessedTableManager get incidentId {
    final $_column = $_itemColumn<String>('incident_id')!;

    final manager = $IncidentTableManager(
      $_db,
      $_db.incident,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_incidentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $AttachmentFilterComposer extends Composer<_$AppDatabase, Attachment> {
  $AttachmentFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get videoPositionMs => $composableBuilder(
    column: $table.videoPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $IncidentFilterComposer get incidentId {
    final $IncidentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incident,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentFilterComposer(
            $db: $db,
            $table: $db.incident,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttachmentOrderingComposer extends Composer<_$AppDatabase, Attachment> {
  $AttachmentOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get videoPositionMs => $composableBuilder(
    column: $table.videoPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $IncidentOrderingComposer get incidentId {
    final $IncidentOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incident,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentOrderingComposer(
            $db: $db,
            $table: $db.incident,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttachmentAnnotationComposer
    extends Composer<_$AppDatabase, Attachment> {
  $AttachmentAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get videoPositionMs => $composableBuilder(
    column: $table.videoPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $IncidentAnnotationComposer get incidentId {
    final $IncidentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incidentId,
      referencedTable: $db.incident,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $IncidentAnnotationComposer(
            $db: $db,
            $table: $db.incident,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $AttachmentTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Attachment,
          AttachmentData,
          $AttachmentFilterComposer,
          $AttachmentOrderingComposer,
          $AttachmentAnnotationComposer,
          $AttachmentCreateCompanionBuilder,
          $AttachmentUpdateCompanionBuilder,
          (AttachmentData, $AttachmentReferences),
          AttachmentData,
          PrefetchHooks Function({bool incidentId})
        > {
  $AttachmentTableManager(_$AppDatabase db, Attachment table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AttachmentFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AttachmentOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AttachmentAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> incidentId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> relativePath = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> videoPositionMs = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentCompanion(
                id: id,
                incidentId: incidentId,
                kind: kind,
                relativePath: relativePath,
                url: url,
                videoPositionMs: videoPositionMs,
                durationMs: durationMs,
                sha256: sha256,
                status: status,
                transcript: transcript,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String incidentId,
                required String kind,
                Value<String?> relativePath = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int?> videoPositionMs = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> sha256 = const Value.absent(),
                required String status,
                Value<String?> transcript = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentCompanion.insert(
                id: id,
                incidentId: incidentId,
                kind: kind,
                relativePath: relativePath,
                url: url,
                videoPositionMs: videoPositionMs,
                durationMs: durationMs,
                sha256: sha256,
                status: status,
                transcript: transcript,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Attachment, AttachmentData>(table),
                  $AttachmentReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({incidentId = false}) {
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
                    if (incidentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.incidentId,
                        referencedTable: $AttachmentReferences._incidentIdTable(
                          db,
                        ),
                        referencedColumn: $AttachmentReferences
                            ._incidentIdTable(db)
                            .id,
                      ) as T;
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

typedef $AttachmentProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Attachment,
      AttachmentData,
      $AttachmentFilterComposer,
      $AttachmentOrderingComposer,
      $AttachmentAnnotationComposer,
      $AttachmentCreateCompanionBuilder,
      $AttachmentUpdateCompanionBuilder,
      (AttachmentData, $AttachmentReferences),
      AttachmentData,
      PrefetchHooks Function({bool incidentId})
    >;
typedef $ReportCreateCompanionBuilder = ReportCompanion Function({
  required String assessmentId,
  required int version,
  required String refereeId,
  required String rubricId,
  required String status,
  Value<String> summary,
  Value<String?> band,
  Value<double?> overallScore,
  Value<int> keyCorrect,
  Value<int> keyTotal,
  Value<String?> amendmentReason,
  Value<String?> finalizedAt,
  Value<String?> canonicalJson,
  Value<String?> contentHash,
  Value<int> rowid,
});
typedef $ReportUpdateCompanionBuilder = ReportCompanion Function({
  Value<String> assessmentId,
  Value<int> version,
  Value<String> refereeId,
  Value<String> rubricId,
  Value<String> status,
  Value<String> summary,
  Value<String?> band,
  Value<double?> overallScore,
  Value<int> keyCorrect,
  Value<int> keyTotal,
  Value<String?> amendmentReason,
  Value<String?> finalizedAt,
  Value<String?> canonicalJson,
  Value<String?> contentHash,
  Value<int> rowid,
});

final class $ReportReferences
    extends BaseReferences<_$AppDatabase, Report, ReportData> {
  $ReportReferences(super.$_db, super.$_table, super.$_typedResult);

  static Assessment _assessmentIdTable(_$AppDatabase db) =>
      db.assessment.createAlias('report__assessment_id__assessment__id');

  $AssessmentProcessedTableManager get assessmentId {
    final $_column = $_itemColumn<String>('assessment_id')!;

    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assessmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Official _refereeIdTable(_$AppDatabase db) =>
      db.official.createAlias('report__referee_id__official__id');

  $OfficialProcessedTableManager get refereeId {
    final $_column = $_itemColumn<String>('referee_id')!;

    final manager = $OfficialTableManager(
      $_db,
      $_db.official,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_refereeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Rubric _rubricIdTable(_$AppDatabase db) =>
      db.rubric.createAlias('report__rubric_id__rubric__id');

  $RubricProcessedTableManager get rubricId {
    final $_column = $_itemColumn<String>('rubric_id')!;

    final manager = $RubricTableManager(
      $_db,
      $_db.rubric,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rubricIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ReportFilterComposer extends Composer<_$AppDatabase, Report> {
  $ReportFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get band => $composableBuilder(
    column: $table.band,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyCorrect => $composableBuilder(
    column: $table.keyCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyTotal => $composableBuilder(
    column: $table.keyTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amendmentReason => $composableBuilder(
    column: $table.amendmentReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalJson => $composableBuilder(
    column: $table.canonicalJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  $AssessmentFilterComposer get assessmentId {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $OfficialFilterComposer get refereeId {
    final $OfficialFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refereeId,
      referencedTable: $db.official,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $OfficialFilterComposer(
            $db: $db,
            $table: $db.official,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $RubricFilterComposer get rubricId {
    final $RubricFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rubricId,
      referencedTable: $db.rubric,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RubricFilterComposer(
            $db: $db,
            $table: $db.rubric,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ReportOrderingComposer extends Composer<_$AppDatabase, Report> {
  $ReportOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get band => $composableBuilder(
    column: $table.band,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyCorrect => $composableBuilder(
    column: $table.keyCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyTotal => $composableBuilder(
    column: $table.keyTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amendmentReason => $composableBuilder(
    column: $table.amendmentReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalJson => $composableBuilder(
    column: $table.canonicalJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  $AssessmentOrderingComposer get assessmentId {
    final $AssessmentOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentOrderingComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $OfficialOrderingComposer get refereeId {
    final $OfficialOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refereeId,
      referencedTable: $db.official,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $OfficialOrderingComposer(
            $db: $db,
            $table: $db.official,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $RubricOrderingComposer get rubricId {
    final $RubricOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rubricId,
      referencedTable: $db.rubric,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RubricOrderingComposer(
            $db: $db,
            $table: $db.rubric,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ReportAnnotationComposer extends Composer<_$AppDatabase, Report> {
  $ReportAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get band =>
      $composableBuilder(column: $table.band, builder: (column) => column);

  GeneratedColumn<double> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get keyCorrect => $composableBuilder(
    column: $table.keyCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get keyTotal =>
      $composableBuilder(column: $table.keyTotal, builder: (column) => column);

  GeneratedColumn<String> get amendmentReason => $composableBuilder(
    column: $table.amendmentReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finalizedAt => $composableBuilder(
    column: $table.finalizedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get canonicalJson => $composableBuilder(
    column: $table.canonicalJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  $AssessmentAnnotationComposer get assessmentId {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $OfficialAnnotationComposer get refereeId {
    final $OfficialAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refereeId,
      referencedTable: $db.official,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $OfficialAnnotationComposer(
            $db: $db,
            $table: $db.official,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $RubricAnnotationComposer get rubricId {
    final $RubricAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rubricId,
      referencedTable: $db.rubric,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RubricAnnotationComposer(
            $db: $db,
            $table: $db.rubric,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ReportTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Report,
          ReportData,
          $ReportFilterComposer,
          $ReportOrderingComposer,
          $ReportAnnotationComposer,
          $ReportCreateCompanionBuilder,
          $ReportUpdateCompanionBuilder,
          (ReportData, $ReportReferences),
          ReportData,
          PrefetchHooks Function({
            bool assessmentId,
            bool refereeId,
            bool rubricId,
          })
        > {
  $ReportTableManager(_$AppDatabase db, Report table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ReportFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ReportOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ReportAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> assessmentId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> refereeId = const Value.absent(),
                Value<String> rubricId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> band = const Value.absent(),
                Value<double?> overallScore = const Value.absent(),
                Value<int> keyCorrect = const Value.absent(),
                Value<int> keyTotal = const Value.absent(),
                Value<String?> amendmentReason = const Value.absent(),
                Value<String?> finalizedAt = const Value.absent(),
                Value<String?> canonicalJson = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportCompanion(
                assessmentId: assessmentId,
                version: version,
                refereeId: refereeId,
                rubricId: rubricId,
                status: status,
                summary: summary,
                band: band,
                overallScore: overallScore,
                keyCorrect: keyCorrect,
                keyTotal: keyTotal,
                amendmentReason: amendmentReason,
                finalizedAt: finalizedAt,
                canonicalJson: canonicalJson,
                contentHash: contentHash,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assessmentId,
                required int version,
                required String refereeId,
                required String rubricId,
                required String status,
                Value<String> summary = const Value.absent(),
                Value<String?> band = const Value.absent(),
                Value<double?> overallScore = const Value.absent(),
                Value<int> keyCorrect = const Value.absent(),
                Value<int> keyTotal = const Value.absent(),
                Value<String?> amendmentReason = const Value.absent(),
                Value<String?> finalizedAt = const Value.absent(),
                Value<String?> canonicalJson = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportCompanion.insert(
                assessmentId: assessmentId,
                version: version,
                refereeId: refereeId,
                rubricId: rubricId,
                status: status,
                summary: summary,
                band: band,
                overallScore: overallScore,
                keyCorrect: keyCorrect,
                keyTotal: keyTotal,
                amendmentReason: amendmentReason,
                finalizedAt: finalizedAt,
                canonicalJson: canonicalJson,
                contentHash: contentHash,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Report, ReportData>(table),
                  $ReportReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({assessmentId = false, refereeId = false, rubricId = false}) {
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
                        if (assessmentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.assessmentId,
                            referencedTable: $ReportReferences
                                ._assessmentIdTable(db),
                            referencedColumn: $ReportReferences
                                ._assessmentIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (refereeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.refereeId,
                            referencedTable: $ReportReferences._refereeIdTable(
                              db,
                            ),
                            referencedColumn: $ReportReferences
                                ._refereeIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (rubricId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.rubricId,
                            referencedTable: $ReportReferences._rubricIdTable(
                              db,
                            ),
                            referencedColumn: $ReportReferences
                                ._rubricIdTable(db)
                                .id,
                          ) as T;
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

typedef $ReportProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Report,
      ReportData,
      $ReportFilterComposer,
      $ReportOrderingComposer,
      $ReportAnnotationComposer,
      $ReportCreateCompanionBuilder,
      $ReportUpdateCompanionBuilder,
      (ReportData, $ReportReferences),
      ReportData,
      PrefetchHooks Function({bool assessmentId, bool refereeId, bool rubricId})
    >;
typedef $CriterionScoreCreateCompanionBuilder =
    CriterionScoreCompanion Function({
      required String assessmentId,
      required int version,
      required String criterionCode,
      Value<String?> suggestedBand,
      Value<double?> suggested,
      Value<String?> finalBand,
      Value<int> notObserved,
      Value<String> justification,
      Value<String?> capBand,
      Value<String> evidenceJson,
      Value<int> rowid,
    });
typedef $CriterionScoreUpdateCompanionBuilder =
    CriterionScoreCompanion Function({
      Value<String> assessmentId,
      Value<int> version,
      Value<String> criterionCode,
      Value<String?> suggestedBand,
      Value<double?> suggested,
      Value<String?> finalBand,
      Value<int> notObserved,
      Value<String> justification,
      Value<String?> capBand,
      Value<String> evidenceJson,
      Value<int> rowid,
    });

class $CriterionScoreFilterComposer
    extends Composer<_$AppDatabase, CriterionScore> {
  $CriterionScoreFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestedBand => $composableBuilder(
    column: $table.suggestedBand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get suggested => $composableBuilder(
    column: $table.suggested,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalBand => $composableBuilder(
    column: $table.finalBand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notObserved => $composableBuilder(
    column: $table.notObserved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get justification => $composableBuilder(
    column: $table.justification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capBand => $composableBuilder(
    column: $table.capBand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $CriterionScoreOrderingComposer
    extends Composer<_$AppDatabase, CriterionScore> {
  $CriterionScoreOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestedBand => $composableBuilder(
    column: $table.suggestedBand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get suggested => $composableBuilder(
    column: $table.suggested,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalBand => $composableBuilder(
    column: $table.finalBand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notObserved => $composableBuilder(
    column: $table.notObserved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get justification => $composableBuilder(
    column: $table.justification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capBand => $composableBuilder(
    column: $table.capBand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CriterionScoreAnnotationComposer
    extends Composer<_$AppDatabase, CriterionScore> {
  $CriterionScoreAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suggestedBand => $composableBuilder(
    column: $table.suggestedBand,
    builder: (column) => column,
  );

  GeneratedColumn<double> get suggested =>
      $composableBuilder(column: $table.suggested, builder: (column) => column);

  GeneratedColumn<String> get finalBand =>
      $composableBuilder(column: $table.finalBand, builder: (column) => column);

  GeneratedColumn<int> get notObserved => $composableBuilder(
    column: $table.notObserved,
    builder: (column) => column,
  );

  GeneratedColumn<String> get justification => $composableBuilder(
    column: $table.justification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get capBand =>
      $composableBuilder(column: $table.capBand, builder: (column) => column);

  GeneratedColumn<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => column,
  );
}

class $CriterionScoreTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          CriterionScore,
          CriterionScoreData,
          $CriterionScoreFilterComposer,
          $CriterionScoreOrderingComposer,
          $CriterionScoreAnnotationComposer,
          $CriterionScoreCreateCompanionBuilder,
          $CriterionScoreUpdateCompanionBuilder,
          (
            CriterionScoreData,
            BaseReferences<_$AppDatabase, CriterionScore, CriterionScoreData>,
          ),
          CriterionScoreData,
          PrefetchHooks Function()
        > {
  $CriterionScoreTableManager(_$AppDatabase db, CriterionScore table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CriterionScoreFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CriterionScoreOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CriterionScoreAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> assessmentId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> criterionCode = const Value.absent(),
                Value<String?> suggestedBand = const Value.absent(),
                Value<double?> suggested = const Value.absent(),
                Value<String?> finalBand = const Value.absent(),
                Value<int> notObserved = const Value.absent(),
                Value<String> justification = const Value.absent(),
                Value<String?> capBand = const Value.absent(),
                Value<String> evidenceJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CriterionScoreCompanion(
                assessmentId: assessmentId,
                version: version,
                criterionCode: criterionCode,
                suggestedBand: suggestedBand,
                suggested: suggested,
                finalBand: finalBand,
                notObserved: notObserved,
                justification: justification,
                capBand: capBand,
                evidenceJson: evidenceJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assessmentId,
                required int version,
                required String criterionCode,
                Value<String?> suggestedBand = const Value.absent(),
                Value<double?> suggested = const Value.absent(),
                Value<String?> finalBand = const Value.absent(),
                Value<int> notObserved = const Value.absent(),
                Value<String> justification = const Value.absent(),
                Value<String?> capBand = const Value.absent(),
                Value<String> evidenceJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CriterionScoreCompanion.insert(
                assessmentId: assessmentId,
                version: version,
                criterionCode: criterionCode,
                suggestedBand: suggestedBand,
                suggested: suggested,
                finalBand: finalBand,
                notObserved: notObserved,
                justification: justification,
                capBand: capBand,
                evidenceJson: evidenceJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<CriterionScore, CriterionScoreData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    CriterionScore,
                    CriterionScoreData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $CriterionScoreProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      CriterionScore,
      CriterionScoreData,
      $CriterionScoreFilterComposer,
      $CriterionScoreOrderingComposer,
      $CriterionScoreAnnotationComposer,
      $CriterionScoreCreateCompanionBuilder,
      $CriterionScoreUpdateCompanionBuilder,
      (
        CriterionScoreData,
        BaseReferences<_$AppDatabase, CriterionScore, CriterionScoreData>,
      ),
      CriterionScoreData,
      PrefetchHooks Function()
    >;
typedef $FindingCreateCompanionBuilder = FindingCompanion Function({
  required String id,
  required String assessmentId,
  required int version,
  required String kind,
  required String criterionCode,
  required String bodyText,
  Value<String> evidenceJson,
  required int position,
  Value<int> rowid,
});
typedef $FindingUpdateCompanionBuilder = FindingCompanion Function({
  Value<String> id,
  Value<String> assessmentId,
  Value<int> version,
  Value<String> kind,
  Value<String> criterionCode,
  Value<String> bodyText,
  Value<String> evidenceJson,
  Value<int> position,
  Value<int> rowid,
});

class $FindingFilterComposer extends Composer<_$AppDatabase, Finding> {
  $FindingFilterComposer({
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

  ColumnFilters<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $FindingOrderingComposer extends Composer<_$AppDatabase, Finding> {
  $FindingOrderingComposer({
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

  ColumnOrderings<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $FindingAnnotationComposer extends Composer<_$AppDatabase, Finding> {
  $FindingAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyText =>
      $composableBuilder(column: $table.bodyText, builder: (column) => column);

  GeneratedColumn<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $FindingTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Finding,
          FindingData,
          $FindingFilterComposer,
          $FindingOrderingComposer,
          $FindingAnnotationComposer,
          $FindingCreateCompanionBuilder,
          $FindingUpdateCompanionBuilder,
          (FindingData, BaseReferences<_$AppDatabase, Finding, FindingData>),
          FindingData,
          PrefetchHooks Function()
        > {
  $FindingTableManager(_$AppDatabase db, Finding table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FindingFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FindingOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FindingAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assessmentId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> criterionCode = const Value.absent(),
                Value<String> bodyText = const Value.absent(),
                Value<String> evidenceJson = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FindingCompanion(
                id: id,
                assessmentId: assessmentId,
                version: version,
                kind: kind,
                criterionCode: criterionCode,
                bodyText: bodyText,
                evidenceJson: evidenceJson,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assessmentId,
                required int version,
                required String kind,
                required String criterionCode,
                required String bodyText,
                Value<String> evidenceJson = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => FindingCompanion.insert(
                id: id,
                assessmentId: assessmentId,
                version: version,
                kind: kind,
                criterionCode: criterionCode,
                bodyText: bodyText,
                evidenceJson: evidenceJson,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Finding, FindingData>(table),
                  BaseReferences<_$AppDatabase, Finding, FindingData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $FindingProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Finding,
      FindingData,
      $FindingFilterComposer,
      $FindingOrderingComposer,
      $FindingAnnotationComposer,
      $FindingCreateCompanionBuilder,
      $FindingUpdateCompanionBuilder,
      (FindingData, BaseReferences<_$AppDatabase, Finding, FindingData>),
      FindingData,
      PrefetchHooks Function()
    >;
typedef $ActionPointCreateCompanionBuilder = ActionPointCompanion Function({
  required String id,
  required String refereeId,
  required String originAssessmentId,
  required int originVersion,
  required String criterionCode,
  required String bodyText,
  required String successIndicator,
  required String status,
  Value<String?> closedByAssessmentId,
  required String createdAt,
  Value<int> rowid,
});
typedef $ActionPointUpdateCompanionBuilder = ActionPointCompanion Function({
  Value<String> id,
  Value<String> refereeId,
  Value<String> originAssessmentId,
  Value<int> originVersion,
  Value<String> criterionCode,
  Value<String> bodyText,
  Value<String> successIndicator,
  Value<String> status,
  Value<String?> closedByAssessmentId,
  Value<String> createdAt,
  Value<int> rowid,
});

final class $ActionPointReferences
    extends BaseReferences<_$AppDatabase, ActionPoint, ActionPointData> {
  $ActionPointReferences(super.$_db, super.$_table, super.$_typedResult);

  static Official _refereeIdTable(_$AppDatabase db) =>
      db.official.createAlias('action_point__referee_id__official__id');

  $OfficialProcessedTableManager get refereeId {
    final $_column = $_itemColumn<String>('referee_id')!;

    final manager = $OfficialTableManager(
      $_db,
      $_db.official,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_refereeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Assessment _originAssessmentIdTable(_$AppDatabase db) => db.assessment
      .createAlias('action_point__origin_assessment_id__assessment__id');

  $AssessmentProcessedTableManager get originAssessmentId {
    final $_column = $_itemColumn<String>('origin_assessment_id')!;

    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_originAssessmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Assessment _closedByAssessmentIdTable(_$AppDatabase db) => db
      .assessment
      .createAlias('action_point__closed_by_assessment_id__assessment__id');

  $AssessmentProcessedTableManager? get closedByAssessmentId {
    final $_column = $_itemColumn<String>('closed_by_assessment_id');
    if ($_column == null) return null;
    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _closedByAssessmentIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<ActionPointReview, List<ActionPointReviewData>>
  _actionPointReviewRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.actionPointReview,
        aliasName: 'action_point__id__action_point_review__action_point_id',
      );

  $ActionPointReviewProcessedTableManager get actionPointReviewRefs {
    final manager = $ActionPointReviewTableManager(
      $_db,
      $_db.actionPointReview,
    ).filter((f) => f.actionPointId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _actionPointReviewRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ActionPointFilterComposer extends Composer<_$AppDatabase, ActionPoint> {
  $ActionPointFilterComposer({
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

  ColumnFilters<int> get originVersion => $composableBuilder(
    column: $table.originVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get successIndicator => $composableBuilder(
    column: $table.successIndicator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $OfficialFilterComposer get refereeId {
    final $OfficialFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refereeId,
      referencedTable: $db.official,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $OfficialFilterComposer(
            $db: $db,
            $table: $db.official,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AssessmentFilterComposer get originAssessmentId {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.originAssessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AssessmentFilterComposer get closedByAssessmentId {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.closedByAssessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> actionPointReviewRefs(
    Expression<bool> Function($ActionPointReviewFilterComposer f) f,
  ) {
    final $ActionPointReviewFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actionPointReview,
      getReferencedColumn: (t) => t.actionPointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActionPointReviewFilterComposer(
            $db: $db,
            $table: $db.actionPointReview,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ActionPointOrderingComposer
    extends Composer<_$AppDatabase, ActionPoint> {
  $ActionPointOrderingComposer({
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

  ColumnOrderings<int> get originVersion => $composableBuilder(
    column: $table.originVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyText => $composableBuilder(
    column: $table.bodyText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get successIndicator => $composableBuilder(
    column: $table.successIndicator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $OfficialOrderingComposer get refereeId {
    final $OfficialOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refereeId,
      referencedTable: $db.official,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $OfficialOrderingComposer(
            $db: $db,
            $table: $db.official,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AssessmentOrderingComposer get originAssessmentId {
    final $AssessmentOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.originAssessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentOrderingComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AssessmentOrderingComposer get closedByAssessmentId {
    final $AssessmentOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.closedByAssessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentOrderingComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ActionPointAnnotationComposer
    extends Composer<_$AppDatabase, ActionPoint> {
  $ActionPointAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get originVersion => $composableBuilder(
    column: $table.originVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get criterionCode => $composableBuilder(
    column: $table.criterionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bodyText =>
      $composableBuilder(column: $table.bodyText, builder: (column) => column);

  GeneratedColumn<String> get successIndicator => $composableBuilder(
    column: $table.successIndicator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $OfficialAnnotationComposer get refereeId {
    final $OfficialAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.refereeId,
      referencedTable: $db.official,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $OfficialAnnotationComposer(
            $db: $db,
            $table: $db.official,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AssessmentAnnotationComposer get originAssessmentId {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.originAssessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $AssessmentAnnotationComposer get closedByAssessmentId {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.closedByAssessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> actionPointReviewRefs<T extends Object>(
    Expression<T> Function($ActionPointReviewAnnotationComposer a) f,
  ) {
    final $ActionPointReviewAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actionPointReview,
      getReferencedColumn: (t) => t.actionPointId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActionPointReviewAnnotationComposer(
            $db: $db,
            $table: $db.actionPointReview,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ActionPointTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ActionPoint,
          ActionPointData,
          $ActionPointFilterComposer,
          $ActionPointOrderingComposer,
          $ActionPointAnnotationComposer,
          $ActionPointCreateCompanionBuilder,
          $ActionPointUpdateCompanionBuilder,
          (ActionPointData, $ActionPointReferences),
          ActionPointData,
          PrefetchHooks Function({
            bool refereeId,
            bool originAssessmentId,
            bool closedByAssessmentId,
            bool actionPointReviewRefs,
          })
        > {
  $ActionPointTableManager(_$AppDatabase db, ActionPoint table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ActionPointFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ActionPointOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ActionPointAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> refereeId = const Value.absent(),
                Value<String> originAssessmentId = const Value.absent(),
                Value<int> originVersion = const Value.absent(),
                Value<String> criterionCode = const Value.absent(),
                Value<String> bodyText = const Value.absent(),
                Value<String> successIndicator = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> closedByAssessmentId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionPointCompanion(
                id: id,
                refereeId: refereeId,
                originAssessmentId: originAssessmentId,
                originVersion: originVersion,
                criterionCode: criterionCode,
                bodyText: bodyText,
                successIndicator: successIndicator,
                status: status,
                closedByAssessmentId: closedByAssessmentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String refereeId,
                required String originAssessmentId,
                required int originVersion,
                required String criterionCode,
                required String bodyText,
                required String successIndicator,
                required String status,
                Value<String?> closedByAssessmentId = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ActionPointCompanion.insert(
                id: id,
                refereeId: refereeId,
                originAssessmentId: originAssessmentId,
                originVersion: originVersion,
                criterionCode: criterionCode,
                bodyText: bodyText,
                successIndicator: successIndicator,
                status: status,
                closedByAssessmentId: closedByAssessmentId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ActionPoint, ActionPointData>(table),
                  $ActionPointReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                refereeId = false,
                originAssessmentId = false,
                closedByAssessmentId = false,
                actionPointReviewRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (actionPointReviewRefs) db.actionPointReview,
                  ],
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
                        if (refereeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.refereeId,
                            referencedTable: $ActionPointReferences
                                ._refereeIdTable(db),
                            referencedColumn: $ActionPointReferences
                                ._refereeIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (originAssessmentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.originAssessmentId,
                            referencedTable: $ActionPointReferences
                                ._originAssessmentIdTable(db),
                            referencedColumn: $ActionPointReferences
                                ._originAssessmentIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (closedByAssessmentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.closedByAssessmentId,
                            referencedTable: $ActionPointReferences
                                ._closedByAssessmentIdTable(db),
                            referencedColumn: $ActionPointReferences
                                ._closedByAssessmentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (actionPointReviewRefs)
                        await $_getPrefetchedData<
                          ActionPointData,
                          ActionPoint,
                          ActionPointReviewData
                        >(
                          currentTable: table,
                          referencedTable: $ActionPointReferences
                              ._actionPointReviewRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ActionPointReferences(
                                db,
                                table,
                                p0,
                              ).actionPointReviewRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.actionPointId == item.id,
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

typedef $ActionPointProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ActionPoint,
      ActionPointData,
      $ActionPointFilterComposer,
      $ActionPointOrderingComposer,
      $ActionPointAnnotationComposer,
      $ActionPointCreateCompanionBuilder,
      $ActionPointUpdateCompanionBuilder,
      (ActionPointData, $ActionPointReferences),
      ActionPointData,
      PrefetchHooks Function({
        bool refereeId,
        bool originAssessmentId,
        bool closedByAssessmentId,
        bool actionPointReviewRefs,
      })
    >;
typedef $ActionPointReviewCreateCompanionBuilder =
    ActionPointReviewCompanion Function({
      required String assessmentId,
      required int version,
      required String actionPointId,
      required String status,
      required String comment,
      Value<String> evidenceJson,
      Value<int> rowid,
    });
typedef $ActionPointReviewUpdateCompanionBuilder =
    ActionPointReviewCompanion Function({
      Value<String> assessmentId,
      Value<int> version,
      Value<String> actionPointId,
      Value<String> status,
      Value<String> comment,
      Value<String> evidenceJson,
      Value<int> rowid,
    });

final class $ActionPointReviewReferences
    extends
        BaseReferences<
          _$AppDatabase,
          ActionPointReview,
          ActionPointReviewData
        > {
  $ActionPointReviewReferences(super.$_db, super.$_table, super.$_typedResult);

  static ActionPoint _actionPointIdTable(_$AppDatabase db) => db.actionPoint
      .createAlias('action_point_review__action_point_id__action_point__id');

  $ActionPointProcessedTableManager get actionPointId {
    final $_column = $_itemColumn<String>('action_point_id')!;

    final manager = $ActionPointTableManager(
      $_db,
      $_db.actionPoint,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_actionPointIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ActionPointReviewFilterComposer
    extends Composer<_$AppDatabase, ActionPointReview> {
  $ActionPointReviewFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnFilters(column),
  );

  $ActionPointFilterComposer get actionPointId {
    final $ActionPointFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionPointId,
      referencedTable: $db.actionPoint,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActionPointFilterComposer(
            $db: $db,
            $table: $db.actionPoint,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ActionPointReviewOrderingComposer
    extends Composer<_$AppDatabase, ActionPointReview> {
  $ActionPointReviewOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => ColumnOrderings(column),
  );

  $ActionPointOrderingComposer get actionPointId {
    final $ActionPointOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionPointId,
      referencedTable: $db.actionPoint,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActionPointOrderingComposer(
            $db: $db,
            $table: $db.actionPoint,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ActionPointReviewAnnotationComposer
    extends Composer<_$AppDatabase, ActionPointReview> {
  $ActionPointReviewAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get assessmentId => $composableBuilder(
    column: $table.assessmentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get evidenceJson => $composableBuilder(
    column: $table.evidenceJson,
    builder: (column) => column,
  );

  $ActionPointAnnotationComposer get actionPointId {
    final $ActionPointAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.actionPointId,
      referencedTable: $db.actionPoint,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ActionPointAnnotationComposer(
            $db: $db,
            $table: $db.actionPoint,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ActionPointReviewTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ActionPointReview,
          ActionPointReviewData,
          $ActionPointReviewFilterComposer,
          $ActionPointReviewOrderingComposer,
          $ActionPointReviewAnnotationComposer,
          $ActionPointReviewCreateCompanionBuilder,
          $ActionPointReviewUpdateCompanionBuilder,
          (ActionPointReviewData, $ActionPointReviewReferences),
          ActionPointReviewData,
          PrefetchHooks Function({bool actionPointId})
        > {
  $ActionPointReviewTableManager(_$AppDatabase db, ActionPointReview table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ActionPointReviewFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ActionPointReviewOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ActionPointReviewAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> assessmentId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> actionPointId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<String> evidenceJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionPointReviewCompanion(
                assessmentId: assessmentId,
                version: version,
                actionPointId: actionPointId,
                status: status,
                comment: comment,
                evidenceJson: evidenceJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assessmentId,
                required int version,
                required String actionPointId,
                required String status,
                required String comment,
                Value<String> evidenceJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionPointReviewCompanion.insert(
                assessmentId: assessmentId,
                version: version,
                actionPointId: actionPointId,
                status: status,
                comment: comment,
                evidenceJson: evidenceJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ActionPointReview, ActionPointReviewData>(table),
                  $ActionPointReviewReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({actionPointId = false}) {
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
                    if (actionPointId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.actionPointId,
                        referencedTable: $ActionPointReviewReferences
                            ._actionPointIdTable(db),
                        referencedColumn: $ActionPointReviewReferences
                            ._actionPointIdTable(db)
                            .id,
                      ) as T;
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

typedef $ActionPointReviewProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ActionPointReview,
      ActionPointReviewData,
      $ActionPointReviewFilterComposer,
      $ActionPointReviewOrderingComposer,
      $ActionPointReviewAnnotationComposer,
      $ActionPointReviewCreateCompanionBuilder,
      $ActionPointReviewUpdateCompanionBuilder,
      (ActionPointReviewData, $ActionPointReviewReferences),
      ActionPointReviewData,
      PrefetchHooks Function({bool actionPointId})
    >;
typedef $OutboxCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  required String aggregateId,
  required String kind,
  required String payloadJson,
  required String createdAt,
  Value<String?> sentAt,
});
typedef $OutboxUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  Value<String> aggregateId,
  Value<String> kind,
  Value<String> payloadJson,
  Value<String> createdAt,
  Value<String?> sentAt,
});

class $OutboxFilterComposer extends Composer<_$AppDatabase, Outbox> {
  $OutboxFilterComposer({
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

  ColumnFilters<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $OutboxOrderingComposer extends Composer<_$AppDatabase, Outbox> {
  $OutboxOrderingComposer({
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

  ColumnOrderings<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $OutboxAnnotationComposer extends Composer<_$AppDatabase, Outbox> {
  $OutboxAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get aggregateId => $composableBuilder(
    column: $table.aggregateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);
}

class $OutboxTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Outbox,
          OutboxData,
          $OutboxFilterComposer,
          $OutboxOrderingComposer,
          $OutboxAnnotationComposer,
          $OutboxCreateCompanionBuilder,
          $OutboxUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, Outbox, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $OutboxTableManager(_$AppDatabase db, Outbox table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $OutboxFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $OutboxOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $OutboxAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> aggregateId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> sentAt = const Value.absent(),
              }) => OutboxCompanion(
                id: id,
                aggregateId: aggregateId,
                kind: kind,
                payloadJson: payloadJson,
                createdAt: createdAt,
                sentAt: sentAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String aggregateId,
                required String kind,
                required String payloadJson,
                required String createdAt,
                Value<String?> sentAt = const Value.absent(),
              }) => OutboxCompanion.insert(
                id: id,
                aggregateId: aggregateId,
                kind: kind,
                payloadJson: payloadJson,
                createdAt: createdAt,
                sentAt: sentAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Outbox, OutboxData>(table),
                  BaseReferences<_$AppDatabase, Outbox, OutboxData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $OutboxProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Outbox,
      OutboxData,
      $OutboxFilterComposer,
      $OutboxOrderingComposer,
      $OutboxAnnotationComposer,
      $OutboxCreateCompanionBuilder,
      $OutboxUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, Outbox, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $ExportLogCreateCompanionBuilder = ExportLogCompanion Function({
  required String id,
  required String assessmentId,
  required int version,
  required String format,
  required String relativePath,
  required String sha256,
  required String createdAt,
  Value<int> rowid,
});
typedef $ExportLogUpdateCompanionBuilder = ExportLogCompanion Function({
  Value<String> id,
  Value<String> assessmentId,
  Value<int> version,
  Value<String> format,
  Value<String> relativePath,
  Value<String> sha256,
  Value<String> createdAt,
  Value<int> rowid,
});

final class $ExportLogReferences
    extends BaseReferences<_$AppDatabase, ExportLog, ExportLogData> {
  $ExportLogReferences(super.$_db, super.$_table, super.$_typedResult);

  static Assessment _assessmentIdTable(_$AppDatabase db) =>
      db.assessment.createAlias('export_log__assessment_id__assessment__id');

  $AssessmentProcessedTableManager get assessmentId {
    final $_column = $_itemColumn<String>('assessment_id')!;

    final manager = $AssessmentTableManager(
      $_db,
      $_db.assessment,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assessmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ExportLogFilterComposer extends Composer<_$AppDatabase, ExportLog> {
  $ExportLogFilterComposer({
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

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $AssessmentFilterComposer get assessmentId {
    final $AssessmentFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentFilterComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExportLogOrderingComposer extends Composer<_$AppDatabase, ExportLog> {
  $ExportLogOrderingComposer({
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

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $AssessmentOrderingComposer get assessmentId {
    final $AssessmentOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentOrderingComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExportLogAnnotationComposer extends Composer<_$AppDatabase, ExportLog> {
  $ExportLogAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $AssessmentAnnotationComposer get assessmentId {
    final $AssessmentAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assessmentId,
      referencedTable: $db.assessment,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $AssessmentAnnotationComposer(
            $db: $db,
            $table: $db.assessment,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ExportLogTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ExportLog,
          ExportLogData,
          $ExportLogFilterComposer,
          $ExportLogOrderingComposer,
          $ExportLogAnnotationComposer,
          $ExportLogCreateCompanionBuilder,
          $ExportLogUpdateCompanionBuilder,
          (ExportLogData, $ExportLogReferences),
          ExportLogData,
          PrefetchHooks Function({bool assessmentId})
        > {
  $ExportLogTableManager(_$AppDatabase db, ExportLog table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ExportLogFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ExportLogOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ExportLogAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> assessmentId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExportLogCompanion(
                id: id,
                assessmentId: assessmentId,
                version: version,
                format: format,
                relativePath: relativePath,
                sha256: sha256,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String assessmentId,
                required int version,
                required String format,
                required String relativePath,
                required String sha256,
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExportLogCompanion.insert(
                id: id,
                assessmentId: assessmentId,
                version: version,
                format: format,
                relativePath: relativePath,
                sha256: sha256,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ExportLog, ExportLogData>(table),
                  $ExportLogReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assessmentId = false}) {
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
                    if (assessmentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assessmentId,
                        referencedTable: $ExportLogReferences
                            ._assessmentIdTable(db),
                        referencedColumn: $ExportLogReferences
                            ._assessmentIdTable(db)
                            .id,
                      ) as T;
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

typedef $ExportLogProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ExportLog,
      ExportLogData,
      $ExportLogFilterComposer,
      $ExportLogOrderingComposer,
      $ExportLogAnnotationComposer,
      $ExportLogCreateCompanionBuilder,
      $ExportLogUpdateCompanionBuilder,
      (ExportLogData, $ExportLogReferences),
      ExportLogData,
      PrefetchHooks Function({bool assessmentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $OfficialTableManager get official =>
      $OfficialTableManager(_db, _db.official);
  $AssessorProfileTableManager get assessorProfile =>
      $AssessorProfileTableManager(_db, _db.assessorProfile);
  $RubricTableManager get rubric => $RubricTableManager(_db, _db.rubric);
  $AssessmentTableManager get assessment =>
      $AssessmentTableManager(_db, _db.assessment);
  $ClockEventTableManager get clockEvent =>
      $ClockEventTableManager(_db, _db.clockEvent);
  $SessionTimeAnchorTableManager get sessionTimeAnchor =>
      $SessionTimeAnchorTableManager(_db, _db.sessionTimeAnchor);
  $IncidentTableManager get incident =>
      $IncidentTableManager(_db, _db.incident);
  $IncidentRevisionTableManager get incidentRevision =>
      $IncidentRevisionTableManager(_db, _db.incidentRevision);
  $AttachmentTableManager get attachment =>
      $AttachmentTableManager(_db, _db.attachment);
  $ReportTableManager get report => $ReportTableManager(_db, _db.report);
  $CriterionScoreTableManager get criterionScore =>
      $CriterionScoreTableManager(_db, _db.criterionScore);
  $FindingTableManager get finding => $FindingTableManager(_db, _db.finding);
  $ActionPointTableManager get actionPoint =>
      $ActionPointTableManager(_db, _db.actionPoint);
  $ActionPointReviewTableManager get actionPointReview =>
      $ActionPointReviewTableManager(_db, _db.actionPointReview);
  $OutboxTableManager get outbox => $OutboxTableManager(_db, _db.outbox);
  $ExportLogTableManager get exportLog =>
      $ExportLogTableManager(_db, _db.exportLog);
}
