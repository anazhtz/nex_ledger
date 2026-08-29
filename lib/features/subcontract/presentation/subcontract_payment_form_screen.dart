import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/subcontract/providers/subcontract_providers.dart';

class SubcontractPaymentFormScreen extends ConsumerStatefulWidget {
  final int? initialSubcontractorId;
  const SubcontractPaymentFormScreen({super.key, this.initialSubcontractorId});

  @override
  ConsumerState<SubcontractPaymentFormScreen> createState() =>
      _SubcontractPaymentFormScreenState();
}

class _SubcontractPaymentFormScreenState
    extends ConsumerState<SubcontractPaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int? _selectedSubcontractor;
  int? _selectedProject;
  int? _selectedWorkOrderId;
  PaymentMode _paymentMode = PaymentMode.bank;
  int? _selectedBankAccountId;
  DateTime _date = DateTime.now();
  bool _isAdvance = false;
  bool _isRetentionRelease = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedSubcontractor = widget.initialSubcontractorId;
    _selectedProject = ref.read(selectedProjectIdProvider);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubcontractor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subcontractor.')),
      );
      return;
    }
    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project.')),
      );
      return;
    }

    final cleanAmountStr =
        _amountCtrl.text.replaceAll(',', '').replaceAll(' ', '').trim();
    final amount = double.tryParse(cleanAmountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    // Negative liquidity balance check
    final accountsWithBalances =
        ref.read(bankAccountsWithBalancesProvider).asData?.value;
    if (accountsWithBalances != null && accountsWithBalances.isNotEmpty) {
      final targetAcc = accountsWithBalances
          .cast<BankAccountWithBalance?>()
          .firstWhere(
            (a) => a?.account.id == _selectedBankAccountId,
            orElse: () => null,
          );
      final currentBal = targetAcc != null
          ? targetAcc.currentBalance
          : (ref.read(liquiditySummaryProvider).asData?.value.totalLiquidity ??
              0.0);

      if (currentBal - amount < 0) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                const SizedBox(width: 8),
                const Text('Negative Balance Warning'),
              ],
            ),
            content: Text(
              'This payment of ${CurrencyFormatter.format(amount)} exceeds the balance in ${targetAcc?.account.accountName ?? 'Total Liquidity'} (${CurrencyFormatter.format(currentBal)}).\n\n'
              'Proceed anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange.shade800),
                child: const Text('Proceed Anyway'),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }

    setState(() => _loading = true);
    try {
      await ref.read(subcontractRepositoryProvider).recordSubcontractPayment(
            subcontractorId: _selectedSubcontractor!,
            projectId: _selectedProject!,
            workOrderId: _selectedWorkOrderId,
            amount: amount,
            paymentDate: _date,
            paymentMode: _paymentMode,
            bankAccountId: _selectedBankAccountId,
            isAdvance: _isAdvance,
            isRetentionRelease: _isRetentionRelease,
            referenceNo: _refCtrl.text.isNotEmpty ? _refCtrl.text.trim() : null,
            notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text.trim() : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Subcontractor payment recorded successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.go('/subcontracts');
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
    final subsAsync = ref.watch(subcontractorListProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final workOrdersAsync = ref.watch(workOrdersListProvider);
    final bankAccountsAsync = ref.watch(bankAccountsWithBalancesProvider);
    final theme = Theme.of(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () => context.go('/subcontracts'),
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 750.w),
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
                              onPressed: () => context.go('/subcontracts'),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Record Subcontractor Payment / Advance',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Cash / Bank outflow settlement for piece-rate contracts',
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

                        // ─── Subcontractor & Project ─────────────────────────
                        subsAsync.when(
                          loading: () => const Center(
                              child: LinearProgressIndicator()),
                          error: (e, _) => Text('Error loading contractors: $e'),
                          data: (subs) => DropdownButtonFormField<int>(
                            isExpanded: true,
                            value: subs.any((s) => s.id == _selectedSubcontractor)
                                ? _selectedSubcontractor
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Subcontractor / Contractor Gang *',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items: subs
                                .map((s) => DropdownMenuItem(
                                      value: s.id,
                                      child: Text('${s.name} (${s.trade})',
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedSubcontractor = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // ─── Live Balance Due Info Banner ────────────────────
                        if (_selectedSubcontractor != null)
                          _buildSubcontractorLiveBalanceBanner(context),

                        SizedBox(height: 14.h),

                        Row(
                          children: [
                            Expanded(
                              child: projectsAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                                data: (projects) => DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  value: projects.any((p) => p.id == _selectedProject)
                                      ? _selectedProject
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Target Project *',
                                    prefixIcon: Icon(Icons.folder_outlined),
                                  ),
                                  items: projects
                                      .map((p) => DropdownMenuItem(
                                            value: p.id,
                                            child: Text('${p.code} — ${p.name}',
                                                overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedProject = v),
                                  validator: (v) =>
                                      v == null ? 'Required' : null,
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: workOrdersAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                                data: (wos) {
                                  final filteredWos = wos
                                      .where((w) =>
                                          _selectedSubcontractor == null ||
                                          w.subcontractor.id ==
                                              _selectedSubcontractor)
                                      .toList();

                                  return DropdownButtonFormField<int?>(
                                    value: filteredWos.any((w) =>
                                            w.workOrder.id ==
                                            _selectedWorkOrderId)
                                        ? _selectedWorkOrderId
                                        : null,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Linked Work Order (Optional)',
                                      prefixIcon: Icon(Icons.assignment_outlined),
                                    ),
                                    items: [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text(
                                            'General Running Advance (All Orders)',
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      ...filteredWos.map((w) => DropdownMenuItem(
                                            value: w.workOrder.id,
                                            child: Text(
                                              '${w.workOrder.orderNumber}: ${w.workOrder.title}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )),
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _selectedWorkOrderId = v),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ─── Payment Type Toggles ────────────────────────────
                        Text(
                          'Payment Classification:',
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
                              label: const Text('Bill Settlement'),
                              selected: !_isAdvance && !_isRetentionRelease,
                              onSelected: (_) => setState(() {
                                _isAdvance = false;
                                _isRetentionRelease = false;
                              }),
                            ),
                            ChoiceChip(
                              label: const Text('Site Running Advance'),
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
                        SizedBox(height: 14.h),

                        // ─── Amount & Date ───────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _amountCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Payment Amount (₹) *',
                                  hintText: '50000',
                                  prefixText: '₹ ',
                                  prefixIcon: Icon(Icons.currency_rupee),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Required';
                                  final num = double.tryParse(v.replaceAll(',', ''));
                                  if (num == null || num <= 0) return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Payment Date *',
                                    prefixIcon: Icon(Icons.calendar_today_outlined),
                                  ),
                                  child: Text(
                                    '${_date.day.toString().padLeft(2, '0')}/'
                                    '${_date.month.toString().padLeft(2, '0')}/'
                                    '${_date.year}',
                                    style: TextStyle(
                                        fontSize: 13.sp, fontWeight: FontWeight.w500),
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
                              child: DropdownButtonFormField<PaymentMode>(
                                value: _paymentMode,
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
                                  if (v != null) setState(() => _paymentMode = v);
                                },
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: bankAccountsAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                                data: (accounts) {
                                  final selectedAccountValue = accounts
                                          .any((a) => a.account.id == _selectedBankAccountId)
                                      ? _selectedBankAccountId
                                      : (accounts.isNotEmpty
                                          ? accounts.first.account.id
                                          : null);

                                  return DropdownButtonFormField<int?>(
                                    value: selectedAccountValue,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Paid From Account',
                                      prefixIcon: Icon(Icons.account_balance_outlined),
                                    ),
                                    items: accounts
                                        .map((a) => DropdownMenuItem(
                                              value: a.account.id,
                                              child: Text(
                                                '${a.account.accountName} (${CurrencyFormatter.format(a.currentBalance)})',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedBankAccountId = v),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _refCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Reference / Cheque #',
                                  hintText: 'e.g. IMPS-93821039',
                                  prefixIcon: Icon(Icons.numbers_outlined),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: TextFormField(
                                controller: _notesCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Narration / Notes',
                                  hintText: 'e.g. Paid via UPI to Murugan',
                                  prefixIcon: Icon(Icons.note_alt_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // ─── Actions ─────────────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/subcontracts'),
                              child: const Text('Cancel (Esc)'),
                            ),
                            SizedBox(width: 12.w),
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
                              label: const Text('Confirm Payment (Ctrl+Enter)'),
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

  Widget _buildSubcontractorLiveBalanceBanner(BuildContext context) {
    final summariesAsync = ref.watch(subcontractorSummariesProvider);

    return summariesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (summaries) {
        final summary = summaries.cast<SubcontractorSummary?>().firstWhere(
              (s) => s?.subcontractor.id == _selectedSubcontractor,
              orElse: () => null,
            );

        if (summary == null) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 20.sp, color: const Color(0xFF2563EB)),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  '${summary.subcontractor.name}: Total Certified: ${CurrencyFormatter.format(summary.totalGrossCertified)} • Already Paid: ${CurrencyFormatter.format(summary.totalPaid)} • Retention Held: ${CurrencyFormatter.format(summary.totalRetentionHeld)} • Net Balance Due: ${CurrencyFormatter.format(summary.currentNetDue)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }
}
