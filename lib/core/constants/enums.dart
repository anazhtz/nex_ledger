/// Core enums for NexLedger.
/// All enums are used across Data, Repository, and Presentation layers.

enum ProjectType { project, adminOverhead }

enum ProjectStatus { active, onHold, closed }

enum TransactionType {
  income,
  expense,
  purchase,
  purchasePayment, // cash outflow when settling a pending/partial purchase bill
  stockAllocation, // material/stock allocated to a project from advance stock (hits P&L, no cash)
  labourPayment,
  deposit,
  depositRefund,
  depositAdjustment,
}

enum PaymentMode { cash, bank, cheque, online }

enum PaymentStatus { paid, pending, partial }

enum AttendanceStatus { present, halfDay, absent }

enum DepositStatus { held, adjusted, partiallyAdjusted, refunded }

// ---------------------------------------------------------------------------
// Display name helpers
// ---------------------------------------------------------------------------

extension ProjectTypeX on ProjectType {
  String get displayName => switch (this) {
        ProjectType.project => 'Project',
        ProjectType.adminOverhead => 'Admin / Overhead',
      };
}

extension ProjectStatusX on ProjectStatus {
  String get displayName => switch (this) {
        ProjectStatus.active => 'Active',
        ProjectStatus.onHold => 'On Hold',
        ProjectStatus.closed => 'Closed',
      };
}

extension TransactionTypeX on TransactionType {
  String get displayName => switch (this) {
        TransactionType.income => 'Income',
        TransactionType.expense => 'Expense',
        TransactionType.purchase => 'Purchase',
        TransactionType.purchasePayment => 'Purchase Payment',
        TransactionType.stockAllocation => 'Stock Allocation',
        TransactionType.labourPayment => 'Labour Payment',
        TransactionType.deposit => 'Security Deposit',
        TransactionType.depositRefund => 'Deposit Refund',
        TransactionType.depositAdjustment => 'Deposit Adjustment',
      };

  /// Whether this transaction type affects P&L by default.
  /// purchasePayment is false — P&L was already hit when the bill was recorded.
  /// Deposit-related types are always false.
  bool get defaultAffectsPnl => switch (this) {
        TransactionType.deposit => false,
        TransactionType.depositRefund => false,
        TransactionType.depositAdjustment => false,
        TransactionType.purchasePayment => false, // P&L already hit at bill entry
        _ => true,
      };

  /// Whether this is a cash outflow (debit).
  /// Note: stockAllocation does NOT move cash (cash was already paid during bulk purchase).
  bool get isDebit => switch (this) {
        TransactionType.expense => true,
        TransactionType.purchase => true,
        TransactionType.purchasePayment => true, // actual cash out when bill is settled
        TransactionType.labourPayment => true,
        TransactionType.depositRefund => true,
        _ => false,
      };
}

extension PaymentModeX on PaymentMode {
  String get displayName => switch (this) {
        PaymentMode.cash => 'Cash',
        PaymentMode.bank => 'Bank Transfer',
        PaymentMode.cheque => 'Cheque',
        PaymentMode.online => 'Online',
      };
}

extension PaymentStatusX on PaymentStatus {
  String get displayName => switch (this) {
        PaymentStatus.paid => 'Paid',
        PaymentStatus.pending => 'Pending',
        PaymentStatus.partial => 'Partial',
      };
}

extension AttendanceStatusX on AttendanceStatus {
  String get displayName => switch (this) {
        AttendanceStatus.present => 'Present',
        AttendanceStatus.halfDay => 'Half Day',
        AttendanceStatus.absent => 'Absent',
      };

  /// Fraction of daily rate to pay (1.0, 0.5, 0.0).
  double get payFraction => switch (this) {
        AttendanceStatus.present => 1.0,
        AttendanceStatus.halfDay => 0.5,
        AttendanceStatus.absent => 0.0,
      };
}

extension DepositStatusX on DepositStatus {
  String get displayName => switch (this) {
        DepositStatus.held => 'Held',
        DepositStatus.adjusted => 'Fully Adjusted',
        DepositStatus.partiallyAdjusted => 'Partially Adjusted',
        DepositStatus.refunded => 'Refunded',
      };
}
