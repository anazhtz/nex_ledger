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
  static const VerificationMeta _clientContractValueMeta =
      const VerificationMeta('clientContractValue');
  @override
  late final GeneratedColumn<double> clientContractValue =
      GeneratedColumn<double>('client_contract_value', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _clientRetentionPercentageMeta =
      const VerificationMeta('clientRetentionPercentage');
  @override
  late final GeneratedColumn<double> clientRetentionPercentage =
      GeneratedColumn<double>('client_retention_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(5.0));
  static const VerificationMeta _clientContactMeta =
      const VerificationMeta('clientContact');
  @override
  late final GeneratedColumn<String> clientContact = GeneratedColumn<String>(
      'client_contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientAddressMeta =
      const VerificationMeta('clientAddress');
  @override
  late final GeneratedColumn<String> clientAddress = GeneratedColumn<String>(
      'client_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientGstOrPanMeta =
      const VerificationMeta('clientGstOrPan');
  @override
  late final GeneratedColumn<String> clientGstOrPan = GeneratedColumn<String>(
      'client_gst_or_pan', aliasedName, true,
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
        code,
        name,
        clientName,
        type,
        status,
        startDate,
        budget,
        clientContractValue,
        clientRetentionPercentage,
        clientContact,
        clientAddress,
        clientGstOrPan,
        createdAt
      ];
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
    if (data.containsKey('client_contract_value')) {
      context.handle(
          _clientContractValueMeta,
          clientContractValue.isAcceptableOrUnknown(
              data['client_contract_value']!, _clientContractValueMeta));
    }
    if (data.containsKey('client_retention_percentage')) {
      context.handle(
          _clientRetentionPercentageMeta,
          clientRetentionPercentage.isAcceptableOrUnknown(
              data['client_retention_percentage']!,
              _clientRetentionPercentageMeta));
    }
    if (data.containsKey('client_contact')) {
      context.handle(
          _clientContactMeta,
          clientContact.isAcceptableOrUnknown(
              data['client_contact']!, _clientContactMeta));
    }
    if (data.containsKey('client_address')) {
      context.handle(
          _clientAddressMeta,
          clientAddress.isAcceptableOrUnknown(
              data['client_address']!, _clientAddressMeta));
    }
    if (data.containsKey('client_gst_or_pan')) {
      context.handle(
          _clientGstOrPanMeta,
          clientGstOrPan.isAcceptableOrUnknown(
              data['client_gst_or_pan']!, _clientGstOrPanMeta));
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
      clientContractValue: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}client_contract_value'])!,
      clientRetentionPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}client_retention_percentage'])!,
      clientContact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_contact']),
      clientAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_address']),
      clientGstOrPan: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_gst_or_pan']),
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
  final double clientContractValue;
  final double clientRetentionPercentage;
  final String? clientContact;
  final String? clientAddress;
  final String? clientGstOrPan;
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
      required this.clientContractValue,
      required this.clientRetentionPercentage,
      this.clientContact,
      this.clientAddress,
      this.clientGstOrPan,
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
    map['client_contract_value'] = Variable<double>(clientContractValue);
    map['client_retention_percentage'] =
        Variable<double>(clientRetentionPercentage);
    if (!nullToAbsent || clientContact != null) {
      map['client_contact'] = Variable<String>(clientContact);
    }
    if (!nullToAbsent || clientAddress != null) {
      map['client_address'] = Variable<String>(clientAddress);
    }
    if (!nullToAbsent || clientGstOrPan != null) {
      map['client_gst_or_pan'] = Variable<String>(clientGstOrPan);
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
      clientContractValue: Value(clientContractValue),
      clientRetentionPercentage: Value(clientRetentionPercentage),
      clientContact: clientContact == null && nullToAbsent
          ? const Value.absent()
          : Value(clientContact),
      clientAddress: clientAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(clientAddress),
      clientGstOrPan: clientGstOrPan == null && nullToAbsent
          ? const Value.absent()
          : Value(clientGstOrPan),
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
      clientContractValue:
          serializer.fromJson<double>(json['clientContractValue']),
      clientRetentionPercentage:
          serializer.fromJson<double>(json['clientRetentionPercentage']),
      clientContact: serializer.fromJson<String?>(json['clientContact']),
      clientAddress: serializer.fromJson<String?>(json['clientAddress']),
      clientGstOrPan: serializer.fromJson<String?>(json['clientGstOrPan']),
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
      'clientContractValue': serializer.toJson<double>(clientContractValue),
      'clientRetentionPercentage':
          serializer.toJson<double>(clientRetentionPercentage),
      'clientContact': serializer.toJson<String?>(clientContact),
      'clientAddress': serializer.toJson<String?>(clientAddress),
      'clientGstOrPan': serializer.toJson<String?>(clientGstOrPan),
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
          double? clientContractValue,
          double? clientRetentionPercentage,
          Value<String?> clientContact = const Value.absent(),
          Value<String?> clientAddress = const Value.absent(),
          Value<String?> clientGstOrPan = const Value.absent(),
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
        clientContractValue: clientContractValue ?? this.clientContractValue,
        clientRetentionPercentage:
            clientRetentionPercentage ?? this.clientRetentionPercentage,
        clientContact:
            clientContact.present ? clientContact.value : this.clientContact,
        clientAddress:
            clientAddress.present ? clientAddress.value : this.clientAddress,
        clientGstOrPan:
            clientGstOrPan.present ? clientGstOrPan.value : this.clientGstOrPan,
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
      clientContractValue: data.clientContractValue.present
          ? data.clientContractValue.value
          : this.clientContractValue,
      clientRetentionPercentage: data.clientRetentionPercentage.present
          ? data.clientRetentionPercentage.value
          : this.clientRetentionPercentage,
      clientContact: data.clientContact.present
          ? data.clientContact.value
          : this.clientContact,
      clientAddress: data.clientAddress.present
          ? data.clientAddress.value
          : this.clientAddress,
      clientGstOrPan: data.clientGstOrPan.present
          ? data.clientGstOrPan.value
          : this.clientGstOrPan,
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
          ..write('clientContractValue: $clientContractValue, ')
          ..write('clientRetentionPercentage: $clientRetentionPercentage, ')
          ..write('clientContact: $clientContact, ')
          ..write('clientAddress: $clientAddress, ')
          ..write('clientGstOrPan: $clientGstOrPan, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      code,
      name,
      clientName,
      type,
      status,
      startDate,
      budget,
      clientContractValue,
      clientRetentionPercentage,
      clientContact,
      clientAddress,
      clientGstOrPan,
      createdAt);
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
          other.clientContractValue == this.clientContractValue &&
          other.clientRetentionPercentage == this.clientRetentionPercentage &&
          other.clientContact == this.clientContact &&
          other.clientAddress == this.clientAddress &&
          other.clientGstOrPan == this.clientGstOrPan &&
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
  final Value<double> clientContractValue;
  final Value<double> clientRetentionPercentage;
  final Value<String?> clientContact;
  final Value<String?> clientAddress;
  final Value<String?> clientGstOrPan;
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
    this.clientContractValue = const Value.absent(),
    this.clientRetentionPercentage = const Value.absent(),
    this.clientContact = const Value.absent(),
    this.clientAddress = const Value.absent(),
    this.clientGstOrPan = const Value.absent(),
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
    this.clientContractValue = const Value.absent(),
    this.clientRetentionPercentage = const Value.absent(),
    this.clientContact = const Value.absent(),
    this.clientAddress = const Value.absent(),
    this.clientGstOrPan = const Value.absent(),
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
    Expression<double>? clientContractValue,
    Expression<double>? clientRetentionPercentage,
    Expression<String>? clientContact,
    Expression<String>? clientAddress,
    Expression<String>? clientGstOrPan,
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
      if (clientContractValue != null)
        'client_contract_value': clientContractValue,
      if (clientRetentionPercentage != null)
        'client_retention_percentage': clientRetentionPercentage,
      if (clientContact != null) 'client_contact': clientContact,
      if (clientAddress != null) 'client_address': clientAddress,
      if (clientGstOrPan != null) 'client_gst_or_pan': clientGstOrPan,
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
      Value<double>? clientContractValue,
      Value<double>? clientRetentionPercentage,
      Value<String?>? clientContact,
      Value<String?>? clientAddress,
      Value<String?>? clientGstOrPan,
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
      clientContractValue: clientContractValue ?? this.clientContractValue,
      clientRetentionPercentage:
          clientRetentionPercentage ?? this.clientRetentionPercentage,
      clientContact: clientContact ?? this.clientContact,
      clientAddress: clientAddress ?? this.clientAddress,
      clientGstOrPan: clientGstOrPan ?? this.clientGstOrPan,
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
    if (clientContractValue.present) {
      map['client_contract_value'] =
          Variable<double>(clientContractValue.value);
    }
    if (clientRetentionPercentage.present) {
      map['client_retention_percentage'] =
          Variable<double>(clientRetentionPercentage.value);
    }
    if (clientContact.present) {
      map['client_contact'] = Variable<String>(clientContact.value);
    }
    if (clientAddress.present) {
      map['client_address'] = Variable<String>(clientAddress.value);
    }
    if (clientGstOrPan.present) {
      map['client_gst_or_pan'] = Variable<String>(clientGstOrPan.value);
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
          ..write('clientContractValue: $clientContractValue, ')
          ..write('clientRetentionPercentage: $clientRetentionPercentage, ')
          ..write('clientContact: $clientContact, ')
          ..write('clientAddress: $clientAddress, ')
          ..write('clientGstOrPan: $clientGstOrPan, ')
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
  static const VerificationMeta _materialCategoryMeta =
      const VerificationMeta('materialCategory');
  @override
  late final GeneratedColumn<String> materialCategory = GeneratedColumn<String>(
      'material_category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hsnCodeMeta =
      const VerificationMeta('hsnCode');
  @override
  late final GeneratedColumn<String> hsnCode = GeneratedColumn<String>(
      'hsn_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _taxApplicableMeta =
      const VerificationMeta('taxApplicable');
  @override
  late final GeneratedColumn<bool> taxApplicable = GeneratedColumn<bool>(
      'tax_applicable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("tax_applicable" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _gstRateMeta =
      const VerificationMeta('gstRate');
  @override
  late final GeneratedColumn<double> gstRate = GeneratedColumn<double>(
      'gst_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _gstAmountMeta =
      const VerificationMeta('gstAmount');
  @override
  late final GeneratedColumn<double> gstAmount = GeneratedColumn<double>(
      'gst_amount', aliasedName, false,
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
        allocatedAmount,
        materialCategory,
        hsnCode,
        taxApplicable,
        gstRate,
        gstAmount
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
    if (data.containsKey('material_category')) {
      context.handle(
          _materialCategoryMeta,
          materialCategory.isAcceptableOrUnknown(
              data['material_category']!, _materialCategoryMeta));
    }
    if (data.containsKey('hsn_code')) {
      context.handle(_hsnCodeMeta,
          hsnCode.isAcceptableOrUnknown(data['hsn_code']!, _hsnCodeMeta));
    }
    if (data.containsKey('tax_applicable')) {
      context.handle(
          _taxApplicableMeta,
          taxApplicable.isAcceptableOrUnknown(
              data['tax_applicable']!, _taxApplicableMeta));
    }
    if (data.containsKey('gst_rate')) {
      context.handle(_gstRateMeta,
          gstRate.isAcceptableOrUnknown(data['gst_rate']!, _gstRateMeta));
    }
    if (data.containsKey('gst_amount')) {
      context.handle(_gstAmountMeta,
          gstAmount.isAcceptableOrUnknown(data['gst_amount']!, _gstAmountMeta));
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
      materialCategory: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}material_category']),
      hsnCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hsn_code']),
      taxApplicable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}tax_applicable'])!,
      gstRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gst_rate'])!,
      gstAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gst_amount'])!,
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
  final String? materialCategory;
  final String? hsnCode;
  final bool taxApplicable;
  final double gstRate;
  final double gstAmount;
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
      required this.allocatedAmount,
      this.materialCategory,
      this.hsnCode,
      required this.taxApplicable,
      required this.gstRate,
      required this.gstAmount});
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
    if (!nullToAbsent || materialCategory != null) {
      map['material_category'] = Variable<String>(materialCategory);
    }
    if (!nullToAbsent || hsnCode != null) {
      map['hsn_code'] = Variable<String>(hsnCode);
    }
    map['tax_applicable'] = Variable<bool>(taxApplicable);
    map['gst_rate'] = Variable<double>(gstRate);
    map['gst_amount'] = Variable<double>(gstAmount);
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
      materialCategory: materialCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(materialCategory),
      hsnCode: hsnCode == null && nullToAbsent
          ? const Value.absent()
          : Value(hsnCode),
      taxApplicable: Value(taxApplicable),
      gstRate: Value(gstRate),
      gstAmount: Value(gstAmount),
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
      materialCategory: serializer.fromJson<String?>(json['materialCategory']),
      hsnCode: serializer.fromJson<String?>(json['hsnCode']),
      taxApplicable: serializer.fromJson<bool>(json['taxApplicable']),
      gstRate: serializer.fromJson<double>(json['gstRate']),
      gstAmount: serializer.fromJson<double>(json['gstAmount']),
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
      'materialCategory': serializer.toJson<String?>(materialCategory),
      'hsnCode': serializer.toJson<String?>(hsnCode),
      'taxApplicable': serializer.toJson<bool>(taxApplicable),
      'gstRate': serializer.toJson<double>(gstRate),
      'gstAmount': serializer.toJson<double>(gstAmount),
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
          double? allocatedAmount,
          Value<String?> materialCategory = const Value.absent(),
          Value<String?> hsnCode = const Value.absent(),
          bool? taxApplicable,
          double? gstRate,
          double? gstAmount}) =>
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
        materialCategory: materialCategory.present
            ? materialCategory.value
            : this.materialCategory,
        hsnCode: hsnCode.present ? hsnCode.value : this.hsnCode,
        taxApplicable: taxApplicable ?? this.taxApplicable,
        gstRate: gstRate ?? this.gstRate,
        gstAmount: gstAmount ?? this.gstAmount,
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
      materialCategory: data.materialCategory.present
          ? data.materialCategory.value
          : this.materialCategory,
      hsnCode: data.hsnCode.present ? data.hsnCode.value : this.hsnCode,
      taxApplicable: data.taxApplicable.present
          ? data.taxApplicable.value
          : this.taxApplicable,
      gstRate: data.gstRate.present ? data.gstRate.value : this.gstRate,
      gstAmount: data.gstAmount.present ? data.gstAmount.value : this.gstAmount,
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
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('materialCategory: $materialCategory, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('taxApplicable: $taxApplicable, ')
          ..write('gstRate: $gstRate, ')
          ..write('gstAmount: $gstAmount')
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
      allocatedAmount,
      materialCategory,
      hsnCode,
      taxApplicable,
      gstRate,
      gstAmount);
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
          other.allocatedAmount == this.allocatedAmount &&
          other.materialCategory == this.materialCategory &&
          other.hsnCode == this.hsnCode &&
          other.taxApplicable == this.taxApplicable &&
          other.gstRate == this.gstRate &&
          other.gstAmount == this.gstAmount);
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
  final Value<String?> materialCategory;
  final Value<String?> hsnCode;
  final Value<bool> taxApplicable;
  final Value<double> gstRate;
  final Value<double> gstAmount;
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
    this.materialCategory = const Value.absent(),
    this.hsnCode = const Value.absent(),
    this.taxApplicable = const Value.absent(),
    this.gstRate = const Value.absent(),
    this.gstAmount = const Value.absent(),
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
    this.materialCategory = const Value.absent(),
    this.hsnCode = const Value.absent(),
    this.taxApplicable = const Value.absent(),
    this.gstRate = const Value.absent(),
    this.gstAmount = const Value.absent(),
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
    Expression<String>? materialCategory,
    Expression<String>? hsnCode,
    Expression<bool>? taxApplicable,
    Expression<double>? gstRate,
    Expression<double>? gstAmount,
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
      if (materialCategory != null) 'material_category': materialCategory,
      if (hsnCode != null) 'hsn_code': hsnCode,
      if (taxApplicable != null) 'tax_applicable': taxApplicable,
      if (gstRate != null) 'gst_rate': gstRate,
      if (gstAmount != null) 'gst_amount': gstAmount,
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
      Value<double>? allocatedAmount,
      Value<String?>? materialCategory,
      Value<String?>? hsnCode,
      Value<bool>? taxApplicable,
      Value<double>? gstRate,
      Value<double>? gstAmount}) {
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
      materialCategory: materialCategory ?? this.materialCategory,
      hsnCode: hsnCode ?? this.hsnCode,
      taxApplicable: taxApplicable ?? this.taxApplicable,
      gstRate: gstRate ?? this.gstRate,
      gstAmount: gstAmount ?? this.gstAmount,
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
    if (materialCategory.present) {
      map['material_category'] = Variable<String>(materialCategory.value);
    }
    if (hsnCode.present) {
      map['hsn_code'] = Variable<String>(hsnCode.value);
    }
    if (taxApplicable.present) {
      map['tax_applicable'] = Variable<bool>(taxApplicable.value);
    }
    if (gstRate.present) {
      map['gst_rate'] = Variable<double>(gstRate.value);
    }
    if (gstAmount.present) {
      map['gst_amount'] = Variable<double>(gstAmount.value);
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
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('materialCategory: $materialCategory, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('taxApplicable: $taxApplicable, ')
          ..write('gstRate: $gstRate, ')
          ..write('gstAmount: $gstAmount')
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

class $SubcontractorsTable extends Subcontractors
    with TableInfo<$SubcontractorsTable, Subcontractor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubcontractorsTable(this.attachedDatabase, [this._alias]);
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
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 150),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tradeMeta = const VerificationMeta('trade');
  @override
  late final GeneratedColumn<String> trade = GeneratedColumn<String>(
      'trade', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _contactMeta =
      const VerificationMeta('contact');
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
      'contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _panOrGstMeta =
      const VerificationMeta('panOrGst');
  @override
  late final GeneratedColumn<String> panOrGst = GeneratedColumn<String>(
      'pan_or_gst', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
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
  List<GeneratedColumn> get $columns =>
      [id, name, trade, contact, panOrGst, notes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subcontractors';
  @override
  VerificationContext validateIntegrity(Insertable<Subcontractor> instance,
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
    if (data.containsKey('trade')) {
      context.handle(
          _tradeMeta, trade.isAcceptableOrUnknown(data['trade']!, _tradeMeta));
    } else if (isInserting) {
      context.missing(_tradeMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(_contactMeta,
          contact.isAcceptableOrUnknown(data['contact']!, _contactMeta));
    }
    if (data.containsKey('pan_or_gst')) {
      context.handle(_panOrGstMeta,
          panOrGst.isAcceptableOrUnknown(data['pan_or_gst']!, _panOrGstMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
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
  Subcontractor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subcontractor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      trade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trade'])!,
      contact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact']),
      panOrGst: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pan_or_gst']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SubcontractorsTable createAlias(String alias) {
    return $SubcontractorsTable(attachedDatabase, alias);
  }
}

class Subcontractor extends DataClass implements Insertable<Subcontractor> {
  final int id;
  final String name;
  final String trade;
  final String? contact;
  final String? panOrGst;
  final String? notes;
  final DateTime createdAt;
  const Subcontractor(
      {required this.id,
      required this.name,
      required this.trade,
      this.contact,
      this.panOrGst,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['trade'] = Variable<String>(trade);
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    if (!nullToAbsent || panOrGst != null) {
      map['pan_or_gst'] = Variable<String>(panOrGst);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubcontractorsCompanion toCompanion(bool nullToAbsent) {
    return SubcontractorsCompanion(
      id: Value(id),
      name: Value(name),
      trade: Value(trade),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      panOrGst: panOrGst == null && nullToAbsent
          ? const Value.absent()
          : Value(panOrGst),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Subcontractor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subcontractor(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      trade: serializer.fromJson<String>(json['trade']),
      contact: serializer.fromJson<String?>(json['contact']),
      panOrGst: serializer.fromJson<String?>(json['panOrGst']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'trade': serializer.toJson<String>(trade),
      'contact': serializer.toJson<String?>(contact),
      'panOrGst': serializer.toJson<String?>(panOrGst),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Subcontractor copyWith(
          {int? id,
          String? name,
          String? trade,
          Value<String?> contact = const Value.absent(),
          Value<String?> panOrGst = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      Subcontractor(
        id: id ?? this.id,
        name: name ?? this.name,
        trade: trade ?? this.trade,
        contact: contact.present ? contact.value : this.contact,
        panOrGst: panOrGst.present ? panOrGst.value : this.panOrGst,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  Subcontractor copyWithCompanion(SubcontractorsCompanion data) {
    return Subcontractor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      trade: data.trade.present ? data.trade.value : this.trade,
      contact: data.contact.present ? data.contact.value : this.contact,
      panOrGst: data.panOrGst.present ? data.panOrGst.value : this.panOrGst,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subcontractor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trade: $trade, ')
          ..write('contact: $contact, ')
          ..write('panOrGst: $panOrGst, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, trade, contact, panOrGst, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subcontractor &&
          other.id == this.id &&
          other.name == this.name &&
          other.trade == this.trade &&
          other.contact == this.contact &&
          other.panOrGst == this.panOrGst &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SubcontractorsCompanion extends UpdateCompanion<Subcontractor> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> trade;
  final Value<String?> contact;
  final Value<String?> panOrGst;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const SubcontractorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.trade = const Value.absent(),
    this.contact = const Value.absent(),
    this.panOrGst = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SubcontractorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String trade,
    this.contact = const Value.absent(),
    this.panOrGst = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        trade = Value(trade);
  static Insertable<Subcontractor> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? trade,
    Expression<String>? contact,
    Expression<String>? panOrGst,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (trade != null) 'trade': trade,
      if (contact != null) 'contact': contact,
      if (panOrGst != null) 'pan_or_gst': panOrGst,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SubcontractorsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? trade,
      Value<String?>? contact,
      Value<String?>? panOrGst,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return SubcontractorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      trade: trade ?? this.trade,
      contact: contact ?? this.contact,
      panOrGst: panOrGst ?? this.panOrGst,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (trade.present) {
      map['trade'] = Variable<String>(trade.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (panOrGst.present) {
      map['pan_or_gst'] = Variable<String>(panOrGst.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubcontractorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('trade: $trade, ')
          ..write('contact: $contact, ')
          ..write('panOrGst: $panOrGst, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WorkOrdersTable extends WorkOrders
    with TableInfo<$WorkOrdersTable, WorkOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderNumberMeta =
      const VerificationMeta('orderNumber');
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
      'order_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _subcontractorIdMeta =
      const VerificationMeta('subcontractorId');
  @override
  late final GeneratedColumn<int> subcontractorId = GeneratedColumn<int>(
      'subcontractor_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES subcontractors (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _tradeMeta = const VerificationMeta('trade');
  @override
  late final GeneratedColumn<String> trade = GeneratedColumn<String>(
      'trade', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 30),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _agreedRateMeta =
      const VerificationMeta('agreedRate');
  @override
  late final GeneratedColumn<double> agreedRate = GeneratedColumn<double>(
      'agreed_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _estimatedQuantityMeta =
      const VerificationMeta('estimatedQuantity');
  @override
  late final GeneratedColumn<double> estimatedQuantity =
      GeneratedColumn<double>('estimated_quantity', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _contractAmountMeta =
      const VerificationMeta('contractAmount');
  @override
  late final GeneratedColumn<double> contractAmount = GeneratedColumn<double>(
      'contract_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _retentionPercentageMeta =
      const VerificationMeta('retentionPercentage');
  @override
  late final GeneratedColumn<double> retentionPercentage =
      GeneratedColumn<double>('retention_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(5.0));
  @override
  late final GeneratedColumnWithTypeConverter<WorkOrderStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('active'))
          .withConverter<WorkOrderStatus>($WorkOrdersTable.$converterstatus);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _targetDateMeta =
      const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
      'target_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _scopeOfWorkMeta =
      const VerificationMeta('scopeOfWork');
  @override
  late final GeneratedColumn<String> scopeOfWork = GeneratedColumn<String>(
      'scope_of_work', aliasedName, true,
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
        orderNumber,
        projectId,
        subcontractorId,
        title,
        trade,
        unit,
        agreedRate,
        estimatedQuantity,
        contractAmount,
        retentionPercentage,
        status,
        startDate,
        targetDate,
        scopeOfWork,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_orders';
  @override
  VerificationContext validateIntegrity(Insertable<WorkOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_number')) {
      context.handle(
          _orderNumberMeta,
          orderNumber.isAcceptableOrUnknown(
              data['order_number']!, _orderNumberMeta));
    } else if (isInserting) {
      context.missing(_orderNumberMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('subcontractor_id')) {
      context.handle(
          _subcontractorIdMeta,
          subcontractorId.isAcceptableOrUnknown(
              data['subcontractor_id']!, _subcontractorIdMeta));
    } else if (isInserting) {
      context.missing(_subcontractorIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('trade')) {
      context.handle(
          _tradeMeta, trade.isAcceptableOrUnknown(data['trade']!, _tradeMeta));
    } else if (isInserting) {
      context.missing(_tradeMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('agreed_rate')) {
      context.handle(
          _agreedRateMeta,
          agreedRate.isAcceptableOrUnknown(
              data['agreed_rate']!, _agreedRateMeta));
    } else if (isInserting) {
      context.missing(_agreedRateMeta);
    }
    if (data.containsKey('estimated_quantity')) {
      context.handle(
          _estimatedQuantityMeta,
          estimatedQuantity.isAcceptableOrUnknown(
              data['estimated_quantity']!, _estimatedQuantityMeta));
    } else if (isInserting) {
      context.missing(_estimatedQuantityMeta);
    }
    if (data.containsKey('contract_amount')) {
      context.handle(
          _contractAmountMeta,
          contractAmount.isAcceptableOrUnknown(
              data['contract_amount']!, _contractAmountMeta));
    } else if (isInserting) {
      context.missing(_contractAmountMeta);
    }
    if (data.containsKey('retention_percentage')) {
      context.handle(
          _retentionPercentageMeta,
          retentionPercentage.isAcceptableOrUnknown(
              data['retention_percentage']!, _retentionPercentageMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
          _targetDateMeta,
          targetDate.isAcceptableOrUnknown(
              data['target_date']!, _targetDateMeta));
    }
    if (data.containsKey('scope_of_work')) {
      context.handle(
          _scopeOfWorkMeta,
          scopeOfWork.isAcceptableOrUnknown(
              data['scope_of_work']!, _scopeOfWorkMeta));
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
  WorkOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_number'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      subcontractorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subcontractor_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      trade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trade'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      agreedRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}agreed_rate'])!,
      estimatedQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}estimated_quantity'])!,
      contractAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}contract_amount'])!,
      retentionPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}retention_percentage'])!,
      status: $WorkOrdersTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      targetDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}target_date']),
      scopeOfWork: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_of_work']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $WorkOrdersTable createAlias(String alias) {
    return $WorkOrdersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WorkOrderStatus, String, String> $converterstatus =
      const EnumNameConverter<WorkOrderStatus>(WorkOrderStatus.values);
}

class WorkOrder extends DataClass implements Insertable<WorkOrder> {
  final int id;
  final String orderNumber;
  final int projectId;
  final int subcontractorId;
  final String title;
  final String trade;
  final String unit;
  final double agreedRate;
  final double estimatedQuantity;
  final double contractAmount;
  final double retentionPercentage;
  final WorkOrderStatus status;
  final DateTime startDate;
  final DateTime? targetDate;
  final String? scopeOfWork;
  final DateTime createdAt;
  const WorkOrder(
      {required this.id,
      required this.orderNumber,
      required this.projectId,
      required this.subcontractorId,
      required this.title,
      required this.trade,
      required this.unit,
      required this.agreedRate,
      required this.estimatedQuantity,
      required this.contractAmount,
      required this.retentionPercentage,
      required this.status,
      required this.startDate,
      this.targetDate,
      this.scopeOfWork,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_number'] = Variable<String>(orderNumber);
    map['project_id'] = Variable<int>(projectId);
    map['subcontractor_id'] = Variable<int>(subcontractorId);
    map['title'] = Variable<String>(title);
    map['trade'] = Variable<String>(trade);
    map['unit'] = Variable<String>(unit);
    map['agreed_rate'] = Variable<double>(agreedRate);
    map['estimated_quantity'] = Variable<double>(estimatedQuantity);
    map['contract_amount'] = Variable<double>(contractAmount);
    map['retention_percentage'] = Variable<double>(retentionPercentage);
    {
      map['status'] =
          Variable<String>($WorkOrdersTable.$converterstatus.toSql(status));
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    if (!nullToAbsent || scopeOfWork != null) {
      map['scope_of_work'] = Variable<String>(scopeOfWork);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WorkOrdersCompanion toCompanion(bool nullToAbsent) {
    return WorkOrdersCompanion(
      id: Value(id),
      orderNumber: Value(orderNumber),
      projectId: Value(projectId),
      subcontractorId: Value(subcontractorId),
      title: Value(title),
      trade: Value(trade),
      unit: Value(unit),
      agreedRate: Value(agreedRate),
      estimatedQuantity: Value(estimatedQuantity),
      contractAmount: Value(contractAmount),
      retentionPercentage: Value(retentionPercentage),
      status: Value(status),
      startDate: Value(startDate),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      scopeOfWork: scopeOfWork == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeOfWork),
      createdAt: Value(createdAt),
    );
  }

  factory WorkOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkOrder(
      id: serializer.fromJson<int>(json['id']),
      orderNumber: serializer.fromJson<String>(json['orderNumber']),
      projectId: serializer.fromJson<int>(json['projectId']),
      subcontractorId: serializer.fromJson<int>(json['subcontractorId']),
      title: serializer.fromJson<String>(json['title']),
      trade: serializer.fromJson<String>(json['trade']),
      unit: serializer.fromJson<String>(json['unit']),
      agreedRate: serializer.fromJson<double>(json['agreedRate']),
      estimatedQuantity: serializer.fromJson<double>(json['estimatedQuantity']),
      contractAmount: serializer.fromJson<double>(json['contractAmount']),
      retentionPercentage:
          serializer.fromJson<double>(json['retentionPercentage']),
      status: $WorkOrdersTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      scopeOfWork: serializer.fromJson<String?>(json['scopeOfWork']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderNumber': serializer.toJson<String>(orderNumber),
      'projectId': serializer.toJson<int>(projectId),
      'subcontractorId': serializer.toJson<int>(subcontractorId),
      'title': serializer.toJson<String>(title),
      'trade': serializer.toJson<String>(trade),
      'unit': serializer.toJson<String>(unit),
      'agreedRate': serializer.toJson<double>(agreedRate),
      'estimatedQuantity': serializer.toJson<double>(estimatedQuantity),
      'contractAmount': serializer.toJson<double>(contractAmount),
      'retentionPercentage': serializer.toJson<double>(retentionPercentage),
      'status': serializer
          .toJson<String>($WorkOrdersTable.$converterstatus.toJson(status)),
      'startDate': serializer.toJson<DateTime>(startDate),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'scopeOfWork': serializer.toJson<String?>(scopeOfWork),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WorkOrder copyWith(
          {int? id,
          String? orderNumber,
          int? projectId,
          int? subcontractorId,
          String? title,
          String? trade,
          String? unit,
          double? agreedRate,
          double? estimatedQuantity,
          double? contractAmount,
          double? retentionPercentage,
          WorkOrderStatus? status,
          DateTime? startDate,
          Value<DateTime?> targetDate = const Value.absent(),
          Value<String?> scopeOfWork = const Value.absent(),
          DateTime? createdAt}) =>
      WorkOrder(
        id: id ?? this.id,
        orderNumber: orderNumber ?? this.orderNumber,
        projectId: projectId ?? this.projectId,
        subcontractorId: subcontractorId ?? this.subcontractorId,
        title: title ?? this.title,
        trade: trade ?? this.trade,
        unit: unit ?? this.unit,
        agreedRate: agreedRate ?? this.agreedRate,
        estimatedQuantity: estimatedQuantity ?? this.estimatedQuantity,
        contractAmount: contractAmount ?? this.contractAmount,
        retentionPercentage: retentionPercentage ?? this.retentionPercentage,
        status: status ?? this.status,
        startDate: startDate ?? this.startDate,
        targetDate: targetDate.present ? targetDate.value : this.targetDate,
        scopeOfWork: scopeOfWork.present ? scopeOfWork.value : this.scopeOfWork,
        createdAt: createdAt ?? this.createdAt,
      );
  WorkOrder copyWithCompanion(WorkOrdersCompanion data) {
    return WorkOrder(
      id: data.id.present ? data.id.value : this.id,
      orderNumber:
          data.orderNumber.present ? data.orderNumber.value : this.orderNumber,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      subcontractorId: data.subcontractorId.present
          ? data.subcontractorId.value
          : this.subcontractorId,
      title: data.title.present ? data.title.value : this.title,
      trade: data.trade.present ? data.trade.value : this.trade,
      unit: data.unit.present ? data.unit.value : this.unit,
      agreedRate:
          data.agreedRate.present ? data.agreedRate.value : this.agreedRate,
      estimatedQuantity: data.estimatedQuantity.present
          ? data.estimatedQuantity.value
          : this.estimatedQuantity,
      contractAmount: data.contractAmount.present
          ? data.contractAmount.value
          : this.contractAmount,
      retentionPercentage: data.retentionPercentage.present
          ? data.retentionPercentage.value
          : this.retentionPercentage,
      status: data.status.present ? data.status.value : this.status,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      targetDate:
          data.targetDate.present ? data.targetDate.value : this.targetDate,
      scopeOfWork:
          data.scopeOfWork.present ? data.scopeOfWork.value : this.scopeOfWork,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkOrder(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('projectId: $projectId, ')
          ..write('subcontractorId: $subcontractorId, ')
          ..write('title: $title, ')
          ..write('trade: $trade, ')
          ..write('unit: $unit, ')
          ..write('agreedRate: $agreedRate, ')
          ..write('estimatedQuantity: $estimatedQuantity, ')
          ..write('contractAmount: $contractAmount, ')
          ..write('retentionPercentage: $retentionPercentage, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('scopeOfWork: $scopeOfWork, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      orderNumber,
      projectId,
      subcontractorId,
      title,
      trade,
      unit,
      agreedRate,
      estimatedQuantity,
      contractAmount,
      retentionPercentage,
      status,
      startDate,
      targetDate,
      scopeOfWork,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkOrder &&
          other.id == this.id &&
          other.orderNumber == this.orderNumber &&
          other.projectId == this.projectId &&
          other.subcontractorId == this.subcontractorId &&
          other.title == this.title &&
          other.trade == this.trade &&
          other.unit == this.unit &&
          other.agreedRate == this.agreedRate &&
          other.estimatedQuantity == this.estimatedQuantity &&
          other.contractAmount == this.contractAmount &&
          other.retentionPercentage == this.retentionPercentage &&
          other.status == this.status &&
          other.startDate == this.startDate &&
          other.targetDate == this.targetDate &&
          other.scopeOfWork == this.scopeOfWork &&
          other.createdAt == this.createdAt);
}

class WorkOrdersCompanion extends UpdateCompanion<WorkOrder> {
  final Value<int> id;
  final Value<String> orderNumber;
  final Value<int> projectId;
  final Value<int> subcontractorId;
  final Value<String> title;
  final Value<String> trade;
  final Value<String> unit;
  final Value<double> agreedRate;
  final Value<double> estimatedQuantity;
  final Value<double> contractAmount;
  final Value<double> retentionPercentage;
  final Value<WorkOrderStatus> status;
  final Value<DateTime> startDate;
  final Value<DateTime?> targetDate;
  final Value<String?> scopeOfWork;
  final Value<DateTime> createdAt;
  const WorkOrdersCompanion({
    this.id = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.projectId = const Value.absent(),
    this.subcontractorId = const Value.absent(),
    this.title = const Value.absent(),
    this.trade = const Value.absent(),
    this.unit = const Value.absent(),
    this.agreedRate = const Value.absent(),
    this.estimatedQuantity = const Value.absent(),
    this.contractAmount = const Value.absent(),
    this.retentionPercentage = const Value.absent(),
    this.status = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.scopeOfWork = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WorkOrdersCompanion.insert({
    this.id = const Value.absent(),
    required String orderNumber,
    required int projectId,
    required int subcontractorId,
    required String title,
    required String trade,
    required String unit,
    required double agreedRate,
    required double estimatedQuantity,
    required double contractAmount,
    this.retentionPercentage = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime startDate,
    this.targetDate = const Value.absent(),
    this.scopeOfWork = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : orderNumber = Value(orderNumber),
        projectId = Value(projectId),
        subcontractorId = Value(subcontractorId),
        title = Value(title),
        trade = Value(trade),
        unit = Value(unit),
        agreedRate = Value(agreedRate),
        estimatedQuantity = Value(estimatedQuantity),
        contractAmount = Value(contractAmount),
        startDate = Value(startDate);
  static Insertable<WorkOrder> custom({
    Expression<int>? id,
    Expression<String>? orderNumber,
    Expression<int>? projectId,
    Expression<int>? subcontractorId,
    Expression<String>? title,
    Expression<String>? trade,
    Expression<String>? unit,
    Expression<double>? agreedRate,
    Expression<double>? estimatedQuantity,
    Expression<double>? contractAmount,
    Expression<double>? retentionPercentage,
    Expression<String>? status,
    Expression<DateTime>? startDate,
    Expression<DateTime>? targetDate,
    Expression<String>? scopeOfWork,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderNumber != null) 'order_number': orderNumber,
      if (projectId != null) 'project_id': projectId,
      if (subcontractorId != null) 'subcontractor_id': subcontractorId,
      if (title != null) 'title': title,
      if (trade != null) 'trade': trade,
      if (unit != null) 'unit': unit,
      if (agreedRate != null) 'agreed_rate': agreedRate,
      if (estimatedQuantity != null) 'estimated_quantity': estimatedQuantity,
      if (contractAmount != null) 'contract_amount': contractAmount,
      if (retentionPercentage != null)
        'retention_percentage': retentionPercentage,
      if (status != null) 'status': status,
      if (startDate != null) 'start_date': startDate,
      if (targetDate != null) 'target_date': targetDate,
      if (scopeOfWork != null) 'scope_of_work': scopeOfWork,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WorkOrdersCompanion copyWith(
      {Value<int>? id,
      Value<String>? orderNumber,
      Value<int>? projectId,
      Value<int>? subcontractorId,
      Value<String>? title,
      Value<String>? trade,
      Value<String>? unit,
      Value<double>? agreedRate,
      Value<double>? estimatedQuantity,
      Value<double>? contractAmount,
      Value<double>? retentionPercentage,
      Value<WorkOrderStatus>? status,
      Value<DateTime>? startDate,
      Value<DateTime?>? targetDate,
      Value<String?>? scopeOfWork,
      Value<DateTime>? createdAt}) {
    return WorkOrdersCompanion(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      projectId: projectId ?? this.projectId,
      subcontractorId: subcontractorId ?? this.subcontractorId,
      title: title ?? this.title,
      trade: trade ?? this.trade,
      unit: unit ?? this.unit,
      agreedRate: agreedRate ?? this.agreedRate,
      estimatedQuantity: estimatedQuantity ?? this.estimatedQuantity,
      contractAmount: contractAmount ?? this.contractAmount,
      retentionPercentage: retentionPercentage ?? this.retentionPercentage,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      scopeOfWork: scopeOfWork ?? this.scopeOfWork,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (subcontractorId.present) {
      map['subcontractor_id'] = Variable<int>(subcontractorId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (trade.present) {
      map['trade'] = Variable<String>(trade.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (agreedRate.present) {
      map['agreed_rate'] = Variable<double>(agreedRate.value);
    }
    if (estimatedQuantity.present) {
      map['estimated_quantity'] = Variable<double>(estimatedQuantity.value);
    }
    if (contractAmount.present) {
      map['contract_amount'] = Variable<double>(contractAmount.value);
    }
    if (retentionPercentage.present) {
      map['retention_percentage'] = Variable<double>(retentionPercentage.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
          $WorkOrdersTable.$converterstatus.toSql(status.value));
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (scopeOfWork.present) {
      map['scope_of_work'] = Variable<String>(scopeOfWork.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkOrdersCompanion(')
          ..write('id: $id, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('projectId: $projectId, ')
          ..write('subcontractorId: $subcontractorId, ')
          ..write('title: $title, ')
          ..write('trade: $trade, ')
          ..write('unit: $unit, ')
          ..write('agreedRate: $agreedRate, ')
          ..write('estimatedQuantity: $estimatedQuantity, ')
          ..write('contractAmount: $contractAmount, ')
          ..write('retentionPercentage: $retentionPercentage, ')
          ..write('status: $status, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('scopeOfWork: $scopeOfWork, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MeasurementBillsTable extends MeasurementBills
    with TableInfo<$MeasurementBillsTable, MeasurementBill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementBillsTable(this.attachedDatabase, [this._alias]);
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
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _workOrderIdMeta =
      const VerificationMeta('workOrderId');
  @override
  late final GeneratedColumn<int> workOrderId = GeneratedColumn<int>(
      'work_order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES work_orders (id)'));
  static const VerificationMeta _billNumberMeta =
      const VerificationMeta('billNumber');
  @override
  late final GeneratedColumn<String> billNumber = GeneratedColumn<String>(
      'bill_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _measuredQuantityMeta =
      const VerificationMeta('measuredQuantity');
  @override
  late final GeneratedColumn<double> measuredQuantity = GeneratedColumn<double>(
      'measured_quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitRateMeta =
      const VerificationMeta('unitRate');
  @override
  late final GeneratedColumn<double> unitRate = GeneratedColumn<double>(
      'unit_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _grossAmountMeta =
      const VerificationMeta('grossAmount');
  @override
  late final GeneratedColumn<double> grossAmount = GeneratedColumn<double>(
      'gross_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _retentionPercentageMeta =
      const VerificationMeta('retentionPercentage');
  @override
  late final GeneratedColumn<double> retentionPercentage =
      GeneratedColumn<double>('retention_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(5.0));
  static const VerificationMeta _retentionAmountMeta =
      const VerificationMeta('retentionAmount');
  @override
  late final GeneratedColumn<double> retentionAmount = GeneratedColumn<double>(
      'retention_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _netAmountMeta =
      const VerificationMeta('netAmount');
  @override
  late final GeneratedColumn<double> netAmount = GeneratedColumn<double>(
      'net_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _locationOrDescriptionMeta =
      const VerificationMeta('locationOrDescription');
  @override
  late final GeneratedColumn<String> locationOrDescription =
      GeneratedColumn<String>('location_or_description', aliasedName, true,
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
        transactionId,
        workOrderId,
        billNumber,
        date,
        measuredQuantity,
        unitRate,
        grossAmount,
        retentionPercentage,
        retentionAmount,
        netAmount,
        locationOrDescription,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_bills';
  @override
  VerificationContext validateIntegrity(Insertable<MeasurementBill> instance,
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
    if (data.containsKey('work_order_id')) {
      context.handle(
          _workOrderIdMeta,
          workOrderId.isAcceptableOrUnknown(
              data['work_order_id']!, _workOrderIdMeta));
    } else if (isInserting) {
      context.missing(_workOrderIdMeta);
    }
    if (data.containsKey('bill_number')) {
      context.handle(
          _billNumberMeta,
          billNumber.isAcceptableOrUnknown(
              data['bill_number']!, _billNumberMeta));
    } else if (isInserting) {
      context.missing(_billNumberMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('measured_quantity')) {
      context.handle(
          _measuredQuantityMeta,
          measuredQuantity.isAcceptableOrUnknown(
              data['measured_quantity']!, _measuredQuantityMeta));
    } else if (isInserting) {
      context.missing(_measuredQuantityMeta);
    }
    if (data.containsKey('unit_rate')) {
      context.handle(_unitRateMeta,
          unitRate.isAcceptableOrUnknown(data['unit_rate']!, _unitRateMeta));
    } else if (isInserting) {
      context.missing(_unitRateMeta);
    }
    if (data.containsKey('gross_amount')) {
      context.handle(
          _grossAmountMeta,
          grossAmount.isAcceptableOrUnknown(
              data['gross_amount']!, _grossAmountMeta));
    } else if (isInserting) {
      context.missing(_grossAmountMeta);
    }
    if (data.containsKey('retention_percentage')) {
      context.handle(
          _retentionPercentageMeta,
          retentionPercentage.isAcceptableOrUnknown(
              data['retention_percentage']!, _retentionPercentageMeta));
    }
    if (data.containsKey('retention_amount')) {
      context.handle(
          _retentionAmountMeta,
          retentionAmount.isAcceptableOrUnknown(
              data['retention_amount']!, _retentionAmountMeta));
    } else if (isInserting) {
      context.missing(_retentionAmountMeta);
    }
    if (data.containsKey('net_amount')) {
      context.handle(_netAmountMeta,
          netAmount.isAcceptableOrUnknown(data['net_amount']!, _netAmountMeta));
    } else if (isInserting) {
      context.missing(_netAmountMeta);
    }
    if (data.containsKey('location_or_description')) {
      context.handle(
          _locationOrDescriptionMeta,
          locationOrDescription.isAcceptableOrUnknown(
              data['location_or_description']!, _locationOrDescriptionMeta));
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
  MeasurementBill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementBill(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      workOrderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}work_order_id'])!,
      billNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bill_number'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      measuredQuantity: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}measured_quantity'])!,
      unitRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_rate'])!,
      grossAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gross_amount'])!,
      retentionPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}retention_percentage'])!,
      retentionAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}retention_amount'])!,
      netAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}net_amount'])!,
      locationOrDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}location_or_description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MeasurementBillsTable createAlias(String alias) {
    return $MeasurementBillsTable(attachedDatabase, alias);
  }
}

class MeasurementBill extends DataClass implements Insertable<MeasurementBill> {
  final int id;
  final int transactionId;
  final int workOrderId;
  final String billNumber;
  final DateTime date;
  final double measuredQuantity;
  final double unitRate;
  final double grossAmount;
  final double retentionPercentage;
  final double retentionAmount;
  final double netAmount;
  final String? locationOrDescription;
  final DateTime createdAt;
  const MeasurementBill(
      {required this.id,
      required this.transactionId,
      required this.workOrderId,
      required this.billNumber,
      required this.date,
      required this.measuredQuantity,
      required this.unitRate,
      required this.grossAmount,
      required this.retentionPercentage,
      required this.retentionAmount,
      required this.netAmount,
      this.locationOrDescription,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['work_order_id'] = Variable<int>(workOrderId);
    map['bill_number'] = Variable<String>(billNumber);
    map['date'] = Variable<DateTime>(date);
    map['measured_quantity'] = Variable<double>(measuredQuantity);
    map['unit_rate'] = Variable<double>(unitRate);
    map['gross_amount'] = Variable<double>(grossAmount);
    map['retention_percentage'] = Variable<double>(retentionPercentage);
    map['retention_amount'] = Variable<double>(retentionAmount);
    map['net_amount'] = Variable<double>(netAmount);
    if (!nullToAbsent || locationOrDescription != null) {
      map['location_or_description'] = Variable<String>(locationOrDescription);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MeasurementBillsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementBillsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      workOrderId: Value(workOrderId),
      billNumber: Value(billNumber),
      date: Value(date),
      measuredQuantity: Value(measuredQuantity),
      unitRate: Value(unitRate),
      grossAmount: Value(grossAmount),
      retentionPercentage: Value(retentionPercentage),
      retentionAmount: Value(retentionAmount),
      netAmount: Value(netAmount),
      locationOrDescription: locationOrDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(locationOrDescription),
      createdAt: Value(createdAt),
    );
  }

  factory MeasurementBill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementBill(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      workOrderId: serializer.fromJson<int>(json['workOrderId']),
      billNumber: serializer.fromJson<String>(json['billNumber']),
      date: serializer.fromJson<DateTime>(json['date']),
      measuredQuantity: serializer.fromJson<double>(json['measuredQuantity']),
      unitRate: serializer.fromJson<double>(json['unitRate']),
      grossAmount: serializer.fromJson<double>(json['grossAmount']),
      retentionPercentage:
          serializer.fromJson<double>(json['retentionPercentage']),
      retentionAmount: serializer.fromJson<double>(json['retentionAmount']),
      netAmount: serializer.fromJson<double>(json['netAmount']),
      locationOrDescription:
          serializer.fromJson<String?>(json['locationOrDescription']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'workOrderId': serializer.toJson<int>(workOrderId),
      'billNumber': serializer.toJson<String>(billNumber),
      'date': serializer.toJson<DateTime>(date),
      'measuredQuantity': serializer.toJson<double>(measuredQuantity),
      'unitRate': serializer.toJson<double>(unitRate),
      'grossAmount': serializer.toJson<double>(grossAmount),
      'retentionPercentage': serializer.toJson<double>(retentionPercentage),
      'retentionAmount': serializer.toJson<double>(retentionAmount),
      'netAmount': serializer.toJson<double>(netAmount),
      'locationOrDescription':
          serializer.toJson<String?>(locationOrDescription),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MeasurementBill copyWith(
          {int? id,
          int? transactionId,
          int? workOrderId,
          String? billNumber,
          DateTime? date,
          double? measuredQuantity,
          double? unitRate,
          double? grossAmount,
          double? retentionPercentage,
          double? retentionAmount,
          double? netAmount,
          Value<String?> locationOrDescription = const Value.absent(),
          DateTime? createdAt}) =>
      MeasurementBill(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        workOrderId: workOrderId ?? this.workOrderId,
        billNumber: billNumber ?? this.billNumber,
        date: date ?? this.date,
        measuredQuantity: measuredQuantity ?? this.measuredQuantity,
        unitRate: unitRate ?? this.unitRate,
        grossAmount: grossAmount ?? this.grossAmount,
        retentionPercentage: retentionPercentage ?? this.retentionPercentage,
        retentionAmount: retentionAmount ?? this.retentionAmount,
        netAmount: netAmount ?? this.netAmount,
        locationOrDescription: locationOrDescription.present
            ? locationOrDescription.value
            : this.locationOrDescription,
        createdAt: createdAt ?? this.createdAt,
      );
  MeasurementBill copyWithCompanion(MeasurementBillsCompanion data) {
    return MeasurementBill(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      workOrderId:
          data.workOrderId.present ? data.workOrderId.value : this.workOrderId,
      billNumber:
          data.billNumber.present ? data.billNumber.value : this.billNumber,
      date: data.date.present ? data.date.value : this.date,
      measuredQuantity: data.measuredQuantity.present
          ? data.measuredQuantity.value
          : this.measuredQuantity,
      unitRate: data.unitRate.present ? data.unitRate.value : this.unitRate,
      grossAmount:
          data.grossAmount.present ? data.grossAmount.value : this.grossAmount,
      retentionPercentage: data.retentionPercentage.present
          ? data.retentionPercentage.value
          : this.retentionPercentage,
      retentionAmount: data.retentionAmount.present
          ? data.retentionAmount.value
          : this.retentionAmount,
      netAmount: data.netAmount.present ? data.netAmount.value : this.netAmount,
      locationOrDescription: data.locationOrDescription.present
          ? data.locationOrDescription.value
          : this.locationOrDescription,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementBill(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('workOrderId: $workOrderId, ')
          ..write('billNumber: $billNumber, ')
          ..write('date: $date, ')
          ..write('measuredQuantity: $measuredQuantity, ')
          ..write('unitRate: $unitRate, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('retentionPercentage: $retentionPercentage, ')
          ..write('retentionAmount: $retentionAmount, ')
          ..write('netAmount: $netAmount, ')
          ..write('locationOrDescription: $locationOrDescription, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      workOrderId,
      billNumber,
      date,
      measuredQuantity,
      unitRate,
      grossAmount,
      retentionPercentage,
      retentionAmount,
      netAmount,
      locationOrDescription,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementBill &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.workOrderId == this.workOrderId &&
          other.billNumber == this.billNumber &&
          other.date == this.date &&
          other.measuredQuantity == this.measuredQuantity &&
          other.unitRate == this.unitRate &&
          other.grossAmount == this.grossAmount &&
          other.retentionPercentage == this.retentionPercentage &&
          other.retentionAmount == this.retentionAmount &&
          other.netAmount == this.netAmount &&
          other.locationOrDescription == this.locationOrDescription &&
          other.createdAt == this.createdAt);
}

class MeasurementBillsCompanion extends UpdateCompanion<MeasurementBill> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> workOrderId;
  final Value<String> billNumber;
  final Value<DateTime> date;
  final Value<double> measuredQuantity;
  final Value<double> unitRate;
  final Value<double> grossAmount;
  final Value<double> retentionPercentage;
  final Value<double> retentionAmount;
  final Value<double> netAmount;
  final Value<String?> locationOrDescription;
  final Value<DateTime> createdAt;
  const MeasurementBillsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.workOrderId = const Value.absent(),
    this.billNumber = const Value.absent(),
    this.date = const Value.absent(),
    this.measuredQuantity = const Value.absent(),
    this.unitRate = const Value.absent(),
    this.grossAmount = const Value.absent(),
    this.retentionPercentage = const Value.absent(),
    this.retentionAmount = const Value.absent(),
    this.netAmount = const Value.absent(),
    this.locationOrDescription = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MeasurementBillsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int workOrderId,
    required String billNumber,
    required DateTime date,
    required double measuredQuantity,
    required double unitRate,
    required double grossAmount,
    this.retentionPercentage = const Value.absent(),
    required double retentionAmount,
    required double netAmount,
    this.locationOrDescription = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : transactionId = Value(transactionId),
        workOrderId = Value(workOrderId),
        billNumber = Value(billNumber),
        date = Value(date),
        measuredQuantity = Value(measuredQuantity),
        unitRate = Value(unitRate),
        grossAmount = Value(grossAmount),
        retentionAmount = Value(retentionAmount),
        netAmount = Value(netAmount);
  static Insertable<MeasurementBill> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? workOrderId,
    Expression<String>? billNumber,
    Expression<DateTime>? date,
    Expression<double>? measuredQuantity,
    Expression<double>? unitRate,
    Expression<double>? grossAmount,
    Expression<double>? retentionPercentage,
    Expression<double>? retentionAmount,
    Expression<double>? netAmount,
    Expression<String>? locationOrDescription,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (workOrderId != null) 'work_order_id': workOrderId,
      if (billNumber != null) 'bill_number': billNumber,
      if (date != null) 'date': date,
      if (measuredQuantity != null) 'measured_quantity': measuredQuantity,
      if (unitRate != null) 'unit_rate': unitRate,
      if (grossAmount != null) 'gross_amount': grossAmount,
      if (retentionPercentage != null)
        'retention_percentage': retentionPercentage,
      if (retentionAmount != null) 'retention_amount': retentionAmount,
      if (netAmount != null) 'net_amount': netAmount,
      if (locationOrDescription != null)
        'location_or_description': locationOrDescription,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MeasurementBillsCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int>? workOrderId,
      Value<String>? billNumber,
      Value<DateTime>? date,
      Value<double>? measuredQuantity,
      Value<double>? unitRate,
      Value<double>? grossAmount,
      Value<double>? retentionPercentage,
      Value<double>? retentionAmount,
      Value<double>? netAmount,
      Value<String?>? locationOrDescription,
      Value<DateTime>? createdAt}) {
    return MeasurementBillsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      workOrderId: workOrderId ?? this.workOrderId,
      billNumber: billNumber ?? this.billNumber,
      date: date ?? this.date,
      measuredQuantity: measuredQuantity ?? this.measuredQuantity,
      unitRate: unitRate ?? this.unitRate,
      grossAmount: grossAmount ?? this.grossAmount,
      retentionPercentage: retentionPercentage ?? this.retentionPercentage,
      retentionAmount: retentionAmount ?? this.retentionAmount,
      netAmount: netAmount ?? this.netAmount,
      locationOrDescription:
          locationOrDescription ?? this.locationOrDescription,
      createdAt: createdAt ?? this.createdAt,
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
    if (workOrderId.present) {
      map['work_order_id'] = Variable<int>(workOrderId.value);
    }
    if (billNumber.present) {
      map['bill_number'] = Variable<String>(billNumber.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (measuredQuantity.present) {
      map['measured_quantity'] = Variable<double>(measuredQuantity.value);
    }
    if (unitRate.present) {
      map['unit_rate'] = Variable<double>(unitRate.value);
    }
    if (grossAmount.present) {
      map['gross_amount'] = Variable<double>(grossAmount.value);
    }
    if (retentionPercentage.present) {
      map['retention_percentage'] = Variable<double>(retentionPercentage.value);
    }
    if (retentionAmount.present) {
      map['retention_amount'] = Variable<double>(retentionAmount.value);
    }
    if (netAmount.present) {
      map['net_amount'] = Variable<double>(netAmount.value);
    }
    if (locationOrDescription.present) {
      map['location_or_description'] =
          Variable<String>(locationOrDescription.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementBillsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('workOrderId: $workOrderId, ')
          ..write('billNumber: $billNumber, ')
          ..write('date: $date, ')
          ..write('measuredQuantity: $measuredQuantity, ')
          ..write('unitRate: $unitRate, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('retentionPercentage: $retentionPercentage, ')
          ..write('retentionAmount: $retentionAmount, ')
          ..write('netAmount: $netAmount, ')
          ..write('locationOrDescription: $locationOrDescription, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SubcontractPaymentsTable extends SubcontractPayments
    with TableInfo<$SubcontractPaymentsTable, SubcontractPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubcontractPaymentsTable(this.attachedDatabase, [this._alias]);
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
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES transactions (id)'));
  static const VerificationMeta _subcontractorIdMeta =
      const VerificationMeta('subcontractorId');
  @override
  late final GeneratedColumn<int> subcontractorId = GeneratedColumn<int>(
      'subcontractor_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES subcontractors (id)'));
  static const VerificationMeta _workOrderIdMeta =
      const VerificationMeta('workOrderId');
  @override
  late final GeneratedColumn<int> workOrderId = GeneratedColumn<int>(
      'work_order_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES work_orders (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paymentDateMeta =
      const VerificationMeta('paymentDate');
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
      'payment_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMode, String> paymentMode =
      GeneratedColumn<String>('payment_mode', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PaymentMode>(
              $SubcontractPaymentsTable.$converterpaymentMode);
  static const VerificationMeta _bankAccountIdMeta =
      const VerificationMeta('bankAccountId');
  @override
  late final GeneratedColumn<int> bankAccountId = GeneratedColumn<int>(
      'bank_account_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES bank_accounts (id)'));
  static const VerificationMeta _isRetentionReleaseMeta =
      const VerificationMeta('isRetentionRelease');
  @override
  late final GeneratedColumn<bool> isRetentionRelease = GeneratedColumn<bool>(
      'is_retention_release', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_retention_release" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isAdvanceMeta =
      const VerificationMeta('isAdvance');
  @override
  late final GeneratedColumn<bool> isAdvance = GeneratedColumn<bool>(
      'is_advance', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_advance" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _referenceNoMeta =
      const VerificationMeta('referenceNo');
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
      'reference_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
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
        transactionId,
        subcontractorId,
        workOrderId,
        amount,
        paymentDate,
        paymentMode,
        bankAccountId,
        isRetentionRelease,
        isAdvance,
        referenceNo,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subcontract_payments';
  @override
  VerificationContext validateIntegrity(Insertable<SubcontractPayment> instance,
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
    if (data.containsKey('subcontractor_id')) {
      context.handle(
          _subcontractorIdMeta,
          subcontractorId.isAcceptableOrUnknown(
              data['subcontractor_id']!, _subcontractorIdMeta));
    } else if (isInserting) {
      context.missing(_subcontractorIdMeta);
    }
    if (data.containsKey('work_order_id')) {
      context.handle(
          _workOrderIdMeta,
          workOrderId.isAcceptableOrUnknown(
              data['work_order_id']!, _workOrderIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
          _paymentDateMeta,
          paymentDate.isAcceptableOrUnknown(
              data['payment_date']!, _paymentDateMeta));
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
          _bankAccountIdMeta,
          bankAccountId.isAcceptableOrUnknown(
              data['bank_account_id']!, _bankAccountIdMeta));
    }
    if (data.containsKey('is_retention_release')) {
      context.handle(
          _isRetentionReleaseMeta,
          isRetentionRelease.isAcceptableOrUnknown(
              data['is_retention_release']!, _isRetentionReleaseMeta));
    }
    if (data.containsKey('is_advance')) {
      context.handle(_isAdvanceMeta,
          isAdvance.isAcceptableOrUnknown(data['is_advance']!, _isAdvanceMeta));
    }
    if (data.containsKey('reference_no')) {
      context.handle(
          _referenceNoMeta,
          referenceNo.isAcceptableOrUnknown(
              data['reference_no']!, _referenceNoMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
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
  SubcontractPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubcontractPayment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      subcontractorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subcontractor_id'])!,
      workOrderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}work_order_id']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}payment_date'])!,
      paymentMode: $SubcontractPaymentsTable.$converterpaymentMode.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}payment_mode'])!),
      bankAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bank_account_id']),
      isRetentionRelease: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_retention_release'])!,
      isAdvance: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_advance'])!,
      referenceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_no']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SubcontractPaymentsTable createAlias(String alias) {
    return $SubcontractPaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMode, String, String> $converterpaymentMode =
      const EnumNameConverter<PaymentMode>(PaymentMode.values);
}

class SubcontractPayment extends DataClass
    implements Insertable<SubcontractPayment> {
  final int id;
  final int transactionId;
  final int subcontractorId;
  final int? workOrderId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMode paymentMode;
  final int? bankAccountId;
  final bool isRetentionRelease;
  final bool isAdvance;
  final String? referenceNo;
  final String? notes;
  final DateTime createdAt;
  const SubcontractPayment(
      {required this.id,
      required this.transactionId,
      required this.subcontractorId,
      this.workOrderId,
      required this.amount,
      required this.paymentDate,
      required this.paymentMode,
      this.bankAccountId,
      required this.isRetentionRelease,
      required this.isAdvance,
      this.referenceNo,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['subcontractor_id'] = Variable<int>(subcontractorId);
    if (!nullToAbsent || workOrderId != null) {
      map['work_order_id'] = Variable<int>(workOrderId);
    }
    map['amount'] = Variable<double>(amount);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    {
      map['payment_mode'] = Variable<String>(
          $SubcontractPaymentsTable.$converterpaymentMode.toSql(paymentMode));
    }
    if (!nullToAbsent || bankAccountId != null) {
      map['bank_account_id'] = Variable<int>(bankAccountId);
    }
    map['is_retention_release'] = Variable<bool>(isRetentionRelease);
    map['is_advance'] = Variable<bool>(isAdvance);
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubcontractPaymentsCompanion toCompanion(bool nullToAbsent) {
    return SubcontractPaymentsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      subcontractorId: Value(subcontractorId),
      workOrderId: workOrderId == null && nullToAbsent
          ? const Value.absent()
          : Value(workOrderId),
      amount: Value(amount),
      paymentDate: Value(paymentDate),
      paymentMode: Value(paymentMode),
      bankAccountId: bankAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccountId),
      isRetentionRelease: Value(isRetentionRelease),
      isAdvance: Value(isAdvance),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory SubcontractPayment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubcontractPayment(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      subcontractorId: serializer.fromJson<int>(json['subcontractorId']),
      workOrderId: serializer.fromJson<int?>(json['workOrderId']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      paymentMode: $SubcontractPaymentsTable.$converterpaymentMode
          .fromJson(serializer.fromJson<String>(json['paymentMode'])),
      bankAccountId: serializer.fromJson<int?>(json['bankAccountId']),
      isRetentionRelease: serializer.fromJson<bool>(json['isRetentionRelease']),
      isAdvance: serializer.fromJson<bool>(json['isAdvance']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'subcontractorId': serializer.toJson<int>(subcontractorId),
      'workOrderId': serializer.toJson<int?>(workOrderId),
      'amount': serializer.toJson<double>(amount),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'paymentMode': serializer.toJson<String>(
          $SubcontractPaymentsTable.$converterpaymentMode.toJson(paymentMode)),
      'bankAccountId': serializer.toJson<int?>(bankAccountId),
      'isRetentionRelease': serializer.toJson<bool>(isRetentionRelease),
      'isAdvance': serializer.toJson<bool>(isAdvance),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SubcontractPayment copyWith(
          {int? id,
          int? transactionId,
          int? subcontractorId,
          Value<int?> workOrderId = const Value.absent(),
          double? amount,
          DateTime? paymentDate,
          PaymentMode? paymentMode,
          Value<int?> bankAccountId = const Value.absent(),
          bool? isRetentionRelease,
          bool? isAdvance,
          Value<String?> referenceNo = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      SubcontractPayment(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        subcontractorId: subcontractorId ?? this.subcontractorId,
        workOrderId: workOrderId.present ? workOrderId.value : this.workOrderId,
        amount: amount ?? this.amount,
        paymentDate: paymentDate ?? this.paymentDate,
        paymentMode: paymentMode ?? this.paymentMode,
        bankAccountId:
            bankAccountId.present ? bankAccountId.value : this.bankAccountId,
        isRetentionRelease: isRetentionRelease ?? this.isRetentionRelease,
        isAdvance: isAdvance ?? this.isAdvance,
        referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  SubcontractPayment copyWithCompanion(SubcontractPaymentsCompanion data) {
    return SubcontractPayment(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      subcontractorId: data.subcontractorId.present
          ? data.subcontractorId.value
          : this.subcontractorId,
      workOrderId:
          data.workOrderId.present ? data.workOrderId.value : this.workOrderId,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentDate:
          data.paymentDate.present ? data.paymentDate.value : this.paymentDate,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      isRetentionRelease: data.isRetentionRelease.present
          ? data.isRetentionRelease.value
          : this.isRetentionRelease,
      isAdvance: data.isAdvance.present ? data.isAdvance.value : this.isAdvance,
      referenceNo:
          data.referenceNo.present ? data.referenceNo.value : this.referenceNo,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubcontractPayment(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('subcontractorId: $subcontractorId, ')
          ..write('workOrderId: $workOrderId, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('isRetentionRelease: $isRetentionRelease, ')
          ..write('isAdvance: $isAdvance, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      subcontractorId,
      workOrderId,
      amount,
      paymentDate,
      paymentMode,
      bankAccountId,
      isRetentionRelease,
      isAdvance,
      referenceNo,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubcontractPayment &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.subcontractorId == this.subcontractorId &&
          other.workOrderId == this.workOrderId &&
          other.amount == this.amount &&
          other.paymentDate == this.paymentDate &&
          other.paymentMode == this.paymentMode &&
          other.bankAccountId == this.bankAccountId &&
          other.isRetentionRelease == this.isRetentionRelease &&
          other.isAdvance == this.isAdvance &&
          other.referenceNo == this.referenceNo &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SubcontractPaymentsCompanion extends UpdateCompanion<SubcontractPayment> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> subcontractorId;
  final Value<int?> workOrderId;
  final Value<double> amount;
  final Value<DateTime> paymentDate;
  final Value<PaymentMode> paymentMode;
  final Value<int?> bankAccountId;
  final Value<bool> isRetentionRelease;
  final Value<bool> isAdvance;
  final Value<String?> referenceNo;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const SubcontractPaymentsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.subcontractorId = const Value.absent(),
    this.workOrderId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.isRetentionRelease = const Value.absent(),
    this.isAdvance = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SubcontractPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int subcontractorId,
    this.workOrderId = const Value.absent(),
    required double amount,
    required DateTime paymentDate,
    required PaymentMode paymentMode,
    this.bankAccountId = const Value.absent(),
    this.isRetentionRelease = const Value.absent(),
    this.isAdvance = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : transactionId = Value(transactionId),
        subcontractorId = Value(subcontractorId),
        amount = Value(amount),
        paymentDate = Value(paymentDate),
        paymentMode = Value(paymentMode);
  static Insertable<SubcontractPayment> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? subcontractorId,
    Expression<int>? workOrderId,
    Expression<double>? amount,
    Expression<DateTime>? paymentDate,
    Expression<String>? paymentMode,
    Expression<int>? bankAccountId,
    Expression<bool>? isRetentionRelease,
    Expression<bool>? isAdvance,
    Expression<String>? referenceNo,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (subcontractorId != null) 'subcontractor_id': subcontractorId,
      if (workOrderId != null) 'work_order_id': workOrderId,
      if (amount != null) 'amount': amount,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (isRetentionRelease != null)
        'is_retention_release': isRetentionRelease,
      if (isAdvance != null) 'is_advance': isAdvance,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SubcontractPaymentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int>? subcontractorId,
      Value<int?>? workOrderId,
      Value<double>? amount,
      Value<DateTime>? paymentDate,
      Value<PaymentMode>? paymentMode,
      Value<int?>? bankAccountId,
      Value<bool>? isRetentionRelease,
      Value<bool>? isAdvance,
      Value<String?>? referenceNo,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return SubcontractPaymentsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      subcontractorId: subcontractorId ?? this.subcontractorId,
      workOrderId: workOrderId ?? this.workOrderId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMode: paymentMode ?? this.paymentMode,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      isRetentionRelease: isRetentionRelease ?? this.isRetentionRelease,
      isAdvance: isAdvance ?? this.isAdvance,
      referenceNo: referenceNo ?? this.referenceNo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (subcontractorId.present) {
      map['subcontractor_id'] = Variable<int>(subcontractorId.value);
    }
    if (workOrderId.present) {
      map['work_order_id'] = Variable<int>(workOrderId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>($SubcontractPaymentsTable
          .$converterpaymentMode
          .toSql(paymentMode.value));
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<int>(bankAccountId.value);
    }
    if (isRetentionRelease.present) {
      map['is_retention_release'] = Variable<bool>(isRetentionRelease.value);
    }
    if (isAdvance.present) {
      map['is_advance'] = Variable<bool>(isAdvance.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubcontractPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('subcontractorId: $subcontractorId, ')
          ..write('workOrderId: $workOrderId, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('isRetentionRelease: $isRetentionRelease, ')
          ..write('isAdvance: $isAdvance, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ClientRaBillsTable extends ClientRaBills
    with TableInfo<$ClientRaBillsTable, ClientRaBill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientRaBillsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE CASCADE'));
  static const VerificationMeta _billNumberMeta =
      const VerificationMeta('billNumber');
  @override
  late final GeneratedColumn<String> billNumber = GeneratedColumn<String>(
      'bill_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _billDateMeta =
      const VerificationMeta('billDate');
  @override
  late final GeneratedColumn<DateTime> billDate = GeneratedColumn<DateTime>(
      'bill_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _stageOrDescriptionMeta =
      const VerificationMeta('stageOrDescription');
  @override
  late final GeneratedColumn<String> stageOrDescription =
      GeneratedColumn<String>('stage_or_description', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
              minTextLength: 1, maxTextLength: 500),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _grossAmountMeta =
      const VerificationMeta('grossAmount');
  @override
  late final GeneratedColumn<double> grossAmount = GeneratedColumn<double>(
      'gross_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _retentionPercentageMeta =
      const VerificationMeta('retentionPercentage');
  @override
  late final GeneratedColumn<double> retentionPercentage =
      GeneratedColumn<double>('retention_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(5.0));
  static const VerificationMeta _retentionAmountMeta =
      const VerificationMeta('retentionAmount');
  @override
  late final GeneratedColumn<double> retentionAmount = GeneratedColumn<double>(
      'retention_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _advanceDeductionMeta =
      const VerificationMeta('advanceDeduction');
  @override
  late final GeneratedColumn<double> advanceDeduction = GeneratedColumn<double>(
      'advance_deduction', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _taxOrTdsDeductionMeta =
      const VerificationMeta('taxOrTdsDeduction');
  @override
  late final GeneratedColumn<double> taxOrTdsDeduction =
      GeneratedColumn<double>('tax_or_tds_deduction', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _netCertifiedAmountMeta =
      const VerificationMeta('netCertifiedAmount');
  @override
  late final GeneratedColumn<double> netCertifiedAmount =
      GeneratedColumn<double>('net_certified_amount', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
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
        transactionId,
        projectId,
        billNumber,
        billDate,
        stageOrDescription,
        grossAmount,
        retentionPercentage,
        retentionAmount,
        advanceDeduction,
        taxOrTdsDeduction,
        netCertifiedAmount,
        dueDate,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_ra_bills';
  @override
  VerificationContext validateIntegrity(Insertable<ClientRaBill> instance,
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
    if (data.containsKey('bill_number')) {
      context.handle(
          _billNumberMeta,
          billNumber.isAcceptableOrUnknown(
              data['bill_number']!, _billNumberMeta));
    } else if (isInserting) {
      context.missing(_billNumberMeta);
    }
    if (data.containsKey('bill_date')) {
      context.handle(_billDateMeta,
          billDate.isAcceptableOrUnknown(data['bill_date']!, _billDateMeta));
    } else if (isInserting) {
      context.missing(_billDateMeta);
    }
    if (data.containsKey('stage_or_description')) {
      context.handle(
          _stageOrDescriptionMeta,
          stageOrDescription.isAcceptableOrUnknown(
              data['stage_or_description']!, _stageOrDescriptionMeta));
    } else if (isInserting) {
      context.missing(_stageOrDescriptionMeta);
    }
    if (data.containsKey('gross_amount')) {
      context.handle(
          _grossAmountMeta,
          grossAmount.isAcceptableOrUnknown(
              data['gross_amount']!, _grossAmountMeta));
    } else if (isInserting) {
      context.missing(_grossAmountMeta);
    }
    if (data.containsKey('retention_percentage')) {
      context.handle(
          _retentionPercentageMeta,
          retentionPercentage.isAcceptableOrUnknown(
              data['retention_percentage']!, _retentionPercentageMeta));
    }
    if (data.containsKey('retention_amount')) {
      context.handle(
          _retentionAmountMeta,
          retentionAmount.isAcceptableOrUnknown(
              data['retention_amount']!, _retentionAmountMeta));
    }
    if (data.containsKey('advance_deduction')) {
      context.handle(
          _advanceDeductionMeta,
          advanceDeduction.isAcceptableOrUnknown(
              data['advance_deduction']!, _advanceDeductionMeta));
    }
    if (data.containsKey('tax_or_tds_deduction')) {
      context.handle(
          _taxOrTdsDeductionMeta,
          taxOrTdsDeduction.isAcceptableOrUnknown(
              data['tax_or_tds_deduction']!, _taxOrTdsDeductionMeta));
    }
    if (data.containsKey('net_certified_amount')) {
      context.handle(
          _netCertifiedAmountMeta,
          netCertifiedAmount.isAcceptableOrUnknown(
              data['net_certified_amount']!, _netCertifiedAmountMeta));
    } else if (isInserting) {
      context.missing(_netCertifiedAmountMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
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
  ClientRaBill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientRaBill(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      billNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bill_number'])!,
      billDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}bill_date'])!,
      stageOrDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}stage_or_description'])!,
      grossAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gross_amount'])!,
      retentionPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}retention_percentage'])!,
      retentionAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}retention_amount'])!,
      advanceDeduction: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}advance_deduction'])!,
      taxOrTdsDeduction: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}tax_or_tds_deduction'])!,
      netCertifiedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}net_certified_amount'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ClientRaBillsTable createAlias(String alias) {
    return $ClientRaBillsTable(attachedDatabase, alias);
  }
}

class ClientRaBill extends DataClass implements Insertable<ClientRaBill> {
  final int id;
  final int transactionId;
  final int projectId;
  final String billNumber;
  final DateTime billDate;
  final String stageOrDescription;
  final double grossAmount;
  final double retentionPercentage;
  final double retentionAmount;
  final double advanceDeduction;
  final double taxOrTdsDeduction;
  final double netCertifiedAmount;
  final DateTime? dueDate;
  final String? notes;
  final DateTime createdAt;
  const ClientRaBill(
      {required this.id,
      required this.transactionId,
      required this.projectId,
      required this.billNumber,
      required this.billDate,
      required this.stageOrDescription,
      required this.grossAmount,
      required this.retentionPercentage,
      required this.retentionAmount,
      required this.advanceDeduction,
      required this.taxOrTdsDeduction,
      required this.netCertifiedAmount,
      this.dueDate,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['project_id'] = Variable<int>(projectId);
    map['bill_number'] = Variable<String>(billNumber);
    map['bill_date'] = Variable<DateTime>(billDate);
    map['stage_or_description'] = Variable<String>(stageOrDescription);
    map['gross_amount'] = Variable<double>(grossAmount);
    map['retention_percentage'] = Variable<double>(retentionPercentage);
    map['retention_amount'] = Variable<double>(retentionAmount);
    map['advance_deduction'] = Variable<double>(advanceDeduction);
    map['tax_or_tds_deduction'] = Variable<double>(taxOrTdsDeduction);
    map['net_certified_amount'] = Variable<double>(netCertifiedAmount);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClientRaBillsCompanion toCompanion(bool nullToAbsent) {
    return ClientRaBillsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      projectId: Value(projectId),
      billNumber: Value(billNumber),
      billDate: Value(billDate),
      stageOrDescription: Value(stageOrDescription),
      grossAmount: Value(grossAmount),
      retentionPercentage: Value(retentionPercentage),
      retentionAmount: Value(retentionAmount),
      advanceDeduction: Value(advanceDeduction),
      taxOrTdsDeduction: Value(taxOrTdsDeduction),
      netCertifiedAmount: Value(netCertifiedAmount),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory ClientRaBill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientRaBill(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      projectId: serializer.fromJson<int>(json['projectId']),
      billNumber: serializer.fromJson<String>(json['billNumber']),
      billDate: serializer.fromJson<DateTime>(json['billDate']),
      stageOrDescription:
          serializer.fromJson<String>(json['stageOrDescription']),
      grossAmount: serializer.fromJson<double>(json['grossAmount']),
      retentionPercentage:
          serializer.fromJson<double>(json['retentionPercentage']),
      retentionAmount: serializer.fromJson<double>(json['retentionAmount']),
      advanceDeduction: serializer.fromJson<double>(json['advanceDeduction']),
      taxOrTdsDeduction: serializer.fromJson<double>(json['taxOrTdsDeduction']),
      netCertifiedAmount:
          serializer.fromJson<double>(json['netCertifiedAmount']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'projectId': serializer.toJson<int>(projectId),
      'billNumber': serializer.toJson<String>(billNumber),
      'billDate': serializer.toJson<DateTime>(billDate),
      'stageOrDescription': serializer.toJson<String>(stageOrDescription),
      'grossAmount': serializer.toJson<double>(grossAmount),
      'retentionPercentage': serializer.toJson<double>(retentionPercentage),
      'retentionAmount': serializer.toJson<double>(retentionAmount),
      'advanceDeduction': serializer.toJson<double>(advanceDeduction),
      'taxOrTdsDeduction': serializer.toJson<double>(taxOrTdsDeduction),
      'netCertifiedAmount': serializer.toJson<double>(netCertifiedAmount),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClientRaBill copyWith(
          {int? id,
          int? transactionId,
          int? projectId,
          String? billNumber,
          DateTime? billDate,
          String? stageOrDescription,
          double? grossAmount,
          double? retentionPercentage,
          double? retentionAmount,
          double? advanceDeduction,
          double? taxOrTdsDeduction,
          double? netCertifiedAmount,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      ClientRaBill(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        projectId: projectId ?? this.projectId,
        billNumber: billNumber ?? this.billNumber,
        billDate: billDate ?? this.billDate,
        stageOrDescription: stageOrDescription ?? this.stageOrDescription,
        grossAmount: grossAmount ?? this.grossAmount,
        retentionPercentage: retentionPercentage ?? this.retentionPercentage,
        retentionAmount: retentionAmount ?? this.retentionAmount,
        advanceDeduction: advanceDeduction ?? this.advanceDeduction,
        taxOrTdsDeduction: taxOrTdsDeduction ?? this.taxOrTdsDeduction,
        netCertifiedAmount: netCertifiedAmount ?? this.netCertifiedAmount,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  ClientRaBill copyWithCompanion(ClientRaBillsCompanion data) {
    return ClientRaBill(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      billNumber:
          data.billNumber.present ? data.billNumber.value : this.billNumber,
      billDate: data.billDate.present ? data.billDate.value : this.billDate,
      stageOrDescription: data.stageOrDescription.present
          ? data.stageOrDescription.value
          : this.stageOrDescription,
      grossAmount:
          data.grossAmount.present ? data.grossAmount.value : this.grossAmount,
      retentionPercentage: data.retentionPercentage.present
          ? data.retentionPercentage.value
          : this.retentionPercentage,
      retentionAmount: data.retentionAmount.present
          ? data.retentionAmount.value
          : this.retentionAmount,
      advanceDeduction: data.advanceDeduction.present
          ? data.advanceDeduction.value
          : this.advanceDeduction,
      taxOrTdsDeduction: data.taxOrTdsDeduction.present
          ? data.taxOrTdsDeduction.value
          : this.taxOrTdsDeduction,
      netCertifiedAmount: data.netCertifiedAmount.present
          ? data.netCertifiedAmount.value
          : this.netCertifiedAmount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientRaBill(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('projectId: $projectId, ')
          ..write('billNumber: $billNumber, ')
          ..write('billDate: $billDate, ')
          ..write('stageOrDescription: $stageOrDescription, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('retentionPercentage: $retentionPercentage, ')
          ..write('retentionAmount: $retentionAmount, ')
          ..write('advanceDeduction: $advanceDeduction, ')
          ..write('taxOrTdsDeduction: $taxOrTdsDeduction, ')
          ..write('netCertifiedAmount: $netCertifiedAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      projectId,
      billNumber,
      billDate,
      stageOrDescription,
      grossAmount,
      retentionPercentage,
      retentionAmount,
      advanceDeduction,
      taxOrTdsDeduction,
      netCertifiedAmount,
      dueDate,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientRaBill &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.projectId == this.projectId &&
          other.billNumber == this.billNumber &&
          other.billDate == this.billDate &&
          other.stageOrDescription == this.stageOrDescription &&
          other.grossAmount == this.grossAmount &&
          other.retentionPercentage == this.retentionPercentage &&
          other.retentionAmount == this.retentionAmount &&
          other.advanceDeduction == this.advanceDeduction &&
          other.taxOrTdsDeduction == this.taxOrTdsDeduction &&
          other.netCertifiedAmount == this.netCertifiedAmount &&
          other.dueDate == this.dueDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ClientRaBillsCompanion extends UpdateCompanion<ClientRaBill> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> projectId;
  final Value<String> billNumber;
  final Value<DateTime> billDate;
  final Value<String> stageOrDescription;
  final Value<double> grossAmount;
  final Value<double> retentionPercentage;
  final Value<double> retentionAmount;
  final Value<double> advanceDeduction;
  final Value<double> taxOrTdsDeduction;
  final Value<double> netCertifiedAmount;
  final Value<DateTime?> dueDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const ClientRaBillsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.billNumber = const Value.absent(),
    this.billDate = const Value.absent(),
    this.stageOrDescription = const Value.absent(),
    this.grossAmount = const Value.absent(),
    this.retentionPercentage = const Value.absent(),
    this.retentionAmount = const Value.absent(),
    this.advanceDeduction = const Value.absent(),
    this.taxOrTdsDeduction = const Value.absent(),
    this.netCertifiedAmount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClientRaBillsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int projectId,
    required String billNumber,
    required DateTime billDate,
    required String stageOrDescription,
    required double grossAmount,
    this.retentionPercentage = const Value.absent(),
    this.retentionAmount = const Value.absent(),
    this.advanceDeduction = const Value.absent(),
    this.taxOrTdsDeduction = const Value.absent(),
    required double netCertifiedAmount,
    this.dueDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : transactionId = Value(transactionId),
        projectId = Value(projectId),
        billNumber = Value(billNumber),
        billDate = Value(billDate),
        stageOrDescription = Value(stageOrDescription),
        grossAmount = Value(grossAmount),
        netCertifiedAmount = Value(netCertifiedAmount);
  static Insertable<ClientRaBill> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? projectId,
    Expression<String>? billNumber,
    Expression<DateTime>? billDate,
    Expression<String>? stageOrDescription,
    Expression<double>? grossAmount,
    Expression<double>? retentionPercentage,
    Expression<double>? retentionAmount,
    Expression<double>? advanceDeduction,
    Expression<double>? taxOrTdsDeduction,
    Expression<double>? netCertifiedAmount,
    Expression<DateTime>? dueDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (projectId != null) 'project_id': projectId,
      if (billNumber != null) 'bill_number': billNumber,
      if (billDate != null) 'bill_date': billDate,
      if (stageOrDescription != null)
        'stage_or_description': stageOrDescription,
      if (grossAmount != null) 'gross_amount': grossAmount,
      if (retentionPercentage != null)
        'retention_percentage': retentionPercentage,
      if (retentionAmount != null) 'retention_amount': retentionAmount,
      if (advanceDeduction != null) 'advance_deduction': advanceDeduction,
      if (taxOrTdsDeduction != null) 'tax_or_tds_deduction': taxOrTdsDeduction,
      if (netCertifiedAmount != null)
        'net_certified_amount': netCertifiedAmount,
      if (dueDate != null) 'due_date': dueDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClientRaBillsCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int>? projectId,
      Value<String>? billNumber,
      Value<DateTime>? billDate,
      Value<String>? stageOrDescription,
      Value<double>? grossAmount,
      Value<double>? retentionPercentage,
      Value<double>? retentionAmount,
      Value<double>? advanceDeduction,
      Value<double>? taxOrTdsDeduction,
      Value<double>? netCertifiedAmount,
      Value<DateTime?>? dueDate,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return ClientRaBillsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      projectId: projectId ?? this.projectId,
      billNumber: billNumber ?? this.billNumber,
      billDate: billDate ?? this.billDate,
      stageOrDescription: stageOrDescription ?? this.stageOrDescription,
      grossAmount: grossAmount ?? this.grossAmount,
      retentionPercentage: retentionPercentage ?? this.retentionPercentage,
      retentionAmount: retentionAmount ?? this.retentionAmount,
      advanceDeduction: advanceDeduction ?? this.advanceDeduction,
      taxOrTdsDeduction: taxOrTdsDeduction ?? this.taxOrTdsDeduction,
      netCertifiedAmount: netCertifiedAmount ?? this.netCertifiedAmount,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (billNumber.present) {
      map['bill_number'] = Variable<String>(billNumber.value);
    }
    if (billDate.present) {
      map['bill_date'] = Variable<DateTime>(billDate.value);
    }
    if (stageOrDescription.present) {
      map['stage_or_description'] = Variable<String>(stageOrDescription.value);
    }
    if (grossAmount.present) {
      map['gross_amount'] = Variable<double>(grossAmount.value);
    }
    if (retentionPercentage.present) {
      map['retention_percentage'] = Variable<double>(retentionPercentage.value);
    }
    if (retentionAmount.present) {
      map['retention_amount'] = Variable<double>(retentionAmount.value);
    }
    if (advanceDeduction.present) {
      map['advance_deduction'] = Variable<double>(advanceDeduction.value);
    }
    if (taxOrTdsDeduction.present) {
      map['tax_or_tds_deduction'] = Variable<double>(taxOrTdsDeduction.value);
    }
    if (netCertifiedAmount.present) {
      map['net_certified_amount'] = Variable<double>(netCertifiedAmount.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientRaBillsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('projectId: $projectId, ')
          ..write('billNumber: $billNumber, ')
          ..write('billDate: $billDate, ')
          ..write('stageOrDescription: $stageOrDescription, ')
          ..write('grossAmount: $grossAmount, ')
          ..write('retentionPercentage: $retentionPercentage, ')
          ..write('retentionAmount: $retentionAmount, ')
          ..write('advanceDeduction: $advanceDeduction, ')
          ..write('taxOrTdsDeduction: $taxOrTdsDeduction, ')
          ..write('netCertifiedAmount: $netCertifiedAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ClientReceiptsTable extends ClientReceipts
    with TableInfo<$ClientReceiptsTable, ClientReceipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientReceiptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE CASCADE'));
  static const VerificationMeta _clientRaBillIdMeta =
      const VerificationMeta('clientRaBillId');
  @override
  late final GeneratedColumn<int> clientRaBillId = GeneratedColumn<int>(
      'client_ra_bill_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES client_ra_bills (id) ON DELETE SET NULL'));
  static const VerificationMeta _receiptDateMeta =
      const VerificationMeta('receiptDate');
  @override
  late final GeneratedColumn<DateTime> receiptDate = GeneratedColumn<DateTime>(
      'receipt_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMode, String> paymentMode =
      GeneratedColumn<String>('payment_mode', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PaymentMode>(
              $ClientReceiptsTable.$converterpaymentMode);
  static const VerificationMeta _bankAccountIdMeta =
      const VerificationMeta('bankAccountId');
  @override
  late final GeneratedColumn<int> bankAccountId = GeneratedColumn<int>(
      'bank_account_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES bank_accounts (id) ON DELETE SET NULL'));
  static const VerificationMeta _isAdvanceMeta =
      const VerificationMeta('isAdvance');
  @override
  late final GeneratedColumn<bool> isAdvance = GeneratedColumn<bool>(
      'is_advance', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_advance" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isRetentionReleaseMeta =
      const VerificationMeta('isRetentionRelease');
  @override
  late final GeneratedColumn<bool> isRetentionRelease = GeneratedColumn<bool>(
      'is_retention_release', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_retention_release" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _referenceNoMeta =
      const VerificationMeta('referenceNo');
  @override
  late final GeneratedColumn<String> referenceNo = GeneratedColumn<String>(
      'reference_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
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
        transactionId,
        projectId,
        clientRaBillId,
        receiptDate,
        amount,
        paymentMode,
        bankAccountId,
        isAdvance,
        isRetentionRelease,
        referenceNo,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'client_receipts';
  @override
  VerificationContext validateIntegrity(Insertable<ClientReceipt> instance,
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
    if (data.containsKey('client_ra_bill_id')) {
      context.handle(
          _clientRaBillIdMeta,
          clientRaBillId.isAcceptableOrUnknown(
              data['client_ra_bill_id']!, _clientRaBillIdMeta));
    }
    if (data.containsKey('receipt_date')) {
      context.handle(
          _receiptDateMeta,
          receiptDate.isAcceptableOrUnknown(
              data['receipt_date']!, _receiptDateMeta));
    } else if (isInserting) {
      context.missing(_receiptDateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
          _bankAccountIdMeta,
          bankAccountId.isAcceptableOrUnknown(
              data['bank_account_id']!, _bankAccountIdMeta));
    }
    if (data.containsKey('is_advance')) {
      context.handle(_isAdvanceMeta,
          isAdvance.isAcceptableOrUnknown(data['is_advance']!, _isAdvanceMeta));
    }
    if (data.containsKey('is_retention_release')) {
      context.handle(
          _isRetentionReleaseMeta,
          isRetentionRelease.isAcceptableOrUnknown(
              data['is_retention_release']!, _isRetentionReleaseMeta));
    }
    if (data.containsKey('reference_no')) {
      context.handle(
          _referenceNoMeta,
          referenceNo.isAcceptableOrUnknown(
              data['reference_no']!, _referenceNoMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
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
  ClientReceipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientReceipt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      clientRaBillId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_ra_bill_id']),
      receiptDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}receipt_date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      paymentMode: $ClientReceiptsTable.$converterpaymentMode.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}payment_mode'])!),
      bankAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bank_account_id']),
      isAdvance: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_advance'])!,
      isRetentionRelease: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_retention_release'])!,
      referenceNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference_no']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ClientReceiptsTable createAlias(String alias) {
    return $ClientReceiptsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMode, String, String> $converterpaymentMode =
      const EnumNameConverter<PaymentMode>(PaymentMode.values);
}

class ClientReceipt extends DataClass implements Insertable<ClientReceipt> {
  final int id;
  final int transactionId;
  final int projectId;
  final int? clientRaBillId;
  final DateTime receiptDate;
  final double amount;
  final PaymentMode paymentMode;
  final int? bankAccountId;
  final bool isAdvance;
  final bool isRetentionRelease;
  final String? referenceNo;
  final String? notes;
  final DateTime createdAt;
  const ClientReceipt(
      {required this.id,
      required this.transactionId,
      required this.projectId,
      this.clientRaBillId,
      required this.receiptDate,
      required this.amount,
      required this.paymentMode,
      this.bankAccountId,
      required this.isAdvance,
      required this.isRetentionRelease,
      this.referenceNo,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['project_id'] = Variable<int>(projectId);
    if (!nullToAbsent || clientRaBillId != null) {
      map['client_ra_bill_id'] = Variable<int>(clientRaBillId);
    }
    map['receipt_date'] = Variable<DateTime>(receiptDate);
    map['amount'] = Variable<double>(amount);
    {
      map['payment_mode'] = Variable<String>(
          $ClientReceiptsTable.$converterpaymentMode.toSql(paymentMode));
    }
    if (!nullToAbsent || bankAccountId != null) {
      map['bank_account_id'] = Variable<int>(bankAccountId);
    }
    map['is_advance'] = Variable<bool>(isAdvance);
    map['is_retention_release'] = Variable<bool>(isRetentionRelease);
    if (!nullToAbsent || referenceNo != null) {
      map['reference_no'] = Variable<String>(referenceNo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClientReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ClientReceiptsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      projectId: Value(projectId),
      clientRaBillId: clientRaBillId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientRaBillId),
      receiptDate: Value(receiptDate),
      amount: Value(amount),
      paymentMode: Value(paymentMode),
      bankAccountId: bankAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccountId),
      isAdvance: Value(isAdvance),
      isRetentionRelease: Value(isRetentionRelease),
      referenceNo: referenceNo == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNo),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory ClientReceipt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientReceipt(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      projectId: serializer.fromJson<int>(json['projectId']),
      clientRaBillId: serializer.fromJson<int?>(json['clientRaBillId']),
      receiptDate: serializer.fromJson<DateTime>(json['receiptDate']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMode: $ClientReceiptsTable.$converterpaymentMode
          .fromJson(serializer.fromJson<String>(json['paymentMode'])),
      bankAccountId: serializer.fromJson<int?>(json['bankAccountId']),
      isAdvance: serializer.fromJson<bool>(json['isAdvance']),
      isRetentionRelease: serializer.fromJson<bool>(json['isRetentionRelease']),
      referenceNo: serializer.fromJson<String?>(json['referenceNo']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'projectId': serializer.toJson<int>(projectId),
      'clientRaBillId': serializer.toJson<int?>(clientRaBillId),
      'receiptDate': serializer.toJson<DateTime>(receiptDate),
      'amount': serializer.toJson<double>(amount),
      'paymentMode': serializer.toJson<String>(
          $ClientReceiptsTable.$converterpaymentMode.toJson(paymentMode)),
      'bankAccountId': serializer.toJson<int?>(bankAccountId),
      'isAdvance': serializer.toJson<bool>(isAdvance),
      'isRetentionRelease': serializer.toJson<bool>(isRetentionRelease),
      'referenceNo': serializer.toJson<String?>(referenceNo),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClientReceipt copyWith(
          {int? id,
          int? transactionId,
          int? projectId,
          Value<int?> clientRaBillId = const Value.absent(),
          DateTime? receiptDate,
          double? amount,
          PaymentMode? paymentMode,
          Value<int?> bankAccountId = const Value.absent(),
          bool? isAdvance,
          bool? isRetentionRelease,
          Value<String?> referenceNo = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      ClientReceipt(
        id: id ?? this.id,
        transactionId: transactionId ?? this.transactionId,
        projectId: projectId ?? this.projectId,
        clientRaBillId:
            clientRaBillId.present ? clientRaBillId.value : this.clientRaBillId,
        receiptDate: receiptDate ?? this.receiptDate,
        amount: amount ?? this.amount,
        paymentMode: paymentMode ?? this.paymentMode,
        bankAccountId:
            bankAccountId.present ? bankAccountId.value : this.bankAccountId,
        isAdvance: isAdvance ?? this.isAdvance,
        isRetentionRelease: isRetentionRelease ?? this.isRetentionRelease,
        referenceNo: referenceNo.present ? referenceNo.value : this.referenceNo,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  ClientReceipt copyWithCompanion(ClientReceiptsCompanion data) {
    return ClientReceipt(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      clientRaBillId: data.clientRaBillId.present
          ? data.clientRaBillId.value
          : this.clientRaBillId,
      receiptDate:
          data.receiptDate.present ? data.receiptDate.value : this.receiptDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      isAdvance: data.isAdvance.present ? data.isAdvance.value : this.isAdvance,
      isRetentionRelease: data.isRetentionRelease.present
          ? data.isRetentionRelease.value
          : this.isRetentionRelease,
      referenceNo:
          data.referenceNo.present ? data.referenceNo.value : this.referenceNo,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientReceipt(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('projectId: $projectId, ')
          ..write('clientRaBillId: $clientRaBillId, ')
          ..write('receiptDate: $receiptDate, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('isAdvance: $isAdvance, ')
          ..write('isRetentionRelease: $isRetentionRelease, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionId,
      projectId,
      clientRaBillId,
      receiptDate,
      amount,
      paymentMode,
      bankAccountId,
      isAdvance,
      isRetentionRelease,
      referenceNo,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientReceipt &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.projectId == this.projectId &&
          other.clientRaBillId == this.clientRaBillId &&
          other.receiptDate == this.receiptDate &&
          other.amount == this.amount &&
          other.paymentMode == this.paymentMode &&
          other.bankAccountId == this.bankAccountId &&
          other.isAdvance == this.isAdvance &&
          other.isRetentionRelease == this.isRetentionRelease &&
          other.referenceNo == this.referenceNo &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ClientReceiptsCompanion extends UpdateCompanion<ClientReceipt> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> projectId;
  final Value<int?> clientRaBillId;
  final Value<DateTime> receiptDate;
  final Value<double> amount;
  final Value<PaymentMode> paymentMode;
  final Value<int?> bankAccountId;
  final Value<bool> isAdvance;
  final Value<bool> isRetentionRelease;
  final Value<String?> referenceNo;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const ClientReceiptsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.clientRaBillId = const Value.absent(),
    this.receiptDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.isAdvance = const Value.absent(),
    this.isRetentionRelease = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClientReceiptsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int projectId,
    this.clientRaBillId = const Value.absent(),
    required DateTime receiptDate,
    required double amount,
    required PaymentMode paymentMode,
    this.bankAccountId = const Value.absent(),
    this.isAdvance = const Value.absent(),
    this.isRetentionRelease = const Value.absent(),
    this.referenceNo = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : transactionId = Value(transactionId),
        projectId = Value(projectId),
        receiptDate = Value(receiptDate),
        amount = Value(amount),
        paymentMode = Value(paymentMode);
  static Insertable<ClientReceipt> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? projectId,
    Expression<int>? clientRaBillId,
    Expression<DateTime>? receiptDate,
    Expression<double>? amount,
    Expression<String>? paymentMode,
    Expression<int>? bankAccountId,
    Expression<bool>? isAdvance,
    Expression<bool>? isRetentionRelease,
    Expression<String>? referenceNo,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (projectId != null) 'project_id': projectId,
      if (clientRaBillId != null) 'client_ra_bill_id': clientRaBillId,
      if (receiptDate != null) 'receipt_date': receiptDate,
      if (amount != null) 'amount': amount,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (isAdvance != null) 'is_advance': isAdvance,
      if (isRetentionRelease != null)
        'is_retention_release': isRetentionRelease,
      if (referenceNo != null) 'reference_no': referenceNo,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClientReceiptsCompanion copyWith(
      {Value<int>? id,
      Value<int>? transactionId,
      Value<int>? projectId,
      Value<int?>? clientRaBillId,
      Value<DateTime>? receiptDate,
      Value<double>? amount,
      Value<PaymentMode>? paymentMode,
      Value<int?>? bankAccountId,
      Value<bool>? isAdvance,
      Value<bool>? isRetentionRelease,
      Value<String?>? referenceNo,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return ClientReceiptsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      projectId: projectId ?? this.projectId,
      clientRaBillId: clientRaBillId ?? this.clientRaBillId,
      receiptDate: receiptDate ?? this.receiptDate,
      amount: amount ?? this.amount,
      paymentMode: paymentMode ?? this.paymentMode,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      isAdvance: isAdvance ?? this.isAdvance,
      isRetentionRelease: isRetentionRelease ?? this.isRetentionRelease,
      referenceNo: referenceNo ?? this.referenceNo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (clientRaBillId.present) {
      map['client_ra_bill_id'] = Variable<int>(clientRaBillId.value);
    }
    if (receiptDate.present) {
      map['receipt_date'] = Variable<DateTime>(receiptDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>(
          $ClientReceiptsTable.$converterpaymentMode.toSql(paymentMode.value));
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<int>(bankAccountId.value);
    }
    if (isAdvance.present) {
      map['is_advance'] = Variable<bool>(isAdvance.value);
    }
    if (isRetentionRelease.present) {
      map['is_retention_release'] = Variable<bool>(isRetentionRelease.value);
    }
    if (referenceNo.present) {
      map['reference_no'] = Variable<String>(referenceNo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('projectId: $projectId, ')
          ..write('clientRaBillId: $clientRaBillId, ')
          ..write('receiptDate: $receiptDate, ')
          ..write('amount: $amount, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('isAdvance: $isAdvance, ')
          ..write('isRetentionRelease: $isRetentionRelease, ')
          ..write('referenceNo: $referenceNo, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProjectBudgetsTable extends ProjectBudgets
    with TableInfo<$ProjectBudgetsTable, ProjectBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectBudgetsTable(this.attachedDatabase, [this._alias]);
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
          'REFERENCES projects (id) ON DELETE CASCADE'));
  @override
  late final GeneratedColumnWithTypeConverter<BudgetCostHead, String> costHead =
      GeneratedColumn<String>('cost_head', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<BudgetCostHead>(
              $ProjectBudgetsTable.$convertercostHead);
  static const VerificationMeta _allocatedAmountMeta =
      const VerificationMeta('allocatedAmount');
  @override
  late final GeneratedColumn<double> allocatedAmount = GeneratedColumn<double>(
      'allocated_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _alertThresholdPercentageMeta =
      const VerificationMeta('alertThresholdPercentage');
  @override
  late final GeneratedColumn<double> alertThresholdPercentage =
      GeneratedColumn<double>('alert_threshold_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(85.0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        costHead,
        allocatedAmount,
        alertThresholdPercentage,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_budgets';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectBudget> instance,
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
    if (data.containsKey('allocated_amount')) {
      context.handle(
          _allocatedAmountMeta,
          allocatedAmount.isAcceptableOrUnknown(
              data['allocated_amount']!, _allocatedAmountMeta));
    } else if (isInserting) {
      context.missing(_allocatedAmountMeta);
    }
    if (data.containsKey('alert_threshold_percentage')) {
      context.handle(
          _alertThresholdPercentageMeta,
          alertThresholdPercentage.isAcceptableOrUnknown(
              data['alert_threshold_percentage']!,
              _alertThresholdPercentageMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {projectId, costHead},
      ];
  @override
  ProjectBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectBudget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      costHead: $ProjectBudgetsTable.$convertercostHead.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cost_head'])!),
      allocatedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}allocated_amount'])!,
      alertThresholdPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}alert_threshold_percentage'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProjectBudgetsTable createAlias(String alias) {
    return $ProjectBudgetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BudgetCostHead, String, String> $convertercostHead =
      const EnumNameConverter<BudgetCostHead>(BudgetCostHead.values);
}

class ProjectBudget extends DataClass implements Insertable<ProjectBudget> {
  final int id;
  final int projectId;
  final BudgetCostHead costHead;
  final double allocatedAmount;
  final double alertThresholdPercentage;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProjectBudget(
      {required this.id,
      required this.projectId,
      required this.costHead,
      required this.allocatedAmount,
      required this.alertThresholdPercentage,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    {
      map['cost_head'] = Variable<String>(
          $ProjectBudgetsTable.$convertercostHead.toSql(costHead));
    }
    map['allocated_amount'] = Variable<double>(allocatedAmount);
    map['alert_threshold_percentage'] =
        Variable<double>(alertThresholdPercentage);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProjectBudgetsCompanion toCompanion(bool nullToAbsent) {
    return ProjectBudgetsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      costHead: Value(costHead),
      allocatedAmount: Value(allocatedAmount),
      alertThresholdPercentage: Value(alertThresholdPercentage),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProjectBudget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectBudget(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      costHead: $ProjectBudgetsTable.$convertercostHead
          .fromJson(serializer.fromJson<String>(json['costHead'])),
      allocatedAmount: serializer.fromJson<double>(json['allocatedAmount']),
      alertThresholdPercentage:
          serializer.fromJson<double>(json['alertThresholdPercentage']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'costHead': serializer.toJson<String>(
          $ProjectBudgetsTable.$convertercostHead.toJson(costHead)),
      'allocatedAmount': serializer.toJson<double>(allocatedAmount),
      'alertThresholdPercentage':
          serializer.toJson<double>(alertThresholdPercentage),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProjectBudget copyWith(
          {int? id,
          int? projectId,
          BudgetCostHead? costHead,
          double? allocatedAmount,
          double? alertThresholdPercentage,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ProjectBudget(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        costHead: costHead ?? this.costHead,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
        alertThresholdPercentage:
            alertThresholdPercentage ?? this.alertThresholdPercentage,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ProjectBudget copyWithCompanion(ProjectBudgetsCompanion data) {
    return ProjectBudget(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      costHead: data.costHead.present ? data.costHead.value : this.costHead,
      allocatedAmount: data.allocatedAmount.present
          ? data.allocatedAmount.value
          : this.allocatedAmount,
      alertThresholdPercentage: data.alertThresholdPercentage.present
          ? data.alertThresholdPercentage.value
          : this.alertThresholdPercentage,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectBudget(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('costHead: $costHead, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('alertThresholdPercentage: $alertThresholdPercentage, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, costHead, allocatedAmount,
      alertThresholdPercentage, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectBudget &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.costHead == this.costHead &&
          other.allocatedAmount == this.allocatedAmount &&
          other.alertThresholdPercentage == this.alertThresholdPercentage &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectBudgetsCompanion extends UpdateCompanion<ProjectBudget> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<BudgetCostHead> costHead;
  final Value<double> allocatedAmount;
  final Value<double> alertThresholdPercentage;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProjectBudgetsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.costHead = const Value.absent(),
    this.allocatedAmount = const Value.absent(),
    this.alertThresholdPercentage = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProjectBudgetsCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required BudgetCostHead costHead,
    required double allocatedAmount,
    this.alertThresholdPercentage = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : projectId = Value(projectId),
        costHead = Value(costHead),
        allocatedAmount = Value(allocatedAmount);
  static Insertable<ProjectBudget> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? costHead,
    Expression<double>? allocatedAmount,
    Expression<double>? alertThresholdPercentage,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (costHead != null) 'cost_head': costHead,
      if (allocatedAmount != null) 'allocated_amount': allocatedAmount,
      if (alertThresholdPercentage != null)
        'alert_threshold_percentage': alertThresholdPercentage,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProjectBudgetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? projectId,
      Value<BudgetCostHead>? costHead,
      Value<double>? allocatedAmount,
      Value<double>? alertThresholdPercentage,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ProjectBudgetsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      costHead: costHead ?? this.costHead,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      alertThresholdPercentage:
          alertThresholdPercentage ?? this.alertThresholdPercentage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (costHead.present) {
      map['cost_head'] = Variable<String>(
          $ProjectBudgetsTable.$convertercostHead.toSql(costHead.value));
    }
    if (allocatedAmount.present) {
      map['allocated_amount'] = Variable<double>(allocatedAmount.value);
    }
    if (alertThresholdPercentage.present) {
      map['alert_threshold_percentage'] =
          Variable<double>(alertThresholdPercentage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('costHead: $costHead, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('alertThresholdPercentage: $alertThresholdPercentage, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EquipmentsTable extends Equipments
    with TableInfo<$EquipmentsTable, Equipment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentsTable(this.attachedDatabase, [this._alias]);
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
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _assetOrRegNumberMeta =
      const VerificationMeta('assetOrRegNumber');
  @override
  late final GeneratedColumn<String> assetOrRegNumber = GeneratedColumn<String>(
      'asset_or_reg_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('JCB / Backhoe Loader'));
  @override
  late final GeneratedColumnWithTypeConverter<EquipmentOwnership, String>
      ownership = GeneratedColumn<String>('ownership', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: Constant(EquipmentOwnership.rented.name))
          .withConverter<EquipmentOwnership>(
              $EquipmentsTable.$converterownership);
  static const VerificationMeta _vendorIdMeta =
      const VerificationMeta('vendorId');
  @override
  late final GeneratedColumn<int> vendorId = GeneratedColumn<int>(
      'vendor_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES vendors (id) ON DELETE SET NULL'));
  static const VerificationMeta _currentProjectIdMeta =
      const VerificationMeta('currentProjectId');
  @override
  late final GeneratedColumn<int> currentProjectId = GeneratedColumn<int>(
      'current_project_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE SET NULL'));
  @override
  late final GeneratedColumnWithTypeConverter<EquipmentRentalBasis, String>
      rentalBasis = GeneratedColumn<String>('rental_basis', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: Constant(EquipmentRentalBasis.hourly.name))
          .withConverter<EquipmentRentalBasis>(
              $EquipmentsTable.$converterrentalBasis);
  static const VerificationMeta _standardRateMeta =
      const VerificationMeta('standardRate');
  @override
  late final GeneratedColumn<double> standardRate = GeneratedColumn<double>(
      'standard_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  late final GeneratedColumnWithTypeConverter<EquipmentFuelPolicy, String>
      fuelPolicy = GeneratedColumn<String>('fuel_policy', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue:
                  Constant(EquipmentFuelPolicy.contractorSupplied.name))
          .withConverter<EquipmentFuelPolicy>(
              $EquipmentsTable.$converterfuelPolicy);
  static const VerificationMeta _operatorNameMeta =
      const VerificationMeta('operatorName');
  @override
  late final GeneratedColumn<String> operatorName = GeneratedColumn<String>(
      'operator_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _operatorContactMeta =
      const VerificationMeta('operatorContact');
  @override
  late final GeneratedColumn<String> operatorContact = GeneratedColumn<String>(
      'operator_contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<EquipmentStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: Constant(EquipmentStatus.active.name))
          .withConverter<EquipmentStatus>($EquipmentsTable.$converterstatus);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        assetOrRegNumber,
        category,
        ownership,
        vendorId,
        currentProjectId,
        rentalBasis,
        standardRate,
        fuelPolicy,
        operatorName,
        operatorContact,
        status,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipments';
  @override
  VerificationContext validateIntegrity(Insertable<Equipment> instance,
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
    if (data.containsKey('asset_or_reg_number')) {
      context.handle(
          _assetOrRegNumberMeta,
          assetOrRegNumber.isAcceptableOrUnknown(
              data['asset_or_reg_number']!, _assetOrRegNumberMeta));
    } else if (isInserting) {
      context.missing(_assetOrRegNumberMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('vendor_id')) {
      context.handle(_vendorIdMeta,
          vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta));
    }
    if (data.containsKey('current_project_id')) {
      context.handle(
          _currentProjectIdMeta,
          currentProjectId.isAcceptableOrUnknown(
              data['current_project_id']!, _currentProjectIdMeta));
    }
    if (data.containsKey('standard_rate')) {
      context.handle(
          _standardRateMeta,
          standardRate.isAcceptableOrUnknown(
              data['standard_rate']!, _standardRateMeta));
    }
    if (data.containsKey('operator_name')) {
      context.handle(
          _operatorNameMeta,
          operatorName.isAcceptableOrUnknown(
              data['operator_name']!, _operatorNameMeta));
    }
    if (data.containsKey('operator_contact')) {
      context.handle(
          _operatorContactMeta,
          operatorContact.isAcceptableOrUnknown(
              data['operator_contact']!, _operatorContactMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Equipment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Equipment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      assetOrRegNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}asset_or_reg_number'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      ownership: $EquipmentsTable.$converterownership.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ownership'])!),
      vendorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vendor_id']),
      currentProjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_project_id']),
      rentalBasis: $EquipmentsTable.$converterrentalBasis.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}rental_basis'])!),
      standardRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}standard_rate'])!,
      fuelPolicy: $EquipmentsTable.$converterfuelPolicy.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuel_policy'])!),
      operatorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_name']),
      operatorContact: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}operator_contact']),
      status: $EquipmentsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $EquipmentsTable createAlias(String alias) {
    return $EquipmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EquipmentOwnership, String, String>
      $converterownership =
      const EnumNameConverter<EquipmentOwnership>(EquipmentOwnership.values);
  static JsonTypeConverter2<EquipmentRentalBasis, String, String>
      $converterrentalBasis = const EnumNameConverter<EquipmentRentalBasis>(
          EquipmentRentalBasis.values);
  static JsonTypeConverter2<EquipmentFuelPolicy, String, String>
      $converterfuelPolicy =
      const EnumNameConverter<EquipmentFuelPolicy>(EquipmentFuelPolicy.values);
  static JsonTypeConverter2<EquipmentStatus, String, String> $converterstatus =
      const EnumNameConverter<EquipmentStatus>(EquipmentStatus.values);
}

class Equipment extends DataClass implements Insertable<Equipment> {
  final int id;
  final String name;
  final String assetOrRegNumber;
  final String category;
  final EquipmentOwnership ownership;
  final int? vendorId;
  final int? currentProjectId;
  final EquipmentRentalBasis rentalBasis;
  final double standardRate;
  final EquipmentFuelPolicy fuelPolicy;
  final String? operatorName;
  final String? operatorContact;
  final EquipmentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Equipment(
      {required this.id,
      required this.name,
      required this.assetOrRegNumber,
      required this.category,
      required this.ownership,
      this.vendorId,
      this.currentProjectId,
      required this.rentalBasis,
      required this.standardRate,
      required this.fuelPolicy,
      this.operatorName,
      this.operatorContact,
      required this.status,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['asset_or_reg_number'] = Variable<String>(assetOrRegNumber);
    map['category'] = Variable<String>(category);
    {
      map['ownership'] = Variable<String>(
          $EquipmentsTable.$converterownership.toSql(ownership));
    }
    if (!nullToAbsent || vendorId != null) {
      map['vendor_id'] = Variable<int>(vendorId);
    }
    if (!nullToAbsent || currentProjectId != null) {
      map['current_project_id'] = Variable<int>(currentProjectId);
    }
    {
      map['rental_basis'] = Variable<String>(
          $EquipmentsTable.$converterrentalBasis.toSql(rentalBasis));
    }
    map['standard_rate'] = Variable<double>(standardRate);
    {
      map['fuel_policy'] = Variable<String>(
          $EquipmentsTable.$converterfuelPolicy.toSql(fuelPolicy));
    }
    if (!nullToAbsent || operatorName != null) {
      map['operator_name'] = Variable<String>(operatorName);
    }
    if (!nullToAbsent || operatorContact != null) {
      map['operator_contact'] = Variable<String>(operatorContact);
    }
    {
      map['status'] =
          Variable<String>($EquipmentsTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EquipmentsCompanion toCompanion(bool nullToAbsent) {
    return EquipmentsCompanion(
      id: Value(id),
      name: Value(name),
      assetOrRegNumber: Value(assetOrRegNumber),
      category: Value(category),
      ownership: Value(ownership),
      vendorId: vendorId == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorId),
      currentProjectId: currentProjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentProjectId),
      rentalBasis: Value(rentalBasis),
      standardRate: Value(standardRate),
      fuelPolicy: Value(fuelPolicy),
      operatorName: operatorName == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorName),
      operatorContact: operatorContact == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorContact),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Equipment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Equipment(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      assetOrRegNumber: serializer.fromJson<String>(json['assetOrRegNumber']),
      category: serializer.fromJson<String>(json['category']),
      ownership: $EquipmentsTable.$converterownership
          .fromJson(serializer.fromJson<String>(json['ownership'])),
      vendorId: serializer.fromJson<int?>(json['vendorId']),
      currentProjectId: serializer.fromJson<int?>(json['currentProjectId']),
      rentalBasis: $EquipmentsTable.$converterrentalBasis
          .fromJson(serializer.fromJson<String>(json['rentalBasis'])),
      standardRate: serializer.fromJson<double>(json['standardRate']),
      fuelPolicy: $EquipmentsTable.$converterfuelPolicy
          .fromJson(serializer.fromJson<String>(json['fuelPolicy'])),
      operatorName: serializer.fromJson<String?>(json['operatorName']),
      operatorContact: serializer.fromJson<String?>(json['operatorContact']),
      status: $EquipmentsTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'assetOrRegNumber': serializer.toJson<String>(assetOrRegNumber),
      'category': serializer.toJson<String>(category),
      'ownership': serializer.toJson<String>(
          $EquipmentsTable.$converterownership.toJson(ownership)),
      'vendorId': serializer.toJson<int?>(vendorId),
      'currentProjectId': serializer.toJson<int?>(currentProjectId),
      'rentalBasis': serializer.toJson<String>(
          $EquipmentsTable.$converterrentalBasis.toJson(rentalBasis)),
      'standardRate': serializer.toJson<double>(standardRate),
      'fuelPolicy': serializer.toJson<String>(
          $EquipmentsTable.$converterfuelPolicy.toJson(fuelPolicy)),
      'operatorName': serializer.toJson<String?>(operatorName),
      'operatorContact': serializer.toJson<String?>(operatorContact),
      'status': serializer
          .toJson<String>($EquipmentsTable.$converterstatus.toJson(status)),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Equipment copyWith(
          {int? id,
          String? name,
          String? assetOrRegNumber,
          String? category,
          EquipmentOwnership? ownership,
          Value<int?> vendorId = const Value.absent(),
          Value<int?> currentProjectId = const Value.absent(),
          EquipmentRentalBasis? rentalBasis,
          double? standardRate,
          EquipmentFuelPolicy? fuelPolicy,
          Value<String?> operatorName = const Value.absent(),
          Value<String?> operatorContact = const Value.absent(),
          EquipmentStatus? status,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Equipment(
        id: id ?? this.id,
        name: name ?? this.name,
        assetOrRegNumber: assetOrRegNumber ?? this.assetOrRegNumber,
        category: category ?? this.category,
        ownership: ownership ?? this.ownership,
        vendorId: vendorId.present ? vendorId.value : this.vendorId,
        currentProjectId: currentProjectId.present
            ? currentProjectId.value
            : this.currentProjectId,
        rentalBasis: rentalBasis ?? this.rentalBasis,
        standardRate: standardRate ?? this.standardRate,
        fuelPolicy: fuelPolicy ?? this.fuelPolicy,
        operatorName:
            operatorName.present ? operatorName.value : this.operatorName,
        operatorContact: operatorContact.present
            ? operatorContact.value
            : this.operatorContact,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Equipment copyWithCompanion(EquipmentsCompanion data) {
    return Equipment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      assetOrRegNumber: data.assetOrRegNumber.present
          ? data.assetOrRegNumber.value
          : this.assetOrRegNumber,
      category: data.category.present ? data.category.value : this.category,
      ownership: data.ownership.present ? data.ownership.value : this.ownership,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      currentProjectId: data.currentProjectId.present
          ? data.currentProjectId.value
          : this.currentProjectId,
      rentalBasis:
          data.rentalBasis.present ? data.rentalBasis.value : this.rentalBasis,
      standardRate: data.standardRate.present
          ? data.standardRate.value
          : this.standardRate,
      fuelPolicy:
          data.fuelPolicy.present ? data.fuelPolicy.value : this.fuelPolicy,
      operatorName: data.operatorName.present
          ? data.operatorName.value
          : this.operatorName,
      operatorContact: data.operatorContact.present
          ? data.operatorContact.value
          : this.operatorContact,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Equipment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('assetOrRegNumber: $assetOrRegNumber, ')
          ..write('category: $category, ')
          ..write('ownership: $ownership, ')
          ..write('vendorId: $vendorId, ')
          ..write('currentProjectId: $currentProjectId, ')
          ..write('rentalBasis: $rentalBasis, ')
          ..write('standardRate: $standardRate, ')
          ..write('fuelPolicy: $fuelPolicy, ')
          ..write('operatorName: $operatorName, ')
          ..write('operatorContact: $operatorContact, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      assetOrRegNumber,
      category,
      ownership,
      vendorId,
      currentProjectId,
      rentalBasis,
      standardRate,
      fuelPolicy,
      operatorName,
      operatorContact,
      status,
      notes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Equipment &&
          other.id == this.id &&
          other.name == this.name &&
          other.assetOrRegNumber == this.assetOrRegNumber &&
          other.category == this.category &&
          other.ownership == this.ownership &&
          other.vendorId == this.vendorId &&
          other.currentProjectId == this.currentProjectId &&
          other.rentalBasis == this.rentalBasis &&
          other.standardRate == this.standardRate &&
          other.fuelPolicy == this.fuelPolicy &&
          other.operatorName == this.operatorName &&
          other.operatorContact == this.operatorContact &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EquipmentsCompanion extends UpdateCompanion<Equipment> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> assetOrRegNumber;
  final Value<String> category;
  final Value<EquipmentOwnership> ownership;
  final Value<int?> vendorId;
  final Value<int?> currentProjectId;
  final Value<EquipmentRentalBasis> rentalBasis;
  final Value<double> standardRate;
  final Value<EquipmentFuelPolicy> fuelPolicy;
  final Value<String?> operatorName;
  final Value<String?> operatorContact;
  final Value<EquipmentStatus> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EquipmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.assetOrRegNumber = const Value.absent(),
    this.category = const Value.absent(),
    this.ownership = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.currentProjectId = const Value.absent(),
    this.rentalBasis = const Value.absent(),
    this.standardRate = const Value.absent(),
    this.fuelPolicy = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.operatorContact = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EquipmentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String assetOrRegNumber,
    this.category = const Value.absent(),
    this.ownership = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.currentProjectId = const Value.absent(),
    this.rentalBasis = const Value.absent(),
    this.standardRate = const Value.absent(),
    this.fuelPolicy = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.operatorContact = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        assetOrRegNumber = Value(assetOrRegNumber);
  static Insertable<Equipment> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? assetOrRegNumber,
    Expression<String>? category,
    Expression<String>? ownership,
    Expression<int>? vendorId,
    Expression<int>? currentProjectId,
    Expression<String>? rentalBasis,
    Expression<double>? standardRate,
    Expression<String>? fuelPolicy,
    Expression<String>? operatorName,
    Expression<String>? operatorContact,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (assetOrRegNumber != null) 'asset_or_reg_number': assetOrRegNumber,
      if (category != null) 'category': category,
      if (ownership != null) 'ownership': ownership,
      if (vendorId != null) 'vendor_id': vendorId,
      if (currentProjectId != null) 'current_project_id': currentProjectId,
      if (rentalBasis != null) 'rental_basis': rentalBasis,
      if (standardRate != null) 'standard_rate': standardRate,
      if (fuelPolicy != null) 'fuel_policy': fuelPolicy,
      if (operatorName != null) 'operator_name': operatorName,
      if (operatorContact != null) 'operator_contact': operatorContact,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EquipmentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? assetOrRegNumber,
      Value<String>? category,
      Value<EquipmentOwnership>? ownership,
      Value<int?>? vendorId,
      Value<int?>? currentProjectId,
      Value<EquipmentRentalBasis>? rentalBasis,
      Value<double>? standardRate,
      Value<EquipmentFuelPolicy>? fuelPolicy,
      Value<String?>? operatorName,
      Value<String?>? operatorContact,
      Value<EquipmentStatus>? status,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return EquipmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      assetOrRegNumber: assetOrRegNumber ?? this.assetOrRegNumber,
      category: category ?? this.category,
      ownership: ownership ?? this.ownership,
      vendorId: vendorId ?? this.vendorId,
      currentProjectId: currentProjectId ?? this.currentProjectId,
      rentalBasis: rentalBasis ?? this.rentalBasis,
      standardRate: standardRate ?? this.standardRate,
      fuelPolicy: fuelPolicy ?? this.fuelPolicy,
      operatorName: operatorName ?? this.operatorName,
      operatorContact: operatorContact ?? this.operatorContact,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (assetOrRegNumber.present) {
      map['asset_or_reg_number'] = Variable<String>(assetOrRegNumber.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (ownership.present) {
      map['ownership'] = Variable<String>(
          $EquipmentsTable.$converterownership.toSql(ownership.value));
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<int>(vendorId.value);
    }
    if (currentProjectId.present) {
      map['current_project_id'] = Variable<int>(currentProjectId.value);
    }
    if (rentalBasis.present) {
      map['rental_basis'] = Variable<String>(
          $EquipmentsTable.$converterrentalBasis.toSql(rentalBasis.value));
    }
    if (standardRate.present) {
      map['standard_rate'] = Variable<double>(standardRate.value);
    }
    if (fuelPolicy.present) {
      map['fuel_policy'] = Variable<String>(
          $EquipmentsTable.$converterfuelPolicy.toSql(fuelPolicy.value));
    }
    if (operatorName.present) {
      map['operator_name'] = Variable<String>(operatorName.value);
    }
    if (operatorContact.present) {
      map['operator_contact'] = Variable<String>(operatorContact.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
          $EquipmentsTable.$converterstatus.toSql(status.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('assetOrRegNumber: $assetOrRegNumber, ')
          ..write('category: $category, ')
          ..write('ownership: $ownership, ')
          ..write('vendorId: $vendorId, ')
          ..write('currentProjectId: $currentProjectId, ')
          ..write('rentalBasis: $rentalBasis, ')
          ..write('standardRate: $standardRate, ')
          ..write('fuelPolicy: $fuelPolicy, ')
          ..write('operatorName: $operatorName, ')
          ..write('operatorContact: $operatorContact, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EquipmentLogsTable extends EquipmentLogs
    with TableInfo<$EquipmentLogsTable, EquipmentLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _equipmentIdMeta =
      const VerificationMeta('equipmentId');
  @override
  late final GeneratedColumn<int> equipmentId = GeneratedColumn<int>(
      'equipment_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES equipments (id) ON DELETE CASCADE'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE CASCADE'));
  static const VerificationMeta _logDateMeta =
      const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
      'log_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startReadingMeta =
      const VerificationMeta('startReading');
  @override
  late final GeneratedColumn<double> startReading = GeneratedColumn<double>(
      'start_reading', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _endReadingMeta =
      const VerificationMeta('endReading');
  @override
  late final GeneratedColumn<double> endReading = GeneratedColumn<double>(
      'end_reading', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalUnitsLoggedMeta =
      const VerificationMeta('totalUnitsLogged');
  @override
  late final GeneratedColumn<double> totalUnitsLogged = GeneratedColumn<double>(
      'total_units_logged', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _breakdownUnitsMeta =
      const VerificationMeta('breakdownUnits');
  @override
  late final GeneratedColumn<double> breakdownUnits = GeneratedColumn<double>(
      'breakdown_units', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _billableUnitsMeta =
      const VerificationMeta('billableUnits');
  @override
  late final GeneratedColumn<double> billableUnits = GeneratedColumn<double>(
      'billable_units', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitRateMeta =
      const VerificationMeta('unitRate');
  @override
  late final GeneratedColumn<double> unitRate = GeneratedColumn<double>(
      'unit_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _grossRentalCostMeta =
      const VerificationMeta('grossRentalCost');
  @override
  late final GeneratedColumn<double> grossRentalCost = GeneratedColumn<double>(
      'gross_rental_cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fuelLitresIssuedMeta =
      const VerificationMeta('fuelLitresIssued');
  @override
  late final GeneratedColumn<double> fuelLitresIssued = GeneratedColumn<double>(
      'fuel_litres_issued', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fuelRatePerLitreMeta =
      const VerificationMeta('fuelRatePerLitre');
  @override
  late final GeneratedColumn<double> fuelRatePerLitre = GeneratedColumn<double>(
      'fuel_rate_per_litre', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _fuelCostDeductionMeta =
      const VerificationMeta('fuelCostDeduction');
  @override
  late final GeneratedColumn<double> fuelCostDeduction =
      GeneratedColumn<double>('fuel_cost_deduction', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _netPayableAmountMeta =
      const VerificationMeta('netPayableAmount');
  @override
  late final GeneratedColumn<double> netPayableAmount = GeneratedColumn<double>(
      'net_payable_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _workDescriptionMeta =
      const VerificationMeta('workDescription');
  @override
  late final GeneratedColumn<String> workDescription = GeneratedColumn<String>(
      'work_description', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _operatorNameMeta =
      const VerificationMeta('operatorName');
  @override
  late final GeneratedColumn<String> operatorName = GeneratedColumn<String>(
      'operator_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supervisorVerifiedMeta =
      const VerificationMeta('supervisorVerified');
  @override
  late final GeneratedColumn<bool> supervisorVerified = GeneratedColumn<bool>(
      'supervisor_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("supervisor_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
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
        equipmentId,
        projectId,
        logDate,
        startReading,
        endReading,
        totalUnitsLogged,
        breakdownUnits,
        billableUnits,
        unitRate,
        grossRentalCost,
        fuelLitresIssued,
        fuelRatePerLitre,
        fuelCostDeduction,
        netPayableAmount,
        workDescription,
        operatorName,
        supervisorVerified,
        notes,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipment_logs';
  @override
  VerificationContext validateIntegrity(Insertable<EquipmentLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('equipment_id')) {
      context.handle(
          _equipmentIdMeta,
          equipmentId.isAcceptableOrUnknown(
              data['equipment_id']!, _equipmentIdMeta));
    } else if (isInserting) {
      context.missing(_equipmentIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta,
          logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('start_reading')) {
      context.handle(
          _startReadingMeta,
          startReading.isAcceptableOrUnknown(
              data['start_reading']!, _startReadingMeta));
    }
    if (data.containsKey('end_reading')) {
      context.handle(
          _endReadingMeta,
          endReading.isAcceptableOrUnknown(
              data['end_reading']!, _endReadingMeta));
    }
    if (data.containsKey('total_units_logged')) {
      context.handle(
          _totalUnitsLoggedMeta,
          totalUnitsLogged.isAcceptableOrUnknown(
              data['total_units_logged']!, _totalUnitsLoggedMeta));
    }
    if (data.containsKey('breakdown_units')) {
      context.handle(
          _breakdownUnitsMeta,
          breakdownUnits.isAcceptableOrUnknown(
              data['breakdown_units']!, _breakdownUnitsMeta));
    }
    if (data.containsKey('billable_units')) {
      context.handle(
          _billableUnitsMeta,
          billableUnits.isAcceptableOrUnknown(
              data['billable_units']!, _billableUnitsMeta));
    }
    if (data.containsKey('unit_rate')) {
      context.handle(_unitRateMeta,
          unitRate.isAcceptableOrUnknown(data['unit_rate']!, _unitRateMeta));
    }
    if (data.containsKey('gross_rental_cost')) {
      context.handle(
          _grossRentalCostMeta,
          grossRentalCost.isAcceptableOrUnknown(
              data['gross_rental_cost']!, _grossRentalCostMeta));
    }
    if (data.containsKey('fuel_litres_issued')) {
      context.handle(
          _fuelLitresIssuedMeta,
          fuelLitresIssued.isAcceptableOrUnknown(
              data['fuel_litres_issued']!, _fuelLitresIssuedMeta));
    }
    if (data.containsKey('fuel_rate_per_litre')) {
      context.handle(
          _fuelRatePerLitreMeta,
          fuelRatePerLitre.isAcceptableOrUnknown(
              data['fuel_rate_per_litre']!, _fuelRatePerLitreMeta));
    }
    if (data.containsKey('fuel_cost_deduction')) {
      context.handle(
          _fuelCostDeductionMeta,
          fuelCostDeduction.isAcceptableOrUnknown(
              data['fuel_cost_deduction']!, _fuelCostDeductionMeta));
    }
    if (data.containsKey('net_payable_amount')) {
      context.handle(
          _netPayableAmountMeta,
          netPayableAmount.isAcceptableOrUnknown(
              data['net_payable_amount']!, _netPayableAmountMeta));
    }
    if (data.containsKey('work_description')) {
      context.handle(
          _workDescriptionMeta,
          workDescription.isAcceptableOrUnknown(
              data['work_description']!, _workDescriptionMeta));
    } else if (isInserting) {
      context.missing(_workDescriptionMeta);
    }
    if (data.containsKey('operator_name')) {
      context.handle(
          _operatorNameMeta,
          operatorName.isAcceptableOrUnknown(
              data['operator_name']!, _operatorNameMeta));
    }
    if (data.containsKey('supervisor_verified')) {
      context.handle(
          _supervisorVerifiedMeta,
          supervisorVerified.isAcceptableOrUnknown(
              data['supervisor_verified']!, _supervisorVerifiedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
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
  EquipmentLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EquipmentLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      equipmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}equipment_id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      logDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}log_date'])!,
      startReading: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}start_reading'])!,
      endReading: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}end_reading'])!,
      totalUnitsLogged: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_units_logged'])!,
      breakdownUnits: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}breakdown_units'])!,
      billableUnits: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}billable_units'])!,
      unitRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_rate'])!,
      grossRentalCost: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}gross_rental_cost'])!,
      fuelLitresIssued: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}fuel_litres_issued'])!,
      fuelRatePerLitre: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}fuel_rate_per_litre'])!,
      fuelCostDeduction: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}fuel_cost_deduction'])!,
      netPayableAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}net_payable_amount'])!,
      workDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}work_description'])!,
      operatorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_name']),
      supervisorVerified: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}supervisor_verified'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EquipmentLogsTable createAlias(String alias) {
    return $EquipmentLogsTable(attachedDatabase, alias);
  }
}

class EquipmentLog extends DataClass implements Insertable<EquipmentLog> {
  final int id;
  final int equipmentId;
  final int projectId;
  final DateTime logDate;
  final double startReading;
  final double endReading;
  final double totalUnitsLogged;
  final double breakdownUnits;
  final double billableUnits;
  final double unitRate;
  final double grossRentalCost;
  final double fuelLitresIssued;
  final double fuelRatePerLitre;
  final double fuelCostDeduction;
  final double netPayableAmount;
  final String workDescription;
  final String? operatorName;
  final bool supervisorVerified;
  final String? notes;
  final DateTime createdAt;
  const EquipmentLog(
      {required this.id,
      required this.equipmentId,
      required this.projectId,
      required this.logDate,
      required this.startReading,
      required this.endReading,
      required this.totalUnitsLogged,
      required this.breakdownUnits,
      required this.billableUnits,
      required this.unitRate,
      required this.grossRentalCost,
      required this.fuelLitresIssued,
      required this.fuelRatePerLitre,
      required this.fuelCostDeduction,
      required this.netPayableAmount,
      required this.workDescription,
      this.operatorName,
      required this.supervisorVerified,
      this.notes,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['equipment_id'] = Variable<int>(equipmentId);
    map['project_id'] = Variable<int>(projectId);
    map['log_date'] = Variable<DateTime>(logDate);
    map['start_reading'] = Variable<double>(startReading);
    map['end_reading'] = Variable<double>(endReading);
    map['total_units_logged'] = Variable<double>(totalUnitsLogged);
    map['breakdown_units'] = Variable<double>(breakdownUnits);
    map['billable_units'] = Variable<double>(billableUnits);
    map['unit_rate'] = Variable<double>(unitRate);
    map['gross_rental_cost'] = Variable<double>(grossRentalCost);
    map['fuel_litres_issued'] = Variable<double>(fuelLitresIssued);
    map['fuel_rate_per_litre'] = Variable<double>(fuelRatePerLitre);
    map['fuel_cost_deduction'] = Variable<double>(fuelCostDeduction);
    map['net_payable_amount'] = Variable<double>(netPayableAmount);
    map['work_description'] = Variable<String>(workDescription);
    if (!nullToAbsent || operatorName != null) {
      map['operator_name'] = Variable<String>(operatorName);
    }
    map['supervisor_verified'] = Variable<bool>(supervisorVerified);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EquipmentLogsCompanion toCompanion(bool nullToAbsent) {
    return EquipmentLogsCompanion(
      id: Value(id),
      equipmentId: Value(equipmentId),
      projectId: Value(projectId),
      logDate: Value(logDate),
      startReading: Value(startReading),
      endReading: Value(endReading),
      totalUnitsLogged: Value(totalUnitsLogged),
      breakdownUnits: Value(breakdownUnits),
      billableUnits: Value(billableUnits),
      unitRate: Value(unitRate),
      grossRentalCost: Value(grossRentalCost),
      fuelLitresIssued: Value(fuelLitresIssued),
      fuelRatePerLitre: Value(fuelRatePerLitre),
      fuelCostDeduction: Value(fuelCostDeduction),
      netPayableAmount: Value(netPayableAmount),
      workDescription: Value(workDescription),
      operatorName: operatorName == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorName),
      supervisorVerified: Value(supervisorVerified),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory EquipmentLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EquipmentLog(
      id: serializer.fromJson<int>(json['id']),
      equipmentId: serializer.fromJson<int>(json['equipmentId']),
      projectId: serializer.fromJson<int>(json['projectId']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      startReading: serializer.fromJson<double>(json['startReading']),
      endReading: serializer.fromJson<double>(json['endReading']),
      totalUnitsLogged: serializer.fromJson<double>(json['totalUnitsLogged']),
      breakdownUnits: serializer.fromJson<double>(json['breakdownUnits']),
      billableUnits: serializer.fromJson<double>(json['billableUnits']),
      unitRate: serializer.fromJson<double>(json['unitRate']),
      grossRentalCost: serializer.fromJson<double>(json['grossRentalCost']),
      fuelLitresIssued: serializer.fromJson<double>(json['fuelLitresIssued']),
      fuelRatePerLitre: serializer.fromJson<double>(json['fuelRatePerLitre']),
      fuelCostDeduction: serializer.fromJson<double>(json['fuelCostDeduction']),
      netPayableAmount: serializer.fromJson<double>(json['netPayableAmount']),
      workDescription: serializer.fromJson<String>(json['workDescription']),
      operatorName: serializer.fromJson<String?>(json['operatorName']),
      supervisorVerified: serializer.fromJson<bool>(json['supervisorVerified']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'equipmentId': serializer.toJson<int>(equipmentId),
      'projectId': serializer.toJson<int>(projectId),
      'logDate': serializer.toJson<DateTime>(logDate),
      'startReading': serializer.toJson<double>(startReading),
      'endReading': serializer.toJson<double>(endReading),
      'totalUnitsLogged': serializer.toJson<double>(totalUnitsLogged),
      'breakdownUnits': serializer.toJson<double>(breakdownUnits),
      'billableUnits': serializer.toJson<double>(billableUnits),
      'unitRate': serializer.toJson<double>(unitRate),
      'grossRentalCost': serializer.toJson<double>(grossRentalCost),
      'fuelLitresIssued': serializer.toJson<double>(fuelLitresIssued),
      'fuelRatePerLitre': serializer.toJson<double>(fuelRatePerLitre),
      'fuelCostDeduction': serializer.toJson<double>(fuelCostDeduction),
      'netPayableAmount': serializer.toJson<double>(netPayableAmount),
      'workDescription': serializer.toJson<String>(workDescription),
      'operatorName': serializer.toJson<String?>(operatorName),
      'supervisorVerified': serializer.toJson<bool>(supervisorVerified),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EquipmentLog copyWith(
          {int? id,
          int? equipmentId,
          int? projectId,
          DateTime? logDate,
          double? startReading,
          double? endReading,
          double? totalUnitsLogged,
          double? breakdownUnits,
          double? billableUnits,
          double? unitRate,
          double? grossRentalCost,
          double? fuelLitresIssued,
          double? fuelRatePerLitre,
          double? fuelCostDeduction,
          double? netPayableAmount,
          String? workDescription,
          Value<String?> operatorName = const Value.absent(),
          bool? supervisorVerified,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt}) =>
      EquipmentLog(
        id: id ?? this.id,
        equipmentId: equipmentId ?? this.equipmentId,
        projectId: projectId ?? this.projectId,
        logDate: logDate ?? this.logDate,
        startReading: startReading ?? this.startReading,
        endReading: endReading ?? this.endReading,
        totalUnitsLogged: totalUnitsLogged ?? this.totalUnitsLogged,
        breakdownUnits: breakdownUnits ?? this.breakdownUnits,
        billableUnits: billableUnits ?? this.billableUnits,
        unitRate: unitRate ?? this.unitRate,
        grossRentalCost: grossRentalCost ?? this.grossRentalCost,
        fuelLitresIssued: fuelLitresIssued ?? this.fuelLitresIssued,
        fuelRatePerLitre: fuelRatePerLitre ?? this.fuelRatePerLitre,
        fuelCostDeduction: fuelCostDeduction ?? this.fuelCostDeduction,
        netPayableAmount: netPayableAmount ?? this.netPayableAmount,
        workDescription: workDescription ?? this.workDescription,
        operatorName:
            operatorName.present ? operatorName.value : this.operatorName,
        supervisorVerified: supervisorVerified ?? this.supervisorVerified,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
  EquipmentLog copyWithCompanion(EquipmentLogsCompanion data) {
    return EquipmentLog(
      id: data.id.present ? data.id.value : this.id,
      equipmentId:
          data.equipmentId.present ? data.equipmentId.value : this.equipmentId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      startReading: data.startReading.present
          ? data.startReading.value
          : this.startReading,
      endReading:
          data.endReading.present ? data.endReading.value : this.endReading,
      totalUnitsLogged: data.totalUnitsLogged.present
          ? data.totalUnitsLogged.value
          : this.totalUnitsLogged,
      breakdownUnits: data.breakdownUnits.present
          ? data.breakdownUnits.value
          : this.breakdownUnits,
      billableUnits: data.billableUnits.present
          ? data.billableUnits.value
          : this.billableUnits,
      unitRate: data.unitRate.present ? data.unitRate.value : this.unitRate,
      grossRentalCost: data.grossRentalCost.present
          ? data.grossRentalCost.value
          : this.grossRentalCost,
      fuelLitresIssued: data.fuelLitresIssued.present
          ? data.fuelLitresIssued.value
          : this.fuelLitresIssued,
      fuelRatePerLitre: data.fuelRatePerLitre.present
          ? data.fuelRatePerLitre.value
          : this.fuelRatePerLitre,
      fuelCostDeduction: data.fuelCostDeduction.present
          ? data.fuelCostDeduction.value
          : this.fuelCostDeduction,
      netPayableAmount: data.netPayableAmount.present
          ? data.netPayableAmount.value
          : this.netPayableAmount,
      workDescription: data.workDescription.present
          ? data.workDescription.value
          : this.workDescription,
      operatorName: data.operatorName.present
          ? data.operatorName.value
          : this.operatorName,
      supervisorVerified: data.supervisorVerified.present
          ? data.supervisorVerified.value
          : this.supervisorVerified,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentLog(')
          ..write('id: $id, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('projectId: $projectId, ')
          ..write('logDate: $logDate, ')
          ..write('startReading: $startReading, ')
          ..write('endReading: $endReading, ')
          ..write('totalUnitsLogged: $totalUnitsLogged, ')
          ..write('breakdownUnits: $breakdownUnits, ')
          ..write('billableUnits: $billableUnits, ')
          ..write('unitRate: $unitRate, ')
          ..write('grossRentalCost: $grossRentalCost, ')
          ..write('fuelLitresIssued: $fuelLitresIssued, ')
          ..write('fuelRatePerLitre: $fuelRatePerLitre, ')
          ..write('fuelCostDeduction: $fuelCostDeduction, ')
          ..write('netPayableAmount: $netPayableAmount, ')
          ..write('workDescription: $workDescription, ')
          ..write('operatorName: $operatorName, ')
          ..write('supervisorVerified: $supervisorVerified, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      equipmentId,
      projectId,
      logDate,
      startReading,
      endReading,
      totalUnitsLogged,
      breakdownUnits,
      billableUnits,
      unitRate,
      grossRentalCost,
      fuelLitresIssued,
      fuelRatePerLitre,
      fuelCostDeduction,
      netPayableAmount,
      workDescription,
      operatorName,
      supervisorVerified,
      notes,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EquipmentLog &&
          other.id == this.id &&
          other.equipmentId == this.equipmentId &&
          other.projectId == this.projectId &&
          other.logDate == this.logDate &&
          other.startReading == this.startReading &&
          other.endReading == this.endReading &&
          other.totalUnitsLogged == this.totalUnitsLogged &&
          other.breakdownUnits == this.breakdownUnits &&
          other.billableUnits == this.billableUnits &&
          other.unitRate == this.unitRate &&
          other.grossRentalCost == this.grossRentalCost &&
          other.fuelLitresIssued == this.fuelLitresIssued &&
          other.fuelRatePerLitre == this.fuelRatePerLitre &&
          other.fuelCostDeduction == this.fuelCostDeduction &&
          other.netPayableAmount == this.netPayableAmount &&
          other.workDescription == this.workDescription &&
          other.operatorName == this.operatorName &&
          other.supervisorVerified == this.supervisorVerified &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class EquipmentLogsCompanion extends UpdateCompanion<EquipmentLog> {
  final Value<int> id;
  final Value<int> equipmentId;
  final Value<int> projectId;
  final Value<DateTime> logDate;
  final Value<double> startReading;
  final Value<double> endReading;
  final Value<double> totalUnitsLogged;
  final Value<double> breakdownUnits;
  final Value<double> billableUnits;
  final Value<double> unitRate;
  final Value<double> grossRentalCost;
  final Value<double> fuelLitresIssued;
  final Value<double> fuelRatePerLitre;
  final Value<double> fuelCostDeduction;
  final Value<double> netPayableAmount;
  final Value<String> workDescription;
  final Value<String?> operatorName;
  final Value<bool> supervisorVerified;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const EquipmentLogsCompanion({
    this.id = const Value.absent(),
    this.equipmentId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.startReading = const Value.absent(),
    this.endReading = const Value.absent(),
    this.totalUnitsLogged = const Value.absent(),
    this.breakdownUnits = const Value.absent(),
    this.billableUnits = const Value.absent(),
    this.unitRate = const Value.absent(),
    this.grossRentalCost = const Value.absent(),
    this.fuelLitresIssued = const Value.absent(),
    this.fuelRatePerLitre = const Value.absent(),
    this.fuelCostDeduction = const Value.absent(),
    this.netPayableAmount = const Value.absent(),
    this.workDescription = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.supervisorVerified = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EquipmentLogsCompanion.insert({
    this.id = const Value.absent(),
    required int equipmentId,
    required int projectId,
    required DateTime logDate,
    this.startReading = const Value.absent(),
    this.endReading = const Value.absent(),
    this.totalUnitsLogged = const Value.absent(),
    this.breakdownUnits = const Value.absent(),
    this.billableUnits = const Value.absent(),
    this.unitRate = const Value.absent(),
    this.grossRentalCost = const Value.absent(),
    this.fuelLitresIssued = const Value.absent(),
    this.fuelRatePerLitre = const Value.absent(),
    this.fuelCostDeduction = const Value.absent(),
    this.netPayableAmount = const Value.absent(),
    required String workDescription,
    this.operatorName = const Value.absent(),
    this.supervisorVerified = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : equipmentId = Value(equipmentId),
        projectId = Value(projectId),
        logDate = Value(logDate),
        workDescription = Value(workDescription);
  static Insertable<EquipmentLog> custom({
    Expression<int>? id,
    Expression<int>? equipmentId,
    Expression<int>? projectId,
    Expression<DateTime>? logDate,
    Expression<double>? startReading,
    Expression<double>? endReading,
    Expression<double>? totalUnitsLogged,
    Expression<double>? breakdownUnits,
    Expression<double>? billableUnits,
    Expression<double>? unitRate,
    Expression<double>? grossRentalCost,
    Expression<double>? fuelLitresIssued,
    Expression<double>? fuelRatePerLitre,
    Expression<double>? fuelCostDeduction,
    Expression<double>? netPayableAmount,
    Expression<String>? workDescription,
    Expression<String>? operatorName,
    Expression<bool>? supervisorVerified,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (equipmentId != null) 'equipment_id': equipmentId,
      if (projectId != null) 'project_id': projectId,
      if (logDate != null) 'log_date': logDate,
      if (startReading != null) 'start_reading': startReading,
      if (endReading != null) 'end_reading': endReading,
      if (totalUnitsLogged != null) 'total_units_logged': totalUnitsLogged,
      if (breakdownUnits != null) 'breakdown_units': breakdownUnits,
      if (billableUnits != null) 'billable_units': billableUnits,
      if (unitRate != null) 'unit_rate': unitRate,
      if (grossRentalCost != null) 'gross_rental_cost': grossRentalCost,
      if (fuelLitresIssued != null) 'fuel_litres_issued': fuelLitresIssued,
      if (fuelRatePerLitre != null) 'fuel_rate_per_litre': fuelRatePerLitre,
      if (fuelCostDeduction != null) 'fuel_cost_deduction': fuelCostDeduction,
      if (netPayableAmount != null) 'net_payable_amount': netPayableAmount,
      if (workDescription != null) 'work_description': workDescription,
      if (operatorName != null) 'operator_name': operatorName,
      if (supervisorVerified != null) 'supervisor_verified': supervisorVerified,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EquipmentLogsCompanion copyWith(
      {Value<int>? id,
      Value<int>? equipmentId,
      Value<int>? projectId,
      Value<DateTime>? logDate,
      Value<double>? startReading,
      Value<double>? endReading,
      Value<double>? totalUnitsLogged,
      Value<double>? breakdownUnits,
      Value<double>? billableUnits,
      Value<double>? unitRate,
      Value<double>? grossRentalCost,
      Value<double>? fuelLitresIssued,
      Value<double>? fuelRatePerLitre,
      Value<double>? fuelCostDeduction,
      Value<double>? netPayableAmount,
      Value<String>? workDescription,
      Value<String?>? operatorName,
      Value<bool>? supervisorVerified,
      Value<String?>? notes,
      Value<DateTime>? createdAt}) {
    return EquipmentLogsCompanion(
      id: id ?? this.id,
      equipmentId: equipmentId ?? this.equipmentId,
      projectId: projectId ?? this.projectId,
      logDate: logDate ?? this.logDate,
      startReading: startReading ?? this.startReading,
      endReading: endReading ?? this.endReading,
      totalUnitsLogged: totalUnitsLogged ?? this.totalUnitsLogged,
      breakdownUnits: breakdownUnits ?? this.breakdownUnits,
      billableUnits: billableUnits ?? this.billableUnits,
      unitRate: unitRate ?? this.unitRate,
      grossRentalCost: grossRentalCost ?? this.grossRentalCost,
      fuelLitresIssued: fuelLitresIssued ?? this.fuelLitresIssued,
      fuelRatePerLitre: fuelRatePerLitre ?? this.fuelRatePerLitre,
      fuelCostDeduction: fuelCostDeduction ?? this.fuelCostDeduction,
      netPayableAmount: netPayableAmount ?? this.netPayableAmount,
      workDescription: workDescription ?? this.workDescription,
      operatorName: operatorName ?? this.operatorName,
      supervisorVerified: supervisorVerified ?? this.supervisorVerified,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (equipmentId.present) {
      map['equipment_id'] = Variable<int>(equipmentId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (startReading.present) {
      map['start_reading'] = Variable<double>(startReading.value);
    }
    if (endReading.present) {
      map['end_reading'] = Variable<double>(endReading.value);
    }
    if (totalUnitsLogged.present) {
      map['total_units_logged'] = Variable<double>(totalUnitsLogged.value);
    }
    if (breakdownUnits.present) {
      map['breakdown_units'] = Variable<double>(breakdownUnits.value);
    }
    if (billableUnits.present) {
      map['billable_units'] = Variable<double>(billableUnits.value);
    }
    if (unitRate.present) {
      map['unit_rate'] = Variable<double>(unitRate.value);
    }
    if (grossRentalCost.present) {
      map['gross_rental_cost'] = Variable<double>(grossRentalCost.value);
    }
    if (fuelLitresIssued.present) {
      map['fuel_litres_issued'] = Variable<double>(fuelLitresIssued.value);
    }
    if (fuelRatePerLitre.present) {
      map['fuel_rate_per_litre'] = Variable<double>(fuelRatePerLitre.value);
    }
    if (fuelCostDeduction.present) {
      map['fuel_cost_deduction'] = Variable<double>(fuelCostDeduction.value);
    }
    if (netPayableAmount.present) {
      map['net_payable_amount'] = Variable<double>(netPayableAmount.value);
    }
    if (workDescription.present) {
      map['work_description'] = Variable<String>(workDescription.value);
    }
    if (operatorName.present) {
      map['operator_name'] = Variable<String>(operatorName.value);
    }
    if (supervisorVerified.present) {
      map['supervisor_verified'] = Variable<bool>(supervisorVerified.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentLogsCompanion(')
          ..write('id: $id, ')
          ..write('equipmentId: $equipmentId, ')
          ..write('projectId: $projectId, ')
          ..write('logDate: $logDate, ')
          ..write('startReading: $startReading, ')
          ..write('endReading: $endReading, ')
          ..write('totalUnitsLogged: $totalUnitsLogged, ')
          ..write('breakdownUnits: $breakdownUnits, ')
          ..write('billableUnits: $billableUnits, ')
          ..write('unitRate: $unitRate, ')
          ..write('grossRentalCost: $grossRentalCost, ')
          ..write('fuelLitresIssued: $fuelLitresIssued, ')
          ..write('fuelRatePerLitre: $fuelRatePerLitre, ')
          ..write('fuelCostDeduction: $fuelCostDeduction, ')
          ..write('netPayableAmount: $netPayableAmount, ')
          ..write('workDescription: $workDescription, ')
          ..write('operatorName: $operatorName, ')
          ..write('supervisorVerified: $supervisorVerified, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PettyCashWalletsTable extends PettyCashWallets
    with TableInfo<$PettyCashWalletsTable, PettyCashWallet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PettyCashWalletsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _supervisorNameMeta =
      const VerificationMeta('supervisorName');
  @override
  late final GeneratedColumn<String> supervisorName = GeneratedColumn<String>(
      'supervisor_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _assignedProjectIdMeta =
      const VerificationMeta('assignedProjectId');
  @override
  late final GeneratedColumn<int> assignedProjectId = GeneratedColumn<int>(
      'assigned_project_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE SET NULL'));
  static const VerificationMeta _maxFloatLimitMeta =
      const VerificationMeta('maxFloatLimit');
  @override
  late final GeneratedColumn<double> maxFloatLimit = GeneratedColumn<double>(
      'max_float_limit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(50000.0));
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        supervisorName,
        phone,
        assignedProjectId,
        maxFloatLimit,
        isActive,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'petty_cash_wallets';
  @override
  VerificationContext validateIntegrity(Insertable<PettyCashWallet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supervisor_name')) {
      context.handle(
          _supervisorNameMeta,
          supervisorName.isAcceptableOrUnknown(
              data['supervisor_name']!, _supervisorNameMeta));
    } else if (isInserting) {
      context.missing(_supervisorNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('assigned_project_id')) {
      context.handle(
          _assignedProjectIdMeta,
          assignedProjectId.isAcceptableOrUnknown(
              data['assigned_project_id']!, _assignedProjectIdMeta));
    }
    if (data.containsKey('max_float_limit')) {
      context.handle(
          _maxFloatLimitMeta,
          maxFloatLimit.isAcceptableOrUnknown(
              data['max_float_limit']!, _maxFloatLimitMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PettyCashWallet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PettyCashWallet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      supervisorName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}supervisor_name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      assignedProjectId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}assigned_project_id']),
      maxFloatLimit: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}max_float_limit'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PettyCashWalletsTable createAlias(String alias) {
    return $PettyCashWalletsTable(attachedDatabase, alias);
  }
}

class PettyCashWallet extends DataClass implements Insertable<PettyCashWallet> {
  final int id;
  final String supervisorName;
  final String phone;
  final int? assignedProjectId;
  final double maxFloatLimit;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PettyCashWallet(
      {required this.id,
      required this.supervisorName,
      required this.phone,
      this.assignedProjectId,
      required this.maxFloatLimit,
      required this.isActive,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['supervisor_name'] = Variable<String>(supervisorName);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || assignedProjectId != null) {
      map['assigned_project_id'] = Variable<int>(assignedProjectId);
    }
    map['max_float_limit'] = Variable<double>(maxFloatLimit);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PettyCashWalletsCompanion toCompanion(bool nullToAbsent) {
    return PettyCashWalletsCompanion(
      id: Value(id),
      supervisorName: Value(supervisorName),
      phone: Value(phone),
      assignedProjectId: assignedProjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedProjectId),
      maxFloatLimit: Value(maxFloatLimit),
      isActive: Value(isActive),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PettyCashWallet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PettyCashWallet(
      id: serializer.fromJson<int>(json['id']),
      supervisorName: serializer.fromJson<String>(json['supervisorName']),
      phone: serializer.fromJson<String>(json['phone']),
      assignedProjectId: serializer.fromJson<int?>(json['assignedProjectId']),
      maxFloatLimit: serializer.fromJson<double>(json['maxFloatLimit']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supervisorName': serializer.toJson<String>(supervisorName),
      'phone': serializer.toJson<String>(phone),
      'assignedProjectId': serializer.toJson<int?>(assignedProjectId),
      'maxFloatLimit': serializer.toJson<double>(maxFloatLimit),
      'isActive': serializer.toJson<bool>(isActive),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PettyCashWallet copyWith(
          {int? id,
          String? supervisorName,
          String? phone,
          Value<int?> assignedProjectId = const Value.absent(),
          double? maxFloatLimit,
          bool? isActive,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PettyCashWallet(
        id: id ?? this.id,
        supervisorName: supervisorName ?? this.supervisorName,
        phone: phone ?? this.phone,
        assignedProjectId: assignedProjectId.present
            ? assignedProjectId.value
            : this.assignedProjectId,
        maxFloatLimit: maxFloatLimit ?? this.maxFloatLimit,
        isActive: isActive ?? this.isActive,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PettyCashWallet copyWithCompanion(PettyCashWalletsCompanion data) {
    return PettyCashWallet(
      id: data.id.present ? data.id.value : this.id,
      supervisorName: data.supervisorName.present
          ? data.supervisorName.value
          : this.supervisorName,
      phone: data.phone.present ? data.phone.value : this.phone,
      assignedProjectId: data.assignedProjectId.present
          ? data.assignedProjectId.value
          : this.assignedProjectId,
      maxFloatLimit: data.maxFloatLimit.present
          ? data.maxFloatLimit.value
          : this.maxFloatLimit,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PettyCashWallet(')
          ..write('id: $id, ')
          ..write('supervisorName: $supervisorName, ')
          ..write('phone: $phone, ')
          ..write('assignedProjectId: $assignedProjectId, ')
          ..write('maxFloatLimit: $maxFloatLimit, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, supervisorName, phone, assignedProjectId,
      maxFloatLimit, isActive, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PettyCashWallet &&
          other.id == this.id &&
          other.supervisorName == this.supervisorName &&
          other.phone == this.phone &&
          other.assignedProjectId == this.assignedProjectId &&
          other.maxFloatLimit == this.maxFloatLimit &&
          other.isActive == this.isActive &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PettyCashWalletsCompanion extends UpdateCompanion<PettyCashWallet> {
  final Value<int> id;
  final Value<String> supervisorName;
  final Value<String> phone;
  final Value<int?> assignedProjectId;
  final Value<double> maxFloatLimit;
  final Value<bool> isActive;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PettyCashWalletsCompanion({
    this.id = const Value.absent(),
    this.supervisorName = const Value.absent(),
    this.phone = const Value.absent(),
    this.assignedProjectId = const Value.absent(),
    this.maxFloatLimit = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PettyCashWalletsCompanion.insert({
    this.id = const Value.absent(),
    required String supervisorName,
    required String phone,
    this.assignedProjectId = const Value.absent(),
    this.maxFloatLimit = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : supervisorName = Value(supervisorName),
        phone = Value(phone);
  static Insertable<PettyCashWallet> custom({
    Expression<int>? id,
    Expression<String>? supervisorName,
    Expression<String>? phone,
    Expression<int>? assignedProjectId,
    Expression<double>? maxFloatLimit,
    Expression<bool>? isActive,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supervisorName != null) 'supervisor_name': supervisorName,
      if (phone != null) 'phone': phone,
      if (assignedProjectId != null) 'assigned_project_id': assignedProjectId,
      if (maxFloatLimit != null) 'max_float_limit': maxFloatLimit,
      if (isActive != null) 'is_active': isActive,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PettyCashWalletsCompanion copyWith(
      {Value<int>? id,
      Value<String>? supervisorName,
      Value<String>? phone,
      Value<int?>? assignedProjectId,
      Value<double>? maxFloatLimit,
      Value<bool>? isActive,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PettyCashWalletsCompanion(
      id: id ?? this.id,
      supervisorName: supervisorName ?? this.supervisorName,
      phone: phone ?? this.phone,
      assignedProjectId: assignedProjectId ?? this.assignedProjectId,
      maxFloatLimit: maxFloatLimit ?? this.maxFloatLimit,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supervisorName.present) {
      map['supervisor_name'] = Variable<String>(supervisorName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (assignedProjectId.present) {
      map['assigned_project_id'] = Variable<int>(assignedProjectId.value);
    }
    if (maxFloatLimit.present) {
      map['max_float_limit'] = Variable<double>(maxFloatLimit.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PettyCashWalletsCompanion(')
          ..write('id: $id, ')
          ..write('supervisorName: $supervisorName, ')
          ..write('phone: $phone, ')
          ..write('assignedProjectId: $assignedProjectId, ')
          ..write('maxFloatLimit: $maxFloatLimit, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PettyCashVouchersTable extends PettyCashVouchers
    with TableInfo<$PettyCashVouchersTable, PettyCashVoucher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PettyCashVouchersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _walletIdMeta =
      const VerificationMeta('walletId');
  @override
  late final GeneratedColumn<int> walletId = GeneratedColumn<int>(
      'wallet_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES petty_cash_wallets (id) ON DELETE CASCADE'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES projects (id) ON DELETE CASCADE'));
  @override
  late final GeneratedColumnWithTypeConverter<PettyCashTxnType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PettyCashTxnType>(
              $PettyCashVouchersTable.$convertertype);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Worker Tea, Food & Refreshments'));
  @override
  late final GeneratedColumnWithTypeConverter<BudgetCostHead, String> costHead =
      GeneratedColumn<String>('cost_head', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: Constant(BudgetCostHead.equipmentOverhead.name))
          .withConverter<BudgetCostHead>(
              $PettyCashVouchersTable.$convertercostHead);
  static const VerificationMeta _voucherNumberMeta =
      const VerificationMeta('voucherNumber');
  @override
  late final GeneratedColumn<String> voucherNumber = GeneratedColumn<String>(
      'voucher_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMode?, String>
      paymentMode = GeneratedColumn<String>('payment_mode', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<PaymentMode?>(
              $PettyCashVouchersTable.$converterpaymentModen);
  static const VerificationMeta _bankAccountIdMeta =
      const VerificationMeta('bankAccountId');
  @override
  late final GeneratedColumn<int> bankAccountId = GeneratedColumn<int>(
      'bank_account_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES bank_accounts (id) ON DELETE SET NULL'));
  static const VerificationMeta _narrationMeta =
      const VerificationMeta('narration');
  @override
  late final GeneratedColumn<String> narration = GeneratedColumn<String>(
      'narration', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _verifiedByMeta =
      const VerificationMeta('verifiedBy');
  @override
  late final GeneratedColumn<String> verifiedBy = GeneratedColumn<String>(
      'verified_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
      'transaction_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES transactions (id) ON DELETE SET NULL'));
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
        walletId,
        projectId,
        type,
        date,
        amount,
        category,
        costHead,
        voucherNumber,
        paymentMode,
        bankAccountId,
        narration,
        verifiedBy,
        transactionId,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'petty_cash_vouchers';
  @override
  VerificationContext validateIntegrity(Insertable<PettyCashVoucher> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wallet_id')) {
      context.handle(_walletIdMeta,
          walletId.isAcceptableOrUnknown(data['wallet_id']!, _walletIdMeta));
    } else if (isInserting) {
      context.missing(_walletIdMeta);
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
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('voucher_number')) {
      context.handle(
          _voucherNumberMeta,
          voucherNumber.isAcceptableOrUnknown(
              data['voucher_number']!, _voucherNumberMeta));
    }
    if (data.containsKey('bank_account_id')) {
      context.handle(
          _bankAccountIdMeta,
          bankAccountId.isAcceptableOrUnknown(
              data['bank_account_id']!, _bankAccountIdMeta));
    }
    if (data.containsKey('narration')) {
      context.handle(_narrationMeta,
          narration.isAcceptableOrUnknown(data['narration']!, _narrationMeta));
    } else if (isInserting) {
      context.missing(_narrationMeta);
    }
    if (data.containsKey('verified_by')) {
      context.handle(
          _verifiedByMeta,
          verifiedBy.isAcceptableOrUnknown(
              data['verified_by']!, _verifiedByMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
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
  PettyCashVoucher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PettyCashVoucher(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      walletId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wallet_id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      type: $PettyCashVouchersTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      costHead: $PettyCashVouchersTable.$convertercostHead.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}cost_head'])!),
      voucherNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voucher_number']),
      paymentMode: $PettyCashVouchersTable.$converterpaymentModen.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}payment_mode'])),
      bankAccountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bank_account_id']),
      narration: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}narration'])!,
      verifiedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verified_by']),
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}transaction_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PettyCashVouchersTable createAlias(String alias) {
    return $PettyCashVouchersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PettyCashTxnType, String, String> $convertertype =
      const EnumNameConverter<PettyCashTxnType>(PettyCashTxnType.values);
  static JsonTypeConverter2<BudgetCostHead, String, String> $convertercostHead =
      const EnumNameConverter<BudgetCostHead>(BudgetCostHead.values);
  static JsonTypeConverter2<PaymentMode, String, String> $converterpaymentMode =
      const EnumNameConverter<PaymentMode>(PaymentMode.values);
  static JsonTypeConverter2<PaymentMode?, String?, String?>
      $converterpaymentModen =
      JsonTypeConverter2.asNullable($converterpaymentMode);
}

class PettyCashVoucher extends DataClass
    implements Insertable<PettyCashVoucher> {
  final int id;
  final int walletId;
  final int projectId;
  final PettyCashTxnType type;
  final DateTime date;
  final double amount;
  final String category;
  final BudgetCostHead costHead;
  final String? voucherNumber;
  final PaymentMode? paymentMode;
  final int? bankAccountId;
  final String narration;
  final String? verifiedBy;
  final int? transactionId;
  final DateTime createdAt;
  const PettyCashVoucher(
      {required this.id,
      required this.walletId,
      required this.projectId,
      required this.type,
      required this.date,
      required this.amount,
      required this.category,
      required this.costHead,
      this.voucherNumber,
      this.paymentMode,
      this.bankAccountId,
      required this.narration,
      this.verifiedBy,
      this.transactionId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wallet_id'] = Variable<int>(walletId);
    map['project_id'] = Variable<int>(projectId);
    {
      map['type'] =
          Variable<String>($PettyCashVouchersTable.$convertertype.toSql(type));
    }
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    {
      map['cost_head'] = Variable<String>(
          $PettyCashVouchersTable.$convertercostHead.toSql(costHead));
    }
    if (!nullToAbsent || voucherNumber != null) {
      map['voucher_number'] = Variable<String>(voucherNumber);
    }
    if (!nullToAbsent || paymentMode != null) {
      map['payment_mode'] = Variable<String>(
          $PettyCashVouchersTable.$converterpaymentModen.toSql(paymentMode));
    }
    if (!nullToAbsent || bankAccountId != null) {
      map['bank_account_id'] = Variable<int>(bankAccountId);
    }
    map['narration'] = Variable<String>(narration);
    if (!nullToAbsent || verifiedBy != null) {
      map['verified_by'] = Variable<String>(verifiedBy);
    }
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<int>(transactionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PettyCashVouchersCompanion toCompanion(bool nullToAbsent) {
    return PettyCashVouchersCompanion(
      id: Value(id),
      walletId: Value(walletId),
      projectId: Value(projectId),
      type: Value(type),
      date: Value(date),
      amount: Value(amount),
      category: Value(category),
      costHead: Value(costHead),
      voucherNumber: voucherNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(voucherNumber),
      paymentMode: paymentMode == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMode),
      bankAccountId: bankAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccountId),
      narration: Value(narration),
      verifiedBy: verifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedBy),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      createdAt: Value(createdAt),
    );
  }

  factory PettyCashVoucher.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PettyCashVoucher(
      id: serializer.fromJson<int>(json['id']),
      walletId: serializer.fromJson<int>(json['walletId']),
      projectId: serializer.fromJson<int>(json['projectId']),
      type: $PettyCashVouchersTable.$convertertype
          .fromJson(serializer.fromJson<String>(json['type'])),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      costHead: $PettyCashVouchersTable.$convertercostHead
          .fromJson(serializer.fromJson<String>(json['costHead'])),
      voucherNumber: serializer.fromJson<String?>(json['voucherNumber']),
      paymentMode: $PettyCashVouchersTable.$converterpaymentModen
          .fromJson(serializer.fromJson<String?>(json['paymentMode'])),
      bankAccountId: serializer.fromJson<int?>(json['bankAccountId']),
      narration: serializer.fromJson<String>(json['narration']),
      verifiedBy: serializer.fromJson<String?>(json['verifiedBy']),
      transactionId: serializer.fromJson<int?>(json['transactionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'walletId': serializer.toJson<int>(walletId),
      'projectId': serializer.toJson<int>(projectId),
      'type': serializer
          .toJson<String>($PettyCashVouchersTable.$convertertype.toJson(type)),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'costHead': serializer.toJson<String>(
          $PettyCashVouchersTable.$convertercostHead.toJson(costHead)),
      'voucherNumber': serializer.toJson<String?>(voucherNumber),
      'paymentMode': serializer.toJson<String?>(
          $PettyCashVouchersTable.$converterpaymentModen.toJson(paymentMode)),
      'bankAccountId': serializer.toJson<int?>(bankAccountId),
      'narration': serializer.toJson<String>(narration),
      'verifiedBy': serializer.toJson<String?>(verifiedBy),
      'transactionId': serializer.toJson<int?>(transactionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PettyCashVoucher copyWith(
          {int? id,
          int? walletId,
          int? projectId,
          PettyCashTxnType? type,
          DateTime? date,
          double? amount,
          String? category,
          BudgetCostHead? costHead,
          Value<String?> voucherNumber = const Value.absent(),
          Value<PaymentMode?> paymentMode = const Value.absent(),
          Value<int?> bankAccountId = const Value.absent(),
          String? narration,
          Value<String?> verifiedBy = const Value.absent(),
          Value<int?> transactionId = const Value.absent(),
          DateTime? createdAt}) =>
      PettyCashVoucher(
        id: id ?? this.id,
        walletId: walletId ?? this.walletId,
        projectId: projectId ?? this.projectId,
        type: type ?? this.type,
        date: date ?? this.date,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        costHead: costHead ?? this.costHead,
        voucherNumber:
            voucherNumber.present ? voucherNumber.value : this.voucherNumber,
        paymentMode: paymentMode.present ? paymentMode.value : this.paymentMode,
        bankAccountId:
            bankAccountId.present ? bankAccountId.value : this.bankAccountId,
        narration: narration ?? this.narration,
        verifiedBy: verifiedBy.present ? verifiedBy.value : this.verifiedBy,
        transactionId:
            transactionId.present ? transactionId.value : this.transactionId,
        createdAt: createdAt ?? this.createdAt,
      );
  PettyCashVoucher copyWithCompanion(PettyCashVouchersCompanion data) {
    return PettyCashVoucher(
      id: data.id.present ? data.id.value : this.id,
      walletId: data.walletId.present ? data.walletId.value : this.walletId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      costHead: data.costHead.present ? data.costHead.value : this.costHead,
      voucherNumber: data.voucherNumber.present
          ? data.voucherNumber.value
          : this.voucherNumber,
      paymentMode:
          data.paymentMode.present ? data.paymentMode.value : this.paymentMode,
      bankAccountId: data.bankAccountId.present
          ? data.bankAccountId.value
          : this.bankAccountId,
      narration: data.narration.present ? data.narration.value : this.narration,
      verifiedBy:
          data.verifiedBy.present ? data.verifiedBy.value : this.verifiedBy,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PettyCashVoucher(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('projectId: $projectId, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('costHead: $costHead, ')
          ..write('voucherNumber: $voucherNumber, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('narration: $narration, ')
          ..write('verifiedBy: $verifiedBy, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      walletId,
      projectId,
      type,
      date,
      amount,
      category,
      costHead,
      voucherNumber,
      paymentMode,
      bankAccountId,
      narration,
      verifiedBy,
      transactionId,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PettyCashVoucher &&
          other.id == this.id &&
          other.walletId == this.walletId &&
          other.projectId == this.projectId &&
          other.type == this.type &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.costHead == this.costHead &&
          other.voucherNumber == this.voucherNumber &&
          other.paymentMode == this.paymentMode &&
          other.bankAccountId == this.bankAccountId &&
          other.narration == this.narration &&
          other.verifiedBy == this.verifiedBy &&
          other.transactionId == this.transactionId &&
          other.createdAt == this.createdAt);
}

class PettyCashVouchersCompanion extends UpdateCompanion<PettyCashVoucher> {
  final Value<int> id;
  final Value<int> walletId;
  final Value<int> projectId;
  final Value<PettyCashTxnType> type;
  final Value<DateTime> date;
  final Value<double> amount;
  final Value<String> category;
  final Value<BudgetCostHead> costHead;
  final Value<String?> voucherNumber;
  final Value<PaymentMode?> paymentMode;
  final Value<int?> bankAccountId;
  final Value<String> narration;
  final Value<String?> verifiedBy;
  final Value<int?> transactionId;
  final Value<DateTime> createdAt;
  const PettyCashVouchersCompanion({
    this.id = const Value.absent(),
    this.walletId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.costHead = const Value.absent(),
    this.voucherNumber = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    this.narration = const Value.absent(),
    this.verifiedBy = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PettyCashVouchersCompanion.insert({
    this.id = const Value.absent(),
    required int walletId,
    required int projectId,
    required PettyCashTxnType type,
    required DateTime date,
    required double amount,
    this.category = const Value.absent(),
    this.costHead = const Value.absent(),
    this.voucherNumber = const Value.absent(),
    this.paymentMode = const Value.absent(),
    this.bankAccountId = const Value.absent(),
    required String narration,
    this.verifiedBy = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : walletId = Value(walletId),
        projectId = Value(projectId),
        type = Value(type),
        date = Value(date),
        amount = Value(amount),
        narration = Value(narration);
  static Insertable<PettyCashVoucher> custom({
    Expression<int>? id,
    Expression<int>? walletId,
    Expression<int>? projectId,
    Expression<String>? type,
    Expression<DateTime>? date,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? costHead,
    Expression<String>? voucherNumber,
    Expression<String>? paymentMode,
    Expression<int>? bankAccountId,
    Expression<String>? narration,
    Expression<String>? verifiedBy,
    Expression<int>? transactionId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (walletId != null) 'wallet_id': walletId,
      if (projectId != null) 'project_id': projectId,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (costHead != null) 'cost_head': costHead,
      if (voucherNumber != null) 'voucher_number': voucherNumber,
      if (paymentMode != null) 'payment_mode': paymentMode,
      if (bankAccountId != null) 'bank_account_id': bankAccountId,
      if (narration != null) 'narration': narration,
      if (verifiedBy != null) 'verified_by': verifiedBy,
      if (transactionId != null) 'transaction_id': transactionId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PettyCashVouchersCompanion copyWith(
      {Value<int>? id,
      Value<int>? walletId,
      Value<int>? projectId,
      Value<PettyCashTxnType>? type,
      Value<DateTime>? date,
      Value<double>? amount,
      Value<String>? category,
      Value<BudgetCostHead>? costHead,
      Value<String?>? voucherNumber,
      Value<PaymentMode?>? paymentMode,
      Value<int?>? bankAccountId,
      Value<String>? narration,
      Value<String?>? verifiedBy,
      Value<int?>? transactionId,
      Value<DateTime>? createdAt}) {
    return PettyCashVouchersCompanion(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      costHead: costHead ?? this.costHead,
      voucherNumber: voucherNumber ?? this.voucherNumber,
      paymentMode: paymentMode ?? this.paymentMode,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      narration: narration ?? this.narration,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (walletId.present) {
      map['wallet_id'] = Variable<int>(walletId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $PettyCashVouchersTable.$convertertype.toSql(type.value));
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (costHead.present) {
      map['cost_head'] = Variable<String>(
          $PettyCashVouchersTable.$convertercostHead.toSql(costHead.value));
    }
    if (voucherNumber.present) {
      map['voucher_number'] = Variable<String>(voucherNumber.value);
    }
    if (paymentMode.present) {
      map['payment_mode'] = Variable<String>($PettyCashVouchersTable
          .$converterpaymentModen
          .toSql(paymentMode.value));
    }
    if (bankAccountId.present) {
      map['bank_account_id'] = Variable<int>(bankAccountId.value);
    }
    if (narration.present) {
      map['narration'] = Variable<String>(narration.value);
    }
    if (verifiedBy.present) {
      map['verified_by'] = Variable<String>(verifiedBy.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PettyCashVouchersCompanion(')
          ..write('id: $id, ')
          ..write('walletId: $walletId, ')
          ..write('projectId: $projectId, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('costHead: $costHead, ')
          ..write('voucherNumber: $voucherNumber, ')
          ..write('paymentMode: $paymentMode, ')
          ..write('bankAccountId: $bankAccountId, ')
          ..write('narration: $narration, ')
          ..write('verifiedBy: $verifiedBy, ')
          ..write('transactionId: $transactionId, ')
          ..write('createdAt: $createdAt')
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
  late final $SubcontractorsTable subcontractors = $SubcontractorsTable(this);
  late final $WorkOrdersTable workOrders = $WorkOrdersTable(this);
  late final $MeasurementBillsTable measurementBills =
      $MeasurementBillsTable(this);
  late final $SubcontractPaymentsTable subcontractPayments =
      $SubcontractPaymentsTable(this);
  late final $ClientRaBillsTable clientRaBills = $ClientRaBillsTable(this);
  late final $ClientReceiptsTable clientReceipts = $ClientReceiptsTable(this);
  late final $ProjectBudgetsTable projectBudgets = $ProjectBudgetsTable(this);
  late final $EquipmentsTable equipments = $EquipmentsTable(this);
  late final $EquipmentLogsTable equipmentLogs = $EquipmentLogsTable(this);
  late final $PettyCashWalletsTable pettyCashWallets =
      $PettyCashWalletsTable(this);
  late final $PettyCashVouchersTable pettyCashVouchers =
      $PettyCashVouchersTable(this);
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
  late final SubcontractDao subcontractDao =
      SubcontractDao(this as AppDatabase);
  late final ClientBillingDao clientBillingDao =
      ClientBillingDao(this as AppDatabase);
  late final ProjectBudgetDao projectBudgetDao =
      ProjectBudgetDao(this as AppDatabase);
  late final EquipmentDao equipmentDao = EquipmentDao(this as AppDatabase);
  late final PettyCashDao pettyCashDao = PettyCashDao(this as AppDatabase);
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
        deposits,
        subcontractors,
        workOrders,
        measurementBills,
        subcontractPayments,
        clientRaBills,
        clientReceipts,
        projectBudgets,
        equipments,
        equipmentLogs,
        pettyCashWallets,
        pettyCashVouchers
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
          WritePropagation(
            on: TableUpdateQuery.onTableName('transactions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('client_ra_bills', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('client_ra_bills', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('transactions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('client_receipts', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('client_receipts', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('client_ra_bills',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('client_receipts', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bank_accounts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('client_receipts', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('project_budgets', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('vendors',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('equipments', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('equipments', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('equipments',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('equipment_logs', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('equipment_logs', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('petty_cash_wallets', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('petty_cash_wallets',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('petty_cash_vouchers', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('projects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('petty_cash_vouchers', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bank_accounts',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('petty_cash_vouchers', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('transactions',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('petty_cash_vouchers', kind: UpdateKind.update),
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
  Value<double> clientContractValue,
  Value<double> clientRetentionPercentage,
  Value<String?> clientContact,
  Value<String?> clientAddress,
  Value<String?> clientGstOrPan,
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
  Value<double> clientContractValue,
  Value<double> clientRetentionPercentage,
  Value<String?> clientContact,
  Value<String?> clientAddress,
  Value<String?> clientGstOrPan,
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

  static MultiTypedResultKey<$WorkOrdersTable, List<WorkOrder>>
      _workOrdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.workOrders,
          aliasName:
              $_aliasNameGenerator(db.projects.id, db.workOrders.projectId));

  $$WorkOrdersTableProcessedTableManager get workOrdersRefs {
    final manager = $$WorkOrdersTableTableManager($_db, $_db.workOrders)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workOrdersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClientRaBillsTable, List<ClientRaBill>>
      _clientRaBillsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clientRaBills,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.clientRaBills.projectId));

  $$ClientRaBillsTableProcessedTableManager get clientRaBillsRefs {
    final manager = $$ClientRaBillsTableTableManager($_db, $_db.clientRaBills)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientRaBillsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClientReceiptsTable, List<ClientReceipt>>
      _clientReceiptsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clientReceipts,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.clientReceipts.projectId));

  $$ClientReceiptsTableProcessedTableManager get clientReceiptsRefs {
    final manager = $$ClientReceiptsTableTableManager($_db, $_db.clientReceipts)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientReceiptsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ProjectBudgetsTable, List<ProjectBudget>>
      _projectBudgetsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.projectBudgets,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.projectBudgets.projectId));

  $$ProjectBudgetsTableProcessedTableManager get projectBudgetsRefs {
    final manager = $$ProjectBudgetsTableTableManager($_db, $_db.projectBudgets)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectBudgetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EquipmentsTable, List<Equipment>>
      _equipmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.equipments,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.equipments.currentProjectId));

  $$EquipmentsTableProcessedTableManager get equipmentsRefs {
    final manager = $$EquipmentsTableTableManager($_db, $_db.equipments).filter(
        (f) => f.currentProjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_equipmentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EquipmentLogsTable, List<EquipmentLog>>
      _equipmentLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.equipmentLogs,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.equipmentLogs.projectId));

  $$EquipmentLogsTableProcessedTableManager get equipmentLogsRefs {
    final manager = $$EquipmentLogsTableTableManager($_db, $_db.equipmentLogs)
        .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_equipmentLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PettyCashWalletsTable, List<PettyCashWallet>>
      _pettyCashWalletsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.pettyCashWallets,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.pettyCashWallets.assignedProjectId));

  $$PettyCashWalletsTableProcessedTableManager get pettyCashWalletsRefs {
    final manager =
        $$PettyCashWalletsTableTableManager($_db, $_db.pettyCashWallets).filter(
            (f) => f.assignedProjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pettyCashWalletsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PettyCashVouchersTable, List<PettyCashVoucher>>
      _pettyCashVouchersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.pettyCashVouchers,
              aliasName: $_aliasNameGenerator(
                  db.projects.id, db.pettyCashVouchers.projectId));

  $$PettyCashVouchersTableProcessedTableManager get pettyCashVouchersRefs {
    final manager =
        $$PettyCashVouchersTableTableManager($_db, $_db.pettyCashVouchers)
            .filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pettyCashVouchersRefsTable($_db));
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

  ColumnFilters<double> get clientContractValue => $composableBuilder(
      column: $table.clientContractValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get clientRetentionPercentage => $composableBuilder(
      column: $table.clientRetentionPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientContact => $composableBuilder(
      column: $table.clientContact, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientAddress => $composableBuilder(
      column: $table.clientAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientGstOrPan => $composableBuilder(
      column: $table.clientGstOrPan,
      builder: (column) => ColumnFilters(column));

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

  Expression<bool> workOrdersRefs(
      Expression<bool> Function($$WorkOrdersTableFilterComposer f) f) {
    final $$WorkOrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableFilterComposer(
              $db: $db,
              $table: $db.workOrders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> clientRaBillsRefs(
      Expression<bool> Function($$ClientRaBillsTableFilterComposer f) f) {
    final $$ClientRaBillsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientRaBills,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientRaBillsTableFilterComposer(
              $db: $db,
              $table: $db.clientRaBills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> clientReceiptsRefs(
      Expression<bool> Function($$ClientReceiptsTableFilterComposer f) f) {
    final $$ClientReceiptsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientReceipts,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientReceiptsTableFilterComposer(
              $db: $db,
              $table: $db.clientReceipts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> projectBudgetsRefs(
      Expression<bool> Function($$ProjectBudgetsTableFilterComposer f) f) {
    final $$ProjectBudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projectBudgets,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectBudgetsTableFilterComposer(
              $db: $db,
              $table: $db.projectBudgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> equipmentsRefs(
      Expression<bool> Function($$EquipmentsTableFilterComposer f) f) {
    final $$EquipmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.equipments,
        getReferencedColumn: (t) => t.currentProjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentsTableFilterComposer(
              $db: $db,
              $table: $db.equipments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> equipmentLogsRefs(
      Expression<bool> Function($$EquipmentLogsTableFilterComposer f) f) {
    final $$EquipmentLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.equipmentLogs,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentLogsTableFilterComposer(
              $db: $db,
              $table: $db.equipmentLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pettyCashWalletsRefs(
      Expression<bool> Function($$PettyCashWalletsTableFilterComposer f) f) {
    final $$PettyCashWalletsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pettyCashWallets,
        getReferencedColumn: (t) => t.assignedProjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PettyCashWalletsTableFilterComposer(
              $db: $db,
              $table: $db.pettyCashWallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pettyCashVouchersRefs(
      Expression<bool> Function($$PettyCashVouchersTableFilterComposer f) f) {
    final $$PettyCashVouchersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pettyCashVouchers,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PettyCashVouchersTableFilterComposer(
              $db: $db,
              $table: $db.pettyCashVouchers,
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

  ColumnOrderings<double> get clientContractValue => $composableBuilder(
      column: $table.clientContractValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get clientRetentionPercentage => $composableBuilder(
      column: $table.clientRetentionPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientContact => $composableBuilder(
      column: $table.clientContact,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientAddress => $composableBuilder(
      column: $table.clientAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientGstOrPan => $composableBuilder(
      column: $table.clientGstOrPan,
      builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<double> get clientContractValue => $composableBuilder(
      column: $table.clientContractValue, builder: (column) => column);

  GeneratedColumn<double> get clientRetentionPercentage => $composableBuilder(
      column: $table.clientRetentionPercentage, builder: (column) => column);

  GeneratedColumn<String> get clientContact => $composableBuilder(
      column: $table.clientContact, builder: (column) => column);

  GeneratedColumn<String> get clientAddress => $composableBuilder(
      column: $table.clientAddress, builder: (column) => column);

  GeneratedColumn<String> get clientGstOrPan => $composableBuilder(
      column: $table.clientGstOrPan, builder: (column) => column);

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

  Expression<T> workOrdersRefs<T extends Object>(
      Expression<T> Function($$WorkOrdersTableAnnotationComposer a) f) {
    final $$WorkOrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.workOrders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> clientRaBillsRefs<T extends Object>(
      Expression<T> Function($$ClientRaBillsTableAnnotationComposer a) f) {
    final $$ClientRaBillsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientRaBills,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientRaBillsTableAnnotationComposer(
              $db: $db,
              $table: $db.clientRaBills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> clientReceiptsRefs<T extends Object>(
      Expression<T> Function($$ClientReceiptsTableAnnotationComposer a) f) {
    final $$ClientReceiptsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientReceipts,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientReceiptsTableAnnotationComposer(
              $db: $db,
              $table: $db.clientReceipts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> projectBudgetsRefs<T extends Object>(
      Expression<T> Function($$ProjectBudgetsTableAnnotationComposer a) f) {
    final $$ProjectBudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.projectBudgets,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProjectBudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.projectBudgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> equipmentsRefs<T extends Object>(
      Expression<T> Function($$EquipmentsTableAnnotationComposer a) f) {
    final $$EquipmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.equipments,
        getReferencedColumn: (t) => t.currentProjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.equipments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> equipmentLogsRefs<T extends Object>(
      Expression<T> Function($$EquipmentLogsTableAnnotationComposer a) f) {
    final $$EquipmentLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.equipmentLogs,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.equipmentLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pettyCashWalletsRefs<T extends Object>(
      Expression<T> Function($$PettyCashWalletsTableAnnotationComposer a) f) {
    final $$PettyCashWalletsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pettyCashWallets,
        getReferencedColumn: (t) => t.assignedProjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PettyCashWalletsTableAnnotationComposer(
              $db: $db,
              $table: $db.pettyCashWallets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pettyCashVouchersRefs<T extends Object>(
      Expression<T> Function($$PettyCashVouchersTableAnnotationComposer a) f) {
    final $$PettyCashVouchersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pettyCashVouchers,
            getReferencedColumn: (t) => t.projectId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PettyCashVouchersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pettyCashVouchers,
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
        {bool transactionsRefs,
        bool attendanceRefs,
        bool depositsRefs,
        bool workOrdersRefs,
        bool clientRaBillsRefs,
        bool clientReceiptsRefs,
        bool projectBudgetsRefs,
        bool equipmentsRefs,
        bool equipmentLogsRefs,
        bool pettyCashWalletsRefs,
        bool pettyCashVouchersRefs})> {
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
            Value<double> clientContractValue = const Value.absent(),
            Value<double> clientRetentionPercentage = const Value.absent(),
            Value<String?> clientContact = const Value.absent(),
            Value<String?> clientAddress = const Value.absent(),
            Value<String?> clientGstOrPan = const Value.absent(),
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
            clientContractValue: clientContractValue,
            clientRetentionPercentage: clientRetentionPercentage,
            clientContact: clientContact,
            clientAddress: clientAddress,
            clientGstOrPan: clientGstOrPan,
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
            Value<double> clientContractValue = const Value.absent(),
            Value<double> clientRetentionPercentage = const Value.absent(),
            Value<String?> clientContact = const Value.absent(),
            Value<String?> clientAddress = const Value.absent(),
            Value<String?> clientGstOrPan = const Value.absent(),
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
            clientContractValue: clientContractValue,
            clientRetentionPercentage: clientRetentionPercentage,
            clientContact: clientContact,
            clientAddress: clientAddress,
            clientGstOrPan: clientGstOrPan,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {transactionsRefs = false,
              attendanceRefs = false,
              depositsRefs = false,
              workOrdersRefs = false,
              clientRaBillsRefs = false,
              clientReceiptsRefs = false,
              projectBudgetsRefs = false,
              equipmentsRefs = false,
              equipmentLogsRefs = false,
              pettyCashWalletsRefs = false,
              pettyCashVouchersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (attendanceRefs) db.attendance,
                if (depositsRefs) db.deposits,
                if (workOrdersRefs) db.workOrders,
                if (clientRaBillsRefs) db.clientRaBills,
                if (clientReceiptsRefs) db.clientReceipts,
                if (projectBudgetsRefs) db.projectBudgets,
                if (equipmentsRefs) db.equipments,
                if (equipmentLogsRefs) db.equipmentLogs,
                if (pettyCashWalletsRefs) db.pettyCashWallets,
                if (pettyCashVouchersRefs) db.pettyCashVouchers
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
                        typedResults: items),
                  if (workOrdersRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            WorkOrder>(
                        currentTable: table,
                        referencedTable:
                            $$ProjectsTableReferences._workOrdersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .workOrdersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (clientRaBillsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            ClientRaBill>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._clientRaBillsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .clientRaBillsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (clientReceiptsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            ClientReceipt>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._clientReceiptsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .clientReceiptsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (projectBudgetsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            ProjectBudget>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._projectBudgetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .projectBudgetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (equipmentsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            Equipment>(
                        currentTable: table,
                        referencedTable:
                            $$ProjectsTableReferences._equipmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .equipmentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.currentProjectId == item.id),
                        typedResults: items),
                  if (equipmentLogsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            EquipmentLog>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._equipmentLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .equipmentLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.projectId == item.id),
                        typedResults: items),
                  if (pettyCashWalletsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            PettyCashWallet>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._pettyCashWalletsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .pettyCashWalletsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.assignedProjectId == item.id),
                        typedResults: items),
                  if (pettyCashVouchersRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable,
                            PettyCashVoucher>(
                        currentTable: table,
                        referencedTable: $$ProjectsTableReferences
                            ._pettyCashVouchersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProjectsTableReferences(db, table, p0)
                                .pettyCashVouchersRefs,
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
        {bool transactionsRefs,
        bool attendanceRefs,
        bool depositsRefs,
        bool workOrdersRefs,
        bool clientRaBillsRefs,
        bool clientReceiptsRefs,
        bool projectBudgetsRefs,
        bool equipmentsRefs,
        bool equipmentLogsRefs,
        bool pettyCashWalletsRefs,
        bool pettyCashVouchersRefs})>;
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

  static MultiTypedResultKey<$SubcontractPaymentsTable,
      List<SubcontractPayment>> _subcontractPaymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.subcontractPayments,
          aliasName: $_aliasNameGenerator(
              db.bankAccounts.id, db.subcontractPayments.bankAccountId));

  $$SubcontractPaymentsTableProcessedTableManager get subcontractPaymentsRefs {
    final manager = $$SubcontractPaymentsTableTableManager(
            $_db, $_db.subcontractPayments)
        .filter((f) => f.bankAccountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_subcontractPaymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClientReceiptsTable, List<ClientReceipt>>
      _clientReceiptsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clientReceipts,
              aliasName: $_aliasNameGenerator(
                  db.bankAccounts.id, db.clientReceipts.bankAccountId));

  $$ClientReceiptsTableProcessedTableManager get clientReceiptsRefs {
    final manager = $$ClientReceiptsTableTableManager($_db, $_db.clientReceipts)
        .filter((f) => f.bankAccountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientReceiptsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PettyCashVouchersTable, List<PettyCashVoucher>>
      _pettyCashVouchersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.pettyCashVouchers,
              aliasName: $_aliasNameGenerator(
                  db.bankAccounts.id, db.pettyCashVouchers.bankAccountId));

  $$PettyCashVouchersTableProcessedTableManager get pettyCashVouchersRefs {
    final manager = $$PettyCashVouchersTableTableManager(
            $_db, $_db.pettyCashVouchers)
        .filter((f) => f.bankAccountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pettyCashVouchersRefsTable($_db));
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

  Expression<bool> subcontractPaymentsRefs(
      Expression<bool> Function($$SubcontractPaymentsTableFilterComposer f) f) {
    final $$SubcontractPaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subcontractPayments,
        getReferencedColumn: (t) => t.bankAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractPaymentsTableFilterComposer(
              $db: $db,
              $table: $db.subcontractPayments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> clientReceiptsRefs(
      Expression<bool> Function($$ClientReceiptsTableFilterComposer f) f) {
    final $$ClientReceiptsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientReceipts,
        getReferencedColumn: (t) => t.bankAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientReceiptsTableFilterComposer(
              $db: $db,
              $table: $db.clientReceipts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pettyCashVouchersRefs(
      Expression<bool> Function($$PettyCashVouchersTableFilterComposer f) f) {
    final $$PettyCashVouchersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pettyCashVouchers,
        getReferencedColumn: (t) => t.bankAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PettyCashVouchersTableFilterComposer(
              $db: $db,
              $table: $db.pettyCashVouchers,
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

  Expression<T> subcontractPaymentsRefs<T extends Object>(
      Expression<T> Function($$SubcontractPaymentsTableAnnotationComposer a)
          f) {
    final $$SubcontractPaymentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.subcontractPayments,
            getReferencedColumn: (t) => t.bankAccountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubcontractPaymentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.subcontractPayments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> clientReceiptsRefs<T extends Object>(
      Expression<T> Function($$ClientReceiptsTableAnnotationComposer a) f) {
    final $$ClientReceiptsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientReceipts,
        getReferencedColumn: (t) => t.bankAccountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientReceiptsTableAnnotationComposer(
              $db: $db,
              $table: $db.clientReceipts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pettyCashVouchersRefs<T extends Object>(
      Expression<T> Function($$PettyCashVouchersTableAnnotationComposer a) f) {
    final $$PettyCashVouchersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pettyCashVouchers,
            getReferencedColumn: (t) => t.bankAccountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PettyCashVouchersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pettyCashVouchers,
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
    PrefetchHooks Function(
        {bool transactionsRefs,
        bool subcontractPaymentsRefs,
        bool clientReceiptsRefs,
        bool pettyCashVouchersRefs})> {
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
          prefetchHooksCallback: (
              {transactionsRefs = false,
              subcontractPaymentsRefs = false,
              clientReceiptsRefs = false,
              pettyCashVouchersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transactionsRefs) db.transactions,
                if (subcontractPaymentsRefs) db.subcontractPayments,
                if (clientReceiptsRefs) db.clientReceipts,
                if (pettyCashVouchersRefs) db.pettyCashVouchers
              ],
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
                        typedResults: items),
                  if (subcontractPaymentsRefs)
                    await $_getPrefetchedData<BankAccount, $BankAccountsTable,
                            SubcontractPayment>(
                        currentTable: table,
                        referencedTable: $$BankAccountsTableReferences
                            ._subcontractPaymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BankAccountsTableReferences(db, table, p0)
                                .subcontractPaymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.bankAccountId == item.id),
                        typedResults: items),
                  if (clientReceiptsRefs)
                    await $_getPrefetchedData<BankAccount, $BankAccountsTable,
                            ClientReceipt>(
                        currentTable: table,
                        referencedTable: $$BankAccountsTableReferences
                            ._clientReceiptsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BankAccountsTableReferences(db, table, p0)
                                .clientReceiptsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.bankAccountId == item.id),
                        typedResults: items),
                  if (pettyCashVouchersRefs)
                    await $_getPrefetchedData<BankAccount, $BankAccountsTable, PettyCashVoucher>(
                        currentTable: table,
                        referencedTable: $$BankAccountsTableReferences
                            ._pettyCashVouchersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BankAccountsTableReferences(db, table, p0)
                                .pettyCashVouchersRefs,
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
    PrefetchHooks Function(
        {bool transactionsRefs,
        bool subcontractPaymentsRefs,
        bool clientReceiptsRefs,
        bool pettyCashVouchersRefs})>;
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

  static MultiTypedResultKey<$MeasurementBillsTable, List<MeasurementBill>>
      _measurementBillsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.measurementBills,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.measurementBills.transactionId));

  $$MeasurementBillsTableProcessedTableManager get measurementBillsRefs {
    final manager = $$MeasurementBillsTableTableManager(
            $_db, $_db.measurementBills)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_measurementBillsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SubcontractPaymentsTable,
      List<SubcontractPayment>> _subcontractPaymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.subcontractPayments,
          aliasName: $_aliasNameGenerator(
              db.transactions.id, db.subcontractPayments.transactionId));

  $$SubcontractPaymentsTableProcessedTableManager get subcontractPaymentsRefs {
    final manager = $$SubcontractPaymentsTableTableManager(
            $_db, $_db.subcontractPayments)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_subcontractPaymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClientRaBillsTable, List<ClientRaBill>>
      _clientRaBillsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clientRaBills,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.clientRaBills.transactionId));

  $$ClientRaBillsTableProcessedTableManager get clientRaBillsRefs {
    final manager = $$ClientRaBillsTableTableManager($_db, $_db.clientRaBills)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientRaBillsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ClientReceiptsTable, List<ClientReceipt>>
      _clientReceiptsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clientReceipts,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.clientReceipts.transactionId));

  $$ClientReceiptsTableProcessedTableManager get clientReceiptsRefs {
    final manager = $$ClientReceiptsTableTableManager($_db, $_db.clientReceipts)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientReceiptsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PettyCashVouchersTable, List<PettyCashVoucher>>
      _pettyCashVouchersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.pettyCashVouchers,
              aliasName: $_aliasNameGenerator(
                  db.transactions.id, db.pettyCashVouchers.transactionId));

  $$PettyCashVouchersTableProcessedTableManager get pettyCashVouchersRefs {
    final manager = $$PettyCashVouchersTableTableManager(
            $_db, $_db.pettyCashVouchers)
        .filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pettyCashVouchersRefsTable($_db));
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

  Expression<bool> measurementBillsRefs(
      Expression<bool> Function($$MeasurementBillsTableFilterComposer f) f) {
    final $$MeasurementBillsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurementBills,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementBillsTableFilterComposer(
              $db: $db,
              $table: $db.measurementBills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> subcontractPaymentsRefs(
      Expression<bool> Function($$SubcontractPaymentsTableFilterComposer f) f) {
    final $$SubcontractPaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subcontractPayments,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractPaymentsTableFilterComposer(
              $db: $db,
              $table: $db.subcontractPayments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> clientRaBillsRefs(
      Expression<bool> Function($$ClientRaBillsTableFilterComposer f) f) {
    final $$ClientRaBillsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientRaBills,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientRaBillsTableFilterComposer(
              $db: $db,
              $table: $db.clientRaBills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> clientReceiptsRefs(
      Expression<bool> Function($$ClientReceiptsTableFilterComposer f) f) {
    final $$ClientReceiptsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientReceipts,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientReceiptsTableFilterComposer(
              $db: $db,
              $table: $db.clientReceipts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pettyCashVouchersRefs(
      Expression<bool> Function($$PettyCashVouchersTableFilterComposer f) f) {
    final $$PettyCashVouchersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pettyCashVouchers,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PettyCashVouchersTableFilterComposer(
              $db: $db,
              $table: $db.pettyCashVouchers,
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

  Expression<T> measurementBillsRefs<T extends Object>(
      Expression<T> Function($$MeasurementBillsTableAnnotationComposer a) f) {
    final $$MeasurementBillsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurementBills,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementBillsTableAnnotationComposer(
              $db: $db,
              $table: $db.measurementBills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> subcontractPaymentsRefs<T extends Object>(
      Expression<T> Function($$SubcontractPaymentsTableAnnotationComposer a)
          f) {
    final $$SubcontractPaymentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.subcontractPayments,
            getReferencedColumn: (t) => t.transactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubcontractPaymentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.subcontractPayments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> clientRaBillsRefs<T extends Object>(
      Expression<T> Function($$ClientRaBillsTableAnnotationComposer a) f) {
    final $$ClientRaBillsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientRaBills,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientRaBillsTableAnnotationComposer(
              $db: $db,
              $table: $db.clientRaBills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> clientReceiptsRefs<T extends Object>(
      Expression<T> Function($$ClientReceiptsTableAnnotationComposer a) f) {
    final $$ClientReceiptsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientReceipts,
        getReferencedColumn: (t) => t.transactionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientReceiptsTableAnnotationComposer(
              $db: $db,
              $table: $db.clientReceipts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pettyCashVouchersRefs<T extends Object>(
      Expression<T> Function($$PettyCashVouchersTableAnnotationComposer a) f) {
    final $$PettyCashVouchersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pettyCashVouchers,
            getReferencedColumn: (t) => t.transactionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PettyCashVouchersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pettyCashVouchers,
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
        bool depositsRefs,
        bool measurementBillsRefs,
        bool subcontractPaymentsRefs,
        bool clientRaBillsRefs,
        bool clientReceiptsRefs,
        bool pettyCashVouchersRefs})> {
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
              depositsRefs = false,
              measurementBillsRefs = false,
              subcontractPaymentsRefs = false,
              clientRaBillsRefs = false,
              clientReceiptsRefs = false,
              pettyCashVouchersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (purchasesRefs) db.purchases,
                if (depositsRefs) db.deposits,
                if (measurementBillsRefs) db.measurementBills,
                if (subcontractPaymentsRefs) db.subcontractPayments,
                if (clientRaBillsRefs) db.clientRaBills,
                if (clientReceiptsRefs) db.clientReceipts,
                if (pettyCashVouchersRefs) db.pettyCashVouchers
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
                        typedResults: items),
                  if (measurementBillsRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            MeasurementBill>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._measurementBillsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .measurementBillsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (subcontractPaymentsRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            SubcontractPayment>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._subcontractPaymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .subcontractPaymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (clientRaBillsRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            ClientRaBill>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._clientRaBillsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .clientRaBillsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (clientReceiptsRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable,
                            ClientReceipt>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._clientReceiptsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .clientReceiptsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.transactionId == item.id),
                        typedResults: items),
                  if (pettyCashVouchersRefs)
                    await $_getPrefetchedData<Transaction, $TransactionsTable, PettyCashVoucher>(
                        currentTable: table,
                        referencedTable: $$TransactionsTableReferences
                            ._pettyCashVouchersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TransactionsTableReferences(db, table, p0)
                                .pettyCashVouchersRefs,
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
        bool depositsRefs,
        bool measurementBillsRefs,
        bool subcontractPaymentsRefs,
        bool clientRaBillsRefs,
        bool clientReceiptsRefs,
        bool pettyCashVouchersRefs})>;
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

  static MultiTypedResultKey<$EquipmentsTable, List<Equipment>>
      _equipmentsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.equipments,
              aliasName:
                  $_aliasNameGenerator(db.vendors.id, db.equipments.vendorId));

  $$EquipmentsTableProcessedTableManager get equipmentsRefs {
    final manager = $$EquipmentsTableTableManager($_db, $_db.equipments)
        .filter((f) => f.vendorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_equipmentsRefsTable($_db));
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

  Expression<bool> equipmentsRefs(
      Expression<bool> Function($$EquipmentsTableFilterComposer f) f) {
    final $$EquipmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.equipments,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentsTableFilterComposer(
              $db: $db,
              $table: $db.equipments,
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

  Expression<T> equipmentsRefs<T extends Object>(
      Expression<T> Function($$EquipmentsTableAnnotationComposer a) f) {
    final $$EquipmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.equipments,
        getReferencedColumn: (t) => t.vendorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.equipments,
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
    PrefetchHooks Function({bool purchasesRefs, bool equipmentsRefs})> {
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
          prefetchHooksCallback: (
              {purchasesRefs = false, equipmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (purchasesRefs) db.purchases,
                if (equipmentsRefs) db.equipments
              ],
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
                        typedResults: items),
                  if (equipmentsRefs)
                    await $_getPrefetchedData<Vendor, $VendorsTable, Equipment>(
                        currentTable: table,
                        referencedTable:
                            $$VendorsTableReferences._equipmentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VendorsTableReferences(db, table, p0)
                                .equipmentsRefs,
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
    PrefetchHooks Function({bool purchasesRefs, bool equipmentsRefs})>;
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
  Value<String?> materialCategory,
  Value<String?> hsnCode,
  Value<bool> taxApplicable,
  Value<double> gstRate,
  Value<double> gstAmount,
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
  Value<String?> materialCategory,
  Value<String?> hsnCode,
  Value<bool> taxApplicable,
  Value<double> gstRate,
  Value<double> gstAmount,
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

  ColumnFilters<String> get materialCategory => $composableBuilder(
      column: $table.materialCategory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hsnCode => $composableBuilder(
      column: $table.hsnCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get taxApplicable => $composableBuilder(
      column: $table.taxApplicable, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gstRate => $composableBuilder(
      column: $table.gstRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gstAmount => $composableBuilder(
      column: $table.gstAmount, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get materialCategory => $composableBuilder(
      column: $table.materialCategory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hsnCode => $composableBuilder(
      column: $table.hsnCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get taxApplicable => $composableBuilder(
      column: $table.taxApplicable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gstRate => $composableBuilder(
      column: $table.gstRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gstAmount => $composableBuilder(
      column: $table.gstAmount, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get materialCategory => $composableBuilder(
      column: $table.materialCategory, builder: (column) => column);

  GeneratedColumn<String> get hsnCode =>
      $composableBuilder(column: $table.hsnCode, builder: (column) => column);

  GeneratedColumn<bool> get taxApplicable => $composableBuilder(
      column: $table.taxApplicable, builder: (column) => column);

  GeneratedColumn<double> get gstRate =>
      $composableBuilder(column: $table.gstRate, builder: (column) => column);

  GeneratedColumn<double> get gstAmount =>
      $composableBuilder(column: $table.gstAmount, builder: (column) => column);

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
            Value<String?> materialCategory = const Value.absent(),
            Value<String?> hsnCode = const Value.absent(),
            Value<bool> taxApplicable = const Value.absent(),
            Value<double> gstRate = const Value.absent(),
            Value<double> gstAmount = const Value.absent(),
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
            materialCategory: materialCategory,
            hsnCode: hsnCode,
            taxApplicable: taxApplicable,
            gstRate: gstRate,
            gstAmount: gstAmount,
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
            Value<String?> materialCategory = const Value.absent(),
            Value<String?> hsnCode = const Value.absent(),
            Value<bool> taxApplicable = const Value.absent(),
            Value<double> gstRate = const Value.absent(),
            Value<double> gstAmount = const Value.absent(),
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
            materialCategory: materialCategory,
            hsnCode: hsnCode,
            taxApplicable: taxApplicable,
            gstRate: gstRate,
            gstAmount: gstAmount,
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
typedef $$SubcontractorsTableCreateCompanionBuilder = SubcontractorsCompanion
    Function({
  Value<int> id,
  required String name,
  required String trade,
  Value<String?> contact,
  Value<String?> panOrGst,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$SubcontractorsTableUpdateCompanionBuilder = SubcontractorsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> trade,
  Value<String?> contact,
  Value<String?> panOrGst,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

final class $$SubcontractorsTableReferences
    extends BaseReferences<_$AppDatabase, $SubcontractorsTable, Subcontractor> {
  $$SubcontractorsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkOrdersTable, List<WorkOrder>>
      _workOrdersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workOrders,
              aliasName: $_aliasNameGenerator(
                  db.subcontractors.id, db.workOrders.subcontractorId));

  $$WorkOrdersTableProcessedTableManager get workOrdersRefs {
    final manager = $$WorkOrdersTableTableManager($_db, $_db.workOrders).filter(
        (f) => f.subcontractorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workOrdersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SubcontractPaymentsTable,
      List<SubcontractPayment>> _subcontractPaymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.subcontractPayments,
          aliasName: $_aliasNameGenerator(
              db.subcontractors.id, db.subcontractPayments.subcontractorId));

  $$SubcontractPaymentsTableProcessedTableManager get subcontractPaymentsRefs {
    final manager = $$SubcontractPaymentsTableTableManager(
            $_db, $_db.subcontractPayments)
        .filter(
            (f) => f.subcontractorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_subcontractPaymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubcontractorsTableFilterComposer
    extends Composer<_$AppDatabase, $SubcontractorsTable> {
  $$SubcontractorsTableFilterComposer({
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

  ColumnFilters<String> get trade => $composableBuilder(
      column: $table.trade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get panOrGst => $composableBuilder(
      column: $table.panOrGst, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> workOrdersRefs(
      Expression<bool> Function($$WorkOrdersTableFilterComposer f) f) {
    final $$WorkOrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.subcontractorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableFilterComposer(
              $db: $db,
              $table: $db.workOrders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> subcontractPaymentsRefs(
      Expression<bool> Function($$SubcontractPaymentsTableFilterComposer f) f) {
    final $$SubcontractPaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subcontractPayments,
        getReferencedColumn: (t) => t.subcontractorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractPaymentsTableFilterComposer(
              $db: $db,
              $table: $db.subcontractPayments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubcontractorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubcontractorsTable> {
  $$SubcontractorsTableOrderingComposer({
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

  ColumnOrderings<String> get trade => $composableBuilder(
      column: $table.trade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contact => $composableBuilder(
      column: $table.contact, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get panOrGst => $composableBuilder(
      column: $table.panOrGst, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SubcontractorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubcontractorsTable> {
  $$SubcontractorsTableAnnotationComposer({
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

  GeneratedColumn<String> get trade =>
      $composableBuilder(column: $table.trade, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get panOrGst =>
      $composableBuilder(column: $table.panOrGst, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> workOrdersRefs<T extends Object>(
      Expression<T> Function($$WorkOrdersTableAnnotationComposer a) f) {
    final $$WorkOrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.subcontractorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.workOrders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> subcontractPaymentsRefs<T extends Object>(
      Expression<T> Function($$SubcontractPaymentsTableAnnotationComposer a)
          f) {
    final $$SubcontractPaymentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.subcontractPayments,
            getReferencedColumn: (t) => t.subcontractorId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubcontractPaymentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.subcontractPayments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SubcontractorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubcontractorsTable,
    Subcontractor,
    $$SubcontractorsTableFilterComposer,
    $$SubcontractorsTableOrderingComposer,
    $$SubcontractorsTableAnnotationComposer,
    $$SubcontractorsTableCreateCompanionBuilder,
    $$SubcontractorsTableUpdateCompanionBuilder,
    (Subcontractor, $$SubcontractorsTableReferences),
    Subcontractor,
    PrefetchHooks Function(
        {bool workOrdersRefs, bool subcontractPaymentsRefs})> {
  $$SubcontractorsTableTableManager(
      _$AppDatabase db, $SubcontractorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubcontractorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubcontractorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubcontractorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> trade = const Value.absent(),
            Value<String?> contact = const Value.absent(),
            Value<String?> panOrGst = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SubcontractorsCompanion(
            id: id,
            name: name,
            trade: trade,
            contact: contact,
            panOrGst: panOrGst,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String trade,
            Value<String?> contact = const Value.absent(),
            Value<String?> panOrGst = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SubcontractorsCompanion.insert(
            id: id,
            name: name,
            trade: trade,
            contact: contact,
            panOrGst: panOrGst,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubcontractorsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {workOrdersRefs = false, subcontractPaymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workOrdersRefs) db.workOrders,
                if (subcontractPaymentsRefs) db.subcontractPayments
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workOrdersRefs)
                    await $_getPrefetchedData<Subcontractor,
                            $SubcontractorsTable, WorkOrder>(
                        currentTable: table,
                        referencedTable: $$SubcontractorsTableReferences
                            ._workOrdersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubcontractorsTableReferences(db, table, p0)
                                .workOrdersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subcontractorId == item.id),
                        typedResults: items),
                  if (subcontractPaymentsRefs)
                    await $_getPrefetchedData<Subcontractor,
                            $SubcontractorsTable, SubcontractPayment>(
                        currentTable: table,
                        referencedTable: $$SubcontractorsTableReferences
                            ._subcontractPaymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubcontractorsTableReferences(db, table, p0)
                                .subcontractPaymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subcontractorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubcontractorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubcontractorsTable,
    Subcontractor,
    $$SubcontractorsTableFilterComposer,
    $$SubcontractorsTableOrderingComposer,
    $$SubcontractorsTableAnnotationComposer,
    $$SubcontractorsTableCreateCompanionBuilder,
    $$SubcontractorsTableUpdateCompanionBuilder,
    (Subcontractor, $$SubcontractorsTableReferences),
    Subcontractor,
    PrefetchHooks Function(
        {bool workOrdersRefs, bool subcontractPaymentsRefs})>;
typedef $$WorkOrdersTableCreateCompanionBuilder = WorkOrdersCompanion Function({
  Value<int> id,
  required String orderNumber,
  required int projectId,
  required int subcontractorId,
  required String title,
  required String trade,
  required String unit,
  required double agreedRate,
  required double estimatedQuantity,
  required double contractAmount,
  Value<double> retentionPercentage,
  Value<WorkOrderStatus> status,
  required DateTime startDate,
  Value<DateTime?> targetDate,
  Value<String?> scopeOfWork,
  Value<DateTime> createdAt,
});
typedef $$WorkOrdersTableUpdateCompanionBuilder = WorkOrdersCompanion Function({
  Value<int> id,
  Value<String> orderNumber,
  Value<int> projectId,
  Value<int> subcontractorId,
  Value<String> title,
  Value<String> trade,
  Value<String> unit,
  Value<double> agreedRate,
  Value<double> estimatedQuantity,
  Value<double> contractAmount,
  Value<double> retentionPercentage,
  Value<WorkOrderStatus> status,
  Value<DateTime> startDate,
  Value<DateTime?> targetDate,
  Value<String?> scopeOfWork,
  Value<DateTime> createdAt,
});

final class $$WorkOrdersTableReferences
    extends BaseReferences<_$AppDatabase, $WorkOrdersTable, WorkOrder> {
  $$WorkOrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.workOrders.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubcontractorsTable _subcontractorIdTable(_$AppDatabase db) =>
      db.subcontractors.createAlias($_aliasNameGenerator(
          db.workOrders.subcontractorId, db.subcontractors.id));

  $$SubcontractorsTableProcessedTableManager get subcontractorId {
    final $_column = $_itemColumn<int>('subcontractor_id')!;

    final manager = $$SubcontractorsTableTableManager($_db, $_db.subcontractors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcontractorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MeasurementBillsTable, List<MeasurementBill>>
      _measurementBillsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.measurementBills,
              aliasName: $_aliasNameGenerator(
                  db.workOrders.id, db.measurementBills.workOrderId));

  $$MeasurementBillsTableProcessedTableManager get measurementBillsRefs {
    final manager = $$MeasurementBillsTableTableManager(
            $_db, $_db.measurementBills)
        .filter((f) => f.workOrderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_measurementBillsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SubcontractPaymentsTable,
      List<SubcontractPayment>> _subcontractPaymentsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.subcontractPayments,
          aliasName: $_aliasNameGenerator(
              db.workOrders.id, db.subcontractPayments.workOrderId));

  $$SubcontractPaymentsTableProcessedTableManager get subcontractPaymentsRefs {
    final manager = $$SubcontractPaymentsTableTableManager(
            $_db, $_db.subcontractPayments)
        .filter((f) => f.workOrderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_subcontractPaymentsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $WorkOrdersTable> {
  $$WorkOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trade => $composableBuilder(
      column: $table.trade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get agreedRate => $composableBuilder(
      column: $table.agreedRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get estimatedQuantity => $composableBuilder(
      column: $table.estimatedQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get contractAmount => $composableBuilder(
      column: $table.contractAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get retentionPercentage => $composableBuilder(
      column: $table.retentionPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<WorkOrderStatus, WorkOrderStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scopeOfWork => $composableBuilder(
      column: $table.scopeOfWork, builder: (column) => ColumnFilters(column));

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

  $$SubcontractorsTableFilterComposer get subcontractorId {
    final $$SubcontractorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcontractorId,
        referencedTable: $db.subcontractors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractorsTableFilterComposer(
              $db: $db,
              $table: $db.subcontractors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> measurementBillsRefs(
      Expression<bool> Function($$MeasurementBillsTableFilterComposer f) f) {
    final $$MeasurementBillsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurementBills,
        getReferencedColumn: (t) => t.workOrderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementBillsTableFilterComposer(
              $db: $db,
              $table: $db.measurementBills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> subcontractPaymentsRefs(
      Expression<bool> Function($$SubcontractPaymentsTableFilterComposer f) f) {
    final $$SubcontractPaymentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subcontractPayments,
        getReferencedColumn: (t) => t.workOrderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractPaymentsTableFilterComposer(
              $db: $db,
              $table: $db.subcontractPayments,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkOrdersTable> {
  $$WorkOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trade => $composableBuilder(
      column: $table.trade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get agreedRate => $composableBuilder(
      column: $table.agreedRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get estimatedQuantity => $composableBuilder(
      column: $table.estimatedQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get contractAmount => $composableBuilder(
      column: $table.contractAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get retentionPercentage => $composableBuilder(
      column: $table.retentionPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scopeOfWork => $composableBuilder(
      column: $table.scopeOfWork, builder: (column) => ColumnOrderings(column));

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

  $$SubcontractorsTableOrderingComposer get subcontractorId {
    final $$SubcontractorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcontractorId,
        referencedTable: $db.subcontractors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractorsTableOrderingComposer(
              $db: $db,
              $table: $db.subcontractors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkOrdersTable> {
  $$WorkOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderNumber => $composableBuilder(
      column: $table.orderNumber, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get trade =>
      $composableBuilder(column: $table.trade, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get agreedRate => $composableBuilder(
      column: $table.agreedRate, builder: (column) => column);

  GeneratedColumn<double> get estimatedQuantity => $composableBuilder(
      column: $table.estimatedQuantity, builder: (column) => column);

  GeneratedColumn<double> get contractAmount => $composableBuilder(
      column: $table.contractAmount, builder: (column) => column);

  GeneratedColumn<double> get retentionPercentage => $composableBuilder(
      column: $table.retentionPercentage, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WorkOrderStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
      column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<String> get scopeOfWork => $composableBuilder(
      column: $table.scopeOfWork, builder: (column) => column);

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

  $$SubcontractorsTableAnnotationComposer get subcontractorId {
    final $$SubcontractorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcontractorId,
        referencedTable: $db.subcontractors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractorsTableAnnotationComposer(
              $db: $db,
              $table: $db.subcontractors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> measurementBillsRefs<T extends Object>(
      Expression<T> Function($$MeasurementBillsTableAnnotationComposer a) f) {
    final $$MeasurementBillsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurementBills,
        getReferencedColumn: (t) => t.workOrderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementBillsTableAnnotationComposer(
              $db: $db,
              $table: $db.measurementBills,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> subcontractPaymentsRefs<T extends Object>(
      Expression<T> Function($$SubcontractPaymentsTableAnnotationComposer a)
          f) {
    final $$SubcontractPaymentsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.subcontractPayments,
            getReferencedColumn: (t) => t.workOrderId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubcontractPaymentsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.subcontractPayments,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$WorkOrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkOrdersTable,
    WorkOrder,
    $$WorkOrdersTableFilterComposer,
    $$WorkOrdersTableOrderingComposer,
    $$WorkOrdersTableAnnotationComposer,
    $$WorkOrdersTableCreateCompanionBuilder,
    $$WorkOrdersTableUpdateCompanionBuilder,
    (WorkOrder, $$WorkOrdersTableReferences),
    WorkOrder,
    PrefetchHooks Function(
        {bool projectId,
        bool subcontractorId,
        bool measurementBillsRefs,
        bool subcontractPaymentsRefs})> {
  $$WorkOrdersTableTableManager(_$AppDatabase db, $WorkOrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> orderNumber = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<int> subcontractorId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> trade = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> agreedRate = const Value.absent(),
            Value<double> estimatedQuantity = const Value.absent(),
            Value<double> contractAmount = const Value.absent(),
            Value<double> retentionPercentage = const Value.absent(),
            Value<WorkOrderStatus> status = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> targetDate = const Value.absent(),
            Value<String?> scopeOfWork = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WorkOrdersCompanion(
            id: id,
            orderNumber: orderNumber,
            projectId: projectId,
            subcontractorId: subcontractorId,
            title: title,
            trade: trade,
            unit: unit,
            agreedRate: agreedRate,
            estimatedQuantity: estimatedQuantity,
            contractAmount: contractAmount,
            retentionPercentage: retentionPercentage,
            status: status,
            startDate: startDate,
            targetDate: targetDate,
            scopeOfWork: scopeOfWork,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String orderNumber,
            required int projectId,
            required int subcontractorId,
            required String title,
            required String trade,
            required String unit,
            required double agreedRate,
            required double estimatedQuantity,
            required double contractAmount,
            Value<double> retentionPercentage = const Value.absent(),
            Value<WorkOrderStatus> status = const Value.absent(),
            required DateTime startDate,
            Value<DateTime?> targetDate = const Value.absent(),
            Value<String?> scopeOfWork = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              WorkOrdersCompanion.insert(
            id: id,
            orderNumber: orderNumber,
            projectId: projectId,
            subcontractorId: subcontractorId,
            title: title,
            trade: trade,
            unit: unit,
            agreedRate: agreedRate,
            estimatedQuantity: estimatedQuantity,
            contractAmount: contractAmount,
            retentionPercentage: retentionPercentage,
            status: status,
            startDate: startDate,
            targetDate: targetDate,
            scopeOfWork: scopeOfWork,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkOrdersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {projectId = false,
              subcontractorId = false,
              measurementBillsRefs = false,
              subcontractPaymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (measurementBillsRefs) db.measurementBills,
                if (subcontractPaymentsRefs) db.subcontractPayments
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
                        $$WorkOrdersTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$WorkOrdersTableReferences._projectIdTable(db).id,
                  ) as T;
                }
                if (subcontractorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subcontractorId,
                    referencedTable:
                        $$WorkOrdersTableReferences._subcontractorIdTable(db),
                    referencedColumn: $$WorkOrdersTableReferences
                        ._subcontractorIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementBillsRefs)
                    await $_getPrefetchedData<WorkOrder, $WorkOrdersTable,
                            MeasurementBill>(
                        currentTable: table,
                        referencedTable: $$WorkOrdersTableReferences
                            ._measurementBillsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkOrdersTableReferences(db, table, p0)
                                .measurementBillsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workOrderId == item.id),
                        typedResults: items),
                  if (subcontractPaymentsRefs)
                    await $_getPrefetchedData<WorkOrder, $WorkOrdersTable,
                            SubcontractPayment>(
                        currentTable: table,
                        referencedTable: $$WorkOrdersTableReferences
                            ._subcontractPaymentsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkOrdersTableReferences(db, table, p0)
                                .subcontractPaymentsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workOrderId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkOrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkOrdersTable,
    WorkOrder,
    $$WorkOrdersTableFilterComposer,
    $$WorkOrdersTableOrderingComposer,
    $$WorkOrdersTableAnnotationComposer,
    $$WorkOrdersTableCreateCompanionBuilder,
    $$WorkOrdersTableUpdateCompanionBuilder,
    (WorkOrder, $$WorkOrdersTableReferences),
    WorkOrder,
    PrefetchHooks Function(
        {bool projectId,
        bool subcontractorId,
        bool measurementBillsRefs,
        bool subcontractPaymentsRefs})>;
typedef $$MeasurementBillsTableCreateCompanionBuilder
    = MeasurementBillsCompanion Function({
  Value<int> id,
  required int transactionId,
  required int workOrderId,
  required String billNumber,
  required DateTime date,
  required double measuredQuantity,
  required double unitRate,
  required double grossAmount,
  Value<double> retentionPercentage,
  required double retentionAmount,
  required double netAmount,
  Value<String?> locationOrDescription,
  Value<DateTime> createdAt,
});
typedef $$MeasurementBillsTableUpdateCompanionBuilder
    = MeasurementBillsCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> workOrderId,
  Value<String> billNumber,
  Value<DateTime> date,
  Value<double> measuredQuantity,
  Value<double> unitRate,
  Value<double> grossAmount,
  Value<double> retentionPercentage,
  Value<double> retentionAmount,
  Value<double> netAmount,
  Value<String?> locationOrDescription,
  Value<DateTime> createdAt,
});

final class $$MeasurementBillsTableReferences extends BaseReferences<
    _$AppDatabase, $MeasurementBillsTable, MeasurementBill> {
  $$MeasurementBillsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.measurementBills.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkOrdersTable _workOrderIdTable(_$AppDatabase db) =>
      db.workOrders.createAlias($_aliasNameGenerator(
          db.measurementBills.workOrderId, db.workOrders.id));

  $$WorkOrdersTableProcessedTableManager get workOrderId {
    final $_column = $_itemColumn<int>('work_order_id')!;

    final manager = $$WorkOrdersTableTableManager($_db, $_db.workOrders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workOrderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MeasurementBillsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementBillsTable> {
  $$MeasurementBillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billNumber => $composableBuilder(
      column: $table.billNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get measuredQuantity => $composableBuilder(
      column: $table.measuredQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitRate => $composableBuilder(
      column: $table.unitRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grossAmount => $composableBuilder(
      column: $table.grossAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get retentionPercentage => $composableBuilder(
      column: $table.retentionPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get retentionAmount => $composableBuilder(
      column: $table.retentionAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netAmount => $composableBuilder(
      column: $table.netAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationOrDescription => $composableBuilder(
      column: $table.locationOrDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

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

  $$WorkOrdersTableFilterComposer get workOrderId {
    final $$WorkOrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workOrderId,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableFilterComposer(
              $db: $db,
              $table: $db.workOrders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementBillsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementBillsTable> {
  $$MeasurementBillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billNumber => $composableBuilder(
      column: $table.billNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get measuredQuantity => $composableBuilder(
      column: $table.measuredQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitRate => $composableBuilder(
      column: $table.unitRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grossAmount => $composableBuilder(
      column: $table.grossAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get retentionPercentage => $composableBuilder(
      column: $table.retentionPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get retentionAmount => $composableBuilder(
      column: $table.retentionAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netAmount => $composableBuilder(
      column: $table.netAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationOrDescription => $composableBuilder(
      column: $table.locationOrDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

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

  $$WorkOrdersTableOrderingComposer get workOrderId {
    final $$WorkOrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workOrderId,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableOrderingComposer(
              $db: $db,
              $table: $db.workOrders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementBillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementBillsTable> {
  $$MeasurementBillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get billNumber => $composableBuilder(
      column: $table.billNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get measuredQuantity => $composableBuilder(
      column: $table.measuredQuantity, builder: (column) => column);

  GeneratedColumn<double> get unitRate =>
      $composableBuilder(column: $table.unitRate, builder: (column) => column);

  GeneratedColumn<double> get grossAmount => $composableBuilder(
      column: $table.grossAmount, builder: (column) => column);

  GeneratedColumn<double> get retentionPercentage => $composableBuilder(
      column: $table.retentionPercentage, builder: (column) => column);

  GeneratedColumn<double> get retentionAmount => $composableBuilder(
      column: $table.retentionAmount, builder: (column) => column);

  GeneratedColumn<double> get netAmount =>
      $composableBuilder(column: $table.netAmount, builder: (column) => column);

  GeneratedColumn<String> get locationOrDescription => $composableBuilder(
      column: $table.locationOrDescription, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  $$WorkOrdersTableAnnotationComposer get workOrderId {
    final $$WorkOrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workOrderId,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.workOrders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementBillsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MeasurementBillsTable,
    MeasurementBill,
    $$MeasurementBillsTableFilterComposer,
    $$MeasurementBillsTableOrderingComposer,
    $$MeasurementBillsTableAnnotationComposer,
    $$MeasurementBillsTableCreateCompanionBuilder,
    $$MeasurementBillsTableUpdateCompanionBuilder,
    (MeasurementBill, $$MeasurementBillsTableReferences),
    MeasurementBill,
    PrefetchHooks Function({bool transactionId, bool workOrderId})> {
  $$MeasurementBillsTableTableManager(
      _$AppDatabase db, $MeasurementBillsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementBillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementBillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementBillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<int> workOrderId = const Value.absent(),
            Value<String> billNumber = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> measuredQuantity = const Value.absent(),
            Value<double> unitRate = const Value.absent(),
            Value<double> grossAmount = const Value.absent(),
            Value<double> retentionPercentage = const Value.absent(),
            Value<double> retentionAmount = const Value.absent(),
            Value<double> netAmount = const Value.absent(),
            Value<String?> locationOrDescription = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MeasurementBillsCompanion(
            id: id,
            transactionId: transactionId,
            workOrderId: workOrderId,
            billNumber: billNumber,
            date: date,
            measuredQuantity: measuredQuantity,
            unitRate: unitRate,
            grossAmount: grossAmount,
            retentionPercentage: retentionPercentage,
            retentionAmount: retentionAmount,
            netAmount: netAmount,
            locationOrDescription: locationOrDescription,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int workOrderId,
            required String billNumber,
            required DateTime date,
            required double measuredQuantity,
            required double unitRate,
            required double grossAmount,
            Value<double> retentionPercentage = const Value.absent(),
            required double retentionAmount,
            required double netAmount,
            Value<String?> locationOrDescription = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              MeasurementBillsCompanion.insert(
            id: id,
            transactionId: transactionId,
            workOrderId: workOrderId,
            billNumber: billNumber,
            date: date,
            measuredQuantity: measuredQuantity,
            unitRate: unitRate,
            grossAmount: grossAmount,
            retentionPercentage: retentionPercentage,
            retentionAmount: retentionAmount,
            netAmount: netAmount,
            locationOrDescription: locationOrDescription,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MeasurementBillsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {transactionId = false, workOrderId = false}) {
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
                    referencedTable: $$MeasurementBillsTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$MeasurementBillsTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }
                if (workOrderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workOrderId,
                    referencedTable:
                        $$MeasurementBillsTableReferences._workOrderIdTable(db),
                    referencedColumn: $$MeasurementBillsTableReferences
                        ._workOrderIdTable(db)
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
        ));
}

typedef $$MeasurementBillsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MeasurementBillsTable,
    MeasurementBill,
    $$MeasurementBillsTableFilterComposer,
    $$MeasurementBillsTableOrderingComposer,
    $$MeasurementBillsTableAnnotationComposer,
    $$MeasurementBillsTableCreateCompanionBuilder,
    $$MeasurementBillsTableUpdateCompanionBuilder,
    (MeasurementBill, $$MeasurementBillsTableReferences),
    MeasurementBill,
    PrefetchHooks Function({bool transactionId, bool workOrderId})>;
typedef $$SubcontractPaymentsTableCreateCompanionBuilder
    = SubcontractPaymentsCompanion Function({
  Value<int> id,
  required int transactionId,
  required int subcontractorId,
  Value<int?> workOrderId,
  required double amount,
  required DateTime paymentDate,
  required PaymentMode paymentMode,
  Value<int?> bankAccountId,
  Value<bool> isRetentionRelease,
  Value<bool> isAdvance,
  Value<String?> referenceNo,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$SubcontractPaymentsTableUpdateCompanionBuilder
    = SubcontractPaymentsCompanion Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> subcontractorId,
  Value<int?> workOrderId,
  Value<double> amount,
  Value<DateTime> paymentDate,
  Value<PaymentMode> paymentMode,
  Value<int?> bankAccountId,
  Value<bool> isRetentionRelease,
  Value<bool> isAdvance,
  Value<String?> referenceNo,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

final class $$SubcontractPaymentsTableReferences extends BaseReferences<
    _$AppDatabase, $SubcontractPaymentsTable, SubcontractPayment> {
  $$SubcontractPaymentsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.subcontractPayments.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SubcontractorsTable _subcontractorIdTable(_$AppDatabase db) =>
      db.subcontractors.createAlias($_aliasNameGenerator(
          db.subcontractPayments.subcontractorId, db.subcontractors.id));

  $$SubcontractorsTableProcessedTableManager get subcontractorId {
    final $_column = $_itemColumn<int>('subcontractor_id')!;

    final manager = $$SubcontractorsTableTableManager($_db, $_db.subcontractors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcontractorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkOrdersTable _workOrderIdTable(_$AppDatabase db) =>
      db.workOrders.createAlias($_aliasNameGenerator(
          db.subcontractPayments.workOrderId, db.workOrders.id));

  $$WorkOrdersTableProcessedTableManager? get workOrderId {
    final $_column = $_itemColumn<int>('work_order_id');
    if ($_column == null) return null;
    final manager = $$WorkOrdersTableTableManager($_db, $_db.workOrders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workOrderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BankAccountsTable _bankAccountIdTable(_$AppDatabase db) =>
      db.bankAccounts.createAlias($_aliasNameGenerator(
          db.subcontractPayments.bankAccountId, db.bankAccounts.id));

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
}

class $$SubcontractPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $SubcontractPaymentsTable> {
  $$SubcontractPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMode, PaymentMode, String>
      get paymentMode => $composableBuilder(
          column: $table.paymentMode,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isRetentionRelease => $composableBuilder(
      column: $table.isRetentionRelease,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAdvance => $composableBuilder(
      column: $table.isAdvance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

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

  $$SubcontractorsTableFilterComposer get subcontractorId {
    final $$SubcontractorsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcontractorId,
        referencedTable: $db.subcontractors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractorsTableFilterComposer(
              $db: $db,
              $table: $db.subcontractors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkOrdersTableFilterComposer get workOrderId {
    final $$WorkOrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workOrderId,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableFilterComposer(
              $db: $db,
              $table: $db.workOrders,
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
}

class $$SubcontractPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubcontractPaymentsTable> {
  $$SubcontractPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRetentionRelease => $composableBuilder(
      column: $table.isRetentionRelease,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAdvance => $composableBuilder(
      column: $table.isAdvance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

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

  $$SubcontractorsTableOrderingComposer get subcontractorId {
    final $$SubcontractorsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcontractorId,
        referencedTable: $db.subcontractors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractorsTableOrderingComposer(
              $db: $db,
              $table: $db.subcontractors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkOrdersTableOrderingComposer get workOrderId {
    final $$WorkOrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workOrderId,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableOrderingComposer(
              $db: $db,
              $table: $db.workOrders,
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

class $$SubcontractPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubcontractPaymentsTable> {
  $$SubcontractPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
      column: $table.paymentDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMode, String> get paymentMode =>
      $composableBuilder(
          column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<bool> get isRetentionRelease => $composableBuilder(
      column: $table.isRetentionRelease, builder: (column) => column);

  GeneratedColumn<bool> get isAdvance =>
      $composableBuilder(column: $table.isAdvance, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  $$SubcontractorsTableAnnotationComposer get subcontractorId {
    final $$SubcontractorsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subcontractorId,
        referencedTable: $db.subcontractors,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubcontractorsTableAnnotationComposer(
              $db: $db,
              $table: $db.subcontractors,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkOrdersTableAnnotationComposer get workOrderId {
    final $$WorkOrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workOrderId,
        referencedTable: $db.workOrders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkOrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.workOrders,
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
}

class $$SubcontractPaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubcontractPaymentsTable,
    SubcontractPayment,
    $$SubcontractPaymentsTableFilterComposer,
    $$SubcontractPaymentsTableOrderingComposer,
    $$SubcontractPaymentsTableAnnotationComposer,
    $$SubcontractPaymentsTableCreateCompanionBuilder,
    $$SubcontractPaymentsTableUpdateCompanionBuilder,
    (SubcontractPayment, $$SubcontractPaymentsTableReferences),
    SubcontractPayment,
    PrefetchHooks Function(
        {bool transactionId,
        bool subcontractorId,
        bool workOrderId,
        bool bankAccountId})> {
  $$SubcontractPaymentsTableTableManager(
      _$AppDatabase db, $SubcontractPaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubcontractPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubcontractPaymentsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubcontractPaymentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<int> subcontractorId = const Value.absent(),
            Value<int?> workOrderId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> paymentDate = const Value.absent(),
            Value<PaymentMode> paymentMode = const Value.absent(),
            Value<int?> bankAccountId = const Value.absent(),
            Value<bool> isRetentionRelease = const Value.absent(),
            Value<bool> isAdvance = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SubcontractPaymentsCompanion(
            id: id,
            transactionId: transactionId,
            subcontractorId: subcontractorId,
            workOrderId: workOrderId,
            amount: amount,
            paymentDate: paymentDate,
            paymentMode: paymentMode,
            bankAccountId: bankAccountId,
            isRetentionRelease: isRetentionRelease,
            isAdvance: isAdvance,
            referenceNo: referenceNo,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int subcontractorId,
            Value<int?> workOrderId = const Value.absent(),
            required double amount,
            required DateTime paymentDate,
            required PaymentMode paymentMode,
            Value<int?> bankAccountId = const Value.absent(),
            Value<bool> isRetentionRelease = const Value.absent(),
            Value<bool> isAdvance = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SubcontractPaymentsCompanion.insert(
            id: id,
            transactionId: transactionId,
            subcontractorId: subcontractorId,
            workOrderId: workOrderId,
            amount: amount,
            paymentDate: paymentDate,
            paymentMode: paymentMode,
            bankAccountId: bankAccountId,
            isRetentionRelease: isRetentionRelease,
            isAdvance: isAdvance,
            referenceNo: referenceNo,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubcontractPaymentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {transactionId = false,
              subcontractorId = false,
              workOrderId = false,
              bankAccountId = false}) {
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
                    referencedTable: $$SubcontractPaymentsTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$SubcontractPaymentsTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }
                if (subcontractorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subcontractorId,
                    referencedTable: $$SubcontractPaymentsTableReferences
                        ._subcontractorIdTable(db),
                    referencedColumn: $$SubcontractPaymentsTableReferences
                        ._subcontractorIdTable(db)
                        .id,
                  ) as T;
                }
                if (workOrderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workOrderId,
                    referencedTable: $$SubcontractPaymentsTableReferences
                        ._workOrderIdTable(db),
                    referencedColumn: $$SubcontractPaymentsTableReferences
                        ._workOrderIdTable(db)
                        .id,
                  ) as T;
                }
                if (bankAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bankAccountId,
                    referencedTable: $$SubcontractPaymentsTableReferences
                        ._bankAccountIdTable(db),
                    referencedColumn: $$SubcontractPaymentsTableReferences
                        ._bankAccountIdTable(db)
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
        ));
}

typedef $$SubcontractPaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubcontractPaymentsTable,
    SubcontractPayment,
    $$SubcontractPaymentsTableFilterComposer,
    $$SubcontractPaymentsTableOrderingComposer,
    $$SubcontractPaymentsTableAnnotationComposer,
    $$SubcontractPaymentsTableCreateCompanionBuilder,
    $$SubcontractPaymentsTableUpdateCompanionBuilder,
    (SubcontractPayment, $$SubcontractPaymentsTableReferences),
    SubcontractPayment,
    PrefetchHooks Function(
        {bool transactionId,
        bool subcontractorId,
        bool workOrderId,
        bool bankAccountId})>;
typedef $$ClientRaBillsTableCreateCompanionBuilder = ClientRaBillsCompanion
    Function({
  Value<int> id,
  required int transactionId,
  required int projectId,
  required String billNumber,
  required DateTime billDate,
  required String stageOrDescription,
  required double grossAmount,
  Value<double> retentionPercentage,
  Value<double> retentionAmount,
  Value<double> advanceDeduction,
  Value<double> taxOrTdsDeduction,
  required double netCertifiedAmount,
  Value<DateTime?> dueDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$ClientRaBillsTableUpdateCompanionBuilder = ClientRaBillsCompanion
    Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> projectId,
  Value<String> billNumber,
  Value<DateTime> billDate,
  Value<String> stageOrDescription,
  Value<double> grossAmount,
  Value<double> retentionPercentage,
  Value<double> retentionAmount,
  Value<double> advanceDeduction,
  Value<double> taxOrTdsDeduction,
  Value<double> netCertifiedAmount,
  Value<DateTime?> dueDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

final class $$ClientRaBillsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientRaBillsTable, ClientRaBill> {
  $$ClientRaBillsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.clientRaBills.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.clientRaBills.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ClientReceiptsTable, List<ClientReceipt>>
      _clientReceiptsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clientReceipts,
              aliasName: $_aliasNameGenerator(
                  db.clientRaBills.id, db.clientReceipts.clientRaBillId));

  $$ClientReceiptsTableProcessedTableManager get clientReceiptsRefs {
    final manager = $$ClientReceiptsTableTableManager($_db, $_db.clientReceipts)
        .filter((f) => f.clientRaBillId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clientReceiptsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ClientRaBillsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientRaBillsTable> {
  $$ClientRaBillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billNumber => $composableBuilder(
      column: $table.billNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get billDate => $composableBuilder(
      column: $table.billDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stageOrDescription => $composableBuilder(
      column: $table.stageOrDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grossAmount => $composableBuilder(
      column: $table.grossAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get retentionPercentage => $composableBuilder(
      column: $table.retentionPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get retentionAmount => $composableBuilder(
      column: $table.retentionAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get advanceDeduction => $composableBuilder(
      column: $table.advanceDeduction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get taxOrTdsDeduction => $composableBuilder(
      column: $table.taxOrTdsDeduction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netCertifiedAmount => $composableBuilder(
      column: $table.netCertifiedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

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

  Expression<bool> clientReceiptsRefs(
      Expression<bool> Function($$ClientReceiptsTableFilterComposer f) f) {
    final $$ClientReceiptsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientReceipts,
        getReferencedColumn: (t) => t.clientRaBillId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientReceiptsTableFilterComposer(
              $db: $db,
              $table: $db.clientReceipts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientRaBillsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientRaBillsTable> {
  $$ClientRaBillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billNumber => $composableBuilder(
      column: $table.billNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get billDate => $composableBuilder(
      column: $table.billDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stageOrDescription => $composableBuilder(
      column: $table.stageOrDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grossAmount => $composableBuilder(
      column: $table.grossAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get retentionPercentage => $composableBuilder(
      column: $table.retentionPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get retentionAmount => $composableBuilder(
      column: $table.retentionAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get advanceDeduction => $composableBuilder(
      column: $table.advanceDeduction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get taxOrTdsDeduction => $composableBuilder(
      column: $table.taxOrTdsDeduction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netCertifiedAmount => $composableBuilder(
      column: $table.netCertifiedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

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

class $$ClientRaBillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientRaBillsTable> {
  $$ClientRaBillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get billNumber => $composableBuilder(
      column: $table.billNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get billDate =>
      $composableBuilder(column: $table.billDate, builder: (column) => column);

  GeneratedColumn<String> get stageOrDescription => $composableBuilder(
      column: $table.stageOrDescription, builder: (column) => column);

  GeneratedColumn<double> get grossAmount => $composableBuilder(
      column: $table.grossAmount, builder: (column) => column);

  GeneratedColumn<double> get retentionPercentage => $composableBuilder(
      column: $table.retentionPercentage, builder: (column) => column);

  GeneratedColumn<double> get retentionAmount => $composableBuilder(
      column: $table.retentionAmount, builder: (column) => column);

  GeneratedColumn<double> get advanceDeduction => $composableBuilder(
      column: $table.advanceDeduction, builder: (column) => column);

  GeneratedColumn<double> get taxOrTdsDeduction => $composableBuilder(
      column: $table.taxOrTdsDeduction, builder: (column) => column);

  GeneratedColumn<double> get netCertifiedAmount => $composableBuilder(
      column: $table.netCertifiedAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  Expression<T> clientReceiptsRefs<T extends Object>(
      Expression<T> Function($$ClientReceiptsTableAnnotationComposer a) f) {
    final $$ClientReceiptsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clientReceipts,
        getReferencedColumn: (t) => t.clientRaBillId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientReceiptsTableAnnotationComposer(
              $db: $db,
              $table: $db.clientReceipts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientRaBillsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientRaBillsTable,
    ClientRaBill,
    $$ClientRaBillsTableFilterComposer,
    $$ClientRaBillsTableOrderingComposer,
    $$ClientRaBillsTableAnnotationComposer,
    $$ClientRaBillsTableCreateCompanionBuilder,
    $$ClientRaBillsTableUpdateCompanionBuilder,
    (ClientRaBill, $$ClientRaBillsTableReferences),
    ClientRaBill,
    PrefetchHooks Function(
        {bool transactionId, bool projectId, bool clientReceiptsRefs})> {
  $$ClientRaBillsTableTableManager(_$AppDatabase db, $ClientRaBillsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientRaBillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientRaBillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientRaBillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<String> billNumber = const Value.absent(),
            Value<DateTime> billDate = const Value.absent(),
            Value<String> stageOrDescription = const Value.absent(),
            Value<double> grossAmount = const Value.absent(),
            Value<double> retentionPercentage = const Value.absent(),
            Value<double> retentionAmount = const Value.absent(),
            Value<double> advanceDeduction = const Value.absent(),
            Value<double> taxOrTdsDeduction = const Value.absent(),
            Value<double> netCertifiedAmount = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ClientRaBillsCompanion(
            id: id,
            transactionId: transactionId,
            projectId: projectId,
            billNumber: billNumber,
            billDate: billDate,
            stageOrDescription: stageOrDescription,
            grossAmount: grossAmount,
            retentionPercentage: retentionPercentage,
            retentionAmount: retentionAmount,
            advanceDeduction: advanceDeduction,
            taxOrTdsDeduction: taxOrTdsDeduction,
            netCertifiedAmount: netCertifiedAmount,
            dueDate: dueDate,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int projectId,
            required String billNumber,
            required DateTime billDate,
            required String stageOrDescription,
            required double grossAmount,
            Value<double> retentionPercentage = const Value.absent(),
            Value<double> retentionAmount = const Value.absent(),
            Value<double> advanceDeduction = const Value.absent(),
            Value<double> taxOrTdsDeduction = const Value.absent(),
            required double netCertifiedAmount,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ClientRaBillsCompanion.insert(
            id: id,
            transactionId: transactionId,
            projectId: projectId,
            billNumber: billNumber,
            billDate: billDate,
            stageOrDescription: stageOrDescription,
            grossAmount: grossAmount,
            retentionPercentage: retentionPercentage,
            retentionAmount: retentionAmount,
            advanceDeduction: advanceDeduction,
            taxOrTdsDeduction: taxOrTdsDeduction,
            netCertifiedAmount: netCertifiedAmount,
            dueDate: dueDate,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ClientRaBillsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {transactionId = false,
              projectId = false,
              clientReceiptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (clientReceiptsRefs) db.clientReceipts
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
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable:
                        $$ClientRaBillsTableReferences._transactionIdTable(db),
                    referencedColumn: $$ClientRaBillsTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$ClientRaBillsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$ClientRaBillsTableReferences._projectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clientReceiptsRefs)
                    await $_getPrefetchedData<ClientRaBill, $ClientRaBillsTable,
                            ClientReceipt>(
                        currentTable: table,
                        referencedTable: $$ClientRaBillsTableReferences
                            ._clientReceiptsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClientRaBillsTableReferences(db, table, p0)
                                .clientReceiptsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.clientRaBillId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ClientRaBillsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientRaBillsTable,
    ClientRaBill,
    $$ClientRaBillsTableFilterComposer,
    $$ClientRaBillsTableOrderingComposer,
    $$ClientRaBillsTableAnnotationComposer,
    $$ClientRaBillsTableCreateCompanionBuilder,
    $$ClientRaBillsTableUpdateCompanionBuilder,
    (ClientRaBill, $$ClientRaBillsTableReferences),
    ClientRaBill,
    PrefetchHooks Function(
        {bool transactionId, bool projectId, bool clientReceiptsRefs})>;
typedef $$ClientReceiptsTableCreateCompanionBuilder = ClientReceiptsCompanion
    Function({
  Value<int> id,
  required int transactionId,
  required int projectId,
  Value<int?> clientRaBillId,
  required DateTime receiptDate,
  required double amount,
  required PaymentMode paymentMode,
  Value<int?> bankAccountId,
  Value<bool> isAdvance,
  Value<bool> isRetentionRelease,
  Value<String?> referenceNo,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$ClientReceiptsTableUpdateCompanionBuilder = ClientReceiptsCompanion
    Function({
  Value<int> id,
  Value<int> transactionId,
  Value<int> projectId,
  Value<int?> clientRaBillId,
  Value<DateTime> receiptDate,
  Value<double> amount,
  Value<PaymentMode> paymentMode,
  Value<int?> bankAccountId,
  Value<bool> isAdvance,
  Value<bool> isRetentionRelease,
  Value<String?> referenceNo,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

final class $$ClientReceiptsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientReceiptsTable, ClientReceipt> {
  $$ClientReceiptsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.clientReceipts.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.clientReceipts.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ClientRaBillsTable _clientRaBillIdTable(_$AppDatabase db) =>
      db.clientRaBills.createAlias($_aliasNameGenerator(
          db.clientReceipts.clientRaBillId, db.clientRaBills.id));

  $$ClientRaBillsTableProcessedTableManager? get clientRaBillId {
    final $_column = $_itemColumn<int>('client_ra_bill_id');
    if ($_column == null) return null;
    final manager = $$ClientRaBillsTableTableManager($_db, $_db.clientRaBills)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientRaBillIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BankAccountsTable _bankAccountIdTable(_$AppDatabase db) =>
      db.bankAccounts.createAlias($_aliasNameGenerator(
          db.clientReceipts.bankAccountId, db.bankAccounts.id));

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
}

class $$ClientReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientReceiptsTable> {
  $$ClientReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get receiptDate => $composableBuilder(
      column: $table.receiptDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMode, PaymentMode, String>
      get paymentMode => $composableBuilder(
          column: $table.paymentMode,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isAdvance => $composableBuilder(
      column: $table.isAdvance, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRetentionRelease => $composableBuilder(
      column: $table.isRetentionRelease,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

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

  $$ClientRaBillsTableFilterComposer get clientRaBillId {
    final $$ClientRaBillsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clientRaBillId,
        referencedTable: $db.clientRaBills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientRaBillsTableFilterComposer(
              $db: $db,
              $table: $db.clientRaBills,
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
}

class $$ClientReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientReceiptsTable> {
  $$ClientReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get receiptDate => $composableBuilder(
      column: $table.receiptDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAdvance => $composableBuilder(
      column: $table.isAdvance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRetentionRelease => $composableBuilder(
      column: $table.isRetentionRelease,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

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

  $$ClientRaBillsTableOrderingComposer get clientRaBillId {
    final $$ClientRaBillsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clientRaBillId,
        referencedTable: $db.clientRaBills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientRaBillsTableOrderingComposer(
              $db: $db,
              $table: $db.clientRaBills,
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

class $$ClientReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientReceiptsTable> {
  $$ClientReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get receiptDate => $composableBuilder(
      column: $table.receiptDate, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMode, String> get paymentMode =>
      $composableBuilder(
          column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<bool> get isAdvance =>
      $composableBuilder(column: $table.isAdvance, builder: (column) => column);

  GeneratedColumn<bool> get isRetentionRelease => $composableBuilder(
      column: $table.isRetentionRelease, builder: (column) => column);

  GeneratedColumn<String> get referenceNo => $composableBuilder(
      column: $table.referenceNo, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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

  $$ClientRaBillsTableAnnotationComposer get clientRaBillId {
    final $$ClientRaBillsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clientRaBillId,
        referencedTable: $db.clientRaBills,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientRaBillsTableAnnotationComposer(
              $db: $db,
              $table: $db.clientRaBills,
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
}

class $$ClientReceiptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientReceiptsTable,
    ClientReceipt,
    $$ClientReceiptsTableFilterComposer,
    $$ClientReceiptsTableOrderingComposer,
    $$ClientReceiptsTableAnnotationComposer,
    $$ClientReceiptsTableCreateCompanionBuilder,
    $$ClientReceiptsTableUpdateCompanionBuilder,
    (ClientReceipt, $$ClientReceiptsTableReferences),
    ClientReceipt,
    PrefetchHooks Function(
        {bool transactionId,
        bool projectId,
        bool clientRaBillId,
        bool bankAccountId})> {
  $$ClientReceiptsTableTableManager(
      _$AppDatabase db, $ClientReceiptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> transactionId = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<int?> clientRaBillId = const Value.absent(),
            Value<DateTime> receiptDate = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<PaymentMode> paymentMode = const Value.absent(),
            Value<int?> bankAccountId = const Value.absent(),
            Value<bool> isAdvance = const Value.absent(),
            Value<bool> isRetentionRelease = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ClientReceiptsCompanion(
            id: id,
            transactionId: transactionId,
            projectId: projectId,
            clientRaBillId: clientRaBillId,
            receiptDate: receiptDate,
            amount: amount,
            paymentMode: paymentMode,
            bankAccountId: bankAccountId,
            isAdvance: isAdvance,
            isRetentionRelease: isRetentionRelease,
            referenceNo: referenceNo,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int transactionId,
            required int projectId,
            Value<int?> clientRaBillId = const Value.absent(),
            required DateTime receiptDate,
            required double amount,
            required PaymentMode paymentMode,
            Value<int?> bankAccountId = const Value.absent(),
            Value<bool> isAdvance = const Value.absent(),
            Value<bool> isRetentionRelease = const Value.absent(),
            Value<String?> referenceNo = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ClientReceiptsCompanion.insert(
            id: id,
            transactionId: transactionId,
            projectId: projectId,
            clientRaBillId: clientRaBillId,
            receiptDate: receiptDate,
            amount: amount,
            paymentMode: paymentMode,
            bankAccountId: bankAccountId,
            isAdvance: isAdvance,
            isRetentionRelease: isRetentionRelease,
            referenceNo: referenceNo,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ClientReceiptsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {transactionId = false,
              projectId = false,
              clientRaBillId = false,
              bankAccountId = false}) {
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
                        $$ClientReceiptsTableReferences._transactionIdTable(db),
                    referencedColumn: $$ClientReceiptsTableReferences
                        ._transactionIdTable(db)
                        .id,
                  ) as T;
                }
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$ClientReceiptsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$ClientReceiptsTableReferences._projectIdTable(db).id,
                  ) as T;
                }
                if (clientRaBillId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clientRaBillId,
                    referencedTable: $$ClientReceiptsTableReferences
                        ._clientRaBillIdTable(db),
                    referencedColumn: $$ClientReceiptsTableReferences
                        ._clientRaBillIdTable(db)
                        .id,
                  ) as T;
                }
                if (bankAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bankAccountId,
                    referencedTable:
                        $$ClientReceiptsTableReferences._bankAccountIdTable(db),
                    referencedColumn: $$ClientReceiptsTableReferences
                        ._bankAccountIdTable(db)
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
        ));
}

typedef $$ClientReceiptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientReceiptsTable,
    ClientReceipt,
    $$ClientReceiptsTableFilterComposer,
    $$ClientReceiptsTableOrderingComposer,
    $$ClientReceiptsTableAnnotationComposer,
    $$ClientReceiptsTableCreateCompanionBuilder,
    $$ClientReceiptsTableUpdateCompanionBuilder,
    (ClientReceipt, $$ClientReceiptsTableReferences),
    ClientReceipt,
    PrefetchHooks Function(
        {bool transactionId,
        bool projectId,
        bool clientRaBillId,
        bool bankAccountId})>;
typedef $$ProjectBudgetsTableCreateCompanionBuilder = ProjectBudgetsCompanion
    Function({
  Value<int> id,
  required int projectId,
  required BudgetCostHead costHead,
  required double allocatedAmount,
  Value<double> alertThresholdPercentage,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$ProjectBudgetsTableUpdateCompanionBuilder = ProjectBudgetsCompanion
    Function({
  Value<int> id,
  Value<int> projectId,
  Value<BudgetCostHead> costHead,
  Value<double> allocatedAmount,
  Value<double> alertThresholdPercentage,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$ProjectBudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectBudgetsTable, ProjectBudget> {
  $$ProjectBudgetsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.projectBudgets.projectId, db.projects.id));

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

class $$ProjectBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectBudgetsTable> {
  $$ProjectBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<BudgetCostHead, BudgetCostHead, String>
      get costHead => $composableBuilder(
          column: $table.costHead,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get alertThresholdPercentage => $composableBuilder(
      column: $table.alertThresholdPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

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

class $$ProjectBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectBudgetsTable> {
  $$ProjectBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get costHead => $composableBuilder(
      column: $table.costHead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get alertThresholdPercentage => $composableBuilder(
      column: $table.alertThresholdPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

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

class $$ProjectBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectBudgetsTable> {
  $$ProjectBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BudgetCostHead, String> get costHead =>
      $composableBuilder(column: $table.costHead, builder: (column) => column);

  GeneratedColumn<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount, builder: (column) => column);

  GeneratedColumn<double> get alertThresholdPercentage => $composableBuilder(
      column: $table.alertThresholdPercentage, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$ProjectBudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectBudgetsTable,
    ProjectBudget,
    $$ProjectBudgetsTableFilterComposer,
    $$ProjectBudgetsTableOrderingComposer,
    $$ProjectBudgetsTableAnnotationComposer,
    $$ProjectBudgetsTableCreateCompanionBuilder,
    $$ProjectBudgetsTableUpdateCompanionBuilder,
    (ProjectBudget, $$ProjectBudgetsTableReferences),
    ProjectBudget,
    PrefetchHooks Function({bool projectId})> {
  $$ProjectBudgetsTableTableManager(
      _$AppDatabase db, $ProjectBudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<BudgetCostHead> costHead = const Value.absent(),
            Value<double> allocatedAmount = const Value.absent(),
            Value<double> alertThresholdPercentage = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ProjectBudgetsCompanion(
            id: id,
            projectId: projectId,
            costHead: costHead,
            allocatedAmount: allocatedAmount,
            alertThresholdPercentage: alertThresholdPercentage,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int projectId,
            required BudgetCostHead costHead,
            required double allocatedAmount,
            Value<double> alertThresholdPercentage = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ProjectBudgetsCompanion.insert(
            id: id,
            projectId: projectId,
            costHead: costHead,
            allocatedAmount: allocatedAmount,
            alertThresholdPercentage: alertThresholdPercentage,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ProjectBudgetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
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
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$ProjectBudgetsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$ProjectBudgetsTableReferences._projectIdTable(db).id,
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

typedef $$ProjectBudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectBudgetsTable,
    ProjectBudget,
    $$ProjectBudgetsTableFilterComposer,
    $$ProjectBudgetsTableOrderingComposer,
    $$ProjectBudgetsTableAnnotationComposer,
    $$ProjectBudgetsTableCreateCompanionBuilder,
    $$ProjectBudgetsTableUpdateCompanionBuilder,
    (ProjectBudget, $$ProjectBudgetsTableReferences),
    ProjectBudget,
    PrefetchHooks Function({bool projectId})>;
typedef $$EquipmentsTableCreateCompanionBuilder = EquipmentsCompanion Function({
  Value<int> id,
  required String name,
  required String assetOrRegNumber,
  Value<String> category,
  Value<EquipmentOwnership> ownership,
  Value<int?> vendorId,
  Value<int?> currentProjectId,
  Value<EquipmentRentalBasis> rentalBasis,
  Value<double> standardRate,
  Value<EquipmentFuelPolicy> fuelPolicy,
  Value<String?> operatorName,
  Value<String?> operatorContact,
  Value<EquipmentStatus> status,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$EquipmentsTableUpdateCompanionBuilder = EquipmentsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> assetOrRegNumber,
  Value<String> category,
  Value<EquipmentOwnership> ownership,
  Value<int?> vendorId,
  Value<int?> currentProjectId,
  Value<EquipmentRentalBasis> rentalBasis,
  Value<double> standardRate,
  Value<EquipmentFuelPolicy> fuelPolicy,
  Value<String?> operatorName,
  Value<String?> operatorContact,
  Value<EquipmentStatus> status,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$EquipmentsTableReferences
    extends BaseReferences<_$AppDatabase, $EquipmentsTable, Equipment> {
  $$EquipmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VendorsTable _vendorIdTable(_$AppDatabase db) => db.vendors
      .createAlias($_aliasNameGenerator(db.equipments.vendorId, db.vendors.id));

  $$VendorsTableProcessedTableManager? get vendorId {
    final $_column = $_itemColumn<int>('vendor_id');
    if ($_column == null) return null;
    final manager = $$VendorsTableTableManager($_db, $_db.vendors)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProjectsTable _currentProjectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.equipments.currentProjectId, db.projects.id));

  $$ProjectsTableProcessedTableManager? get currentProjectId {
    final $_column = $_itemColumn<int>('current_project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currentProjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EquipmentLogsTable, List<EquipmentLog>>
      _equipmentLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.equipmentLogs,
              aliasName: $_aliasNameGenerator(
                  db.equipments.id, db.equipmentLogs.equipmentId));

  $$EquipmentLogsTableProcessedTableManager get equipmentLogsRefs {
    final manager = $$EquipmentLogsTableTableManager($_db, $_db.equipmentLogs)
        .filter((f) => f.equipmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_equipmentLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EquipmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableFilterComposer({
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

  ColumnFilters<String> get assetOrRegNumber => $composableBuilder(
      column: $table.assetOrRegNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EquipmentOwnership, EquipmentOwnership, String>
      get ownership => $composableBuilder(
          column: $table.ownership,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<EquipmentRentalBasis, EquipmentRentalBasis,
          String>
      get rentalBasis => $composableBuilder(
          column: $table.rentalBasis,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get standardRate => $composableBuilder(
      column: $table.standardRate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EquipmentFuelPolicy, EquipmentFuelPolicy,
          String>
      get fuelPolicy => $composableBuilder(
          column: $table.fuelPolicy,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get operatorName => $composableBuilder(
      column: $table.operatorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorContact => $composableBuilder(
      column: $table.operatorContact,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EquipmentStatus, EquipmentStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

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

  $$ProjectsTableFilterComposer get currentProjectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currentProjectId,
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

  Expression<bool> equipmentLogsRefs(
      Expression<bool> Function($$EquipmentLogsTableFilterComposer f) f) {
    final $$EquipmentLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.equipmentLogs,
        getReferencedColumn: (t) => t.equipmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentLogsTableFilterComposer(
              $db: $db,
              $table: $db.equipmentLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EquipmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableOrderingComposer({
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

  ColumnOrderings<String> get assetOrRegNumber => $composableBuilder(
      column: $table.assetOrRegNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownership => $composableBuilder(
      column: $table.ownership, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rentalBasis => $composableBuilder(
      column: $table.rentalBasis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get standardRate => $composableBuilder(
      column: $table.standardRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fuelPolicy => $composableBuilder(
      column: $table.fuelPolicy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorName => $composableBuilder(
      column: $table.operatorName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorContact => $composableBuilder(
      column: $table.operatorContact,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

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

  $$ProjectsTableOrderingComposer get currentProjectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currentProjectId,
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

class $$EquipmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EquipmentsTable> {
  $$EquipmentsTableAnnotationComposer({
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

  GeneratedColumn<String> get assetOrRegNumber => $composableBuilder(
      column: $table.assetOrRegNumber, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EquipmentOwnership, String> get ownership =>
      $composableBuilder(column: $table.ownership, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EquipmentRentalBasis, String>
      get rentalBasis => $composableBuilder(
          column: $table.rentalBasis, builder: (column) => column);

  GeneratedColumn<double> get standardRate => $composableBuilder(
      column: $table.standardRate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EquipmentFuelPolicy, String>
      get fuelPolicy => $composableBuilder(
          column: $table.fuelPolicy, builder: (column) => column);

  GeneratedColumn<String> get operatorName => $composableBuilder(
      column: $table.operatorName, builder: (column) => column);

  GeneratedColumn<String> get operatorContact => $composableBuilder(
      column: $table.operatorContact, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EquipmentStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

  $$ProjectsTableAnnotationComposer get currentProjectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.currentProjectId,
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

  Expression<T> equipmentLogsRefs<T extends Object>(
      Expression<T> Function($$EquipmentLogsTableAnnotationComposer a) f) {
    final $$EquipmentLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.equipmentLogs,
        getReferencedColumn: (t) => t.equipmentId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.equipmentLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EquipmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EquipmentsTable,
    Equipment,
    $$EquipmentsTableFilterComposer,
    $$EquipmentsTableOrderingComposer,
    $$EquipmentsTableAnnotationComposer,
    $$EquipmentsTableCreateCompanionBuilder,
    $$EquipmentsTableUpdateCompanionBuilder,
    (Equipment, $$EquipmentsTableReferences),
    Equipment,
    PrefetchHooks Function(
        {bool vendorId, bool currentProjectId, bool equipmentLogsRefs})> {
  $$EquipmentsTableTableManager(_$AppDatabase db, $EquipmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquipmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquipmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquipmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> assetOrRegNumber = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<EquipmentOwnership> ownership = const Value.absent(),
            Value<int?> vendorId = const Value.absent(),
            Value<int?> currentProjectId = const Value.absent(),
            Value<EquipmentRentalBasis> rentalBasis = const Value.absent(),
            Value<double> standardRate = const Value.absent(),
            Value<EquipmentFuelPolicy> fuelPolicy = const Value.absent(),
            Value<String?> operatorName = const Value.absent(),
            Value<String?> operatorContact = const Value.absent(),
            Value<EquipmentStatus> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              EquipmentsCompanion(
            id: id,
            name: name,
            assetOrRegNumber: assetOrRegNumber,
            category: category,
            ownership: ownership,
            vendorId: vendorId,
            currentProjectId: currentProjectId,
            rentalBasis: rentalBasis,
            standardRate: standardRate,
            fuelPolicy: fuelPolicy,
            operatorName: operatorName,
            operatorContact: operatorContact,
            status: status,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String assetOrRegNumber,
            Value<String> category = const Value.absent(),
            Value<EquipmentOwnership> ownership = const Value.absent(),
            Value<int?> vendorId = const Value.absent(),
            Value<int?> currentProjectId = const Value.absent(),
            Value<EquipmentRentalBasis> rentalBasis = const Value.absent(),
            Value<double> standardRate = const Value.absent(),
            Value<EquipmentFuelPolicy> fuelPolicy = const Value.absent(),
            Value<String?> operatorName = const Value.absent(),
            Value<String?> operatorContact = const Value.absent(),
            Value<EquipmentStatus> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              EquipmentsCompanion.insert(
            id: id,
            name: name,
            assetOrRegNumber: assetOrRegNumber,
            category: category,
            ownership: ownership,
            vendorId: vendorId,
            currentProjectId: currentProjectId,
            rentalBasis: rentalBasis,
            standardRate: standardRate,
            fuelPolicy: fuelPolicy,
            operatorName: operatorName,
            operatorContact: operatorContact,
            status: status,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EquipmentsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {vendorId = false,
              currentProjectId = false,
              equipmentLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (equipmentLogsRefs) db.equipmentLogs
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
                if (vendorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vendorId,
                    referencedTable:
                        $$EquipmentsTableReferences._vendorIdTable(db),
                    referencedColumn:
                        $$EquipmentsTableReferences._vendorIdTable(db).id,
                  ) as T;
                }
                if (currentProjectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.currentProjectId,
                    referencedTable:
                        $$EquipmentsTableReferences._currentProjectIdTable(db),
                    referencedColumn: $$EquipmentsTableReferences
                        ._currentProjectIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (equipmentLogsRefs)
                    await $_getPrefetchedData<Equipment, $EquipmentsTable,
                            EquipmentLog>(
                        currentTable: table,
                        referencedTable: $$EquipmentsTableReferences
                            ._equipmentLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EquipmentsTableReferences(db, table, p0)
                                .equipmentLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.equipmentId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EquipmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EquipmentsTable,
    Equipment,
    $$EquipmentsTableFilterComposer,
    $$EquipmentsTableOrderingComposer,
    $$EquipmentsTableAnnotationComposer,
    $$EquipmentsTableCreateCompanionBuilder,
    $$EquipmentsTableUpdateCompanionBuilder,
    (Equipment, $$EquipmentsTableReferences),
    Equipment,
    PrefetchHooks Function(
        {bool vendorId, bool currentProjectId, bool equipmentLogsRefs})>;
typedef $$EquipmentLogsTableCreateCompanionBuilder = EquipmentLogsCompanion
    Function({
  Value<int> id,
  required int equipmentId,
  required int projectId,
  required DateTime logDate,
  Value<double> startReading,
  Value<double> endReading,
  Value<double> totalUnitsLogged,
  Value<double> breakdownUnits,
  Value<double> billableUnits,
  Value<double> unitRate,
  Value<double> grossRentalCost,
  Value<double> fuelLitresIssued,
  Value<double> fuelRatePerLitre,
  Value<double> fuelCostDeduction,
  Value<double> netPayableAmount,
  required String workDescription,
  Value<String?> operatorName,
  Value<bool> supervisorVerified,
  Value<String?> notes,
  Value<DateTime> createdAt,
});
typedef $$EquipmentLogsTableUpdateCompanionBuilder = EquipmentLogsCompanion
    Function({
  Value<int> id,
  Value<int> equipmentId,
  Value<int> projectId,
  Value<DateTime> logDate,
  Value<double> startReading,
  Value<double> endReading,
  Value<double> totalUnitsLogged,
  Value<double> breakdownUnits,
  Value<double> billableUnits,
  Value<double> unitRate,
  Value<double> grossRentalCost,
  Value<double> fuelLitresIssued,
  Value<double> fuelRatePerLitre,
  Value<double> fuelCostDeduction,
  Value<double> netPayableAmount,
  Value<String> workDescription,
  Value<String?> operatorName,
  Value<bool> supervisorVerified,
  Value<String?> notes,
  Value<DateTime> createdAt,
});

final class $$EquipmentLogsTableReferences
    extends BaseReferences<_$AppDatabase, $EquipmentLogsTable, EquipmentLog> {
  $$EquipmentLogsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $EquipmentsTable _equipmentIdTable(_$AppDatabase db) =>
      db.equipments.createAlias(
          $_aliasNameGenerator(db.equipmentLogs.equipmentId, db.equipments.id));

  $$EquipmentsTableProcessedTableManager get equipmentId {
    final $_column = $_itemColumn<int>('equipment_id')!;

    final manager = $$EquipmentsTableTableManager($_db, $_db.equipments)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_equipmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.equipmentLogs.projectId, db.projects.id));

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

class $$EquipmentLogsTableFilterComposer
    extends Composer<_$AppDatabase, $EquipmentLogsTable> {
  $$EquipmentLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get startReading => $composableBuilder(
      column: $table.startReading, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get endReading => $composableBuilder(
      column: $table.endReading, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalUnitsLogged => $composableBuilder(
      column: $table.totalUnitsLogged,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get breakdownUnits => $composableBuilder(
      column: $table.breakdownUnits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get billableUnits => $composableBuilder(
      column: $table.billableUnits, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitRate => $composableBuilder(
      column: $table.unitRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grossRentalCost => $composableBuilder(
      column: $table.grossRentalCost,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fuelLitresIssued => $composableBuilder(
      column: $table.fuelLitresIssued,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fuelRatePerLitre => $composableBuilder(
      column: $table.fuelRatePerLitre,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fuelCostDeduction => $composableBuilder(
      column: $table.fuelCostDeduction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netPayableAmount => $composableBuilder(
      column: $table.netPayableAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workDescription => $composableBuilder(
      column: $table.workDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorName => $composableBuilder(
      column: $table.operatorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get supervisorVerified => $composableBuilder(
      column: $table.supervisorVerified,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$EquipmentsTableFilterComposer get equipmentId {
    final $$EquipmentsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.equipmentId,
        referencedTable: $db.equipments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentsTableFilterComposer(
              $db: $db,
              $table: $db.equipments,
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

class $$EquipmentLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $EquipmentLogsTable> {
  $$EquipmentLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get startReading => $composableBuilder(
      column: $table.startReading,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get endReading => $composableBuilder(
      column: $table.endReading, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalUnitsLogged => $composableBuilder(
      column: $table.totalUnitsLogged,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get breakdownUnits => $composableBuilder(
      column: $table.breakdownUnits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get billableUnits => $composableBuilder(
      column: $table.billableUnits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitRate => $composableBuilder(
      column: $table.unitRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grossRentalCost => $composableBuilder(
      column: $table.grossRentalCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fuelLitresIssued => $composableBuilder(
      column: $table.fuelLitresIssued,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fuelRatePerLitre => $composableBuilder(
      column: $table.fuelRatePerLitre,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fuelCostDeduction => $composableBuilder(
      column: $table.fuelCostDeduction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netPayableAmount => $composableBuilder(
      column: $table.netPayableAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workDescription => $composableBuilder(
      column: $table.workDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorName => $composableBuilder(
      column: $table.operatorName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get supervisorVerified => $composableBuilder(
      column: $table.supervisorVerified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$EquipmentsTableOrderingComposer get equipmentId {
    final $$EquipmentsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.equipmentId,
        referencedTable: $db.equipments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentsTableOrderingComposer(
              $db: $db,
              $table: $db.equipments,
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

class $$EquipmentLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EquipmentLogsTable> {
  $$EquipmentLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<double> get startReading => $composableBuilder(
      column: $table.startReading, builder: (column) => column);

  GeneratedColumn<double> get endReading => $composableBuilder(
      column: $table.endReading, builder: (column) => column);

  GeneratedColumn<double> get totalUnitsLogged => $composableBuilder(
      column: $table.totalUnitsLogged, builder: (column) => column);

  GeneratedColumn<double> get breakdownUnits => $composableBuilder(
      column: $table.breakdownUnits, builder: (column) => column);

  GeneratedColumn<double> get billableUnits => $composableBuilder(
      column: $table.billableUnits, builder: (column) => column);

  GeneratedColumn<double> get unitRate =>
      $composableBuilder(column: $table.unitRate, builder: (column) => column);

  GeneratedColumn<double> get grossRentalCost => $composableBuilder(
      column: $table.grossRentalCost, builder: (column) => column);

  GeneratedColumn<double> get fuelLitresIssued => $composableBuilder(
      column: $table.fuelLitresIssued, builder: (column) => column);

  GeneratedColumn<double> get fuelRatePerLitre => $composableBuilder(
      column: $table.fuelRatePerLitre, builder: (column) => column);

  GeneratedColumn<double> get fuelCostDeduction => $composableBuilder(
      column: $table.fuelCostDeduction, builder: (column) => column);

  GeneratedColumn<double> get netPayableAmount => $composableBuilder(
      column: $table.netPayableAmount, builder: (column) => column);

  GeneratedColumn<String> get workDescription => $composableBuilder(
      column: $table.workDescription, builder: (column) => column);

  GeneratedColumn<String> get operatorName => $composableBuilder(
      column: $table.operatorName, builder: (column) => column);

  GeneratedColumn<bool> get supervisorVerified => $composableBuilder(
      column: $table.supervisorVerified, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EquipmentsTableAnnotationComposer get equipmentId {
    final $$EquipmentsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.equipmentId,
        referencedTable: $db.equipments,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EquipmentsTableAnnotationComposer(
              $db: $db,
              $table: $db.equipments,
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

class $$EquipmentLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EquipmentLogsTable,
    EquipmentLog,
    $$EquipmentLogsTableFilterComposer,
    $$EquipmentLogsTableOrderingComposer,
    $$EquipmentLogsTableAnnotationComposer,
    $$EquipmentLogsTableCreateCompanionBuilder,
    $$EquipmentLogsTableUpdateCompanionBuilder,
    (EquipmentLog, $$EquipmentLogsTableReferences),
    EquipmentLog,
    PrefetchHooks Function({bool equipmentId, bool projectId})> {
  $$EquipmentLogsTableTableManager(_$AppDatabase db, $EquipmentLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquipmentLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquipmentLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquipmentLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> equipmentId = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<DateTime> logDate = const Value.absent(),
            Value<double> startReading = const Value.absent(),
            Value<double> endReading = const Value.absent(),
            Value<double> totalUnitsLogged = const Value.absent(),
            Value<double> breakdownUnits = const Value.absent(),
            Value<double> billableUnits = const Value.absent(),
            Value<double> unitRate = const Value.absent(),
            Value<double> grossRentalCost = const Value.absent(),
            Value<double> fuelLitresIssued = const Value.absent(),
            Value<double> fuelRatePerLitre = const Value.absent(),
            Value<double> fuelCostDeduction = const Value.absent(),
            Value<double> netPayableAmount = const Value.absent(),
            Value<String> workDescription = const Value.absent(),
            Value<String?> operatorName = const Value.absent(),
            Value<bool> supervisorVerified = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              EquipmentLogsCompanion(
            id: id,
            equipmentId: equipmentId,
            projectId: projectId,
            logDate: logDate,
            startReading: startReading,
            endReading: endReading,
            totalUnitsLogged: totalUnitsLogged,
            breakdownUnits: breakdownUnits,
            billableUnits: billableUnits,
            unitRate: unitRate,
            grossRentalCost: grossRentalCost,
            fuelLitresIssued: fuelLitresIssued,
            fuelRatePerLitre: fuelRatePerLitre,
            fuelCostDeduction: fuelCostDeduction,
            netPayableAmount: netPayableAmount,
            workDescription: workDescription,
            operatorName: operatorName,
            supervisorVerified: supervisorVerified,
            notes: notes,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int equipmentId,
            required int projectId,
            required DateTime logDate,
            Value<double> startReading = const Value.absent(),
            Value<double> endReading = const Value.absent(),
            Value<double> totalUnitsLogged = const Value.absent(),
            Value<double> breakdownUnits = const Value.absent(),
            Value<double> billableUnits = const Value.absent(),
            Value<double> unitRate = const Value.absent(),
            Value<double> grossRentalCost = const Value.absent(),
            Value<double> fuelLitresIssued = const Value.absent(),
            Value<double> fuelRatePerLitre = const Value.absent(),
            Value<double> fuelCostDeduction = const Value.absent(),
            Value<double> netPayableAmount = const Value.absent(),
            required String workDescription,
            Value<String?> operatorName = const Value.absent(),
            Value<bool> supervisorVerified = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              EquipmentLogsCompanion.insert(
            id: id,
            equipmentId: equipmentId,
            projectId: projectId,
            logDate: logDate,
            startReading: startReading,
            endReading: endReading,
            totalUnitsLogged: totalUnitsLogged,
            breakdownUnits: breakdownUnits,
            billableUnits: billableUnits,
            unitRate: unitRate,
            grossRentalCost: grossRentalCost,
            fuelLitresIssued: fuelLitresIssued,
            fuelRatePerLitre: fuelRatePerLitre,
            fuelCostDeduction: fuelCostDeduction,
            netPayableAmount: netPayableAmount,
            workDescription: workDescription,
            operatorName: operatorName,
            supervisorVerified: supervisorVerified,
            notes: notes,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EquipmentLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({equipmentId = false, projectId = false}) {
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
                if (equipmentId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.equipmentId,
                    referencedTable:
                        $$EquipmentLogsTableReferences._equipmentIdTable(db),
                    referencedColumn:
                        $$EquipmentLogsTableReferences._equipmentIdTable(db).id,
                  ) as T;
                }
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$EquipmentLogsTableReferences._projectIdTable(db),
                    referencedColumn:
                        $$EquipmentLogsTableReferences._projectIdTable(db).id,
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

typedef $$EquipmentLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EquipmentLogsTable,
    EquipmentLog,
    $$EquipmentLogsTableFilterComposer,
    $$EquipmentLogsTableOrderingComposer,
    $$EquipmentLogsTableAnnotationComposer,
    $$EquipmentLogsTableCreateCompanionBuilder,
    $$EquipmentLogsTableUpdateCompanionBuilder,
    (EquipmentLog, $$EquipmentLogsTableReferences),
    EquipmentLog,
    PrefetchHooks Function({bool equipmentId, bool projectId})>;
typedef $$PettyCashWalletsTableCreateCompanionBuilder
    = PettyCashWalletsCompanion Function({
  Value<int> id,
  required String supervisorName,
  required String phone,
  Value<int?> assignedProjectId,
  Value<double> maxFloatLimit,
  Value<bool> isActive,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$PettyCashWalletsTableUpdateCompanionBuilder
    = PettyCashWalletsCompanion Function({
  Value<int> id,
  Value<String> supervisorName,
  Value<String> phone,
  Value<int?> assignedProjectId,
  Value<double> maxFloatLimit,
  Value<bool> isActive,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$PettyCashWalletsTableReferences extends BaseReferences<
    _$AppDatabase, $PettyCashWalletsTable, PettyCashWallet> {
  $$PettyCashWalletsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _assignedProjectIdTable(_$AppDatabase db) =>
      db.projects.createAlias($_aliasNameGenerator(
          db.pettyCashWallets.assignedProjectId, db.projects.id));

  $$ProjectsTableProcessedTableManager? get assignedProjectId {
    final $_column = $_itemColumn<int>('assigned_project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assignedProjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PettyCashVouchersTable, List<PettyCashVoucher>>
      _pettyCashVouchersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.pettyCashVouchers,
              aliasName: $_aliasNameGenerator(
                  db.pettyCashWallets.id, db.pettyCashVouchers.walletId));

  $$PettyCashVouchersTableProcessedTableManager get pettyCashVouchersRefs {
    final manager =
        $$PettyCashVouchersTableTableManager($_db, $_db.pettyCashVouchers)
            .filter((f) => f.walletId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pettyCashVouchersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PettyCashWalletsTableFilterComposer
    extends Composer<_$AppDatabase, $PettyCashWalletsTable> {
  $$PettyCashWalletsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supervisorName => $composableBuilder(
      column: $table.supervisorName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxFloatLimit => $composableBuilder(
      column: $table.maxFloatLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ProjectsTableFilterComposer get assignedProjectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignedProjectId,
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

  Expression<bool> pettyCashVouchersRefs(
      Expression<bool> Function($$PettyCashVouchersTableFilterComposer f) f) {
    final $$PettyCashVouchersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pettyCashVouchers,
        getReferencedColumn: (t) => t.walletId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PettyCashVouchersTableFilterComposer(
              $db: $db,
              $table: $db.pettyCashVouchers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PettyCashWalletsTableOrderingComposer
    extends Composer<_$AppDatabase, $PettyCashWalletsTable> {
  $$PettyCashWalletsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supervisorName => $composableBuilder(
      column: $table.supervisorName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxFloatLimit => $composableBuilder(
      column: $table.maxFloatLimit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectsTableOrderingComposer get assignedProjectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignedProjectId,
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

class $$PettyCashWalletsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PettyCashWalletsTable> {
  $$PettyCashWalletsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get supervisorName => $composableBuilder(
      column: $table.supervisorName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<double> get maxFloatLimit => $composableBuilder(
      column: $table.maxFloatLimit, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get assignedProjectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.assignedProjectId,
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

  Expression<T> pettyCashVouchersRefs<T extends Object>(
      Expression<T> Function($$PettyCashVouchersTableAnnotationComposer a) f) {
    final $$PettyCashVouchersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.pettyCashVouchers,
            getReferencedColumn: (t) => t.walletId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PettyCashVouchersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.pettyCashVouchers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PettyCashWalletsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PettyCashWalletsTable,
    PettyCashWallet,
    $$PettyCashWalletsTableFilterComposer,
    $$PettyCashWalletsTableOrderingComposer,
    $$PettyCashWalletsTableAnnotationComposer,
    $$PettyCashWalletsTableCreateCompanionBuilder,
    $$PettyCashWalletsTableUpdateCompanionBuilder,
    (PettyCashWallet, $$PettyCashWalletsTableReferences),
    PettyCashWallet,
    PrefetchHooks Function(
        {bool assignedProjectId, bool pettyCashVouchersRefs})> {
  $$PettyCashWalletsTableTableManager(
      _$AppDatabase db, $PettyCashWalletsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PettyCashWalletsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PettyCashWalletsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PettyCashWalletsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> supervisorName = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<int?> assignedProjectId = const Value.absent(),
            Value<double> maxFloatLimit = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PettyCashWalletsCompanion(
            id: id,
            supervisorName: supervisorName,
            phone: phone,
            assignedProjectId: assignedProjectId,
            maxFloatLimit: maxFloatLimit,
            isActive: isActive,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String supervisorName,
            required String phone,
            Value<int?> assignedProjectId = const Value.absent(),
            Value<double> maxFloatLimit = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PettyCashWalletsCompanion.insert(
            id: id,
            supervisorName: supervisorName,
            phone: phone,
            assignedProjectId: assignedProjectId,
            maxFloatLimit: maxFloatLimit,
            isActive: isActive,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PettyCashWalletsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {assignedProjectId = false, pettyCashVouchersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pettyCashVouchersRefs) db.pettyCashVouchers
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
                if (assignedProjectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.assignedProjectId,
                    referencedTable: $$PettyCashWalletsTableReferences
                        ._assignedProjectIdTable(db),
                    referencedColumn: $$PettyCashWalletsTableReferences
                        ._assignedProjectIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pettyCashVouchersRefs)
                    await $_getPrefetchedData<PettyCashWallet,
                            $PettyCashWalletsTable, PettyCashVoucher>(
                        currentTable: table,
                        referencedTable: $$PettyCashWalletsTableReferences
                            ._pettyCashVouchersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PettyCashWalletsTableReferences(db, table, p0)
                                .pettyCashVouchersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.walletId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PettyCashWalletsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PettyCashWalletsTable,
    PettyCashWallet,
    $$PettyCashWalletsTableFilterComposer,
    $$PettyCashWalletsTableOrderingComposer,
    $$PettyCashWalletsTableAnnotationComposer,
    $$PettyCashWalletsTableCreateCompanionBuilder,
    $$PettyCashWalletsTableUpdateCompanionBuilder,
    (PettyCashWallet, $$PettyCashWalletsTableReferences),
    PettyCashWallet,
    PrefetchHooks Function(
        {bool assignedProjectId, bool pettyCashVouchersRefs})>;
typedef $$PettyCashVouchersTableCreateCompanionBuilder
    = PettyCashVouchersCompanion Function({
  Value<int> id,
  required int walletId,
  required int projectId,
  required PettyCashTxnType type,
  required DateTime date,
  required double amount,
  Value<String> category,
  Value<BudgetCostHead> costHead,
  Value<String?> voucherNumber,
  Value<PaymentMode?> paymentMode,
  Value<int?> bankAccountId,
  required String narration,
  Value<String?> verifiedBy,
  Value<int?> transactionId,
  Value<DateTime> createdAt,
});
typedef $$PettyCashVouchersTableUpdateCompanionBuilder
    = PettyCashVouchersCompanion Function({
  Value<int> id,
  Value<int> walletId,
  Value<int> projectId,
  Value<PettyCashTxnType> type,
  Value<DateTime> date,
  Value<double> amount,
  Value<String> category,
  Value<BudgetCostHead> costHead,
  Value<String?> voucherNumber,
  Value<PaymentMode?> paymentMode,
  Value<int?> bankAccountId,
  Value<String> narration,
  Value<String?> verifiedBy,
  Value<int?> transactionId,
  Value<DateTime> createdAt,
});

final class $$PettyCashVouchersTableReferences extends BaseReferences<
    _$AppDatabase, $PettyCashVouchersTable, PettyCashVoucher> {
  $$PettyCashVouchersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PettyCashWalletsTable _walletIdTable(_$AppDatabase db) =>
      db.pettyCashWallets.createAlias($_aliasNameGenerator(
          db.pettyCashVouchers.walletId, db.pettyCashWallets.id));

  $$PettyCashWalletsTableProcessedTableManager get walletId {
    final $_column = $_itemColumn<int>('wallet_id')!;

    final manager =
        $$PettyCashWalletsTableTableManager($_db, $_db.pettyCashWallets)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_walletIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
          $_aliasNameGenerator(db.pettyCashVouchers.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager($_db, $_db.projects)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BankAccountsTable _bankAccountIdTable(_$AppDatabase db) =>
      db.bankAccounts.createAlias($_aliasNameGenerator(
          db.pettyCashVouchers.bankAccountId, db.bankAccounts.id));

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

  static $TransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.transactions.createAlias($_aliasNameGenerator(
          db.pettyCashVouchers.transactionId, db.transactions.id));

  $$TransactionsTableProcessedTableManager? get transactionId {
    final $_column = $_itemColumn<int>('transaction_id');
    if ($_column == null) return null;
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PettyCashVouchersTableFilterComposer
    extends Composer<_$AppDatabase, $PettyCashVouchersTable> {
  $$PettyCashVouchersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PettyCashTxnType, PettyCashTxnType, String>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<BudgetCostHead, BudgetCostHead, String>
      get costHead => $composableBuilder(
          column: $table.costHead,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get voucherNumber => $composableBuilder(
      column: $table.voucherNumber, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PaymentMode?, PaymentMode, String>
      get paymentMode => $composableBuilder(
          column: $table.paymentMode,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get narration => $composableBuilder(
      column: $table.narration, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verifiedBy => $composableBuilder(
      column: $table.verifiedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$PettyCashWalletsTableFilterComposer get walletId {
    final $$PettyCashWalletsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.pettyCashWallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PettyCashWalletsTableFilterComposer(
              $db: $db,
              $table: $db.pettyCashWallets,
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
}

class $$PettyCashVouchersTableOrderingComposer
    extends Composer<_$AppDatabase, $PettyCashVouchersTable> {
  $$PettyCashVouchersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get costHead => $composableBuilder(
      column: $table.costHead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voucherNumber => $composableBuilder(
      column: $table.voucherNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMode => $composableBuilder(
      column: $table.paymentMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get narration => $composableBuilder(
      column: $table.narration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verifiedBy => $composableBuilder(
      column: $table.verifiedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$PettyCashWalletsTableOrderingComposer get walletId {
    final $$PettyCashWalletsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.pettyCashWallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PettyCashWalletsTableOrderingComposer(
              $db: $db,
              $table: $db.pettyCashWallets,
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
}

class $$PettyCashVouchersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PettyCashVouchersTable> {
  $$PettyCashVouchersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PettyCashTxnType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BudgetCostHead, String> get costHead =>
      $composableBuilder(column: $table.costHead, builder: (column) => column);

  GeneratedColumn<String> get voucherNumber => $composableBuilder(
      column: $table.voucherNumber, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMode?, String> get paymentMode =>
      $composableBuilder(
          column: $table.paymentMode, builder: (column) => column);

  GeneratedColumn<String> get narration =>
      $composableBuilder(column: $table.narration, builder: (column) => column);

  GeneratedColumn<String> get verifiedBy => $composableBuilder(
      column: $table.verifiedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PettyCashWalletsTableAnnotationComposer get walletId {
    final $$PettyCashWalletsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.walletId,
        referencedTable: $db.pettyCashWallets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PettyCashWalletsTableAnnotationComposer(
              $db: $db,
              $table: $db.pettyCashWallets,
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
}

class $$PettyCashVouchersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PettyCashVouchersTable,
    PettyCashVoucher,
    $$PettyCashVouchersTableFilterComposer,
    $$PettyCashVouchersTableOrderingComposer,
    $$PettyCashVouchersTableAnnotationComposer,
    $$PettyCashVouchersTableCreateCompanionBuilder,
    $$PettyCashVouchersTableUpdateCompanionBuilder,
    (PettyCashVoucher, $$PettyCashVouchersTableReferences),
    PettyCashVoucher,
    PrefetchHooks Function(
        {bool walletId,
        bool projectId,
        bool bankAccountId,
        bool transactionId})> {
  $$PettyCashVouchersTableTableManager(
      _$AppDatabase db, $PettyCashVouchersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PettyCashVouchersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PettyCashVouchersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PettyCashVouchersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> walletId = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<PettyCashTxnType> type = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<BudgetCostHead> costHead = const Value.absent(),
            Value<String?> voucherNumber = const Value.absent(),
            Value<PaymentMode?> paymentMode = const Value.absent(),
            Value<int?> bankAccountId = const Value.absent(),
            Value<String> narration = const Value.absent(),
            Value<String?> verifiedBy = const Value.absent(),
            Value<int?> transactionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PettyCashVouchersCompanion(
            id: id,
            walletId: walletId,
            projectId: projectId,
            type: type,
            date: date,
            amount: amount,
            category: category,
            costHead: costHead,
            voucherNumber: voucherNumber,
            paymentMode: paymentMode,
            bankAccountId: bankAccountId,
            narration: narration,
            verifiedBy: verifiedBy,
            transactionId: transactionId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int walletId,
            required int projectId,
            required PettyCashTxnType type,
            required DateTime date,
            required double amount,
            Value<String> category = const Value.absent(),
            Value<BudgetCostHead> costHead = const Value.absent(),
            Value<String?> voucherNumber = const Value.absent(),
            Value<PaymentMode?> paymentMode = const Value.absent(),
            Value<int?> bankAccountId = const Value.absent(),
            required String narration,
            Value<String?> verifiedBy = const Value.absent(),
            Value<int?> transactionId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              PettyCashVouchersCompanion.insert(
            id: id,
            walletId: walletId,
            projectId: projectId,
            type: type,
            date: date,
            amount: amount,
            category: category,
            costHead: costHead,
            voucherNumber: voucherNumber,
            paymentMode: paymentMode,
            bankAccountId: bankAccountId,
            narration: narration,
            verifiedBy: verifiedBy,
            transactionId: transactionId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PettyCashVouchersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {walletId = false,
              projectId = false,
              bankAccountId = false,
              transactionId = false}) {
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
                if (walletId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.walletId,
                    referencedTable:
                        $$PettyCashVouchersTableReferences._walletIdTable(db),
                    referencedColumn: $$PettyCashVouchersTableReferences
                        ._walletIdTable(db)
                        .id,
                  ) as T;
                }
                if (projectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.projectId,
                    referencedTable:
                        $$PettyCashVouchersTableReferences._projectIdTable(db),
                    referencedColumn: $$PettyCashVouchersTableReferences
                        ._projectIdTable(db)
                        .id,
                  ) as T;
                }
                if (bankAccountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bankAccountId,
                    referencedTable: $$PettyCashVouchersTableReferences
                        ._bankAccountIdTable(db),
                    referencedColumn: $$PettyCashVouchersTableReferences
                        ._bankAccountIdTable(db)
                        .id,
                  ) as T;
                }
                if (transactionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.transactionId,
                    referencedTable: $$PettyCashVouchersTableReferences
                        ._transactionIdTable(db),
                    referencedColumn: $$PettyCashVouchersTableReferences
                        ._transactionIdTable(db)
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
        ));
}

typedef $$PettyCashVouchersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PettyCashVouchersTable,
    PettyCashVoucher,
    $$PettyCashVouchersTableFilterComposer,
    $$PettyCashVouchersTableOrderingComposer,
    $$PettyCashVouchersTableAnnotationComposer,
    $$PettyCashVouchersTableCreateCompanionBuilder,
    $$PettyCashVouchersTableUpdateCompanionBuilder,
    (PettyCashVoucher, $$PettyCashVouchersTableReferences),
    PettyCashVoucher,
    PrefetchHooks Function(
        {bool walletId,
        bool projectId,
        bool bankAccountId,
        bool transactionId})>;

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
  $$SubcontractorsTableTableManager get subcontractors =>
      $$SubcontractorsTableTableManager(_db, _db.subcontractors);
  $$WorkOrdersTableTableManager get workOrders =>
      $$WorkOrdersTableTableManager(_db, _db.workOrders);
  $$MeasurementBillsTableTableManager get measurementBills =>
      $$MeasurementBillsTableTableManager(_db, _db.measurementBills);
  $$SubcontractPaymentsTableTableManager get subcontractPayments =>
      $$SubcontractPaymentsTableTableManager(_db, _db.subcontractPayments);
  $$ClientRaBillsTableTableManager get clientRaBills =>
      $$ClientRaBillsTableTableManager(_db, _db.clientRaBills);
  $$ClientReceiptsTableTableManager get clientReceipts =>
      $$ClientReceiptsTableTableManager(_db, _db.clientReceipts);
  $$ProjectBudgetsTableTableManager get projectBudgets =>
      $$ProjectBudgetsTableTableManager(_db, _db.projectBudgets);
  $$EquipmentsTableTableManager get equipments =>
      $$EquipmentsTableTableManager(_db, _db.equipments);
  $$EquipmentLogsTableTableManager get equipmentLogs =>
      $$EquipmentLogsTableTableManager(_db, _db.equipmentLogs);
  $$PettyCashWalletsTableTableManager get pettyCashWallets =>
      $$PettyCashWalletsTableTableManager(_db, _db.pettyCashWallets);
  $$PettyCashVouchersTableTableManager get pettyCashVouchers =>
      $$PettyCashVouchersTableTableManager(_db, _db.pettyCashVouchers);
}
