import 'package:nex_ledger/shared/widgets/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/purchase/presentation/widgets/allocate_stock_dialog.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_invoice_providers.dart';

String _plain(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);

/// Colour-coded Paid / Partial / Pending label.
class InvoiceStatusChip extends StatelessWidget {
  final PaymentStatus status;
  const InvoiceStatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      PaymentStatus.paid => (const Color(0xFF059669), const Color(0xFFECFDF5)),
      PaymentStatus.partial => (
          const Color(0xFFD97706),
          const Color(0xFFFFFBEB)
        ),
      PaymentStatus.pending => (
          const Color(0xFFDC2626),
          const Color(0xFFFEF2F2)
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.displayName,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

/// Everything about one saved invoice, with Pay / Edit / Delete.
/// Looks the invoice up live, so it updates after a payment.
class InvoiceDetailDialog extends ConsumerWidget {
  final int invoiceId;
  const InvoiceDetailDialog({super.key, required this.invoiceId});

  static Future<void> show(BuildContext context, int invoiceId) =>
      showDialog<void>(
        context: context,
        builder: (_) => InvoiceDetailDialog(invoiceId: invoiceId),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(invoiceListProvider).asData?.value;
    final d = list?.where((i) => i.invoice.id == invoiceId).firstOrNull;
    if (d == null) {
      if (list != null) {
        // The invoice was deleted while this dialog was open: close quietly.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return const SizedBox.shrink();
      }
      return const AlertDialog(
          content: SizedBox(
              height: 60, child: Center(child: CircularProgressIndicator())));
    }
    final inv = d.invoice;
    final items = d.lines.where((l) => !l.purchase.isOtherCharge).toList();
    final charges = d.lines.where((l) => l.purchase.isOtherCharge).toList();

    Widget kv(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                width: 110,
                child: Text(k,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12))),
            Expanded(
                child: Text(v.isEmpty ? '—' : v,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600))),
          ]),
        );

    Widget totalRow(String k, double v, {bool bold = false, Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Expanded(
                child: Text(k,
                    style: TextStyle(
                        fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                        color: color))),
            Text(CurrencyFormatter.format(v),
                style: TextStyle(
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                    color: color)),
          ]),
        );

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
      title: Row(children: [
        const Icon(Icons.receipt_long_rounded, color: Color(0xFF1F5FBF)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(inv.purchaseNo,
                style: const TextStyle(fontWeight: FontWeight.w800))),
        InvoiceStatusChip(d.status),
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded)),
      ]),
      content: SizedBox(
        width: 980,
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 40, runSpacing: 4, children: [
              SizedBox(
                  width: 440,
                  child: Column(children: [
                    kv('Supplier', d.vendor.name),
                    kv('GSTIN', inv.supplierGstin ?? ''),
                    kv('State', inv.supplierState ?? ''),
                    kv('Project', '${d.project.code} — ${d.project.name}'),
                    kv(
                        'Supplier invoice',
                        [
                          inv.invoiceNo,
                          if (inv.invoiceDate != null)
                            DateFormatter.format(inv.invoiceDate!)
                        ].whereType<String>().join('  ·  ')),
                  ])),
              SizedBox(
                  width: 440,
                  child: Column(children: [
                    kv('Purchase date', DateFormatter.format(inv.date)),
                    kv(
                        'GST type',
                        inv.isInterState
                            ? 'Inter-state (IGST)'
                            : 'Local (CGST + SGST)'),
                    kv(
                        'Credit',
                        inv.creditDays > 0
                            ? '${inv.creditDays} days${d.dueDate != null ? ' · due ${DateFormatter.format(d.dueDate!)}' : ''}'
                            : 'None'),
                    kv(
                        'Transport',
                        [inv.transportBy, inv.vehicleNo]
                            .whereType<String>()
                            .join('  ·  ')),
                    kv(
                        'Held as',
                        inv.isAdvanceStock
                            ? 'Stock / asset (not a project cost until allocated)'
                            : 'Direct project cost'),
                  ])),
            ]),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 38,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 52,
                columnSpacing: 18,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('HSN')),
                  DataColumn(label: Text('Qty'), numeric: true),
                  DataColumn(label: Text('Rate'), numeric: true),
                  DataColumn(label: Text('Disc'), numeric: true),
                  DataColumn(label: Text('GST'), numeric: true),
                  DataColumn(label: Text('Taxable'), numeric: true),
                  DataColumn(label: Text('GST ₹'), numeric: true),
                  DataColumn(label: Text('Amount'), numeric: true),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('')),
                ],
                rows: [
                  for (var i = 0; i < items.length; i++)
                    () {
                      final p = items[i].purchase;
                      final unallocated =
                          items[i].transaction.amount - p.allocatedAmount;
                      final canAllocate =
                          p.isAdvanceStock && unallocated > 0.01;
                      return DataRow(cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.itemDescription,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              if ((p.specification ?? '').isNotEmpty)
                                Text(p.specification!,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B))),
                            ])),
                        DataCell(Text(p.hsn ?? '—')),
                        DataCell(Text('${_plain(p.quantity)} ${p.unit ?? ''}')),
                        DataCell(Text(_plain(p.unitRate))),
                        DataCell(Text(p.discountPercent > 0
                            ? '${_plain(p.discountPercent)}%'
                            : '—')),
                        DataCell(Text('${_plain(p.gstRate)}%')),
                        DataCell(
                            Text(CurrencyFormatter.format(p.taxableAmount))),
                        DataCell(Text(CurrencyFormatter.format(
                            p.cgstAmount + p.sgstAmount + p.igstAmount))),
                        DataCell(Text(
                            CurrencyFormatter.format(
                                items[i].transaction.amount),
                            style:
                                const TextStyle(fontWeight: FontWeight.w700))),
                        DataCell(InvoiceStatusChip(p.paymentStatus)),
                        DataCell(canAllocate
                            ? TextButton.icon(
                                onPressed: () => showDialog<void>(
                                    context: context,
                                    builder: (_) =>
                                        AllocateStockDialog(pd: items[i])),
                                icon:
                                    const Icon(Icons.outbox_rounded, size: 15),
                                label: const Text('Allocate'),
                              )
                            : const SizedBox.shrink()),
                      ]);
                    }(),
                  for (final c in charges)
                    DataRow(cells: [
                      const DataCell(Text('')),
                      DataCell(Text(c.purchase.itemDescription,
                          style: const TextStyle(fontStyle: FontStyle.italic))),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(
                          Text(CurrencyFormatter.format(c.transaction.amount))),
                      DataCell(InvoiceStatusChip(c.purchase.paymentStatus)),
                      const DataCell(Text('')),
                    ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 340,
                child: Column(children: [
                  totalRow('Taxable value', inv.taxableValue),
                  if (inv.isInterState)
                    totalRow('IGST', inv.igstAmount)
                  else ...[
                    totalRow('CGST', inv.cgstAmount),
                    totalRow('SGST', inv.sgstAmount),
                  ],
                  totalRow('Other charges', inv.otherCharges),
                  totalRow('Round off', inv.roundOff),
                  const Divider(),
                  totalRow('Grand Total', d.total, bold: true),
                  totalRow('Paid', d.paid, color: const Color(0xFF059669)),
                  totalRow('Balance', d.balance,
                      bold: true,
                      color: d.balance > 0 ? const Color(0xFFDC2626) : null),
                ]),
              ),
            ),
            if ((inv.remarks ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Remarks: ${inv.remarks}',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
            const SizedBox(height: 16),
            // Buttons live in the content (not AlertDialog.actions) so the
            // Delete button can sit on the left and the rest on the right.
            Row(children: [
              TextButton.icon(
                onPressed: () => _delete(context, ref, d),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete'),
                style:
                    TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/purchases/invoice/${inv.id}/edit');
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              if (d.balance > 0) ...[
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => InvoicePayDialog(invoiceId: inv.id)),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: Text('Pay ${CurrencyFormatter.format(d.balance)}'),
                ),
              ],
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, InvoiceDetail d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.delete_forever_rounded, color: Colors.red.shade700),
          const SizedBox(width: 8),
          const Text('Delete this invoice?'),
        ]),
        content: Text(
          'Delete ${d.invoice.purchaseNo} from ${d.vendor.name} (${CurrencyFormatter.format(d.total)})?\n\n'
          'This removes all ${d.lines.length} rows${d.paid > 0 ? ' and the ${CurrencyFormatter.format(d.paid)} of payments recorded against it' : ''}. '
          'Cash and project figures go back as if it was never entered.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Delete Invoice'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(purchaseInvoiceRepositoryProvider)
          .deleteInvoice(d.invoice.id);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✓ Invoice deleted.'),
          backgroundColor: Color(0xFF059669)));
    } on StateError catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message), backgroundColor: Colors.red.shade700));
    }
  }
}

/// Record a payment against a whole invoice.
class InvoicePayDialog extends ConsumerStatefulWidget {
  final int invoiceId;
  const InvoicePayDialog({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoicePayDialog> createState() => _InvoicePayDialogState();
}

class _InvoicePayDialogState extends ConsumerState<InvoicePayDialog> {
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  PaymentMode? _mode;
  int? _bankId;
  bool _saving = false;
  bool _seeded = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(InvoiceDetail d) async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) {
      _snack('Enter a payment amount.');
      return;
    }
    if (amount > d.balance + 0.005) {
      _snack(
          'The payment is more than the balance due (${CurrencyFormatter.format(d.balance)}).');
      return;
    }
    setState(() => _saving = true);
    try {
      final left = await ref
          .read(purchaseInvoiceRepositoryProvider)
          .recordInvoicePayment(
            invoiceId: d.invoice.id,
            amount: amount,
            date: _date,
            paymentMode: _mode,
            bankAccountId: _bankId,
            referenceNo: _refCtrl.text,
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '✓ Paid ${CurrencyFormatter.format(amount)}. Balance ${CurrencyFormatter.format(left)}.'),
        backgroundColor: const Color(0xFF059669),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('${e is ArgumentError ? e.message : e}');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.red.shade700));

  @override
  Widget build(BuildContext context) {
    final d = ref
        .watch(invoiceListProvider)
        .asData
        ?.value
        .where((i) => i.invoice.id == widget.invoiceId)
        .firstOrNull;
    if (d == null) {
      return const AlertDialog(
          content: SizedBox(
              height: 60, child: Center(child: CircularProgressIndicator())));
    }
    if (!_seeded) {
      _seeded = true;
      _amountCtrl.text = _plain(d.balance);
    }
    final accounts =
        ref.watch(bankAccountsWithBalancesProvider).asData?.value ?? const [];

    return AlertDialog(
      title: const Row(children: [
        Icon(Icons.payments_outlined, color: Color(0xFF1F5FBF)),
        SizedBox(width: 8),
        Text('Pay Supplier'),
      ]),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${d.invoice.purchaseNo}  ·  ${d.vendor.name}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(
                            'Invoice total ${CurrencyFormatter.format(d.total)}  ·  Paid ${CurrencyFormatter.format(d.paid)}'),
                        Text(
                            'Balance due ${CurrencyFormatter.format(d.balance)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFDC2626))),
                      ]),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _amountCtrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Amount to pay now *', prefixText: '₹ '),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final p = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (p != null) setState(() => _date = p);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Payment date',
                        suffixIcon:
                            Icon(Icons.calendar_today_outlined, size: 16)),
                    child: Text(DateFormatter.format(_date)),
                  ),
                ),
                const SizedBox(height: 12),
                AppDropdownField<PaymentMode?>(
                  value: _mode,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Payment mode'),
                  items: [
                    const DropdownMenuItem<PaymentMode?>(
                        value: null, child: Text('— Select Mode —')),
                    ...kSelectablePaymentModes.map((m) =>
                        DropdownMenuItem<PaymentMode?>(
                            value: m, child: Text(m.displayName))),
                  ],
                  onChanged: (v) => setState(() => _mode = v),
                ),
                if (accounts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  AppDropdownField<int?>(
                    value: _bankId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Paid from'),
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text('— Auto (Default) —')),
                      ...accounts.map((a) => DropdownMenuItem<int?>(
                          value: a.account.id,
                          child: Text(
                              '${a.account.accountName} (${a.account.isCashAccount ? 'Cash' : 'Bank'})',
                              overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (v) => setState(() {
                      _bankId = v;
                      final picked =
                          accounts.where((a) => a.account.id == v).firstOrNull;
                      if (picked != null) {
                        _mode = picked.account.isCashAccount
                            ? PaymentMode.cash
                            : PaymentMode.bank;
                      }
                    }),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _refCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Reference / cheque no. (optional)'),
                ),
              ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : () => _save(d),
          child: Text(_saving ? 'Recording…' : 'Record Payment'),
        ),
      ],
    );
  }
}
