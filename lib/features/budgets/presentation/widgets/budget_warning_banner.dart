import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/daos/project_budget_dao.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/set_project_budget_dialog.dart';
import 'package:nex_ledger/features/budgets/providers/project_budget_providers.dart';

/// Active real-time budget evaluation banner for entry forms (Purchases, Labour, Subcontracts, Expenses)
class BudgetWarningBanner extends ConsumerStatefulWidget {
  final int? projectId;
  final BudgetCostHead costHead;
  final double addedAmount;

  const BudgetWarningBanner({
    super.key,
    required this.projectId,
    required this.costHead,
    required this.addedAmount,
  });

  @override
  ConsumerState<BudgetWarningBanner> createState() => _BudgetWarningBannerState();
}

class _BudgetWarningBannerState extends ConsumerState<BudgetWarningBanner> {
  BudgetAlertResult? _alertResult;
  bool _evaluating = false;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  @override
  void didUpdateWidget(covariant BudgetWarningBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId ||
        oldWidget.costHead != widget.costHead ||
        oldWidget.addedAmount != widget.addedAmount) {
      _evaluate();
    }
  }

  Future<void> _evaluate() async {
    if (widget.projectId == null) {
      if (mounted) setState(() => _alertResult = null);
      return;
    }

    setState(() => _evaluating = true);
    try {
      final res = await ref.read(projectBudgetRepositoryProvider).evaluateBudgetImpact(
            projectId: widget.projectId!,
            costHead: widget.costHead,
            newAmount: widget.addedAmount,
          );
      if (mounted) {
        setState(() {
          _alertResult = res;
          _evaluating = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _evaluating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.projectId == null) return const SizedBox.shrink();
    if (_evaluating && _alertResult == null) return const SizedBox.shrink();

    final result = _alertResult;
    if (result == null) return const SizedBox.shrink();

    if (!result.hasBudget) {
      return Container(
        margin: EdgeInsets.only(top: 8.h, bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, size: 16.sp, color: const Color(0xFF64748B)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'No ${widget.costHead.displayName} budget configured for this project.',
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
              ),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => SetProjectBudgetDialog(projectId: widget.projectId!),
                ).then((_) => _evaluate());
              },
              child: Text(
                '+ Set Budget',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // 1. Critical Overrun (>= 100%)
    if (result.status == BudgetHealthStatus.overBudget) {
      return Container(
        margin: EdgeInsets.only(top: 8.h, bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, size: 22.sp, color: const Color(0xFFDC2626)),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ CRITICAL COST OVERRUN ALERT',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF991B1B),
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'This entry pushes ${widget.costHead.displayName} to ${result.projectedUtilizationPct.toStringAsFixed(1)}% of budget (Cost Overrun of ${CurrencyFormatter.format(result.overrunAmount)}!).',
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFFB91C1C)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Allocated Budget: ${CurrencyFormatter.format(result.allocatedBudget)} • Current Spent: ${CurrencyFormatter.format(result.currentSpent)} • Projected: ${CurrencyFormatter.format(result.projectedSpent)}',
                    style: TextStyle(fontSize: 10.sp, color: const Color(0xFF7F1D1D), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. Caution Warning (85% to 99.9%)
    if (result.status == BudgetHealthStatus.warning) {
      final remaining = result.allocatedBudget - result.projectedSpent;
      return Container(
        margin: EdgeInsets.only(top: 8.h, bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 20.sp, color: const Color(0xFFD97706)),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚡ BUDGET CAUTION (Approaching Limit)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'This entry will utilize ${result.projectedUtilizationPct.toStringAsFixed(1)}% of allocated ${widget.costHead.displayName} budget (${CurrencyFormatter.format(remaining)} remaining).',
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFFB45309)),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Allocated: ${CurrencyFormatter.format(result.allocatedBudget)} • Projected Spent: ${CurrencyFormatter.format(result.projectedSpent)}',
                    style: TextStyle(fontSize: 10.sp, color: const Color(0xFF78350F), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 3. Healthy (<85%)
    final remaining = result.allocatedBudget - result.projectedSpent;
    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16.sp, color: const Color(0xFF16A34A)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '${widget.costHead.displayName} Budget: ${CurrencyFormatter.format(result.projectedSpent)} / ${CurrencyFormatter.format(result.allocatedBudget)} (${result.projectedUtilizationPct.toStringAsFixed(1)}% used • ${CurrencyFormatter.format(remaining)} remaining)',
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF15803D), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
