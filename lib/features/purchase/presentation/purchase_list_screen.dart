import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/reports/providers/report_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

final purchaseViewTabProvider = StateProvider<int>((ref) => 0); // 0 = Invoices, 1 = Material Breakdown

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(filteredPurchaseListProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final filterProject = ref.watch(purchaseProjectFilterProvider);
    final apAsync = ref.watch(accountsPayableProvider(filterProject));
    final stockAssetAsync = ref.watch(totalUnallocatedStockAssetProvider);
    final selectedTab = ref.watch(purchaseViewTabProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchases & Materials',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Vendor-linked purchase bills, material consumption & advance stock assets',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => context.go('/purchases/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Purchase'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Summary Cards (Accounts Payable & Advance Stock Asset) ───────
            Row(
              children: [
                // Accounts Payable summary card
                Expanded(
                  child: apAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (ap) => ap > 0
                        ? _AccountsPayableCard(amount: ap, theme: theme)
                        : const SizedBox.shrink(),
                  ),
                ),
                stockAssetAsync.maybeWhen(
                  data: (stock) => stock > 0 ? const SizedBox(width: 12) : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
                // Advance Stock Asset summary card
                Expanded(
                  child: stockAssetAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (stock) => stock > 0
                        ? _AdvanceStockAssetCard(amount: stock, theme: theme)
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Filter & View Mode Tabs ─────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (projects) => Wrap(
                    spacing: 16.w,
                    runSpacing: 10.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 280.w,
                        child: DropdownButtonFormField<int?>(
                          value: filterProject,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Project',
                            prefixIcon: Icon(Icons.folder_outlined, size: 20),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null,
                                child: Text('All Projects & Stock',
                                    overflow: TextOverflow.ellipsis)),
                            ...projects.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.code} — ${p.name}',
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: (v) => ref
                              .read(purchaseProjectFilterProvider.notifier)
                              .state = v,
                        ),
                      ),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(
                            value: 0,
                            label: Text('Purchase Invoices'),
                            icon: Icon(Icons.receipt_long_rounded, size: 16),
                          ),
                          ButtonSegment(
                            value: 1,
                            label: Text('Material Breakdown'),
                            icon: Icon(Icons.view_in_ar_rounded, size: 16),
                          ),
                        ],
                        selected: {selectedTab},
                        onSelectionChanged: (set) {
                          ref.read(purchaseViewTabProvider.notifier).state =
                              set.first;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (selectedTab == 0)
              Expanded(
                child: purchasesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (purchases) => DataTableCard(
                    emptyMessage: 'No purchases found.',
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Project')),
                      DataColumn(label: Text('Vendor')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Classification')),
                      DataColumn(label: Text('Amount'), numeric: true),
                      DataColumn(label: Text('Payment')),
                      DataColumn(label: Text('Mode')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: purchases.map((pd) {
                      final isPending =
                          pd.purchase.paymentStatus == PaymentStatus.pending ||
                              pd.purchase.paymentStatus == PaymentStatus.partial;
                      final isStock = pd.purchase.isAdvanceStock;
                      final unallocated =
                          pd.transaction.amount - pd.purchase.allocatedAmount;
                      final canAllocate = isStock && unallocated > 0.01;

                      return DataRow(cells: [
                        DataCell(Text(
                            DateFormatter.format(pd.transaction.date))),
                        DataCell(Text(pd.project.name,
                            overflow: TextOverflow.ellipsis)),
                        DataCell(GestureDetector(
                          onTap: () => context.push(
                              '/vendors/${pd.vendor.id}'),
                          child: Text(
                            pd.vendor.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (pd.purchase.materialCategory != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        pd.purchase.materialCategory!,
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF4F46E5)),
                                      ),
                                    ),
                                  if (pd.purchase.hsnCode != null &&
                                      pd.purchase.hsnCode!.trim().isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: Text(
                                        'HSN: ${pd.purchase.hsnCode}',
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF475569)),
                                      ),
                                    ),
                                  Text(
                                    pd.purchase.itemDescription,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (pd.purchase.quantity > 1 ||
                                      pd.purchase.unitRate > 0)
                                    Text(
                                      'Qty: ${pd.purchase.quantity % 1 == 0 ? pd.purchase.quantity.toInt() : pd.purchase.quantity} ${pd.purchase.unit ?? 'Nos'} @ ${CurrencyFormatter.format(pd.purchase.unitRate)}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  if (pd.purchase.taxApplicable &&
                                      pd.purchase.gstAmount > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text(
                                        '• GST ${pd.purchase.gstRate % 1 == 0 ? pd.purchase.gstRate.toInt() : pd.purchase.gstRate}% (+${CurrencyFormatter.format(pd.purchase.gstAmount)})',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF16A34A),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          pd.purchase.isAdvanceStock
                              ? _StockClassificationBadge(
                                  total: pd.transaction.amount,
                                  allocated: pd.purchase.allocatedAmount,
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Direct Cost',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF475569),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                CurrencyFormatter.format(pd.transaction.amount),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              if (pd.purchase.taxApplicable && pd.purchase.gstAmount > 0)
                                Text(
                                  'Base: ${CurrencyFormatter.format(pd.transaction.amount - pd.purchase.gstAmount)}',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        DataCell(_PaymentStatusChip(
                            status: pd.purchase.paymentStatus)),
                        DataCell(Text(
                          pd.transaction.paymentMode?.displayName ?? '—',
                        )),
                        DataCell(
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 17),
                                  tooltip: 'Edit Bill',
                                  onPressed: () => context
                                      .go('/purchases/${pd.purchase.id}/edit'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      size: 17),
                                  tooltip: 'Delete Bill',
                                  color: theme.colorScheme.error,
                                  onPressed: () =>
                                      _deletePurchase(context, ref, pd),
                                ),
                                if (isPending)
                                  TextButton.icon(
                                    onPressed: () => _showMarkPaidDialog(
                                      context,
                                      ref,
                                      pd,
                                    ),
                                    icon: const Icon(Icons.check_circle_outline,
                                        size: 15),
                                    label: const Text('Mark Paid'),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.primary,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                if (canAllocate) ...[
                                  FilledButton.tonalIcon(
                                    onPressed: () => _showAllocateStockDialog(
                                      context,
                                      ref,
                                      pd,
                                    ),
                                    icon: const Icon(Icons.outbox_rounded,
                                        size: 15),
                                    label: const Text('Allocate'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFFFEF3C7),
                                      foregroundColor: const Color(0xFFB45309),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              )
            else
              Expanded(
                child: _buildMaterialBreakdownView(context, ref, filterProject, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialBreakdownView(
    BuildContext context,
    WidgetRef ref,
    int? filterProject,
    ThemeData theme,
  ) {
    if (filterProject == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_alt_outlined, size: 48.sp, color: const Color(0xFF94A3B8)),
                SizedBox(height: 12.h),
                Text(
                  'Select a Project to View Material Consumption',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Use the project dropdown filter above to see total quantities of Cement, Steel, Metal, Sand, etc. consumed by that specific project.',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final consumptionAsync = ref.watch(projectMaterialConsumptionProvider(filterProject));

    return consumptionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading materials: $e')),
      data: (materials) {
        if (materials.isEmpty) {
          return const Center(
            child: Text('No material purchases recorded for this project yet.'),
          );
        }

        final totalSpend = materials.fold<double>(0.0, (sum, m) => sum + m.totalAmount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary KPI
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_rounded, color: const Color(0xFF4F46E5), size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Total Material Consumption: ${CurrencyFormatter.format(totalSpend)} across ${materials.length} material categories',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF312E81),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: DataTableCard(
                title: 'Project Material Consumption Breakdown',
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Material Category')),
                  DataColumn(label: Text('Total Quantity')),
                  DataColumn(label: Text('Unit')),
                  DataColumn(label: Text('Avg Rate (₹)')),
                  DataColumn(label: Text('Total Cost (₹)')),
                  DataColumn(label: Text('Bills')),
                  DataColumn(label: Text('Latest Purchase')),
                ],
                rows: materials.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final m = entry.value;

                  final qtyStr = m.totalQuantity % 1 == 0
                      ? m.totalQuantity.toInt().toString()
                      : m.totalQuantity.toStringAsFixed(2);

                  return DataRow(
                    cells: [
                      DataCell(Text(idx.toString(), style: const TextStyle(color: Color(0xFF94A3B8)))),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.category_outlined, size: 16.sp, color: const Color(0xFF4F46E5)),
                          SizedBox(width: 6.w),
                          Text(m.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      )),
                      DataCell(Text(qtyStr, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(m.unit)),
                      DataCell(Text(CurrencyFormatter.format(m.avgUnitRate))),
                      DataCell(Text(
                        CurrencyFormatter.format(m.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      )),
                      DataCell(Text('${m.billCount} bills')),
                      DataCell(Text(
                        m.lastPurchaseDate != null
                            ? '${DateFormatter.format(m.lastPurchaseDate!)}${m.lastVendorName != null ? ' (${m.lastVendorName})' : ''}'
                            : '—',
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMarkPaidDialog(
    BuildContext context,
    WidgetRef ref,
    PurchaseDetail pd,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _MarkPaidDialog(pd: pd),
    );
  }

  void _showAllocateStockDialog(
    BuildContext context,
    WidgetRef ref,
    PurchaseDetail pd,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _AllocateStockDialog(pd: pd),
    );
  }

  Future<void> _deletePurchase(
    BuildContext context,
    WidgetRef ref,
    PurchaseDetail pd,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Delete Purchase Bill?'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete purchase "${pd.purchase.itemDescription}" from vendor "${pd.vendor.name}" (${CurrencyFormatter.format(pd.transaction.amount)})?\n\n'
          'This will permanently remove the purchase bill and linked financial transaction.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Delete Bill'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(purchaseRepositoryProvider)
            .deletePurchase(pd.purchase.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Purchase bill deleted successfully.'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting purchase: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stock classification badge
// ─────────────────────────────────────────────────────────────────────────────

class _StockClassificationBadge extends StatelessWidget {
  final double total;
  final double allocated;
  const _StockClassificationBadge(
      {required this.total, required this.allocated});

  @override
  Widget build(BuildContext context) {
    final remaining = total - allocated;
    final isFullyAllocated = remaining <= 0.01;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFullyAllocated
            ? const Color(0xFFF1F5F9)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isFullyAllocated
              ? const Color(0xFFCBD5E1)
              : const Color(0xFFFCD34D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFullyAllocated
                    ? Icons.inventory_outlined
                    : Icons.inventory_2_rounded,
                size: 11,
                color: isFullyAllocated
                    ? const Color(0xFF64748B)
                    : const Color(0xFFB45309),
              ),
              const SizedBox(width: 4),
              Text(
                isFullyAllocated ? 'Stock (Exhausted)' : 'Stock Asset',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isFullyAllocated
                      ? const Color(0xFF64748B)
                      : const Color(0xFFB45309),
                ),
              ),
            ],
          ),
          if (!isFullyAllocated)
            Text(
              'Avail: ${CurrencyFormatter.format(remaining)}',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Advance Stock Asset summary card
// ─────────────────────────────────────────────────────────────────────────────

class _AdvanceStockAssetCard extends StatelessWidget {
  final double amount;
  final ThemeData theme;
  const _AdvanceStockAssetCard({required this.amount, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFEF3C7).withAlpha(120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFF59E0B),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_rounded,
                color: Color(0xFFD97706), size: 28),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unallocated Advance Stock (Company Asset)',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bulk materials held in stock — allocate to projects when used',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              CurrencyFormatter.format(amount),
              style: const TextStyle(
                color: Color(0xFFB45309),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Accounts Payable summary card
// ─────────────────────────────────────────────────────────────────────────────

class _AccountsPayableCard extends StatelessWidget {
  final double amount;
  final ThemeData theme;
  const _AccountsPayableCard({required this.amount, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.errorContainer.withAlpha(60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.error.withAlpha(100),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: theme.colorScheme.error, size: 28),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accounts Payable (Vendor Dues)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Unpaid vendor bills — expense recognized, cash not yet moved',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              CurrencyFormatter.format(amount),
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Allocate Stock to Project Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _AllocateStockDialog extends ConsumerStatefulWidget {
  final PurchaseDetail pd;
  const _AllocateStockDialog({required this.pd});

  @override
  ConsumerState<_AllocateStockDialog> createState() =>
      _AllocateStockDialogState();
}

class _AllocateStockDialogState extends ConsumerState<_AllocateStockDialog> {
  final _amountCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int? _targetProjectId;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final remaining = widget.pd.transaction.amount -
        widget.pd.purchase.allocatedAmount;
    _amountCtrl.text = remaining > 0 ? remaining.toStringAsFixed(0) : '';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _narrationCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);
    final totalStock = widget.pd.transaction.amount;
    final allocated = widget.pd.purchase.allocatedAmount;
    final unallocated = totalStock - allocated;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.outbox_rounded, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          const Text('Allocate Stock to Project'),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock info card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pd.purchase.itemDescription,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Vendor: ${widget.pd.vendor.name}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF78350F)),
                        ),
                        const Spacer(),
                        Text(
                          'Available: ${CurrencyFormatter.format(unallocated)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Target Project selector
              projectsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (projects) => DropdownButtonFormField<int>(
                  value: _targetProjectId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Target Project to Charge *',
                    isDense: true,
                  ),
                  items: projects
                      .map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.code} — ${p.name}',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _targetProjectId = v),
                  validator: (v) => v == null ? 'Select target project' : null,
                ),
              ),
              const SizedBox(height: 14),

              // Allocation Date + Amount
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined,
                          size: 20),
                      title: Text(
                        'Date: ${DateFormatter.format(_date)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _date = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _amountCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Allocated Amount *',
                        prefixText: '₹ ',
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null || val <= 0) return 'Invalid';
                        if (val > unallocated + 0.01) {
                          return 'Max ${CurrencyFormatter.format(unallocated)}';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Narration
              TextFormField(
                controller: _narrationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Usage Note / Location (optional)',
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _allocate,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.outbox_rounded, size: 18),
          label: Text(_saving ? 'Allocating…' : 'Confirm Allocation'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
          ),
        ),
      ],
    );
  }

  Future<void> _allocate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final repo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
      final amount = double.parse(_amountCtrl.text.trim());

      await repo.allocateStockToProject(
        purchaseId: widget.pd.purchase.id,
        targetProjectId: _targetProjectId!,
        date: _date,
        amountToAllocate: amount,
        narration: _narrationCtrl.text.trim().isEmpty
            ? null
            : _narrationCtrl.text.trim(),
        referenceNo: _refCtrl.text.trim().isEmpty
            ? null
            : _refCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${CurrencyFormatter.format(amount)} allocated to project successfully. Cost recognized in P&L!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _MarkPaidDialog extends ConsumerStatefulWidget {
  final PurchaseDetail pd;
  const _MarkPaidDialog({required this.pd});

  @override
  ConsumerState<_MarkPaidDialog> createState() => _MarkPaidDialogState();
}

class _MarkPaidDialogState extends ConsumerState<_MarkPaidDialog> {
  late final TextEditingController _amountPaidCtrl;
  final _refController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  PaymentMode? _paymentMode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final total = widget.pd.transaction.amount;
    final alreadyPaid = widget.pd.purchase.paidAmount;
    final due = (total - alreadyPaid).clamp(0.0, double.infinity);
    _amountPaidCtrl = TextEditingController(
      text: due % 1 == 0 ? due.toInt().toString() : due.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountPaidCtrl.dispose();
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.pd.transaction.amount;
    final alreadyPaid = widget.pd.purchase.paidAmount;
    final due = (total - alreadyPaid).clamp(0.0, double.infinity);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.payment_rounded, color: theme.colorScheme.primary, size: 22.sp),
          SizedBox(width: 8.w),
          const Text('Record Vendor Payment'),
        ],
      ),
      content: SizedBox(
        width: 440.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill & Due Breakdown Card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pd.purchase.itemDescription,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Text(
                        'Vendor: ${widget.pd.vendor.name}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total Bill: ${CurrencyFormatter.format(total)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (alreadyPaid > 0) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          'Already Paid: ${CurrencyFormatter.format(alreadyPaid)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Credit Due: ${CurrencyFormatter.format(due)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Amount to pay field + quick fill
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountPaidCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Amount to Pay Now (₹) *',
                      prefixText: '₹ ',
                      isDense: true,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                SizedBox(width: 8.w),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _amountPaidCtrl.text = due % 1 == 0
                          ? due.toInt().toString()
                          : due.toStringAsFixed(2);
                    });
                  },
                  child: const Text('Pay Full Due'),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Payment date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(
                'Payment Date: ${DateFormatter.format(_paymentDate)}',
                style: TextStyle(fontSize: 13.sp),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _paymentDate = picked);
                }
              },
            ),
            SizedBox(height: 8.h),

            // Payment mode
            DropdownButtonFormField<PaymentMode?>(
              value: _paymentMode,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Payment Mode',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('— Select Mode —', overflow: TextOverflow.ellipsis)),
                ...PaymentMode.values.map(
                  (m) => DropdownMenuItem(
                      value: m, child: Text(m.displayName, overflow: TextOverflow.ellipsis)),
                ),
              ],
              onChanged: (v) => setState(() => _paymentMode = v),
            ),
            SizedBox(height: 14.h),

            // Reference
            TextField(
              controller: _refController,
              decoration: const InputDecoration(
                labelText: 'Reference / Cheque / UTR No. (optional)',
                isDense: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? SizedBox(
                  width: 16.w,
                  height: 16.h,
                  child: const CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check, size: 18),
          label: Text(_saving ? 'Recording…' : 'Record Payment'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final cleanStr =
        _amountPaidCtrl.text.replaceAll(',', '').replaceAll(' ', '').trim();
    final amountPaid = double.tryParse(cleanStr);
    if (amountPaid == null || amountPaid <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid positive payment amount.')),
      );
      return;
    }

    final total = widget.pd.transaction.amount;
    final alreadyPaid = widget.pd.purchase.paidAmount;
    final due = (total - alreadyPaid).clamp(0.0, double.infinity);

    if (amountPaid > due + 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Payment amount (${CurrencyFormatter.format(amountPaid)}) cannot exceed outstanding due (${CurrencyFormatter.format(due)}).'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final repo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
      await repo.markPurchasePaid(
        purchaseId: widget.pd.purchase.id,
        paymentDate: _paymentDate,
        amountPaid: amountPaid,
        paymentMode: _paymentMode,
        referenceNo: _refController.text.trim().isEmpty
            ? null
            : _refController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Payment of ${CurrencyFormatter.format(amountPaid)} recorded for ${widget.pd.purchase.itemDescription}',
          ),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment status chip
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentStatusChip extends StatelessWidget {
  final PaymentStatus status;
  const _PaymentStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      PaymentStatus.paid => (Colors.green.shade700, Colors.green.shade50),
      PaymentStatus.pending => (Colors.red.shade700, Colors.red.shade50),
      PaymentStatus.partial => (Colors.orange.shade700, Colors.orange.shade50),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
