# AGENTS.md — NexLedger (Mini ERP Desktop App)

This file is the source of truth for architecture, structure, and conventions.
Read this fully before writing or modifying any code.

## 1. Project Summary

A single-user Flutter Desktop application (Windows primary target) for a small
business to track project-wise cash flow, purchases, labour payments, and
deposits. Fully offline — no login, no cloud, no multi-user support in v1.

## 2. Tech Stack (do not substitute without asking)

- Flutter Desktop (Windows + macOS targets)
- State management: **Riverpod** (use `flutter_riverpod` + code-gen via `riverpod_generator`)
- Local database: **drift** (type-safe SQLite ORM)
- Desktop SQLite driver: `sqlite3_flutter_libs`
- Routing: `go_router`
- Forms: `reactive_forms` or plain `Form` + `TextEditingController` — keep it simple, no over-engineering
- Charts: none in v1 (tables only)

## 3. Architecture Pattern

Use a simple **layered architecture** — do not over-engineer with Clean
Architecture's full ceremony for a project this size. Three layers only:

1. **Data layer** — drift tables, DAOs, database class
2. **Domain/Repository layer** — one repository per module, wraps DAO calls,
   contains business logic (esp. the deposit/P&L rule below)
3. **Presentation layer** — Riverpod providers (state) + Flutter widgets (UI),
   organized by feature/module, not by type

Do NOT create separate `models/`, `views/`, `controllers/` folders at the
top level — organize by feature instead (see folder structure below).

## 4. Folder Structure

```
lib/
├── main.dart
├── app.dart                       # MaterialApp + go_router setup
│
├── core/
│   ├── database/
│   │   ├── app_database.dart      # drift @DriftDatabase class
│   │   ├── tables/
│   │   │   ├── projects_table.dart
│   │   │   ├── transactions_table.dart
│   │   │   ├── vendors_table.dart
│   │   │   ├── purchases_table.dart
│   │   │   ├── workers_table.dart
│   │   │   ├── attendance_table.dart
│   │   │   └── deposits_table.dart
│   │   └── daos/
│   │       ├── project_dao.dart
│   │       ├── transaction_dao.dart
│   │       ├── purchase_dao.dart
│   │       ├── labour_dao.dart
│   │       └── deposit_dao.dart
│   ├── theme/
│   │   └── app_theme.dart         # Material 3, light scheme
│   ├── constants/
│   │   └── enums.dart             # TransactionType, ProjectStatus, etc.
│   └── utils/
│       ├── currency_formatter.dart
│       └── date_formatter.dart
│
├── features/
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── widgets/
│   │   └── providers/
│   │       └── dashboard_provider.dart
│   │
│   ├── projects/
│   │   ├── data/
│   │   │   └── project_repository.dart
│   │   ├── presentation/
│   │   │   ├── project_list_screen.dart
│   │   │   ├── project_form_screen.dart
│   │   │   └── widgets/
│   │   └── providers/
│   │       └── project_providers.dart
│   │
│   ├── cash_book/
│   │   ├── data/cash_book_repository.dart
│   │   ├── presentation/
│   │   │   ├── cash_book_list_screen.dart
│   │   │   ├── cash_book_entry_form.dart
│   │   │   └── widgets/
│   │   └── providers/cash_book_providers.dart
│   │
│   ├── purchase/
│   │   ├── data/purchase_repository.dart
│   │   ├── presentation/
│   │   └── providers/
│   │
│   ├── labour/
│   │   ├── data/labour_repository.dart
│   │   ├── presentation/
│   │   │   ├── attendance_screen.dart
│   │   │   ├── labour_payment_screen.dart
│   │   │   └── widgets/
│   │   └── providers/
│   │
│   ├── deposits/
│   │   ├── data/deposit_repository.dart   # contains the P&L rule logic
│   │   ├── presentation/
│   │   └── providers/
│   │
│   ├── reports/
│   │   ├── data/report_repository.dart    # aggregation queries
│   │   ├── presentation/
│   │   │   ├── project_pnl_screen.dart
│   │   │   ├── deposit_ledger_screen.dart
│   │   │   └── consolidated_pnl_screen.dart
│   │   └── providers/
│   │
│   └── settings/
│       ├── presentation/settings_screen.dart
│       └── providers/
│           └── backup_export_provider.dart # DB file export button
│
└── shared/
    ├── widgets/                   # buttons, cards, data tables reused across features
    └── models/                    # plain Dart value objects shared across features
```

## 5. State Management Rules

- One `@riverpod` provider file per feature under `providers/`.
- Repositories are exposed via a `Provider`, DAOs via the `AppDatabase` singleton provider.
- Screens are `ConsumerWidget` / `ConsumerStatefulWidget` — never use `StatefulWidget` with manual `setState` for data that comes from the database.
- Use `AsyncValue` + `.when(data:, loading:, error:)` for all DB-driven UI — no manual loading booleans.
- Form state (unsaved input) can use local `StateProvider`/`TextEditingController` — does not need to go through the repository until submit.

## 6. CRITICAL Business Rule — Deposit vs P&L (implement exactly as described)

A deposit is a **liability**, never income, at the moment it's received.

- **Deposit received** → insert `Transaction(type: deposit, affectsPnl: false)`. Cash balance increases. P&L unaffected.
- **Deposit adjusted to income** → insert a NEW `Transaction(type: income, affectsPnl: true)` for the adjusted amount, and update the linked `Deposit.status` to `adjusted` or `partiallyAdjusted`. Never mutate the original deposit transaction — always add a new linked row so the audit trail is preserved.
- **Deposit refunded** → insert `Transaction(type: depositRefund, affectsPnl: false)`. Cash decreases, deposit liability decreases, P&L still unaffected.

All P&L report queries must filter `WHERE affectsPnl = true`. This is the
single most important rule in the whole app — get it wrong and every report
is incorrect.

## 7. Enums (core/constants/enums.dart)

```dart
enum ProjectType { project, adminOverhead }
enum ProjectStatus { active, onHold, closed }
enum TransactionType { income, expense, purchase, labourPayment, deposit, depositRefund, depositAdjustment }
enum PaymentMode { cash, bank, cheque, online }
enum PaymentStatus { paid, pending, partial }
enum AttendanceStatus { present, halfDay, absent }
enum DepositStatus { held, adjusted, partiallyAdjusted, refunded }
```

## 8. Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Riverpod providers: `camelCaseProvider` (e.g. `projectListProvider`)
- DAO methods: verb-first (`getAllProjects()`, `insertTransaction()`, `watchProjectPnl()`)
- Use `watch*` DAO methods (drift streams) for anything shown live on screen; use `get*` for one-off reads (e.g. during export).

## 9. Explicitly Out of Scope for v1 — do not build these unless asked

- Login / authentication / multi-user roles
- Cloud sync, Supabase, any remote database
- Invoice generation, GST/tax handling
- Charts/graphs
- PDF/Excel export of reports (Settings > Backup DB file export is the only export feature in v1)
- Multi-currency support

## 10. Deliverable Definition of Done

- `flutter build windows` produces a working .exe
- All 7 screens functional: Dashboard, Projects, Cash Book, Purchase, Labour (Attendance + Payment), Deposits, Reports (Project P&L, Deposit Ledger, Consolidated P&L)
- Deposit/P&L rule in Section 6 correctly implemented and verified with at least one manual test case per transaction type
- Settings > Backup Database button works (copies local SQLite file to a user-chosen folder)
- Section 11 verification test case below passes exactly

## 11. Verification Test Case (run this after build to confirm correctness)

Create a project `PRJ-2026-001` ("Luxury Villa Renovation") and enter these
5 transactions in order. After each step, the running totals must match
exactly — use this to catch any bug in the deposit/P&L logic before calling
the build done.

1. **Deposit received:** ₹5,00,000
   → Cash Balance: ₹5,00,000 | Deposit Liability Held: ₹5,00,000 | P&L: ₹0
2. **Purchase:** materials, ₹1,20,000
   → Cash Balance: ₹3,80,000 | Project Purchases: ₹1,20,000
3. **Labour Payment:** 10 days @ ₹1,000/day = ₹10,000
   → Cash Balance: ₹3,70,000 | Project Labour Cost: ₹10,000
4. **Expense:** fuel/transport, ₹5,000
   → Cash Balance: ₹3,65,000 | Project Expenses: ₹5,000
5. **Adjust Deposit to Income:** ₹3,00,000
   → Cash Balance: unchanged at ₹3,65,000 (money was already received in
   step 1 — adjusting does NOT move cash again)
   → Deposit Liability Held: ₹2,00,000 (₹5,00,000 − ₹3,00,000)
   → Project Income: ₹3,00,000 (this now hits P&L)

**Final expected numbers for `PRJ-2026-001`:**
- Total Recognized Income: ₹3,00,000
- Total Costs (Purchases + Labour + Expenses): ₹1,35,000 (₹1,20,000 + ₹10,000 + ₹5,000)
- **Net Project P&L: ₹1,65,000 profit** (₹3,00,000 − ₹1,35,000)
- Deposit Balance Held (liability, separate from P&L): ₹2,00,000
- Physical Cash in Bank/Hand: ₹3,65,000

If any of these five numbers don't match after entering the 5 steps above,
the deposit/P&L separation (Section 6) has a bug — do not consider the
build complete until they match exactly.