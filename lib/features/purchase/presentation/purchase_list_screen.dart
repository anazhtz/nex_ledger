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
                      'Vendor-linked purchase entries',
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

            // ── Accounts Payable summary card ───────────────────────────────
            apAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (ap) => ap > 0
                  ? _AccountsPayableCard(amount: ap, theme: theme)
                  : const SizedBox.shrink(),
            ),
            apAsync.maybeWhen(data: (ap) => ap > 0, orElse: () => false)
                ? const SizedBox(height: 12)
                : const SizedBox.shrink(),

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
                        width: 220,
                        child: DropdownButtonFormField<int?>(
                          value: filterProject,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Project',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All Projects')),
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
                    DataColumn(label: Text('Amount'), numeric: true),
                    DataColumn(label: Text('Payment')),
                    DataColumn(label: Text('Mode')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: purchases.map((pd) {
                    final isPending =
                        pd.purchase.paymentStatus == PaymentStatus.pending ||
                            pd.purchase.paymentStatus == PaymentStatus.partial;
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
                          width: 180,
                          child: Text(pd.purchase.itemDescription,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      DataCell(Text(
                          CurrencyFormatter.format(pd.transaction.amount))),
                      DataCell(_PaymentStatusChip(
                          status: pd.purchase.paymentStatus)),
                      DataCell(Text(
                          pd.transaction.paymentMode?.displayName ?? '—')),
                      DataCell(
                        isPending
                            ? TextButton.icon(
                                onPressed: () => _showMarkPaidDialog(
                                  context,
                                  ref,
                                  pd,
                                ),
                                icon: const Icon(Icons.check_circle_outline,
                                    size: 16),
                                label: const Text('Mark Paid'),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      theme.colorScheme.primary,
                                ),
                              )
                            : const Text('—'),
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

  /// Shows a dialog to confirm payment and record the cash outflow.
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
      color: theme.colorScheme.errorContainer.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.error.withOpacity(0.4),
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
