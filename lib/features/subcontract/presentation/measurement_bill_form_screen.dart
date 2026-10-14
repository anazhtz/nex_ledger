import 'package:nex_ledger/shared/widgets/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/gst_utils.dart';
import 'package:nex_ledger/shared/widgets/optional_gst_panel.dart';
import 'package:nex_ledger/features/subcontract/providers/subcontract_providers.dart';

class MeasurementBillFormScreen extends ConsumerStatefulWidget {
  final int? initialWorkOrderId;
  const MeasurementBillFormScreen({super.key, this.initialWorkOrderId});

  @override
  ConsumerState<MeasurementBillFormScreen> createState() =>
      _MeasurementBillFormScreenState();
}

class _MeasurementBillFormScreenState
    extends ConsumerState<MeasurementBillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _billNumCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _retentionCtrl = TextEditingController(text: '5.0');
  final _locationCtrl = TextEditingController();

  int? _selectedWorkOrderId;
  DateTime _date = DateTime.now();
  bool _loading = false;

  /// Optional GST on this bill (charged on the measured value).
  OptionalGstValue _gst = const OptionalGstValue();
  Key _gstPanelKey = const ValueKey('gst-none');

  /// Puts the subcontractor's name (and GSTIN, when what was saved is one)
  /// into the GST panel, and rebuilds the panel so it starts from them.
  void _prefillGstParty(Subcontractor sub, int workOrderId) {
    final saved = sub.panOrGst;
    setState(() {
      _gst = _gst.copyWith(
        partyName: sub.name,
        partyGstin:
            GstUtils.hasValidFormat(saved) ? GstUtils.normalize(saved) : '',
      );
      _gstPanelKey = ValueKey('gst-wo-$workOrderId');
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedWorkOrderId = widget.initialWorkOrderId;
    if (widget.initialWorkOrderId != null) {
      // Opened from a work order: fill the GST party details right away.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final wo = await ref
            .read(subcontractRepositoryProvider)
            .getWorkOrderDetailById(widget.initialWorkOrderId!);
        if (wo != null && mounted) {
          _prefillGstParty(wo.subcontractor, widget.initialWorkOrderId!);
        }
      });
    }
    _billNumCtrl.text =
        'MB-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  void dispose() {
    _billNumCtrl.dispose();
    _qtyCtrl.dispose();
    _retentionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWorkOrderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a work order.')),
      );
      return;
    }

    final qty =
        double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final retention =
        double.tryParse(_retentionCtrl.text.replaceAll(',', '').trim()) ?? 5.0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid positive measured quantity.')),
      );
      return;
    }

    final woDetail = await ref
        .read(subcontractRepositoryProvider)
        .getWorkOrderDetailById(_selectedWorkOrderId!);

    if (woDetail == null) return;

    setState(() => _loading = true);
    try {
      await ref.read(subcontractRepositoryProvider).recordMeasurementBill(
            workOrderId: _selectedWorkOrderId!,
            billNumber: _billNumCtrl.text.trim(),
            date: _date,
            measuredQuantity: qty,
            unitRate: woDetail.workOrder.agreedRate,
            retentionPercentage: retention,
            locationOrDescription: _locationCtrl.text.isNotEmpty
                ? _locationCtrl.text.trim()
                : null,
            gstRate: _gst.isActive ? _gst.rate : 0.0,
            interState: _gst.interState,
            partyGstin: _gst.partyGstin,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('✓ Measurement bill certified & added to project cost!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.go('/subcontracts');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workOrdersAsync = ref.watch(workOrdersListProvider);
    final theme = Theme.of(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go('/subcontracts'),
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 750.w),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Record Site Measurement (RA Bill)',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Certify completed piece-rate work & book project expense',
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
                        SizedBox(height: 16.h),

                        // ─── Work Order Selector ─────────────────────────────
                        workOrdersAsync.when(
                          loading: () =>
                              const Center(child: LinearProgressIndicator()),
                          error: (e, _) =>
                              Text('Error loading work orders: $e'),
                          data: (wos) {
                            final activeWos = wos;
                            final selectedValue = activeWos.any((w) =>
                                    w.workOrder.id == _selectedWorkOrderId)
                                ? _selectedWorkOrderId
                                : null;

                            return AppDropdownField<int>(
                              value: selectedValue,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Select Subcontract Work Order *',
                                prefixIcon: Icon(Icons.assignment_outlined),
                              ),
                              items: activeWos
                                  .map((w) => DropdownMenuItem(
                                        value: w.workOrder.id,
                                        child: Text(
                                          '${w.workOrder.orderNumber}: ${w.workOrder.title} (${w.subcontractor.name} • ${w.project.name})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedWorkOrderId = v;
                                  if (v != null) {
                                    final selectedWo = activeWos
                                        .firstWhere((w) => w.workOrder.id == v);
                                    _retentionCtrl.text = selectedWo
                                        .workOrder.retentionPercentage
                                        .toString();
                                    // The subcontractor's GSTIN, when it was
                                    // saved as one, fills in by itself.
                                    final saved =
                                        selectedWo.subcontractor.panOrGst;
                                    _gst = _gst.copyWith(
                                      partyName: selectedWo.subcontractor.name,
                                      partyGstin: GstUtils.hasValidFormat(saved)
                                          ? GstUtils.normalize(saved)
                                          : '',
                                    );
                                    _gstPanelKey = ValueKey('gst-wo-$v');
                                  }
                                });
                              },
                              validator: (v) => v == null ? 'Required' : null,
                            );
                          },
                        ),
                        SizedBox(height: 14.h),

                        // ─── Work Order Live Progress Gauge Banner ───────────
                        if (_selectedWorkOrderId != null)
                          _buildSelectedWorkOrderStats(context),

                        SizedBox(height: 14.h),

                        // ─── Bill # & Date ───────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _billNumCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Bill / MB # *',
                                  prefixIcon: Icon(Icons.tag_outlined),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Measurement Date *',
                                    prefixIcon:
                                        Icon(Icons.calendar_today_outlined),
                                  ),
                                  child: Text(
                                    '${_date.day.toString().padLeft(2, '0')}/'
                                    '${_date.month.toString().padLeft(2, '0')}/'
                                    '${_date.year}',
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Quantity & Retention ────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _qtyCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Measured Qty for this Bill *',
                                  hintText: 'e.g. 2500',
                                  prefixIcon: Icon(Icons.straighten_rounded),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (_) => setState(() {}),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Required';
                                  final num =
                                      double.tryParse(v.replaceAll(',', ''));
                                  if (num == null || num <= 0) return 'Invalid';
                                  return null;
                                },
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
                                  prefixIcon: Icon(Icons.lock_clock_outlined),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // ─── Live Calculation Preview Card ───────────────────
                        if (_selectedWorkOrderId != null)
                          _buildLiveCalculationCard(context),

                        SizedBox(height: 14.h),

                        // ─── Optional GST on this bill ───────────────────────
                        if (_selectedWorkOrderId != null) ...[
                          OptionalGstPanel(
                            key: _gstPanelKey,
                            taxable: _billValue(),
                            initial: _gst,
                            title: 'This bill has GST',
                            partyLabel: 'Subcontractor',
                            onChanged: (v) => setState(() => _gst = v),
                          ),
                          SizedBox(height: 14.h),
                        ],

                        TextFormField(
                          controller: _locationCtrl,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Site Location / Description',
                            hintText:
                                'e.g. 1st Floor living room, master bedroom, and east exterior walls',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ─── Accounting Notice ───────────────────────────────
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: const Color(0xFF64748B), size: 18.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Recording this measurement certifies the completed work and books the expense in Project P&L. No physical cash leaves your bank/drawer until a payment is recorded.',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ─── Buttons ─────────────────────────────────────────
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
                              label: const Text('Certify & Save (Ctrl+Enter)'),
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

  Widget _buildSelectedWorkOrderStats(BuildContext context) {
    final summaryAsync =
        ref.watch(workOrderFinancialSummaryProvider(_selectedWorkOrderId!));
    final woDetailAsync =
        ref.watch(workOrderDetailProvider(_selectedWorkOrderId!));

    return summaryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (summary) {
        final woDetail = woDetailAsync.asData?.value;
        if (summary == null || woDetail == null) return const SizedBox.shrink();
        final wo = woDetail.workOrder;
        final targetQty = wo.estimatedQuantity;
        final alreadyMeasured = summary.totalMeasuredQuantity;
        final remainingQty =
            (targetQty - alreadyMeasured).clamp(0.0, double.infinity);

        return Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 18.sp, color: const Color(0xFF2563EB)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Contract: ${wo.title} (${wo.trade})',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Agreed Rate: ₹${wo.agreedRate % 1 == 0 ? wo.agreedRate.toInt() : wo.agreedRate} / ${wo.unit}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'Target Qty: ${targetQty % 1 == 0 ? targetQty.toInt() : targetQty} ${wo.unit} • Already Certified: ${alreadyMeasured % 1 == 0 ? alreadyMeasured.toInt() : alreadyMeasured} ${wo.unit} (${summary.progressPercentage.toStringAsFixed(1)}%) • Remaining: ${remainingQty % 1 == 0 ? remainingQty.toInt() : remainingQty} ${wo.unit}',
                style:
                    TextStyle(fontSize: 11.sp, color: const Color(0xFF1E40AF)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Measured quantity × agreed rate (the value before GST).
  double _billValue() {
    final wo =
        ref.read(workOrderDetailProvider(_selectedWorkOrderId!)).asData?.value;
    final qty =
        double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    return qty * (wo?.workOrder.agreedRate ?? 0.0);
  }

  Widget _buildLiveCalculationCard(BuildContext context) {
    final woDetailAsync =
        ref.watch(workOrderDetailProvider(_selectedWorkOrderId!));
    final woDetail = woDetailAsync.asData?.value;
    if (woDetail == null) return const SizedBox.shrink();

    final rate = woDetail.workOrder.agreedRate;
    final qty =
        double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final retentionPct =
        double.tryParse(_retentionCtrl.text.replaceAll(',', '').trim()) ?? 5.0;

    if (qty <= 0) return const SizedBox.shrink();

    final gross = qty * rate;
    final retention = gross * (retentionPct / 100.0);
    final gst = _gst.split(gross);
    final gstAmount = gst.hasGst ? gst.gst : 0.0;
    final net = gross - retention + gstAmount;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 18.sp, color: const Color(0xFF059669)),
              SizedBox(width: 8.w),
              Text(
                'Bill Calculation Preview:',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF065F46),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gross Value ($qty × ₹$rate):',
                  style: TextStyle(
                      fontSize: 12.sp, color: const Color(0xFF047857))),
              Text(CurrencyFormatter.format(gross),
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF065F46))),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Retention Withheld ($retentionPct%):',
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.orange.shade900)),
              Text('- ${CurrencyFormatter.format(retention)}',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900)),
            ],
          ),
          if (gstAmount > 0) ...[
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'GST (${_gst.rate % 1 == 0 ? _gst.rate.toInt() : _gst.rate}% on the bill value):',
                    style: TextStyle(
                        fontSize: 12.sp, color: const Color(0xFF047857))),
                Text('+ ${CurrencyFormatter.format(gstAmount)}',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF065F46))),
              ],
            ),
          ],
          const Divider(color: Color(0xFFA7F3D0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  gstAmount > 0
                      ? 'Net Payable (incl. GST):'
                      : 'Net Billable Amount (Payable):',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF065F46))),
              Text(CurrencyFormatter.format(net),
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF065F46))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }
}
