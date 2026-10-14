import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/shared/widgets/project_picker.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';
import 'package:nex_ledger/features/reports/data/purchase_register.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';
import 'package:nex_ledger/shared/widgets/stat_card.dart';

/// Purchase Register: every purchase bill with filters, plus a shop-wise view.
/// [byShop] chooses which view opens first.
class PurchaseRegisterScreen extends ConsumerStatefulWidget {
  final bool byShop;
  const PurchaseRegisterScreen({super.key, this.byShop = false});

  @override
  ConsumerState<PurchaseRegisterScreen> createState() =>
      _PurchaseRegisterScreenState();
}

class _PurchaseRegisterScreenState
    extends ConsumerState<PurchaseRegisterScreen> {
  PurchaseFilter _filter = const PurchaseFilter();
  late bool _byShop = widget.byShop;
  bool _exporting = false;

  static const _green = Color(0xFF059669);
  static const _red = Color(0xFFDC2626);
  static const _amber = Color(0xFFD97706);

  String _rangeLabel() {
    final r = _filter.dateRange;
    if (r == null) return 'All time';
    return '${DateFormatter.format(r.start)} – ${DateFormatter.format(r.end)}';
  }

  Future<void> _pickRange(String choice) async {
    final now = DateTime.now();
    DateTimeRange? range;
    switch (choice) {
      case 'all':
        setState(() => _filter = _filter.copyWith(clearDateRange: true));
        return;
      case 'this_month':
        range = DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month + 1, 0));
      case 'last_month':
        range = DateTimeRange(
            start: DateTime(now.year, now.month - 1, 1),
            end: DateTime(now.year, now.month, 0));
      case 'fy':
        range = financialYearRange(now);
      case 'custom':
        range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: _filter.dateRange,
        );
    }
    if (range != null && mounted) {
      setState(() => _filter = _filter.copyWith(dateRange: range));
    }
  }

  Future<void> _export(List<PurchaseDetail> rows, List<Project> projects,
      List<Vendor> vendors) async {
    setState(() => _exporting = true);
    try {
      final text = describePurchaseFilter(
        _filter,
        projectName: projects
            .where((p) => p.id == _filter.projectId)
            .map((p) => '${p.code} — ${p.name}')
            .firstOrNull,
        vendorName: vendors
            .where((v) => v.id == _filter.vendorId)
            .map((v) => v.name)
            .firstOrNull,
        formatDate: DateFormatter.format,
      );
      final path = await ExcelExportService.exportPurchaseRegister(
          rows: rows, filterText: text);
      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Purchase register exported: $path'),
          backgroundColor: _green,
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Export failed: $e'),
        backgroundColor: Colors.red.shade700,
      ));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final purchasesAsync = ref.watch(purchaseListProvider);
    final projects =
        ref.watch(projectListProvider).asData?.value ?? const <Project>[];
    final vendors =
        ref.watch(vendorListProvider).asData?.value ?? const <Vendor>[];

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: purchasesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final rows = applyPurchaseFilter(all, _filter);
          final totals = purchaseTotals(rows);
          return Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(theme, rows, projects, vendors),
                SizedBox(height: 14.h),
                _filterBar(projects, vendors),
                SizedBox(height: 14.h),
                _summaryCards(totals),
                SizedBox(height: 14.h),
                Expanded(
                  child: _byShop ? _shopTable(rows) : _billsTable(rows),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(ThemeData theme, List<PurchaseDetail> rows,
      List<Project> projects, List<Vendor> vendors) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 10,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _byShop ? 'Shop-wise Purchases' : 'Purchase Register',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              _byShop
                  ? 'How much you bought from each shop, what is paid and what you still owe'
                  : 'Every purchase bill. Filter by project, shop, date or payment status',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: _exporting || rows.isEmpty
              ? null
              : () => _export(rows, projects, vendors),
          icon: _exporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(_exporting ? 'Exporting...' : 'Export Excel (.xlsx)'),
          style: FilledButton.styleFrom(backgroundColor: _green),
        ),
      ],
    );
  }

  Widget _filterBar(List<Project> projects, List<Vendor> vendors) {
    final projectValue = projects.any((p) => p.id == _filter.projectId)
        ? _filter.projectId
        : null;
    final vendorValue =
        vendors.any((v) => v.id == _filter.vendorId) ? _filter.vendorId : null;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 230,
              child: ProjectPickerField(
                projects: projects,
                value: projectValue,
                labelText: 'Project',
                allLabel: 'All Projects',
                onChanged: (v) => setState(() => _filter = v == null
                    ? _filter.copyWith(clearProject: true)
                    : _filter.copyWith(projectId: v)),
              ),
            ),
            SizedBox(
              width: 230,
              child: DropdownButtonFormField<int?>(
                key: ValueKey('shop-$vendorValue'),
                value: vendorValue,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'Shop / Supplier', isDense: true),
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('All Shops')),
                  ...vendors.map((v) => DropdownMenuItem<int?>(
                        value: v.id,
                        child: Text(v.name, overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (v) => setState(() => _filter = v == null
                    ? _filter.copyWith(clearVendor: true)
                    : _filter.copyWith(vendorId: v)),
              ),
            ),
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<PaymentStatus?>(
                key: ValueKey('status-${_filter.status}'),
                value: _filter.status,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Payment', isDense: true),
                items: [
                  const DropdownMenuItem<PaymentStatus?>(
                      value: null, child: Text('All')),
                  ...PaymentStatus.values.map((s) =>
                      DropdownMenuItem<PaymentStatus?>(
                          value: s, child: Text(s.displayName))),
                ],
                onChanged: (v) => setState(() => _filter = v == null
                    ? _filter.copyWith(clearStatus: true)
                    : _filter.copyWith(status: v)),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Choose a period',
              onSelected: _pickRange,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'all', child: Text('All time')),
                PopupMenuItem(value: 'this_month', child: Text('This month')),
                PopupMenuItem(value: 'last_month', child: Text('Last month')),
                PopupMenuItem(
                    value: 'fy', child: Text('This financial year (Apr–Mar)')),
                PopupMenuDivider(),
                PopupMenuItem(value: 'custom', child: Text('Choose dates...')),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 18, color: Color(0xFF1F5FBF)),
                    const SizedBox(width: 8),
                    Text(_rangeLabel(),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
            if (!_filter.isEmpty)
              TextButton.icon(
                onPressed: () =>
                    setState(() => _filter = const PurchaseFilter()),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Clear filters'),
              ),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('All Bills')),
                ButtonSegment(value: true, label: Text('By Shop')),
              ],
              selected: {_byShop},
              onSelectionChanged: (s) => setState(() => _byShop = s.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards(PurchaseTotals t) {
    final cards = [
      StatCard(
        label: 'Bills',
        value: '${t.count}',
        icon: Icons.receipt_long_outlined,
      ),
      StatCard(
        label: 'Total Purchased',
        value: CurrencyFormatter.format(t.total),
        icon: Icons.shopping_bag_outlined,
        iconColor: const Color(0xFF1F5FBF),
      ),
      StatCard(
        label: 'Paid',
        value: CurrencyFormatter.format(t.paid),
        icon: Icons.check_circle_outline,
        iconColor: _green,
        valueColor: _green,
      ),
      StatCard(
        label: 'Balance to Pay',
        value: CurrencyFormatter.format(t.balance),
        icon: Icons.pending_actions_outlined,
        iconColor: t.balance > 0 ? _red : _green,
        valueColor: t.balance > 0 ? _red : _green,
      ),
    ];
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 760) {
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final card in cards)
            SizedBox(width: (c.maxWidth - 12) / 2, child: card),
        ]);
      }
      return Row(children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: cards[i]),
        ],
      ]);
    });
  }

  Widget _statusChip(PaymentStatus s) {
    final (color, bg) = switch (s) {
      PaymentStatus.paid => (_green, const Color(0xFFECFDF5)),
      PaymentStatus.partial => (_amber, const Color(0xFFFFFBEB)),
      PaymentStatus.pending => (_red, const Color(0xFFFEF2F2)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(s.displayName,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _billsTable(List<PurchaseDetail> rows) {
    return DataTableCard(
      title: 'Purchase Bills (${rows.length})',
      emptyMessage: _filter.isEmpty
          ? 'No purchases recorded yet.'
          : 'No purchases match these filters.',
      minWidth: 1000,
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Shop')),
        DataColumn(label: Text('Project')),
        DataColumn(label: Text('Item')),
        DataColumn(label: Text('Bill Amount'), numeric: true),
        DataColumn(label: Text('Paid'), numeric: true),
        DataColumn(label: Text('Balance'), numeric: true),
        DataColumn(label: Text('Status')),
      ],
      rows: [
        for (final d in rows)
          DataRow(cells: [
            DataCell(Text(DateFormatter.format(d.transaction.date))),
            DataCell(
              Text(d.vendor.name,
                  style: const TextStyle(
                      color: Color(0xFF1F5FBF), fontWeight: FontWeight.w600)),
              onTap: () => context.push('/vendors/${d.vendor.id}'),
            ),
            DataCell(ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(d.project.code, overflow: TextOverflow.ellipsis),
            )),
            DataCell(ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(d.purchase.itemDescription,
                  overflow: TextOverflow.ellipsis),
            )),
            DataCell(Text(CurrencyFormatter.format(d.transaction.amount),
                style: const TextStyle(fontWeight: FontWeight.w700))),
            DataCell(Text(CurrencyFormatter.format(d.purchase.paidAmount),
                style: const TextStyle(color: _green))),
            DataCell(Text(
              CurrencyFormatter.format(purchaseBalance(d)),
              style: TextStyle(
                  color:
                      purchaseBalance(d) > 0 ? _red : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600),
            )),
            DataCell(_statusChip(d.purchase.paymentStatus)),
          ]),
      ],
    );
  }

  Widget _shopTable(List<PurchaseDetail> rows) {
    final shops = summarizeByShop(rows);
    return DataTableCard(
      title: 'Shops (${shops.length})',
      emptyMessage: _filter.isEmpty
          ? 'No purchases recorded yet.'
          : 'No purchases match these filters.',
      minWidth: 900,
      columns: const [
        DataColumn(label: Text('Shop / Supplier')),
        DataColumn(label: Text('Bills'), numeric: true),
        DataColumn(label: Text('Total Purchased'), numeric: true),
        DataColumn(label: Text('Paid'), numeric: true),
        DataColumn(label: Text('Balance to Pay'), numeric: true),
        DataColumn(label: Text('Last Bill')),
      ],
      rows: [
        for (final s in shops)
          DataRow(cells: [
            DataCell(
              Tooltip(
                message: 'Show this shop\'s bills',
                child: Text(s.vendor.name,
                    style: const TextStyle(
                        color: Color(0xFF1F5FBF), fontWeight: FontWeight.w600)),
              ),
              onTap: () => setState(() {
                _filter = _filter.copyWith(vendorId: s.vendor.id);
                _byShop = false;
              }),
            ),
            DataCell(Text('${s.bills}')),
            DataCell(Text(CurrencyFormatter.format(s.total),
                style: const TextStyle(fontWeight: FontWeight.w700))),
            DataCell(Text(CurrencyFormatter.format(s.paid),
                style: const TextStyle(color: _green))),
            DataCell(Text(
              CurrencyFormatter.format(s.balance),
              style: TextStyle(
                  color: s.balance > 0 ? _red : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w700),
            )),
            DataCell(Text(DateFormatter.format(s.lastBillDate))),
          ]),
      ],
    );
  }
}
