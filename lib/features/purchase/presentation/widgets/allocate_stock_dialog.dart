import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/daos/purchase_dao.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Allocate Stock to Project Dialog
// ─────────────────────────────────────────────────────────────────────────────

class AllocateStockDialog extends ConsumerStatefulWidget {
  final PurchaseDetail pd;
  const AllocateStockDialog({required this.pd});

  @override
  ConsumerState<AllocateStockDialog> createState() =>
      AllocateStockDialogState();
}

class AllocateStockDialogState extends ConsumerState<AllocateStockDialog> {
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
    final remaining =
        widget.pd.transaction.amount - widget.pd.purchase.allocatedAmount;
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
                      leading:
                          const Icon(Icons.calendar_today_outlined, size: 20),
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
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
        referenceNo: _refCtrl.text.trim().isEmpty ? null : _refCtrl.text.trim(),
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
