import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/deposits/data/deposit_repository.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DepositRepository(db.depositDao, db.transactionDao, db);
});

final depositListProvider = StreamProvider<List<DepositDetail>>((ref) {
  return ref.watch(depositRepositoryProvider).watchAllDeposits();
});

final totalDepositsHeldProvider = StreamProvider<double>((ref) {
  return ref.watch(depositRepositoryProvider).watchTotalDepositsHeld();
});

/// Filter deposits by project id.
final depositProjectFilterProvider = StateProvider<int?>((ref) => null);

final filteredDepositListProvider =
    StreamProvider<List<DepositDetail>>((ref) {
  final explicitProjectId = ref.watch(depositProjectFilterProvider);
  final globalProjectId = ref.watch(selectedProjectIdProvider);
  final projectId = explicitProjectId ?? globalProjectId;
  final repo = ref.watch(depositRepositoryProvider);
  if (projectId != null) {
    return repo.watchDepositsByProject(projectId);
  }
  return repo.watchAllDeposits();
});
