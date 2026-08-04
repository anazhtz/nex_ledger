import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/cash_book/providers/cash_book_providers.dart';
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
          narration: _narrationCtrl.text.isNotEmpty
              ? _narrationCtrl.text
              : null,
          referenceNo: _refCtrl.text.isNotEmpty ? _refCtrl.text : null,
        );
      } else {
        await repo.addExpense(
          projectId: _selectedProject!,
          date: _date,
          amount: amount,
          paymentMode: _paymentMode,
          narration: _narrationCtrl.text.isNotEmpty
              ? _narrationCtrl.text
              : null,
          referenceNo: _refCtrl.text.isNotEmpty ? _refCtrl.text : null,
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/cash-book'),
                ),
                const SizedBox(width: 8),
                Text(
                  'New Cash Book Entry',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Type toggle
                        SegmentedButton<TransactionType>(
                          segments: const [
                            ButtonSegment(
                              value: TransactionType.income,
                              label: Text('Income'),
                              icon: Icon(Icons.add_circle_outline),
                            ),
                            ButtonSegment(
                              value: TransactionType.expense,
                              label: Text('Expense'),
                              icon: Icon(Icons.remove_circle_outline),
                            ),
                          ],
                          selected: {_type},
                          onSelectionChanged: (s) =>
                              setState(() => _type = s.first),
                        ),
                        const SizedBox(height: 16),

                        // Project selector (Auto-assigned if active context locked)
                        projectsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (projects) {
                            final globalId = ref.watch(selectedProjectIdProvider);
                            return _buildProjectSelector(projects, globalId, theme);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date + Amount row
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                    suffixIcon: Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18),
                                  ),
                                  child: Text(
                                    '${_date.day.toString().padLeft(2, '0')}/'
                                    '${_date.month.toString().padLeft(2, '0')}/'
                                    '${_date.year}',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _amountCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Amount (₹) *',
                                  prefixText: '₹ ',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Required';
                                  if (double.tryParse(v) == null)
                                    return 'Invalid amount';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Payment mode
                        DropdownButtonFormField<PaymentMode?>(
                          value: _paymentMode,
                          decoration: const InputDecoration(
                              labelText: 'Payment Mode'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('— Select —')),
                            ...PaymentMode.values.map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.displayName),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _paymentMode = v),
                        ),
                        const SizedBox(height: 16),

                        // Narration
                        TextFormField(
                          controller: _narrationCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Narration'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // Reference no
                        TextFormField(
                          controller: _refCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Reference / Voucher No.'),
                        ),
                        const SizedBox(height: 24),

                        // Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/cash-book'),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Save Entry'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSelector(
      List<Project> projects, int? globalId, ThemeData theme) {
    if (globalId != null) {
      final activeProject =
          projects.where((p) => p.id == globalId).firstOrNull;
      if (activeProject != null) {
        _selectedProject = activeProject.id;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_special_rounded,
                  color: theme.colorScheme.primary, size: 20),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
      decoration:
          const InputDecoration(labelText: 'Select Target Project *'),
      items: projects
          .map((p) => DropdownMenuItem(
                value: p.id,
                child: Text('${p.code} — ${p.name}',
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedProject = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }
}
