import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/deposits/providers/deposit_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class DepositEntryForm extends ConsumerStatefulWidget {
  const DepositEntryForm({super.key});

  @override
  ConsumerState<DepositEntryForm> createState() => _DepositEntryFormState();
}

class _DepositEntryFormState extends ConsumerState<DepositEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();
  final _refCtrl = TextEditingController();

  DepositType _depositType = DepositType.paid; // Default to Deposit Paid (To Govt/Client)
  int? _selectedProject;
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
      if (_depositType == DepositType.paid) {
        await ref.read(depositRepositoryProvider).paySecurityDeposit(
              projectId: _selectedProject!,
              date: _date,
              amount: double.parse(_amountCtrl.text),
              paymentMode: _paymentMode,
              narration: _narrationCtrl.text.isNotEmpty
                  ? _narrationCtrl.text
                  : null,
              referenceNo:
                  _refCtrl.text.isNotEmpty ? _refCtrl.text : null,
            );
      } else {
        await ref.read(depositRepositoryProvider).receiveDeposit(
              projectId: _selectedProject!,
              date: _date,
              amount: double.parse(_amountCtrl.text),
              paymentMode: _paymentMode,
              narration: _narrationCtrl.text.isNotEmpty
                  ? _narrationCtrl.text
                  : null,
              referenceNo:
                  _refCtrl.text.isNotEmpty ? _refCtrl.text : null,
            );
      }
      if (mounted) context.go('/deposits');
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

    final isPaid = _depositType == DepositType.paid;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/deposits'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPaid
                        ? 'Record Security Deposit Paid'
                        : 'Record Client Deposit Received',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segmented toggle: Paid vs Received
            SegmentedButton<DepositType>(
              segments: const [
                ButtonSegment<DepositType>(
                  value: DepositType.paid,
                  label: Text('Deposit Paid (Govt)'),
                  icon: Icon(Icons.outbox_rounded, size: 16),
                ),
                ButtonSegment<DepositType>(
                  value: DepositType.received,
                  label: Text('Deposit Received (Client)'),
                  icon: Icon(Icons.move_to_inbox_rounded, size: 16),
                ),
              ],
              selected: {_depositType},
              onSelectionChanged: (set) {
                if (set.isNotEmpty) {
                  setState(() => _depositType = set.first);
                }
              },
            ),
            const SizedBox(height: 12),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isPaid ? Colors.blue.shade50 : Colors.orange.shade50,
                border: Border.all(
                    color: isPaid
                        ? Colors.blue.shade200
                        : Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: isPaid
                        ? Colors.blue.shade700
                        : Colors.orange.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isPaid
                          ? 'Security deposit paid to Government/Client is a refundable Asset (Outflow). It does NOT affect P&L (₹0) and will be credited back when returned after project completion.'
                          : 'Deposit received from client is recorded as a Liability (Inflow). It does NOT affect P&L (₹0) until adjusted against a bill.',
                      style: TextStyle(
                        color: isPaid
                            ? Colors.blue.shade900
                            : Colors.orange.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        projectsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (projects) {
                            final globalId = ref.watch(selectedProjectIdProvider);
                            return _buildProjectSelector(projects, globalId, theme);
                          },
                        ),
                        const SizedBox(height: 16),
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
                                    return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<PaymentMode?>(
                          value: _paymentMode,
                          isExpanded: true,
                          decoration: const InputDecoration(
                              labelText: 'Payment Mode'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('— Select —', overflow: TextOverflow.ellipsis)),
                            ...PaymentMode.values.map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.displayName, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _paymentMode = v),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _refCtrl,
                          decoration: InputDecoration(
                            labelText: isPaid
                                ? 'EMD / FDR / Challan / Agreement Ref'
                                : 'Work Order / Client Ref',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _narrationCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Narration / Remarks'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/deposits'),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Text(isPaid
                                      ? 'Save Security Deposit'
                                      : 'Save Client Deposit'),
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
              Expanded(
                child: Text(
                  '${activeProject.code} — ${activeProject.name}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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
      isExpanded: true,
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
