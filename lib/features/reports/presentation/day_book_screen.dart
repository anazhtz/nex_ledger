import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';
import 'package:nex_ledger/features/reports/providers/report_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';
import 'package:nex_ledger/shared/widgets/stat_card.dart';

class DayBookScreen extends ConsumerWidget {
  const DayBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDayBookDateProvider);
    final selectedBankAccountId = ref.watch(selectedDayBookBankAccountIdProvider);
    final dayBookAsync = ref.watch(dayBookReportProvider);
    final accountsAsync = ref.watch(bankAccountsWithBalancesProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header & Date Controls ───
            _buildHeader(context, ref, selectedDate, theme),
            SizedBox(height: 16.h),

            // ─── Filter Bar (Account & Quick Dates) ───
            _buildFilterBar(context, ref, selectedDate, selectedBankAccountId, accountsAsync, theme),
            SizedBox(height: 20.h),

            // ─── Main Content (Stats & Transactions Table) ───
            dayBookAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Error loading day-book: $err', style: TextStyle(color: Colors.red.shade700)),
                ),
              ),
              data: (report) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 5 Metric Stat Cards
                  _buildSummaryCards(report),
                  SizedBox(height: 24.h),

                  // Transactions Table Card
                  _buildTransactionsCard(context, ref, report, selectedProjectId, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, DateTime selectedDate, ThemeData theme) {
    final isToday = _isSameDay(selectedDate, DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.today_rounded, color: const Color(0xFF4F46E5), size: 28.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Day-Book Sheet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Complete day-by-day cash book, income, expenses & closing audit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),

        // Date Picker & Navigator Pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFCBD5E1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Previous Day',
                onPressed: () {
                  ref.read(selectedDayBookDateProvider.notifier).state =
                      selectedDate.subtract(const Duration(days: 1));
                },
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    ref.read(selectedDayBookDateProvider.notifier).state = picked;
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 18.sp, color: const Color(0xFF4F46E5)),
                      SizedBox(width: 8.w),
                      Text(
                        isToday
                            ? 'Today (${DateFormatter.format(selectedDate)})'
                            : DateFormatter.format(selectedDate),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Next Day',
                onPressed: () {
                  ref.read(selectedDayBookDateProvider.notifier).state =
                      selectedDate.add(const Duration(days: 1));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    int? selectedBankAccountId,
    AsyncValue<List<dynamic>> accountsAsync,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            // Quick preset pills: Today, Yesterday
            OutlinedButton.icon(
              onPressed: () {
                ref.read(selectedDayBookDateProvider.notifier).state = DateTime.now();
              },
              icon: const Icon(Icons.today_rounded, size: 16),
              label: const Text('Today'),
              style: OutlinedButton.styleFrom(
                backgroundColor: _isSameDay(selectedDate, DateTime.now())
                    ? const Color(0xFFEEF2FF)
                    : null,
                foregroundColor: _isSameDay(selectedDate, DateTime.now())
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF475569),
                side: BorderSide(
                  color: _isSameDay(selectedDate, DateTime.now())
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFCBD5E1),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(selectedDayBookDateProvider.notifier).state =
                    DateTime.now().subtract(const Duration(days: 1));
              },
              icon: const Icon(Icons.history_rounded, size: 16),
              label: const Text('Yesterday'),
              style: OutlinedButton.styleFrom(
                backgroundColor: _isSameDay(selectedDate, DateTime.now().subtract(const Duration(days: 1)))
                    ? const Color(0xFFEEF2FF)
                    : null,
                foregroundColor: _isSameDay(selectedDate, DateTime.now().subtract(const Duration(days: 1)))
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF475569),
                side: BorderSide(
                  color: _isSameDay(selectedDate, DateTime.now().subtract(const Duration(days: 1)))
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFCBD5E1),
                ),
              ),
            ),

            const Spacer(),

            // Bank Account filter
            accountsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (accounts) {
                return SizedBox(
                  width: 260.w,
                  child: DropdownButtonFormField<int?>(
                    value: selectedBankAccountId,
                    isExpanded: true,
                    isDense: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      labelText: 'Account / Drawer Filter',
                      prefixIcon: const Icon(Icons.account_balance_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Cash & Bank Accounts'),
                      ),
                      ...accounts.map(
                        (a) => DropdownMenuItem(
                          value: a.account.id as int,
                          child: Text(
                            '${a.account.accountName} (${a.account.isCashAccount ? 'Cash' : 'Bank'})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      ref.read(selectedDayBookBankAccountIdProvider.notifier).state = v;
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(DayBookReport report) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 950;

      final cards = [
        StatCard(
          label: 'Opening Balance',
          value: CurrencyFormatter.format(report.openingBalance),
          icon: Icons.account_balance_wallet_outlined,
          iconColor: const Color(0xFF64748B),
          valueColor: report.openingBalance < 0 ? const Color(0xFFDC2626) : const Color(0xFF1E293B),
          subtitle: 'Funds at start of day',
        ),
        StatCard(
          label: 'Total Receipts (Inflow)',
          value: '+${CurrencyFormatter.format(report.totalInflow)}',
          icon: Icons.arrow_downward_rounded,
          iconColor: const Color(0xFF059669),
          valueColor: const Color(0xFF059669),
          subtitle: 'Income & customer deposits',
        ),
        StatCard(
          label: 'Total Payments (Outflow)',
          value: '-${CurrencyFormatter.format(report.totalOutflow)}',
          icon: Icons.arrow_upward_rounded,
          iconColor: const Color(0xFFDC2626),
          valueColor: const Color(0xFFDC2626),
          subtitle: 'Expenses, labour & purchases',
        ),
        StatCard(
          label: 'Net Day Movement',
          value: (report.netMovement >= 0 ? '+' : '') + CurrencyFormatter.format(report.netMovement),
          icon: Icons.swap_vert_rounded,
          iconColor: report.netMovement >= 0 ? const Color(0xFF2563EB) : const Color(0xFFDC2626),
          valueColor: report.netMovement >= 0 ? const Color(0xFF2563EB) : const Color(0xFFDC2626),
          subtitle: 'Cash in minus cash out today',
        ),
        StatCard(
          label: 'Closing Balance',
          value: CurrencyFormatter.format(report.closingBalance),
          icon: Icons.lock_clock_outlined,
          iconColor: const Color(0xFF4F46E5),
          valueColor: report.closingBalance < 0 ? const Color(0xFFDC2626) : const Color(0xFF4F46E5),
          subtitle: 'Funds at close of day',
        ),
      ];

      if (isCompact) {
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: cards.map((c) => SizedBox(width: (constraints.maxWidth - 24.w) / 2, child: c)).toList(),
        );
      }

      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: c))).toList(),
      );
    });
  }

  Widget _buildTransactionsCard(
    BuildContext context,
    WidgetRef ref,
    DayBookReport report,
    int? selectedProjectId,
    ThemeData theme,
  ) {
    if (report.entries.isEmpty) {
      return Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_note_outlined, size: 54.sp, color: const Color(0xFF94A3B8)),
                SizedBox(height: 14.h),
                Text(
                  'No Transactions on ${DateFormatter.format(report.date)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Opening balance (${CurrencyFormatter.format(report.openingBalance)}) carried forward seamlessly as closing balance.',
                  style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.go('/cash-book/new'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Record Expense / Income'),
                    ),
                    SizedBox(width: 12.w),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/purchases/new'),
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text('Record Purchase'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DataTableCard(
      title: 'Transactions Log (${report.entries.length} Entries) — ${DateFormatter.format(report.date)}',
      action: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: report.netPnl >= 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          'Day Net P&L: ${report.netPnl >= 0 ? '+' : ''}${CurrencyFormatter.format(report.netPnl)}',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: report.netPnl >= 0 ? const Color(0xFF166534) : const Color(0xFF991B1B),
          ),
        ),
      ),
      columns: const [
        DataColumn(label: Text('Ref / Time')),
        DataColumn(label: Text('Project')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Particulars / Narration')),
        DataColumn(label: Text('Payment Mode')),
        DataColumn(numeric: true, label: Text('Inflow (Receipt)')),
        DataColumn(numeric: true, label: Text('Outflow (Payment)')),
        DataColumn(label: Text('P&L Impact')),
      ],
      rows: report.entries.map((e) {
        final t = e.transaction;
        final isCashIn = e.isInflow && t.affectsCash;
        final isCashOut = e.isOutflow && t.affectsCash;

        return DataRow(
          cells: [
            DataCell(Text(t.referenceNo ?? '—', style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.project.code, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
                  Text(e.project.name, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                ],
              ),
            ),
            DataCell(_buildTypeBadge(t.type)),
            DataCell(
              Text(
                t.narration ?? '—',
                style: const TextStyle(color: Color(0xFF334155)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    t.paymentMode == PaymentMode.cash ? Icons.payments_outlined : Icons.account_balance_outlined,
                    size: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                  SizedBox(width: 4.w),
                  Text(t.paymentMode?.displayName ?? '—'),
                ],
              ),
            ),
            DataCell(
              isCashIn
                  ? Text(
                      '+${CurrencyFormatter.format(t.amount)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                    )
                  : const Text('—', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            DataCell(
              isCashOut
                  ? Text(
                      '-${CurrencyFormatter.format(t.amount)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                    )
                  : const Text('—', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            DataCell(
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: t.affectsPnl ? const Color(0xFFF1F5F9) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  t.affectsPnl ? 'Hits P&L' : 'Balance Sheet Only',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: t.affectsPnl ? const Color(0xFF475569) : const Color(0xFF92400E),
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTypeBadge(TransactionType type) {
    Color bg;
    Color fg;
    String label;

    switch (type) {
      case TransactionType.income:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'Income';
        break;
      case TransactionType.expense:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Expense';
        break;
      case TransactionType.purchase:
      case TransactionType.purchasePayment:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = type == TransactionType.purchase ? 'Purchase Bill' : 'Vendor Payment';
        break;
      case TransactionType.labourPayment:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        label = 'Labour Wages';
        break;
      case TransactionType.deposit:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF075985);
        label = 'Deposit In';
        break;
      case TransactionType.depositRefund:
        bg = const Color(0xFFFCE7F3);
        fg = const Color(0xFF9D174D);
        label = 'Deposit Refund';
        break;
      case TransactionType.depositPaid:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF334155);
        label = 'Deposit Paid (Govt)';
        break;
      case TransactionType.depositRecovery:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        label = 'Deposit Recovered';
        break;
      case TransactionType.depositAdjustment:
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF5B21B6);
        label = 'Deposit Adjusted';
        break;
      case TransactionType.stockAllocation:
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF6B21A8);
        label = 'Stock Allocated';
        break;
      case TransactionType.ownerCapital:
        bg = const Color(0xFFCCFBF1);
        fg = const Color(0xFF115E59);
        label = 'Owner Capital';
        break;
      case TransactionType.drawings:
        bg = const Color(0xFFFFE4E6);
        fg = const Color(0xFF9F1239);
        label = 'Owner Drawings';
        break;
      case TransactionType.subcontractBill:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF3730A3);
        label = 'Subcontract RA Bill';
        break;
      case TransactionType.subcontractPayment:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Subcontract Payment';
        break;
      case TransactionType.clientRaBill:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'Client RA Bill';
        break;
      case TransactionType.clientReceipt:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        label = 'Client Receipt';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
