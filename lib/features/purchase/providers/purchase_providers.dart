import 'package:flutter_riverpod/flutter_riverpod.dart';
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
