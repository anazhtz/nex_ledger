import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class VendorDetailScreen extends ConsumerWidget {
  final int vendorId;
  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorAsync = ref.watch(vendorByIdProvider(vendorId));
    final summaryAsync = ref.watch(vendorLedgerSummaryProvider(vendorId));
    final purchasesAsync = ref.watch(vendorPurchasesProvider(vendorId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: vendorAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (vendor) {
          if (vendor == null) {
            return const Center(child: Text('Vendor not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Back + Title ──────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name,
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          vendor.contact ?? 'No contact on file',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Accounts Payable badge (if any outstanding)
                    summaryAsync.maybeWhen(
                      data: (s) => s.totalPending > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.red.shade200, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Outstanding Payable',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                              color: Colors.red.shade700)),
                                  Text(
                                    CurrencyFormatter.format(s.totalPending),
                                    style: theme.textTheme.titleLarge
                                        ?.copyWith(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Summary Strip ─────────────────────────────────────────
                summaryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (s) => _VendorSummaryStrip(summary: s),
                ),
                const SizedBox(height: 20),

                // ── Purchase History Table ─────────────────────────────────
                Expanded(
                  child: purchasesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (purchases) => _VendorPurchaseTable(
                      purchases: purchases,
                      ref: ref,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary strip
// ─────────────────────────────────────────────────────────────────────────────

class _VendorSummaryStrip extends StatelessWidget {
  final VendorLedgerSummary summary;
  const _VendorSummaryStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryTile(
          label: 'Total Purchases',
          value: CurrencyFormatter.format(summary.totalPurchases),
          icon: Icons.shopping_cart_outlined,
          color: Colors.orange.shade700,
          bg: Colors.orange.shade50,
        ),
        const SizedBox(width: 12),
        _SummaryTile(
          label: 'Amount Paid',
          value: CurrencyFormatter.format(summary.totalPaid),
          icon: Icons.check_circle_outline_rounded,
          color: Colors.green.shade700,
          bg: Colors.green.shade50,
        ),
        const SizedBox(width: 12),
        _SummaryTile(
          label: 'Outstanding Payable',
          value: CurrencyFormatter.format(summary.totalPending),
          icon: summary.totalPending > 0
              ? Icons.account_balance_wallet_outlined
              : Icons.check_circle_outline_rounded,
          color: summary.totalPending > 0
              ? Colors.red.shade700
              : Colors.green.shade700,
          bg: summary.totalPending > 0
              ? Colors.red.shade50
              : Colors.green.shade50,
          bold: true,
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool bold;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        theme.textTheme.labelSmall?.copyWith(color: color)),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight:
                        bold ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Purchase history table
// ─────────────────────────────────────────────────────────────────────────────

class _VendorPurchaseTable extends StatelessWidget {
  final List<PurchaseDetail> purchases;
  final WidgetRef ref;
  const _VendorPurchaseTable({required this.purchases, required this.ref});

  @override
  Widget build(BuildContext context) {
    final total = purchases.fold<double>(0.0, (s, p) => s + p.transaction.amount);
    final pending = purchases
        .where((p) => p.purchase.paymentStatus != PaymentStatus.paid)
        .fold<double>(0.0, (s, p) => s + p.transaction.amount);

    return DataTableCard(
      title: 'Purchase History  •  ${purchases.length} bills  •  Total: ${CurrencyFormatter.format(total)}'
          '${pending > 0 ? "  •  Pending: ${CurrencyFormatter.format(pending)}" : ""}',
      emptyMessage: 'No purchases from this vendor yet.',
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Project')),
        DataColumn(label: Text('Description')),
        DataColumn(label: Text('Amount'), numeric: true),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Mode')),
        DataColumn(label: Text('Action')),
      ],
      rows: purchases.map((pd) {
        final isPending =
            pd.purchase.paymentStatus == PaymentStatus.pending ||
                pd.purchase.paymentStatus == PaymentStatus.partial;
        return DataRow(cells: [
          DataCell(Text(DateFormatter.format(pd.transaction.date))),
          DataCell(Text(pd.project.name, overflow: TextOverflow.ellipsis)),
          DataCell(SizedBox(
            width: 180,
            child: Text(pd.purchase.itemDescription,
                overflow: TextOverflow.ellipsis),
          )),
          DataCell(Text(CurrencyFormatter.format(pd.transaction.amount))),
          DataCell(_PaymentStatusChip(pd.purchase.paymentStatus)),
          DataCell(
              Text(pd.transaction.paymentMode?.displayName ?? '—')),
          DataCell(
            isPending
                ? TextButton.icon(
                    onPressed: () =>
                        _showMarkPaidDialog(context, ref, pd),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Mark Paid'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.primary,
                    ),
                  )
                : const Text('—'),
          ),
        ]);
      }).toList(),
    );
  }

  void _showMarkPaidDialog(
      BuildContext context, WidgetRef ref, PurchaseDetail pd) {
    showDialog<void>(
      context: context,
      builder: (_) => _MarkPaidDialog(pd: pd, ref: ref),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mark as Paid dialog (inline for vendor ledger)
// ─────────────────────────────────────────────────────────────────────────────

class _MarkPaidDialog extends StatefulWidget {
  final PurchaseDetail pd;
  final WidgetRef ref;
  const _MarkPaidDialog({required this.pd, required this.ref});

  @override
  State<_MarkPaidDialog> createState() => _MarkPaidDialogState();
}

class _MarkPaidDialogState extends State<_MarkPaidDialog> {
  DateTime _date = DateTime.now();
  PaymentMode? _mode;
  final _refCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _refCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Confirm Payment'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(widget.pd.purchase.itemDescription,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Text(
                  CurrencyFormatter.format(widget.pd.transaction.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w700),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text('Date: ${DateFormatter.format(_date)}'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            DropdownButtonFormField<PaymentMode?>(
              value: _mode,
              decoration: const InputDecoration(
                  labelText: 'Payment Mode', isDense: true),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('— Select —')),
                ...PaymentMode.values.map((m) =>
                    DropdownMenuItem(value: m, child: Text(m.displayName))),
              ],
              onChanged: (v) => setState(() => _mode = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _refCtrl,
              decoration: const InputDecoration(
                  labelText: 'Reference / Cheque No. (optional)',
                  isDense: true),
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
      final db = widget.ref.read(appDatabaseProvider);
      final repo =
          PurchaseRepository(db.purchaseDao, db.transactionDao, db);
      await repo.markPurchasePaid(
        purchaseId: widget.pd.purchase.id,
        paymentDate: _date,
        amountPaid: widget.pd.transaction.amount,
        paymentMode: _mode,
        referenceNo:
            _refCtrl.text.trim().isEmpty ? null : _refCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Payment recorded for ${widget.pd.purchase.itemDescription}'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment status chip
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentStatusChip extends StatelessWidget {
  final PaymentStatus status;
  const _PaymentStatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      PaymentStatus.paid => (Colors.green.shade700, Colors.green.shade50),
      PaymentStatus.pending => (Colors.red.shade700, Colors.red.shade50),
      PaymentStatus.partial =>
        (Colors.orange.shade700, Colors.orange.shade50),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(status.displayName,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
