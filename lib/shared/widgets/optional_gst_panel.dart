import 'package:nex_ledger/shared/widgets/app_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/gst_utils.dart';
import 'package:nex_ledger/core/utils/simple_gst.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_invoice_providers.dart';

/// What the user chose in the optional GST block of a form.
class OptionalGstValue {
  final bool enabled;
  final double rate;

  /// True = IGST, false = CGST + SGST.
  final bool interState;
  final String partyName;
  final String partyGstin;
  final String billNo;

  const OptionalGstValue({
    this.enabled = false,
    this.rate = 18,
    this.interState = false,
    this.partyName = '',
    this.partyGstin = '',
    this.billNo = '',
  });

  /// GST is on and has a rate.
  bool get isActive => enabled && rate > 0;

  /// The split of [taxable] (value before GST) under these choices.
  SimpleGst split(double taxable) => calcSimpleGst(
      taxable: taxable, rate: isActive ? rate : 0, interState: interState);

  OptionalGstValue copyWith({
    bool? enabled,
    double? rate,
    bool? interState,
    String? partyName,
    String? partyGstin,
    String? billNo,
  }) =>
      OptionalGstValue(
        enabled: enabled ?? this.enabled,
        rate: rate ?? this.rate,
        interState: interState ?? this.interState,
        partyName: partyName ?? this.partyName,
        partyGstin: partyGstin ?? this.partyGstin,
        billNo: billNo ?? this.billNo,
      );
}

/// A small card with a switch: "Add GST to this bill". When on, the user
/// picks the GST %, optionally enters the party's name / GSTIN / bill number,
/// and sees the tax and total for the value before GST ([taxable]).
///
/// Local vs inter-state is worked out from the company state (Settings) and
/// the party's GSTIN, and can be set by hand.
class OptionalGstPanel extends ConsumerStatefulWidget {
  /// Value before GST, from the form's amount.
  final double taxable;
  final OptionalGstValue initial;
  final ValueChanged<OptionalGstValue> onChanged;
  final String title;
  final String partyLabel;
  final bool showParty;
  final bool showBillNo;

  const OptionalGstPanel({
    super.key,
    required this.taxable,
    required this.onChanged,
    this.initial = const OptionalGstValue(),
    this.title = 'Add GST to this bill',
    this.partyLabel = 'Supplier',
    this.showParty = true,
    this.showBillNo = false,
  });

  @override
  ConsumerState<OptionalGstPanel> createState() => _OptionalGstPanelState();
}

class _OptionalGstPanelState extends ConsumerState<OptionalGstPanel> {
  static const _slabs = [5.0, 12.0, 18.0, 28.0];

  late OptionalGstValue _value = widget.initial;
  bool? _interOverride;
  late final _partyCtrl = TextEditingController(text: widget.initial.partyName);
  late final _gstinCtrl =
      TextEditingController(text: widget.initial.partyGstin);
  late final _billCtrl = TextEditingController(text: widget.initial.billNo);

  @override
  void initState() {
    super.initState();
    // A saved bill keeps the type it was saved with.
    if (widget.initial.enabled) _interOverride = widget.initial.interState;
  }

  @override
  void dispose() {
    _partyCtrl.dispose();
    _gstinCtrl.dispose();
    _billCtrl.dispose();
    super.dispose();
  }

  bool _autoInter(String? companyCode) => GstUtils.isInterStateByCode(
      companyCode, GstUtils.stateCodeOf(_gstinCtrl.text));

  void _emit(String? companyCode) {
    final inter = _interOverride ?? _autoInter(companyCode);
    _value = _value.copyWith(
      interState: inter,
      partyName: _partyCtrl.text,
      partyGstin: _gstinCtrl.text,
      billNo: _billCtrl.text,
    );
    widget.onChanged(_value);
  }

  Future<void> _customRate(String? companyCode) async {
    final ctrl = TextEditingController();
    final v = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('GST rate'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
              labelText: 'Total GST rate (%)', suffixText: '%'),
          onSubmitted: (s) => Navigator.pop(ctx, double.tryParse(s)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, double.tryParse(ctrl.text)),
              child: const Text('Use')),
        ],
      ),
    );
    ctrl.dispose();
    if (v != null && v > 0 && v <= 100 && mounted) {
      setState(() => _value = _value.copyWith(rate: v));
      _emit(companyCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyCode = ref.watch(companyStateCodeProvider);
    final enabled = _value.enabled;
    final inter = _interOverride ?? _autoInter(companyCode);
    final split = calcSimpleGst(
        taxable: widget.taxable,
        rate: enabled ? _value.rate : 0,
        interState: inter);
    final slabs = {..._slabs, _value.rate}.toList()..sort();
    final gstinText = GstUtils.normalize(_gstinCtrl.text);
    final gstinBad =
        gstinText.isNotEmpty && !GstUtils.hasValidFormat(gstinText);

    Widget line(String k, double v, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Expanded(
                child: Text(k,
                    style: TextStyle(
                        fontWeight: bold ? FontWeight.w800 : FontWeight.w500))),
            Text(CurrencyFormatter.format(v),
                style: TextStyle(
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ]),
        );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: enabled ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Switch(
            key: const Key('gst_switch'),
            value: enabled,
            onChanged: (v) {
              setState(() => _value = _value.copyWith(enabled: v));
              _emit(companyCode);
            },
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(widget.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          if (!enabled)
            const Text('optional',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ]),
        if (enabled) ...[
          const SizedBox(height: 10),
          Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  child: AppDropdownField<double>(
                    key: const Key('gst_rate'),
                    value: _value.rate,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'GST %', isDense: true),
                    items: [
                      for (final s in slabs)
                        DropdownMenuItem(
                            value: s,
                            child: Text('${s % 1 == 0 ? s.toInt() : s}%')),
                      const DropdownMenuItem(value: -1, child: Text('Other…')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      if (v == -1) {
                        _customRate(companyCode);
                      } else {
                        setState(() => _value = _value.copyWith(rate: v));
                        _emit(companyCode);
                      }
                    },
                  ),
                ),
                if (widget.showParty) ...[
                  SizedBox(
                    width: 200,
                    child: TextField(
                      key: const Key('gst_party'),
                      controller: _partyCtrl,
                      decoration: InputDecoration(
                          labelText: '${widget.partyLabel} (optional)',
                          isDense: true),
                      onChanged: (_) => _emit(companyCode),
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    child: TextField(
                      key: const Key('gst_gstin'),
                      controller: _gstinCtrl,
                      maxLength: 15,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'GSTIN (optional)',
                        counterText: '',
                        isDense: true,
                        errorText: gstinBad ? 'Not a valid GSTIN' : null,
                      ),
                      onChanged: (_) {
                        setState(() {});
                        _emit(companyCode);
                      },
                    ),
                  ),
                ],
                if (widget.showBillNo)
                  SizedBox(
                    width: 150,
                    child: TextField(
                      key: const Key('gst_bill'),
                      controller: _billCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Bill no.', isDense: true),
                      onChanged: (_) => _emit(companyCode),
                    ),
                  ),
              ]),
          const SizedBox(height: 6),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
            Radio<bool>(
              value: false,
              groupValue: inter,
              onChanged: (v) {
                setState(() => _interOverride = v);
                _emit(companyCode);
              },
            ),
            InkWell(
              onTap: () {
                setState(() => _interOverride = false);
                _emit(companyCode);
              },
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                  child: Text('Local (CGST + SGST)')),
            ),
            const SizedBox(width: 12),
            Radio<bool>(
              value: true,
              groupValue: inter,
              onChanged: (v) {
                setState(() => _interOverride = v);
                _emit(companyCode);
              },
            ),
            InkWell(
              onTap: () {
                setState(() => _interOverride = true);
                _emit(companyCode);
              },
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                  child: Text('Inter State (IGST)')),
            ),
            if (_interOverride != null &&
                _interOverride != _autoInter(companyCode))
              TextButton(
                onPressed: () {
                  setState(() => _interOverride = null);
                  _emit(companyCode);
                },
                child: const Text('Auto'),
              ),
          ]),
          const Divider(height: 18),
          line('Value before GST', split.taxable),
          if (inter)
            line(
                'IGST @ ${_value.rate % 1 == 0 ? _value.rate.toInt() : _value.rate}%',
                split.igst)
          else ...[
            line('CGST @ ${_value.rate / 2}%', split.cgst),
            line('SGST @ ${_value.rate / 2}%', split.sgst),
          ],
          line('Total with GST', split.total, bold: true),
        ],
      ]),
    );
  }
}
