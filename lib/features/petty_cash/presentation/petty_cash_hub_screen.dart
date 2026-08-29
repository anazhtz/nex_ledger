import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/daos/petty_cash_dao.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/core/utils/pdf_receipt_service.dart';
import 'package:nex_ledger/features/petty_cash/providers/petty_cash_providers.dart';
import 'package:nex_ledger/features/petty_cash/presentation/widgets/petty_cash_disburse_or_return_dialog.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';
import 'package:nex_ledger/shared/widgets/pdf_preview_dialog.dart';

class PettyCashHubScreen extends ConsumerStatefulWidget {
  const PettyCashHubScreen({super.key});

  @override
  ConsumerState<PettyCashHubScreen> createState() => _PettyCashHubScreenState();
}

class _PettyCashHubScreenState extends ConsumerState<PettyCashHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openDisburseDialog({int? walletId, bool isReturn = false}) {
    showDialog(
      context: context,
      builder: (ctx) => PettyCashDisburseOrReturnDialog(
        initialWalletId: walletId,
        isReturn: isReturn,
      ),
    );
  }

  Future<void> _exportPettyCashVouchersToCsv(List<PettyCashVoucherDetail> vouchers) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(
          'Date,Type,Supervisor Name,Phone,Project Site,Category,Cost Head,Voucher #,Amount (INR),Payment Mode,Bank Account,Narration,Verified By');

      for (final v in vouchers) {
        final voc = v.voucher;
        buffer.writeln(
            '"${DateFormatter.format(voc.date)}","${voc.type.displayName}","${v.wallet.supervisorName}","${v.wallet.phone}","${v.project.name}","${voc.category}","${voc.costHead.displayName}","${voc.voucherNumber ?? ''}",${voc.amount},"${voc.paymentMode?.name ?? ''}","${v.bankAccount?.bankName ?? 'Cash Drawer'}","${voc.narration}","${voc.verifiedBy ?? ''}"');
      }

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/petty_cash_audit_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(buffer.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Petty cash audit report exported to: $path'),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(pettyCashPortfolioMetricsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header & Action Bar ─────────────────────────────────────────
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16.w,
              runSpacing: 12.h,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 550.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Site Supervisor Petty Cash & Floats',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Clear audit of cash advances handed to site engineers, expense vouchers & unspent pocket balances',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        final list = ref.read(allPettyCashVouchersProvider).valueOrNull ?? [];
                        if (list.isNotEmpty) _exportPettyCashVouchersToCsv(list);
                      },
                      icon: Icon(Icons.file_download_outlined, size: 16.sp),
                      label: const Text('Export CSV Audit'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => context.go('/petty-cash/wallets/new'),
                      icon: Icon(Icons.person_add_alt_1_outlined, size: 16.sp),
                      label: const Text('+ Add Supervisor'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _openDisburseDialog(isReturn: true),
                      icon: Icon(Icons.arrow_back_rounded, size: 16.sp, color: const Color(0xFF059669)),
                      label: const Text('Return Cash'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _openDisburseDialog(isReturn: false),
                      icon: Icon(Icons.payments_outlined, size: 16.sp),
                      label: const Text('+ Disburse Advance'),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.go('/petty-cash/vouchers/new'),
                      icon: Icon(Icons.receipt_long_outlined, size: 16.sp),
                      label: const Text('+ Record Site Voucher'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // ─── KPI Row ─────────────────────────────────────────────────────
            metricsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (m) => _buildKpiRow(m),
            ),
            SizedBox(height: 14.h),

            // ─── Navigation Tabs ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF2563EB),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: const Color(0xFF2563EB),
                tabs: const [
                  Tab(icon: Icon(Icons.wallet_outlined), text: 'Supervisor Cash Wallets'),
                  Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Daily Vouchers & Cash Ledger'),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ─── Tab Views ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWalletsTab(context),
                  _buildVouchersTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── KPI Row Widget ─────────────────────────────────────────────────────────

  Widget _buildKpiRow(PettyCashPortfolioMetrics m) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 36.w) / 4 > 220.w
            ? (constraints.maxWidth - 36.w) / 4
            : 220.w;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Active Site Supervisors',
                    value: '${m.activeSupervisorsCount} Supervisors',
                    subtitle: 'Holding site imprest floats',
                    icon: Icons.people_outline_rounded,
                    color: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFFEFF6FF),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Total Advances Disbursed',
                    value: CurrencyFormatter.format(m.totalFloatDisbursed),
                    subtitle: 'Cash handed from office/bank',
                    icon: Icons.arrow_outward_rounded,
                    color: const Color(0xFF6366F1),
                    bgColor: const Color(0xFFEEF2FF),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Site Expenses Claimed',
                    value: CurrencyFormatter.format(m.totalSiteExpensesClaimed),
                    subtitle: 'Vouchers recognized in Project P&L',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF10B981),
                    bgColor: const Color(0xFFECFDF5),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Unspent Cash in Pockets',
                    value: CurrencyFormatter.format(m.totalCashInSupervisorsPockets),
                    subtitle: 'Running physical cash on sites',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 1: Supervisor Cash Wallets ─────────────────────────────────────────

  Widget _buildWalletsTab(BuildContext context) {
    final walletsAsync = ref.watch(filteredWalletsProvider);

    return Column(
      children: [
        // Filter Row
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: SizedBox(
              width: 340.w,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search supervisor name, phone, site...',
                  prefixIcon: Icon(Icons.search, size: 18.sp),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                ),
                onChanged: (v) =>
                    ref.read(pettyCashSearchQueryProvider.notifier).state = v,
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // Wallets Table
        Expanded(
          child: walletsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading wallets: $e')),
            data: (wallets) {
              if (wallets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 48.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(height: 12.h),
                      Text('No supervisor wallets registered.',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                      SizedBox(height: 8.h),
                      FilledButton.tonal(
                        onPressed: () => context.go('/petty-cash/wallets/new'),
                        child: const Text('+ Add First Supervisor Wallet'),
                      ),
                    ],
                  ),
                );
              }

              return DataTableCard(
                minWidth: 1000.w,
                columns: const [
                  DataColumn(label: Text('Supervisor & Contact')),
                  DataColumn(label: Text('Assigned Site')),
                  DataColumn(label: Text('Approved Float Limit')),
                  DataColumn(label: Text('Total Advances Disbursed')),
                  DataColumn(label: Text('Total Expenses Claimed')),
                  DataColumn(label: Text('Cash Returned')),
                  DataColumn(label: Text('Cash in Pocket (Balance)')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: wallets.map((w) {
                  final wallet = w.wallet;
                  final balanceColor = w.currentUnspentCashBalance > wallet.maxFloatLimit
                      ? const Color(0xFFDC2626)
                      : (w.currentUnspentCashBalance > 0
                          ? const Color(0xFF059669)
                          : const Color(0xFF64748B));

                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(wallet.supervisorName,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                            Text(wallet.phone,
                                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          w.assignedProject != null
                              ? '${w.assignedProject!.code} — ${w.assignedProject!.name}'
                              : 'Multi-Site / Float',
                          style: TextStyle(fontSize: 11.sp),
                        ),
                      ),
                      DataCell(Text(CurrencyFormatter.format(wallet.maxFloatLimit),
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500))),
                      DataCell(Text(CurrencyFormatter.format(w.totalAdvancesReceived),
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF2563EB), fontWeight: FontWeight.w600))),
                      DataCell(Text(CurrencyFormatter.format(w.totalExpensesClaimed),
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF059669), fontWeight: FontWeight.w600))),
                      DataCell(Text(CurrencyFormatter.format(w.totalCashReturned),
                          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)))),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: balanceColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            CurrencyFormatter.format(w.currentUnspentCashBalance),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: balanceColor,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.payments_outlined, size: 16.sp, color: const Color(0xFF2563EB)),
                              tooltip: 'Disburse Advance Float',
                              onPressed: () => _openDisburseDialog(walletId: wallet.id, isReturn: false),
                            ),
                            IconButton(
                              icon: Icon(Icons.receipt_long_outlined, size: 16.sp, color: const Color(0xFF059669)),
                              tooltip: 'Record Site Voucher',
                              onPressed: () => context.go('/petty-cash/vouchers/new?walletId=${wallet.id}&projectId=${wallet.assignedProjectId ?? ''}'),
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_back_rounded, size: 16.sp, color: const Color(0xFFD97706)),
                              tooltip: 'Return Unspent Cash',
                              onPressed: () => _openDisburseDialog(walletId: wallet.id, isReturn: true),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 16.sp, color: const Color(0xFF64748B)),
                              tooltip: 'Edit Wallet',
                              onPressed: () => context.go('/petty-cash/wallets/${wallet.id}/edit'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Tab 2: Daily Vouchers & Cash Advances Ledger ─────────────────────────

  Widget _buildVouchersTab(BuildContext context) {
    final filteredVouchersAsync = ref.watch(filteredPettyCashVouchersProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final walletsAsync = ref.watch(allWalletsProvider);
    final selectedFilterProject = ref.watch(pettyCashFilterProjectProvider);
    final selectedFilterSupervisor = ref.watch(pettyCashFilterSupervisorProvider);
    final selectedFilterType = ref.watch(pettyCashFilterTypeProvider);

    return Column(
      children: [
        // Filter Row
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                SizedBox(
                  width: 260.w,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search narration, voucher #...',
                      prefixIcon: Icon(Icons.search, size: 18.sp),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    ),
                    onChanged: (v) =>
                        ref.read(pettyCashSearchQueryProvider.notifier).state = v,
                  ),
                ),
                walletsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (wallets) => SizedBox(
                    width: 220.w,
                    child: DropdownButtonFormField<int?>(
                      value: selectedFilterSupervisor,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Filter Supervisor',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Supervisors', overflow: TextOverflow.ellipsis)),
                        ...wallets.map(
                          (w) => DropdownMenuItem(
                            value: w.wallet.id,
                            child: Text(w.wallet.supervisorName, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          ref.read(pettyCashFilterSupervisorProvider.notifier).state = v,
                    ),
                  ),
                ),
                projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (projects) => SizedBox(
                    width: 220.w,
                    child: DropdownButtonFormField<int?>(
                      value: selectedFilterProject,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Filter Project',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Projects', overflow: TextOverflow.ellipsis)),
                        ...projects.map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          ref.read(pettyCashFilterProjectProvider.notifier).state = v,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200.w,
                  child: DropdownButtonFormField<PettyCashTxnType?>(
                    value: selectedFilterType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Entry Type',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Types', overflow: TextOverflow.ellipsis)),
                      ...PettyCashTxnType.values.map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.displayName, overflow: TextOverflow.ellipsis)),
                      ),
                    ],
                    onChanged: (v) =>
                        ref.read(pettyCashFilterTypeProvider.notifier).state = v,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // Vouchers Table
        Expanded(
          child: filteredVouchersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading vouchers: $e')),
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(height: 12.h),
                      Text('No petty cash transactions recorded.',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                      SizedBox(height: 8.h),
                      FilledButton.tonal(
                        onPressed: () => context.go('/petty-cash/vouchers/new'),
                        child: const Text('+ Record First Site Voucher'),
                      ),
                    ],
                  ),
                );
              }

              return DataTableCard(
                minWidth: 1050.w,
                columns: const [
                  DataColumn(label: Text('Date & Ref #')),
                  DataColumn(label: Text('Entry Type')),
                  DataColumn(label: Text('Supervisor & Project')),
                  DataColumn(label: Text('Category / Cost Head')),
                  DataColumn(label: Text('Amount (₹)')),
                  DataColumn(label: Text('Mode & Bank')),
                  DataColumn(label: Text('P&L Impact')),
                  DataColumn(label: Text('Narration')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: list.map((item) {
                  final v = item.voucher;
                  final typeColor = switch (v.type) {
                    PettyCashTxnType.advanceDisbursed || PettyCashTxnType.floatReplenished => const Color(0xFF2563EB),
                    PettyCashTxnType.voucherExpense => const Color(0xFF059669),
                    PettyCashTxnType.cashReturned => const Color(0xFFD97706),
                  };

                  final isPnlHit = v.type == PettyCashTxnType.voucherExpense;

                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateFormatter.format(v.date),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                            if (v.voucherNumber != null)
                              Text(v.voucherNumber!,
                                  style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B), fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            switch (v.type) {
                              PettyCashTxnType.advanceDisbursed => 'Advance Float',
                              PettyCashTxnType.voucherExpense => 'Site Voucher',
                              PettyCashTxnType.cashReturned => 'Cash Return',
                              PettyCashTxnType.floatReplenished => 'Replenished',
                            },
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: typeColor),
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item.wallet.supervisorName,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
                            Text('${item.project.code}',
                                style: TextStyle(fontSize: 10.sp, color: const Color(0xFF2563EB))),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(v.category, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500)),
                            if (v.type == PettyCashTxnType.voucherExpense)
                              Text(v.costHead.displayName,
                                  style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      DataCell(Text(
                        CurrencyFormatter.format(v.amount),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: typeColor),
                      )),
                      DataCell(
                        Text(
                          item.bankAccount != null
                              ? '${item.bankAccount!.bankName}'
                              : (v.paymentMode?.name.toUpperCase() ?? 'CASH'),
                          style: TextStyle(fontSize: 11.sp),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isPnlHit ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            isPnlHit ? 'Project Expense (P&L)' : '₹0 (Float Transfer)',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: isPnlHit ? const Color(0xFF059669) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 140.w,
                          child: Text(
                            v.narration,
                            style: TextStyle(fontSize: 11.sp),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.print_outlined, size: 16.sp, color: const Color(0xFF2563EB)),
                              tooltip: 'Print Voucher (PDF)',
                              onPressed: () {
                                PdfPreviewDialog.show(
                                  context: context,
                                  title: 'Petty Cash Voucher — #${v.voucherNumber ?? v.id}',
                                  pdfBuilder: (format) =>
                                      PdfReceiptService.generatePettyCashVoucher(
                                    voucher: v,
                                    supervisorName: item.wallet.supervisorName,
                                    projectCode: item.project.code,
                                    projectName: item.project.name,
                                    bankAccountName: item.bankAccount?.accountName,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 16.sp, color: const Color(0xFFEF4444)),
                              tooltip: 'Delete Entry',
                              onPressed: () => _confirmDeleteVoucher(context, v.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDeleteVoucher(BuildContext context, int voucherId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Petty Cash Entry?'),
        content: const Text('This will delete the voucher and reconcile the supervisor cash balance.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(pettyCashRepositoryProvider).deleteVoucher(voucherId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
