import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

/// Hours in a standard working day, used to derive the default overtime rate.
const double kStandardWorkdayHours = 8.0;

extension WorkerWageX on Worker {
  /// Overtime pay per hour. Uses the worker's own OT rate when set (> 0),
  /// otherwise dailyRate ÷ 8.
  double get effectiveOvertimeRate =>
      overtimeRate > 0 ? overtimeRate : dailyRate / kStandardWorkdayHours;
}

/// One day's pay: attendance fraction × daily rate, plus overtime hours × OT rate.
double dayWage(Worker worker, AttendanceStatus status, double overtimeHours) =>
    status.payFraction * worker.dailyRate +
    overtimeHours * worker.effectiveOvertimeRate;

/// Pay for the overtime part of a day only.
double overtimePay(Worker worker, double overtimeHours) =>
    overtimeHours * worker.effectiveOvertimeRate;

/// Compact hours text: 2 -> "2", 1.5 -> "1.5".
String formatHours(double hours) =>
    hours % 1 == 0 ? hours.toInt().toString() : hours.toStringAsFixed(1);
