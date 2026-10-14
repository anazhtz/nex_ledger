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
import 'package:nex_ledger/features/purchase/providers/purchase_invoice_providers.dart';
import 'package:nex_ledger/features/reports/data/input_gst.dart';
import 'package:nex_ledger/features/reports/providers/report_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';
import 'package:nex_ledger/shared/widgets/stat_card.dart';

enum _InputView { projects, sources, entries }

/// Input GST: the GST you paid on purchases, subcontractor bills, machinery
/// rent and expenses, added up for each project.
class InputGstScreen extends ConsumerStatefulWidget {
  const InputGstScreen({super.key});

  @override
  ConsumerState<InputGstScreen> createState() => _InputGstScreenState();
}

class _InputGstScreenState extends ConsumerState<InputGstScreen> {
  InputGstFilter _filter = const InputGstFilter();
  _InputView _view = _InputView.projects;
  bool _exporting = false;

  static const _green = Color(0xFF059669);
  static const _purple = Color(0xFF7C3AED);

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

  Future<void> _export(List<InputGstEntry> rows, List<Project> projects) async {
    setState(() => _exporting = true);
    try {
      final text = describeInputGstFilter(
        _filter,
        projectName: projects
            .where((p) => p.id == _filter.projectId)
            .map((p) => '${p.code} — ${p.name}')
            .firstOrNull,
        formatDate: DateFormatter.format,
      );
      final pnls = ref.read(consolidatedPnlProvider).asData?.value ?? const [];
      final path = await ExcelExportService.exportInputGst(
        entries: rows,
        filterText: text,
        projectCosts: {
          for (final p in pnls)
            p.project.id: p.expenses + p.purchases + p.labourCosts
        },
      );
      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Input GST report exported: $path'),
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
    final entriesAsync = ref.watch(inputGstEntriesProvider);
    final projects =
        ref.watch(projectListProvider).asData?.value ?? const <Project>[];

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final rows = applyInputGstFilter(all, _filter);
          final totals = inputGstTotals(rows);
          return Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(theme, rows, projects),
                SizedBox(height: 14.h),
                _filterBar(projects),
                SizedBox(height: 14.h),
                _summaryCards(totals),
                SizedBox(height: 14.h),
                Expanded(
                  child: switch (_view) {
                    _InputView.projects => _projectTable(rows),
                    _InputView.sources => _sourceTable(rows),
                    _InputView.entries => _entryTable(rows),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(
      ThemeData theme, List<InputGstEntry> rows, List<Project> projects) {
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
              'Input GST Report',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'GST you paid on purchases, subcontractor bills, machinery rent and expenses, for each project',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed:
              _exporting || rows.isEmpty ? null : () => _export(rows, projects),
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

  Widget _filterBar(List<Project> projects) {
    final projectValue = projects.any((p) => p.id == _filter.projectId)
        ? _filter.projectId
        : null;
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
              width: 200,
              child: DropdownButtonFormField<InputGstSource?>(
                key: ValueKey('igst-source-${_filter.source}'),
                value: _filter.source,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Source', isDense: true),
                items: [
                  const DropdownMenuItem<InputGstSource?>(
                      value: null, child: Text('All Sources')),
                  for (final s in InputGstSource.values)
                    DropdownMenuItem<InputGstSource?>(
                        value: s, child: Text(s.label)),
                ],
                onChanged: (v) => setState(() => _filter = v == null
                    ? _filter.copyWith(clearSource: true)
                    : _filter.copyWith(source: v)),
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
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.calendar_month_rounded,
                      size: 18, color: Color(0xFF1F5FBF)),
                  const SizedBox(width: 8),
                  Text(_rangeLabel(),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ]),
              ),
            ),
            if (!_filter.isEmpty)
              TextButton.icon(
                onPressed: () =>
                    setState(() => _filter = const InputGstFilter()),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Clear filters'),
              ),
            SegmentedButton<_InputView>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                    value: _InputView.projects, label: Text('By Project')),
                ButtonSegment(
                    value: _InputView.sources, label: Text('By Source')),
                ButtonSegment(
                    value: _InputView.entries, label: Text('All Entries')),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards(InputGstTotals t) {
    final cards = [
      StatCard(
        label: 'Total Input GST',
        value: CurrencyFormatter.format(t.gst),
        icon: Icons.account_balance_rounded,
        iconColor: _purple,
        valueColor: _purple,
        subtitle: 'GST paid, all sources',
      ),
      StatCard(
        label: 'CGST + SGST',
        value: CurrencyFormatter.format(t.cgst + t.sgst),
        icon: Icons.home_work_outlined,
        iconColor: const Color(0xFF1F5FBF),
        subtitle:
            'CGST ${CurrencyFormatter.format(t.cgst)} · SGST ${CurrencyFormatter.format(t.sgst)}',
      ),
      StatCard(
        label: 'IGST',
        value: CurrencyFormatter.format(t.igst),
        icon: Icons.public_rounded,
        iconColor: const Color(0xFFEA580C),
        subtitle: 'Inter-state purchases',
      ),
      StatCard(
        label: 'Taxable Value',
        value: CurrencyFormatter.format(t.taxable),
        icon: Icons.receipt_long_outlined,
        subtitle: '${t.entries} bill${t.entries == 1 ? '' : 's'} with GST',
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

  static const _emptyMessage =
      'No GST bills yet. Turn on GST when you enter a purchase, subcontractor bill or expense.';

  /// Each project's total costs (GST included), as in the P&L.
  Map<int, double> _projectCosts() {
    final pnls = ref.watch(consolidatedPnlProvider).asData?.value ?? const [];
    return {
      for (final p in pnls)
        p.project.id: p.expenses + p.purchases + p.labourCosts
    };
  }

  Widget _projectTable(List<InputGstEntry> rows) {
    final projects = summarizeByProject(rows);
    final costs = _projectCosts();
    return DataTableCard(
      title: 'Input GST by Project',
      emptyMessage:
          _filter.isEmpty ? _emptyMessage : 'No GST bills match these filters.',
      minWidth: 1700,
      columns: [
        const DataColumn(label: Text('Project')),
        const DataColumn(
            label: Text('Project Costs (incl. GST)'), numeric: true),
        const DataColumn(label: Text('GST inside Costs'), numeric: true),
        const DataColumn(label: Text('Costs without GST'), numeric: true),
        const DataColumn(label: Text('Taxable Value'), numeric: true),
        const DataColumn(label: Text('CGST'), numeric: true),
        const DataColumn(label: Text('SGST'), numeric: true),
        const DataColumn(label: Text('IGST'), numeric: true),
        const DataColumn(label: Text('Total Input GST'), numeric: true),
        for (final s in InputGstSource.values)
          DataColumn(label: Text(s.label), numeric: true),
      ],
      rows: [
        for (final p in projects)
          DataRow(cells: [
            DataCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.projectCode,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(p.projectName,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              onTap: () => setState(() {
                _filter = _filter.copyWith(projectId: p.projectId);
                _view = _InputView.entries;
              }),
            ),
            ...() {
              final view = ProjectCostView(
                  totalCosts: costs[p.projectId] ?? 0.0,
                  gstInCosts: p.gstInCosts);
              return [
                DataCell(Text(CurrencyFormatter.format(view.totalCosts),
                    style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(_m(view.gstInCosts),
                    style: const TextStyle(color: _purple))),
                DataCell(Text(CurrencyFormatter.format(view.costsWithoutGst))),
              ];
            }(),
            DataCell(Text(CurrencyFormatter.format(p.totals.taxable))),
            DataCell(Text(_m(p.totals.cgst))),
            DataCell(Text(_m(p.totals.sgst))),
            DataCell(Text(_m(p.totals.igst))),
            DataCell(Text(CurrencyFormatter.format(p.totals.gst),
                style: const TextStyle(
                    fontWeight: FontWeight.w800, color: _purple))),
            for (final s in InputGstSource.values)
              DataCell(Text(_m(p.gstBySource[s] ?? 0))),
          ]),
      ],
    );
  }

  Widget _sourceTable(List<InputGstEntry> rows) {
    final sources = summarizeBySource(rows);
    return DataTableCard(
      title: 'Input GST by Source',
      emptyMessage:
          _filter.isEmpty ? _emptyMessage : 'No GST bills match these filters.',
      minWidth: 900,
      columns: const [
        DataColumn(label: Text('Source')),
        DataColumn(label: Text('Bills'), numeric: true),
        DataColumn(label: Text('Taxable Value'), numeric: true),
        DataColumn(label: Text('CGST'), numeric: true),
        DataColumn(label: Text('SGST'), numeric: true),
        DataColumn(label: Text('IGST'), numeric: true),
        DataColumn(label: Text('Total Input GST'), numeric: true),
      ],
      rows: [
        for (final s in sources)
          DataRow(
            cells: [
              DataCell(
                Text(s.source.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Color(0xFF1F5FBF))),
                onTap: () => setState(() {
                  _filter = _filter.copyWith(source: s.source);
                  _view = _InputView.entries;
                }),
              ),
              DataCell(Text('${s.totals.entries}')),
              DataCell(Text(CurrencyFormatter.format(s.totals.taxable))),
              DataCell(Text(_m(s.totals.cgst))),
              DataCell(Text(_m(s.totals.sgst))),
              DataCell(Text(_m(s.totals.igst))),
              DataCell(Text(CurrencyFormatter.format(s.totals.gst),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: _purple))),
            ],
          ),
      ],
    );
  }

  Widget _entryTable(List<InputGstEntry> rows) {
    return DataTableCard(
      title: 'GST Bills (${rows.length})',
      emptyMessage:
          _filter.isEmpty ? _emptyMessage : 'No GST bills match these filters.',
      minWidth: 1300,
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Project')),
        DataColumn(label: Text('Source')),
        DataColumn(label: Text('Party')),
        DataColumn(label: Text('GSTIN')),
        DataColumn(label: Text('Document')),
        DataColumn(label: Text('Taxable'), numeric: true),
        DataColumn(label: Text('CGST'), numeric: true),
        DataColumn(label: Text('SGST'), numeric: true),
        DataColumn(label: Text('IGST'), numeric: true),
        DataColumn(label: Text('Total GST'), numeric: true),
      ],
      rows: [
        for (final e in rows)
          DataRow(cells: [
            DataCell(Text(DateFormatter.format(e.date))),
            DataCell(Text(e.projectCode,
                style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(e.source.label)),
            DataCell(ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: Text(e.party, overflow: TextOverflow.ellipsis),
            )),
            DataCell(
                Text(e.gstin ?? '—', style: const TextStyle(fontSize: 12))),
            DataCell(ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 190),
              child: Text(e.docNo, overflow: TextOverflow.ellipsis),
            )),
            DataCell(Text(CurrencyFormatter.format(e.taxable))),
            DataCell(Text(_m(e.cgst))),
            DataCell(Text(_m(e.sgst))),
            DataCell(Text(_m(e.igst))),
            DataCell(Text(CurrencyFormatter.format(e.gst),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: _purple))),
          ]),
      ],
    );
  }
}
