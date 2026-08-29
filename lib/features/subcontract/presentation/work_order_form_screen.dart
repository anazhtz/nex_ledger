import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/subcontract/providers/subcontract_providers.dart';

class WorkOrderFormScreen extends ConsumerStatefulWidget {
  final int? workOrderId;
  const WorkOrderFormScreen({super.key, this.workOrderId});

  @override
  ConsumerState<WorkOrderFormScreen> createState() =>
      _WorkOrderFormScreenState();
}

class _WorkOrderFormScreenState extends ConsumerState<WorkOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderNumCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _tradeCtrl = TextEditingController(text: 'Plastering (Internal & External)');
  final _unitCtrl = TextEditingController(text: 'Sq.ft');
  final _rateCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _retentionCtrl = TextEditingController(text: '5.0');
  final _scopeCtrl = TextEditingController();

  int? _selectedProject;
  int? _selectedSubcontractor;
  WorkOrderStatus _status = WorkOrderStatus.active;
  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;
  bool _loading = false;

  bool get _isEditing => widget.workOrderId != null;

  @override
  void initState() {
    super.initState();
    _selectedProject = ref.read(selectedProjectIdProvider);
    if (!_isEditing) {
      _orderNumCtrl.text =
          'WO-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadWorkOrder());
    }
  }

  Future<void> _loadWorkOrder() async {
    final repo = ref.read(subcontractRepositoryProvider);
    final woDetail = await repo.getWorkOrderDetailById(widget.workOrderId!);
    if (woDetail != null && mounted) {
      final wo = woDetail.workOrder;
      setState(() {
        _selectedProject = wo.projectId;
        _selectedSubcontractor = wo.subcontractorId;
        _orderNumCtrl.text = wo.orderNumber;
        _titleCtrl.text = wo.title;
        _tradeCtrl.text = wo.trade;
        _unitCtrl.text = wo.unit;
        _rateCtrl.text = wo.agreedRate % 1 == 0
            ? wo.agreedRate.toInt().toString()
            : wo.agreedRate.toStringAsFixed(2);
        _qtyCtrl.text = wo.estimatedQuantity % 1 == 0
            ? wo.estimatedQuantity.toInt().toString()
            : wo.estimatedQuantity.toString();
        _retentionCtrl.text = wo.retentionPercentage.toString();
        _status = wo.status;
        _startDate = wo.startDate;
        _targetDate = wo.targetDate;
        _scopeCtrl.text = wo.scopeOfWork ?? '';
      });
    }
  }

  @override
  void dispose() {
    _orderNumCtrl.dispose();
    _titleCtrl.dispose();
    _tradeCtrl.dispose();
    _unitCtrl.dispose();
    _rateCtrl.dispose();
    _qtyCtrl.dispose();
    _retentionCtrl.dispose();
    _scopeCtrl.dispose();
    super.dispose();
  }

  double get _calculatedContractAmount {
    final rate = double.tryParse(_rateCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    return rate * qty;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target project.')),
      );
      return;
    }
    if (_selectedSubcontractor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subcontractor.')),
      );
      return;
    }

    final rate = double.tryParse(_rateCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final retention =
        double.tryParse(_retentionCtrl.text.replaceAll(',', '').trim()) ?? 5.0;

    if (rate <= 0 || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid positive rate and quantity.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(subcontractRepositoryProvider);

      if (_isEditing) {
        await repo.updateWorkOrder(
          id: widget.workOrderId!,
          orderNumber: _orderNumCtrl.text.trim(),
          projectId: _selectedProject!,
          subcontractorId: _selectedSubcontractor!,
          title: _titleCtrl.text.trim(),
          trade: _tradeCtrl.text.trim(),
          unit: _unitCtrl.text.trim(),
          agreedRate: rate,
          estimatedQuantity: qty,
          retentionPercentage: retention,
          status: _status,
          startDate: _startDate,
          targetDate: _targetDate,
          scopeOfWork: _scopeCtrl.text.isNotEmpty ? _scopeCtrl.text.trim() : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Work order updated successfully!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          context.go('/subcontracts');
        }
      } else {
        await repo.createWorkOrder(
          orderNumber: _orderNumCtrl.text.trim(),
          projectId: _selectedProject!,
          subcontractorId: _selectedSubcontractor!,
          title: _titleCtrl.text.trim(),
          trade: _tradeCtrl.text.trim(),
          unit: _unitCtrl.text.trim(),
          agreedRate: rate,
          estimatedQuantity: qty,
          retentionPercentage: retention,
          status: _status,
          startDate: _startDate,
          targetDate: _targetDate,
          scopeOfWork: _scopeCtrl.text.isNotEmpty ? _scopeCtrl.text.trim() : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Work order agreement created successfully!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          context.go('/subcontracts');
        }
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
    final projectsAsync = ref.watch(projectListProvider);
    final subsAsync = ref.watch(subcontractorListProvider);
    final theme = Theme.of(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () => context.go('/subcontracts'),
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.w),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Header ─────────────────────────────────────────
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.go('/subcontracts'),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _isEditing
                                  ? 'Edit Work Order Agreement'
                                  : 'New Subcontract Work Order',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ─── Project & Subcontractor ─────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _orderNumCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Work Order # *',
                                  prefixIcon: Icon(Icons.tag_outlined),
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: projectsAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                                data: (projects) => DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  value: projects.any((p) => p.id == _selectedProject)
                                      ? _selectedProject
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Target Project *',
                                    prefixIcon: Icon(Icons.folder_outlined),
                                  ),
                                  items: projects
                                      .map((p) => DropdownMenuItem(
                                            value: p.id,
                                            child: Text('${p.code} — ${p.name}',
                                                overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedProject = v),
                                  validator: (v) =>
                                      v == null ? 'Required' : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // Subcontractor Selector
                        subsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (subs) => Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  value: subs.any((s) => s.id == _selectedSubcontractor)
                                      ? _selectedSubcontractor
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Subcontractor / Contractor Gang *',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  items: subs
                                      .map((s) => DropdownMenuItem(
                                            value: s.id,
                                            child: Text(
                                                '${s.name} (${s.trade})',
                                                overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      _selectedSubcontractor = v;
                                      final selectedSub = subs.firstWhere((s) => s.id == v);
                                      _tradeCtrl.text = selectedSub.trade;
                                    });
                                  },
                                  validator: (v) =>
                                      v == null ? 'Required' : null,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              TextButton.icon(
                                onPressed: () => _showQuickAddSubDialog(context),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('New Contractor'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ─── Trade Presets ChoiceChips ───────────────────────
                        Text(
                          'Trade Category Preset (Click to auto-set default unit):',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: kStandardWorkOrderTrades.map((tradePreset) {
                              final isSelected = _tradeCtrl.text == tradePreset.name;
                              return Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: ChoiceChip(
                                  label: Text(tradePreset.name),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF4F46E5),
                                  labelStyle: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : const Color(0xFF334155),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _tradeCtrl.text = tradePreset.name;
                                        _unitCtrl.text = tradePreset.defaultUnit;
                                        if (_titleCtrl.text.isEmpty) {
                                          _titleCtrl.text = tradePreset.name;
                                        }
                                      });
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 14.h),

                        TextFormField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Work Order Title / Description *',
                            hintText: 'e.g. Ground Floor Plastering & Ceiling Finishing',
                            prefixIcon: Icon(Icons.assignment_outlined),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 14.h),

                        // ─── Rates & Quantity (2 Clean Rows) ─────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _rateCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Agreed Rate (₹) *',
                                  hintText: '18.00',
                                  prefixText: '₹ ',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (_) => setState(() {}),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _unitCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Unit *',
                                  hintText: 'Sq.ft',
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _qtyCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Estimated Qty *',
                                  hintText: '10000',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (_) => setState(() {}),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _retentionCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Retention %',
                                  suffixText: '%',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Live Contract Amount Banner ─────────────────────
                        if (_calculatedContractAmount > 0)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calculate_outlined,
                                    color: const Color(0xFF2563EB), size: 20.sp),
                                SizedBox(width: 10.w),
                                Text(
                                  'Total Contract Value: ',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF1E3A8A),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(_calculatedContractAmount),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E3A8A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 14.h),

                        // ─── Dates & Scope ───────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickStartDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Start Date *',
                                    prefixIcon: Icon(Icons.calendar_today_outlined),
                                  ),
                                  child: Text(
                                    '${_startDate.day.toString().padLeft(2, '0')}/'
                                    '${_startDate.month.toString().padLeft(2, '0')}/'
                                    '${_startDate.year}',
                                    style: TextStyle(
                                        fontSize: 13.sp, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: InkWell(
                                onTap: _pickTargetDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Target Completion Date',
                                    prefixIcon: Icon(Icons.event_available_outlined),
                                  ),
                                  child: Text(
                                    _targetDate != null
                                        ? '${_targetDate!.day.toString().padLeft(2, '0')}/'
                                            '${_targetDate!.month.toString().padLeft(2, '0')}/'
                                            '${_targetDate!.year}'
                                        : 'Not specified',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: _targetDate != null
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                      color: _targetDate != null
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        TextFormField(
                          controller: _scopeCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Scope of Work & Terms',
                            hintText:
                                'e.g. Scaffolding provided by contractor. Water & electricity provided by client.',
                            alignLabelWithHint: true,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ─── Action Buttons ──────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/subcontracts'),
                              child: const Text('Cancel (Esc)'),
                            ),
                            SizedBox(width: 12.w),
                            FilledButton.icon(
                              onPressed: _loading ? null : _submit,
                              icon: _loading
                                  ? SizedBox(
                                      width: 16.sp,
                                      height: 16.sp,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check, size: 18),
                              label: Text(_isEditing
                                  ? 'Update Work Order'
                                  : 'Save Work Order (Ctrl+Enter)'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _showQuickAddSubDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final tradeCtrl = TextEditingController(text: _tradeCtrl.text);
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Contractor'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10.h),
              TextFormField(
                controller: tradeCtrl,
                decoration: const InputDecoration(labelText: 'Trade *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
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
              final id = await ref.read(subcontractRepositoryProvider).addSubcontractor(
                    name: nameCtrl.text.trim(),
                    trade: tradeCtrl.text.trim(),
                  );
              if (ctx.mounted) {
                setState(() => _selectedSubcontractor = id);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
