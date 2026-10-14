import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/shared/widgets/project_picker.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/core/utils/wage_calculator.dart';
import 'package:nex_ledger/features/labour/providers/labour_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final Map<int, AttendanceStatus> _localStatus = {};

  /// Overtime hours per worker for the selected date (0 = none).
  final Map<int, double> _localOt = {};
  static const double _maxOtHours = 16.0;
  bool _saving = false;
  DateTime? _lastLoadedDate;
  int? _lastLoadedProject;

  void _syncStatuses(
    List<Worker> workers,
    List<AttendanceWithWorker> attendanceList,
    DateTime selectedDate,
    int? selectedProject,
  ) {
    if (_lastLoadedDate != selectedDate ||
        _lastLoadedProject != selectedProject) {
      _lastLoadedDate = selectedDate;
      _lastLoadedProject = selectedProject;
      _localStatus.clear();
      _localOt.clear();
      final map = {
        for (final a in attendanceList)
          a.attendance.workerId: a.attendance.status,
      };
      final otMap = {
        for (final a in attendanceList)
          a.attendance.workerId: a.attendance.overtimeHours,
      };
      for (final w in workers) {
        _localStatus[w.id] = map[w.id] ?? AttendanceStatus.absent;
        _localOt[w.id] = otMap[w.id] ?? 0.0;
      }
    } else {
      // Sync any newly added workers
      final map = {
        for (final a in attendanceList)
          a.attendance.workerId: a.attendance.status,
      };
      final otMap = {
        for (final a in attendanceList)
          a.attendance.workerId: a.attendance.overtimeHours,
      };
      for (final w in workers) {
        _localStatus.putIfAbsent(
            w.id, () => map[w.id] ?? AttendanceStatus.absent);
        _localOt.putIfAbsent(w.id, () => otMap[w.id] ?? 0.0);
      }
    }
  }

  Future<void> _saveAttendance(
      int projectId, DateTime date, List<Worker> workers) async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(labourRepositoryProvider);
      final statusesToSave = <int, AttendanceStatus>{};
      for (final w in workers) {
        statusesToSave[w.id] = _localStatus[w.id] ?? AttendanceStatus.absent;
      }
      final otToSave = <int, double>{
        for (final w in workers) w.id: _localOt[w.id] ?? 0.0,
      };
      await repo.saveBatchAttendance(
        projectId: projectId,
        date: date,
        workerStatuses: statusesToSave,
        overtimeHours: otToSave,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Daily attendance saved for ${workers.length} workers on ${DateFormatter.format(date)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving attendance: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Sets the same overtime hours for every worker currently marked Present
  /// (or Half Day). Enter 0 to clear overtime for them.
  Future<void> _bulkOvertime(List<Worker> workers) async {
    final hours = await showDialog<double>(
      context: context,
      builder: (_) => const _BulkOvertimeDialog(),
    );
    if (hours == null || !mounted) return;
    final h = hours.clamp(0.0, _maxOtHours).toDouble();
    setState(() {
      for (final w in workers) {
        final st = _localStatus[w.id] ?? AttendanceStatus.absent;
        if (st != AttendanceStatus.absent) _localOt[w.id] = h;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(attendanceDateProvider);
    final globalProject = ref.watch(selectedProjectIdProvider);
    final selectedProject =
        ref.watch(attendanceProjectProvider) ?? globalProject;
    final workersAsync = ref.watch(workerListProvider);
    final attendanceAsync = ref.watch(attendanceListProvider);
    final projectsAsync = ref.watch(activeProjectsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Labour Attendance',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                      ),
                    ),
                    Text(
                      'Track site worker attendance, trade roles, and daily wage costs',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (selectedProject != null)
                  workersAsync.maybeWhen(
                    data: (workers) => workers.isNotEmpty
                        ? FilledButton.icon(
                            onPressed: _saving
                                ? null
                                : () => _saveAttendance(
                                      selectedProject,
                                      selectedDate,
                                      workers,
                                    ),
                            icon: _saving
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.save_rounded, size: 18.sp),
                            label: Text(_saving
                                ? 'Saving...'
                                : 'Save Daily Attendance'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1F5FBF),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 14.h),
                            ),
                          )
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
              ],
            ),
            SizedBox(height: 16.h),

            // Controls Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.all(14.r),
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
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                size: 18.sp, color: const Color(0xFF1F5FBF)),
                            SizedBox(width: 8.w),
                            Text(
                              DateFormatter.format(selectedDate),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Project selector
                    Expanded(
                      child: projectsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (projects) => ProjectPickerField(
                          projects: projects,
                          value: selectedProject,
                          labelText: 'Active Project Context',
                          hintText: 'Select Project',
                          prefixIcon: Icons.domain_rounded,
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
            SizedBox(height: 16.h),

            // Main Attendance Body
            if (selectedProject == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.domain_disabled_rounded,
                          size: 48.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(height: 12.h),
                      Text(
                        'Select an active project above to mark daily attendance.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded,
                                size: 48.sp, color: const Color(0xFF94A3B8)),
                            SizedBox(height: 12.h),
                            Text(
                              'No workers found. Add worker master profiles first under Labour > Workers Master.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return attendanceAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (attendanceList) {
                        _syncStatuses(workers, attendanceList, selectedDate,
                            selectedProject);

                        // Calculate total wages for today
                        double totalDailyWage = 0.0;
                        int presentCount = 0;
                        int halfCount = 0;
                        int absentCount = 0;
                        double totalOtHours = 0.0;

                        for (final w in workers) {
                          final st =
                              _localStatus[w.id] ?? AttendanceStatus.absent;
                          final ot = _localOt[w.id] ?? 0.0;
                          totalDailyWage += dayWage(w, st, ot);
                          totalOtHours += ot;
                          if (st == AttendanceStatus.present) {
                            presentCount++;
                          } else if (st == AttendanceStatus.halfDay) {
                            halfCount++;
                          } else {
                            absentCount++;
                          }
                        }

                        return Column(
                          children: [
                            // Daily Summary Pill Bar + Batch Actions
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12.w,
                                runSpacing: 10.h,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.payments_rounded,
                                          color: const Color(0xFF10B981),
                                          size: 20.sp),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'Estimated Wage Today: ',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(
                                            totalDailyWage),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF047857),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      '$presentCount Present  •  $halfCount Half-Day  •  $absentCount Absent',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  if (totalOtHours > 0) ...[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        '${formatHours(totalOtHours)} hrs OT',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFC2410C),
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Quick Batch Action Buttons
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        for (final w in workers) {
                                          _localStatus[w.id] =
                                              AttendanceStatus.present;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.done_all_rounded,
                                        size: 16.sp,
                                        color: const Color(0xFF10B981)),
                                    label: Text('All Present',
                                        style: TextStyle(fontSize: 12.sp)),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        for (final w in workers) {
                                          _localStatus[w.id] =
                                              AttendanceStatus.halfDay;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.timelapse_rounded,
                                        size: 16.sp,
                                        color: const Color(0xFFF59E0B)),
                                    label: Text('All Half-Day',
                                        style: TextStyle(fontSize: 12.sp)),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        for (final w in workers) {
                                          _localStatus[w.id] =
                                              AttendanceStatus.absent;
                                        }
                                      });
                                    },
                                    icon: Icon(Icons.clear_all_rounded,
                                        size: 16.sp,
                                        color: const Color(0xFFEF4444)),
                                    label: Text('All Absent',
                                        style: TextStyle(fontSize: 12.sp)),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _bulkOvertime(workers),
                                    icon: Icon(Icons.more_time_rounded,
                                        size: 16.sp,
                                        color: const Color(0xFFEA580C)),
                                    label: Text('OT for All Present',
                                        style: TextStyle(fontSize: 12.sp)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // Workers Attendance List Card
                            Expanded(
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                                child: ListView.separated(
                                  padding: EdgeInsets.symmetric(vertical: 6.h),
                                  itemCount: workers.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final worker = workers[i];
                                    final currentStatus =
                                        _localStatus[worker.id] ??
                                            AttendanceStatus.absent;
                                    return ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 4.h),
                                      leading: Container(
                                        padding: EdgeInsets.all(8.r),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAF1FB),
                                          borderRadius:
                                              BorderRadius.circular(8.r),
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: const Color(0xFF1F5FBF),
                                          size: 20.sp,
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            worker.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          if (worker.workerCode != null)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6.w,
                                                  vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEAF1FB),
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                worker.workerCode!,
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xFF1F5FBF),
                                                ),
                                              ),
                                            ),
                                          SizedBox(width: 6.w),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              worker.trade ?? 'General Helper',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 12.w,
                                        children: [
                                          Text(
                                            'Daily Wage Rate: ₹${worker.dailyRate.toStringAsFixed(0)} / day',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                          _OvertimeStepper(
                                            hours: _localOt[worker.id] ?? 0.0,
                                            maxHours: _maxOtHours,
                                            onChanged: (h) => setState(
                                                () => _localOt[worker.id] = h),
                                          ),
                                        ],
                                      ),
                                      trailing: _AttendanceToggle(
                                        status: currentStatus,
                                        onChanged: (newStatus) {
                                          setState(() {
                                            _localStatus[worker.id] = newStatus;
                                          });
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
  const _AttendanceToggle({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AttendanceStatus>(
      segments: const [
        ButtonSegment(
          value: AttendanceStatus.present,
          label: Text(
            'Present (1.0)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          icon: Icon(Icons.check_circle_rounded,
              color: Color(0xFF10B981), size: 16),
        ),
        ButtonSegment(
          value: AttendanceStatus.halfDay,
          label: Text(
            'Half Day (0.5)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          icon:
              Icon(Icons.timelapse_rounded, color: Color(0xFFF59E0B), size: 16),
        ),
        ButtonSegment(
          value: AttendanceStatus.absent,
          label: Text(
            'Absent (0.0)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
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

/// Compact "− OT 2h +" control (0.5 hour steps).
class _OvertimeStepper extends StatelessWidget {
  final double hours;
  final double maxHours;
  final ValueChanged<double> onChanged;
  const _OvertimeStepper({
    required this.hours,
    required this.maxHours,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = hours > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 18),
          tooltip: 'Less overtime',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: active
              ? () => onChanged((hours - 0.5).clamp(0.0, maxHours))
              : null,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFF7ED) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            active ? 'OT ${formatHours(hours)} h' : 'No OT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? const Color(0xFFC2410C) : const Color(0xFF64748B),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 18),
          tooltip: 'Add overtime (0.5 h)',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: hours < maxHours
              ? () => onChanged((hours + 0.5).clamp(0.0, maxHours))
              : null,
        ),
      ],
    );
  }
}

/// Asks for one overtime figure to apply to everyone present. Owns its text
/// controller so it is disposed together with the dialog (not while closing).
class _BulkOvertimeDialog extends StatefulWidget {
  const _BulkOvertimeDialog();

  @override
  State<_BulkOvertimeDialog> createState() => _BulkOvertimeDialogState();
}

class _BulkOvertimeDialogState extends State<_BulkOvertimeDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _apply() => Navigator.pop(context, double.tryParse(_ctrl.text.trim()));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Overtime for All Present'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Overtime hours per worker',
          helperText:
              'Applied to workers marked Present or Half Day. 0 clears it.',
          suffixText: 'hrs',
        ),
        onSubmitted: (_) => _apply(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _apply, child: const Text('Apply')),
      ],
    );
  }
}
