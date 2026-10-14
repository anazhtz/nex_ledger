import 'package:drift/drift.dart';

/// People who invest in (or draw from) the business — partners, family
/// investors, the proprietor. Capital / drawings transactions can point to one.
class Investors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// Soft-delete: false hides the investor from pickers but keeps history.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
