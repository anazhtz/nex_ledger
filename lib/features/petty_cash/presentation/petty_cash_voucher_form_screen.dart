import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/budget_warning_banner.dart';
import 'package:nex_ledger/features/petty_cash/providers/petty_cash_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class PettyCashVoucherFormScreen extends ConsumerStatefulWidget {
  final int? initialWalletId;
  final int? initialProjectId;

  const PettyCashVoucherFormScreen({
    super.key,
    this.initialWalletId,
    this.initialProjectId,
  });

  @override
  ConsumerState<PettyCashVoucherFormScreen> createState() =>
      _PettyCashVoucherFormScreenState();
}

class _PettyCashVoucherFormScreenState
    extends ConsumerState<PettyCashVoucherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();

  int? _selectedWalletId;
  int? _selectedProjectId;
  String _selectedCategory = kStandardPettyCashCategories.first.name;
  BudgetCostHead _costHead = BudgetCostHead.labour;

  final _amountCtrl = TextEditingController();
  final _voucherNumCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();
  final _verifiedByCtrl = TextEditingController(text: 'Site Engineer / PM');
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedWalletId = widget.initialWalletId;
    _selectedProjectId = widget.initialProjectId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _voucherNumCtrl.dispose();
    _narrationCtrl.dispose();
    _verifiedByCtrl.dispose();
    super.dispose();
  }

  double get _enteredAmount =>
      double.tryParse(_amountCtrl.text.trim().replaceAll(',', '')) ?? 0.0;

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
        const SnackBar(content: Text('Please select a supervisor.')),
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
      final repo = ref.read(pettyCashRepositoryProvider);

      await repo.recordExpenseVoucher(
        walletId: _selectedWalletId!,
        projectId: _selectedProjectId!,
        date: _date,
        amount: _enteredAmount,
        category: _selectedCategory,
        costHead: _costHead,
        voucherNumber: _voucherNumCtrl.text.trim().isNotEmpty
            ? _voucherNumCtrl.text.trim()
            : null,
        narration: _narrationCtrl.text.trim(),
        verifiedBy: _verifiedByCtrl.text.trim().isNotEmpty
            ? _verifiedByCtrl.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Site expense voucher recorded & booked into Project P&L!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.go('/petty-cash');
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
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(allWalletsProvider);
    final projectsAsync = ref.watch(projectListProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go('/petty-cash'),
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
                              onPressed: () => context.go('/petty-cash'),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Record Site Petty Cash Expense Voucher',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Deducts from supervisor cash float and books expense into Project P&L and Budget',
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
                        SizedBox(height: 18.h),

                        // ─── Supervisor & Project Selectors ───────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Voucher Date *',
                                    prefixIcon: Icon(Icons.calendar_today_outlined),
                                  ),
                                  child: Text(
                                    '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 3,
                              child: walletsAsync.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (e, _) => Text('Error: $e'),
                                data: (wallets) => DropdownButtonFormField<int?>(
                                  value: _selectedWalletId,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Spent by Supervisor / Float *',
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
                                          '${w.wallet.supervisorName} (Float Balance: ${CurrencyFormatter.format(w.currentUnspentCashBalance)})',
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
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Target Project Dropdown ─────────────────────────
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
                                labelText: 'Project Site to Charge Expense *',
                                prefixIcon: Icon(Icons.folder_outlined),
                              ),
                              selectedItemBuilder: (context) => [
                                const Text('— Select Project Site —', overflow: TextOverflow.ellipsis),
                                ...validProjects.map(
                                  (p) => Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                                ),
                              ],
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('— Select Project Site —', overflow: TextOverflow.ellipsis),
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
                        SizedBox(height: 16.h),

                        // ─── Preset Category Chips ───────────────────────────
                        Text(
                          'Expense Category:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: kStandardPettyCashCategories.map((cat) {
                              final isSelected = _selectedCategory == cat.name;
                              return Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: ChoiceChip(
                                  label: Text(cat.name),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF2563EB),
                                  labelStyle: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : const Color(0xFF334155),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedCategory = cat.name;
                                        _costHead = cat.defaultCostHead;
                                        if (_narrationCtrl.text.isEmpty) {
                                          _narrationCtrl.text = cat.name;
                                        }
                                      });
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // ─── Cost Head & Amount ──────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<BudgetCostHead>(
                                value: _costHead,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Budget Cost Head *',
                                  prefixIcon: Icon(Icons.pie_chart_outline),
                                ),
                                selectedItemBuilder: (context) => BudgetCostHead.values
                                    .map((h) => Text(h.displayName, overflow: TextOverflow.ellipsis))
                                    .toList(),
                                items: BudgetCostHead.values
                                    .map(
                                      (h) => DropdownMenuItem(
                                        value: h,
                                        child: Text(h.displayName, overflow: TextOverflow.ellipsis),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (h) {
                                  if (h != null) setState(() => _costHead = h);
                                },
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _amountCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Voucher Amount (₹) *',
                                  hintText: '2500',
                                  prefixText: '₹ ',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Required';
                                  final parsed = double.tryParse(v.trim().replaceAll(',', ''));
                                  if (parsed == null || parsed <= 0) return 'Enter valid amount';
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _voucherNumCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Receipt / Voucher #',
                                  hintText: 'VCH-089',
                                  prefixIcon: Icon(Icons.tag_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Real-Time Budget Warning Banner ─────────────────
                        if (_selectedProjectId != null && _enteredAmount > 0)
                          BudgetWarningBanner(
                            projectId: _selectedProjectId,
                            costHead: _costHead,
                            addedAmount: _enteredAmount,
                          ),

                        SizedBox(height: 14.h),

                        // ─── Narration & Verified By ─────────────────────────
                        TextFormField(
                          controller: _narrationCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Expense Narration / Description *',
                            hintText: 'e.g. 50 packs tea and snacks for night slab casting overtime workers',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 14.h),

                        TextFormField(
                          controller: _verifiedByCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Verified / Approved By',
                            hintText: 'Project Manager / Site Engineer',
                            prefixIcon: Icon(Icons.verified_user_outlined),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ─── Submit Buttons ──────────────────────────────────
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 12.w,
                          runSpacing: 8.h,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/petty-cash'),
                              child: const Text('Cancel'),
                            ),
                            FilledButton.icon(
                              onPressed: _loading ? null : _submit,
                              icon: _loading
                                  ? SizedBox(
                                      width: 16.sp,
                                      height: 16.sp,
                                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check, size: 18),
                              label: const Text('Save Expense Voucher'),
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
}
