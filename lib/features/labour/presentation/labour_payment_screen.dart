import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/data/bank_account_repository.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/cash_book/providers/cash_book_providers.dart';
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
  int? _selectedBankAccountId;
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
    if (_selectedWorker == null || _selectedProject == null) return;
    setState(() => _loadingSummary = true);
    try {
      final summary = await ref.read(labourRepositoryProvider).getPaymentSummary(
            _selectedWorker!,
            _selectedProject!,
            _from,
            _to,
          );
      setState(() => _summary = summary);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating summary: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingSummary = false);
    }
  }

  Future<void> _recordPayment() async {
    if (_summary == null || _selectedProject == null || _selectedWorker == null) {
      return;
    }

    if (_summary!.amountDue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No outstanding wage balance due for this worker.')),
      );
      return;
    }

    // Negative balance check on wage payout
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

      if (currentBal - _summary!.amountDue < 0) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange.shade800),
                const SizedBox(width: 8),
                const Text('Negative Balance Warning'),
              ],
            ),
            content: Text(
              'This wage payment of ${CurrencyFormatter.format(_summary!.amountDue)} exceeds your current balance in ${targetAcc?.account.accountName ?? 'Total Liquidity'} (${CurrencyFormatter.format(currentBal)}).\n\n'
              'Recording this will make your balance negative (${CurrencyFormatter.format(currentBal - _summary!.amountDue)}).\n\n'
              'Do you wish to proceed anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel / Change Account'),
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

    setState(() => _paying = true);
    try {
      await ref.read(labourRepositoryProvider).recordPayment(
            workerId: _selectedWorker!,
            projectId: _selectedProject!,
            date: DateTime.now(),
            amount: _summary!.amountDue,
            paymentMode: _paymentMode ?? PaymentMode.cash,
            bankAccountId: _selectedBankAccountId,
            narration: _narrationCtrl.text.isEmpty ? null : _narrationCtrl.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Labour payment of ${CurrencyFormatter.format(_summary!.amountDue)} recorded!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        ref.invalidate(cashBalanceProvider);
        await _loadSummary();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording payment: $e')),
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
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
        _summary = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(activeProjectsProvider);
    final workersAsync = ref.watch(workerListProvider);
    final accountsAsync = ref.watch(bankAccountsWithBalancesProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _recordPayment,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _recordPayment,
        const SingleActivator(LogicalKeyboardKey.escape): () => context.go('/labour/attendance'),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
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
                Expanded(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
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
                                Text('All-Time Running Balance Summary',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                _SummaryRow(
                                    label: 'Worker Name', value: _summary!.worker.name),
                                _SummaryRow(
                                    label: 'Daily Wage Rate',
                                    value: '${CurrencyFormatter.format(_summary!.worker.dailyRate)} / day'),
                                _SummaryRow(
                                    label: 'Total Days Worked (All-Time)',
                                    value: '${_summary!.totalDaysWorked.toStringAsFixed(1)} days'),
                                _SummaryRow(
                                    label: 'Gross Earned Wages (All-Time)',
                                    value: CurrencyFormatter.format(_summary!.totalEarnedWages)),
                                _SummaryRow(
                                    label: 'Less: Total Payments Disbursed (All-Time)',
                                    value: '-${CurrencyFormatter.format(_summary!.totalPaymentsPaid)}',
                                    valueColor: const Color(0xFFEF4444)),
                                const Divider(height: 24),
                                _SummaryRow(
                                  label: 'Net Outstanding Wage Balance Due',
                                  value: CurrencyFormatter.format(_summary!.amountDue),
                                  bold: true,
                                  valueColor: const Color(0xFF4F46E5),
                                ),
                                const SizedBox(height: 16),

                                // Payment mode
                                DropdownButtonFormField<PaymentMode?>(
                                  value: _paymentMode,
                                  decoration:
                                      const InputDecoration(labelText: 'Payment Mode'),
                                  items: [
                                    const DropdownMenuItem(
                                        value: null, child: Text('— Select Mode —')),
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

                                // Bank / Cash Account
                                accountsAsync.when(
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                  data: (accounts) {
                                    if (accounts.isEmpty) return const SizedBox.shrink();
                                    return Column(
                                      children: [
                                        DropdownButtonFormField<int?>(
                                          value: _selectedBankAccountId,
                                          decoration: const InputDecoration(
                                            labelText: 'Paid From (Account)',
                                            prefixIcon: Icon(Icons.account_balance_outlined),
                                          ),
                                          items: [
                                            const DropdownMenuItem(
                                              value: null,
                                              child: Text('— Auto (Default) —'),
                                            ),
                                            ...accounts.map(
                                              (a) => DropdownMenuItem(
                                                value: a.account.id,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${a.account.accountName} (${a.account.isCashAccount ? 'Cash' : 'Bank'})',
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '• ${CurrencyFormatter.format(a.currentBalance)}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: a.currentBalance < 0
                                                            ? Colors.red.shade700
                                                            : Colors.green.shade700,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                          onChanged: (v) => setState(
                                              () => _selectedBankAccountId = v),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    );
                                  },
                                ),

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
                  ),
                ),
              ],
            ),
          ),
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
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = bold
        ? theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.colorScheme.onSurface,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}
