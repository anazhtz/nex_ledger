import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/equipment/providers/equipment_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';

class EquipmentFormScreen extends ConsumerStatefulWidget {
  final int? equipmentId;
  const EquipmentFormScreen({super.key, this.equipmentId});

  @override
  ConsumerState<EquipmentFormScreen> createState() => _EquipmentFormScreenState();
}

class _EquipmentFormScreenState extends ConsumerState<EquipmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _assetNumCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _operatorNameCtrl = TextEditingController();
  final _operatorContactCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedCategory = kStandardEquipmentCategories.first.name;
  EquipmentOwnership _ownership = EquipmentOwnership.rented;
  EquipmentRentalBasis _rentalBasis = EquipmentRentalBasis.hourly;
  EquipmentFuelPolicy _fuelPolicy = EquipmentFuelPolicy.contractorSupplied;
  EquipmentStatus _status = EquipmentStatus.active;
  int? _selectedVendorId;
  int? _selectedProjectId;
  bool _loading = false;

  bool get _isEditing => widget.equipmentId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEquipment());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _assetNumCtrl.dispose();
    _rateCtrl.dispose();
    _operatorNameCtrl.dispose();
    _operatorContactCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _loadEquipment() async {
    final eqWithDetails = await ref.read(singleEquipmentProvider(widget.equipmentId!).future);
    if (eqWithDetails == null || !mounted) return;

    final eq = eqWithDetails.equipment;
    _nameCtrl.text = eq.name;
    _assetNumCtrl.text = eq.assetOrRegNumber;
    _selectedCategory = eq.category;
    _ownership = eq.ownership;
    _rentalBasis = eq.rentalBasis;
    _fuelPolicy = eq.fuelPolicy;
    _status = eq.status;
    _selectedVendorId = eq.vendorId;
    _selectedProjectId = eq.currentProjectId;
    _rateCtrl.text = eq.standardRate > 0 ? eq.standardRate.toStringAsFixed(0) : '';
    _operatorNameCtrl.text = eq.operatorName ?? '';
    _operatorContactCtrl.text = eq.operatorContact ?? '';
    _notesCtrl.text = eq.notes ?? '';
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final rate = double.tryParse(_rateCtrl.text.trim().replaceAll(',', '')) ?? 0.0;
      final repo = ref.read(equipmentRepositoryProvider);

      if (_isEditing) {
        await repo.updateEquipment(
          id: widget.equipmentId!,
          name: _nameCtrl.text.trim(),
          assetOrRegNumber: _assetNumCtrl.text.trim(),
          category: _selectedCategory,
          ownership: _ownership,
          vendorId: _ownership == EquipmentOwnership.rented ? _selectedVendorId : null,
          currentProjectId: _selectedProjectId,
          rentalBasis: _rentalBasis,
          standardRate: rate,
          fuelPolicy: _fuelPolicy,
          operatorName: _operatorNameCtrl.text.trim().isNotEmpty ? _operatorNameCtrl.text.trim() : null,
          operatorContact: _operatorContactCtrl.text.trim().isNotEmpty ? _operatorContactCtrl.text.trim() : null,
          status: _status,
          notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Equipment updated successfully!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          context.go('/equipment');
        }
        return;
      }

      await repo.createEquipment(
        name: _nameCtrl.text.trim(),
        assetOrRegNumber: _assetNumCtrl.text.trim(),
        category: _selectedCategory,
        ownership: _ownership,
        vendorId: _ownership == EquipmentOwnership.rented ? _selectedVendorId : null,
        currentProjectId: _selectedProjectId,
        rentalBasis: _rentalBasis,
        standardRate: rate,
        fuelPolicy: _fuelPolicy,
        operatorName: _operatorNameCtrl.text.trim().isNotEmpty ? _operatorNameCtrl.text.trim() : null,
        operatorContact: _operatorContactCtrl.text.trim().isNotEmpty ? _operatorContactCtrl.text.trim() : null,
        status: _status,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ New Equipment / Machinery added to fleet!'),
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
    final projectsAsync = ref.watch(projectListProvider);
    final vendorsAsync = ref.watch(vendorListProvider);

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
                                    _isEditing ? 'Edit Machinery / Equipment' : 'Add Machinery & Equipment to Fleet',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Register JCB, Cranes, Tippers, DG Sets, Excavators with rental basis and fuel policy',
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

                        // ─── Machinery Category Presets ─────────────────────
                        Text(
                          'Machinery Category / Type:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: kStandardEquipmentCategories.map((cat) {
                              final isSelected = _selectedCategory == cat.name;
                              return Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: ChoiceChip(
                                  label: Text(cat.name),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF2563EB),
                                  labelStyle: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : const Color(0xFF334155),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedCategory = cat.name;
                                        if (_nameCtrl.text.isEmpty) {
                                          _nameCtrl.text = cat.name;
                                        }
                                      });
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ─── Machine Name & Registration # ───────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Machinery Name / Model *',
                                  hintText: 'e.g. JCB 3DX Super Backhoe Loader',
                                  prefixIcon: Icon(Icons.precision_manufacturing_outlined),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _assetNumCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Asset / Vehicle Reg # *',
                                  hintText: 'e.g. KA-04-MB-8899',
                                  prefixIcon: Icon(Icons.pin_outlined),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // ─── Ownership Segment ──────────────────────────────
                        Text(
                          'Ownership Model:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        SegmentedButton<EquipmentOwnership>(
                          segments: const [
                            ButtonSegment(
                              value: EquipmentOwnership.rented,
                              label: Text('Rented / Leased (Third-Party Vendor)'),
                              icon: Icon(Icons.car_rental, size: 16),
                            ),
                            ButtonSegment(
                              value: EquipmentOwnership.owned,
                              label: Text('Company Owned Asset'),
                              icon: Icon(Icons.business_rounded, size: 16),
                            ),
                          ],
                          selected: {_ownership},
                          onSelectionChanged: (set) => setState(() => _ownership = set.first),
                        ),
                        SizedBox(height: 14.h),

                        // ─── Vendor Dropdown (If Rented) ────────────────────
                        if (_ownership == EquipmentOwnership.rented) ...[
                          vendorsAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error loading vendors: $e'),
                            data: (vendors) => DropdownButtonFormField<int?>(
                              value: _selectedVendorId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Machinery Rental Vendor / Owner *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('— Select Rental Supplier —', overflow: TextOverflow.ellipsis),
                                ),
                                ...vendors.map(
                                  (v) => DropdownMenuItem(
                                    value: v.id,
                                    child: Text(
                                        v.contact != null ? '${v.name} (${v.contact})' : v.name,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(() => _selectedVendorId = v),
                              validator: (v) => _ownership == EquipmentOwnership.rented && v == null
                                  ? 'Vendor is required for rented machinery'
                                  : null,
                            ),
                          ),
                          SizedBox(height: 14.h),
                        ],

                        // ─── Project Assignment & Status ─────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: projectsAsync.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (e, _) => Text('Error: $e'),
                                data: (projects) {
                                  final validProjects =
                                      projects.where((p) => p.type == ProjectType.project).toList();
                                  return DropdownButtonFormField<int?>(
                                    value: _selectedProjectId,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Current Assigned Project Site',
                                      prefixIcon: Icon(Icons.folder_outlined),
                                    ),
                                    items: [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text('— Unassigned / In Yard —', overflow: TextOverflow.ellipsis),
                                      ),
                                      ...validProjects.map(
                                        (p) => DropdownMenuItem(
                                          value: p.id,
                                          child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) => setState(() => _selectedProjectId = v),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<EquipmentStatus>(
                                value: _status,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  prefixIcon: Icon(Icons.info_outline),
                                ),
                                items: EquipmentStatus.values
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.displayName, overflow: TextOverflow.ellipsis),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _status = v);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Rental Basis & Standard Rate ────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<EquipmentRentalBasis>(
                                value: _rentalBasis,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Rental Rate Basis *',
                                  prefixIcon: Icon(Icons.timelapse_outlined),
                                ),
                                items: EquipmentRentalBasis.values
                                    .map(
                                      (b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(b.displayName, overflow: TextOverflow.ellipsis),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _rentalBasis = v);
                                },
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _rateCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Agreed Rate (₹ / ${_rentalBasis.unitLabel}) *',
                                  hintText: '1200',
                                  prefixText: '₹ ',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Fuel Policy ─────────────────────────────────────
                        DropdownButtonFormField<EquipmentFuelPolicy>(
                          value: _fuelPolicy,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Diesel / Fuel Policy *',
                            prefixIcon: Icon(Icons.local_gas_station_outlined),
                            helperText: 'Select who supplies diesel (Contractor diesel will be deducted from vendor bills)',
                          ),
                          items: EquipmentFuelPolicy.values
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.displayName, overflow: TextOverflow.ellipsis),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _fuelPolicy = v);
                          },
                        ),
                        SizedBox(height: 14.h),

                        // ─── Operator Details ────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _operatorNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Default Operator Name',
                                  hintText: 'e.g. Ramesh Kumar',
                                  prefixIcon: Icon(Icons.person_pin_outlined),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: TextFormField(
                                controller: _operatorContactCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Operator Phone / Mobile',
                                  hintText: 'e.g. 9876543210',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Notes ───────────────────────────────────────────
                        TextFormField(
                          controller: _notesCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Notes / Machine Specs',
                            hintText: 'e.g. Hydraulic rock breaker attachment included, 2024 model',
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
                              label: Text(_isEditing ? 'Update Equipment' : 'Save Equipment to Fleet'),
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
