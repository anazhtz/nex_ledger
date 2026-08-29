import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'projects_table.dart';
import 'vendors_table.dart';

@DataClassName('Equipment')
class Equipments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get assetOrRegNumber => text().withLength(min: 1, max: 60)();
  TextColumn get category => text().withDefault(const Constant('JCB / Backhoe Loader'))();
  TextColumn get ownership => textEnum<EquipmentOwnership>().withDefault(Constant(EquipmentOwnership.rented.name))();
  IntColumn get vendorId => integer().nullable().references(Vendors, #id, onDelete: KeyAction.setNull)();
  IntColumn get currentProjectId => integer().nullable().references(Projects, #id, onDelete: KeyAction.setNull)();
  TextColumn get rentalBasis => textEnum<EquipmentRentalBasis>().withDefault(Constant(EquipmentRentalBasis.hourly.name))();
  RealColumn get standardRate => real().withDefault(const Constant(0.0))();
  TextColumn get fuelPolicy => textEnum<EquipmentFuelPolicy>().withDefault(Constant(EquipmentFuelPolicy.contractorSupplied.name))();
  TextColumn get operatorName => text().nullable()();
  TextColumn get operatorContact => text().nullable()();
  TextColumn get status => textEnum<EquipmentStatus>().withDefault(Constant(EquipmentStatus.active.name))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
