import 'package:nex_ledger/shared/widgets/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/shared/widgets/project_picker.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/core/utils/financial_year.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/purchase/presentation/widgets/invoice_widgets.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_invoice_providers.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';
import 'package:nex_ledger/features/reports/data/gst_register.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';
import 'package:nex_ledger/shared/widgets/stat_card.dart';

enum _GstView { invoices, rates, suppliers }

/// GST Purchase Register: every GST invoice with CGST / SGST / IGST, plus
/// rate-wise and supplier-wise totals, ready for the accountant (Excel).
class GstRegisterScreen extends ConsumerStatefulWidget {
  const GstRegisterScreen({super.key});

  @override
  ConsumerState<GstRegisterScreen> createState() => _GstRegisterScreenState();
}

class _GstRegisterScreenState extends ConsumerState<GstRegisterScreen> {
  GstRegisterFilter _filter = const GstRegisterFilter();
  _GstView _view = _GstView.invoices;
  bool _exporting = false;

  static const _green = Color(0xFF059669);

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

  Future<void> _export(List<InvoiceDetail> rows, List<Project> projects,
      List<Vendor> vendors) async {
    setState(() => _exporting = true);
    try {
      final text = describeGstFilter(
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
      final path = await ExcelExportService.exportGstRegister(
          rows: rows, filterText: text);
      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('GST register exported: $path'),
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
    final invoicesAsync = ref.watch(invoiceListProvider);
    final projects =
        ref.watch(projectListProvider).asData?.value ?? const <Project>[];
    final vendors =
        ref.watch(vendorListProvider).asData?.value ?? const <Vendor>[];

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final rows = applyGstFilter(all, _filter);
          final totals = gstRegisterTotals(rows);
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
                  child: switch (_view) {
                    _GstView.invoices => _invoiceTable(rows),
                    _GstView.rates => _rateTable(rows),
                    _GstView.suppliers => _supplierTable(rows),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(ThemeData theme, List<InvoiceDetail> rows,
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
              'GST Purchase Register',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'GST on every purchase invoice, ready for your accountant',
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
              child: AppDropdownField<int?>(
                key: ValueKey('gst-vendor-$vendorValue'),
                value: vendorValue,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Supplier', isDense: true),
                items: [
                  const DropdownMenuItem<int?>(
                      value: null, child: Text('All Suppliers')),
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
                    setState(() => _filter = const GstRegisterFilter()),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Clear filters'),
              ),
            SegmentedButton<_GstView>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                    value: _GstView.invoices, label: Text('By Invoice')),
                ButtonSegment(
                    value: _GstView.rates, label: Text('By GST Rate')),
                ButtonSegment(
                    value: _GstView.suppliers, label: Text('By Supplier')),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards(GstRegisterTotals t) {
    final cards = [
      StatCard(
        label: 'Invoices',
        value: '${t.invoices}',
        icon: Icons.receipt_long_outlined,
      ),
      StatCard(
        label: 'Taxable Value',
        value: CurrencyFormatter.format(t.taxable),
        icon: Icons.shopping_bag_outlined,
        iconColor: const Color(0xFF1F5FBF),
      ),
      StatCard(
        label: 'Total GST',
        value: CurrencyFormatter.format(t.totalGst),
        icon: Icons.account_balance_outlined,
        iconColor: const Color(0xFF7C3AED),
        subtitle:
            'CGST ${CurrencyFormatter.format(t.cgst)} · SGST ${CurrencyFormatter.format(t.sgst)} · IGST ${CurrencyFormatter.format(t.igst)}',
      ),
      StatCard(
        label: 'Invoice Total',
        value: CurrencyFormatter.format(t.total),
        icon: Icons.summarize_outlined,
        iconColor: _green,
        valueColor: _green,
        subtitle: t.otherCharges > 0
            ? 'incl. charges ${CurrencyFormatter.format(t.otherCharges)}'
            : null,
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

  String _m(double v) => v == 0 ? '—' : CurrencyFormatter.format(v);

  Widget _invoiceTable(List<InvoiceDetail> rows) {
    return DataTableCard(
      title: 'GST Invoices (${rows.length})',
      emptyMessage: _filter.isEmpty
          ? 'No GST purchase invoices yet. Add one from Purchases > Add Purchase.'
          : 'No invoices match these filters.',
      minWidth: 1300,
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Purchase No')),
        DataColumn(label: Text('Supplier')),
        DataColumn(label: Text('GSTIN')),
        DataColumn(label: Text('Invoice No')),
        DataColumn(label: Text('Taxable'), numeric: true),
        DataColumn(label: Text('CGST'), numeric: true),
        DataColumn(label: Text('SGST'), numeric: true),
        DataColumn(label: Text('IGST'), numeric: true),
        DataColumn(label: Text('Charges'), numeric: true),
        DataColumn(label: Text('Total'), numeric: true),
        DataColumn(label: Text('Status')),
      ],
      rows: [
        for (final d in rows)
          DataRow(cells: [
            DataCell(Text(DateFormatter.format(d.invoice.date))),
            DataCell(
              Text(d.invoice.purchaseNo,
                  style: const TextStyle(
                      color: Color(0xFF1F5FBF), fontWeight: FontWeight.w700)),
              onTap: () => InvoiceDetailDialog.show(context, d.invoice.id),
            ),
            DataCell(ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: Text(d.vendor.name, overflow: TextOverflow.ellipsis),
            )),
            DataCell(Text(d.invoice.supplierGstin ?? '—',
                style: TextStyle(
                    fontSize: 12,
                    color: d.invoice.supplierGstin == null
                        ? const Color(0xFF94A3B8)
                        : null))),
            DataCell(Text(d.invoice.invoiceNo ?? '—')),
            DataCell(Text(CurrencyFormatter.format(d.invoice.taxableValue))),
            DataCell(Text(_m(d.invoice.cgstAmount))),
            DataCell(Text(_m(d.invoice.sgstAmount))),
            DataCell(Text(_m(d.invoice.igstAmount))),
            DataCell(Text(_m(d.invoice.otherCharges))),
            DataCell(Text(CurrencyFormatter.format(d.invoice.grandTotal),
                style: const TextStyle(fontWeight: FontWeight.w700))),
            DataCell(InvoiceStatusChip(d.status)),
          ]),
      ],
    );
  }

  Widget _rateTable(List<InvoiceDetail> rows) {
    final rates = summarizeByRate(rows);
    String pct(double r) => r % 1 == 0 ? '${r.toInt()}%' : '$r%';
    return DataTableCard(
      title: 'GST by Rate',
      emptyMessage: 'No GST purchase invoices to summarise.',
      minWidth: 900,
      columns: const [
        DataColumn(label: Text('GST Rate')),
        DataColumn(label: Text('Items'), numeric: true),
        DataColumn(label: Text('Taxable Value'), numeric: true),
        DataColumn(label: Text('CGST'), numeric: true),
        DataColumn(label: Text('SGST'), numeric: true),
        DataColumn(label: Text('IGST'), numeric: true),
        DataColumn(label: Text('Total GST'), numeric: true),
      ],
      rows: [
        for (final r in rates)
          DataRow(cells: [
            DataCell(Text(pct(r.rate),
                style: const TextStyle(fontWeight: FontWeight.w700))),
            DataCell(Text('${r.items}')),
            DataCell(Text(CurrencyFormatter.format(r.taxable))),
            DataCell(Text(_m(r.cgst))),
            DataCell(Text(_m(r.sgst))),
            DataCell(Text(_m(r.igst))),
            DataCell(Text(CurrencyFormatter.format(r.totalGst),
                style: const TextStyle(fontWeight: FontWeight.w700))),
          ]),
      ],
    );
  }

  Widget _supplierTable(List<InvoiceDetail> rows) {
    final suppliers = summarizeBySupplier(rows);
    return DataTableCard(
      title: 'Suppliers (${suppliers.length})',
      emptyMessage: 'No GST purchase invoices to summarise.',
      minWidth: 900,
      columns: const [
        DataColumn(label: Text('Supplier')),
        DataColumn(label: Text('GSTIN')),
        DataColumn(label: Text('Invoices'), numeric: true),
        DataColumn(label: Text('Taxable Value'), numeric: true),
        DataColumn(label: Text('GST'), numeric: true),
        DataColumn(label: Text('Invoice Total'), numeric: true),
      ],
      rows: [
        for (final s in suppliers)
          DataRow(cells: [
            DataCell(
              Tooltip(
                message: "Show this supplier's invoices",
                child: Text(s.name,
                    style: const TextStyle(
                        color: Color(0xFF1F5FBF), fontWeight: FontWeight.w600)),
              ),
              onTap: () {
                final id =
                    rows.firstWhere((d) => d.vendor.name == s.name).vendor.id;
                setState(() {
                  _filter = _filter.copyWith(vendorId: id);
                  _view = _GstView.invoices;
                });
              },
            ),
            DataCell(
                Text(s.gstin ?? '—', style: const TextStyle(fontSize: 12))),
            DataCell(Text('${s.invoices}')),
            DataCell(Text(CurrencyFormatter.format(s.taxable))),
            DataCell(Text(CurrencyFormatter.format(s.gst))),
            DataCell(Text(CurrencyFormatter.format(s.total),
                style: const TextStyle(fontWeight: FontWeight.w700))),
          ]),
      ],
    );
  }
}
