import 'package:drift/drift.dart';
import 'equipments_table.dart';
import 'projects_table.dart';

@DataClassName('EquipmentLog')
class EquipmentLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get equipmentId => integer().references(Equipments, #id, onDelete: KeyAction.cascade)();
  IntColumn get projectId => integer().references(Projects, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get logDate => dateTime()();
  RealColumn get startReading => real().withDefault(const Constant(0.0))();
  RealColumn get endReading => real().withDefault(const Constant(0.0))();
  RealColumn get totalUnitsLogged => real().withDefault(const Constant(0.0))();
  RealColumn get breakdownUnits => real().withDefault(const Constant(0.0))();
  RealColumn get billableUnits => real().withDefault(const Constant(0.0))();
  RealColumn get unitRate => real().withDefault(const Constant(0.0))();
  RealColumn get grossRentalCost => real().withDefault(const Constant(0.0))();
  RealColumn get fuelLitresIssued => real().withDefault(const Constant(0.0))();
  RealColumn get fuelRatePerLitre => real().withDefault(const Constant(0.0))();
  RealColumn get fuelCostDeduction => real().withDefault(const Constant(0.0))();
  RealColumn get netPayableAmount => real().withDefault(const Constant(0.0))();
  TextColumn get workDescription => text().withLength(min: 1, max: 255)();
  TextColumn get operatorName => text().nullable()();
  BoolColumn get supervisorVerified => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
