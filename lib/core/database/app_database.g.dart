// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _clientNameMeta =
      const VerificationMeta('clientName');
  @override
  late final GeneratedColumn<String> clientName = GeneratedColumn<String>(
      'client_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ProjectType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ProjectType>($ProjectsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<ProjectStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ProjectStatus>($ProjectsTable.$converterstatus);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _budgetMeta = const VerificationMeta('budget');
  @override
  late final GeneratedColumn<double> budget = GeneratedColumn<double>(
      'budget', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, code, name, clientName, type, status, startDate, budget, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('client_name')) {
      context.handle(
          _clientNameMeta,
          clientName.isAcceptableOrUnknown(
              data['client_name']!, _clientNameMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('budget')) {
      context.handle(_budgetMeta,
          budget.isAcceptableOrUnknown(data['budget']!, _budgetMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      clientName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_name']),
      type: $ProjectsTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      status: $ProjectsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      budget: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}budget']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProjectType, String, String> $convertertype =
      const EnumNameConverter<ProjectType>(ProjectType.values);
  static JsonTypeConverter2<ProjectStatus, String, String> $converterstatus =
      const EnumNameConverter<ProjectStatus>(ProjectStatus.values);
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String code;
  final String name;
  final String? clientName;

  /// ProjectType enum stored as text
  final ProjectType type;

  /// ProjectStatus enum stored as text
  final ProjectStatus status;
  final DateTime startDate;
  final double? budget;
  final DateTime createdAt;
  const Project(
      {required this.id,
      required this.code,
      required this.name,
      this.clientName,
      required this.type,
      required this.status,
      required this.startDate,
      this.budget,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || clientName != null) {
      map['client_name'] = Variable<String>(clientName);
    }
    {
      map['type'] = Variable<String>($ProjectsTable.$convertertype.toSql(type));
    }
    {
      map['status'] =
          Variable<String>($ProjectsTable.$converterstatus.toSql(status));
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || budget != null) {
      map['budget'] = Variable<double>(budget);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      clientName: clientName == null && nullToAbsent
          ? const Value.absent()
          : Value(clientName),
      type: Value(type),
      status: Value(status),
      startDate: Value(startDate),
      budget:
          budget == null && nullToAbsent ? const Value.absent() : Value(budget),
      createdAt: Value(createdAt),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      clientName: serializer.fromJson<String?>(json['clientName']),
      type: $ProjectsTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      status: $ProjectsTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      budget: serializer.fromJson<double?>(json['budget']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'clientName': serializer.toJson<String?>(clientName),
      'type':
          serializer.toJson<String>($ProjectsTable.$convertertype.toJson(type)),
      'status': serializer
          .toJson<String>($ProjectsTable.$converterstatus.toJson(status)),
      'startDate': serializer.toJson<DateTime>(startDate),
      'budget': serializer.toJson<double?>(budget),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Project copyWith(
          {int? id,
          String? code,
          String? name,
          Value<String?> clientName = const Value.absent(),
          ProjectType? type,
          ProjectStatus? status,
          DateTime? startDate,
          Value<double?> budget = const Value.absent(),
          DateTime? createdAt}) =>
      Project(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        clientName: clientName.present ? clientName.value : this.clientName,
        type: type ?? this.type,
        status: status ?? this.status,
        startDate: startDate ?? this.startDate,
        budget: budget.present ? budget.value : this.budget,
        createdAt: createdAt ?? this.createdAt,
      );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      clientName:
          data.clientName.present ? data.clientName.value : this.clientName,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      budget: data.budget.present ? data.budget.value : this.budget,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('clientName: $clientName, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('budget: $budget, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, code, name, clientName, type, status, startDate, budget, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.clientName == this.clientName &&
          other.type == this.type &&
          other.status == this.status &&
          other.startDate == this.startDate &&
          other.budget == this.budget &&
          other.createdAt == this.createdAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> clientName;
  final Value<ProjectType> type;
  final Value<ProjectStatus> status;
  final Value<DateTime> startDate;
  final Value<double?> budget;
  final Value<DateTime> createdAt;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.clientName = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.budget = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    this.clientName = const Value.absent(),
    required ProjectType type,
    required ProjectStatus status,
    required DateTime startDate,
    this.budget = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : code = Value(code),
        name = Value(name),
        type = Value(type),
        status = Value(status),
        startDate = Value(startDate);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? clientName,
    Expression<String>? type,
    Expression<String>? status,
    Expression<DateTime>? startDate,
    Expression<double>? budget,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (clientName != null) 'client_name': clientName,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (budget != null) 'budget': budget,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String?>? clientName,
      Value<ProjectType>? type,
      Value<ProjectStatus>? status,
      Value<DateTime>? startDate,
      Value<double?>? budget,
      Value<DateTime>? createdAt}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      clientName: clientName ?? this.clientName,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      budget: budget ?? this.budget,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (clientName.present) {
      map['client_name'] = Variable<String>(clientName.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($ProjectsTable.$convertertype.toSql(type.value));
    }
    if (status.present) {
      map['status'] =
          Variable<String>($ProjectsTable.$converterstatus.toSql(status.value));
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (budget.present) {
      map['budget'] = Variable<double>(budget.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('clientName: $clientName, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('budget: $budget, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WorkersTable extends Workers with TableInfo<$WorkersTable, Worker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _workerCodeMeta =
      const VerificationMeta('workerCode');
  @override
  late final GeneratedColumn<String> workerCode = GeneratedColumn<String>(
      'worker_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tradeMeta = const VerificationMeta('trade');
  @override
  late final GeneratedColumn<String> trade = GeneratedColumn<String>(
      'trade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dailyRateMeta =
      const VerificationMeta('dailyRate');
  @override
  late final GeneratedColumn<double> dailyRate = GeneratedColumn<double>(
      'daily_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, workerCode, trade, dailyRate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workers';
  @override
  VerificationContext validateIntegrity(Insertable<Worker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('worker_code')) {
      context.handle(
          _workerCodeMeta,
          workerCode.isAcceptableOrUnknown(
              data['worker_code']!, _workerCodeMeta));
    }
    if (data.containsKey('trade')) {
      context.handle(
          _tradeMeta, trade.isAcceptableOrUnknown(data['trade']!, _tradeMeta));
    }
    if (data.containsKey('daily_rate')) {
      context.handle(_dailyRateMeta,
          dailyRate.isAcceptableOrUnknown(data['daily_rate']!, _dailyRateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Worker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Worker(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      workerCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}worker_code']),
      trade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trade']),
      dailyRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}daily_rate'])!,
    );
  }

  @override
  $WorkersTable createAlias(String alias) {
    return $WorkersTable(attachedDatabase, alias);
  }
}

class Worker extends DataClass implements Insertable<Worker> {
  final int id;
  final String name;
  final String? workerCode;
  final String? trade;
  final double dailyRate;
  const Worker(
      {required this.id,
      required this.name,
      this.workerCode,
      this.trade,
      required this.dailyRate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || workerCode != null) {
      map['worker_code'] = Variable<String>(workerCode);
    }
    if (!nullToAbsent || trade != null) {
      map['trade'] = Variable<String>(trade);
    }
    map['daily_rate'] = Variable<double>(dailyRate);
    return map;
  }

  WorkersCompanion toCompanion(bool nullToAbsent) {
    return WorkersCompanion(
      id: Value(id),
      name: Value(name),
      workerCode: workerCode == null && nullToAbsent
          ? const Value.absent()
          : Value(workerCode),
      trade:
          trade == null && nullToAbsent ? const Value.absent() : Value(trade),
      dailyRate: Value(dailyRate),
    );
  }

  factory Worker.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Worker(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      workerCode: serializer.fromJson<String?>(json['workerCode']),
      trade: serializer.fromJson<String?>(json['trade']),
      dailyRate: serializer.fromJson<double>(json['dailyRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'workerCode': serializer.toJson<String?>(workerCode),
      'trade': serializer.toJson<String?>(trade),
      'dailyRate': serializer.toJson<double>(dailyRate),
    };
  }

  Worker copyWith(
          {int? id,
          String? name,
          Value<String?> workerCode = const Value.absent(),
          Value<String?> trade = const Value.absent(),
          double? dailyRate}) =>
      Worker(
        id: id ?? this.id,
        name: name ?? this.name,
        workerCode: workerCode.present ? workerCode.value : this.workerCode,
        trade: trade.present ? trade.value : this.trade,
        dailyRate: dailyRate ?? this.dailyRate,
      );
  Worker copyWithCompanion(WorkersCompanion data) {
    return Worker(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      workerCode:
          data.workerCode.present ? data.workerCode.value : this.workerCode,
      trade: data.trade.present ? data.trade.value : this.trade,
      dailyRate: data.dailyRate.present ? data.dailyRate.value : this.dailyRate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Worker(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('workerCode: $workerCode, ')
          ..write('trade: $trade, ')
          ..write('dailyRate: $dailyRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, workerCode, trade, dailyRate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Worker &&
          other.id == this.id &&
          other.name == this.name &&
          other.workerCode == this.workerCode &&
          other.trade == this.trade &&
          other.dailyRate == this.dailyRate);
}

class WorkersCompanion extends UpdateCompanion<Worker> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> workerCode;
  final Value<String?> trade;
  final Value<double> dailyRate;
  const WorkersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.workerCode = const Value.absent(),
    this.trade = const Value.absent(),
    this.dailyRate = const Value.absent(),
  });
  WorkersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.workerCode = const Value.absent(),
    this.trade = const Value.absent(),
    this.dailyRate = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Worker> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? workerCode,
    Expression<String>? trade,
    Expression<double>? dailyRate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (workerCode != null) 'worker_code': workerCode,
      if (trade != null) 'trade': trade,
      if (dailyRate != null) 'daily_rate': dailyRate,
    });
  }

  WorkersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? workerCode,
      Value<String?>? trade,
      Value<double>? dailyRate}) {
    return WorkersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      workerCode: workerCode ?? this.workerCode,
      trade: trade ?? this.trade,
      dailyRate: dailyRate ?? this.dailyRate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (workerCode.present) {
      map['worker_code'] = Variable<String>(workerCode.value);
    }
    if (trade.present) {
      map['trade'] = Variable<String>(trade.value);
    }
    if (dailyRate.present) {
      map['daily_rate'] = Variable<double>(dailyRate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('workerCode: $workerCode, ')
          ..write('trade: $trade, ')
          ..write('dailyRate: $dailyRate')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoriesTable extends ExpenseCategories
    with TableInfo<$ExpenseCategoriesTable, ExpenseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _subCategoryMeta =
      const VerificationMeta('subCategory');
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, groupName, subCategory, isDefault, isActive, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_categories';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('sub_category')) {
      context.handle(
          _subCategoryMeta,
          subCategory.isAcceptableOrUnknown(
              data['sub_category']!, _subCategoryMeta));
    } else if (isInserting) {
      context.missing(_subCategoryMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $ExpenseCategoriesTable createAlias(String alias) {
    return $ExpenseCategoriesTable(attachedDatabase, alias);
  }
}

class ExpenseCategory extends DataClass implements Insertable<ExpenseCategory> {
  final int id;

  /// Parent group label, e.g. "Vehicle Expenses"
  final String groupName;

  /// Sub-category label, e.g. "Fuel (Vehicle)"
  final String subCategory;

  /// Seeded rows are flagged true — UI must prevent deletion of these.
  final bool isDefault;

  /// Soft-delete: false = hidden from dropdowns but data retained.
  final bool isActive;

  /// Controls display order within a group.
  final int sortOrder;
  const ExpenseCategory(
      {required this.id,
      required this.groupName,
      required this.subCategory,
      required this.isDefault,
      required this.isActive,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['group_name'] = Variable<String>(groupName);
    map['sub_category'] = Variable<String>(subCategory);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      groupName: Value(groupName),
      subCategory: Value(subCategory),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategory(
      id: serializer.fromJson<int>(json['id']),
      groupName: serializer.fromJson<String>(json['groupName']),
      subCategory: serializer.fromJson<String>(json['subCategory']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'groupName': serializer.toJson<String>(groupName),
      'subCategory': serializer.toJson<String>(subCategory),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ExpenseCategory copyWith(
          {int? id,
          String? groupName,
          String? subCategory,
          bool? isDefault,
          bool? isActive,
          int? sortOrder}) =>
      ExpenseCategory(
        id: id ?? this.id,
        groupName: groupName ?? this.groupName,
        subCategory: subCategory ?? this.subCategory,
        isDefault: isDefault ?? this.isDefault,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  ExpenseCategory copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategory(
      id: data.id.present ? data.id.value : this.id,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      subCategory:
          data.subCategory.present ? data.subCategory.value : this.subCategory,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategory(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('subCategory: $subCategory, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupName, subCategory, isDefault, isActive, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategory &&
          other.id == this.id &&
          other.groupName == this.groupName &&
          other.subCategory == this.subCategory &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategory> {
  final Value<int> id;
  final Value<String> groupName;
  final Value<String> subCategory;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.groupName = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String groupName,
    required String subCategory,
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : groupName = Value(groupName),
        subCategory = Value(subCategory);
  static Insertable<ExpenseCategory> custom({
    Expression<int>? id,
    Expression<String>? groupName,
    Expression<String>? subCategory,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupName != null) 'group_name': groupName,
      if (subCategory != null) 'sub_category': subCategory,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ExpenseCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? groupName,
      Value<String>? subCategory,
      Value<bool>? isDefault,
      Value<bool>? isActive,
      Value<int>? sortOrder}) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      subCategory: subCategory ?? this.subCategory,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('groupName: $groupName, ')
          ..write('subCategory: $subCategory, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $BankAccountsTable extends BankAccounts
    with TableInfo<$BankAccountsTable, BankAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _accountNameMeta =
      const VerificationMeta('accountName');
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
      'account_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ifscCodeMeta =
      const VerificationMeta('ifscCode');
  @override
  late final GeneratedColumn<String> ifscCode = GeneratedColumn<String>(
      'ifsc_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _branchMeta = const VerificationMeta('branch');
  @override
  late final GeneratedColumn<String> branch = GeneratedColumn<String>(
      'branch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _openingBalanceMeta =
      const VerificationMeta('openingBalance');
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
      'opening_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _isCashAccountMeta =
      const VerificationMeta('isCashAccount');
  @override
  late final GeneratedColumn<bool> isCashAccount = GeneratedColumn<bool>(
      'is_cash_account', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_cash_account" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountName,
        bankName,
        accountNumber,
        ifscCode,
        branch,
        openingBalance,
        isCashAccount,
        isDefault,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<BankAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_name')) {
      context.handle(
          _accountNameMeta,
          accountName.isAcceptableOrUnknown(
              data['account_name']!, _accountNameMeta));
    } else if (isInserting) {
      context.missing(_accountNameMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    }
    if (data.containsKey('ifsc_code')) {
      context.handle(_ifscCodeMeta,
          ifscCode.isAcceptableOrUnknown(data['ifsc_code']!, _ifscCodeMeta));
    }
    if (data.containsKey('branch')) {
      context.handle(_branchMeta,
          branch.isAcceptableOrUnknown(data['branch']!, _branchMeta));
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
          _openingBalanceMeta,
          openingBalance.isAcceptableOrUnknown(
              data['opening_balance']!, _openingBalanceMeta));
    }
    if (data.containsKey('is_cash_account')) {
      context.handle(
          _isCashAccountMeta,
          isCashAccount.isAcceptableOrUnknown(
              data['is_cash_account']!, _isCashAccountMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankAccount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      accountName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_name'])!,
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name']),
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number']),
      ifscCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ifsc_code']),
      branch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch']),
      openingBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}opening_balance'])!,
      isCashAccount: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_cash_account'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BankAccountsTable createAlias(String alias) {
    return $BankAccountsTable(attachedDatabase, alias);
  }
}

class BankAccount extends DataClass implements Insertable<BankAccount> {
  final int id;
  final String accountName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branch;
  final double openingBalance;
  final bool isCashAccount;
  final bool isDefault;
  final DateTime createdAt;
  const BankAccount(
      {required this.id,
      required this.accountName,
      this.bankName,
      this.accountNumber,
      this.ifscCode,
      this.branch,
      required this.openingBalance,
      required this.isCashAccount,
      required this.isDefault,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_name'] = Variable<String>(accountName);
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    if (!nullToAbsent || ifscCode != null) {
      map['ifsc_code'] = Variable<String>(ifscCode);
    }
    if (!nullToAbsent || branch != null) {
      map['branch'] = Variable<String>(branch);
    }
    map['opening_balance'] = Variable<double>(openingBalance);
    map['is_cash_account'] = Variable<bool>(isCashAccount);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BankAccountsCompanion toCompanion(bool nullToAbsent) {
    return BankAccountsCompanion(
      id: Value(id),
      accountName: Value(accountName),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      ifscCode: ifscCode == null && nullToAbsent
          ? const Value.absent()
          : Value(ifscCode),
      branch:
          branch == null && nullToAbsent ? const Value.absent() : Value(branch),
      openingBalance: Value(openingBalance),
      isCashAccount: Value(isCashAccount),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
    );
  }

  factory BankAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankAccount(
      id: serializer.fromJson<int>(json['id']),
      accountName: serializer.fromJson<String>(json['accountName']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      ifscCode: serializer.fromJson<String?>(json['ifscCode']),
      branch: serializer.fromJson<String?>(json['branch']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      isCashAccount: serializer.fromJson<bool>(json['isCashAccount']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountName': serializer.toJson<String>(accountName),
      'bankName': serializer.toJson<String?>(bankName),
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'ifscCode': serializer.toJson<String?>(ifscCode),
      'branch': serializer.toJson<String?>(branch),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'isCashAccount': serializer.toJson<bool>(isCashAccount),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BankAccount copyWith(
          {int? id,
          String? accountName,
          Value<String?> bankName = const Value.absent(),
          Value<String?> accountNumber = const Value.absent(),
          Value<String?> ifscCode = const Value.absent(),
          Value<String?> branch = const Value.absent(),
          double? openingBalance,
          bool? isCashAccount,
          bool? isDefault,
          DateTime? createdAt}) =>
      BankAccount(
        id: id ?? this.id,
        accountName: accountName ?? this.accountName,
        bankName: bankName.present ? bankName.value : this.bankName,
        accountNumber:
            accountNumber.present ? accountNumber.value : this.accountNumber,
        ifscCode: ifscCode.present ? ifscCode.value : this.ifscCode,
        branch: branch.present ? branch.value : this.branch,
        openingBalance: openingBalance ?? this.openingBalance,
        isCashAccount: isCashAccount ?? this.isCashAccount,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
      );
  BankAccount copyWithCompanion(BankAccountsCompanion data) {
    return BankAccount(
      id: data.id.present ? data.id.value : this.id,
      accountName:
          data.accountName.present ? data.accountName.value : this.accountName,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      ifscCode: data.ifscCode.present ? data.ifscCode.value : this.ifscCode,
      branch: data.branch.present ? data.branch.value : this.branch,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      isCashAccount: data.isCashAccount.present
          ? data.isCashAccount.value
          : this.isCashAccount,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankAccount(')
          ..write('id: $id, ')
          ..write('accountName: $accountName, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('ifscCode: $ifscCode, ')
          ..write('branch: $branch, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isCashAccount: $isCashAccount, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountName, bankName, accountNumber,
      ifscCode, branch, openingBalance, isCashAccount, isDefault, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankAccount &&
          other.id == this.id &&
          other.accountName == this.accountName &&
          other.bankName == this.bankName &&
          other.accountNumber == this.accountNumber &&
          other.ifscCode == this.ifscCode &&
          other.branch == this.branch &&
          other.openingBalance == this.openingBalance &&
          other.isCashAccount == this.isCashAccount &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class BankAccountsCompanion extends UpdateCompanion<BankAccount> {
  final Value<int> id;
  final Value<String> accountName;
  final Value<String?> bankName;
  final Value<String?> accountNumber;
  final Value<String?> ifscCode;
  final Value<String?> branch;
  final Value<double> openingBalance;
  final Value<bool> isCashAccount;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  const BankAccountsCompanion({
    this.id = const Value.absent(),
    this.accountName = const Value.absent(),
    this.bankName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.ifscCode = const Value.absent(),
    this.branch = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.isCashAccount = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BankAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String accountName,
    this.bankName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.ifscCode = const Value.absent(),
    this.branch = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.isCashAccount = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : accountName = Value(accountName);
  static Insertable<BankAccount> custom({
    Expression<int>? id,
    Expression<String>? accountName,
    Expression<String>? bankName,
    Expression<String>? accountNumber,
    Expression<String>? ifscCode,
    Expression<String>? branch,
    Expression<double>? openingBalance,
    Expression<bool>? isCashAccount,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountName != null) 'account_name': accountName,
      if (bankName != null) 'bank_name': bankName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (ifscCode != null) 'ifsc_code': ifscCode,
      if (branch != null) 'branch': branch,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (isCashAccount != null) 'is_cash_account': isCashAccount,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BankAccountsCompanion copyWith(
      {Value<int>? id,
      Value<String>? accountName,
      Value<String?>? bankName,
      Value<String?>? accountNumber,
      Value<String?>? ifscCode,
      Value<String?>? branch,
      Value<double>? openingBalance,
      Value<bool>? isCashAccount,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt}) {
    return BankAccountsCompanion(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branch: branch ?? this.branch,
      openingBalance: openingBalance ?? this.openingBalance,
      isCashAccount: isCashAccount ?? this.isCashAccount,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (ifscCode.present) {
      map['ifsc_code'] = Variable<String>(ifscCode.value);
    }
    if (branch.present) {
      map['branch'] = Variable<String>(branch.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (isCashAccount.present) {
      map['is_cash_account'] = Variable<bool>(isCashAccount.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankAccountsCompanion(')
          ..write('id: $id, ')
          ..write('accountName: $accountName, ')
          ..write('bankName: $bankName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('ifscCode: $ifscCode, ')
          ..write('branch: $branch, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isCashAccount: $isCashAccount, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE RESTRICT'));
  static const VerificationMeta _workerIdMeta =
      const VerificationMeta('workerId');
  @override
  late final GeneratedColumn<int> workerId = GeneratedColumn<int>(
      'worker_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES workers (id) ON DELETE RESTRICT'));
  static const VerificationMeta _expenseCategoryIdMeta =
      const VerificationMeta('expenseCategoryId');
  @override
  late final GeneratedColumn<int> expenseCategoryId = GeneratedColumn<int>(
      'expense_category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES expense_categories (id) ON DELETE SET NULL'));
  static const VerificationMeta _bankAccountIdMeta =
      const VerificationMeta('bankAccountId');
  @override
  late final GeneratedColumn<int> bankAccountId = GeneratedColumn<int>(
      'bank_account_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES bank_accounts (id) ON DELETE SET NULL'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TransactionType>($TransactionsTable.$convertertype);
  static const VerificationMeta _affectsPnlMeta =
      const VerificationMeta('affectsPnl');
  @override
  late final GeneratedColumn<bool> affectsPnl = GeneratedColumn<bool>(
      'affects_pnl', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("affects_pnl" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _affectsCashMeta =
      const VerificationMeta('affectsCash');
  @override
  late final GeneratedColumn<bool> affectsCash = GeneratedColumn<bool>(
      'affects_cash', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("affects_cash" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMode?, String>
      paymentMode = GeneratedColumn<String>('payment_mode', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<PaymentMode?>(
              $TransactionsTable.$converterpaymentModen);
  static const VerificationMeta _narrationMeta =
      const VerificationMeta('narration');
  @override
  late final GeneratedColumn<String> narration = GeneratedColumn<String>(
      'narration', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _referenceNoMeta =
      const VerificationMeta('referenceNo');
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
      'reference_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        workerId,
        expenseCategoryId,
        bankAccountId,
        date,
        type,
        affectsPnl,
        affectsCash,
        amount,
        paymentMode,
        narration,
        referenceNo,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('worker_id')) {
      context.handle(_workerIdMeta,
          workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta));
    }
    if (data.containsKey('expense_category_id')) {
      context.handle(
          _expenseCategoryIdMeta,
          expenseCategoryId.isAcceptableOrUnknown(
              data['expense_category_id']!, _expenseCategoryIdMeta));
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
          _bankAccountIdMeta,
          bankAccountId.isAcceptableOrUnknown(
              data['bank_account_id']!, _bankAccountIdMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('affects_pnl')) {
      context.handle(
          _affectsPnlMeta,
          affectsPnl.isAcceptableOrUnknown(
              data['affects_pnl']!, _affectsPnlMeta));
    }
    if (data.containsKey('affects_cash')) {
      context.handle(
          _affectsCashMeta,
          affectsCash.isAcceptableOrUnknown(
              data['affects_cash']!, _affectsCashMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('narration')) {
      context.handle(_narrationMeta,
          narration.isAcceptableOrUnknown(data['narration']!, _narrationMeta));
    }
    if (data.containsKey('reference_no')) {
      context.handle(
          _referenceNoMeta,
          referenceNo.isAcceptableOrUnknown(
              data['reference_no']!, _referenceNoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      workerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}worker_id']),
      expenseCategoryId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}expense_category_id']),
      bankAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bank_account_id']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      type: $TransactionsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      affectsPnl: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}affects_pnl'])!,
      affectsCash: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}affects_cash'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentMode: $TransactionsTable.$converterpaymentModen.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}payment_mode'])),
      narration: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}narration']),
      referenceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_no']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, String, String> $convertertype =
      const EnumNameConverter<TransactionType>(TransactionType.values);
  static JsonTypeConverter2<PaymentMode, String, String> $converterpaymentMode =
      const EnumNameConverter<PaymentMode>(PaymentMode.values);
  static JsonTypeConverter2<PaymentMode?, String?, String?>
      $converterpaymentModen =
      JsonTypeConverter2.asNullable($converterpaymentMode);
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int projectId;
  final int? workerId;

  /// Optional expense category — only set for type=expense entries.
  /// setNull on delete so existing transactions survive category removal.
  final int? expenseCategoryId;

  /// Optional Bank Account reference — indicates which bank account or cash drawer held this money.
  final int? bankAccountId;
  final DateTime date;
  final TransactionType type;

  /// FALSE for deposit / depositRefund transactions — they are liabilities,
  /// not income. TRUE for income/expense/purchase/labourPayment.
  final bool affectsPnl;

  /// FALSE for internal adjustments (e.g. deposit adjusted to income) that do NOT move physical cash.
  /// TRUE for physical cash inflows/outflows.
  final bool affectsCash;
  final double amount;
  final PaymentMode? paymentMode;
  final String? narration;
  final String? referenceNo;
  final DateTime createdAt;
  const Transaction(
      {required this.id,
      required this.projectId,
      this.workerId,
      this.expenseCategoryId,
      this.bankAccountId,
      required this.date,
      required this.type,
      required this.affectsPnl,
      required this.affectsCash,
      required this.amount,
      this.paymentMode,
      this.narration,
      this.referenceNo,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    if (!nullToAbsent || workerId != null) {
      map['worker_id'] = Variable<int>(workerId);
    }
    if (!nullToAbsent || expenseCategoryId != null) {
      map['expense_category_id'] = Variable<int>(expenseCategoryId);
    }
    if (!nullToAbsent || bankAccountId != null) {
      map['bank_account_id'] = Variable<int>(bankAccountId);
    }
    map['date'] = Variable<DateTime>(date);
    {
      map['type'] =
          Variable<String>($TransactionsTable.$convertertype.toSql(type));
    }
    map['affects_pnl'] = Variable<bool>(affectsPnl);
    map['affects_cash'] = Variable<bool>(affectsCash);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || paymentMode != null) {
      map['payment_mode'] = Variable<String>(
          $TransactionsTable.$converterpaymentModen.toSql(paymentMode));
    }
    if (!nullToAbsent || narration != null) {
      map['narration'] = Variable<String>(narration);
    }
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      workerId: workerId == null && nullToAbsent
          ? const Value.absent()
          : Value(workerId),
      expenseCategoryId: expenseCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseCategoryId),
      bankAccountId: bankAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccountId),
      date: Value(date),
      type: Value(type),
      affectsPnl: Value(affectsPnl),
      affectsCash: Value(affectsCash),
      amount: Value(amount),
      paymentMode: paymentMode == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMode),
      narration: narration == null && nullToAbsent
          ? const Value.absent()
          : Value(narration),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      workerId: serializer.fromJson<int?>(json['workerId']),
      expenseCategoryId: serializer.fromJson<int?>(json['expenseCategoryId']),
      bankAccountId: serializer.fromJson<int?>(json['bankAccountId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: $TransactionsTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      affectsPnl: serializer.fromJson<bool>(json['affectsPnl']),
      affectsCash: serializer.fromJson<bool>(json['affectsCash']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMode: $TransactionsTable.$converterpaymentModen
          .fromJson(serializer.fromJson<String?>(json['paymentMode'])),
      narration: serializer.fromJson<String?>(json['narration']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'workerId': serializer.toJson<int?>(workerId),
      'expenseCategoryId': serializer.toJson<int?>(expenseCategoryId),
      'bankAccountId': serializer.toJson<int?>(bankAccountId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer
          .toJson<String>($TransactionsTable.$convertertype.toJson(type)),
      'affectsPnl': serializer.toJson<bool>(affectsPnl),
      'affectsCash': serializer.toJson<bool>(affectsCash),
      'amount': serializer.toJson<double>(amount),
      'paymentMode': serializer.toJson<String?>(
          $TransactionsTable.$converterpaymentModen.toJson(paymentMode)),
      'narration': serializer.toJson<String?>(narration),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transaction copyWith(
          {int? id,
          int? projectId,
          Value<int?> workerId = const Value.absent(),
          Value<int?> expenseCategoryId = const Value.absent(),
          Value<int?> bankAccountId = const Value.absent(),
          DateTime? date,
          TransactionType? type,
          bool? affectsPnl,
          bool? affectsCash,
          double? amount,
          Value<PaymentMode?> paymentMode = const Value.absent(),
          Value<String?> narration = const Value.absent(),
          Value<String?> referenceNo = const Value.absent(),
          DateTime? createdAt}) =>
      Transaction(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        workerId: workerId.present ? workerId.value : this.workerId,
        expenseCategoryId: expenseCategoryId.present
            ? expenseCategoryId.value
            : this.expenseCategoryId,
        bankAccountId:
            bankAccountId.present ? bankAccountId.value : this.bankAccountId,
        date: date ?? this.date,
        type: type ?? this.type,
        affectsPnl: affectsPnl ?? this.affectsPnl,
        affectsCash: affectsCash ?? this.affectsCash,
        amount: amount ?? this.amount,
        paymentMode: paymentMode.present ? paymentMode.value : this.paymentMode,
        narration: narration.present ? narration.value : this.narration,
        referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
        createdAt: createdAt ?? this.createdAt,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      expenseCategoryId: data.expenseCategoryId.present
          ? data.expenseCategoryId.value
          : this.expenseCategoryId,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      affectsPnl:
          data.affectsPnl.present ? data.affectsPnl.value : this.affectsPnl,
      affectsCash:
          data.affectsCash.present ? data.affectsCash.value : this.affectsCash,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      narration: data.narration.present ? data.narration.value : this.narration,
      referenceNo:
          data.referenceNo.present ? data.referenceNo.value : this.referenceNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('workerId: $workerId, ')
          ..write('expenseCategoryId: $expenseCategoryId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('affectsPnl: $affectsPnl, ')
          ..write('affectsCash: $affectsCash, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('narration: $narration, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      projectId,
      workerId,
      expenseCategoryId,
      bankAccountId,
      date,
      type,
      affectsPnl,
      affectsCash,
      amount,
      paymentMode,
      narration,
      referenceNo,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.workerId == this.workerId &&
          other.expenseCategoryId == this.expenseCategoryId &&
          other.bankAccountId == this.bankAccountId &&
          other.date == this.date &&
          other.type == this.type &&
          other.affectsPnl == this.affectsPnl &&
          other.affectsCash == this.affectsCash &&
          other.amount == this.amount &&
          other.paymentMode == this.paymentMode &&
          other.narration == this.narration &&
          other.referenceNo == this.referenceNo &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<int?> workerId;
  final Value<int?> expenseCategoryId;
  final Value<int?> bankAccountId;
  final Value<DateTime> date;
  final Value<TransactionType> type;
  final Value<bool> affectsPnl;
  final Value<bool> affectsCash;
  final Value<double> amount;
  final Value<PaymentMode?> paymentMode;
  final Value<String?> narration;
  final Value<String?> referenceNo;
  final Value<DateTime> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.workerId = const Value.absent(),
    this.expenseCategoryId = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.affectsPnl = const Value.absent(),
    this.affectsCash = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.narration = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    this.workerId = const Value.absent(),
    this.expenseCategoryId = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    required DateTime date,
    required TransactionType type,
    this.affectsPnl = const Value.absent(),
    this.affectsCash = const Value.absent(),
    required double amount,
    this.paymentMode = const Value.absent(),
    this.narration = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : projectId = Value(projectId),
        date = Value(date),
        type = Value(type),
        amount = Value(amount);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<int>? workerId,
    Expression<int>? expenseCategoryId,
    Expression<int>? bankAccountId,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<bool>? affectsPnl,
    Expression<bool>? affectsCash,
    Expression<double>? amount,
    Expression<String>? paymentMode,
    Expression<String>? narration,
    Expression<String>? referenceNo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (workerId != null) 'worker_id': workerId,
      if (expenseCategoryId != null) 'expense_category_id': expenseCategoryId,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (affectsPnl != null) 'affects_pnl': affectsPnl,
      if (affectsCash != null) 'affects_cash': affectsCash,
      if (amount != null) 'amount': amount,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (narration != null) 'narration': narration,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? projectId,
      Value<int?>? workerId,
      Value<int?>? expenseCategoryId,
      Value<int?>? bankAccountId,
      Value<DateTime>? date,
      Value<TransactionType>? type,
      Value<bool>? affectsPnl,
      Value<bool>? affectsCash,
      Value<double>? amount,
      Value<PaymentMode?>? paymentMode,
      Value<String?>? narration,
      Value<String?>? referenceNo,
      Value<DateTime>? createdAt}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      workerId: workerId ?? this.workerId,
      expenseCategoryId: expenseCategoryId ?? this.expenseCategoryId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      date: date ?? this.date,
      type: type ?? this.type,
      affectsPnl: affectsPnl ?? this.affectsPnl,
      affectsCash: affectsCash ?? this.affectsCash,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      narration: narration ?? this.narration,
      referenceNo: referenceNo ?? this.referenceNo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<int>(workerId.value);
    }
    if (expenseCategoryId.present) {
      map['expense_category_id'] = Variable<int>(expenseCategoryId.value);
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<int>(bankAccountId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($TransactionsTable.$convertertype.toSql(type.value));
    }
    if (affectsPnl.present) {
      map['affects_pnl'] = Variable<bool>(affectsPnl.value);
    }
    if (affectsCash.present) {
      map['affects_cash'] = Variable<bool>(affectsCash.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(
          $TransactionsTable.$converterpaymentModen.toSql(paymentMode.value));
    }
    if (narration.present) {
      map['narration'] = Variable<String>(narration.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('workerId: $workerId, ')
          ..write('expenseCategoryId: $expenseCategoryId, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('affectsPnl: $affectsPnl, ')
          ..write('affectsCash: $affectsCash, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('narration: $narration, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VendorsTable extends Vendors with TableInfo<$VendorsTable, Vendor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _contactMeta =
      const VerificationMeta('contact');
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
      'contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, contact];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendors';
  @override
  VerificationContext validateIntegrity(Insertable<Vendor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(_contactMeta,
          contact.isAcceptableOrUnknown(data['contact']!, _contactMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vendor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vendor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      contact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact']),
    );
  }

  @override
  $VendorsTable createAlias(String alias) {
    return $VendorsTable(attachedDatabase, alias);
  }
}

class Vendor extends DataClass implements Insertable<Vendor> {
  final int id;
  final String name;
  final String? contact;
  const Vendor({required this.id, required this.name, this.contact});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    return map;
  }

  VendorsCompanion toCompanion(bool nullToAbsent) {
    return VendorsCompanion(
      id: Value(id),
      name: Value(name),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
    );
  }

  factory Vendor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vendor(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contact: serializer.fromJson<String?>(json['contact']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'contact': serializer.toJson<String?>(contact),
    };
  }

  Vendor copyWith(
          {int? id,
          String? name,
          Value<String?> contact = const Value.absent()}) =>
      Vendor(
        id: id ?? this.id,
        name: name ?? this.name,
        contact: contact.present ? contact.value : this.contact,
      );
  Vendor copyWithCompanion(VendorsCompanion data) {
    return Vendor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contact: data.contact.present ? data.contact.value : this.contact,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vendor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, contact);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vendor &&
          other.id == this.id &&
          other.name == this.name &&
          other.contact == this.contact);
}

class VendorsCompanion extends UpdateCompanion<Vendor> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> contact;
  const VendorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contact = const Value.absent(),
  });
  VendorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.contact = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Vendor> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? contact,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contact != null) 'contact': contact,
    });
  }

  VendorsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String?>? contact}) {
    return VendorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id) ON DELETE CASCADE'));
  static const VerificationMeta _vendorIdMeta =
      const VerificationMeta('vendorId');
  @override
  late final GeneratedColumn<int> vendorId = GeneratedColumn<int>(
      'vendor_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vendors (id) ON DELETE RESTRICT'));
  static const VerificationMeta _itemDescriptionMeta =
      const VerificationMeta('itemDescription');
  @override
  late final GeneratedColumn<String> itemDescription = GeneratedColumn<String>(
      'item_description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _unitRateMeta =
      const VerificationMeta('unitRate');
  @override
  late final GeneratedColumn<double> unitRate = GeneratedColumn<double>(
      'unit_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  late final GeneratedColumnWithTypeConverter<PaymentStatus, String>
      paymentStatus = GeneratedColumn<String>(
              'payment_status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PaymentStatus>(
              $PurchasesTable.$converterpaymentStatus);
  static const VerificationMeta _isAdvanceStockMeta =
      const VerificationMeta('isAdvanceStock');
  @override
  late final GeneratedColumn<bool> isAdvanceStock = GeneratedColumn<bool>(
      'is_advance_stock', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_advance_stock" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _allocatedAmountMeta =
      const VerificationMeta('allocatedAmount');
  @override
  late final GeneratedColumn<double> allocatedAmount = GeneratedColumn<double>(
      'allocated_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        vendorId,
        itemDescription,
        quantity,
        unitRate,
        unit,
        paidAmount,
        paymentStatus,
        isAdvanceStock,
        allocatedAmount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(Insertable<Purchase> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('vendor_id')) {
      context.handle(_vendorIdMeta,
          vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta));
    } else if (isInserting) {
      context.missing(_vendorIdMeta);
    }
    if (data.containsKey('item_description')) {
      context.handle(
          _itemDescriptionMeta,
          itemDescription.isAcceptableOrUnknown(
              data['item_description']!, _itemDescriptionMeta));
    } else if (isInserting) {
      context.missing(_itemDescriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('unit_rate')) {
      context.handle(_unitRateMeta,
          unitRate.isAcceptableOrUnknown(data['unit_rate']!, _unitRateMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('is_advance_stock')) {
      context.handle(
          _isAdvanceStockMeta,
          isAdvanceStock.isAcceptableOrUnknown(
              data['is_advance_stock']!, _isAdvanceStockMeta));
    }
    if (data.containsKey('allocated_amount')) {
      context.handle(
          _allocatedAmountMeta,
          allocatedAmount.isAcceptableOrUnknown(
              data['allocated_amount']!, _allocatedAmountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      vendorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vendor_id'])!,
      itemDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}item_description'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      unitRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_rate'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}paid_amount'])!,
      paymentStatus: $PurchasesTable.$converterpaymentStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}payment_status'])!),
      isAdvanceStock: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_advance_stock'])!,
      allocatedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}allocated_amount'])!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentStatus, String, String>
      $converterpaymentStatus =
      const EnumNameConverter<PaymentStatus>(PaymentStatus.values);
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final int id;
  final int transactionId;
  final int vendorId;
  final String itemDescription;
  final double quantity;
  final double unitRate;
  final String? unit;
  final double paidAmount;
  final PaymentStatus paymentStatus;
  final bool isAdvanceStock;
  final double allocatedAmount;
  const Purchase(
      {required this.id,
      required this.transactionId,
      required this.vendorId,
      required this.itemDescription,
      required this.quantity,
      required this.unitRate,
      this.unit,
      required this.paidAmount,
      required this.paymentStatus,
      required this.isAdvanceStock,
      required this.allocatedAmount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['vendor_id'] = Variable<int>(vendorId);
    map['item_description'] = Variable<String>(itemDescription);
    map['quantity'] = Variable<double>(quantity);
    map['unit_rate'] = Variable<double>(unitRate);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['paid_amount'] = Variable<double>(paidAmount);
    {
      map['payment_status'] = Variable<String>(
          $PurchasesTable.$converterpaymentStatus.toSql(paymentStatus));
    }
    map['is_advance_stock'] = Variable<bool>(isAdvanceStock);
    map['allocated_amount'] = Variable<double>(allocatedAmount);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      vendorId: Value(vendorId),
      itemDescription: Value(itemDescription),
      quantity: Value(quantity),
      unitRate: Value(unitRate),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      paidAmount: Value(paidAmount),
      paymentStatus: Value(paymentStatus),
      isAdvanceStock: Value(isAdvanceStock),
      allocatedAmount: Value(allocatedAmount),
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      vendorId: serializer.fromJson<int>(json['vendorId']),
      itemDescription: serializer.fromJson<String>(json['itemDescription']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitRate: serializer.fromJson<double>(json['unitRate']),
      unit: serializer.fromJson<String?>(json['unit']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      paymentStatus: $PurchasesTable.$converterpaymentStatus
          .fromJson(serializer.fromJson<String>(json['paymentStatus'])),
      isAdvanceStock: serializer.fromJson<bool>(json['isAdvanceStock']),
      allocatedAmount: serializer.fromJson<double>(json['allocatedAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'vendorId': serializer.toJson<int>(vendorId),
      'itemDescription': serializer.toJson<String>(itemDescription),
      'quantity': serializer.toJson<double>(quantity),
      'unitRate': serializer.toJson<double>(unitRate),
      'unit': serializer.toJson<String?>(unit),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'paymentStatus': serializer.toJson<String>(
          $PurchasesTable.$converterpaymentStatus.toJson(paymentStatus)),
      'isAdvanceStock': serializer.toJson<bool>(isAdvanceStock),
      'allocatedAmount': serializer.toJson<double>(allocatedAmount),
    };
  }

  Purchase copyWith(
          {int? id,
          int? transactionId,
          int? vendorId,
          String? itemDescription,
          double? quantity,
          double? unitRate,
          Value<String?> unit = const Value.absent(),
          double? paidAmount,
          PaymentStatus? paymentStatus,
          bool? isAdvanceStock,
          double? allocatedAmount}) =>
      Purchase(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        vendorId: vendorId ?? this.vendorId,
        itemDescription: itemDescription ?? this.itemDescription,
        quantity: quantity ?? this.quantity,
        unitRate: unitRate ?? this.unitRate,
        unit: unit.present ? unit.value : this.unit,
        paidAmount: paidAmount ?? this.paidAmount,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        isAdvanceStock: isAdvanceStock ?? this.isAdvanceStock,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      );
  Purchase copyWithCompanion(PurchasesCompanion data) {
    return Purchase(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      itemDescription: data.itemDescription.present
          ? data.itemDescription.value
          : this.itemDescription,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitRate: data.unitRate.present ? data.unitRate.value : this.unitRate,
      unit: data.unit.present ? data.unit.value : this.unit,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      isAdvanceStock: data.isAdvanceStock.present
          ? data.isAdvanceStock.value
          : this.isAdvanceStock,
      allocatedAmount: data.allocatedAmount.present
          ? data.allocatedAmount.value
          : this.allocatedAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('vendorId: $vendorId, ')
          ..write('itemDescription: $itemDescription, ')
          ..write('quantity: $quantity, ')
          ..write('unitRate: $unitRate, ')
          ..write('unit: $unit, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('isAdvanceStock: $isAdvanceStock, ')
          ..write('allocatedAmount: $allocatedAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      vendorId,
      itemDescription,
      quantity,
      unitRate,
      unit,
      paidAmount,
      paymentStatus,
      isAdvanceStock,
      allocatedAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.vendorId == this.vendorId &&
          other.itemDescription == this.itemDescription &&
          other.quantity == this.quantity &&
          other.unitRate == this.unitRate &&
          other.unit == this.unit &&
          other.paidAmount == this.paidAmount &&
          other.paymentStatus == this.paymentStatus &&
          other.isAdvanceStock == this.isAdvanceStock &&
          other.allocatedAmount == this.allocatedAmount);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> vendorId;
  final Value<String> itemDescription;
  final Value<double> quantity;
  final Value<double> unitRate;
  final Value<String?> unit;
  final Value<double> paidAmount;
  final Value<PaymentStatus> paymentStatus;
  final Value<bool> isAdvanceStock;
  final Value<double> allocatedAmount;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.itemDescription = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitRate = const Value.absent(),
    this.unit = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.isAdvanceStock = const Value.absent(),
    this.allocatedAmount = const Value.absent(),
  });
  PurchasesCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int vendorId,
    required String itemDescription,
    this.quantity = const Value.absent(),
    this.unitRate = const Value.absent(),
    this.unit = const Value.absent(),
    this.paidAmount = const Value.absent(),
    required PaymentStatus paymentStatus,
    this.isAdvanceStock = const Value.absent(),
    this.allocatedAmount = const Value.absent(),
  })  : transactionId = Value(transactionId),
        vendorId = Value(vendorId),
        itemDescription = Value(itemDescription),
        paymentStatus = Value(paymentStatus);
  static Insertable<Purchase> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? vendorId,
    Expression<String>? itemDescription,
    Expression<double>? quantity,
    Expression<double>? unitRate,
    Expression<String>? unit,
    Expression<double>? paidAmount,
    Expression<String>? paymentStatus,
    Expression<bool>? isAdvanceStock,
    Expression<double>? allocatedAmount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (vendorId != null) 'vendor_id': vendorId,
      if (itemDescription != null) 'item_description': itemDescription,
      if (quantity != null) 'quantity': quantity,
      if (unitRate != null) 'unit_rate': unitRate,
      if (unit != null) 'unit': unit,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (isAdvanceStock != null) 'is_advance_stock': isAdvanceStock,
      if (allocatedAmount != null) 'allocated_amount': allocatedAmount,
    });
  }

  PurchasesCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int>? vendorId,
      Value<String>? itemDescription,
      Value<double>? quantity,
      Value<double>? unitRate,
      Value<String?>? unit,
      Value<double>? paidAmount,
      Value<PaymentStatus>? paymentStatus,
      Value<bool>? isAdvanceStock,
      Value<double>? allocatedAmount}) {
    return PurchasesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      vendorId: vendorId ?? this.vendorId,
      itemDescription: itemDescription ?? this.itemDescription,
      quantity: quantity ?? this.quantity,
      unitRate: unitRate ?? this.unitRate,
      unit: unit ?? this.unit,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      isAdvanceStock: isAdvanceStock ?? this.isAdvanceStock,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<int>(vendorId.value);
    }
    if (itemDescription.present) {
      map['item_description'] = Variable<String>(itemDescription.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitRate.present) {
      map['unit_rate'] = Variable<double>(unitRate.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(
          $PurchasesTable.$converterpaymentStatus.toSql(paymentStatus.value));
    }
    if (isAdvanceStock.present) {
      map['is_advance_stock'] = Variable<bool>(isAdvanceStock.value);
    }
    if (allocatedAmount.present) {
      map['allocated_amount'] = Variable<double>(allocatedAmount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('vendorId: $vendorId, ')
          ..write('itemDescription: $itemDescription, ')
          ..write('quantity: $quantity, ')
          ..write('unitRate: $unitRate, ')
          ..write('unit: $unit, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('isAdvanceStock: $isAdvanceStock, ')
          ..write('allocatedAmount: $allocatedAmount')
          ..write(')'))
        .toString();
  }
}

class $AttendanceTable extends Attendance
    with TableInfo<$AttendanceTable, AttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workerIdMeta =
      const VerificationMeta('workerId');
  @override
  late final GeneratedColumn<int> workerId = GeneratedColumn<int>(
      'worker_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES workers (id) ON DELETE CASCADE'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE RESTRICT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<AttendanceStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<AttendanceStatus>($AttendanceTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [id, workerId, projectId, date, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(Insertable<AttendanceData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('worker_id')) {
      context.handle(_workerIdMeta,
          workerId.isAcceptableOrUnknown(data['worker_id']!, _workerIdMeta));
    } else if (isInserting) {
      context.missing(_workerIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {workerId, projectId, date},
      ];
  @override
  AttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}worker_id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      status: $AttendanceTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
    );
  }

  @override
  $AttendanceTable createAlias(String alias) {
    return $AttendanceTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AttendanceStatus, String, String> $converterstatus =
      const EnumNameConverter<AttendanceStatus>(AttendanceStatus.values);
}

class AttendanceData extends DataClass implements Insertable<AttendanceData> {
  final int id;
  final int workerId;
  final int projectId;
  final DateTime date;
  final AttendanceStatus status;
  const AttendanceData(
      {required this.id,
      required this.workerId,
      required this.projectId,
      required this.date,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['worker_id'] = Variable<int>(workerId);
    map['project_id'] = Variable<int>(projectId);
    map['date'] = Variable<DateTime>(date);
    {
      map['status'] =
          Variable<String>($AttendanceTable.$converterstatus.toSql(status));
    }
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      id: Value(id),
      workerId: Value(workerId),
      projectId: Value(projectId),
      date: Value(date),
      status: Value(status),
    );
  }

  factory AttendanceData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceData(
      id: serializer.fromJson<int>(json['id']),
      workerId: serializer.fromJson<int>(json['workerId']),
      projectId: serializer.fromJson<int>(json['projectId']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: $AttendanceTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workerId': serializer.toJson<int>(workerId),
      'projectId': serializer.toJson<int>(projectId),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer
          .toJson<String>($AttendanceTable.$converterstatus.toJson(status)),
    };
  }

  AttendanceData copyWith(
          {int? id,
          int? workerId,
          int? projectId,
          DateTime? date,
          AttendanceStatus? status}) =>
      AttendanceData(
        id: id ?? this.id,
        workerId: workerId ?? this.workerId,
        projectId: projectId ?? this.projectId,
        date: date ?? this.date,
        status: status ?? this.status,
      );
  AttendanceData copyWithCompanion(AttendanceCompanion data) {
    return AttendanceData(
      id: data.id.present ? data.id.value : this.id,
      workerId: data.workerId.present ? data.workerId.value : this.workerId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceData(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('projectId: $projectId, ')
          ..write('date: $date, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, workerId, projectId, date, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceData &&
          other.id == this.id &&
          other.workerId == this.workerId &&
          other.projectId == this.projectId &&
          other.date == this.date &&
          other.status == this.status);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceData> {
  final Value<int> id;
  final Value<int> workerId;
  final Value<int> projectId;
  final Value<DateTime> date;
  final Value<AttendanceStatus> status;
  const AttendanceCompanion({
    this.id = const Value.absent(),
    this.workerId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
  });
  AttendanceCompanion.insert({
    this.id = const Value.absent(),
    required int workerId,
    required int projectId,
    required DateTime date,
    required AttendanceStatus status,
  })  : workerId = Value(workerId),
        projectId = Value(projectId),
        date = Value(date),
        status = Value(status);
  static Insertable<AttendanceData> custom({
    Expression<int>? id,
    Expression<int>? workerId,
    Expression<int>? projectId,
    Expression<DateTime>? date,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workerId != null) 'worker_id': workerId,
      if (projectId != null) 'project_id': projectId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
    });
  }

  AttendanceCompanion copyWith(
      {Value<int>? id,
      Value<int>? workerId,
      Value<int>? projectId,
      Value<DateTime>? date,
      Value<AttendanceStatus>? status}) {
    return AttendanceCompanion(
      id: id ?? this.id,
      workerId: workerId ?? this.workerId,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workerId.present) {
      map['worker_id'] = Variable<int>(workerId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
          $AttendanceTable.$converterstatus.toSql(status.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('id: $id, ')
          ..write('workerId: $workerId, ')
          ..write('projectId: $projectId, ')
          ..write('date: $date, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $DepositsTable extends Deposits with TableInfo<$DepositsTable, Deposit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DepositsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id) ON DELETE RESTRICT'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE RESTRICT'));
  @override
  late final GeneratedColumnWithTypeConverter<DepositType, String> depositType =
      GeneratedColumn<String>('deposit_type', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: Constant(DepositType.paid.name))
          .withConverter<DepositType>($DepositsTable.$converterdepositType);
  @override
  late final GeneratedColumnWithTypeConverter<DepositStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DepositStatus>($DepositsTable.$converterstatus);
  static const VerificationMeta _adjustedAmountMeta =
      const VerificationMeta('adjustedAmount');
  @override
  late final GeneratedColumn<double> adjustedAmount = GeneratedColumn<double>(
      'adjusted_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _adjustmentReferenceMeta =
      const VerificationMeta('adjustmentReference');
  @override
  late final GeneratedColumn<String> adjustmentReference =
      GeneratedColumn<String>('adjustment_reference', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionId,
        projectId,
        depositType,
        status,
        adjustedAmount,
        adjustmentReference
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deposits';
  @override
  VerificationContext validateIntegrity(Insertable<Deposit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('adjusted_amount')) {
      context.handle(
          _adjustedAmountMeta,
          adjustedAmount.isAcceptableOrUnknown(
              data['adjusted_amount']!, _adjustedAmountMeta));
    }
    if (data.containsKey('adjustment_reference')) {
      context.handle(
          _adjustmentReferenceMeta,
          adjustmentReference.isAcceptableOrUnknown(
              data['adjustment_reference']!, _adjustmentReferenceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deposit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deposit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      depositType: $DepositsTable.$converterdepositType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}deposit_type'])!),
      status: $DepositsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      adjustedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}adjusted_amount'])!,
      adjustmentReference: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}adjustment_reference']),
    );
  }

  @override
  $DepositsTable createAlias(String alias) {
    return $DepositsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DepositType, String, String> $converterdepositType =
      const EnumNameConverter<DepositType>(DepositType.values);
  static JsonTypeConverter2<DepositStatus, String, String> $converterstatus =
      const EnumNameConverter<DepositStatus>(DepositStatus.values);
}

class Deposit extends DataClass implements Insertable<Deposit> {
  final int id;
  final int transactionId;
  final int projectId;
  final DepositType depositType;
  final DepositStatus status;

  /// Total portion of this deposit recovered (if paid) or adjusted to income (if received) so far.
  final double adjustedAmount;

  /// FDR / EMD / Challan / Work-order / Invoice reference.
  final String? adjustmentReference;
  const Deposit(
      {required this.id,
      required this.transactionId,
      required this.projectId,
      required this.depositType,
      required this.status,
      required this.adjustedAmount,
      this.adjustmentReference});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['project_id'] = Variable<int>(projectId);
    {
      map['deposit_type'] = Variable<String>(
          $DepositsTable.$converterdepositType.toSql(depositType));
    }
    {
      map['status'] =
          Variable<String>($DepositsTable.$converterstatus.toSql(status));
    }
    map['adjusted_amount'] = Variable<double>(adjustedAmount);
    if (!nullToAbsent || adjustmentReference != null) {
      map['adjustment_reference'] = Variable<String>(adjustmentReference);
    }
    return map;
  }

  DepositsCompanion toCompanion(bool nullToAbsent) {
    return DepositsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      projectId: Value(projectId),
      depositType: Value(depositType),
      status: Value(status),
      adjustedAmount: Value(adjustedAmount),
      adjustmentReference: adjustmentReference == null && nullToAbsent
          ? const Value.absent()
          : Value(adjustmentReference),
    );
  }

  factory Deposit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deposit(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      projectId: serializer.fromJson<int>(json['projectId']),
      depositType: $DepositsTable.$converterdepositType
          .fromJson(serializer.fromJson<String>(json['depositType'])),
      status: $DepositsTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      adjustedAmount: serializer.fromJson<double>(json['adjustedAmount']),
      adjustmentReference:
          serializer.fromJson<String?>(json['adjustmentReference']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'projectId': serializer.toJson<int>(projectId),
      'depositType': serializer.toJson<String>(
          $DepositsTable.$converterdepositType.toJson(depositType)),
      'status': serializer
          .toJson<String>($DepositsTable.$converterstatus.toJson(status)),
      'adjustedAmount': serializer.toJson<double>(adjustedAmount),
      'adjustmentReference': serializer.toJson<String?>(adjustmentReference),
    };
  }

  Deposit copyWith(
          {int? id,
          int? transactionId,
          int? projectId,
          DepositType? depositType,
          DepositStatus? status,
          double? adjustedAmount,
          Value<String?> adjustmentReference = const Value.absent()}) =>
      Deposit(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        projectId: projectId ?? this.projectId,
        depositType: depositType ?? this.depositType,
        status: status ?? this.status,
        adjustedAmount: adjustedAmount ?? this.adjustedAmount,
        adjustmentReference: adjustmentReference.present
            ? adjustmentReference.value
            : this.adjustmentReference,
      );
  Deposit copyWithCompanion(DepositsCompanion data) {
    return Deposit(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      depositType:
          data.depositType.present ? data.depositType.value : this.depositType,
      status: data.status.present ? data.status.value : this.status,
      adjustedAmount: data.adjustedAmount.present
          ? data.adjustedAmount.value
          : this.adjustedAmount,
      adjustmentReference: data.adjustmentReference.present
          ? data.adjustmentReference.value
          : this.adjustmentReference,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deposit(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('projectId: $projectId, ')
          ..write('depositType: $depositType, ')
          ..write('status: $status, ')
          ..write('adjustedAmount: $adjustedAmount, ')
          ..write('adjustmentReference: $adjustmentReference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, projectId, depositType,
      status, adjustedAmount, adjustmentReference);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deposit &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.projectId == this.projectId &&
          other.depositType == this.depositType &&
          other.status == this.status &&
          other.adjustedAmount == this.adjustedAmount &&
          other.adjustmentReference == this.adjustmentReference);
}

class DepositsCompanion extends UpdateCompanion<Deposit> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> projectId;
  final Value<DepositType> depositType;
  final Value<DepositStatus> status;
  final Value<double> adjustedAmount;
  final Value<String?> adjustmentReference;
  const DepositsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.depositType = const Value.absent(),
    this.status = const Value.absent(),
    this.adjustedAmount = const Value.absent(),
    this.adjustmentReference = const Value.absent(),
  });
  DepositsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int projectId,
    this.depositType = const Value.absent(),
    required DepositStatus status,
    this.adjustedAmount = const Value.absent(),
    this.adjustmentReference = const Value.absent(),
  })  : transactionId = Value(transactionId),
        projectId = Value(projectId),
        status = Value(status);
  static Insertable<Deposit> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? projectId,
    Expression<String>? depositType,
    Expression<String>? status,
    Expression<double>? adjustedAmount,
    Expression<String>? adjustmentReference,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (projectId != null) 'project_id': projectId,
      if (depositType != null) 'deposit_type': depositType,
      if (status != null) 'status': status,
      if (adjustedAmount != null) 'adjusted_amount': adjustedAmount,
      if (adjustmentReference != null)
        'adjustment_reference': adjustmentReference,
    });
  }

  DepositsCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int>? projectId,
      Value<DepositType>? depositType,
      Value<DepositStatus>? status,
      Value<double>? adjustedAmount,
      Value<String?>? adjustmentReference}) {
    return DepositsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      projectId: projectId ?? this.projectId,
      depositType: depositType ?? this.depositType,
      status: status ?? this.status,
      adjustedAmount: adjustedAmount ?? this.adjustedAmount,
      adjustmentReference: adjustmentReference ?? this.adjustmentReference,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (depositType.present) {
      map['deposit_type'] = Variable<String>(
          $DepositsTable.$converterdepositType.toSql(depositType.value));
    }
    if (status.present) {
      map['status'] =
          Variable<String>($DepositsTable.$converterstatus.toSql(status.value));
    }
    if (adjustedAmount.present) {
      map['adjusted_amount'] = Variable<double>(adjustedAmount.value);
    }
    if (adjustmentReference.present) {
      map['adjustment_reference'] = Variable<String>(adjustmentReference.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DepositsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('projectId: $projectId, ')
          ..write('depositType: $depositType, ')
          ..write('status: $status, ')
          ..write('adjustedAmount: $adjustedAmount, ')
          ..write('adjustmentReference: $adjustmentReference')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $WorkersTable workers = $WorkersTable(this);
  late final $ExpenseCategoriesTable expenseCategories =
      $ExpenseCategoriesTable(this);
  late final $BankAccountsTable bankAccounts = $BankAccountsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $VendorsTable vendors = $VendorsTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $DepositsTable deposits = $DepositsTable(this);
  late final ProjectDao projectDao = ProjectDao(this as AppDatabase);
  late final TransactionDao transactionDao =
      TransactionDao(this as AppDatabase);
  late final PurchaseDao purchaseDao = PurchaseDao(this as AppDatabase);
  late final LabourDao labourDao = LabourDao(this as AppDatabase);
  late final DepositDao depositDao = DepositDao(this as AppDatabase);
  late final ExpenseCategoryDao expenseCategoryDao =
      ExpenseCategoryDao(this as AppDatabase);
  late final BankAccountDao bankAccountDao =
      BankAccountDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        projects,
        workers,
        expenseCategories,
        bankAccounts,
        transactions,
        vendors,
        purchases,
        attendance,
        deposits
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('expense_categories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transactions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bank_accounts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('transactions', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('transactions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('purchases', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('workers',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('attendance', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  required String code,
  required String name,
  Value<String?> clientName,
  required ProjectType type,
  required ProjectStatus status,
  required DateTime startDate,
  Value<double?> budget,
  Value<DateTime> createdAt,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  Value<String> code,
  Value<String> name,
  Value<String?> clientName,
  Value<ProjectType> type,
  Value<ProjectStatus> status,
  Value<DateTime> startDate,
  Value<double?> budget,
  Value<DateTime> createdAt,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.transactions,
          aliasName:
              $_aliasNameGenerator(db.projects.id, db.transactions.projectId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AttendanceTable, List<AttendanceData>>
      _attendanceRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.attendance,
          aliasName:
              $_aliasNameGenerator(db.projects.id, db.attendance.projectId));

  $$AttendanceTableProcessedTableManager get attendanceRefs {
    final manager = $$AttendanceTableTableManager($_db, $_db.attendance)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendanceRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DepositsTable, List<Deposit>> _depositsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.deposits,
          aliasName:
              $_aliasNameGenerator(db.projects.id, db.deposits.projectId));

  $$DepositsTableProcessedTableManager get depositsRefs {
    final manager = $$DepositsTableTableManager($_db, $_db.deposits)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_depositsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientName => $composableBuilder(
      column: $table.clientName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ProjectType, ProjectType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ProjectStatus, ProjectStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get budget => $composableBuilder(
      column: $table.budget, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> attendanceRefs(
      Expression<bool> Function($$AttendanceTableFilterComposer f) f) {
    final $$AttendanceTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableFilterComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> depositsRefs(
      Expression<bool> Function($$DepositsTableFilterComposer f) f) {
    final $$DepositsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deposits,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DepositsTableFilterComposer(
              $db: $db,
              $table: $db.deposits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientName => $composableBuilder(
      column: $table.clientName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get budget => $composableBuilder(
      column: $table.budget, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get clientName => $composableBuilder(
      column: $table.clientName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProjectType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProjectStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<double> get budget =>
      $composableBuilder(column: $table.budget, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> attendanceRefs<T extends Object>(
      Expression<T> Function($$AttendanceTableAnnotationComposer a) f) {
    final $$AttendanceTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableAnnotationComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> depositsRefs<T extends Object>(
      Expression<T> Function($$DepositsTableAnnotationComposer a) f) {
    final $$DepositsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deposits,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DepositsTableAnnotationComposer(
              $db: $db,
              $table: $db.deposits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, $$ProjectsTableReferences),
    Project,
    PrefetchHooks Function(
        {bool transactionsRefs, bool attendanceRefs, bool depositsRefs})> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> clientName = const Value.absent(),
            Value<ProjectType> type = const Value.absent(),
            Value<ProjectStatus> status = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<double?> budget = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            code: code,
            name: name,
            clientName: clientName,
            type: type,
            status: status,
            startDate: startDate,
            budget: budget,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            required String name,
            Value<String?> clientName = const Value.absent(),
            required ProjectType type,
            required ProjectStatus status,
            required DateTime startDate,
            Value<double?> budget = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            code: code,
            name: name,
            clientName: clientName,
            type: type,
            status: status,
            startDate: startDate,
            budget: budget,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {transactionsRefs = false,
              attendanceRefs = false,
              depositsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (attendanceRefs) db.attendance,
                if (depositsRefs) db.deposits
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (attendanceRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            AttendanceData>(
                        currentTable: table,
                        referencedTable:
                            $$ProjectsTableReferences._attendanceRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .attendanceRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (depositsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable, Deposit>(
                        currentTable: table,
                        referencedTable:
                            $$ProjectsTableReferences._depositsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .depositsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, $$ProjectsTableReferences),
    Project,
    PrefetchHooks Function(
        {bool transactionsRefs, bool attendanceRefs, bool depositsRefs})>;
typedef $$WorkersTableCreateCompanionBuilder = WorkersCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> workerCode,
  Value<String?> trade,
  Value<double> dailyRate,
});
typedef $$WorkersTableUpdateCompanionBuilder = WorkersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> workerCode,
  Value<String?> trade,
  Value<double> dailyRate,
});

final class $$WorkersTableReferences
    extends BaseReferences<_$AppDatabase, $WorkersTable, Worker> {
  $$WorkersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.transactions,
          aliasName:
              $_aliasNameGenerator(db.workers.id, db.transactions.workerId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.workerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AttendanceTable, List<AttendanceData>>
      _attendanceRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.attendance,
              aliasName:
                  $_aliasNameGenerator(db.workers.id, db.attendance.workerId));

  $$AttendanceTableProcessedTableManager get attendanceRefs {
    final manager = $$AttendanceTableTableManager($_db, $_db.attendance)
        .filter((f) => f.workerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendanceRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkersTableFilterComposer
    extends Composer<_$AppDatabase, $WorkersTable> {
  $$WorkersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workerCode => $composableBuilder(
      column: $table.workerCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trade => $composableBuilder(
      column: $table.trade, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dailyRate => $composableBuilder(
      column: $table.dailyRate, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.workerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> attendanceRefs(
      Expression<bool> Function($$AttendanceTableFilterComposer f) f) {
    final $$AttendanceTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.workerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableFilterComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkersTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkersTable> {
  $$WorkersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workerCode => $composableBuilder(
      column: $table.workerCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trade => $composableBuilder(
      column: $table.trade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dailyRate => $composableBuilder(
      column: $table.dailyRate, builder: (column) => ColumnOrderings(column));
}

class $$WorkersTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkersTable> {
  $$WorkersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get workerCode => $composableBuilder(
      column: $table.workerCode, builder: (column) => column);

  GeneratedColumn<String> get trade =>
      $composableBuilder(column: $table.trade, builder: (column) => column);

  GeneratedColumn<double> get dailyRate =>
      $composableBuilder(column: $table.dailyRate, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.workerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> attendanceRefs<T extends Object>(
      Expression<T> Function($$AttendanceTableAnnotationComposer a) f) {
    final $$AttendanceTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.attendance,
        getReferencedColumn: (t) => t.workerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttendanceTableAnnotationComposer(
              $db: $db,
              $table: $db.attendance,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkersTable,
    Worker,
    $$WorkersTableFilterComposer,
    $$WorkersTableOrderingComposer,
    $$WorkersTableAnnotationComposer,
    $$WorkersTableCreateCompanionBuilder,
    $$WorkersTableUpdateCompanionBuilder,
    (Worker, $$WorkersTableReferences),
    Worker,
    PrefetchHooks Function({bool transactionsRefs, bool attendanceRefs})> {
  $$WorkersTableTableManager(_$AppDatabase db, $WorkersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> workerCode = const Value.absent(),
            Value<String?> trade = const Value.absent(),
            Value<double> dailyRate = const Value.absent(),
          }) =>
              WorkersCompanion(
            id: id,
            name: name,
            workerCode: workerCode,
            trade: trade,
            dailyRate: dailyRate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> workerCode = const Value.absent(),
            Value<String?> trade = const Value.absent(),
            Value<double> dailyRate = const Value.absent(),
          }) =>
              WorkersCompanion.insert(
            id: id,
            name: name,
            workerCode: workerCode,
            trade: trade,
            dailyRate: dailyRate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WorkersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {transactionsRefs = false, attendanceRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (attendanceRefs) db.attendance
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<Worker, $WorkersTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable:
                            $$WorkersTableReferences._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkersTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.workerId == item.id),
                        typedResults: items),
                  if (attendanceRefs)
                    await $_getPrefetchedData<Worker, $WorkersTable,
                            AttendanceData>(
                        currentTable: table,
                        referencedTable:
                            $$WorkersTableReferences._attendanceRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkersTableReferences(db, table, p0)
                                .attendanceRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.workerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkersTable,
    Worker,
    $$WorkersTableFilterComposer,
    $$WorkersTableOrderingComposer,
    $$WorkersTableAnnotationComposer,
    $$WorkersTableCreateCompanionBuilder,
    $$WorkersTableUpdateCompanionBuilder,
    (Worker, $$WorkersTableReferences),
    Worker,
    PrefetchHooks Function({bool transactionsRefs, bool attendanceRefs})>;
typedef $$ExpenseCategoriesTableCreateCompanionBuilder
    = ExpenseCategoriesCompanion Function({
  Value<int> id,
  required String groupName,
  required String subCategory,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<int> sortOrder,
});
typedef $$ExpenseCategoriesTableUpdateCompanionBuilder
    = ExpenseCategoriesCompanion Function({
  Value<int> id,
  Value<String> groupName,
  Value<String> subCategory,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<int> sortOrder,
});

final class $$ExpenseCategoriesTableReferences extends BaseReferences<
    _$AppDatabase, $ExpenseCategoriesTable, ExpenseCategory> {
  $$ExpenseCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.expenseCategories.id, db.transactions.expenseCategoryId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter(
            (f) => f.expenseCategoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.expenseCategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$ExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.expenseCategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExpenseCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpenseCategoriesTable,
    ExpenseCategory,
    $$ExpenseCategoriesTableFilterComposer,
    $$ExpenseCategoriesTableOrderingComposer,
    $$ExpenseCategoriesTableAnnotationComposer,
    $$ExpenseCategoriesTableCreateCompanionBuilder,
    $$ExpenseCategoriesTableUpdateCompanionBuilder,
    (ExpenseCategory, $$ExpenseCategoriesTableReferences),
    ExpenseCategory,
    PrefetchHooks Function({bool transactionsRefs})> {
  $$ExpenseCategoriesTableTableManager(
      _$AppDatabase db, $ExpenseCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<String> subCategory = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              ExpenseCategoriesCompanion(
            id: id,
            groupName: groupName,
            subCategory: subCategory,
            isDefault: isDefault,
            isActive: isActive,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String groupName,
            required String subCategory,
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              ExpenseCategoriesCompanion.insert(
            id: id,
            groupName: groupName,
            subCategory: subCategory,
            isDefault: isDefault,
            isActive: isActive,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExpenseCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<ExpenseCategory,
                            $ExpenseCategoriesTable, Transaction>(
                        currentTable: table,
                        referencedTable: $$ExpenseCategoriesTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExpenseCategoriesTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.expenseCategoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ExpenseCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpenseCategoriesTable,
    ExpenseCategory,
    $$ExpenseCategoriesTableFilterComposer,
    $$ExpenseCategoriesTableOrderingComposer,
    $$ExpenseCategoriesTableAnnotationComposer,
    $$ExpenseCategoriesTableCreateCompanionBuilder,
    $$ExpenseCategoriesTableUpdateCompanionBuilder,
    (ExpenseCategory, $$ExpenseCategoriesTableReferences),
    ExpenseCategory,
    PrefetchHooks Function({bool transactionsRefs})>;
typedef $$BankAccountsTableCreateCompanionBuilder = BankAccountsCompanion
    Function({
  Value<int> id,
  required String accountName,
  Value<String?> bankName,
  Value<String?> accountNumber,
  Value<String?> ifscCode,
  Value<String?> branch,
  Value<double> openingBalance,
  Value<bool> isCashAccount,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
});
typedef $$BankAccountsTableUpdateCompanionBuilder = BankAccountsCompanion
    Function({
  Value<int> id,
  Value<String> accountName,
  Value<String?> bankName,
  Value<String?> accountNumber,
  Value<String?> ifscCode,
  Value<String?> branch,
  Value<double> openingBalance,
  Value<bool> isCashAccount,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
});

final class $$BankAccountsTableReferences
    extends BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccount> {
  $$BankAccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
      _transactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.transactions,
              aliasName: $_aliasNameGenerator(
                  db.bankAccounts.id, db.transactions.bankAccountId));

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.bankAccountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BankAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountName => $composableBuilder(
      column: $table.accountName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ifscCode => $composableBuilder(
      column: $table.ifscCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branch => $composableBuilder(
      column: $table.branch, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCashAccount => $composableBuilder(
      column: $table.isCashAccount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> transactionsRefs(
      Expression<bool> Function($$TransactionsTableFilterComposer f) f) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.bankAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BankAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountName => $composableBuilder(
      column: $table.accountName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ifscCode => $composableBuilder(
      column: $table.ifscCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branch => $composableBuilder(
      column: $table.branch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCashAccount => $composableBuilder(
      column: $table.isCashAccount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BankAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountName => $composableBuilder(
      column: $table.accountName, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<String> get ifscCode =>
      $composableBuilder(column: $table.ifscCode, builder: (column) => column);

  GeneratedColumn<String> get branch =>
      $composableBuilder(column: $table.branch, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
      column: $table.openingBalance, builder: (column) => column);

  GeneratedColumn<bool> get isCashAccount => $composableBuilder(
      column: $table.isCashAccount, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> transactionsRefs<T extends Object>(
      Expression<T> Function($$TransactionsTableAnnotationComposer a) f) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.bankAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BankAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BankAccountsTable,
    BankAccount,
    $$BankAccountsTableFilterComposer,
    $$BankAccountsTableOrderingComposer,
    $$BankAccountsTableAnnotationComposer,
    $$BankAccountsTableCreateCompanionBuilder,
    $$BankAccountsTableUpdateCompanionBuilder,
    (BankAccount, $$BankAccountsTableReferences),
    BankAccount,
    PrefetchHooks Function({bool transactionsRefs})> {
  $$BankAccountsTableTableManager(_$AppDatabase db, $BankAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> accountName = const Value.absent(),
            Value<String?> bankName = const Value.absent(),
            Value<String?> accountNumber = const Value.absent(),
            Value<String?> ifscCode = const Value.absent(),
            Value<String?> branch = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<bool> isCashAccount = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BankAccountsCompanion(
            id: id,
            accountName: accountName,
            bankName: bankName,
            accountNumber: accountNumber,
            ifscCode: ifscCode,
            branch: branch,
            openingBalance: openingBalance,
            isCashAccount: isCashAccount,
            isDefault: isDefault,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String accountName,
            Value<String?> bankName = const Value.absent(),
            Value<String?> accountNumber = const Value.absent(),
            Value<String?> ifscCode = const Value.absent(),
            Value<String?> branch = const Value.absent(),
            Value<double> openingBalance = const Value.absent(),
            Value<bool> isCashAccount = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BankAccountsCompanion.insert(
            id: id,
            accountName: accountName,
            bankName: bankName,
            accountNumber: accountNumber,
            ifscCode: ifscCode,
            branch: branch,
            openingBalance: openingBalance,
            isCashAccount: isCashAccount,
            isDefault: isDefault,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BankAccountsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (transactionsRefs) db.transactions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transactionsRefs)
                    await $_getPrefetchedData<BankAccount, $BankAccountsTable,
                            Transaction>(
                        currentTable: table,
                        referencedTable: $$BankAccountsTableReferences
                            ._transactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BankAccountsTableReferences(db, table, p0)
                                .transactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.bankAccountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BankAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BankAccountsTable,
    BankAccount,
    $$BankAccountsTableFilterComposer,
    $$BankAccountsTableOrderingComposer,
    $$BankAccountsTableAnnotationComposer,
    $$BankAccountsTableCreateCompanionBuilder,
    $$BankAccountsTableUpdateCompanionBuilder,
    (BankAccount, $$BankAccountsTableReferences),
    BankAccount,
    PrefetchHooks Function({bool transactionsRefs})>;
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required int projectId,
  Value<int?> workerId,
  Value<int?> expenseCategoryId,
  Value<int?> bankAccountId,
  required DateTime date,
  required TransactionType type,
  Value<bool> affectsPnl,
  Value<bool> affectsCash,
  required double amount,
  Value<PaymentMode?> paymentMode,
  Value<String?> narration,
  Value<String?> referenceNo,
  Value<DateTime> createdAt,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<int> projectId,
  Value<int?> workerId,
  Value<int?> expenseCategoryId,
  Value<int?> bankAccountId,
  Value<DateTime> date,
  Value<TransactionType> type,
  Value<bool> affectsPnl,
  Value<bool> affectsCash,
  Value<double> amount,
  Value<PaymentMode?> paymentMode,
  Value<String?> narration,
  Value<String?> referenceNo,
  Value<DateTime> createdAt,
});

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.transactions.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkersTable _workerIdTable(_$AppDatabase db) =>
      db.workers.createAlias(
          $_aliasNameGenerator(db.transactions.workerId, db.workers.id));

  $$WorkersTableProcessedTableManager? get workerId {
    final $_column = $_itemColumn<int>('worker_id');
    if ($_column == null) return null;
    final manager = $$WorkersTableTableManager($_db, $_db.workers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExpenseCategoriesTable _expenseCategoryIdTable(_$AppDatabase db) =>
      db.expenseCategories.createAlias($_aliasNameGenerator(
          db.transactions.expenseCategoryId, db.expenseCategories.id));

  $$ExpenseCategoriesTableProcessedTableManager? get expenseCategoryId {
    final $_column = $_itemColumn<int>('expense_category_id');
    if ($_column == null) return null;
    final manager =
        $$ExpenseCategoriesTableTableManager($_db, $_db.expenseCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BankAccountsTable _bankAccountIdTable(_$AppDatabase db) =>
      db.bankAccounts.createAlias($_aliasNameGenerator(
          db.transactions.bankAccountId, db.bankAccounts.id));

  $$BankAccountsTableProcessedTableManager? get bankAccountId {
    final $_column = $_itemColumn<int>('bank_account_id');
    if ($_column == null) return null;
    final manager = $$BankAccountsTableTableManager($_db, $_db.bankAccounts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bankAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PurchasesTable, List<Purchase>>
      _purchasesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.purchases,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.purchases.transactionId));

  $$PurchasesTableProcessedTableManager get purchasesRefs {
    final manager = $$PurchasesTableTableManager($_db, $_db.purchases)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchasesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DepositsTable, List<Deposit>> _depositsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.deposits,
          aliasName: $_aliasNameGenerator(
              db.transactions.id, db.deposits.transactionId));

  $$DepositsTableProcessedTableManager get depositsRefs {
    final manager = $$DepositsTableTableManager($_db, $_db.deposits)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_depositsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get affectsPnl => $composableBuilder(
      column: $table.affectsPnl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get affectsCash => $composableBuilder(
      column: $table.affectsCash, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMode?, PaymentMode, String>
      get paymentMode => $composableBuilder(
          column: $table.paymentMode,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get narration => $composableBuilder(
      column: $table.narration, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkersTableFilterComposer get workerId {
    final $$WorkersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workerId,
        referencedTable: $db.workers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkersTableFilterComposer(
              $db: $db,
              $table: $db.workers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExpenseCategoriesTableFilterComposer get expenseCategoryId {
    final $$ExpenseCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseCategoryId,
        referencedTable: $db.expenseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.expenseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BankAccountsTableFilterComposer get bankAccountId {
    final $$BankAccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bankAccountId,
        referencedTable: $db.bankAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BankAccountsTableFilterComposer(
              $db: $db,
              $table: $db.bankAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> purchasesRefs(
      Expression<bool> Function($$PurchasesTableFilterComposer f) f) {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.purchases,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchasesTableFilterComposer(
              $db: $db,
              $table: $db.purchases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> depositsRefs(
      Expression<bool> Function($$DepositsTableFilterComposer f) f) {
    final $$DepositsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deposits,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DepositsTableFilterComposer(
              $db: $db,
              $table: $db.deposits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get affectsPnl => $composableBuilder(
      column: $table.affectsPnl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get affectsCash => $composableBuilder(
      column: $table.affectsCash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get narration => $composableBuilder(
      column: $table.narration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkersTableOrderingComposer get workerId {
    final $$WorkersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workerId,
        referencedTable: $db.workers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkersTableOrderingComposer(
              $db: $db,
              $table: $db.workers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExpenseCategoriesTableOrderingComposer get expenseCategoryId {
    final $$ExpenseCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.expenseCategoryId,
        referencedTable: $db.expenseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.expenseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BankAccountsTableOrderingComposer get bankAccountId {
    final $$BankAccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bankAccountId,
        referencedTable: $db.bankAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BankAccountsTableOrderingComposer(
              $db: $db,
              $table: $db.bankAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get affectsPnl => $composableBuilder(
      column: $table.affectsPnl, builder: (column) => column);

  GeneratedColumn<bool> get affectsCash => $composableBuilder(
      column: $table.affectsCash, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMode?, String> get paymentMode =>
      $composableBuilder(
          column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<String> get narration =>
      $composableBuilder(column: $table.narration, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkersTableAnnotationComposer get workerId {
    final $$WorkersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workerId,
        referencedTable: $db.workers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkersTableAnnotationComposer(
              $db: $db,
              $table: $db.workers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExpenseCategoriesTableAnnotationComposer get expenseCategoryId {
    final $$ExpenseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.expenseCategoryId,
            referencedTable: $db.expenseCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExpenseCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.expenseCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$BankAccountsTableAnnotationComposer get bankAccountId {
    final $$BankAccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bankAccountId,
        referencedTable: $db.bankAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BankAccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.bankAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> purchasesRefs<T extends Object>(
      Expression<T> Function($$PurchasesTableAnnotationComposer a) f) {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.purchases,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchasesTableAnnotationComposer(
              $db: $db,
              $table: $db.purchases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> depositsRefs<T extends Object>(
      Expression<T> Function($$DepositsTableAnnotationComposer a) f) {
    final $$DepositsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.deposits,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DepositsTableAnnotationComposer(
              $db: $db,
              $table: $db.deposits,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool projectId,
        bool workerId,
        bool expenseCategoryId,
        bool bankAccountId,
        bool purchasesRefs,
        bool depositsRefs})> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<int?> workerId = const Value.absent(),
            Value<int?> expenseCategoryId = const Value.absent(),
            Value<int?> bankAccountId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<TransactionType> type = const Value.absent(),
            Value<bool> affectsPnl = const Value.absent(),
            Value<bool> affectsCash = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<PaymentMode?> paymentMode = const Value.absent(),
            Value<String?> narration = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            projectId: projectId,
            workerId: workerId,
            expenseCategoryId: expenseCategoryId,
            bankAccountId: bankAccountId,
            date: date,
            type: type,
            affectsPnl: affectsPnl,
            affectsCash: affectsCash,
            amount: amount,
            paymentMode: paymentMode,
            narration: narration,
            referenceNo: referenceNo,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int projectId,
            Value<int?> workerId = const Value.absent(),
            Value<int?> expenseCategoryId = const Value.absent(),
            Value<int?> bankAccountId = const Value.absent(),
            required DateTime date,
            required TransactionType type,
            Value<bool> affectsPnl = const Value.absent(),
            Value<bool> affectsCash = const Value.absent(),
            required double amount,
            Value<PaymentMode?> paymentMode = const Value.absent(),
            Value<String?> narration = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            projectId: projectId,
            workerId: workerId,
            expenseCategoryId: expenseCategoryId,
            bankAccountId: bankAccountId,
            date: date,
            type: type,
            affectsPnl: affectsPnl,
            affectsCash: affectsCash,
            amount: amount,
            paymentMode: paymentMode,
            narration: narration,
            referenceNo: referenceNo,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {projectId = false,
              workerId = false,
              expenseCategoryId = false,
              bankAccountId = false,
              purchasesRefs = false,
              depositsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (purchasesRefs) db.purchases,
                if (depositsRefs) db.deposits
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$TransactionsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._projectIdTable(db).id,
                  ) as T;
                }
                if (workerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workerId,
                    referencedTable:
                        $$TransactionsTableReferences._workerIdTable(db),
                    referencedColumn:
                        $$TransactionsTableReferences._workerIdTable(db).id,
                  ) as T;
                }
                if (expenseCategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.expenseCategoryId,
                    referencedTable: $$TransactionsTableReferences
                        ._expenseCategoryIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._expenseCategoryIdTable(db)
                        .id,
                  ) as T;
                }
                if (bankAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bankAccountId,
                    referencedTable:
                        $$TransactionsTableReferences._bankAccountIdTable(db),
                    referencedColumn: $$TransactionsTableReferences
                        ._bankAccountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (purchasesRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            Purchase>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._purchasesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .purchasesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (depositsRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            Deposit>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._depositsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .depositsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (Transaction, $$TransactionsTableReferences),
    Transaction,
    PrefetchHooks Function(
        {bool projectId,
        bool workerId,
        bool expenseCategoryId,
        bool bankAccountId,
        bool purchasesRefs,
        bool depositsRefs})>;
typedef $$VendorsTableCreateCompanionBuilder = VendorsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> contact,
});
typedef $$VendorsTableUpdateCompanionBuilder = VendorsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> contact,
});

final class $$VendorsTableReferences
    extends BaseReferences<_$AppDatabase, $VendorsTable, Vendor> {
  $$VendorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PurchasesTable, List<Purchase>>
      _purchasesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.purchases,
              aliasName:
                  $_aliasNameGenerator(db.vendors.id, db.purchases.vendorId));

  $$PurchasesTableProcessedTableManager get purchasesRefs {
    final manager = $$PurchasesTableTableManager($_db, $_db.purchases)
        .filter((f) => f.vendorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchasesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VendorsTableFilterComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnFilters(column));

  Expression<bool> purchasesRefs(
      Expression<bool> Function($$PurchasesTableFilterComposer f) f) {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.purchases,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchasesTableFilterComposer(
              $db: $db,
              $table: $db.purchases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VendorsTableOrderingComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnOrderings(column));
}

class $$VendorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  Expression<T> purchasesRefs<T extends Object>(
      Expression<T> Function($$PurchasesTableAnnotationComposer a) f) {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.purchases,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PurchasesTableAnnotationComposer(
              $db: $db,
              $table: $db.purchases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VendorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VendorsTable,
    Vendor,
    $$VendorsTableFilterComposer,
    $$VendorsTableOrderingComposer,
    $$VendorsTableAnnotationComposer,
    $$VendorsTableCreateCompanionBuilder,
    $$VendorsTableUpdateCompanionBuilder,
    (Vendor, $$VendorsTableReferences),
    Vendor,
    PrefetchHooks Function({bool purchasesRefs})> {
  $$VendorsTableTableManager(_$AppDatabase db, $VendorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> contact = const Value.absent(),
          }) =>
              VendorsCompanion(
            id: id,
            name: name,
            contact: contact,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> contact = const Value.absent(),
          }) =>
              VendorsCompanion.insert(
            id: id,
            name: name,
            contact: contact,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VendorsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({purchasesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (purchasesRefs) db.purchases],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (purchasesRefs)
                    await $_getPrefetchedData<Vendor, $VendorsTable, Purchase>(
                        currentTable: table,
                        referencedTable:
                            $$VendorsTableReferences._purchasesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VendorsTableReferences(db, table, p0)
                                .purchasesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.vendorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VendorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VendorsTable,
    Vendor,
    $$VendorsTableFilterComposer,
    $$VendorsTableOrderingComposer,
    $$VendorsTableAnnotationComposer,
    $$VendorsTableCreateCompanionBuilder,
    $$VendorsTableUpdateCompanionBuilder,
    (Vendor, $$VendorsTableReferences),
    Vendor,
    PrefetchHooks Function({bool purchasesRefs})>;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  Value<int> id,
  required int transactionId,
  required int vendorId,
  required String itemDescription,
  Value<double> quantity,
  Value<double> unitRate,
  Value<String?> unit,
  Value<double> paidAmount,
  required PaymentStatus paymentStatus,
  Value<bool> isAdvanceStock,
  Value<double> allocatedAmount,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> vendorId,
  Value<String> itemDescription,
  Value<double> quantity,
  Value<double> unitRate,
  Value<String?> unit,
  Value<double> paidAmount,
  Value<PaymentStatus> paymentStatus,
  Value<bool> isAdvanceStock,
  Value<double> allocatedAmount,
});

final class $$PurchasesTableReferences
    extends BaseReferences<_$AppDatabase, $PurchasesTable, Purchase> {
  $$PurchasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
          $_aliasNameGenerator(db.purchases.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $VendorsTable _vendorIdTable(_$AppDatabase db) => db.vendors
      .createAlias($_aliasNameGenerator(db.purchases.vendorId, db.vendors.id));

  $$VendorsTableProcessedTableManager get vendorId {
    final $_column = $_itemColumn<int>('vendor_id')!;

    final manager = $$VendorsTableTableManager($_db, $_db.vendors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemDescription => $composableBuilder(
      column: $table.itemDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitRate => $composableBuilder(
      column: $table.unitRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentStatus, PaymentStatus, String>
      get paymentStatus => $composableBuilder(
          column: $table.paymentStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isAdvanceStock => $composableBuilder(
      column: $table.isAdvanceStock,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount,
      builder: (column) => ColumnFilters(column));

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorsTableFilterComposer get vendorId {
    final $$VendorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableFilterComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemDescription => $composableBuilder(
      column: $table.itemDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitRate => $composableBuilder(
      column: $table.unitRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAdvanceStock => $composableBuilder(
      column: $table.isAdvanceStock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount,
      builder: (column) => ColumnOrderings(column));

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorsTableOrderingComposer get vendorId {
    final $$VendorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableOrderingComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemDescription => $composableBuilder(
      column: $table.itemDescription, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitRate =>
      $composableBuilder(column: $table.unitRate, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentStatus, String> get paymentStatus =>
      $composableBuilder(
          column: $table.paymentStatus, builder: (column) => column);

  GeneratedColumn<bool> get isAdvanceStock => $composableBuilder(
      column: $table.isAdvanceStock, builder: (column) => column);

  GeneratedColumn<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$VendorsTableAnnotationComposer get vendorId {
    final $$VendorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.vendorId,
        referencedTable: $db.vendors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VendorsTableAnnotationComposer(
              $db: $db,
              $table: $db.vendors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PurchasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (Purchase, $$PurchasesTableReferences),
    Purchase,
    PrefetchHooks Function({bool transactionId, bool vendorId})> {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<int> vendorId = const Value.absent(),
            Value<String> itemDescription = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> unitRate = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<PaymentStatus> paymentStatus = const Value.absent(),
            Value<bool> isAdvanceStock = const Value.absent(),
            Value<double> allocatedAmount = const Value.absent(),
          }) =>
              PurchasesCompanion(
            id: id,
            transactionId: transactionId,
            vendorId: vendorId,
            itemDescription: itemDescription,
            quantity: quantity,
            unitRate: unitRate,
            unit: unit,
            paidAmount: paidAmount,
            paymentStatus: paymentStatus,
            isAdvanceStock: isAdvanceStock,
            allocatedAmount: allocatedAmount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int vendorId,
            required String itemDescription,
            Value<double> quantity = const Value.absent(),
            Value<double> unitRate = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            required PaymentStatus paymentStatus,
            Value<bool> isAdvanceStock = const Value.absent(),
            Value<double> allocatedAmount = const Value.absent(),
          }) =>
              PurchasesCompanion.insert(
            id: id,
            transactionId: transactionId,
            vendorId: vendorId,
            itemDescription: itemDescription,
            quantity: quantity,
            unitRate: unitRate,
            unit: unit,
            paidAmount: paidAmount,
            paymentStatus: paymentStatus,
            isAdvanceStock: isAdvanceStock,
            allocatedAmount: allocatedAmount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PurchasesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({transactionId = false, vendorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable:
                        $$PurchasesTableReferences._transactionIdTable(db),
                    referencedColumn:
                        $$PurchasesTableReferences._transactionIdTable(db).id,
                  ) as T;
                }
                if (vendorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vendorId,
                    referencedTable:
                        $$PurchasesTableReferences._vendorIdTable(db),
                    referencedColumn:
                        $$PurchasesTableReferences._vendorIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PurchasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (Purchase, $$PurchasesTableReferences),
    Purchase,
    PrefetchHooks Function({bool transactionId, bool vendorId})>;
typedef $$AttendanceTableCreateCompanionBuilder = AttendanceCompanion Function({
  Value<int> id,
  required int workerId,
  required int projectId,
  required DateTime date,
  required AttendanceStatus status,
});
typedef $$AttendanceTableUpdateCompanionBuilder = AttendanceCompanion Function({
  Value<int> id,
  Value<int> workerId,
  Value<int> projectId,
  Value<DateTime> date,
  Value<AttendanceStatus> status,
});

final class $$AttendanceTableReferences
    extends BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData> {
  $$AttendanceTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkersTable _workerIdTable(_$AppDatabase db) => db.workers
      .createAlias($_aliasNameGenerator(db.attendance.workerId, db.workers.id));

  $$WorkersTableProcessedTableManager get workerId {
    final $_column = $_itemColumn<int>('worker_id')!;

    final manager = $$WorkersTableTableManager($_db, $_db.workers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.attendance.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AttendanceStatus, AttendanceStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$WorkersTableFilterComposer get workerId {
    final $$WorkersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workerId,
        referencedTable: $db.workers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkersTableFilterComposer(
              $db: $db,
              $table: $db.workers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  $$WorkersTableOrderingComposer get workerId {
    final $$WorkersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workerId,
        referencedTable: $db.workers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkersTableOrderingComposer(
              $db: $db,
              $table: $db.workers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AttendanceStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$WorkersTableAnnotationComposer get workerId {
    final $$WorkersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workerId,
        referencedTable: $db.workers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkersTableAnnotationComposer(
              $db: $db,
              $table: $db.workers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AttendanceTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttendanceTable,
    AttendanceData,
    $$AttendanceTableFilterComposer,
    $$AttendanceTableOrderingComposer,
    $$AttendanceTableAnnotationComposer,
    $$AttendanceTableCreateCompanionBuilder,
    $$AttendanceTableUpdateCompanionBuilder,
    (AttendanceData, $$AttendanceTableReferences),
    AttendanceData,
    PrefetchHooks Function({bool workerId, bool projectId})> {
  $$AttendanceTableTableManager(_$AppDatabase db, $AttendanceTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workerId = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<AttendanceStatus> status = const Value.absent(),
          }) =>
              AttendanceCompanion(
            id: id,
            workerId: workerId,
            projectId: projectId,
            date: date,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workerId,
            required int projectId,
            required DateTime date,
            required AttendanceStatus status,
          }) =>
              AttendanceCompanion.insert(
            id: id,
            workerId: workerId,
            projectId: projectId,
            date: date,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttendanceTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workerId = false, projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (workerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workerId,
                    referencedTable:
                        $$AttendanceTableReferences._workerIdTable(db),
                    referencedColumn:
                        $$AttendanceTableReferences._workerIdTable(db).id,
                  ) as T;
                }
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$AttendanceTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$AttendanceTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AttendanceTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttendanceTable,
    AttendanceData,
    $$AttendanceTableFilterComposer,
    $$AttendanceTableOrderingComposer,
    $$AttendanceTableAnnotationComposer,
    $$AttendanceTableCreateCompanionBuilder,
    $$AttendanceTableUpdateCompanionBuilder,
    (AttendanceData, $$AttendanceTableReferences),
    AttendanceData,
    PrefetchHooks Function({bool workerId, bool projectId})>;
typedef $$DepositsTableCreateCompanionBuilder = DepositsCompanion Function({
  Value<int> id,
  required int transactionId,
  required int projectId,
  Value<DepositType> depositType,
  required DepositStatus status,
  Value<double> adjustedAmount,
  Value<String?> adjustmentReference,
});
typedef $$DepositsTableUpdateCompanionBuilder = DepositsCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> projectId,
  Value<DepositType> depositType,
  Value<DepositStatus> status,
  Value<double> adjustedAmount,
  Value<String?> adjustmentReference,
});

final class $$DepositsTableReferences
    extends BaseReferences<_$AppDatabase, $DepositsTable, Deposit> {
  $$DepositsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias(
          $_aliasNameGenerator(db.deposits.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.deposits.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DepositsTableFilterComposer
    extends Composer<_$AppDatabase, $DepositsTable> {
  $$DepositsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DepositType, DepositType, String>
      get depositType => $composableBuilder(
          column: $table.depositType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DepositStatus, DepositStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get adjustedAmount => $composableBuilder(
      column: $table.adjustedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adjustmentReference => $composableBuilder(
      column: $table.adjustmentReference,
      builder: (column) => ColumnFilters(column));

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableFilterComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableFilterComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DepositsTableOrderingComposer
    extends Composer<_$AppDatabase, $DepositsTable> {
  $$DepositsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get depositType => $composableBuilder(
      column: $table.depositType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get adjustedAmount => $composableBuilder(
      column: $table.adjustedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adjustmentReference => $composableBuilder(
      column: $table.adjustmentReference,
      builder: (column) => ColumnOrderings(column));

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableOrderingComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableOrderingComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DepositsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DepositsTable> {
  $$DepositsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DepositType, String> get depositType =>
      $composableBuilder(
          column: $table.depositType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DepositStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get adjustedAmount => $composableBuilder(
      column: $table.adjustedAmount, builder: (column) => column);

  GeneratedColumn<String> get adjustmentReference => $composableBuilder(
      column: $table.adjustmentReference, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.transactionId,
        referencedTable: $db.transactions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TransactionsTableAnnotationComposer(
              $db: $db,
              $table: $db.transactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.projects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DepositsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DepositsTable,
    Deposit,
    $$DepositsTableFilterComposer,
    $$DepositsTableOrderingComposer,
    $$DepositsTableAnnotationComposer,
    $$DepositsTableCreateCompanionBuilder,
    $$DepositsTableUpdateCompanionBuilder,
    (Deposit, $$DepositsTableReferences),
    Deposit,
    PrefetchHooks Function({bool transactionId, bool projectId})> {
  $$DepositsTableTableManager(_$AppDatabase db, $DepositsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DepositsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DepositsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DepositsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<DepositType> depositType = const Value.absent(),
            Value<DepositStatus> status = const Value.absent(),
            Value<double> adjustedAmount = const Value.absent(),
            Value<String?> adjustmentReference = const Value.absent(),
          }) =>
              DepositsCompanion(
            id: id,
            transactionId: transactionId,
            projectId: projectId,
            depositType: depositType,
            status: status,
            adjustedAmount: adjustedAmount,
            adjustmentReference: adjustmentReference,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int projectId,
            Value<DepositType> depositType = const Value.absent(),
            required DepositStatus status,
            Value<double> adjustedAmount = const Value.absent(),
            Value<String?> adjustmentReference = const Value.absent(),
          }) =>
              DepositsCompanion.insert(
            id: id,
            transactionId: transactionId,
            projectId: projectId,
            depositType: depositType,
            status: status,
            adjustedAmount: adjustedAmount,
            adjustmentReference: adjustmentReference,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$DepositsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({transactionId = false, projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable:
                        $$DepositsTableReferences._transactionIdTable(db),
                    referencedColumn:
                        $$DepositsTableReferences._transactionIdTable(db).id,
                  ) as T;
                }
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$DepositsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$DepositsTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DepositsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DepositsTable,
    Deposit,
    $$DepositsTableFilterComposer,
    $$DepositsTableOrderingComposer,
    $$DepositsTableAnnotationComposer,
    $$DepositsTableCreateCompanionBuilder,
    $$DepositsTableUpdateCompanionBuilder,
    (Deposit, $$DepositsTableReferences),
    Deposit,
    PrefetchHooks Function({bool transactionId, bool projectId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$WorkersTableTableManager get workers =>
      $$WorkersTableTableManager(_db, _db.workers);
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(_db, _db.expenseCategories);
  $$BankAccountsTableTableManager get bankAccounts =>
      $$BankAccountsTableTableManager(_db, _db.bankAccounts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$VendorsTableTableManager get vendors =>
      $$VendorsTableTableManager(_db, _db.vendors);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db, _db.attendance);
  $$DepositsTableTableManager get deposits =>
      $$DepositsTableTableManager(_db, _db.deposits);
}
