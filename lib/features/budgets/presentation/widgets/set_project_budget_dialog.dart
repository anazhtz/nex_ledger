import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/budgets/providers/project_budget_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class SetProjectBudgetDialog extends ConsumerStatefulWidget {
  final int projectId;
  const SetProjectBudgetDialog({super.key, required this.projectId});

  @override
  ConsumerState<SetProjectBudgetDialog> createState() => _SetProjectBudgetDialogState();
}

class _SetProjectBudgetDialogState extends ConsumerState<SetProjectBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _materialsCtrl = TextEditingController();
  final _labourCtrl = TextEditingController();
  final _subcontractCtrl = TextEditingController();
  final _overheadCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController(text: '85');
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _materialsCtrl.dispose();
    _labourCtrl.dispose();
    _subcontractCtrl.dispose();
    _overheadCtrl.dispose();
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _loadExistingBudgets() async {
    if (_initialized) return;
    _initialized = true;

    final existingBudgets =
        await ref.read(projectBudgetRepositoryProvider).watchBudgetsForProject(widget.projectId).first;

    if (!mounted) return;

    for (final b in existingBudgets) {
      final amountStr = b.allocatedAmount > 0 ? b.allocatedAmount.toStringAsFixed(0) : '';
      switch (b.costHead) {
        case BudgetCostHead.materials:
          _materialsCtrl.text = amountStr;
          break;
        case BudgetCostHead.labour:
          _labourCtrl.text = amountStr;
          break;
        case BudgetCostHead.subcontract:
          _subcontractCtrl.text = amountStr;
          break;
        case BudgetCostHead.equipmentOverhead:
          _overheadCtrl.text = amountStr;
          break;
        default:
          break;
      }
      _thresholdCtrl.text = b.alertThresholdPercentage.toStringAsFixed(0);
    }
    if (mounted) setState(() {});
  }

  double _parse(TextEditingController ctrl) {
    return double.tryParse(ctrl.text.trim().replaceAll(',', '')) ?? 0.0;
  }

  double get _totalBudgeted =>
      _parse(_materialsCtrl) + _parse(_labourCtrl) + _parse(_subcontractCtrl) + _parse(_overheadCtrl);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final threshold = double.tryParse(_thresholdCtrl.text.trim()) ?? 85.0;
      final allocations = {
        BudgetCostHead.materials: _parse(_materialsCtrl),
        BudgetCostHead.labour: _parse(_labourCtrl),
        BudgetCostHead.subcontract: _parse(_subcontractCtrl),
        BudgetCostHead.equipmentOverhead: _parse(_overheadCtrl),
      };

      await ref.read(projectBudgetRepositoryProvider).setProjectBudgets(
            projectId: widget.projectId,
            allocations: allocations,
            alertThresholdPercentage: threshold,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Project budget allocations updated successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadExistingBudgets();
    final projectsAsync = ref.watch(projectListProvider);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 620.w),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ───────────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.account_balance_wallet_rounded,
                            color: const Color(0xFF2563EB), size: 22.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set Project Cost Budgets',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            projectsAsync.when(
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (projects) {
                                final p = projects.firstWhere(
                                  (item) => item.id == widget.projectId,
                                  orElse: () => projects.first,
                                );
                                return Text(
                                  '${p.code} — ${p.name} (Client: ${p.clientName ?? 'Direct Client'})',
                                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // ─── Contract Margin Banner ───────────────────────────────
                  projectsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (projects) {
                      final p = projects.firstWhere(
                        (item) => item.id == widget.projectId,
                        orElse: () => projects.first,
                      );
                      if (p.clientContractValue <= 0) return const SizedBox.shrink();

                      final contractVal = p.clientContractValue;
                      final targetProfit = contractVal - _totalBudgeted;
                      final targetMarginPct = contractVal > 0 ? (targetProfit / contractVal) * 100 : 0.0;
                      final isPositive = targetProfit >= 0;

                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: isPositive ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isPositive ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Agreed Contract Sum: ${CurrencyFormatter.format(contractVal)}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isPositive ? const Color(0xFF14532D) : const Color(0xFF7F1D1D),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Total Budgeted Cost: ${CurrencyFormatter.format(_totalBudgeted)} • Target Profit: ${CurrencyFormatter.format(targetProfit)} (${targetMarginPct.toStringAsFixed(1)}% Gross Margin)',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: isPositive ? const Color(0xFF166534) : const Color(0xFF991B1B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // ─── Budget Allocation Inputs ─────────────────────────────
                  _buildCostHeadInput(
                    label: 'Materials & Purchases Budget (₹)',
                    hint: 'e.g. 3500000',
                    icon: Icons.inventory_2_outlined,
                    controller: _materialsCtrl,
                    subtitle: 'Cement, Steel, Sand, Bricks, Tiles, Electrical, Plumbing materials',
                  ),
                  SizedBox(height: 12.h),

                  _buildCostHeadInput(
                    label: 'Direct Labour & Worker Wages Budget (₹)',
                    hint: 'e.g. 1200000',
                    icon: Icons.groups_outlined,
                    controller: _labourCtrl,
                    subtitle: 'Daily attendance wages, mason/carpenter/helper payouts',
                  ),
                  SizedBox(height: 12.h),

                  _buildCostHeadInput(
                    label: 'Subcontractors & Piece-Rate Work Budget (₹)',
                    hint: 'e.g. 1800000',
                    icon: Icons.engineering_outlined,
                    controller: _subcontractCtrl,
                    subtitle: 'Work orders, shuttering, plastering, earthwork contracts',
                  ),
                  SizedBox(height: 12.h),

                  _buildCostHeadInput(
                    label: 'Equipment, Fuel & Site Overheads Budget (₹)',
                    hint: 'e.g. 500000',
                    icon: Icons.local_shipping_outlined,
                    controller: _overheadCtrl,
                    subtitle: 'Machinery rental (JCB/Crane), diesel, transport, site office expenses',
                  ),
                  SizedBox(height: 14.h),

                  // ─── Caution Threshold ──────────────────────────────────
                  TextFormField(
                    controller: _thresholdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Caution Alert Threshold % (Amber Warning Trigger)',
                      hintText: '85',
                      suffixText: '%',
                      prefixIcon: Icon(Icons.notifications_active_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val <= 0 || val > 100) return 'Enter 1-100%';
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),

                  // ─── Total Summary Card ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Target Cost Budget:',
                              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                            ),
                            Text(
                              CurrencyFormatter.format(_totalBudgeted),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 24.sp, color: const Color(0xFF64748B)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ─── Action Buttons ───────────────────────────────────────
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12.w,
                    runSpacing: 8.h,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      SizedBox(width: 12.w),
                      FilledButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? SizedBox(
                                width: 16.sp,
                                height: 16.sp,
                                child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: const Text('Save Budget Allocations'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostHeadInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixText: '₹ ',
            prefixIcon: Icon(icon),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Text(
            subtitle,
            style: TextStyle(fontSize: 10.sp, color: const Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }
}
