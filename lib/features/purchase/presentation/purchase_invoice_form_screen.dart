import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/constants/material_constants.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/gst_calculator.dart';
import 'package:nex_ledger/core/utils/gst_utils.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/budget_warning_banner.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_invoice_providers.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';
import 'package:nex_ledger/shared/widgets/erp_widgets.dart';

/// One row of the items table, with its text controllers.
class _LineCtl {
  int? purchaseId;
  final item = TextEditingController();
  final spec = TextEditingController();
  final hsn = TextEditingController();
  final qty = TextEditingController(text: '1');
  final rate = TextEditingController();
  final disc = TextEditingController();
  final itemFocus = FocusNode();
  String unit = 'Nos';
  double gstRate = 0;

  void dispose() {
    item.dispose();
    spec.dispose();
    hsn.dispose();
    qty.dispose();
    rate.dispose();
    disc.dispose();
    itemFocus.dispose();
  }

  GstLineInput get input => GstLineInput(
        qty: _num(qty),
        rate: _num(rate),
        discountPercent: _num(disc),
        gstRate: gstRate,
      );

  bool get isFilled => item.text.trim().isNotEmpty;
}

double _num(TextEditingController c) =>
    double.tryParse(c.text.replaceAll(',', '').replaceAll(' ', '').trim()) ??
    0.0;

String _plain(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);

/// GST purchase invoice: header, several items each with its own GST rate,
/// extra charges, and automatic totals. Also used to edit a saved invoice.
class PurchaseInvoiceFormScreen extends ConsumerStatefulWidget {
  final int? invoiceId;
  const PurchaseInvoiceFormScreen({super.key, this.invoiceId});

  @override
  ConsumerState<PurchaseInvoiceFormScreen> createState() =>
      _PurchaseInvoiceFormScreenState();
}

class _PurchaseInvoiceFormScreenState
    extends ConsumerState<PurchaseInvoiceFormScreen> {
  static const _gstSlabs = [0.0, 5.0, 12.0, 18.0, 28.0];
  static const _units = [
    'Nos',
    'Bags',
    'Tons',
    'Kg',
    'CFT',
    'Sq.ft',
    'Cu.m',
    'Litres',
    'Meters',
    'Trips',
    'Hours',
    'Lump sum',
    'Boxes',
    'Other',
  ];

  // header
  DateTime _date = DateTime.now();
  DateTime? _invoiceDate;
  final _invoiceNoCtrl = TextEditingController();
  int? _projectId;
  int? _vendorId;
  final _gstinCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String? _state;
  bool? _interOverride; // null = decide automatically
  String? _category;
  bool _advanceStock = false;
  final _transportCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _creditDaysCtrl = TextEditingController(text: '30');

  // payment (new invoices only)
  PaymentStatus _paymentStatus = PaymentStatus.pending;
  final _paidCtrl = TextEditingController();
  PaymentMode? _paymentMode;
  int? _bankAccountId;
  double _paidSoFar = 0; // edit mode

  // charges
  final _freightCtrl = TextEditingController();
  final _loadingCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();
  bool _roundOff = true;

  final List<_LineCtl> _lines = [_LineCtl()];

  String _purchaseNo = '';
  bool _saving = false;
  bool _loaded = false;

  bool get _isEditing => widget.invoiceId != null;

  @override
  void initState() {
    super.initState();
    _projectId = ref.read(selectedProjectIdProvider);
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadInvoice());
    } else {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshNumber());
    }
  }

  @override
  void dispose() {
    for (final c in [
      _invoiceNoCtrl,
      _gstinCtrl,
      _addressCtrl,
      _transportCtrl,
      _vehicleCtrl,
      _remarksCtrl,
      _creditDaysCtrl,
      _paidCtrl,
      _freightCtrl,
      _loadingCtrl,
      _otherCtrl,
    ]) {
      c.dispose();
    }
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  // ─── loading ──────────────────────────────────────────────────────────────

  Future<void> _refreshNumber() async {
    if (_isEditing) return;
    final no =
        await ref.read(purchaseInvoiceRepositoryProvider).nextPurchaseNo(_date);
    if (mounted) setState(() => _purchaseNo = no);
  }

  Future<void> _loadInvoice() async {
    final d = await ref
        .read(purchaseInvoiceRepositoryProvider)
        .getInvoice(widget.invoiceId!);
    if (!mounted) return;
    if (d == null) {
      setState(() => _loaded = true);
      return;
    }
    final inv = d.invoice;
    setState(() {
      _purchaseNo = inv.purchaseNo;
      _date = inv.date;
      _invoiceDate = inv.invoiceDate;
      _invoiceNoCtrl.text = inv.invoiceNo ?? '';
      _projectId = inv.projectId;
      _vendorId = inv.vendorId;
      _gstinCtrl.text = inv.supplierGstin ?? '';
      _state = inv.supplierState;
      _addressCtrl.text = d.vendor.address ?? '';
      _interOverride = inv.isInterState;
      _advanceStock = inv.isAdvanceStock;
      _transportCtrl.text = inv.transportBy ?? '';
      _vehicleCtrl.text = inv.vehicleNo ?? '';
      _remarksCtrl.text = inv.remarks ?? '';
      _creditDaysCtrl.text = inv.creditDays.toString();
      // Round-off was on if the saved total is a whole rupee.
      _roundOff = (inv.grandTotal * 100).round() % 100 == 0;
      _paidSoFar = d.paid;

      for (final l in _lines) {
        l.dispose();
      }
      _lines.clear();
      for (final row in d.lines.where((l) => !l.purchase.isOtherCharge)) {
        final p = row.purchase;
        final c = _LineCtl()
          ..purchaseId = p.id
          ..unit = p.unit ?? 'Nos'
          ..gstRate = p.gstRate;
        c.item.text = p.itemDescription;
        c.spec.text = p.specification ?? '';
        c.hsn.text = p.hsn ?? '';
        c.qty.text = _plain(p.quantity);
        c.rate.text = _plain(p.unitRate);
        c.disc.text = p.discountPercent == 0 ? '' : _plain(p.discountPercent);
        _lines.add(c);
        _category ??= p.materialCategory;
      }
      if (_lines.isEmpty) _lines.add(_LineCtl());
      for (final row in d.lines.where((l) => l.purchase.isOtherCharge)) {
        final amt = row.transaction.amount;
        switch (row.purchase.itemDescription) {
          case kFreightLabel:
            _freightCtrl.text = _plain(amt);
          case kLoadingLabel:
            _loadingCtrl.text = _plain(amt);
          default:
            _otherCtrl.text = _plain(amt);
        }
      }
      _loaded = true;
    });
  }

  // ─── GST decisions ────────────────────────────────────────────────────────

  bool _isInterState(String? companyCode) {
    if (_interOverride != null) return _interOverride!;
    final supplier =
        GstUtils.supplierStateCode(gstin: _gstinCtrl.text, stateName: _state);
    return GstUtils.isInterStateByCode(companyCode, supplier);
  }

  void _onGstinChanged(String v) {
    final name = GstUtils.stateNameOf(v);
    setState(() {
      if (name != null) _state = name;
    });
  }

  void _onSupplierPicked(int? id, List<Vendor> vendors) {
    final v = vendors.where((x) => x.id == id).firstOrNull;
    setState(() {
      _vendorId = id;
      _gstinCtrl.text = v?.gstin ?? '';
      _state = v?.state;
      _addressCtrl.text = v?.address ?? '';
    });
  }

  // ─── actions ──────────────────────────────────────────────────────────────

  void _addLine({String unit = 'Nos'}) {
    final l = _LineCtl()..unit = unit;
    setState(() => _lines.add(l));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => l.itemFocus.requestFocus());
  }

  void _removeLine(_LineCtl l) {
    if (_lines.length == 1) {
      // keep one empty row rather than an empty table
      setState(() {
        l.item.clear();
        l.spec.clear();
        l.hsn.clear();
        l.qty.text = '1';
        l.rate.clear();
        l.disc.clear();
        l.gstRate = 0;
        l.purchaseId = null;
      });
      return;
    }
    setState(() => _lines.remove(l));
    WidgetsBinding.instance.addPostFrameCallback((_) => l.dispose());
  }

  void _applyDefault(_LineCtl l, ItemDefault d) {
    setState(() {
      if (l.hsn.text.trim().isEmpty && (d.hsn ?? '').isNotEmpty) {
        l.hsn.text = d.hsn!;
      }
      l.gstRate = d.gstRate;
      if ((d.unit ?? '').isNotEmpty) l.unit = d.unit!;
    });
  }

  Future<void> _pickDate({required bool invoice}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (invoice ? _invoiceDate : _date) ?? _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => invoice ? _invoiceDate = picked : _date = picked);
    if (!invoice) _refreshNumber();
  }

  Future<void> _askCustomRate(_LineCtl l) async {
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
    if (v != null && v >= 0 && v <= 100 && mounted) {
      setState(() => l.gstRate = v);
    }
  }

  Future<void> _addSupplierDialog() async {
    final nameCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String? state;
    final created = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Add Supplier'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration:
                      const InputDecoration(labelText: 'Supplier name *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: gstinCtrl,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 15,
                  decoration: const InputDecoration(
                      labelText: 'GSTIN (optional)', counterText: ''),
                  onChanged: (v) {
                    final n = GstUtils.stateNameOf(v);
                    if (n != null) setD(() => state = n);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String?>(
                  value: state,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'State'),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('— Not set —')),
                    ...GstUtils.stateByCode.values.map((s) =>
                        DropdownMenuItem<String?>(value: s, child: Text(s))),
                  ],
                  onChanged: (v) => setD(() => state = v),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Phone (optional)'),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final id = await ref.read(purchaseRepositoryProvider).addVendor(
                      name,
                      contact: phoneCtrl.text.trim().isEmpty
                          ? null
                          : phoneCtrl.text.trim(),
                      gstin: GstUtils.normalize(gstinCtrl.text).isEmpty
                          ? null
                          : GstUtils.normalize(gstinCtrl.text),
                      state: state,
                    );
                if (ctx.mounted) Navigator.pop(ctx, id);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    gstinCtrl.dispose();
    phoneCtrl.dispose();
    if (created != null && mounted) {
      final vendors = await ref.read(vendorListProvider.future);
      _onSupplierPicked(created, vendors);
    }
  }

  // ─── totals & saving ──────────────────────────────────────────────────────

  _Calc _calc(bool inter) {
    final results = <GstLineResult>[];
    final perRow = <GstLineResult>[];
    for (final l in _lines) {
      final r = calcGstLine(l.input, interState: inter);
      perRow.add(r);
      if (l.isFilled) results.add(r);
    }
    final totals = calcGstInvoice(
      results,
      charges: [_num(_freightCtrl), _num(_loadingCtrl), _num(_otherCtrl)],
      roundOff: _roundOff,
    );
    return _Calc(perRow, totals);
  }

  void _snack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade700 : const Color(0xFF059669),
    ));
  }

  Future<bool> _confirmGstin() async {
    final g = GstUtils.normalize(_gstinCtrl.text);
    if (g.isEmpty) return true;
    if (!GstUtils.hasValidFormat(g)) {
      _snack(
          'The supplier GSTIN is not in the right format. It has 15 characters, like 32AABFS1234A1Z5.');
      return false;
    }
    if (GstUtils.stateCodeOf(g) == null) {
      _snack('The first two digits of the GSTIN are not a valid state code.');
      return false;
    }
    if (!GstUtils.isValid(g)) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Check the GSTIN'),
          content: Text(
              '$g has the right shape, but its check digit does not match. It may have a typing mistake.\n\nSave anyway?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Go back')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save anyway')),
          ],
        ),
      );
      return ok == true;
    }
    return true;
  }

  Future<bool> _confirmNegativeBalance(double paid) async {
    if (paid <= 0) return true;
    final accounts = ref.read(bankAccountsWithBalancesProvider).asData?.value;
    if (accounts == null || accounts.isEmpty) return true;
    final target = accounts
        .cast<BankAccountWithBalance?>()
        .firstWhere((a) => a?.account.id == _bankAccountId, orElse: () => null);
    final current = target != null
        ? target.currentBalance
        : (ref.read(liquiditySummaryProvider).asData?.value.totalLiquidity ??
            0.0);
    if (current - paid >= 0) return true;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          const Text('Negative Balance Warning'),
        ]),
        content: Text(
          'This payment of ${CurrencyFormatter.format(paid)} is more than the balance in ${target?.account.accountName ?? 'Total Liquidity'} (${CurrencyFormatter.format(current)}).\n\n'
          'The balance would become ${CurrencyFormatter.format(current - paid)}.\n\nProceed anyway?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel / Change Account')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
            child: const Text('Proceed Anyway'),
          ),
        ],
      ),
    );
    return proceed == true;
  }

  Future<void> _submit({bool addNew = false}) async {
    if (_saving) return;
    if (_projectId == null) return _snack('Please select a project / site.');
    if (_vendorId == null) return _snack('Please select or add a supplier.');
    final filled = _lines.where((l) => l.isFilled).toList();
    if (filled.isEmpty) return _snack('Add at least one item to the invoice.');
    for (final l in filled) {
      if (_num(l.qty) <= 0) {
        return _snack('Enter a quantity for "${l.item.text.trim()}".');
      }
    }
    if (!await _confirmGstin()) return;

    final companyCode = ref.read(companyStateCodeProvider);
    final inter = _isInterState(companyCode);
    final calc = _calc(inter);
    final grand = calc.totals.grandTotal;
    if (grand <= 0) return _snack('The invoice total must be more than zero.');

    double paidNow = 0;
    if (!_isEditing) {
      switch (_paymentStatus) {
        case PaymentStatus.paid:
          paidNow = grand;
        case PaymentStatus.partial:
          paidNow = _num(_paidCtrl);
          if (paidNow <= 0 || paidNow >= grand) {
            return _snack(paidNow >= grand
                ? 'The amount paid equals the total. Choose "Paid in Full" instead.'
                : 'Enter the amount paid today.');
          }
        case PaymentStatus.pending:
          paidNow = 0;
      }
      if (!await _confirmNegativeBalance(paidNow)) return;
    } else if (grand < _paidSoFar - 0.005) {
      return _snack(
          'The new total ${CurrencyFormatter.format(grand)} is less than the ${CurrencyFormatter.format(_paidSoFar)} already paid.');
    }

    final draft = PurchaseInvoiceDraft(
      date: _date,
      invoiceNo: _invoiceNoCtrl.text,
      invoiceDate: _invoiceDate,
      vendorId: _vendorId!,
      projectId: _projectId!,
      supplierGstin: _gstinCtrl.text,
      supplierState: _state,
      supplierAddress: _addressCtrl.text,
      interState: inter,
      creditDays: (_paymentStatus == PaymentStatus.paid && !_isEditing)
          ? 0
          : (int.tryParse(_creditDaysCtrl.text.trim()) ?? 0),
      transportBy: _transportCtrl.text,
      vehicleNo: _vehicleCtrl.text,
      remarks: _remarksCtrl.text,
      isAdvanceStock: _advanceStock,
      lines: [
        for (final l in filled)
          InvoiceLineDraft(
            purchaseId: l.purchaseId,
            item: l.item.text,
            specification: l.spec.text,
            hsn: l.hsn.text,
            unit: l.unit,
            qty: _num(l.qty),
            rate: _num(l.rate),
            discountPercent: _num(l.disc),
            gstRate: l.gstRate,
            materialCategory: _category,
          ),
      ],
      freight: _num(_freightCtrl),
      loading: _num(_loadingCtrl),
      otherCharges: _num(_otherCtrl),
      roundOff: _roundOff,
      paidNow: paidNow,
      paymentMode: _paymentMode,
      bankAccountId: _bankAccountId,
      paymentReference: _invoiceNoCtrl.text,
    );

    setState(() => _saving = true);
    try {
      final repo = ref.read(purchaseInvoiceRepositoryProvider);
      if (_isEditing) {
        await repo.updateInvoice(widget.invoiceId!, draft);
        if (!mounted) return;
        _snack('✓ Invoice $_purchaseNo updated.', error: false);
        context.go('/purchases');
        return;
      }
      final id = await repo.createInvoice(draft);
      final saved = await repo.getInvoice(id);
      if (!mounted) return;
      _snack('✓ Invoice ${saved?.invoice.purchaseNo ?? ''} saved.',
          error: false);
      if (addNew) {
        _resetForNew();
      } else {
        context.go('/purchases');
      }
    } on ArgumentError catch (e) {
      _snack('${e.message}');
    } on StateError catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('Error saving invoice: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _resetForNew() {
    setState(() {
      _invoiceNoCtrl.clear();
      _invoiceDate = null;
      _vendorId = null;
      _gstinCtrl.clear();
      _addressCtrl.clear();
      _state = null;
      _interOverride = null;
      _transportCtrl.clear();
      _vehicleCtrl.clear();
      _remarksCtrl.clear();
      _freightCtrl.clear();
      _loadingCtrl.clear();
      _otherCtrl.clear();
      _paidCtrl.clear();
      _paymentStatus = PaymentStatus.pending;
      _advanceStock = false;
      for (final l in _lines) {
        l.dispose();
      }
      _lines
        ..clear()
        ..add(_LineCtl());
    });
    _refreshNumber();
  }

  // ─── build ────────────────────────────────────────────────────────────────

  InputDecoration _dec({String? hint, String? prefix, Widget? suffix}) =>
      InputDecoration(
          hintText: hint,
          prefixText: prefix,
          suffixIcon: suffix,
          isDense: true);

  String _fmtDate(DateTime? d) => d == null
      ? ''
      : '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  Widget _dateField(DateTime? value, {required bool invoice}) => InkWell(
        onTap: () => _pickDate(invoice: invoice),
        child: InputDecorator(
          decoration:
              _dec(suffix: Icon(Icons.calendar_today_outlined, size: 16.sp)),
          child: Text(_fmtDate(value).isEmpty ? 'dd-mm-yyyy' : _fmtDate(value),
              style: TextStyle(
                  fontSize: 13.sp,
                  color: value == null ? AppTheme.textMuted : null)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);
    final vendorsAsync = ref.watch(vendorListProvider);
    final accountsAsync = ref.watch(bankAccountsWithBalancesProvider);
    final companyCode = ref.watch(companyStateCodeProvider);

    final inter = _isInterState(companyCode);
    final calc = _calc(inter);
    final grand = calc.totals.grandTotal;
    final paid = _isEditing
        ? _paidSoFar
        : switch (_paymentStatus) {
            PaymentStatus.paid => grand,
            PaymentStatus.partial => _num(_paidCtrl),
            PaymentStatus.pending => 0.0,
          };
    final balance = math.max(0.0, grand - paid);

    void goBack() => context.go('/purchases');

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
            _submit(),
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): () =>
            _submit(),
        const SingleActivator(LogicalKeyboardKey.escape): goBack,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppTheme.surfaceBg,
          body: !_loaded
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ErpPageHeader(
                              title: _isEditing
                                  ? 'Edit Purchase Invoice'
                                  : 'Purchase Entry',
                              subtitle:
                                  'GST purchase invoice: several items, each with its own GST rate',
                              onClose: goBack,
                            ),
                            SizedBox(height: 16.h),
                            _headerPanel(projectsAsync, vendorsAsync,
                                accountsAsync, companyCode, inter),
                            SizedBox(height: 16.h),
                            const ErpSectionTitle('Material Details'),
                            SizedBox(height: 8.h),
                            _itemsTable(inter, calc),
                            SizedBox(height: 10.h),
                            if (_projectId != null && !_advanceStock)
                              BudgetWarningBanner(
                                projectId: _projectId,
                                costHead: BudgetCostHead.materials,
                                addedAmount: grand,
                              ),
                            SizedBox(height: 16.h),
                            _bottomRow(calc, inter, paid, balance),
                          ],
                        ),
                      ),
                    ),
                    ErpActionBar(
                      onCancel: goBack,
                      loading: _saving,
                      onSaveAndNew:
                          _isEditing ? null : () => _submit(addNew: true),
                      onSaveAndClose: () => _submit(),
                      saveLabel: _isEditing ? 'Save Changes' : 'Save & Close',
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── header ───────────────────────────────────────────────────────────────

  Widget _headerPanel(
    AsyncValue<List<Project>> projectsAsync,
    AsyncValue<List<Vendor>> vendorsAsync,
    AsyncValue<List<BankAccountWithBalance>> accountsAsync,
    String? companyCode,
    bool inter,
  ) {
    final gstinText = GstUtils.normalize(_gstinCtrl.text);
    final gstinBad =
        gstinText.isNotEmpty && !GstUtils.hasValidFormat(gstinText);
    final autoInter = GstUtils.isInterStateByCode(companyCode,
        GstUtils.supplierStateCode(gstin: _gstinCtrl.text, stateName: _state));

    return ErpPanel(
      child: ErpColumns(
        children: [
          // column 1: purchase + supplier
          Column(children: [
            ErpField(
              label: 'Purchase No.',
              child: InputDecorator(
                decoration: _dec(),
                child: Text(
                  _purchaseNo.isEmpty ? '…' : _purchaseNo,
                  style:
                      TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            ErpField(
                label: 'Purchase Date',
                required: true,
                child: _dateField(_date, invoice: false)),
            ErpField(
              label: 'Invoice No.',
              child: Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _invoiceNoCtrl,
                    decoration: _dec(hint: 'Supplier invoice no.'),
                  ),
                ),
                SizedBox(width: 8.w),
                SizedBox(
                    width: 150.w,
                    child: _dateField(_invoiceDate, invoice: true)),
              ]),
            ),
            ErpField(
              label: 'Supplier / Vendor',
              required: true,
              child: vendorsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (vendors) => Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      key: ValueKey('vendor-$_vendorId-${vendors.length}'),
                      value: vendors.any((v) => v.id == _vendorId)
                          ? _vendorId
                          : null,
                      isExpanded: true,
                      decoration: _dec(),
                      items: [
                        const DropdownMenuItem<int?>(
                            value: null, child: Text('Select supplier')),
                        ...vendors.map((v) => DropdownMenuItem<int?>(
                            value: v.id,
                            child:
                                Text(v.name, overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) => _onSupplierPicked(v, vendors),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  IconButton.outlined(
                    tooltip: 'Add supplier',
                    onPressed: _addSupplierDialog,
                    icon: Icon(Icons.add, size: 18.sp),
                  ),
                ]),
              ),
            ),
            ErpField(
              label: 'GSTIN',
              child: Row(children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _gstinCtrl,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 15,
                    decoration: InputDecoration(
                      isDense: true,
                      counterText: '',
                      hintText: '32AABFS1234A1Z5',
                      errorText: gstinBad ? 'Not a valid GSTIN format' : null,
                    ),
                    onChanged: _onGstinChanged,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('state-$_state'),
                    value: GstUtils.stateByCode.values.contains(_state)
                        ? _state
                        : null,
                    isExpanded: true,
                    decoration: _dec(hint: 'State'),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text('State')),
                      ...GstUtils.stateByCode.values.map((s) =>
                          DropdownMenuItem<String?>(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (v) => setState(() => _state = v),
                  ),
                ),
              ]),
            ),
            ErpField(
              label: 'Address',
              child: TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: _dec(hint: 'Supplier address (optional)'),
              ),
            ),
          ]),

          // column 2: project + GST type
          Column(children: [
            ErpField(
              label: 'Project / Site',
              required: true,
              child: projectsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (projects) => DropdownButtonFormField<int?>(
                  key: ValueKey('project-$_projectId'),
                  value: projects.any((p) => p.id == _projectId)
                      ? _projectId
                      : null,
                  isExpanded: true,
                  decoration: _dec(),
                  items: [
                    const DropdownMenuItem<int?>(
                        value: null, child: Text('Select project')),
                    ...projects.map((p) => DropdownMenuItem<int?>(
                        value: p.id,
                        child: Text('${p.code} — ${p.name}',
                            overflow: TextOverflow.ellipsis))),
                  ],
                  onChanged: (v) => setState(() => _projectId = v),
                ),
              ),
            ),
            ErpField(
              label: 'Category',
              child: DropdownButtonFormField<String?>(
                key: ValueKey('cat-$_category'),
                value:
                    kStandardMaterialCategories.any((c) => c.name == _category)
                        ? _category
                        : null,
                isExpanded: true,
                decoration: _dec(),
                items: [
                  const DropdownMenuItem<String?>(
                      value: null, child: Text('— None —')),
                  ...kStandardMaterialCategories.map((c) =>
                      DropdownMenuItem<String?>(
                          value: c.name, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
            ),
            ErpField(
              label: 'Purchase Type',
              child: Row(children: [
                Radio<bool>(
                  value: false,
                  groupValue: inter,
                  onChanged: (v) => setState(() => _interOverride = v),
                ),
                InkWell(
                  onTap: () => setState(() => _interOverride = false),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text('Local'),
                  ),
                ),
                SizedBox(width: 12.w),
                Radio<bool>(
                  value: true,
                  groupValue: inter,
                  onChanged: (v) => setState(() => _interOverride = v),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _interOverride = true),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text('Inter State'),
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.only(left: 120.w, bottom: 10.h),
              child: Row(children: [
                Expanded(
                  child: Text(
                    _interOverride != null && _interOverride != autoInter
                        ? 'Set by hand. ${inter ? 'IGST' : 'CGST + SGST'} will be used.'
                        : companyCode == null
                            ? 'Set your company GSTIN in Settings to choose this automatically.'
                            : inter
                                ? 'Supplier is in another state: IGST.'
                                : 'Supplier is in your state: CGST + SGST.',
                    style:
                        TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
                  ),
                ),
                if (_interOverride != null)
                  TextButton(
                    onPressed: () => setState(() => _interOverride = null),
                    child: const Text('Auto'),
                  ),
              ]),
            ),
            ErpField(
              label: 'Stock / Asset',
              child: Row(children: [
                Switch(
                    value: _advanceStock,
                    onChanged: (v) => setState(() => _advanceStock = v)),
                Expanded(
                  child: Text(
                    _advanceStock
                        ? 'Held as stock; not a project cost until allocated.'
                        : 'Normal site purchase; counts as project cost now.',
                    style:
                        TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
                  ),
                ),
              ]),
            ),
          ]),

          // column 3: transport + payment
          Column(children: [
            ErpField(
              label: 'Transport By',
              child: TextFormField(
                  controller: _transportCtrl,
                  decoration: _dec(hint: 'Transporter (optional)')),
            ),
            ErpField(
              label: 'Vehicle No.',
              child: TextFormField(
                  controller: _vehicleCtrl,
                  decoration: _dec(hint: 'e.g. KL 11 AB 1234')),
            ),
            if (_isEditing) ...[
              ErpField(
                label: 'Payment',
                child: Text(
                  'Paid so far ${CurrencyFormatter.format(_paidSoFar)}. Record more payments from the Purchases list.',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
                ),
              ),
              ErpField(
                label: 'Credit Period',
                child: TextFormField(
                  controller: _creditDaysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _dec(prefix: '', hint: 'days'),
                ),
              ),
            ] else ...[
              ErpField(
                label: 'Payment Terms',
                child: DropdownButtonFormField<PaymentStatus>(
                  value: _paymentStatus,
                  isExpanded: true,
                  decoration: _dec(),
                  items: const [
                    DropdownMenuItem(
                        value: PaymentStatus.pending,
                        child: Text('Credit (Unpaid)')),
                    DropdownMenuItem(
                        value: PaymentStatus.partial,
                        child: Text('Partial Advance')),
                    DropdownMenuItem(
                        value: PaymentStatus.paid, child: Text('Paid in Full')),
                  ],
                  onChanged: (v) => setState(
                      () => _paymentStatus = v ?? PaymentStatus.pending),
                ),
              ),
              if (_paymentStatus != PaymentStatus.paid)
                ErpField(
                  label: 'Credit Period',
                  child: TextFormField(
                    controller: _creditDaysCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _dec(hint: 'days'),
                  ),
                ),
              if (_paymentStatus != PaymentStatus.pending) ...[
                ErpField(
                  label: 'Payment Mode',
                  child: DropdownButtonFormField<PaymentMode?>(
                    value: _paymentMode,
                    isExpanded: true,
                    decoration: _dec(),
                    items: [
                      const DropdownMenuItem<PaymentMode?>(
                          value: null, child: Text('— Select Mode —')),
                      ...kSelectablePaymentModes.map((m) =>
                          DropdownMenuItem<PaymentMode?>(
                              value: m, child: Text(m.displayName))),
                    ],
                    onChanged: (v) => setState(() => _paymentMode = v),
                  ),
                ),
                accountsAsync.maybeWhen(
                    data: _accountField, orElse: () => const SizedBox.shrink()),
              ],
              if (_paymentStatus == PaymentStatus.partial)
                ErpField(
                  label: 'Paid Today',
                  required: true,
                  child: TextFormField(
                    key: const Key('inv_paid'),
                    controller: _paidCtrl,
                    decoration: _dec(prefix: '₹ '),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _accountField(List<BankAccountWithBalance> accounts) {
    if (accounts.isEmpty) return const SizedBox.shrink();
    return ErpField(
      label: 'Paid From',
      child: DropdownButtonFormField<int?>(
        value: _bankAccountId,
        isExpanded: true,
        decoration: _dec(),
        items: [
          const DropdownMenuItem<int?>(
              value: null, child: Text('— Auto (Default) —')),
          ...accounts.map((a) => DropdownMenuItem<int?>(
                value: a.account.id,
                child: Row(children: [
                  Expanded(
                    child: Text(
                      '${a.account.accountName} (${a.account.isCashAccount ? 'Cash' : 'Bank'})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(CurrencyFormatter.format(a.currentBalance),
                      style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: a.currentBalance >= 0
                              ? AppTheme.successGreen
                              : AppTheme.dangerRed)),
                ]),
              )),
        ],
        onChanged: (v) => setState(() {
          _bankAccountId = v;
          final picked = accounts.where((a) => a.account.id == v).firstOrNull;
          if (picked != null) {
            _paymentMode = picked.account.isCashAccount
                ? PaymentMode.cash
                : PaymentMode.bank;
          }
        }),
      ),
    );
  }

  // ─── items table ──────────────────────────────────────────────────────────

  static const double _wSr = 44,
      _wItem = 230,
      _wSpec = 150,
      _wHsn = 100,
      _wQty = 90,
      _wUnit = 100,
      _wRate = 100,
      _wDisc = 72,
      _wGst = 86,
      _wTaxable = 120,
      _wTax = 104,
      _wAmount = 130,
      _wDel = 44;

  double _tableWidth(bool inter) =>
      _wSr +
      _wItem +
      _wSpec +
      _wHsn +
      _wQty +
      _wUnit +
      _wRate +
      _wDisc +
      _wGst +
      _wTaxable +
      (inter ? _wTax : _wTax * 2) +
      _wAmount +
      _wDel;

  Widget _cell(double w, Widget child,
          {Alignment align = Alignment.centerLeft}) =>
      SizedBox(
          width: w,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(alignment: align, child: child)));

  Widget _head(double w, String t, {bool right = false}) => _cell(
        w,
        Text(t,
            textAlign: right ? TextAlign.right : TextAlign.left,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMain)),
        align: right ? Alignment.centerRight : Alignment.centerLeft,
      );

  String _m(double v) =>
      CurrencyFormatter.format(v).replaceFirst('₹', '').trim();

  Widget _itemsTable(bool inter, _Calc calc) {
    final defaults =
        ref.watch(itemDefaultsProvider).asData?.value ?? const <ItemDefault>[];
    return ErpPanel(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(builder: (context, c) {
        final width = math.max(c.maxWidth, _tableWidth(inter));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(children: [
                  Container(
                    color: AppTheme.tableHeaderBg,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(children: [
                      _head(_wSr, 'Sr'),
                      _head(_wItem, 'Item / Material *'),
                      _head(_wSpec, 'Specification'),
                      _head(_wHsn, 'HSN / SAC'),
                      _head(_wQty, 'Qty *', right: true),
                      _head(_wUnit, 'Unit'),
                      _head(_wRate, 'Rate (₹)', right: true),
                      _head(_wDisc, 'Disc %', right: true),
                      _head(_wGst, 'GST %'),
                      _head(_wTaxable, 'Taxable (₹)', right: true),
                      if (inter)
                        _head(_wTax, 'IGST (₹)', right: true)
                      else ...[
                        _head(_wTax, 'CGST (₹)', right: true),
                        _head(_wTax, 'SGST (₹)', right: true),
                      ],
                      _head(_wAmount, 'Amount (₹)', right: true),
                      SizedBox(width: _wDel),
                    ]),
                  ),
                  for (var i = 0; i < _lines.length; i++)
                    _lineRow(i, _lines[i], calc.rows[i], inter, defaults),
                ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Wrap(spacing: 10, runSpacing: 8, children: [
                OutlinedButton.icon(
                  onPressed: () => _addLine(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Item'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _addLine(unit: 'Lump sum'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Service / Other'),
                ),
              ]),
            ),
          ],
        );
      }),
    );
  }

  Widget _lineRow(int index, _LineCtl l, GstLineResult r, bool inter,
      List<ItemDefault> defaults) {
    final tight = InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h));
    final slabs = {..._gstSlabs, l.gstRate}.toList()..sort();
    final units = _units.contains(l.unit) ? _units : [l.unit, ..._units];

    Widget numField(TextEditingController c, String keyName, {String? hint}) =>
        TextFormField(
          key: Key('inv_${keyName}_$index'),
          controller: c,
          textAlign: TextAlign.right,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: tight.copyWith(hintText: hint),
          onChanged: (_) => setState(() {}),
        );

    return Container(
      key: ObjectKey(l),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.borderColor))),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        _cell(_wSr, Text('${index + 1}', style: TextStyle(fontSize: 13.sp)),
            align: Alignment.center),
        _cell(
          _wItem,
          RawAutocomplete<ItemDefault>(
            textEditingController: l.item,
            focusNode: l.itemFocus,
            displayStringForOption: (o) => o.itemName,
            optionsBuilder: (v) {
              final q = v.text.trim().toLowerCase();
              if (q.isEmpty) return const Iterable<ItemDefault>.empty();
              return defaults.where((d) => d.itemKey.contains(q)).take(8);
            },
            onSelected: (d) => _applyDefault(l, d),
            fieldViewBuilder: (context, ctrl, focus, onSubmit) => TextFormField(
              key: Key('inv_item_$index'),
              controller: ctrl,
              focusNode: focus,
              decoration: tight.copyWith(hintText: 'e.g. TMT Steel 12mm'),
              onChanged: (_) => setState(() {}),
            ),
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 360, maxHeight: 240),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (final o in options)
                        ListTile(
                          dense: true,
                          title: Text(o.itemName),
                          subtitle: Text(
                              '${(o.hsn ?? '').isEmpty ? 'No HSN' : 'HSN ${o.hsn}'}  ·  GST ${_plain(o.gstRate)}%${(o.unit ?? '').isEmpty ? '' : '  ·  ${o.unit}'}'),
                          onTap: () => onSelected(o),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _cell(
            _wSpec,
            TextFormField(
                controller: l.spec,
                decoration: tight.copyWith(hintText: '12mm Fe500D'))),
        _cell(
          _wHsn,
          TextFormField(
              key: Key('inv_hsn_$index'), controller: l.hsn, decoration: tight),
        ),
        _cell(_wQty, numField(l.qty, 'qty')),
        _cell(
          _wUnit,
          DropdownButtonFormField<String>(
            value: l.unit,
            isExpanded: true,
            decoration: tight,
            items: [
              for (final u in units)
                DropdownMenuItem(
                    value: u, child: Text(u, overflow: TextOverflow.ellipsis))
            ],
            onChanged: (v) => setState(() => l.unit = v ?? l.unit),
          ),
        ),
        _cell(_wRate, numField(l.rate, 'rate', hint: '0.00')),
        _cell(_wDisc, numField(l.disc, 'disc', hint: '0')),
        _cell(
          _wGst,
          DropdownButtonFormField<double>(
            key: Key('inv_gst_$index'),
            value: l.gstRate,
            isExpanded: true,
            decoration: tight,
            items: [
              for (final s in slabs)
                DropdownMenuItem(value: s, child: Text('${_plain(s)}%')),
              const DropdownMenuItem(value: -1, child: Text('Other…')),
            ],
            onChanged: (v) {
              if (v == null) return;
              if (v == -1) {
                _askCustomRate(l);
              } else {
                setState(() => l.gstRate = v);
              }
            },
          ),
        ),
        _cell(_wTaxable, Text(_m(r.taxable), style: TextStyle(fontSize: 13.sp)),
            align: Alignment.centerRight),
        if (inter)
          _cell(_wTax, Text(_m(r.igst), style: TextStyle(fontSize: 13.sp)),
              align: Alignment.centerRight)
        else ...[
          _cell(_wTax, Text(_m(r.cgst), style: TextStyle(fontSize: 13.sp)),
              align: Alignment.centerRight),
          _cell(_wTax, Text(_m(r.sgst), style: TextStyle(fontSize: 13.sp)),
              align: Alignment.centerRight),
        ],
        _cell(
            _wAmount,
            Text(_m(r.total),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
            align: Alignment.centerRight),
        SizedBox(
          width: _wDel,
          child: IconButton(
            tooltip: 'Remove this row',
            onPressed: () => _removeLine(l),
            icon: Icon(Icons.delete_outline_rounded,
                size: 18.sp, color: AppTheme.dangerRed),
          ),
        ),
      ]),
    );
  }

  // ─── bottom: charges / remarks / totals ───────────────────────────────────

  Widget _bottomRow(_Calc calc, bool inter, double paid, double balance) {
    final t = calc.totals;
    Widget chargeField(String label, TextEditingController c, String keyName) =>
        ErpField(
          label: label,
          labelWidth: 130,
          child: TextFormField(
            key: Key(keyName),
            controller: c,
            textAlign: TextAlign.right,
            decoration: _dec(prefix: '₹ ', hint: '0.00'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
          ),
        );

    return ErpColumns(
      children: [
        ErpPanel(
          title: 'Other Charges',
          child: Column(children: [
            chargeField('Transport / Freight', _freightCtrl, 'inv_freight'),
            chargeField('Loading / Unloading', _loadingCtrl, 'inv_loading'),
            chargeField('Other Charges', _otherCtrl, 'inv_other'),
            Row(children: [
              Switch(
                  value: _roundOff,
                  onChanged: (v) => setState(() => _roundOff = v)),
              Expanded(
                child: Text('Round off the total to the nearest rupee',
                    style:
                        TextStyle(fontSize: 12.sp, color: AppTheme.textMuted)),
              ),
            ]),
            Text('Charges are added without GST.',
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
          ]),
        ),
        ErpPanel(
          title: 'Remarks',
          child: TextFormField(
            controller: _remarksCtrl,
            maxLines: 6,
            decoration: const InputDecoration(
                hintText: 'Remarks / narration (optional)'),
          ),
        ),
        ErpPanel(
          color: AppTheme.totalsBg,
          borderColor: AppTheme.totalsBorder,
          child: Column(children: [
            ErpTotalLine(
                label: 'Items (before discount)',
                value: CurrencyFormatter.format(t.gross)),
            ErpTotalLine(
                label: 'Total Discount',
                value: CurrencyFormatter.format(t.discount)),
            ErpTotalLine(
                label: 'Taxable Value',
                value: CurrencyFormatter.format(t.taxable)),
            if (inter)
              ErpTotalLine(
                  label: 'IGST', value: CurrencyFormatter.format(t.igst))
            else ...[
              ErpTotalLine(
                  label: 'CGST', value: CurrencyFormatter.format(t.cgst)),
              ErpTotalLine(
                  label: 'SGST', value: CurrencyFormatter.format(t.sgst)),
            ],
            ErpTotalLine(
                label: 'Other Charges',
                value: CurrencyFormatter.format(t.otherCharges)),
            ErpTotalLine(
                label: 'Round Off',
                value: CurrencyFormatter.format(t.roundOff)),
            Divider(color: AppTheme.totalsBorder, height: 18.h),
            Row(children: [
              Expanded(
                child: Text('Grand Total',
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBlue)),
              ),
              Text(CurrencyFormatter.format(t.grandTotal),
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlue)),
            ]),
            Divider(color: AppTheme.totalsBorder, height: 18.h),
            ErpTotalLine(
                label: _isEditing ? 'Paid so far' : 'Paid Now',
                value: CurrencyFormatter.format(paid)),
            ErpTotalLine(
              label: 'Balance Payable',
              value: CurrencyFormatter.format(balance),
              bold: true,
              color: balance > 0 ? AppTheme.dangerRed : AppTheme.textMain,
            ),
          ]),
        ),
      ],
    );
  }
}

class _Calc {
  final List<GstLineResult> rows;
  final GstInvoiceTotals totals;
  const _Calc(this.rows, this.totals);
}
