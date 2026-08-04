import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

final cashBookRepositoryProvider = Provider<CashBookRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CashBookRepository(db.transactionDao);
});

/// Current cash balance stream.
final cashBalanceProvider = StreamProvider<double>((ref) {
  return ref.watch(cashBookRepositoryProvider).watchCashBalance();
});

/// Filterable cash book entries.
/// Pass [CashBookFilter] via a StateProvider to drive the filter.
class CashBookFilter {
  final int? projectId;
  final List<TransactionType>? types;
  final DateTime? from;
  final DateTime? to;
  CashBookFilter({this.projectId, this.types, this.from, this.to});

  CashBookFilter copyWith({
    int? projectId,
    List<TransactionType>? types,
    DateTime? from,
    DateTime? to,
    bool clearProject = false,
    bool clearTypes = false,
    bool clearFrom = false,
    bool clearTo = false,
  }) =>
      CashBookFilter(
        projectId: clearProject ? null : (projectId ?? this.projectId),
        types: clearTypes ? null : (types ?? this.types),
        from: clearFrom ? null : (from ?? this.from),
        to: clearTo ? null : (to ?? this.to),
      );
}

final cashBookFilterProvider =
    StateProvider<CashBookFilter>((ref) => CashBookFilter());

final cashBookListProvider =
    StreamProvider<List<TransactionWithProject>>((ref) {
  final filter = ref.watch(cashBookFilterProvider);
  final globalProject = ref.watch(selectedProjectIdProvider);
  final effectiveProjectId = filter.projectId ?? globalProject;
  return ref.watch(cashBookRepositoryProvider).watchFiltered(
        projectId: effectiveProjectId,
        types: filter.types,
        from: filter.from,
        to: filter.to,
      );
});
