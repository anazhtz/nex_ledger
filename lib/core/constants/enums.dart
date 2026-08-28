/// Core enums for NexLedger.
/// All enums are used across Data, Repository, and Presentation layers.

enum ProjectType { project, adminOverhead }

enum ProjectStatus { active, onHold, closed }

enum DepositType {
  paid,     // Security Deposit Paid to Govt / Client (Asset, Outflow)
  received, // Security Deposit Received from Client / Subcontractor (Liability, Inflow)
}

enum TransactionType {
  income,
  expense,
  purchase,
  purchasePayment, // cash outflow when settling a pending/partial purchase bill
  stockAllocation, // material/stock allocated to a project from advance stock (hits P&L, no cash)
  labourPayment,
  deposit,           // Deposit received from client (Inflow, Liability, P&L = 0)
  depositRefund,     // Deposit refunded to client (Outflow, Liability cleared, P&L = 0)
  depositAdjustment, // Deposit adjusted to income (No cash, P&L Income recognized)
  depositPaid,       // Security Deposit Paid to Govt/Client (Outflow, Asset, P&L = 0)
  depositRecovery,   // Security Deposit Recovered/Returned from Govt/Client (Inflow, Asset cleared, P&L = 0)
}

enum PaymentMode { cash, bank, cheque, online }

enum PaymentStatus { paid, pending, partial }

enum AttendanceStatus { present, halfDay, absent }

enum DepositStatus {
  held,              // Currently held (with Govt or as Liability)
  recovered,         // Fully recovered/received back from Govt
  adjusted,          // Fully adjusted to income
  partiallyAdjusted, // Partially adjusted or partially recovered
  refunded,          // Refunded to client
}

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

extension DepositTypeX on DepositType {
  String get displayName => switch (this) {
        DepositType.paid => 'Deposit Paid (To Govt / Client)',
        DepositType.received => 'Deposit Received (From Client)',
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
        TransactionType.deposit => 'Deposit Received',
        TransactionType.depositRefund => 'Deposit Refund',
        TransactionType.depositAdjustment => 'Deposit Adjustment',
        TransactionType.depositPaid => 'Security Deposit Paid',
        TransactionType.depositRecovery => 'Deposit Recovered / Returned',
      };

  /// Whether this transaction type affects P&L by default.
  /// purchasePayment is false — P&L was already hit when the bill was recorded.
  /// Deposit-related types (except adjustment to income) are always false.
  bool get defaultAffectsPnl => switch (this) {
        TransactionType.deposit => false,
        TransactionType.depositRefund => false,
        TransactionType.depositPaid => false,
        TransactionType.depositRecovery => false,
        TransactionType.depositAdjustment => true,
        TransactionType.purchasePayment => false, // P&L already hit at bill entry
        _ => true,
      };

  /// Whether this is a cash outflow (debit).
  /// Note: stockAllocation and depositAdjustment do NOT move physical cash.
  bool get isDebit => switch (this) {
        TransactionType.expense => true,
        TransactionType.purchase => true,
        TransactionType.purchasePayment => true, // actual cash out when bill is settled
        TransactionType.labourPayment => true,
        TransactionType.depositRefund => true,
        TransactionType.depositPaid => true, // cash out when paying security deposit to govt
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
        DepositStatus.recovered => 'Fully Recovered',
        DepositStatus.adjusted => 'Fully Adjusted',
        DepositStatus.partiallyAdjusted => 'Partially Adjusted / Recovered',
        DepositStatus.refunded => 'Refunded',
      };
}
