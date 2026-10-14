import 'package:nex_ledger/shared/widgets/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/utils/gst_utils.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_invoice_providers.dart';

/// Settings card: the company's own GSTIN and state. The state is what lets
/// the purchase form decide between CGST + SGST (same state) and IGST
/// (different state) on its own.
class CompanyGstCard extends ConsumerStatefulWidget {
  const CompanyGstCard({super.key});

  @override
  ConsumerState<CompanyGstCard> createState() => _CompanyGstCardState();
}

class _CompanyGstCardState extends ConsumerState<CompanyGstCard> {
  final _gstinCtrl = TextEditingController();
  String? _stateCode; // used when there is no GSTIN
  bool _loaded = false;
  bool _saving = false;
  String? _savedMessage;

  @override
  void dispose() {
    _gstinCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    final gstin = await db.getSetting(AppDatabase.settingCompanyGstin);
    final state = await db.getSetting(AppDatabase.settingCompanyState);
    if (!mounted) return;
    setState(() {
      _gstinCtrl.text = gstin ?? '';
      _stateCode = state;
      _loaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? get _gstinProblem {
    final g = GstUtils.normalize(_gstinCtrl.text);
    if (g.isEmpty) return null;
    if (!GstUtils.hasValidFormat(g)) {
      return 'A GSTIN has 15 characters, for example 32AABFS1234A1Z5';
    }
    if (GstUtils.stateCodeOf(g) == null) return 'Unknown state code in GSTIN';
    return null;
  }

  bool get _checkDigitWrong {
    final g = GstUtils.normalize(_gstinCtrl.text);
    return GstUtils.hasValidFormat(g) &&
        GstUtils.stateCodeOf(g) != null &&
        !GstUtils.isValid(g);
  }

  Future<void> _save() async {
    if (_gstinProblem != null) return;
    setState(() => _saving = true);
    final db = ref.read(appDatabaseProvider);
    final g = GstUtils.normalize(_gstinCtrl.text);
    await db.setSetting(AppDatabase.settingCompanyGstin, g);
    // With a GSTIN the state is implied; without one keep the chosen state.
    await db.setSetting(
        AppDatabase.settingCompanyState, g.isEmpty ? _stateCode : null);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _savedMessage = 'Saved';
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyCode = ref.watch(companyStateCodeProvider);
    final fromGstin = GstUtils.stateNameOf(_gstinCtrl.text);
    final problem = _gstinProblem;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: const Color(0xFF059669), size: 22.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Company GST Details',
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A))),
                      Text(
                        'Used on purchase invoices to choose CGST + SGST or IGST automatically',
                        style: TextStyle(
                            fontSize: 11.sp, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (!_loaded)
              const LinearProgressIndicator()
            else
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _gstinCtrl,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: 'Company GSTIN',
                        hintText: '32AABFS1234A1Z5',
                        counterText: '',
                        errorText: problem,
                        helperText: _checkDigitWrong
                            ? 'Check digit does not match. Please re-check the number.'
                            : null,
                        helperStyle: const TextStyle(color: Color(0xFFB45309)),
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      onChanged: (_) => setState(() => _savedMessage = null),
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: fromGstin != null
                        ? InputDecorator(
                            decoration: const InputDecoration(
                                labelText: 'State (from GSTIN)',
                                prefixIcon: Icon(Icons.map_outlined)),
                            child: Text(fromGstin),
                          )
                        : AppDropdownField<String?>(
                            value: _stateCode,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'State (if no GSTIN)',
                                prefixIcon: Icon(Icons.map_outlined)),
                            items: [
                              const DropdownMenuItem<String?>(
                                  value: null, child: Text('— Not set —')),
                              ...GstUtils.stateByCode.entries.map((e) =>
                                  DropdownMenuItem<String?>(
                                      value: e.key, child: Text(e.value))),
                            ],
                            onChanged: (v) => setState(() {
                              _stateCode = v;
                              _savedMessage = null;
                            }),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: FilledButton.icon(
                      onPressed: _saving || problem != null ? null : _save,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(_saving ? 'Saving...' : 'Save'),
                    ),
                  ),
                  if (_savedMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Text('✓ $_savedMessage',
                          style: const TextStyle(color: Color(0xFF059669))),
                    ),
                ],
              ),
            SizedBox(height: 10.h),
            Text(
              companyCode == null
                  ? 'Not set yet. Until it is, every purchase is treated as local (CGST + SGST); you can still switch a purchase to inter-state by hand.'
                  : 'Purchases from suppliers in ${GstUtils.stateByCode[companyCode]} use CGST + SGST. Suppliers in other states use IGST.',
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
