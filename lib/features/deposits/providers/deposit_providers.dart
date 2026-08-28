import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
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

/// Total security deposits paid to Govt/Client still held (Asset).
final totalDepositsPaidHeldProvider = StreamProvider<double>((ref) {
  return ref.watch(depositRepositoryProvider).watchTotalDepositsPaidHeld();
});

/// Total deposits received from clients still held (Liability).
final totalDepositsReceivedHeldProvider = StreamProvider<double>((ref) {
  return ref.watch(depositRepositoryProvider).watchTotalDepositsReceivedHeld();
});

/// Combined total deposits held.
final totalDepositsHeldProvider = StreamProvider<double>((ref) {
  return ref.watch(depositRepositoryProvider).watchTotalDepositsHeld();
});

/// Filter deposits by project id.
final depositProjectFilterProvider = StateProvider<int?>((ref) => null);

/// Filter deposits by DepositType (null for all).
final depositTypeFilterProvider = StateProvider<DepositType?>((ref) => null);

final filteredDepositListProvider =
    StreamProvider<List<DepositDetail>>((ref) {
  final explicitProjectId = ref.watch(depositProjectFilterProvider);
  final globalProjectId = ref.watch(selectedProjectIdProvider);
  final typeFilter = ref.watch(depositTypeFilterProvider);
  final projectId = explicitProjectId ?? globalProjectId;
  final repo = ref.watch(depositRepositoryProvider);

  Stream<List<DepositDetail>> baseStream;
  if (projectId != null) {
    baseStream = repo.watchDepositsByProject(projectId);
  } else {
    baseStream = repo.watchAllDeposits();
  }

  if (typeFilter != null) {
    return baseStream.map((list) =>
        list.where((d) => d.deposit.depositType == typeFilter).toList());
  }
  return baseStream;
});
