import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/subcontract/providers/subcontract_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class SubcontractHubScreen extends ConsumerStatefulWidget {
  const SubcontractHubScreen({super.key});

  @override
  ConsumerState<SubcontractHubScreen> createState() =>
      _SubcontractHubScreenState();
}

class _SubcontractHubScreenState extends ConsumerState<SubcontractHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(subcontractOverviewMetricsProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final filterProject = ref.watch(subcontractProjectFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header & Action Buttons ──────────────────────────────────────
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16.w,
              runSpacing: 12.h,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subcontracts & Piece-Rate Work Orders',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Measurement contracts, running RA bills, advance tracking & retention accounting',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showAddSubcontractorDialog(context),
                      icon: Icon(Icons.person_add_outlined, size: 16.sp),
                      label: const Text('Add Contractor'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push('/subcontracts/payment/new'),
                      icon: Icon(Icons.payments_outlined, size: 16.sp),
                      label: const Text('Record Payment'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push('/subcontracts/measurement/new'),
                      icon: Icon(Icons.straighten_rounded, size: 16.sp),
                      label: const Text('Add Measurement Bill'),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.push('/subcontracts/work-orders/new'),
                      icon: Icon(Icons.add, size: 16.sp),
                      label: const Text('New Work Order'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ─── KPI Metrics Row ──────────────────────────────────────────────
            metricsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (m) => _buildKpiRow(m),
            ),
            SizedBox(height: 16.h),

            // ─── Filter & Tabs Bar ────────────────────────────────────────────
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: Row(
                  children: [
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: const Color(0xFF4F46E5),
                      labelColor: const Color(0xFF4F46E5),
                      unselectedLabelColor: const Color(0xFF64748B),
                      labelStyle: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w500),
                      tabs: const [
                        Tab(
                            icon: Icon(Icons.assignment_outlined, size: 16),
                            text: 'Work Orders'),
                        Tab(
                            icon: Icon(Icons.straighten_rounded, size: 16),
                            text: 'Measurement Bills (RA)'),
                        Tab(
                            icon: Icon(Icons.payments_outlined, size: 16),
                            text: 'Payments & Advances'),
                        Tab(
                            icon: Icon(Icons.groups_outlined, size: 16),
                            text: 'Contractors & Dues'),
                      ],
                    ),
                    const Spacer(),
                    projectsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (projects) => SizedBox(
                        width: 250.w,
                        child: DropdownButtonFormField<int?>(
                          value: filterProject,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Filter by Project',
                            prefixIcon: Icon(Icons.folder_outlined, size: 18.sp),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Projects',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            ...projects.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.code} — ${p.name}',
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: (v) => ref
                              .read(subcontractProjectFilterProvider.notifier)
                              .state = v,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // ─── Tab Views ────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWorkOrdersTab(context),
                  _buildMeasurementBillsTab(context),
                  _buildPaymentsTab(context),
                  _buildSubcontractorsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── KPI Row Widget ─────────────────────────────────────────────────────────

  Widget _buildKpiRow(SubcontractOverviewMetrics m) {
    return Row(
      children: [
        _buildKpiCard(
          title: 'Total Contract Value',
          value: CurrencyFormatter.format(m.totalContractValue),
          subtitle: '${m.activeContractsCount} Active Work Orders',
          icon: Icons.assignment_turned_in_rounded,
          color: const Color(0xFF3B82F6),
          bgColor: const Color(0xFFEFF6FF),
        ),
        SizedBox(width: 12.w),
        _buildKpiCard(
          title: 'Certified Gross Work',
          value: CurrencyFormatter.format(m.totalGrossCertified),
          subtitle: 'Site measurements verified',
          icon: Icons.verified_outlined,
          color: const Color(0xFF10B981),
          bgColor: const Color(0xFFECFDF5),
        ),
        SizedBox(width: 12.w),
        _buildKpiCard(
          title: 'Total Paid / Advances',
          value: CurrencyFormatter.format(m.totalPaid),
          subtitle: 'Settled against bills',
          icon: Icons.payments_outlined,
          color: const Color(0xFF6366F1),
          bgColor: const Color(0xFFEEF2FF),
        ),
        SizedBox(width: 12.w),
        _buildKpiCard(
          title: 'Retention Held (5%)',
          value: CurrencyFormatter.format(m.totalRetentionHeld),
          subtitle: 'Held for defect liability',
          icon: Icons.lock_clock_outlined,
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFFFFFBEB),
        ),
        SizedBox(width: 12.w),
        _buildKpiCard(
          title: 'Net Balance Due',
          value: CurrencyFormatter.format(m.totalNetDue),
          subtitle: 'Payable to contractors',
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFFEF4444),
          bgColor: const Color(0xFFFEF2F2),
        ),
      ],
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
    return Expanded(
      child: Container(
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
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Work Orders Tab ────────────────────────────────────────────────────────

  Widget _buildWorkOrdersTab(BuildContext context) {
    final workOrdersAsync = ref.watch(workOrdersListProvider);

    return workOrdersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (workOrders) {
        return DataTableCard(
          emptyMessage:
              'No work orders found. Click "+ New Work Order" to create a subcontract agreement.',
          columns: const [
            DataColumn(label: Text('Order #')),
            DataColumn(label: Text('Project')),
            DataColumn(label: Text('Contractor & Trade')),
            DataColumn(label: Text('Agreed Rate & Qty')),
            DataColumn(label: Text('Contract Value (₹)')),
            DataColumn(label: Text('Progress')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: workOrders.map((woDetail) {
            final wo = woDetail.workOrder;
            final isCompleted = wo.status == WorkOrderStatus.completed;

            return DataRow(cells: [
              DataCell(
                GestureDetector(
                  onTap: () => context.push('/subcontracts/work-orders/${wo.id}'),
                  child: Text(
                    wo.orderNumber,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F46E5),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              DataCell(Text(
                woDetail.project.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              )),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      woDetail.subcontractor.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      wo.trade,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  '₹${wo.agreedRate % 1 == 0 ? wo.agreedRate.toInt() : wo.agreedRate} / ${wo.unit} (${wo.estimatedQuantity % 1 == 0 ? wo.estimatedQuantity.toInt() : wo.estimatedQuantity} ${wo.unit})',
                ),
              ),
              DataCell(
                Text(
                  CurrencyFormatter.format(wo.contractAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Consumer(
                  builder: (context, ref, _) {
                    final summaryAsync = ref
                        .watch(workOrderFinancialSummaryProvider(wo.id));
                    return summaryAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (summary) {
                        if (summary == null) return const Text('0%');
                        final pct = summary.progressPercentage;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 60.w,
                              child: LinearProgressIndicator(
                                value: (pct / 100).clamp(0.0, 1.0),
                                backgroundColor: const Color(0xFFE2E8F0),
                                color: pct >= 100
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF4F46E5),
                                minHeight: 6.h,
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: pct >= 100
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    wo.status.displayName,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? const Color(0xFF059669)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.straighten_rounded, size: 17.sp),
                      tooltip: 'Record Measurement (RA Bill)',
                      color: const Color(0xFF4F46E5),
                      onPressed: () => context.push(
                        '/subcontracts/measurement/new?workOrderId=${wo.id}',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.visibility_outlined, size: 17.sp),
                      tooltip: 'View Details',
                      onPressed: () =>
                          context.push('/subcontracts/work-orders/${wo.id}'),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 17.sp),
                      tooltip: 'Edit Work Order',
                      onPressed: () => context
                          .push('/subcontracts/work-orders/${wo.id}/edit'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, size: 17.sp),
                      tooltip: 'Delete Work Order',
                      color: Colors.red.shade600,
                      onPressed: () => _deleteWorkOrder(context, wo.id),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        );
      },
    );
  }

  // ─── Measurement Bills Tab ──────────────────────────────────────────────────

  Widget _buildMeasurementBillsTab(BuildContext context) {
    final billsAsync = ref.watch(measurementBillsListProvider(null));

    return billsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bills) {
        return DataTableCard(
          emptyMessage: 'No measurement bills certified yet.',
          columns: const [
            DataColumn(label: Text('Bill #')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Project')),
            DataColumn(label: Text('Contractor & Work Order')),
            DataColumn(label: Text('Measured Qty')),
            DataColumn(label: Text('Gross Work (₹)')),
            DataColumn(label: Text('Retention (5%)')),
            DataColumn(label: Text('Net Billable (₹)')),
            DataColumn(label: Text('Location / Notes')),
          ],
          rows: bills.map((bDetail) {
            final b = bDetail.bill;
            return DataRow(cells: [
              DataCell(Text(
                b.billNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              DataCell(Text(DateFormatter.format(b.date))),
              DataCell(Text(bDetail.project.name,
                  overflow: TextOverflow.ellipsis)),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bDetail.subcontractor.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      bDetail.workOrder.title,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text(
                '${b.measuredQuantity % 1 == 0 ? b.measuredQuantity.toInt() : b.measuredQuantity} ${bDetail.workOrder.unit}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              DataCell(Text(
                CurrencyFormatter.format(b.grossAmount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              DataCell(Text(
                CurrencyFormatter.format(b.retentionAmount),
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              )),
              DataCell(Text(
                CurrencyFormatter.format(b.netAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669),
                ),
              )),
              DataCell(Text(
                b.locationOrDescription ?? '—',
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                overflow: TextOverflow.ellipsis,
              )),
            ]);
          }).toList(),
        );
      },
    );
  }

  // ─── Payments & Advances Tab ────────────────────────────────────────────────

  Widget _buildPaymentsTab(BuildContext context) {
    final paymentsAsync = ref.watch(subcontractPaymentsListProvider(null));

    return paymentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (payments) {
        return DataTableCard(
          emptyMessage: 'No subcontractor payments recorded yet.',
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Contractor')),
            DataColumn(label: Text('Work Order / Scope')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Mode & Account')),
            DataColumn(label: Text('Amount Paid (₹)')),
            DataColumn(label: Text('Reference / Notes')),
          ],
          rows: payments.map((pDetail) {
            final p = pDetail.payment;
            final isRetention = p.isRetentionRelease;
            final isAdv = p.isAdvance;

            return DataRow(cells: [
              DataCell(Text(DateFormatter.format(p.paymentDate))),
              DataCell(Text(
                pDetail.subcontractor.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              DataCell(Text(
                pDetail.workOrder?.title ?? 'General Project Advance',
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              )),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isRetention
                        ? const Color(0xFFFFFBEB)
                        : (isAdv
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFEFF6FF)),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    isRetention
                        ? 'Retention Release'
                        : (isAdv ? 'Site Advance' : 'Bill Settlement'),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: isRetention
                          ? const Color(0xFFB45309)
                          : (isAdv
                              ? const Color(0xFFD97706)
                              : const Color(0xFF2563EB)),
                    ),
                  ),
                ),
              ),
              DataCell(Text(
                '${p.paymentMode.displayName}${pDetail.bankAccount != null ? ' (${pDetail.bankAccount!.accountName})' : ''}',
              )),
              DataCell(Text(
                CurrencyFormatter.format(p.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              )),
              DataCell(Text(
                p.notes ?? (p.referenceNo ?? '—'),
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                overflow: TextOverflow.ellipsis,
              )),
            ]);
          }).toList(),
        );
      },
    );
  }

  // ─── Subcontractors & Dues Tab ──────────────────────────────────────────────

  Widget _buildSubcontractorsTab(BuildContext context) {
    final summariesAsync = ref.watch(subcontractorSummariesProvider);

    return summariesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summaries) {
        return DataTableCard(
          emptyMessage: 'No subcontractors registered yet.',
          columns: const [
            DataColumn(label: Text('Contractor Name')),
            DataColumn(label: Text('Trade / Skill')),
            DataColumn(label: Text('Contact')),
            DataColumn(label: Text('Active Contracts')),
            DataColumn(label: Text('Total Contracts (₹)')),
            DataColumn(label: Text('Certified Work (₹)')),
            DataColumn(label: Text('Retention Held (₹)')),
            DataColumn(label: Text('Paid Advances (₹)')),
            DataColumn(label: Text('Current Balance Due (₹)')),
            DataColumn(label: Text('Actions')),
          ],
          rows: summaries.map((s) {
            final sub = s.subcontractor;
            final hasDue = s.currentNetDue > 0.01;

            return DataRow(cells: [
              DataCell(Text(
                sub.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              DataCell(Text(sub.trade)),
              DataCell(Text(sub.contact ?? '—')),
              DataCell(Text('${s.activeWorkOrdersCount} work orders')),
              DataCell(Text(CurrencyFormatter.format(s.totalContractValue))),
              DataCell(Text(CurrencyFormatter.format(s.totalGrossCertified))),
              DataCell(Text(
                CurrencyFormatter.format(s.totalRetentionHeld),
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              )),
              DataCell(Text(CurrencyFormatter.format(s.totalPaid))),
              DataCell(Text(
                CurrencyFormatter.format(s.currentNetDue),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasDue ? Colors.red.shade700 : const Color(0xFF059669),
                ),
              )),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasDue)
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                        ),
                        onPressed: () => context.push(
                          '/subcontracts/payment/new?subcontractorId=${sub.id}',
                        ),
                        child: const Text('Pay Due'),
                      ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 17.sp),
                      tooltip: 'Edit Details',
                      onPressed: () =>
                          _showEditSubcontractorDialog(context, sub),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        );
      },
    );
  }

  // ─── Modal Dialogs ──────────────────────────────────────────────────────────

  Future<void> _showAddSubcontractorDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final tradeCtrl = TextEditingController(text: 'Plastering');
    final contactCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Subcontractor / Maistry'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contractor / Gang Name *',
                  hintText: 'e.g. Murugan Mason Gang',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: kStandardWorkOrderTrades.first.name,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Primary Trade *',
                  prefixIcon: Icon(Icons.handyman_outlined),
                ),
                items: kStandardWorkOrderTrades
                    .map((t) => DropdownMenuItem(
                          value: t.name,
                          child: Text(t.name, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) tradeCtrl.text = v;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: contactCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number / Contact',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ref.read(subcontractRepositoryProvider).addSubcontractor(
                    name: nameCtrl.text.trim(),
                    trade: tradeCtrl.text.trim(),
                    contact: contactCtrl.text.isNotEmpty
                        ? contactCtrl.text.trim()
                        : null,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Contractor'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSubcontractorDialog(
      BuildContext context, Subcontractor sub) async {
    final nameCtrl = TextEditingController(text: sub.name);
    final tradeCtrl = TextEditingController(text: sub.trade);
    final contactCtrl = TextEditingController(text: sub.contact ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Subcontractor Details'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contractor Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: tradeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Trade / Skill *',
                  prefixIcon: Icon(Icons.handyman_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: contactCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ref.read(subcontractRepositoryProvider).updateSubcontractor(
                    id: sub.id,
                    name: nameCtrl.text.trim(),
                    trade: tradeCtrl.text.trim(),
                    contact: contactCtrl.text.isNotEmpty
                        ? contactCtrl.text.trim()
                        : null,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWorkOrder(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Work Order?'),
        content: const Text(
            'Are you sure you want to delete this work order agreement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(subcontractRepositoryProvider).deleteWorkOrder(id);
    }
  }
}
