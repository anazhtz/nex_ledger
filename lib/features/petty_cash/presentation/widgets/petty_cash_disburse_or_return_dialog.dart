import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/petty_cash/providers/petty_cash_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class PettyCashDisburseOrReturnDialog extends ConsumerStatefulWidget {
  final int? initialWalletId;
  final bool isReturn;

  const PettyCashDisburseOrReturnDialog({
    super.key,
    this.initialWalletId,
    this.isReturn = false,
  });

  @override
  ConsumerState<PettyCashDisburseOrReturnDialog> createState() =>
      _PettyCashDisburseOrReturnDialogState();
}

class _PettyCashDisburseOrReturnDialogState
    extends ConsumerState<PettyCashDisburseOrReturnDialog> {
  final _formKey = GlobalKey<FormState>();
  late bool _isReturn;
  DateTime _date = DateTime.now();

  int? _selectedWalletId;
  int? _selectedProjectId;
  PaymentMode _paymentMode = PaymentMode.cash;
  int? _selectedBankAccountId;

  final _amountCtrl = TextEditingController();
  final _voucherNumCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();
  final _verifiedByCtrl = TextEditingController(text: 'Accountant / PM');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _isReturn = widget.isReturn;
    _selectedWalletId = widget.initialWalletId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _voucherNumCtrl.dispose();
    _narrationCtrl.dispose();
    _verifiedByCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supervisor wallet.')),
      );
      return;
    }
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project site.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final amount =
          double.tryParse(_amountCtrl.text.trim().replaceAll(',', '')) ?? 0.0;
      final repo = ref.read(pettyCashRepositoryProvider);

      if (_isReturn) {
        await repo.returnUnspentCash(
          walletId: _selectedWalletId!,
          projectId: _selectedProjectId!,
          date: _date,
          amount: amount,
          paymentMode: _paymentMode,
          bankAccountId: _selectedBankAccountId,
          narration: _narrationCtrl.text.trim().isNotEmpty
              ? _narrationCtrl.text.trim()
              : 'Unspent petty cash returned to office',
          voucherNumber: _voucherNumCtrl.text.trim().isNotEmpty
              ? _voucherNumCtrl.text.trim()
              : null,
          verifiedBy: _verifiedByCtrl.text.trim().isNotEmpty
              ? _verifiedByCtrl.text.trim()
              : null,
        );
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Unspent cash returned & credited to office drawer/bank!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
        return;
      }

      await repo.disburseCashAdvance(
        walletId: _selectedWalletId!,
        projectId: _selectedProjectId!,
        date: _date,
        amount: amount,
        paymentMode: _paymentMode,
        bankAccountId: _selectedBankAccountId,
        narration: _narrationCtrl.text.trim().isNotEmpty
            ? _narrationCtrl.text.trim()
            : 'Site petty cash advance float handed to supervisor',
        voucherNumber: _voucherNumCtrl.text.trim().isNotEmpty
            ? _voucherNumCtrl.text.trim()
            : null,
        verifiedBy: _verifiedByCtrl.text.trim().isNotEmpty
            ? _verifiedByCtrl.text.trim()
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Cash advance disbursed to supervisor wallet!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(allWalletsProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final bankAccountsAsync = ref.watch(bankAccountsListProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.w),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Dialog Header ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isReturn
                                  ? 'Return Unspent Cash to Office'
                                  : 'Disburse Cash Advance to Supervisor',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _isReturn
                                  ? 'Supervisor surrenders unspent site cash back into bank or drawer'
                                  : 'Hand physical cash or UPI advance to supervisor for site expenses',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ─── Supervisor Selector ───────────────────────────────────
                  walletsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (wallets) => DropdownButtonFormField<int?>(
                      value: _selectedWalletId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Supervisor / Engineer *',
                        prefixIcon: Icon(Icons.person_pin_outlined),
                      ),
                      selectedItemBuilder: (context) => [
                        const Text('— Select Supervisor —', overflow: TextOverflow.ellipsis),
                        ...wallets.map(
                          (w) => Text(w.wallet.supervisorName, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('— Select Supervisor —', overflow: TextOverflow.ellipsis),
                        ),
                        ...wallets.map(
                          (w) => DropdownMenuItem(
                            value: w.wallet.id,
                            child: Text(
                              w.wallet.supervisorName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (id) {
                        setState(() {
                          _selectedWalletId = id;
                          if (id != null && _selectedProjectId == null) {
                            final match = wallets.firstWhere((item) => item.wallet.id == id);
                            _selectedProjectId = match.wallet.assignedProjectId;
                          }
                        });
                      },
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // ─── Target Project Site ───────────────────────────────────
                  projectsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                    data: (projects) {
                      final validProjects =
                          projects.where((p) => p.type == ProjectType.project).toList();
                      return DropdownButtonFormField<int?>(
                        value: _selectedProjectId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Assigned Project Site *',
                          prefixIcon: Icon(Icons.folder_outlined),
                        ),
                        selectedItemBuilder: (context) => [
                          const Text('— Select Project —', overflow: TextOverflow.ellipsis),
                          ...validProjects.map(
                            (p) => Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                          ),
                        ],
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('— Select Project —', overflow: TextOverflow.ellipsis),
                          ),
                          ...validProjects.map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedProjectId = v),
                        validator: (v) => v == null ? 'Required' : null,
                      );
                    },
                  ),
                  SizedBox(height: 14.h),

                  // ─── Date Picker ───────────────────────────────────────────
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Transaction Date *',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(
                        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // ─── Amount ────────────────────────────────────────────────
                  TextFormField(
                    controller: _amountCtrl,
                    decoration: InputDecoration(
                      labelText: _isReturn ? 'Cash Returned Amount (₹) *' : 'Cash Advance Amount (₹) *',
                      hintText: '20000',
                      prefixText: '₹ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final parsed = double.tryParse(v.trim().replaceAll(',', ''));
                      if (parsed == null || parsed <= 0) return 'Enter valid amount';
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),

                  // ─── Payment Mode ──────────────────────────────────────────
                  DropdownButtonFormField<PaymentMode>(
                    value: _paymentMode,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode *',
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                    ),
                    selectedItemBuilder: (context) => const [
                      Text('Cash Drawer', overflow: TextOverflow.ellipsis),
                      Text('Bank Transfer / NEFT', overflow: TextOverflow.ellipsis),
                      Text('UPI / GPay / Online', overflow: TextOverflow.ellipsis),
                      Text('Cheque', overflow: TextOverflow.ellipsis),
                    ],
                    items: const [
                      DropdownMenuItem(value: PaymentMode.cash, child: Text('Cash Drawer', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: PaymentMode.bank, child: Text('Bank Transfer / NEFT', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: PaymentMode.online, child: Text('UPI / GPay / Online', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: PaymentMode.cheque, child: Text('Cheque', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (m) {
                      if (m != null) setState(() => _paymentMode = m);
                    },
                  ),
                  SizedBox(height: 14.h),

                  // ─── Office Bank Account ───────────────────────────────────
                  bankAccountsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (accounts) => DropdownButtonFormField<int?>(
                      value: _selectedBankAccountId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Office Bank / Drawer Account',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                      selectedItemBuilder: (context) => [
                        const Text('— Main Cash Drawer —', overflow: TextOverflow.ellipsis),
                        ...accounts.map(
                          (a) => Text(a.accountName, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('— Main Cash Drawer —', overflow: TextOverflow.ellipsis),
                        ),
                        ...accounts.map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(
                              a.accountName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => _selectedBankAccountId = v),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // ─── Voucher Number & Narration ────────────────────────────
                  TextFormField(
                    controller: _voucherNumCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Voucher / Ref # (Optional)',
                      hintText: 'e.g. ADV-01 / RET-01',
                      prefixIcon: Icon(Icons.tag_outlined),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  TextFormField(
                    controller: _narrationCtrl,
                    decoration: InputDecoration(
                      labelText: 'Narration / Purpose',
                      hintText: _isReturn
                          ? 'e.g. Unused advance returned after slab casting completion'
                          : 'e.g. Handed cash float for worker snacks & emergency hardware',
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  TextFormField(
                    controller: _verifiedByCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Authorized / Verified By',
                      hintText: 'Accountant / PM',
                      prefixIcon: Icon(Icons.verified_user_outlined),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ─── Action Buttons ────────────────────────────────────────
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 10.w,
                    runSpacing: 8.h,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? SizedBox(
                                width: 14.sp,
                                height: 14.sp,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(_isReturn ? Icons.check : Icons.send_rounded, size: 16),
                        label: Text(_isReturn ? 'Save Cash Return' : 'Disburse Float Advance'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
