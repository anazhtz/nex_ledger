import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/client_billing/providers/client_billing_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class ClientReceiptFormScreen extends ConsumerStatefulWidget {
  final int? initialProjectId;
  final int? initialRaBillId;

  const ClientReceiptFormScreen({
    super.key,
    this.initialProjectId,
    this.initialRaBillId,
  });

  @override
  ConsumerState<ClientReceiptFormScreen> createState() =>
      _ClientReceiptFormScreenState();
}

class _ClientReceiptFormScreenState
    extends ConsumerState<ClientReceiptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int? _selectedProjectId;
  int? _selectedRaBillId;
  PaymentMode _selectedPaymentMode = PaymentMode.bank;
  int? _selectedBankAccountId;
  DateTime _receiptDate = DateTime.now();

  bool _isAdvance = false;
  bool _isRetentionRelease = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedProjectId =
        widget.initialProjectId ?? ref.read(selectedProjectIdProvider);
    _selectedRaBillId = widget.initialRaBillId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _amount =>
      double.tryParse(_amountCtrl.text.replaceAll(',', '').trim()) ?? 0.0;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target project.')),
      );
      return;
    }

    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive receipt amount.')),
      );
      return;
    }

    if (_selectedPaymentMode == PaymentMode.bank &&
        _selectedBankAccountId == null) {
      final accounts =
          await ref.read(bankAccountsListProvider.future);
      if (accounts.isNotEmpty) {
        _selectedBankAccountId = accounts.first.id;
      }
    }

    setState(() => _loading = true);
    try {
      await ref.read(clientBillingRepositoryProvider).recordClientReceipt(
            projectId: _selectedProjectId!,
            clientRaBillId: _selectedRaBillId,
            receiptDate: _receiptDate,
            amount: _amount,
            paymentMode: _selectedPaymentMode,
            bankAccountId: _selectedBankAccountId,
            isAdvance: _isAdvance,
            isRetentionRelease: _isRetentionRelease,
            referenceNo: _refCtrl.text.isNotEmpty ? _refCtrl.text.trim() : null,
            notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text.trim() : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Client receipt recorded successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.go('/client-billing');
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
    final projectsAsync = ref.watch(projectListProvider);
    final bankAccountsAsync = ref.watch(bankAccountsListProvider);
    final raBillsAsync =
        ref.watch(clientRaBillsListProvider(_selectedProjectId));
    final theme = Theme.of(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go('/client-billing'),
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.w),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Header ─────────────────────────────────────────
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.go('/client-billing'),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Record Client Receipt / Collection',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Record money received from client via Bank, Cheque, or Cash',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ─── Project Selector ────────────────────────────────
                        projectsAsync.when(
                          loading: () => const Center(
                              child: LinearProgressIndicator()),
                          error: (e, _) => Text('Error loading projects: $e'),
                          data: (projects) {
                            final validProjects = projects
                                .where((p) => p.type == ProjectType.project)
                                .toList();

                            return DropdownButtonFormField<int>(
                              isExpanded: true,
                              value: validProjects.any(
                                      (p) => p.id == _selectedProjectId)
                                  ? _selectedProjectId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Select Target Project & Client *',
                                prefixIcon: Icon(Icons.folder_outlined),
                              ),
                              items: validProjects
                                  .map((p) => DropdownMenuItem(
                                        value: p.id,
                                        child: Text(
                                          '${p.code} — ${p.name} (Client: ${p.clientName ?? 'Direct Client'})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedProjectId = v;
                                  _selectedRaBillId = null;
                                });
                              },
                              validator: (v) => v == null ? 'Required' : null,
                            );
                          },
                        ),
                        SizedBox(height: 14.h),

                        // ─── Live Balance Due Banner ─────────────────────────
                        if (_selectedProjectId != null)
                          _buildLiveProjectReceivablesBanner(context),

                        SizedBox(height: 14.h),

                        // ─── Linked RA Bill Dropdown (Optional) ──────────────
                        raBillsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (bills) {
                            return DropdownButtonFormField<int?>(
                              value: bills.any((b) => b.bill.id == _selectedRaBillId)
                                  ? _selectedRaBillId
                                  : null,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Linked Client RA Bill (Optional)',
                                prefixIcon: Icon(Icons.receipt_long_outlined),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                      'General Account Receipt (Not tied to specific bill)',
                                      overflow: TextOverflow.ellipsis),
                                ),
                                ...bills.map((b) => DropdownMenuItem(
                                      value: b.bill.id,
                                      child: Text(
                                        '${b.bill.billNumber}: ${b.bill.stageOrDescription} (Net: ${CurrencyFormatter.format(b.bill.netCertifiedAmount)})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _selectedRaBillId = v;
                                  if (v != null) {
                                    final bill = bills
                                        .firstWhere((b) => b.bill.id == v)
                                        .bill;
                                    _amountCtrl.text =
                                        bill.netCertifiedAmount.toString();
                                  }
                                });
                              },
                            );
                          },
                        ),
                        SizedBox(height: 16.h),

                        // ─── Classification Chips ────────────────────────────
                        Text(
                          'Collection Classification:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            ChoiceChip(
                              label: const Text('RA Bill Settlement'),
                              selected: !_isAdvance && !_isRetentionRelease,
                              onSelected: (_) => setState(() {
                                _isAdvance = false;
                                _isRetentionRelease = false;
                              }),
                            ),
                            ChoiceChip(
                              label: const Text('Mobilization Advance'),
                              selected: _isAdvance,
                              onSelected: (_) => setState(() {
                                _isAdvance = true;
                                _isRetentionRelease = false;
                              }),
                            ),
                            ChoiceChip(
                              label: const Text('Retention Release'),
                              selected: _isRetentionRelease,
                              onSelected: (_) => setState(() {
                                _isAdvance = false;
                                _isRetentionRelease = true;
                              }),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ─── Amount & Date ───────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _amountCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Amount Received (₹) *',
                                  hintText: '1000000',
                                  prefixText: '₹ ',
                                  prefixIcon: Icon(Icons.currency_rupee),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Required';
                                  final num =
                                      double.tryParse(v.replaceAll(',', ''));
                                  if (num == null || num <= 0) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: _pickReceiptDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Receipt Date *',
                                    prefixIcon:
                                        Icon(Icons.calendar_today_outlined),
                                  ),
                                  child: Text(
                                    '${_receiptDate.day.toString().padLeft(2, '0')}/'
                                    '${_receiptDate.month.toString().padLeft(2, '0')}/'
                                    '${_receiptDate.year}',
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Payment Mode & Bank Account ─────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<PaymentMode>(
                                value: _selectedPaymentMode,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Payment Mode *',
                                  prefixIcon: Icon(Icons.payment_outlined),
                                ),
                                items: PaymentMode.values
                                    .map((m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(m.displayName),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _selectedPaymentMode = v);
                                  }
                                },
                              ),
                            ),
                            if (_selectedPaymentMode != PaymentMode.cash) ...[
                              SizedBox(width: 14.w),
                              Expanded(
                                flex: 3,
                                child: bankAccountsAsync.when(
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                  data: (accounts) {
                                    return DropdownButtonFormField<int>(
                                      value: accounts.any(
                                              (a) => a.id == _selectedBankAccountId)
                                          ? _selectedBankAccountId
                                          : (accounts.isNotEmpty
                                              ? accounts.first.id
                                              : null),
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Receiving Bank Account *',
                                        prefixIcon:
                                            Icon(Icons.account_balance_outlined),
                                      ),
                                      items: accounts
                                          .map((a) => DropdownMenuItem(
                                                value: a.id,
                                                child: Text(
                                                  '${a.bankName} (${a.accountNumber})',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (v) => setState(
                                          () => _selectedBankAccountId = v),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Reference & Notes ───────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _refCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Cheque / NEFT / RTGS / UTR #',
                                  hintText: 'e.g. UTR-982348123984',
                                  prefixIcon: Icon(Icons.tag_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        TextFormField(
                          controller: _notesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Receipt Notes',
                            hintText: 'e.g. Payment for RA Bill 01 via HDFC transfer',
                            prefixIcon: Icon(Icons.note_alt_outlined),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ─── Explanatory Notice ──────────────────────────────
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: const Color(0xFF64748B), size: 18.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Recording this client collection deposits physical cash into your bank/cash balance and reduces the client\'s outstanding receivables. P&L is not affected (already recognized when the bill was raised).',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ─── Buttons ─────────────────────────────────────────
                        Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12.w,
                          runSpacing: 8.h,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/client-billing'),
                              child: const Text('Cancel (Esc)'),
                            ),
                            FilledButton.icon(
                              onPressed: _loading ? null : _submit,
                              icon: _loading
                                  ? SizedBox(
                                      width: 16.sp,
                                      height: 16.sp,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check, size: 18),
                              label: const Text('Record Client Receipt (Ctrl+Enter)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveProjectReceivablesBanner(BuildContext context) {
    final progressAsync =
        ref.watch(projectRevenueProgressProvider(_selectedProjectId!));

    return progressAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (progress) {
        if (progress == null) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded,
                  size: 20.sp, color: const Color(0xFF16A34A)),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client: ${progress.project.clientName ?? 'Direct Client'} • Outstanding Due: ${CurrencyFormatter.format(progress.clientOutstandingReceivables)}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF14532D),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Contract: ${CurrencyFormatter.format(progress.clientContractValue)} • Total Invoiced: ${CurrencyFormatter.format(progress.totalGrossBilled)} • Total Receipts: ${CurrencyFormatter.format(progress.totalClientReceipts)} • Retention Held: ${CurrencyFormatter.format(progress.clientRetentionHeldByClient)}',
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF166534)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickReceiptDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _receiptDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _receiptDate = picked);
  }
}
