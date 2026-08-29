import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/client_billing/providers/client_billing_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class ClientRaBillFormScreen extends ConsumerStatefulWidget {
  final int? initialProjectId;
  const ClientRaBillFormScreen({super.key, this.initialProjectId});

  @override
  ConsumerState<ClientRaBillFormScreen> createState() =>
      _ClientRaBillFormScreenState();
}

class _ClientRaBillFormScreenState
    extends ConsumerState<ClientRaBillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _billNumCtrl = TextEditingController();
  final _stageCtrl = TextEditingController();
  final _grossCtrl = TextEditingController();
  final _retentionPctCtrl = TextEditingController(text: '5.0');
  final _advanceDeductCtrl = TextEditingController(text: '0');
  final _tdsDeductCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();

  int? _selectedProjectId;
  DateTime _billDate = DateTime.now();
  DateTime? _dueDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedProjectId =
        widget.initialProjectId ?? ref.read(selectedProjectIdProvider);
    _billNumCtrl.text =
        'RA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  void dispose() {
    _billNumCtrl.dispose();
    _stageCtrl.dispose();
    _grossCtrl.dispose();
    _retentionPctCtrl.dispose();
    _advanceDeductCtrl.dispose();
    _tdsDeductCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _grossAmount =>
      double.tryParse(_grossCtrl.text.replaceAll(',', '').trim()) ?? 0.0;

  double get _retentionPct =>
      double.tryParse(_retentionPctCtrl.text.replaceAll(',', '').trim()) ?? 5.0;

  double get _retentionAmount => _grossAmount * (_retentionPct / 100.0);

  double get _advanceDeduction =>
      double.tryParse(_advanceDeductCtrl.text.replaceAll(',', '').trim()) ?? 0.0;

  double get _tdsDeduction =>
      double.tryParse(_tdsDeductCtrl.text.replaceAll(',', '').trim()) ?? 0.0;

  double get _netCertifiedAmount =>
      _grossAmount - _retentionAmount - _advanceDeduction - _tdsDeduction;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project.')),
      );
      return;
    }

    if (_grossAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive gross bill amount.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(clientBillingRepositoryProvider).raiseClientRaBill(
            projectId: _selectedProjectId!,
            billNumber: _billNumCtrl.text.trim(),
            billDate: _billDate,
            stageOrDescription: _stageCtrl.text.trim(),
            grossAmount: _grossAmount,
            retentionPercentage: _retentionPct,
            advanceDeduction: _advanceDeduction,
            taxOrTdsDeduction: _tdsDeduction,
            dueDate: _dueDate,
            notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text.trim() : null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Client RA Bill certified & added to project revenue!'),
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
    final theme = Theme.of(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () => context.go('/client-billing'),
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
                                    'Raise Client Running Account (RA) Bill',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Progressive stage invoice for certified construction work',
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
                                  if (v != null) {
                                    final p = validProjects
                                        .firstWhere((item) => item.id == v);
                                    _retentionPctCtrl.text = p
                                        .clientRetentionPercentage
                                        .toString();
                                  }
                                });
                              },
                              validator: (v) => v == null ? 'Required' : null,
                            );
                          },
                        ),
                        SizedBox(height: 14.h),

                        // ─── Project Revenue Progress Banner ─────────────────
                        if (_selectedProjectId != null)
                          _buildSelectedProjectProgressBanner(context),

                        SizedBox(height: 14.h),

                        // ─── Bill # & Dates ──────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _billNumCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'RA Bill # *',
                                  hintText: 'RA-01',
                                  prefixIcon: Icon(Icons.tag_outlined),
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: InkWell(
                                onTap: _pickBillDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Invoice / Bill Date *',
                                    prefixIcon: Icon(Icons.calendar_today_outlined),
                                  ),
                                  child: Text(
                                    '${_billDate.day.toString().padLeft(2, '0')}/'
                                    '${_billDate.month.toString().padLeft(2, '0')}/'
                                    '${_billDate.year}',
                                    style: TextStyle(
                                        fontSize: 13.sp, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _stageCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Work Stage / Milestone Description *',
                                  hintText:
                                      'e.g. Ground Floor RCC Columns & 1st Slab Concreting Completed',
                                  prefixIcon: Icon(Icons.assignment_turned_in_outlined),
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: _pickDueDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Payment Due Date',
                                    prefixIcon: Icon(Icons.event_available_outlined),
                                  ),
                                  child: Text(
                                    _dueDate != null
                                        ? '${_dueDate!.day.toString().padLeft(2, '0')}/'
                                            '${_dueDate!.month.toString().padLeft(2, '0')}/'
                                            '${_dueDate!.year}'
                                        : 'Immediate / Not set',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: _dueDate != null
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                      color: _dueDate != null
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Gross Bill & Deductions ─────────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _grossCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Gross Certified Bill (₹) *',
                                  hintText: '3500000',
                                  prefixText: '₹ ',
                                  prefixIcon: Icon(Icons.currency_rupee),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (_) => setState(() {}),
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
                              flex: 2,
                              child: TextFormField(
                                controller: _retentionPctCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Retention %',
                                  suffixText: '%',
                                  prefixIcon: Icon(Icons.lock_clock_outlined),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _advanceDeductCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Mobilization Advance Recovery (₹)',
                                  hintText: '0',
                                  prefixText: '₹ ',
                                  prefixIcon: Icon(Icons.remove_circle_outline),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: TextFormField(
                                controller: _tdsDeductCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'TDS / Withholding Tax Deducted (₹)',
                                  hintText: '0',
                                  prefixText: '₹ ',
                                  prefixIcon: Icon(Icons.percent_rounded),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ─── Live Calculation Card ───────────────────────────
                        if (_grossAmount > 0) _buildLiveCalculationCard(context),

                        SizedBox(height: 14.h),

                        TextFormField(
                          controller: _notesCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Billing Notes & Terms',
                            hintText:
                                'e.g. Certified by Architect Mr. Anandan on 28th Aug',
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
                                  'Raising this Client RA Bill certifies progressive revenue in Project P&L and creates an Account Receivable asset. Physical cash is moved when you record the client payment receipt.',
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
                              label: const Text('Certify & Save RA Bill (Ctrl+Enter)'),
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

  Widget _buildSelectedProjectProgressBanner(BuildContext context) {
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
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.w,
                runSpacing: 4.h,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business_center_rounded,
                          size: 18.sp, color: const Color(0xFF2563EB)),
                      SizedBox(width: 8.w),
                      Text(
                        'Client: ${progress.project.clientName ?? 'Direct Client'}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Contract Sum: ${CurrencyFormatter.format(progress.clientContractValue)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'Already Invoiced: ${CurrencyFormatter.format(progress.totalGrossBilled)} (${progress.billingProgressPercentage.toStringAsFixed(1)}%) • Remaining Unbilled: ${CurrencyFormatter.format(progress.unbilledContractValue)} • Collected: ${CurrencyFormatter.format(progress.totalClientReceipts)} • Pending: ${CurrencyFormatter.format(progress.clientOutstandingReceivables)}',
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF1E40AF)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveCalculationCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 18.sp, color: const Color(0xFF059669)),
              SizedBox(width: 8.w),
              Text(
                'Certified RA Bill Breakdown:',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF065F46),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gross Work Certified:',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF047857))),
              Text(CurrencyFormatter.format(_grossAmount),
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF065F46))),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Client Retention Held (${_retentionPct.toStringAsFixed(1)}%):',
                  style: TextStyle(fontSize: 12.sp, color: Colors.orange.shade900)),
              Text('- ${CurrencyFormatter.format(_retentionAmount)}',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900)),
            ],
          ),
          if (_advanceDeduction > 0) ...[
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mobilization Advance Recovery:',
                    style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade900)),
                Text('- ${CurrencyFormatter.format(_advanceDeduction)}',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900)),
              ],
            ),
          ],
          if (_tdsDeduction > 0) ...[
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TDS / Tax Withheld:',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
                Text('- ${CurrencyFormatter.format(_tdsDeduction)}',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B))),
              ],
            ),
          ],
          const Divider(color: Color(0xFFA7F3D0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net Certified Amount Due from Client:',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF065F46))),
              Text(CurrencyFormatter.format(_netCertifiedAmount),
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF065F46))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickBillDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _billDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _billDate = picked);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _billDate.add(const Duration(days: 15)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }
}
