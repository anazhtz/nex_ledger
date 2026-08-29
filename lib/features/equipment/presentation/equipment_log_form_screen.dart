import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/budget_warning_banner.dart';
import 'package:nex_ledger/features/equipment/providers/equipment_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

class EquipmentLogFormScreen extends ConsumerStatefulWidget {
  final int? logId;
  final int? initialEquipmentId;
  final int? initialProjectId;

  const EquipmentLogFormScreen({
    super.key,
    this.logId,
    this.initialEquipmentId,
    this.initialProjectId,
  });

  @override
  ConsumerState<EquipmentLogFormScreen> createState() => _EquipmentLogFormScreenState();
}

class _EquipmentLogFormScreenState extends ConsumerState<EquipmentLogFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _logDate = DateTime.now();

  int? _selectedEquipmentId;
  int? _selectedProjectId;

  final _startReadingCtrl = TextEditingController(text: '0');
  final _endReadingCtrl = TextEditingController(text: '0');
  final _totalUnitsCtrl = TextEditingController(text: '0');
  final _breakdownUnitsCtrl = TextEditingController(text: '0');
  final _billableUnitsCtrl = TextEditingController(text: '0');
  final _unitRateCtrl = TextEditingController();
  final _fuelLitresCtrl = TextEditingController(text: '0');
  final _fuelRateCtrl = TextEditingController(text: '95');
  final _workDescCtrl = TextEditingController();
  final _operatorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _supervisorVerified = true;
  bool _loading = false;

  bool get _isEditing => widget.logId != null;

  @override
  void initState() {
    super.initState();
    _selectedEquipmentId = widget.initialEquipmentId;
    _selectedProjectId = widget.initialProjectId;

    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingLog());
    }
  }

  @override
  void dispose() {
    _startReadingCtrl.dispose();
    _endReadingCtrl.dispose();
    _totalUnitsCtrl.dispose();
    _breakdownUnitsCtrl.dispose();
    _billableUnitsCtrl.dispose();
    _unitRateCtrl.dispose();
    _fuelLitresCtrl.dispose();
    _fuelRateCtrl.dispose();
    _workDescCtrl.dispose();
    _operatorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _loadExistingLog() async {
    final allLogs = await ref.read(allEquipmentLogsProvider.future);
    final detail = allLogs.firstWhere(
      (l) => l.log.id == widget.logId,
      orElse: () => allLogs.first,
    );

    final l = detail.log;
    _logDate = l.logDate;
    _selectedEquipmentId = l.equipmentId;
    _selectedProjectId = l.projectId;
    _startReadingCtrl.text = l.startReading.toString();
    _endReadingCtrl.text = l.endReading.toString();
    _totalUnitsCtrl.text = l.totalUnitsLogged.toString();
    _breakdownUnitsCtrl.text = l.breakdownUnits.toString();
    _billableUnitsCtrl.text = l.billableUnits.toString();
    _unitRateCtrl.text = l.unitRate.toStringAsFixed(0);
    _fuelLitresCtrl.text = l.fuelLitresIssued.toString();
    _fuelRateCtrl.text = l.fuelRatePerLitre.toString();
    _workDescCtrl.text = l.workDescription;
    _operatorCtrl.text = l.operatorName ?? '';
    _supervisorVerified = l.supervisorVerified;
    _notesCtrl.text = l.notes ?? '';
    if (mounted) setState(() {});
  }

  double _parse(TextEditingController ctrl) =>
      double.tryParse(ctrl.text.trim().replaceAll(',', '')) ?? 0.0;

  void _onReadingsChanged() {
    final start = _parse(_startReadingCtrl);
    final end = _parse(_endReadingCtrl);
    if (end > start) {
      final total = end - start;
      _totalUnitsCtrl.text = total.toStringAsFixed(1);
      final breakdown = _parse(_breakdownUnitsCtrl);
      final billable = (total - breakdown).clamp(0.0, total);
      _billableUnitsCtrl.text = billable.toStringAsFixed(1);
    }
    setState(() {});
  }

  void _onTotalOrBreakdownChanged() {
    final total = _parse(_totalUnitsCtrl);
    final breakdown = _parse(_breakdownUnitsCtrl);
    final billable = (total - breakdown).clamp(0.0, total);
    _billableUnitsCtrl.text = billable.toStringAsFixed(1);
    setState(() {});
  }

  double get _billableUnits => _parse(_billableUnitsCtrl);
  double get _unitRate => _parse(_unitRateCtrl);
  double get _grossRentalCost => _billableUnits * _unitRate;
  double get _fuelLitres => _parse(_fuelLitresCtrl);
  double get _fuelRate => _parse(_fuelRateCtrl);
  double get _fuelCostDeduction => _fuelLitres * _fuelRate;
  double get _netPayableAmount => (_grossRentalCost - _fuelCostDeduction).clamp(0.0, double.infinity);

  void _onEquipmentSelected(EquipmentWithDetails? eq) {
    if (eq == null) return;
    setState(() {
      _selectedEquipmentId = eq.equipment.id;
      if (_selectedProjectId == null && eq.equipment.currentProjectId != null) {
        _selectedProjectId = eq.equipment.currentProjectId;
      }
      if (_unitRateCtrl.text.isEmpty || _unitRateCtrl.text == '0') {
        _unitRateCtrl.text = eq.equipment.standardRate > 0
            ? eq.equipment.standardRate.toStringAsFixed(0)
            : '';
      }
      if (_operatorCtrl.text.isEmpty && eq.equipment.operatorName != null) {
        _operatorCtrl.text = eq.equipment.operatorName!;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _logDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _logDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEquipmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an equipment / machine.')),
      );
      return;
    }
    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project site.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final repo = ref.read(equipmentRepositoryProvider);

      if (_isEditing) {
        await repo.updateDailyLog(
          id: widget.logId!,
          equipmentId: _selectedEquipmentId!,
          projectId: _selectedProjectId!,
          logDate: _logDate,
          startReading: _parse(_startReadingCtrl),
          endReading: _parse(_endReadingCtrl),
          totalUnitsLogged: _parse(_totalUnitsCtrl),
          breakdownUnits: _parse(_breakdownUnitsCtrl),
          billableUnits: _billableUnits,
          unitRate: _unitRate,
          grossRentalCost: _grossRentalCost,
          fuelLitresIssued: _fuelLitres,
          fuelRatePerLitre: _fuelRate,
          fuelCostDeduction: _fuelCostDeduction,
          netPayableAmount: _netPayableAmount,
          workDescription: _workDescCtrl.text.trim(),
          operatorName: _operatorCtrl.text.trim().isNotEmpty ? _operatorCtrl.text.trim() : null,
          supervisorVerified: _supervisorVerified,
          notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Equipment daily log updated!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          context.go('/equipment');
        }
        return;
      }

      await repo.recordDailyLog(
        equipmentId: _selectedEquipmentId!,
        projectId: _selectedProjectId!,
        logDate: _logDate,
        startReading: _parse(_startReadingCtrl),
        endReading: _parse(_endReadingCtrl),
        totalUnitsLogged: _parse(_totalUnitsCtrl),
        breakdownUnits: _parse(_breakdownUnitsCtrl),
        billableUnits: _billableUnits,
        unitRate: _unitRate,
        grossRentalCost: _grossRentalCost,
        fuelLitresIssued: _fuelLitres,
        fuelRatePerLitre: _fuelRate,
        fuelCostDeduction: _fuelCostDeduction,
        netPayableAmount: _netPayableAmount,
        workDescription: _workDescCtrl.text.trim(),
        operatorName: _operatorCtrl.text.trim().isNotEmpty ? _operatorCtrl.text.trim() : null,
        supervisorVerified: _supervisorVerified,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Machinery daily log & diesel deduction recorded!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.go('/equipment');
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
    final theme = Theme.of(context);
    final equipmentsAsync = ref.watch(allEquipmentsProvider);
    final projectsAsync = ref.watch(projectListProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () => context.go('/equipment'),
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
                              onPressed: () => context.go('/equipment'),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditing
                                        ? 'Edit Daily Machine Usage Log'
                                        : 'Log Daily Machinery Usage & Timesheet',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Track hour meter start/end, idle breakdown hours, and contractor diesel deductions',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),

                        // ─── Log Date & Machinery Selector ───────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Log Date *',
                                    prefixIcon: Icon(Icons.calendar_today_outlined),
                                  ),
                                  child: Text(
                                    '${_logDate.day.toString().padLeft(2, '0')}/'
                                    '${_logDate.month.toString().padLeft(2, '0')}/'
                                    '${_logDate.year}',
                                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 3,
                              child: equipmentsAsync.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (e, _) => Text('Error: $e'),
                                data: (equipments) => DropdownButtonFormField<int?>(
                                  value: _selectedEquipmentId,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Machine / Equipment *',
                                    prefixIcon: Icon(Icons.precision_manufacturing_outlined),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('— Select Machine —', overflow: TextOverflow.ellipsis),
                                    ),
                                    ...equipments.map(
                                      (eq) => DropdownMenuItem(
                                        value: eq.equipment.id,
                                        child: Text(
                                          '${eq.equipment.name} (${eq.equipment.assetOrRegNumber})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (id) {
                                    if (id != null) {
                                      final match = equipments.firstWhere((item) => item.equipment.id == id);
                                      _onEquipmentSelected(match);
                                    }
                                  },
                                  validator: (v) => v == null ? 'Required' : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Target Project Dropdown ─────────────────────────
                        projectsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                          data: (projects) {
                            final validProjects =
                                projects.where((p) => p.type == ProjectType.project).toList();
                            return DropdownButtonFormField<int?>(
                              value: _selectedProjectId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Target Project Site *',
                                prefixIcon: Icon(Icons.folder_outlined),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('— Select Project —', overflow: TextOverflow.ellipsis),
                                ),
                                ...validProjects.map(
                                  (p) => DropdownMenuItem(
                                    value: p.id,
                                    child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(() => _selectedProjectId = v),
                              validator: (v) => v == null ? 'Required' : null,
                            );
                          },
                        ),
                        SizedBox(height: 14.h),

                        // ─── Meter Readings / Hours Logged ───────────────────
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _startReadingCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Start Meter Reading',
                                  hintText: '1450.0',
                                  prefixIcon: Icon(Icons.speed_outlined),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => _onReadingsChanged(),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: TextFormField(
                                controller: _endReadingCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'End Meter Reading',
                                  hintText: '1458.5',
                                  prefixIcon: Icon(Icons.speed_outlined),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => _onReadingsChanged(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _totalUnitsCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Total Logged Units (Hrs/Days/Trips) *',
                                  hintText: '8.5',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => _onTotalOrBreakdownChanged(),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: TextFormField(
                                controller: _breakdownUnitsCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Breakdown / Idle Units (Deducted)',
                                  hintText: '0.5',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => _onTotalOrBreakdownChanged(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Billable Units & Unit Rate ──────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _billableUnitsCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Net Billable Units *',
                                  hintText: '8.0',
                                  prefixIcon: Icon(Icons.check_circle_outline),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: TextFormField(
                                controller: _unitRateCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Unit Rate (₹) *',
                                  hintText: '1200',
                                  prefixText: '₹ ',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ─── Contractor Diesel / Fuel Deduction Section ──────
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_gas_station_rounded,
                                      size: 18.sp, color: const Color(0xFFD97706)),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Contractor Diesel Issued (Deducted from Machinery Bill)',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fuelLitresCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Diesel Issued (Litres)',
                                        hintText: '35.0',
                                        suffixText: 'Ltr',
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fuelRateCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Diesel Rate (₹ / Litre)',
                                        hintText: '95.00',
                                        prefixText: '₹ ',
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                              if (_fuelCostDeduction > 0) ...[
                                SizedBox(height: 8.h),
                                Text(
                                  'Total Diesel Cost Deduction: ${CurrencyFormatter.format(_fuelCostDeduction)} (${_fuelLitres.toStringAsFixed(1)} Ltrs @ ₹${_fuelRate.toStringAsFixed(2)}/Ltr)',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ─── Live Calculation Breakdown Card ─────────────────
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Machinery Daily Log Financial Summary:',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF065F46),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Gross Rental Cost (${_billableUnits.toStringAsFixed(1)} units @ ${CurrencyFormatter.format(_unitRate)}):',
                                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF047857))),
                                  Text(CurrencyFormatter.format(_grossRentalCost),
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF065F46))),
                                ],
                              ),
                              if (_fuelCostDeduction > 0) ...[
                                SizedBox(height: 4.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Less: Contractor Diesel Supplied:',
                                        style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade900)),
                                    Text('- ${CurrencyFormatter.format(_fuelCostDeduction)}',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade900)),
                                  ],
                                ),
                              ],
                              const Divider(color: Color(0xFFA7F3D0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Net Amount Payable to Machine Owner:',
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF065F46))),
                                  Text(CurrencyFormatter.format(_netPayableAmount),
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF065F46))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // ─── Real-Time Project Equipment Budget Warning ──────
                        if (_selectedProjectId != null && _netPayableAmount > 0)
                          BudgetWarningBanner(
                            projectId: _selectedProjectId,
                            costHead: BudgetCostHead.equipmentOverhead,
                            addedAmount: _netPayableAmount,
                          ),

                        SizedBox(height: 14.h),

                        // ─── Work Description & Operator ─────────────────────
                        TextFormField(
                          controller: _workDescCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Work Description / Civil Task Executed *',
                            hintText: 'e.g. Basement raft footing trench excavation & earth removal',
                            prefixIcon: Icon(Icons.assignment_outlined),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: 14.h),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _operatorCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Operator On Duty',
                                  hintText: 'e.g. Ramesh Operator',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: SwitchListTile(
                                title: Text('Verified on Site', style: TextStyle(fontSize: 12.sp)),
                                value: _supervisorVerified,
                                onChanged: (v) => setState(() => _supervisorVerified = v),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        TextFormField(
                          controller: _notesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Log Notes',
                            hintText: 'e.g. Rain stoppage between 2pm-3pm',
                            prefixIcon: Icon(Icons.notes_outlined),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ─── Submit Buttons ──────────────────────────────────
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 12.w,
                          runSpacing: 8.h,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/equipment'),
                              child: const Text('Cancel'),
                            ),
                            FilledButton.icon(
                              onPressed: _loading ? null : _submit,
                              icon: _loading
                                  ? SizedBox(
                                      width: 16.sp,
                                      height: 16.sp,
                                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check, size: 18),
                              label: Text(_isEditing ? 'Update Log' : 'Save Daily Log Sheet'),
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
}
