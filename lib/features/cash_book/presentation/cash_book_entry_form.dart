import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/cash_book/providers/cash_book_providers.dart';
import 'package:nex_ledger/features/expense_categories/providers/expense_category_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class CashBookEntryForm extends ConsumerStatefulWidget {
  const CashBookEntryForm({super.key});

  @override
  ConsumerState<CashBookEntryForm> createState() => _CashBookEntryFormState();
}

class _CashBookEntryFormState extends ConsumerState<CashBookEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();
  final _refCtrl = TextEditingController();

  int? _selectedProject;
  TransactionType _type = TransactionType.income;
  PaymentMode? _paymentMode;
  DateTime _date = DateTime.now();
  bool _loading = false;

  // Category selection (flat single-dropdown)
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedProject = ref.read(selectedProjectIdProvider);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _narrationCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final repo = ref.read(cashBookRepositoryProvider);
      final amount = double.parse(_amountCtrl.text);
      if (_type == TransactionType.income) {
        await repo.addIncome(
          projectId: _selectedProject!,
          date: _date,
          amount: amount,
          paymentMode: _paymentMode,
          narration: _narrationCtrl.text.isNotEmpty ? _narrationCtrl.text : null,
          referenceNo: _refCtrl.text.isNotEmpty ? _refCtrl.text : null,
        );
      } else {
        await repo.addExpense(
          projectId: _selectedProject!,
          date: _date,
          amount: amount,
          paymentMode: _paymentMode,
          narration: _narrationCtrl.text.isNotEmpty ? _narrationCtrl.text : null,
          referenceNo: _refCtrl.text.isNotEmpty ? _refCtrl.text : null,
          expenseCategoryId: _selectedCategoryId,
        );
      }
      if (mounted) context.go('/cash-book');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectListProvider);
    final categoriesAsync = ref.watch(expenseCategoryListProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () => context.go('/cash-book'),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 680.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go('/cash-book'),
                      tooltip: 'Back to Cash Book',
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Cash Book Entry',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Record an income or expense transaction',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Form Container Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type toggle
                          Center(
                            child: SegmentedButton<TransactionType>(
                              segments: const [
                                ButtonSegment(
                                  value: TransactionType.income,
                                  label: Text('Income (+)', style: TextStyle(fontWeight: FontWeight.w600)),
                                  icon: Icon(Icons.add_circle_rounded, color: Color(0xFF10B981)),
                                ),
                                ButtonSegment(
                                  value: TransactionType.expense,
                                  label: Text('Expense (−)', style: TextStyle(fontWeight: FontWeight.w600)),
                                  icon: Icon(Icons.remove_circle_rounded, color: Color(0xFFEF4444)),
                                ),
                              ],
                              selected: {_type},
                              onSelectionChanged: (s) {
                                setState(() {
                                  _type = s.first;
                                  _selectedCategoryId = null;
                                });
                              },
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.comfortable,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Project selector
                          projectsAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (projects) {
                              final globalId = ref.watch(selectedProjectIdProvider);
                              return _buildProjectSelector(projects, globalId, theme);
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Date + Amount row
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _pickDate,
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Transaction Date',
                                      prefixIcon: Icon(Icons.calendar_month_rounded, size: 20),
                                    ),
                                    child: Text(
                                      '${_date.day.toString().padLeft(2, '0')}/'
                                      '${_date.month.toString().padLeft(2, '0')}/'
                                      '${_date.year}',
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: TextFormField(
                                  controller: _amountCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Amount (₹) *',
                                    prefixIcon: Icon(Icons.currency_rupee_rounded, size: 20),
                                  ),
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Required';
                                    if (double.tryParse(v) == null) return 'Invalid amount';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Payment mode
                          DropdownButtonFormField<PaymentMode?>(
                            value: _paymentMode,
                            decoration: const InputDecoration(
                              labelText: 'Payment Mode',
                              prefixIcon: Icon(Icons.payment_rounded, size: 20),
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('— Select Payment Mode —')),
                              ...PaymentMode.values.map(
                                (m) => DropdownMenuItem(value: m, child: Text(m.displayName)),
                              ),
                            ],
                            onChanged: (v) => setState(() => _paymentMode = v),
                          ),
                          SizedBox(height: 16.h),

                          // ─── Expense Category Picker (only shown for Expense) ───
                          if (_type == TransactionType.expense) ...[
                            categoriesAsync.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (categories) =>
                                  _buildCategoryPicker(categories, theme),
                            ),
                            SizedBox(height: 16.h),
                          ],

                          // Narration
                          TextFormField(
                            controller: _narrationCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Narration / Particulars',
                              prefixIcon: Icon(Icons.notes_rounded, size: 20),
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(height: 16.h),

                          // Reference no
                          TextFormField(
                            controller: _refCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Reference / Voucher No.',
                              prefixIcon: Icon(Icons.receipt_long_rounded, size: 20),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => context.go('/cash-book'),
                                child: const Text('Cancel'),
                              ),
                              SizedBox(width: 12.w),
                              FilledButton.icon(
                                onPressed: _loading ? null : _submit,
                                icon: _loading
                                    ? SizedBox(
                                        width: 16.w,
                                        height: 16.h,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(Icons.save_rounded, size: 18.sp),
                                label: Text(_loading ? 'Saving...' : 'Save Cash Book Entry'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }

  /// Single-dropdown expense category picker (flat 18-category list).
  Widget _buildCategoryPicker(List<ExpenseCategory> categories, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          Icon(Icons.label_rounded, size: 16.sp, color: const Color(0xFFEA580C)),
          SizedBox(width: 8.w),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Expense Category (optional)',
                labelStyle: const TextStyle(
                    color: Color(0xFFEA580C), fontWeight: FontWeight.w600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Color(0xFFFED7AA)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Color(0xFFFED7AA)),
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('— None (Uncategorised) —',
                      style: TextStyle(color: Color(0xFF94A3B8))),
                ),
                ...categories.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.subCategory,
                          overflow: TextOverflow.ellipsis),
                    )),
              ],
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSelector(
      List<Project> projects, int? globalId, ThemeData theme) {
    if (globalId != null) {
      final activeProject = projects.where((p) => p.id == globalId).firstOrNull;
      if (activeProject != null) {
        _selectedProject = activeProject.id;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_special_rounded, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Target Project: ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${activeProject.code} — ${activeProject.name}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Auto-Assigned',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return DropdownButtonFormField<int>(
      value: _selectedProject,
      decoration: const InputDecoration(labelText: 'Select Target Project *'),
      items: projects
          .map((p) => DropdownMenuItem(
                value: p.id,
                child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedProject = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }
}
