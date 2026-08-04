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
        date,
        type,
        affectsPnl,
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
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      type: $TransactionsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      affectsPnl: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}affects_pnl'])!,
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
  final DateTime date;
  final TransactionType type;

  /// FALSE for deposit / depositRefund transactions — they are liabilities,
  /// not income. TRUE for income/expense/purchase/labourPayment.
  final bool affectsPnl;
  final double amount;
  final PaymentMode? paymentMode;
  final String? narration;
  final String? referenceNo;
  final DateTime createdAt;
  const Transaction(
      {required this.id,
      required this.projectId,
      required this.date,
      required this.type,
      required this.affectsPnl,
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
    map['date'] = Variable<DateTime>(date);
    {
      map['type'] =
          Variable<String>($TransactionsTable.$convertertype.toSql(type));
    }
    map['affects_pnl'] = Variable<bool>(affectsPnl);
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
      date: Value(date),
      type: Value(type),
      affectsPnl: Value(affectsPnl),
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
      date: serializer.fromJson<DateTime>(json['date']),
      type: $TransactionsTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      affectsPnl: serializer.fromJson<bool>(json['affectsPnl']),
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
      'date': serializer.toJson<DateTime>(date),
      'type': serializer
          .toJson<String>($TransactionsTable.$convertertype.toJson(type)),
      'affectsPnl': serializer.toJson<bool>(affectsPnl),
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
          DateTime? date,
          TransactionType? type,
          bool? affectsPnl,
          double? amount,
          Value<PaymentMode?> paymentMode = const Value.absent(),
          Value<String?> narration = const Value.absent(),
          Value<String?> referenceNo = const Value.absent(),
          DateTime? createdAt}) =>
      Transaction(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        date: date ?? this.date,
        type: type ?? this.type,
        affectsPnl: affectsPnl ?? this.affectsPnl,
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
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      affectsPnl:
          data.affectsPnl.present ? data.affectsPnl.value : this.affectsPnl,
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
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('affectsPnl: $affectsPnl, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('narration: $narration, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, date, type, affectsPnl, amount,
      paymentMode, narration, referenceNo, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.date == this.date &&
          other.type == this.type &&
          other.affectsPnl == this.affectsPnl &&
          other.amount == this.amount &&
          other.paymentMode == this.paymentMode &&
          other.narration == this.narration &&
          other.referenceNo == this.referenceNo &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<DateTime> date;
  final Value<TransactionType> type;
  final Value<bool> affectsPnl;
  final Value<double> amount;
  final Value<PaymentMode?> paymentMode;
  final Value<String?> narration;
  final Value<String?> referenceNo;
  final Value<DateTime> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.affectsPnl = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.narration = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required DateTime date,
    required TransactionType type,
    this.affectsPnl = const Value.absent(),
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
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<bool>? affectsPnl,
    Expression<double>? amount,
    Expression<String>? paymentMode,
    Expression<String>? narration,
    Expression<String>? referenceNo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (affectsPnl != null) 'affects_pnl': affectsPnl,
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
      Value<DateTime>? date,
      Value<TransactionType>? type,
      Value<bool>? affectsPnl,
      Value<double>? amount,
      Value<PaymentMode?>? paymentMode,
      Value<String?>? narration,
      Value<String?>? referenceNo,
      Value<DateTime>? createdAt}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      type: type ?? this.type,
      affectsPnl: affectsPnl ?? this.affectsPnl,
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
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('affectsPnl: $affectsPnl, ')
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
  @override
  late final GeneratedColumnWithTypeConverter<PaymentStatus, String>
      paymentStatus = GeneratedColumn<String>(
              'payment_status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PaymentStatus>(
              $PurchasesTable.$converterpaymentStatus);
  @override
  List<GeneratedColumn> get $columns =>
      [id, transactionId, vendorId, itemDescription, paymentStatus];
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
      paymentStatus: $PurchasesTable.$converterpaymentStatus.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}payment_status'])!),
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
  final PaymentStatus paymentStatus;
  const Purchase(
      {required this.id,
      required this.transactionId,
      required this.vendorId,
      required this.itemDescription,
      required this.paymentStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['vendor_id'] = Variable<int>(vendorId);
    map['item_description'] = Variable<String>(itemDescription);
    {
      map['payment_status'] = Variable<String>(
          $PurchasesTable.$converterpaymentStatus.toSql(paymentStatus));
    }
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      vendorId: Value(vendorId),
      itemDescription: Value(itemDescription),
      paymentStatus: Value(paymentStatus),
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
      paymentStatus: $PurchasesTable.$converterpaymentStatus
          .fromJson(serializer.fromJson<String>(json['paymentStatus'])),
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
      'paymentStatus': serializer.toJson<String>(
          $PurchasesTable.$converterpaymentStatus.toJson(paymentStatus)),
    };
  }

  Purchase copyWith(
          {int? id,
          int? transactionId,
          int? vendorId,
          String? itemDescription,
          PaymentStatus? paymentStatus}) =>
      Purchase(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        vendorId: vendorId ?? this.vendorId,
        itemDescription: itemDescription ?? this.itemDescription,
        paymentStatus: paymentStatus ?? this.paymentStatus,
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
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('vendorId: $vendorId, ')
          ..write('itemDescription: $itemDescription, ')
          ..write('paymentStatus: $paymentStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, transactionId, vendorId, itemDescription, paymentStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.vendorId == this.vendorId &&
          other.itemDescription == this.itemDescription &&
          other.paymentStatus == this.paymentStatus);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> vendorId;
  final Value<String> itemDescription;
  final Value<PaymentStatus> paymentStatus;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.itemDescription = const Value.absent(),
    this.paymentStatus = const Value.absent(),
  });
  PurchasesCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int vendorId,
    required String itemDescription,
    required PaymentStatus paymentStatus,
  })  : transactionId = Value(transactionId),
        vendorId = Value(vendorId),
        itemDescription = Value(itemDescription),
        paymentStatus = Value(paymentStatus);
  static Insertable<Purchase> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? vendorId,
    Expression<String>? itemDescription,
    Expression<String>? paymentStatus,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (vendorId != null) 'vendor_id': vendorId,
      if (itemDescription != null) 'item_description': itemDescription,
      if (paymentStatus != null) 'payment_status': paymentStatus,
    });
  }

  PurchasesCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int>? vendorId,
      Value<String>? itemDescription,
      Value<PaymentStatus>? paymentStatus}) {
    return PurchasesCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      vendorId: vendorId ?? this.vendorId,
      itemDescription: itemDescription ?? this.itemDescription,
      paymentStatus: paymentStatus ?? this.paymentStatus,
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
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(
          $PurchasesTable.$converterpaymentStatus.toSql(paymentStatus.value));
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
          ..write('paymentStatus: $paymentStatus')
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
  static const VerificationMeta _dailyRateMeta =
      const VerificationMeta('dailyRate');
  @override
  late final GeneratedColumn<double> dailyRate = GeneratedColumn<double>(
      'daily_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [id, name, workerCode, dailyRate];
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
  final double dailyRate;
  const Worker(
      {required this.id,
      required this.name,
      this.workerCode,
      required this.dailyRate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || workerCode != null) {
      map['worker_code'] = Variable<String>(workerCode);
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
      'dailyRate': serializer.toJson<double>(dailyRate),
    };
  }

  Worker copyWith(
          {int? id,
          String? name,
          Value<String?> workerCode = const Value.absent(),
          double? dailyRate}) =>
      Worker(
        id: id ?? this.id,
        name: name ?? this.name,
        workerCode: workerCode.present ? workerCode.value : this.workerCode,
        dailyRate: dailyRate ?? this.dailyRate,
      );
  Worker copyWithCompanion(WorkersCompanion data) {
    return Worker(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      workerCode:
          data.workerCode.present ? data.workerCode.value : this.workerCode,
      dailyRate: data.dailyRate.present ? data.dailyRate.value : this.dailyRate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Worker(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('workerCode: $workerCode, ')
          ..write('dailyRate: $dailyRate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, workerCode, dailyRate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Worker &&
          other.id == this.id &&
          other.name == this.name &&
          other.workerCode == this.workerCode &&
          other.dailyRate == this.dailyRate);
}

class WorkersCompanion extends UpdateCompanion<Worker> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> workerCode;
  final Value<double> dailyRate;
  const WorkersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.workerCode = const Value.absent(),
    this.dailyRate = const Value.absent(),
  });
  WorkersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.workerCode = const Value.absent(),
    this.dailyRate = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Worker> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? workerCode,
    Expression<double>? dailyRate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (workerCode != null) 'worker_code': workerCode,
      if (dailyRate != null) 'daily_rate': dailyRate,
    });
  }

  WorkersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? workerCode,
      Value<double>? dailyRate}) {
    return WorkersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      workerCode: workerCode ?? this.workerCode,
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
          ..write('dailyRate: $dailyRate')
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

  static JsonTypeConverter2<DepositStatus, String, String> $converterstatus =
      const EnumNameConverter<DepositStatus>(DepositStatus.values);
}

class Deposit extends DataClass implements Insertable<Deposit> {
  final int id;
  final int transactionId;
  final int projectId;
  final DepositStatus status;

  /// Total portion of this deposit adjusted to income so far.
  final double adjustedAmount;

  /// Invoice / work-order reference the deposit was applied against.
  final String? adjustmentReference;
  const Deposit(
      {required this.id,
      required this.transactionId,
      required this.projectId,
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
          DepositStatus? status,
          double? adjustedAmount,
          Value<String?> adjustmentReference = const Value.absent()}) =>
      Deposit(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        projectId: projectId ?? this.projectId,
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
          ..write('status: $status, ')
          ..write('adjustedAmount: $adjustedAmount, ')
          ..write('adjustmentReference: $adjustmentReference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, projectId, status,
      adjustedAmount, adjustmentReference);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deposit &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.projectId == this.projectId &&
          other.status == this.status &&
          other.adjustedAmount == this.adjustedAmount &&
          other.adjustmentReference == this.adjustmentReference);
}

class DepositsCompanion extends UpdateCompanion<Deposit> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> projectId;
  final Value<DepositStatus> status;
  final Value<double> adjustedAmount;
  final Value<String?> adjustmentReference;
  const DepositsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.status = const Value.absent(),
    this.adjustedAmount = const Value.absent(),
    this.adjustmentReference = const Value.absent(),
  });
  DepositsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int projectId,
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
    Expression<String>? status,
    Expression<double>? adjustedAmount,
    Expression<String>? adjustmentReference,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (projectId != null) 'project_id': projectId,
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
      Value<DepositStatus>? status,
      Value<double>? adjustedAmount,
      Value<String?>? adjustmentReference}) {
    return DepositsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      projectId: projectId ?? this.projectId,
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
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $VendorsTable vendors = $VendorsTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $WorkersTable workers = $WorkersTable(this);
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $DepositsTable deposits = $DepositsTable(this);
  late final ProjectDao projectDao = ProjectDao(this as AppDatabase);
  late final TransactionDao transactionDao =
      TransactionDao(this as AppDatabase);
  late final PurchaseDao purchaseDao = PurchaseDao(this as AppDatabase);
  late final LabourDao labourDao = LabourDao(this as AppDatabase);
  late final DepositDao depositDao = DepositDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        projects,
        transactions,
        vendors,
        purchases,
        workers,
        attendance,
        deposits
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
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
typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required int projectId,
  required DateTime date,
  required TransactionType type,
  Value<bool> affectsPnl,
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
  Value<DateTime> date,
  Value<TransactionType> type,
  Value<bool> affectsPnl,
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
        {bool projectId, bool purchasesRefs, bool depositsRefs})> {
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
            Value<DateTime> date = const Value.absent(),
            Value<TransactionType> type = const Value.absent(),
            Value<bool> affectsPnl = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<PaymentMode?> paymentMode = const Value.absent(),
            Value<String?> narration = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            projectId: projectId,
            date: date,
            type: type,
            affectsPnl: affectsPnl,
            amount: amount,
            paymentMode: paymentMode,
            narration: narration,
            referenceNo: referenceNo,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int projectId,
            required DateTime date,
            required TransactionType type,
            Value<bool> affectsPnl = const Value.absent(),
            required double amount,
            Value<PaymentMode?> paymentMode = const Value.absent(),
            Value<String?> narration = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            projectId: projectId,
            date: date,
            type: type,
            affectsPnl: affectsPnl,
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
        {bool projectId, bool purchasesRefs, bool depositsRefs})>;
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
  required PaymentStatus paymentStatus,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> vendorId,
  Value<String> itemDescription,
  Value<PaymentStatus> paymentStatus,
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

  ColumnWithTypeConverterFilters<PaymentStatus, PaymentStatus, String>
      get paymentStatus => $composableBuilder(
          column: $table.paymentStatus,
          builder: (column) => ColumnWithTypeConverterFilters(column));

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

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
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

  GeneratedColumnWithTypeConverter<PaymentStatus, String> get paymentStatus =>
      $composableBuilder(
          column: $table.paymentStatus, builder: (column) => column);

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
            Value<PaymentStatus> paymentStatus = const Value.absent(),
          }) =>
              PurchasesCompanion(
            id: id,
            transactionId: transactionId,
            vendorId: vendorId,
            itemDescription: itemDescription,
            paymentStatus: paymentStatus,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int vendorId,
            required String itemDescription,
            required PaymentStatus paymentStatus,
          }) =>
              PurchasesCompanion.insert(
            id: id,
            transactionId: transactionId,
            vendorId: vendorId,
            itemDescription: itemDescription,
            paymentStatus: paymentStatus,
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
typedef $$WorkersTableCreateCompanionBuilder = WorkersCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> workerCode,
  Value<double> dailyRate,
});
typedef $$WorkersTableUpdateCompanionBuilder = WorkersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> workerCode,
  Value<double> dailyRate,
});

final class $$WorkersTableReferences
    extends BaseReferences<_$AppDatabase, $WorkersTable, Worker> {
  $$WorkersTableReferences(super.$_db, super.$_table, super.$_typedResult);

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

  ColumnFilters<double> get dailyRate => $composableBuilder(
      column: $table.dailyRate, builder: (column) => ColumnFilters(column));

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

  GeneratedColumn<double> get dailyRate =>
      $composableBuilder(column: $table.dailyRate, builder: (column) => column);

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
    PrefetchHooks Function({bool attendanceRefs})> {
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
            Value<double> dailyRate = const Value.absent(),
          }) =>
              WorkersCompanion(
            id: id,
            name: name,
            workerCode: workerCode,
            dailyRate: dailyRate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> workerCode = const Value.absent(),
            Value<double> dailyRate = const Value.absent(),
          }) =>
              WorkersCompanion.insert(
            id: id,
            name: name,
            workerCode: workerCode,
            dailyRate: dailyRate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WorkersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({attendanceRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (attendanceRefs) db.attendance],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
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
    PrefetchHooks Function({bool attendanceRefs})>;
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
  required DepositStatus status,
  Value<double> adjustedAmount,
  Value<String?> adjustmentReference,
});
typedef $$DepositsTableUpdateCompanionBuilder = DepositsCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> projectId,
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
            Value<DepositStatus> status = const Value.absent(),
            Value<double> adjustedAmount = const Value.absent(),
            Value<String?> adjustmentReference = const Value.absent(),
          }) =>
              DepositsCompanion(
            id: id,
            transactionId: transactionId,
            projectId: projectId,
            status: status,
            adjustedAmount: adjustedAmount,
            adjustmentReference: adjustmentReference,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int projectId,
            required DepositStatus status,
            Value<double> adjustedAmount = const Value.absent(),
            Value<String?> adjustmentReference = const Value.absent(),
          }) =>
              DepositsCompanion.insert(
            id: id,
            transactionId: transactionId,
            projectId: projectId,
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
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$VendorsTableTableManager get vendors =>
      $$VendorsTableTableManager(_db, _db.vendors);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$WorkersTableTableManager get workers =>
      $$WorkersTableTableManager(_db, _db.workers);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db, _db.attendance);
  $$DepositsTableTableManager get deposits =>
      $$DepositsTableTableManager(_db, _db.deposits);
}
