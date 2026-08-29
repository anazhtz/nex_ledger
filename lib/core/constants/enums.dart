/// Core enums for NexLedger.
/// All enums are used across Data, Repository, and Presentation layers.

enum ProjectType { project, adminOverhead }

enum ProjectStatus { active, onHold, closed }

enum WorkOrderStatus { active, completed, onHold, cancelled }

enum DepositType {
  paid,     // Security Deposit Paid to Govt / Client (Asset, Outflow)
  received, // Security Deposit Received from Client / Subcontractor (Liability, Inflow)
}

enum LedgerType {
  client,
  supplier,
  labour,
  subcontractor,
  bankCash,
  personal,
}

enum TransactionType {
  income,
  expense,
  purchase,
  purchasePayment, // cash outflow when settling a pending/partial purchase bill
  stockAllocation, // material/stock allocated to a project from advance stock (hits P&L, no cash)
  labourPayment,
  subcontractBill,    // Subcontract measurement/RA bill certified (hits P&L, no cash out)
  subcontractPayment, // Cash/Bank outflow to subcontractor (moves cash, P&L already booked)
  clientRaBill,       // Progressive RA Bill certified to client (hits P&L income, no cash)
  clientReceipt,      // Cash/Bank inflow from client (moves cash, P&L already recognized)
  deposit,           // Deposit received from client (Inflow, Liability, P&L = 0)
  depositRefund,     // Deposit refunded to client (Outflow, Liability cleared, P&L = 0)
  depositAdjustment, // Deposit adjusted to income (No cash, P&L Income recognized)
  depositPaid,       // Security Deposit Paid to Govt/Client (Outflow, Asset, P&L = 0)
  depositRecovery,   // Security Deposit Recovered/Returned from Govt/Client (Inflow, Asset cleared, P&L = 0)
  ownerCapital,      // Owner Capital Injected (Inflow, Equity, P&L = 0)
  drawings,          // Owner Drawings / Personal Withdrawal (Outflow, Equity, P&L = 0)
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

enum BudgetCostHead {
  materials,          // Material Purchases (Cement, Steel, Bricks, Tiles, Sand, etc.)
  labour,             // Direct Labour & Worker Wages
  subcontract,        // Subcontractors / Piece-Rate Work Orders
  equipmentOverhead,  // Machinery (JCB, Crane), Fuel, Transport, Site Overheads
  overallTotal,       // Master Project Target Cost Budget
}

enum BudgetHealthStatus {
  healthy,    // < 80% of budget spent
  warning,    // 80% to 99.9% of budget spent (caution)
  overBudget, // >= 100% of budget spent (cost overrun)
}

// ---------------------------------------------------------------------------
// Display name helpers
// ---------------------------------------------------------------------------

extension WorkOrderStatusX on WorkOrderStatus {
  String get displayName => switch (this) {
        WorkOrderStatus.active => 'Active',
        WorkOrderStatus.completed => 'Completed',
        WorkOrderStatus.onHold => 'On Hold',
        WorkOrderStatus.cancelled => 'Cancelled',
      };
}

extension LedgerTypeX on LedgerType {
  String get displayName => switch (this) {
        LedgerType.client => 'Clients / Customer Contracts',
        LedgerType.supplier => 'Suppliers / Vendors',
        LedgerType.labour => 'Daily Labour / Workers',
        LedgerType.subcontractor => 'Subcontractors / Piece-Rate',
        LedgerType.bankCash => 'Bank & Cash Accounts',
        LedgerType.personal => 'Personal / Owner Equity',
      };
}

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
        TransactionType.income => 'Direct Income',
        TransactionType.clientRaBill => 'Client RA Bill (Progress Invoice)',
        TransactionType.clientReceipt => 'Client Payment / Receipt',
        TransactionType.expense => 'Expense',
        TransactionType.purchase => 'Purchase',
        TransactionType.purchasePayment => 'Purchase Payment',
        TransactionType.stockAllocation => 'Stock Allocation',
        TransactionType.labourPayment => 'Labour Payment',
        TransactionType.subcontractBill => 'Subcontract Work (RA Bill)',
        TransactionType.subcontractPayment => 'Subcontract Payment / Advance',
        TransactionType.deposit => 'Deposit Received',
        TransactionType.depositRefund => 'Deposit Refund',
        TransactionType.depositAdjustment => 'Deposit Adjustment',
        TransactionType.depositPaid => 'Security Deposit Paid',
        TransactionType.depositRecovery => 'Deposit Recovered / Returned',
        TransactionType.ownerCapital => 'Owner Capital / Injection',
        TransactionType.drawings => 'Owner Drawings / Personal',
      };

  /// Whether this transaction type affects P&L by default.
  /// purchasePayment, subcontractPayment, and clientReceipt are false — P&L was already recognized when the invoice was certified.
  /// Deposit-related and Owner Equity types are always false.
  bool get defaultAffectsPnl => switch (this) {
        TransactionType.deposit => false,
        TransactionType.depositRefund => false,
        TransactionType.depositPaid => false,
        TransactionType.depositRecovery => false,
        TransactionType.ownerCapital => false,
        TransactionType.drawings => false,
        TransactionType.depositAdjustment => true,
        TransactionType.clientReceipt => false, // P&L already recognized at RA bill certification
        TransactionType.purchasePayment => false, // P&L already hit at bill entry
        TransactionType.subcontractPayment => false, // P&L already hit at RA bill certification
        _ => true,
      };

  /// Whether this is a cash outflow (debit).
  /// Note: stockAllocation, depositAdjustment, and subcontractBill do NOT move physical cash.
  bool get isDebit => switch (this) {
        TransactionType.expense => true,
        TransactionType.purchase => true,
        TransactionType.purchasePayment => true, // actual cash out when bill is settled
        TransactionType.labourPayment => true,
        TransactionType.subcontractPayment => true, // cash out when paying subcontractor
        TransactionType.depositRefund => true,
        TransactionType.depositPaid => true, // cash out when paying security deposit to govt
        TransactionType.drawings => true, // cash out when owner withdraws money
        _ => false,
      };
}

extension BudgetCostHeadX on BudgetCostHead {
  String get displayName => switch (this) {
        BudgetCostHead.materials => 'Materials & Purchases',
        BudgetCostHead.labour => 'Direct Labour & Wages',
        BudgetCostHead.subcontract => 'Subcontractors & Piece-Rate',
        BudgetCostHead.equipmentOverhead => 'Equipment, Fuel & Site Overheads',
        BudgetCostHead.overallTotal => 'Overall Target Project Cost',
      };

  String get shortName => switch (this) {
        BudgetCostHead.materials => 'Materials',
        BudgetCostHead.labour => 'Labour',
        BudgetCostHead.subcontract => 'Subcontract',
        BudgetCostHead.equipmentOverhead => 'Overheads',
        BudgetCostHead.overallTotal => 'Total Budget',
      };
}

extension BudgetHealthStatusX on BudgetHealthStatus {
  String get displayName => switch (this) {
        BudgetHealthStatus.healthy => 'On Track',
        BudgetHealthStatus.warning => 'Approaching Limit',
        BudgetHealthStatus.overBudget => 'Over Budget (Overrun)',
      };
}

class WorkOrderTradePreset {
  final String name;
  final String defaultUnit;
  final String description;

  const WorkOrderTradePreset({
    required this.name,
    required this.defaultUnit,
    required this.description,
  });
}

const List<WorkOrderTradePreset> kStandardWorkOrderTrades = [
  WorkOrderTradePreset(name: 'Plastering (Internal & External)', defaultUnit: 'Sq.ft', description: 'Wall & ceiling cement plastering'),
  WorkOrderTradePreset(name: 'Tile Laying & Flooring', defaultUnit: 'Sq.ft', description: 'Vitrified tiles, granite, marble laying & polishing'),
  WorkOrderTradePreset(name: 'Painting & Putty', defaultUnit: 'Sq.ft', description: 'Putty, primer, interior & exterior emulsion paint'),
  WorkOrderTradePreset(name: 'Brick & Block Masonry', defaultUnit: 'Sq.ft', description: 'Red brick, solid concrete block, AAC block work'),
  WorkOrderTradePreset(name: 'Bar Bending & Reinforcement', defaultUnit: 'Tons', description: 'TMT cutting, bending, and steel tying for slabs/columns'),
  WorkOrderTradePreset(name: 'Centering & Shuttering', defaultUnit: 'Sq.ft', description: 'Formwork, plywood shuttering, and prop staging'),
  WorkOrderTradePreset(name: 'Plumbing & Sanitation', defaultUnit: 'Points', description: 'Concealed CPVC/PVC piping, sanitary fittings & drainage'),
  WorkOrderTradePreset(name: 'Electrical & Wiring', defaultUnit: 'Points', description: 'Conduit laying, wire pulling, switchboard fixing'),
  WorkOrderTradePreset(name: 'False Ceiling & POP', defaultUnit: 'Sq.ft', description: 'Gypsum board / grid false ceiling & cornices'),
  WorkOrderTradePreset(name: 'Carpentry & Woodwork', defaultUnit: 'Rft', description: 'Door frames, window shutters, modular cabinetry'),
  WorkOrderTradePreset(name: 'Fabrication & MS Grills', defaultUnit: 'Kg', description: 'MS safety gates, stair railings, structural steel'),
  WorkOrderTradePreset(name: 'Waterproofing', defaultUnit: 'Sq.ft', description: 'Terrace, sunken slab, basement chemical membrane'),
  WorkOrderTradePreset(name: 'Excavation & Earthwork', defaultUnit: 'CFT', description: 'Footing trenches, basement excavation & backfilling'),
  WorkOrderTradePreset(name: 'General Subcontract', defaultUnit: 'Lump sum', description: 'Custom contract / specialized civil task'),
];

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
