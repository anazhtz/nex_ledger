import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/reports/providers/report_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(filteredPurchaseListProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final filterProject = ref.watch(purchaseProjectFilterProvider);
    final apAsync = ref.watch(accountsPayableProvider(filterProject));
    final stockAssetAsync = ref.watch(totalUnallocatedStockAssetProvider);
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchases',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Vendor-linked purchase entries & advance stock assets',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const Spacer(),
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

            // ── Filter ──────────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (projects) => Row(
                    children: [
                      SizedBox(
                        width: 240,
                        child: DropdownButtonFormField<int?>(
                          value: filterProject,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Project',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All Projects & Stock')),
                            ...projects.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: (v) => ref
                              .read(purchaseProjectFilterProvider.notifier)
                              .state = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Purchase Table ───────────────────────────────────────────────
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
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )),
                      DataCell(
                        SizedBox(
                          width: 160,
                          child: Text(pd.purchase.itemDescription,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      DataCell(
                        isStock
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
                      DataCell(Text(
                          CurrencyFormatter.format(pd.transaction.amount))),
                      DataCell(_PaymentStatusChip(
                          status: pd.purchase.paymentStatus)),
                      DataCell(Text(
                          pd.transaction.paymentMode?.displayName ?? '—')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                              if (isPending) const SizedBox(width: 6),
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
                            if (!isPending && !canAllocate)
                              const Text('—'),
                          ],
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
    final theme = Theme.of(context);
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

// ─────────────────────────────────────────────────────────────────────────────
// Mark as Paid dialog
// ─────────────────────────────────────────────────────────────────────────────

class _MarkPaidDialog extends ConsumerStatefulWidget {
  final PurchaseDetail pd;
  const _MarkPaidDialog({required this.pd});

  @override
  ConsumerState<_MarkPaidDialog> createState() => _MarkPaidDialogState();
}

class _MarkPaidDialogState extends ConsumerState<_MarkPaidDialog> {
  DateTime _paymentDate = DateTime.now();
  PaymentMode? _paymentMode;
  final _refController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = widget.pd.transaction.amount;

    return AlertDialog(
      title: const Text('Mark Purchase as Paid'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary row
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.pd.purchase.itemDescription,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('Vendor: ', style: theme.textTheme.bodySmall),
                    Text(widget.pd.vendor.name,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(CurrencyFormatter.format(amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        )),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(
                  'Payment Date: ${DateFormatter.format(_paymentDate)}'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _paymentDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _paymentDate = picked);
                }
              },
            ),

            const SizedBox(height: 8),

            // Payment mode
            DropdownButtonFormField<PaymentMode?>(
              value: _paymentMode,
              decoration: const InputDecoration(
                labelText: 'Payment Mode',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('— Select Mode —')),
                ...PaymentMode.values.map(
                  (m) => DropdownMenuItem(
                      value: m, child: Text(m.displayName)),
                ),
              ],
              onChanged: (v) => setState(() => _paymentMode = v),
            ),

            const SizedBox(height: 16),

            // Reference
            TextField(
              controller: _refController,
              decoration: const InputDecoration(
                labelText: 'Reference / Cheque No. (optional)',
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
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check, size: 18),
          label: Text(_saving ? 'Saving…' : 'Confirm Payment'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final repo =
          PurchaseRepository(db.purchaseDao, db.transactionDao, db);
      await repo.markPurchasePaid(
        purchaseId: widget.pd.purchase.id,
        paymentDate: _paymentDate,
        amountPaid: widget.pd.transaction.amount,
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
            'Payment recorded for ${widget.pd.purchase.itemDescription}',
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
