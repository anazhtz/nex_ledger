import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/tables/projects_table.dart';

@DataClassName('ProjectBudget')
class ProjectBudgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get costHead => textEnum<BudgetCostHead>()();
  RealColumn get allocatedAmount => real()();
  RealColumn get alertThresholdPercentage =>
      real().withDefault(const Constant(85.0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {projectId, costHead},
      ];
}
