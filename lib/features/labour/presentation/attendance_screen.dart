import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/labour/providers/labour_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(attendanceDateProvider);
    final globalProject = ref.watch(selectedProjectIdProvider);
    final selectedProject = ref.watch(attendanceProjectProvider) ?? globalProject;
    final workersAsync = ref.watch(workerListProvider);
    final attendanceAsync = ref.watch(attendanceListProvider);
    final projectsAsync = ref.watch(activeProjectsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Labour Attendance',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Track site worker attendance, trade roles, and daily wage costs',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Controls Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Date picker
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          ref.read(attendanceDateProvider.notifier).state =
                              picked;
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF4F46E5)),
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.format(selectedDate),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Project selector (Auto-assigned if active context locked)
                    Expanded(
                      child: projectsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (projects) => DropdownButtonFormField<int?>(
                          value: selectedProject,
                          decoration: const InputDecoration(
                            labelText: 'Active Project Context',
                            isDense: true,
                            prefixIcon: Icon(Icons.domain_rounded, size: 18),
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null,
                                child: Text('— Select Project —')),
                            ...projects.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.code} — ${p.name}',
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: (v) => ref
                              .read(attendanceProjectProvider.notifier)
                              .state = v,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Main Attendance Body
            if (selectedProject == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.domain_disabled_rounded, size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      Text(
                        'Select an active project above or from the top bar to mark attendance.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: workersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (workers) {
                    if (workers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline_rounded, size: 48, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            Text(
                              'No workers found. Add worker master profiles first under Labour > Workers Master.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      );
                    }
                    return attendanceAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (attendanceList) {
                        final statusMap = {
                          for (final a in attendanceList)
                            a.attendance.workerId: a.attendance.status,
                        };

                        // Calculate total wages for today
                        double totalDailyWage = 0.0;
                        int presentCount = 0;
                        int halfCount = 0;
                        int absentCount = 0;

                        for (final w in workers) {
                          final st = statusMap[w.id] ?? AttendanceStatus.absent;
                          if (st == AttendanceStatus.present) {
                            totalDailyWage += w.dailyRate;
                            presentCount++;
                          } else if (st == AttendanceStatus.halfDay) {
                            totalDailyWage += (w.dailyRate * 0.5);
                            halfCount++;
                          } else {
                            absentCount++;
                          }
                        }

                        return Column(
                          children: [
                            // Daily Summary Pill Bar + Batch Actions
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.payments_rounded, color: Color(0xFF10B981), size: 20),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Estimated Labour Wage Today: ',
                                          style: TextStyle(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          CurrencyFormatter.format(totalDailyWage),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '$presentCount Present  •  $halfCount Half-Day  •  $absentCount Absent',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                      ),
                                    ),
                                    const SizedBox(width: 24),

                                    // Quick Batch Action Buttons
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final repo = ref.read(labourRepositoryProvider);
                                        for (final w in workers) {
                                          await repo.markAttendance(
                                            workerId: w.id,
                                            projectId: selectedProject,
                                            date: selectedDate,
                                            status: AttendanceStatus.present,
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF10B981)),
                                      label: const Text('All Present', style: TextStyle(fontSize: 12)),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final repo = ref.read(labourRepositoryProvider);
                                        for (final w in workers) {
                                          await repo.markAttendance(
                                            workerId: w.id,
                                            projectId: selectedProject,
                                            date: selectedDate,
                                            status: AttendanceStatus.absent,
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.clear_all_rounded, size: 16, color: Color(0xFFEF4444)),
                                      label: const Text('All Absent', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Workers Attendance List Card
                            Expanded(
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  itemCount: workers.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final worker = workers[i];
                                    final currentStatus =
                                        statusMap[worker.id] ?? AttendanceStatus.absent;
                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.person_rounded, color: Color(0xFF4F46E5), size: 20),
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            worker.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(width: 8),
                                          if (worker.workerCode != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEEF2FF),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                worker.workerCode!,
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                                              ),
                                            ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              worker.trade ?? 'General Helper',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        'Daily Wage Rate: ₹${worker.dailyRate.toStringAsFixed(0)} / day',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                      trailing: _AttendanceToggle(
                                        status: currentStatus,
                                        onChanged: (newStatus) async {
                                          await ref
                                              .read(labourRepositoryProvider)
                                              .markAttendance(
                                                workerId: worker.id,
                                                projectId: selectedProject,
                                                date: selectedDate,
                                                status: newStatus,
                                              );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceToggle extends StatelessWidget {
  final AttendanceStatus status;
  final ValueChanged<AttendanceStatus> onChanged;
  const _AttendanceToggle(
      {required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AttendanceStatus>(
      segments: const [
        ButtonSegment(
          value: AttendanceStatus.present,
          label: Text('Present (1.0)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
        ),
        ButtonSegment(
          value: AttendanceStatus.halfDay,
          label: Text('Half Day (0.5)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.timelapse_rounded, color: Color(0xFFF59E0B), size: 16),
        ),
        ButtonSegment(
          value: AttendanceStatus.absent,
          label: Text('Absent (0.0)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 16),
        ),
      ],
      selected: {status},
      onSelectionChanged: (s) => onChanged(s.first),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
