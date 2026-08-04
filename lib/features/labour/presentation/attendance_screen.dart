import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
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
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Attendance',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Mark present / half-day / absent per worker',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: theme.colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 16),
                            const SizedBox(width: 8),
                            Text(DateFormatter.format(selectedDate)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Project selector
                    SizedBox(
                      width: 240,
                      child: projectsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (projects) =>
                            DropdownButtonFormField<int?>(
                          value: selectedProject,
                          decoration: const InputDecoration(
                            labelText: 'Project',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null,
                                child: Text('Select Project')),
                            ...projects.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name,
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

            // Workers grid
            if (selectedProject == null)
              Expanded(
                child: Center(
                  child: Text(
                    'Select a project to mark attendance.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              Expanded(
                child: workersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (workers) {
                    if (workers.isEmpty) {
                      return Center(
                        child: Text(
                          'No workers found. Add workers in Labour > Workers.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return attendanceAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (attendanceList) {
                        // Build map workerId → status
                        final statusMap = {
                          for (final a in attendanceList)
                            a.attendance.workerId: a.attendance.status,
                        };
                        return Card(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: workers.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1),
                            itemBuilder: (context, i) {
                              final worker = workers[i];
                              final currentStatus =
                                  statusMap[worker.id] ?? AttendanceStatus.absent;
                              return ListTile(
                                title: Text(worker.name),
                                subtitle: Text(
                                  '₹${worker.dailyRate.toStringAsFixed(0)}/day'
                                  '${worker.workerCode != null ? '  •  ${worker.workerCode}' : ''}',
                                  style: theme.textTheme.bodySmall,
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
          label: Text('P', style: TextStyle(fontSize: 12)),
          tooltip: 'Present',
        ),
        ButtonSegment(
          value: AttendanceStatus.halfDay,
          label: Text('½', style: TextStyle(fontSize: 12)),
          tooltip: 'Half Day',
        ),
        ButtonSegment(
          value: AttendanceStatus.absent,
          label: Text('A', style: TextStyle(fontSize: 12)),
          tooltip: 'Absent',
        ),
      ],
      selected: {status},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
