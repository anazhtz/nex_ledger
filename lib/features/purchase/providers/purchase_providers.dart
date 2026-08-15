import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PurchaseRepository(db.purchaseDao, db.transactionDao, db);
});

final purchaseListProvider = StreamProvider<List<PurchaseDetail>>((ref) {
  return ref.watch(purchaseRepositoryProvider).watchAllPurchases();
});

final vendorListProvider = StreamProvider<List<Vendor>>((ref) {
  return ref.watch(purchaseRepositoryProvider).watchAllVendors();
});

/// Filter for purchase list by project id.
final purchaseProjectFilterProvider = StateProvider<int?>((ref) => null);

final filteredPurchaseListProvider =
    StreamProvider<List<PurchaseDetail>>((ref) {
  final explicitProjectId = ref.watch(purchaseProjectFilterProvider);
  final globalProjectId = ref.watch(selectedProjectIdProvider);
  final projectId = explicitProjectId ?? globalProjectId;
  final repo = ref.watch(purchaseRepositoryProvider);
  if (projectId != null) {
    return repo.watchPurchasesByProject(projectId);
  }
  return repo.watchAllPurchases();
});

// ─── Vendor Ledger Providers ──────────────────────────────────────────────────

/// Reactive stream of a vendor's details (name, contact).
final vendorByIdProvider = StreamProvider.family<Vendor?, int>((ref, vendorId) {
  final db = ref.watch(appDatabaseProvider);
  return db.purchaseDao.watchVendorById(vendorId);
});

/// All purchases for a single vendor across all projects (newest first).
final vendorPurchasesProvider =
    StreamProvider.family<List<PurchaseDetail>, int>((ref, vendorId) {
  final db = ref.watch(appDatabaseProvider);
  return db.purchaseDao.watchPurchasesByVendor(vendorId);
});

/// Vendor ledger summary — totals computed reactively from purchase stream.
class VendorLedgerSummary {
  final double totalPurchases;
  final double totalPaid;
  final double totalPending;

  const VendorLedgerSummary({
    required this.totalPurchases,
    required this.totalPaid,
    required this.totalPending,
  });
}

final vendorLedgerSummaryProvider =
    StreamProvider.family<VendorLedgerSummary, int>((ref, vendorId) {
  return ref.watch(vendorPurchasesProvider(vendorId).stream).map((purchases) {
    double totalPurchases = 0;
    double totalPaid = 0;
    double totalPending = 0;

    for (final pd in purchases) {
      final amount = pd.transaction.amount;
      totalPurchases += amount;
      if (pd.purchase.paymentStatus == PaymentStatus.paid) {
        totalPaid += amount;
      } else {
        // pending or partial — count as payable
        totalPending += amount;
      }
    }

    return VendorLedgerSummary(
      totalPurchases: totalPurchases,
      totalPaid: totalPaid,
      totalPending: totalPending,
    );
  });
});

// ─── Advance Stock Asset Providers ──────────────────────────────────────────

/// Stream of all advance stock purchases.
final advanceStockPurchasesProvider =
    StreamProvider<List<PurchaseDetail>>((ref) {
  final repo = ref.watch(purchaseRepositoryProvider);
  return repo.watchAdvanceStockPurchases();
});

/// Total value of unallocated advance stock held across the company (Asset).
final totalUnallocatedStockAssetProvider = StreamProvider<double>((ref) {
  return ref.watch(advanceStockPurchasesProvider.stream).map((list) {
    return list.fold<double>(0.0, (sum, pd) {
      final remaining =
          pd.transaction.amount - pd.purchase.allocatedAmount;
      return sum + (remaining > 0 ? remaining : 0.0);
    });
  });
});

