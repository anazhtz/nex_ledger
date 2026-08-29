import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/reports/data/ledger_repository.dart';
import 'package:nex_ledger/features/reports/models/ledger_models.dart';

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LedgerRepository(db);
});

/// Active ledger tab in the Ledgers Hub (Supplier, Labour, Bank/Cash, Personal).
final activeLedgerTabProvider =
    StateProvider<LedgerType>((ref) => LedgerType.supplier);

/// Selected vendor ID in the Supplier ledger view.
final selectedLedgerVendorIdProvider = StateProvider<int?>((ref) => null);

/// Selected worker ID in the Labour ledger view.
final selectedLedgerWorkerIdProvider = StateProvider<int?>((ref) => null);

/// Selected Bank Account ID in the Bank/Cash ledger view (null = Physical Cash in Hand).
final selectedLedgerBankAccountIdProvider = StateProvider<int?>((ref) => null);

/// Optional project filter across ledger statements.
final ledgerProjectFilterProvider = StateProvider<int?>((ref) => null);

/// Optional date range filter across ledger statements.
final ledgerDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// ─── STREAM PROVIDERS ────────────────────────────────────────────────────────

/// Supplier / Vendor Ledger Stream
final vendorLedgerProvider =
    StreamProvider.family<({LedgerSummary summary, List<LedgerEntry> entries}), int>(
  (ref, vendorId) {
    final repo = ref.watch(ledgerRepositoryProvider);
    final projectId = ref.watch(ledgerProjectFilterProvider);
    final dateRange = ref.watch(ledgerDateRangeProvider);
    return repo.watchVendorLedger(vendorId, projectId: projectId, dateRange: dateRange);
  },
);

/// Labour / Worker Ledger Stream
final workerLedgerProvider =
    StreamProvider.family<({LedgerSummary summary, List<LedgerEntry> entries}), int>(
  (ref, workerId) {
    final repo = ref.watch(ledgerRepositoryProvider);
    final projectId = ref.watch(ledgerProjectFilterProvider);
    final dateRange = ref.watch(ledgerDateRangeProvider);
    return repo.watchWorkerLedger(workerId, projectId: projectId, dateRange: dateRange);
  },
);

/// Bank Account / Cash in Hand Ledger Stream
final accountLedgerProvider =
    StreamProvider.family<({LedgerSummary summary, List<LedgerEntry> entries}), int?>(
  (ref, bankAccountId) {
    final repo = ref.watch(ledgerRepositoryProvider);
    final dateRange = ref.watch(ledgerDateRangeProvider);
    return repo.watchAccountLedger(bankAccountId: bankAccountId, dateRange: dateRange);
  },
);

/// Personal / Owner Capital & Drawings Ledger Stream
final personalLedgerProvider =
    StreamProvider<({LedgerSummary summary, List<LedgerEntry> entries})>(
  (ref) {
    final repo = ref.watch(ledgerRepositoryProvider);
    final dateRange = ref.watch(ledgerDateRangeProvider);
    return repo.watchPersonalLedger(dateRange: dateRange);
  },
);

/// Selected Subcontractor ID in the Subcontractor ledger view.
final selectedLedgerSubcontractorIdProvider = StateProvider<int?>((ref) => null);

/// Subcontractor / Piece-Rate Ledger Stream
final subcontractorLedgerProvider =
    StreamProvider.family<({LedgerSummary summary, List<LedgerEntry> entries}), int>(
  (ref, subcontractorId) {
    final repo = ref.watch(ledgerRepositoryProvider);
    final projectId = ref.watch(ledgerProjectFilterProvider);
    final dateRange = ref.watch(ledgerDateRangeProvider);
    return repo.watchSubcontractorLedger(subcontractorId, projectId: projectId, dateRange: dateRange);
  },
);
