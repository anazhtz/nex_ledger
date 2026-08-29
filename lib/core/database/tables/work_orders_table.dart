import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'projects_table.dart';
import 'subcontractors_table.dart';

/// WorkOrders table — piece-rate subcontract agreements per project with rate, estimated quantity, & retention rules.
class WorkOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderNumber => text().withLength(min: 1, max: 50).unique()();
  IntColumn get projectId => integer().references(Projects, #id)();
  IntColumn get subcontractorId => integer().references(Subcontractors, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)(); // e.g. "Internal & External Plastering"
  TextColumn get trade => text().withLength(min: 1, max: 100)();
  TextColumn get unit => text().withLength(min: 1, max: 30)(); // "Sq.ft", "Rft", "CFT", "Nos", "Lump sum"
  RealColumn get agreedRate => real()(); // ₹ per unit (e.g. 18.0)
  RealColumn get estimatedQuantity => real()(); // e.g. 10000.0
  RealColumn get contractAmount => real()(); // agreedRate * estimatedQuantity (e.g. 180000.0)
  RealColumn get retentionPercentage => real().withDefault(const Constant(5.0))(); // default 5.0%
  TextColumn get status => textEnum<WorkOrderStatus>().withDefault(const Constant('active'))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get scopeOfWork => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
