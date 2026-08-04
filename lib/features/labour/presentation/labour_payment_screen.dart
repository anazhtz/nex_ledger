import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/labour/data/labour_repository.dart';
import 'package:nex_ledger/features/labour/providers/labour_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class LabourPaymentScreen extends ConsumerStatefulWidget {
  const LabourPaymentScreen({super.key});

  @override
  ConsumerState<LabourPaymentScreen> createState() =>
      _LabourPaymentScreenState();
}

class _LabourPaymentScreenState extends ConsumerState<LabourPaymentScreen> {
  int? _selectedProject;
  int? _selectedWorker;
  DateTime _from = DateTime.now().subtract(const Duration(days: 29));
  DateTime _to = DateTime.now();
  WorkerPaymentSummary? _summary;
  bool _loadingSummary = false;
  bool _paying = false;

  PaymentMode? _paymentMode;
  final _narrationCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedProject = ref.read(selectedProjectIdProvider);
  }

  @override
  void dispose() {
    _narrationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    if (_selectedProject == null || _selectedWorker == null) return;
    setState(() => _loadingSummary = true);
    try {
      final summary =
          await ref.read(labourRepositoryProvider).getPaymentSummary(
                _selectedWorker!,
                _selectedProject!,
                _from,
                _to,
              );
      setState(() => _summary = summary);
    } finally {
      setState(() => _loadingSummary = false);
    }
  }

  Future<void> _recordPayment() async {
    if (_summary == null || _selectedProject == null) return;
    setState(() => _paying = true);
    try {
      await ref.read(labourRepositoryProvider).recordPayment(
            projectId: _selectedProject!,
            date: DateTime.now(),
            amount: _summary!.amountDue,
            paymentMode: _paymentMode,
            narration: _narrationCtrl.text.isNotEmpty
                ? _narrationCtrl.text
                : 'Labour payment — ${_summary!.worker.name}',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment of ${CurrencyFormatter.format(_summary!.amountDue)} recorded for ${_summary!.worker.name}',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
        setState(() => _summary = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom)
          _from = picked;
        else
          _to = picked;
        _summary = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(activeProjectsProvider);
    final workersAsync = ref.watch(workerListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Labour Payment',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Calculate and record worker payments based on attendance',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Worker & Period',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),

                      // Project (Auto-assigned if active context locked)
                      projectsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (projects) {
                          final globalId = ref.watch(selectedProjectIdProvider);
                          return _buildProjectSelector(
                              projects, globalId, theme);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Worker
                      workersAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (workers) => DropdownButtonFormField<int?>(
                          value: _selectedWorker,
                          decoration:
                              const InputDecoration(labelText: 'Worker'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('Select Worker')),
                            ...workers.map((w) => DropdownMenuItem(
                                  value: w.id,
                                  child: Text(
                                      '${w.name} — ₹${w.dailyRate.toStringAsFixed(0)}/day'),
                                )),
                          ],
                          onChanged: (v) => setState(() {
                            _selectedWorker = v;
                            _summary = null;
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date range
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'From',
                                  suffixIcon: Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16),
                                ),
                                child: Text(DateFormatter.format(_from)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'To',
                                  suffixIcon: Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16),
                                ),
                                child: Text(DateFormatter.format(_to)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.tonal(
                            onPressed: _loadSummary,
                            child: const Text('Calculate'),
                          ),
                        ],
                      ),

                      if (_loadingSummary)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: LinearProgressIndicator(),
                        ),

                      if (_summary != null) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text('Payment Summary',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _SummaryRow(
                            label: 'Worker', value: _summary!.worker.name),
                        _SummaryRow(
                            label: 'Daily Rate',
                            value: CurrencyFormatter.format(
                                _summary!.worker.dailyRate)),
                        _SummaryRow(
                            label: 'Effective Days',
                            value: _summary!.effectiveDays.toStringAsFixed(1)),
                        const Divider(height: 24),
                        _SummaryRow(
                          label: 'Amount Due',
                          value: CurrencyFormatter.format(_summary!.amountDue),
                          bold: true,
                          valueColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),

                        // Payment mode
                        DropdownButtonFormField<PaymentMode?>(
                          value: _paymentMode,
                          decoration:
                              const InputDecoration(labelText: 'Payment Mode'),
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
                          onChanged: (v) => setState(() => _paymentMode = v),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _narrationCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Narration'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _paying || _summary!.amountDue <= 0
                                ? null
                                : _recordPayment,
                            icon: const Icon(Icons.payments_outlined),
                            label: _paying
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(
                                    'Record Payment of ${CurrencyFormatter.format(_summary!.amountDue)}'),
                          ),
                        ),
                      ],
                    ],
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
      final activeProject = projects.where((p) => p.id == globalId).firstOrNull;
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

    return DropdownButtonFormField<int?>(
      value: _selectedProject,
      decoration: const InputDecoration(labelText: 'Select Project'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Select Project')),
        ...projects.map((p) => DropdownMenuItem(
              value: p.id,
              child: Text(p.name),
            )),
      ],
      onChanged: (v) => setState(() {
        _selectedProject = v;
        _summary = null;
      }),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  const _SummaryRow(
      {required this.label,
      required this.value,
      this.bold = false,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
