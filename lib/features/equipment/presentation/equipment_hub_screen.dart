import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/daos/equipment_dao.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/equipment/providers/equipment_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class EquipmentHubScreen extends ConsumerStatefulWidget {
  const EquipmentHubScreen({super.key});

  @override
  ConsumerState<EquipmentHubScreen> createState() => _EquipmentHubScreenState();
}

class _EquipmentHubScreenState extends ConsumerState<EquipmentHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportEquipmentLogsToCsv(List<EquipmentLogDetail> logs) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(
          'Log Date,Equipment Name,Reg #,Category,Ownership,Vendor,Project Site,Start Reading,End Reading,Total Units,Breakdown Units,Billable Units,Unit Rate,Gross Rental (INR),Diesel Litres,Diesel Cost Deducted (INR),Net Payable (INR),Operator,Supervisor Verified,Work Description');

      for (final l in logs) {
        final log = l.log;
        buffer.writeln(
            '"${DateFormatter.format(log.logDate)}","${l.equipment.name}","${l.equipment.assetOrRegNumber}","${l.equipment.category}","${l.equipment.ownership.displayName}","${l.vendor?.name ?? 'Company Owned'}","${l.project.name}",${log.startReading},${log.endReading},${log.totalUnitsLogged},${log.breakdownUnits},${log.billableUnits},${log.unitRate},${log.grossRentalCost},${log.fuelLitresIssued},${log.fuelCostDeduction},${log.netPayableAmount},"${log.operatorName ?? ''}","${log.supervisorVerified ? 'Yes' : 'No'}","${log.workDescription}"');
      }

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/machinery_log_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(buffer.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Machinery logs exported to: $path'),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(equipmentFleetMetricsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header & Action Bar ─────────────────────────────────────────
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16.w,
              runSpacing: 12.h,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 550.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Site Machinery & Equipment Rental',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Track JCB, cranes, excavators, tipper hours, breakdown times & contractor diesel deductions',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        final logs = ref.read(allEquipmentLogsProvider).valueOrNull ?? [];
                        if (logs.isNotEmpty) _exportEquipmentLogsToCsv(logs);
                      },
                      icon: Icon(Icons.file_download_outlined, size: 16.sp),
                      label: const Text('Export CSV Report'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => context.go('/equipment/new'),
                      icon: Icon(Icons.add_circle_outline, size: 16.sp),
                      label: const Text('+ Add Equipment'),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.go('/equipment/logs/new'),
                      icon: Icon(Icons.speed_outlined, size: 16.sp),
                      label: const Text('+ Log Daily Usage'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // ─── Fleet KPI Row ───────────────────────────────────────────────
            metricsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (m) => _buildKpiRow(m),
            ),
            SizedBox(height: 14.h),

            // ─── Navigation Tabs ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF2563EB),
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: const Color(0xFF2563EB),
                tabs: const [
                  Tab(icon: Icon(Icons.precision_manufacturing_outlined), text: 'Machinery Fleet'),
                  Tab(icon: Icon(Icons.view_timeline_outlined), text: 'Daily Logbook & Timesheets'),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ─── Tab Views ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFleetTab(context),
                  _buildLogsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── KPI Row Widget ─────────────────────────────────────────────────────────

  Widget _buildKpiRow(EquipmentFleetMetrics m) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 36.w) / 4 > 220.w
            ? (constraints.maxWidth - 36.w) / 4
            : 220.w;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Total Machinery Fleet',
                    value: '${m.totalMachineryCount} Units',
                    subtitle: '${m.rentedCount} Rented • ${m.ownedCount} Company Owned',
                    icon: Icons.precision_manufacturing_rounded,
                    color: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFFEFF6FF),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Active on Site Today',
                    value: '${m.activeOnSiteCount} Active',
                    subtitle: 'Currently deployed across project sites',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF10B981),
                    bgColor: const Color(0xFFECFDF5),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Total Logged Usage',
                    value: '${m.totalLoggedUnits.toStringAsFixed(1)} Units',
                    subtitle: 'Gross Rental: ${CurrencyFormatter.format(m.totalGrossRentalIncurred)}',
                    icon: Icons.access_time_rounded,
                    color: const Color(0xFF6366F1),
                    bgColor: const Color(0xFFEEF2FF),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Diesel Deducted from Bills',
                    value: CurrencyFormatter.format(m.totalFuelDeducted),
                    subtitle: 'Net Payable: ${CurrencyFormatter.format(m.totalNetRentalPayable)}',
                    icon: Icons.local_gas_station_rounded,
                    color: const Color(0xFFD97706),
                    bgColor: const Color(0xFFFFFBEB),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 1: Machinery Fleet List ───────────────────────────────────────────

  Widget _buildFleetTab(BuildContext context) {
    final filteredEquipmentsAsync = ref.watch(filteredEquipmentsProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final selectedFilterProject = ref.watch(equipmentFilterProjectProvider);

    return Column(
      children: [
        // Filter Row
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                SizedBox(
                  width: 300.w,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search machinery, reg #, vendor...',
                      prefixIcon: Icon(Icons.search, size: 18.sp),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                    onChanged: (v) =>
                        ref.read(equipmentSearchQueryProvider.notifier).state = v,
                  ),
                ),
                projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (projects) => SizedBox(
                    width: 250.w,
                    child: DropdownButtonFormField<int?>(
                      value: selectedFilterProject,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Filter by Project',
                        prefixIcon: Icon(Icons.folder_outlined, size: 18.sp),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Sites / Yard', overflow: TextOverflow.ellipsis),
                        ),
                        ...projects.map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          ref.read(equipmentFilterProjectProvider.notifier).state = v,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // Fleet Table
        Expanded(
          child: filteredEquipmentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading machinery: $e')),
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.precision_manufacturing_outlined, size: 48.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(height: 12.h),
                      Text('No machinery records found.',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                      SizedBox(height: 8.h),
                      FilledButton.tonal(
                        onPressed: () => context.go('/equipment/new'),
                        child: const Text('+ Add First Machine / Equipment'),
                      ),
                    ],
                  ),
                );
              }

              return DataTableCard(
                minWidth: 950.w,
                columns: const [
                  DataColumn(label: Text('Machine & Reg #')),
                  DataColumn(label: Text('Type / Category')),
                  DataColumn(label: Text('Ownership & Vendor')),
                  DataColumn(label: Text('Rate Basis & Rate')),
                  DataColumn(label: Text('Assigned Site')),
                  DataColumn(label: Text('Usage & Net Cost')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: list.map((item) {
                  final eq = item.equipment;
                  final statusColor = switch (eq.status) {
                    EquipmentStatus.active => const Color(0xFF059669),
                    EquipmentStatus.idle => const Color(0xFFD97706),
                    EquipmentStatus.maintenance => const Color(0xFFDC2626),
                    EquipmentStatus.released => const Color(0xFF64748B),
                  };

                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(eq.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                            Text('Reg: ${eq.assetOrRegNumber}',
                                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      DataCell(Text(eq.category, style: TextStyle(fontSize: 12.sp))),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(eq.ownership.displayName,
                                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
                            if (item.vendor != null)
                              Text('Vendor: ${item.vendor!.name}',
                                  style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          '${CurrencyFormatter.format(eq.standardRate)} / ${eq.rentalBasis.unitLabel}',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(
                        Text(
                          item.project != null ? '${item.project!.code} — ${item.project!.name}' : 'Yard / Idle',
                          style: TextStyle(fontSize: 11.sp),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${item.totalLoggedUnits.toStringAsFixed(1)} ${eq.rentalBasis.unitLabel} logged',
                                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
                            Text('Net: ${CurrencyFormatter.format(item.totalNetCost)}',
                                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            eq.status.displayName,
                            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.speed_outlined, size: 16.sp, color: const Color(0xFF2563EB)),
                              tooltip: 'Log Usage Sheet',
                              onPressed: () => context.go('/equipment/logs/new?equipmentId=${eq.id}&projectId=${eq.currentProjectId ?? ''}'),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 16.sp, color: const Color(0xFF64748B)),
                              tooltip: 'Edit Machine',
                              onPressed: () => context.go('/equipment/${eq.id}/edit'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Tab 2: Daily Logbook & Timesheets ─────────────────────────────────────

  Widget _buildLogsTab(BuildContext context) {
    final filteredLogsAsync = ref.watch(filteredEquipmentLogsProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final selectedFilterProject = ref.watch(equipmentLogsFilterProjectProvider);

    return Column(
      children: [
        // Filter Row
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                SizedBox(
                  width: 300.w,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search logs, task, operator...',
                      prefixIcon: Icon(Icons.search, size: 18.sp),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                    onChanged: (v) =>
                        ref.read(equipmentLogsSearchQueryProvider.notifier).state = v,
                  ),
                ),
                projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (projects) => SizedBox(
                    width: 250.w,
                    child: DropdownButtonFormField<int?>(
                      value: selectedFilterProject,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Filter by Project',
                        prefixIcon: Icon(Icons.folder_outlined, size: 18.sp),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Project Sites', overflow: TextOverflow.ellipsis),
                        ),
                        ...projects.map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (v) =>
                          ref.read(equipmentLogsFilterProjectProvider.notifier).state = v,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // Logs Table
        Expanded(
          child: filteredLogsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading logs: $e')),
            data: (logs) {
              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.view_timeline_outlined, size: 48.sp, color: const Color(0xFF94A3B8)),
                      SizedBox(height: 12.h),
                      Text('No daily machinery usage logs found.',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                      SizedBox(height: 8.h),
                      FilledButton.tonal(
                        onPressed: () => context.go('/equipment/logs/new'),
                        child: const Text('+ Record Daily Machine Usage'),
                      ),
                    ],
                  ),
                );
              }

              return DataTableCard(
                minWidth: 1050.w,
                columns: const [
                  DataColumn(label: Text('Date & Project')),
                  DataColumn(label: Text('Machine & Reg #')),
                  DataColumn(label: Text('Start - End Meter')),
                  DataColumn(label: Text('Billable Units')),
                  DataColumn(label: Text('Gross Rental (₹)')),
                  DataColumn(label: Text('Diesel Issued & Deducted')),
                  DataColumn(label: Text('Net Payable (₹)')),
                  DataColumn(label: Text('Work Description')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: logs.map((l) {
                  final log = l.log;
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateFormatter.format(log.logDate),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                            Text('${l.project.code}',
                                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l.equipment.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
                            Text(l.equipment.assetOrRegNumber,
                                style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      DataCell(
                        Text('${log.startReading} → ${log.endReading}',
                            style: TextStyle(fontSize: 11.sp, fontFamily: 'monospace')),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${log.billableUnits.toStringAsFixed(1)} ${l.equipment.rentalBasis.unitLabel}',
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                            if (log.breakdownUnits > 0)
                              Text('Idle: ${log.breakdownUnits.toStringAsFixed(1)}',
                                  style: TextStyle(fontSize: 10.sp, color: Colors.orange.shade900)),
                          ],
                        ),
                      ),
                      DataCell(Text(CurrencyFormatter.format(log.grossRentalCost),
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600))),
                      DataCell(
                        log.fuelCostDeduction > 0
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('- ${CurrencyFormatter.format(log.fuelCostDeduction)}',
                                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                                  Text('${log.fuelLitresIssued.toStringAsFixed(1)} Ltrs diesel',
                                      style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
                                ],
                              )
                            : Text('—', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF94A3B8))),
                      ),
                      DataCell(Text(
                        CurrencyFormatter.format(log.netPayableAmount),
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669)),
                      )),
                      DataCell(
                        SizedBox(
                          width: 140.w,
                          child: Text(
                            log.workDescription,
                            style: TextStyle(fontSize: 11.sp),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, size: 16.sp, color: const Color(0xFF64748B)),
                              tooltip: 'Edit Log',
                              onPressed: () => context.go('/equipment/logs/${log.id}/edit'),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 16.sp, color: const Color(0xFFEF4444)),
                              tooltip: 'Delete Log',
                              onPressed: () => _confirmDeleteLog(context, log.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmDeleteLog(BuildContext context, int logId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Daily Usage Log?'),
        content: const Text('Are you sure you want to delete this machine log record?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(equipmentRepositoryProvider).deleteDailyLog(logId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
