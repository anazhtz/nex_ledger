import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/subcontract/providers/subcontract_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class WorkOrderDetailScreen extends ConsumerWidget {
  final int workOrderId;
  const WorkOrderDetailScreen({super.key, required this.workOrderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final woDetailAsync = ref.watch(workOrderDetailProvider(workOrderId));
    final summaryAsync =
        ref.watch(workOrderFinancialSummaryProvider(workOrderId));
    final billsAsync = ref.watch(measurementBillsListProvider(workOrderId));
    final paymentsAsync = ref.watch(subcontractPaymentsListProvider(null));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: woDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (woDetail) {
          if (woDetail == null) {
            return const Center(child: Text('Work order not found.'));
          }

          final wo = woDetail.workOrder;
          final isCompleted = wo.status == WorkOrderStatus.completed;

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ─────────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/subcontracts'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${wo.orderNumber}: ${wo.title}',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
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
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Project: ${woDetail.project.name} • Contractor: ${woDetail.subcontractor.name} (${wo.trade})',
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
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => context.push(
                            '/subcontracts/payment/new?subcontractorId=${wo.subcontractorId}',
                          ),
                          icon: const Icon(Icons.payments_outlined, size: 16),
                          label: const Text('Record Payment'),
                        ),
                        FilledButton.icon(
                          onPressed: () => context.push(
                            '/subcontracts/measurement/new?workOrderId=${wo.id}',
                          ),
                          icon: const Icon(Icons.straighten_rounded, size: 16),
                          label: const Text('Record Measurement'),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ─── Financial Summary Cards ─────────────────────────────────
                summaryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (summary) {
                    if (summary == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        Row(
                          children: [
                            _buildStatCard(
                              title: 'Total Contract Value',
                              value: CurrencyFormatter.format(wo.contractAmount),
                              subtitle:
                                  '${wo.estimatedQuantity % 1 == 0 ? wo.estimatedQuantity.toInt() : wo.estimatedQuantity} ${wo.unit} @ ₹${wo.agreedRate}/unit',
                              color: const Color(0xFF3B82F6),
                              bgColor: const Color(0xFFEFF6FF),
                              icon: Icons.assignment_outlined,
                            ),
                            SizedBox(width: 12.w),
                            _buildStatCard(
                              title: 'Certified Gross Work',
                              value: CurrencyFormatter.format(
                                  summary.totalGrossCertified),
                              subtitle:
                                  '${summary.totalMeasuredQuantity % 1 == 0 ? summary.totalMeasuredQuantity.toInt() : summary.totalMeasuredQuantity} ${wo.unit} measured (${summary.progressPercentage.toStringAsFixed(1)}%)',
                              color: const Color(0xFF10B981),
                              bgColor: const Color(0xFFECFDF5),
                              icon: Icons.verified_outlined,
                            ),
                            SizedBox(width: 12.w),
                            _buildStatCard(
                              title: 'Retention Held (5%)',
                              value: CurrencyFormatter.format(
                                  summary.totalRetentionHeld),
                              subtitle: 'Defect liability holdback',
                              color: const Color(0xFFF59E0B),
                              bgColor: const Color(0xFFFFFBEB),
                              icon: Icons.lock_clock_outlined,
                            ),
                            SizedBox(width: 12.w),
                            _buildStatCard(
                              title: 'Total Paid / Advances',
                              value: CurrencyFormatter.format(summary.totalPaid),
                              subtitle: 'Disbursed to contractor',
                              color: const Color(0xFF6366F1),
                              bgColor: const Color(0xFFEEF2FF),
                              icon: Icons.payments_outlined,
                            ),
                            SizedBox(width: 12.w),
                            _buildStatCard(
                              title: 'Current Net Due',
                              value:
                                  CurrencyFormatter.format(summary.currentNetDue),
                              subtitle: 'Payable balance',
                              color: summary.currentNetDue > 0.01
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF059669),
                              bgColor: summary.currentNetDue > 0.01
                                  ? const Color(0xFFFEF2F2)
                                  : const Color(0xFFECFDF5),
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // Progress Gauge Bar
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Physical Execution Progress: ${summary.totalMeasuredQuantity % 1 == 0 ? summary.totalMeasuredQuantity.toInt() : summary.totalMeasuredQuantity} / ${wo.estimatedQuantity % 1 == 0 ? wo.estimatedQuantity.toInt() : wo.estimatedQuantity} ${wo.unit}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${summary.progressPercentage.toStringAsFixed(1)}% Completed',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: summary.progressPercentage >= 100
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF4F46E5),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              LinearProgressIndicator(
                                value: (summary.progressPercentage / 100)
                                    .clamp(0.0, 1.0),
                                minHeight: 8.h,
                                borderRadius: BorderRadius.circular(4.r),
                                backgroundColor: const Color(0xFFE2E8F0),
                                color: summary.progressPercentage >= 100
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF4F46E5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20.h),

                // ─── Sub-Table 1: Certified Measurement Bills ────────────────
                billsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading bills: $e'),
                  data: (bills) {
                    return DataTableCard(
                      title: 'Certified Measurement Bills (RA Bills History)',
                      emptyMessage: 'No measurements certified yet.',
                      columns: const [
                        DataColumn(label: Text('Bill #')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Measured Qty')),
                        DataColumn(label: Text('Gross Work (₹)')),
                        DataColumn(label: Text('Retention (5%)')),
                        DataColumn(label: Text('Net Billable (₹)')),
                        DataColumn(label: Text('Location / Notes')),
                      ],
                      rows: bills.map((bDetail) {
                        final b = bDetail.bill;
                        return DataRow(cells: [
                          DataCell(Text(b.billNumber,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                          DataCell(Text(DateFormatter.format(b.date))),
                          DataCell(Text(
                            '${b.measuredQuantity % 1 == 0 ? b.measuredQuantity.toInt() : b.measuredQuantity} ${wo.unit}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(Text(CurrencyFormatter.format(b.grossAmount),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                          DataCell(Text(
                            CurrencyFormatter.format(b.retentionAmount),
                            style: TextStyle(color: Colors.orange.shade800),
                          )),
                          DataCell(Text(
                            CurrencyFormatter.format(b.netAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          )),
                          DataCell(Text(b.locationOrDescription ?? '—')),
                        ]);
                      }).toList(),
                    );
                  },
                ),
                SizedBox(height: 20.h),

                // ─── Sub-Table 2: Payments & Advances Log ────────────────────
                paymentsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (allPayments) {
                    final woPayments = allPayments
                        .where((p) =>
                            p.payment.workOrderId == wo.id ||
                            p.payment.subcontractorId == wo.subcontractorId)
                        .toList();

                    return DataTableCard(
                      title: 'Payments & Advances Log for this Contractor',
                      emptyMessage: 'No payments recorded for this order yet.',
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Mode & Bank Account')),
                        DataColumn(label: Text('Amount (₹)')),
                        DataColumn(label: Text('Reference / Notes')),
                      ],
                      rows: woPayments.map((pDetail) {
                        final p = pDetail.payment;
                        final isRetention = p.isRetentionRelease;
                        final isAdv = p.isAdvance;

                        return DataRow(cells: [
                          DataCell(Text(DateFormatter.format(p.paymentDate))),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
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
                                    : (isAdv
                                        ? 'Site Advance'
                                        : 'Bill Settlement'),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text(p.notes ?? (p.referenceNo ?? '—'))),
                        ]);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required IconData icon,
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
