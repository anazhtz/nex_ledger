import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/constants/material_constants.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/features/materials/models/project_material_entry.dart';
import 'package:nex_ledger/features/materials/providers/material_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';
import 'package:nex_ledger/shared/widgets/stat_card.dart';

class MaterialRegisterScreen extends ConsumerStatefulWidget {
  final int? initialProjectId;
  const MaterialRegisterScreen({super.key, this.initialProjectId});

  @override
  ConsumerState<MaterialRegisterScreen> createState() =>
      _MaterialRegisterScreenState();
}

class _MaterialRegisterScreenState
    extends ConsumerState<MaterialRegisterScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialProjectId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(materialSelectedProjectIdProvider.notifier).state =
            widget.initialProjectId;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _setDateRange(DateTimeRange? range) {
    ref.read(materialDateRangeProvider.notifier).state = range;
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: ref.read(materialDateRangeProvider),
    );
    if (picked != null) {
      _setDateRange(picked);
    }
  }

  Future<void> _exportToExcel(ProjectMaterialSummary summary) async {
    setState(() => _exporting = true);
    try {
      final dateRange = ref.read(materialDateRangeProvider);
      final filePath =
          await ExcelExportService.exportMaterialQuantityStatement(
        summary: summary,
        dateRange: dateRange,
      );
      if (!mounted) return;
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Material Register exported: $filePath'),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _showDeliveryHistoryDialog(
      BuildContext context, ProjectMaterialItem item) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            width: 900.w,
            constraints: BoxConstraints(maxHeight: 650.h),
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.local_shipping_rounded,
                          color: const Color(0xFF4F46E5), size: 22.sp),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.itemDescription,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Category: ${item.materialCategory} • Total Inward: ${item.totalQuantity % 1 == 0 ? item.totalQuantity.toInt() : item.totalQuantity} ${item.unit} • Spend: ${CurrencyFormatter.format(item.totalAmount)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(),
                SizedBox(height: 12.h),

                // Deliveries Inward Table
                Expanded(
                  child: SingleChildScrollView(
                    child: DataTableCard(
                      title:
                          'Inward Consignment Deliveries (${item.deliveryHistory.length})',
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Challan / Bill No')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Unit Rate (₹)')),
                        DataColumn(label: Text('Total Amount (₹)')),
                        DataColumn(label: Text('Supplier / Vendor')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: item.deliveryHistory.map((del) {
                        return DataRow(cells: [
                          DataCell(Text(
                            DateFormatter.format(del.transaction.date),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(Text(
                            del.transaction.referenceNo ?? '—',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12.sp,
                              color: const Color(0xFF475569),
                            ),
                          )),
                          DataCell(Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '${del.purchase.quantity % 1 == 0 ? del.purchase.quantity.toInt() : del.purchase.quantity} ${del.purchase.unit ?? 'Nos'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          )),
                          DataCell(Text(
                            CurrencyFormatter.format(del.purchase.unitRate),
                          )),
                          DataCell(Text(
                            CurrencyFormatter.format(del.transaction.amount),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(GestureDetector(
                            onTap: () {
                              Navigator.of(dialogCtx).pop();
                              context.push('/vendors/${del.vendor.id}');
                            },
                            child: Text(
                              del.vendor.name,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                          DataCell(Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: del.purchase.paymentStatus ==
                                      PaymentStatus.paid
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              del.purchase.paymentStatus.displayName,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: del.purchase.paymentStatus ==
                                        PaymentStatus.paid
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB45309),
                              ),
                            ),
                          )),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              tooltip: 'Edit Purchase Bill',
                              onPressed: () {
                                Navigator.of(dialogCtx).pop();
                                context.push('/purchases/${del.purchase.id}/edit');
                              },
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectListProvider);
    final selectedProjectId = ref.watch(materialSelectedProjectIdProvider);
    final selectedCategory = ref.watch(materialSelectedCategoryProvider);
    final dateRange = ref.watch(materialDateRangeProvider);
    final summaryAsync = ref.watch(projectMaterialSummaryProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header & Top Actions ──────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                final titleColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Material Register',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Live material quantity tracking, delivery inward logs & average consumption rates per project',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );

                final actionButtons = Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Date Filter Menu
                    PopupMenuButton<String>(
                      tooltip: 'Filter Period',
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 16.sp, color: const Color(0xFF475569)),
                            SizedBox(width: 8.w),
                            Text(
                              dateRange != null
                                  ? '${DateFormatter.format(dateRange.start)} - ${DateFormatter.format(dateRange.end)}'
                                  : 'All Time Period',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.arrow_drop_down,
                                size: 18.sp, color: const Color(0xFF64748B)),
                          ],
                        ),
                      ),
                      onSelected: (val) {
                        final now = DateTime.now();
                        if (val == 'all') {
                          _setDateRange(null);
                        } else if (val == 'this_month') {
                          _setDateRange(DateTimeRange(
                            start: DateTime(now.year, now.month, 1),
                            end: DateTime(now.year, now.month + 1, 0),
                          ));
                        } else if (val == 'last_month') {
                          _setDateRange(DateTimeRange(
                            start: DateTime(now.year, now.month - 1, 1),
                            end: DateTime(now.year, now.month, 0),
                          ));
                        } else if (val == 'this_year') {
                          _setDateRange(DateTimeRange(
                            start: DateTime(now.year, 1, 1),
                            end: DateTime(now.year, 12, 31),
                          ));
                        } else if (val == 'custom') {
                          _pickCustomDateRange();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'all',
                            child: Text('All Time (All Deliveries)')),
                        const PopupMenuItem(
                            value: 'this_month', child: Text('This Month')),
                        const PopupMenuItem(
                            value: 'last_month', child: Text('Last Month')),
                        const PopupMenuItem(
                            value: 'this_year',
                            child: Text('This Financial Year')),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                            value: 'custom',
                            child: Text('Custom Date Range...')),
                      ],
                    ),

                    // Export Excel Button
                    summaryAsync.maybeWhen(
                      data: (summary) => OutlinedButton.icon(
                        onPressed: _exporting || summary.items.isEmpty
                            ? null
                            : () => _exportToExcel(summary),
                        icon: _exporting
                            ? SizedBox(
                                width: 14.sp,
                                height: 14.sp,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.table_view_rounded, size: 16),
                        label: Text(_exporting ? 'Exporting...' : 'Export Excel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF059669),
                          side: const BorderSide(color: Color(0xFF6EE7B7)),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),

                    // Add Purchase Button
                    FilledButton.icon(
                      onPressed: () => context.push('/purchases/new'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('+ Add Material Purchase'),
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleColumn,
                      SizedBox(height: 12.h),
                      actionButtons,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: titleColumn),
                    SizedBox(width: 16.w),
                    actionButtons,
                  ],
                );
              },
            ),
            SizedBox(height: 20.h),

            // ─── Filter Bar: Project Dropdown, Category Dropdown & Search ────────
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // 1. Project Selector
                    projectsAsync.maybeWhen(
                      data: (projects) => SizedBox(
                        width: 320.w,
                        child: DropdownButtonFormField<int?>(
                          value: selectedProjectId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Select Project',
                            prefixIcon:
                                Icon(Icons.business_center_outlined, size: 20),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Projects (Consolidated View)',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            ...projects.map((p) => DropdownMenuItem<int?>(
                                  value: p.id,
                                  child: Text(
                                    '${p.code} — ${p.name}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                          ],
                          onChanged: (pId) {
                            ref
                                .read(materialSelectedProjectIdProvider.notifier)
                                .state = pId;
                          },
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),

                    // 2. Category Filter
                    SizedBox(
                      width: 240.w,
                      child: DropdownButtonFormField<String?>(
                        value: selectedCategory,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Filter Category',
                          prefixIcon: Icon(Icons.category_outlined, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Categories',
                                overflow: TextOverflow.ellipsis),
                          ),
                          ...kStandardMaterialCategories.map((cat) =>
                              DropdownMenuItem<String?>(
                                value: cat.name,
                                child: Text(cat.name,
                                    overflow: TextOverflow.ellipsis),
                              )),
                        ],
                        onChanged: (cat) {
                          ref
                              .read(materialSelectedCategoryProvider.notifier)
                              .state = cat;
                        },
                      ),
                    ),

                    // 3. Search Bar
                    SizedBox(
                      width: 260.w,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search item, supplier, ref...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    ref
                                        .read(
                                            materialSearchQueryProvider.notifier)
                                        .state = '';
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onChanged: (val) {
                          ref
                              .read(materialSearchQueryProvider.notifier)
                              .state = val;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // ─── Content: KPIs & Material Data Table ─────────────────────────────
            summaryAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Error loading material register: $e'),
                ),
              ),
              data: (summary) {
                if (summary.items.isEmpty) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(48.r),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 52.sp, color: const Color(0xFF94A3B8)),
                            SizedBox(height: 16.h),
                            Text(
                              'No Material Records Found',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'No purchase bills match the selected project or filter criteria.\nRecord material purchases via "+ Add Material Purchase" to see live quantities.',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF64748B)),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 18.h),
                            FilledButton.icon(
                              onPressed: () => context.push('/purchases/new'),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add First Purchase Bill'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Stat Cards ──────────────────────────────────────────
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 800;
                        final List<Widget> cards = [
                          StatCard(
                            label: 'Total Material Cost',
                            value: CurrencyFormatter.format(
                                summary.totalMaterialSpend),
                            icon: Icons.payments_outlined,
                            iconColor: const Color(0xFF2563EB),
                          ),
                          StatCard(
                            label: 'Delivery Consignments',
                            value: '${summary.totalDeliveriesCount} Inwards',
                            icon: Icons.local_shipping_outlined,
                            iconColor: const Color(0xFF059669),
                          ),
                          StatCard(
                            label: 'Material Categories',
                            value: '${summary.totalCategoriesCount} Categories',
                            icon: Icons.category_outlined,
                            iconColor: const Color(0xFFD97706),
                          ),
                          StatCard(
                            label: 'Distinct Items',
                            value: '${summary.totalDistinctItemsCount} Materials',
                            icon: Icons.inventory_2_outlined,
                            iconColor: const Color(0xFF7C3AED),
                          ),
                        ];

                        if (isSmall) {
                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12.h,
                            crossAxisSpacing: 12.w,
                            childAspectRatio: 2.2,
                            children: cards,
                          );
                        }

                        return Row(
                          children: cards
                              .map((c) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: c != cards.last ? 12.w : 0),
                                      child: c,
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),

                    // ─── Material Quantities Table ───────────────────────────
                    DataTableCard(
                      title:
                          '${summary.projectName} — Material Consumption & Stock Inwards',
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Material Category')),
                        DataColumn(label: Text('Item Description')),
                        DataColumn(label: Text('Total Quantity Inward')),
                        DataColumn(label: Text('Avg Unit Rate (₹)')),
                        DataColumn(label: Text('Total Spend (₹)')),
                        DataColumn(label: Text('Inwards')),
                        DataColumn(label: Text('Latest Supply')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: summary.items.asMap().entries.map((entry) {
                        final idx = entry.key + 1;
                        final item = entry.value;

                        return DataRow(cells: [
                          DataCell(Text(
                            '$idx',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          )),
                          DataCell(Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              item.materialCategory,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4F46E5),
                              ),
                            ),
                          )),
                          DataCell(Text(
                            item.itemDescription,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.totalQuantity % 1 == 0
                                    ? item.totalQuantity.toInt().toString()
                                    : item.totalQuantity.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                      color: const Color(0xFFCBD5E1)),
                                ),
                                child: Text(
                                  item.unit,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          )),
                          DataCell(Text(
                            CurrencyFormatter.format(item.avgUnitRate),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF334155),
                            ),
                          )),
                          DataCell(Text(
                            CurrencyFormatter.format(item.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          )),
                          DataCell(Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              '${item.inwardCount} bills',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          )),
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.lastDeliveryDate != null
                                    ? DateFormatter.format(item.lastDeliveryDate!)
                                    : '—',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              if (item.primaryVendor != null)
                                Text(
                                  item.primaryVendor!,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          )),
                          DataCell(
                            FilledButton.tonalIcon(
                              onPressed: () =>
                                  _showDeliveryHistoryDialog(context, item),
                              icon: const Icon(Icons.history_rounded, size: 14),
                              label: const Text('Inward History'),
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 6.h),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
