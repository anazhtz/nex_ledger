import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/labour/providers/labour_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class WorkerDetailScreen extends ConsumerWidget {
  final int workerId;
  const WorkerDetailScreen({super.key, required this.workerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(workerLedgerSummaryProvider(workerId));
    final attendanceAsync = ref.watch(workerAttendanceAllProvider(workerId));
    final paymentsAsync = ref.watch(workerPaymentsProvider(workerId));
    final projectsAsync = ref.watch(projectListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (summary) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back + Title ─────────────────────────────────────────────
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.worker.name,
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Row(
                        children: [
                          if (summary.worker.workerCode != null)
                            _Badge(
                                summary.worker.workerCode!,
                                theme.colorScheme.primaryContainer,
                                theme.colorScheme.onPrimaryContainer),
                          if (summary.worker.trade != null) ...[
                            const SizedBox(width: 8),
                            _Badge(
                                summary.worker.trade!,
                                theme.colorScheme.secondaryContainer,
                                theme.colorScheme.onSecondaryContainer),
                          ],
                          const SizedBox(width: 8),
                          Text(
                            '${CurrencyFormatter.format(summary.worker.dailyRate)}/day',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Summary Strip ────────────────────────────────────────────
              _SummaryStrip(summary: summary, theme: theme),
              const SizedBox(height: 20),

              // ── Tables in Row ────────────────────────────────────────────
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Attendance History (left, 60%)
                    Expanded(
                      flex: 6,
                      child: attendanceAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (records) => projectsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (projects) {
                            final projectMap = {
                              for (final p in projects) p.id: p.name
                            };
                            return _AttendanceTable(
                              records: records,
                              projectMap: projectMap,
                              dailyRate: summary.worker.dailyRate,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Payment History (right, 40%)
                    Expanded(
                      flex: 4,
                      child: paymentsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (payments) => projectsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (projects) {
                            final projectMap = {
                              for (final p in projects) p.id: p.name
                            };
                            return _PaymentHistoryTable(
                              payments: payments,
                              projectMap: projectMap,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary strip
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  final WorkerLedgerSummary summary;
  final ThemeData theme;
  const _SummaryStrip({required this.summary, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryTile(
          label: 'Days Worked',
          value: summary.totalDaysWorked.toStringAsFixed(1),
          icon: Icons.calendar_today_rounded,
          color: Colors.blue.shade700,
          bg: Colors.blue.shade50,
        ),
        const SizedBox(width: 12),
        _SummaryTile(
          label: 'Total Earned',
          value: CurrencyFormatter.format(summary.totalEarned),
          icon: Icons.account_balance_rounded,
          color: Colors.green.shade700,
          bg: Colors.green.shade50,
        ),
        const SizedBox(width: 12),
        _SummaryTile(
          label: 'Total Paid',
          value: CurrencyFormatter.format(summary.totalPaid),
          icon: Icons.check_circle_rounded,
          color: Colors.teal.shade700,
          bg: Colors.teal.shade50,
        ),
        const SizedBox(width: 12),
        _SummaryTile(
          label: 'Balance Due',
          value: CurrencyFormatter.format(summary.balanceDue),
          icon: summary.balanceDue > 0
              ? Icons.warning_amber_rounded
              : Icons.check_circle_rounded,
          color: summary.balanceDue > 0
              ? Colors.red.shade700
              : Colors.green.shade700,
          bg: summary.balanceDue > 0
              ? Colors.red.shade50
              : Colors.green.shade50,
          bold: true,
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool bold;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: color)),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight:
                        bold ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Attendance history table
// ─────────────────────────────────────────────────────────────────────────────

class _AttendanceTable extends StatelessWidget {
  final List<AttendanceWithWorker> records;
  final Map<int, String> projectMap;
  final double dailyRate;
  const _AttendanceTable(
      {required this.records,
      required this.projectMap,
      required this.dailyRate});

  @override
  Widget build(BuildContext context) {
    return DataTableCard(
      title: 'Attendance History (${records.length} entries)',
      emptyMessage: 'No attendance recorded yet.',
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Project')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Eff. Days'), numeric: true),
        DataColumn(label: Text('Day Earnings'), numeric: true),
      ],
      rows: records.map((r) {
        final fraction = r.attendance.status.payFraction;
        final earning = fraction * dailyRate;
        return DataRow(cells: [
          DataCell(Text(DateFormatter.format(r.attendance.date))),
          DataCell(Text(
            projectMap[r.attendance.projectId] ?? '—',
            overflow: TextOverflow.ellipsis,
          )),
          DataCell(_AttendanceBadge(r.attendance.status)),
          DataCell(Text(fraction.toStringAsFixed(1))),
          DataCell(Text(
            CurrencyFormatter.format(earning),
            style: TextStyle(
              color: earning > 0 ? Colors.green.shade700 : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          )),
        ]);
      }).toList(),
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  final AttendanceStatus status;
  const _AttendanceBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, bg, icon) = switch (status) {
      AttendanceStatus.present => (
          Colors.green.shade700,
          Colors.green.shade50,
          Icons.check_circle_rounded
        ),
      AttendanceStatus.halfDay => (
          Colors.orange.shade700,
          Colors.orange.shade50,
          Icons.timelapse_rounded
        ),
      AttendanceStatus.absent => (
          Colors.red.shade700,
          Colors.red.shade50,
          Icons.cancel_rounded
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(status.displayName,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment history table
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentHistoryTable extends StatelessWidget {
  final List<Transaction> payments;
  final Map<int, String> projectMap;
  const _PaymentHistoryTable(
      {required this.payments, required this.projectMap});

  @override
  Widget build(BuildContext context) {
    final totalPaid =
        payments.fold<double>(0.0, (s, t) => s + t.amount);

    return DataTableCard(
      title: 'Payment History  •  Total: ${CurrencyFormatter.format(totalPaid)}',
      emptyMessage: 'No payments recorded yet.',
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Project')),
        DataColumn(label: Text('Amount'), numeric: true),
        DataColumn(label: Text('Mode')),
      ],
      rows: payments.map((t) {
        return DataRow(cells: [
          DataCell(Text(DateFormatter.format(t.date))),
          DataCell(Text(
            projectMap[t.projectId] ?? '—',
            overflow: TextOverflow.ellipsis,
          )),
          DataCell(Text(
            CurrencyFormatter.format(t.amount),
            style: TextStyle(
                color: Colors.teal.shade700, fontWeight: FontWeight.w600),
          )),
          DataCell(Text(t.paymentMode?.displayName ?? '—')),
        ]);
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small badge widget
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Badge(this.text, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
