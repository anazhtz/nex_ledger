import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/constants/material_constants.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/shared/widgets/erp_widgets.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/budget_warning_banner.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';

class PurchaseFormScreen extends ConsumerStatefulWidget {
  final int? purchaseId;
  const PurchaseFormScreen({super.key, this.purchaseId});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _rateCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'Nos');
  final _amountCtrl = TextEditingController();
  final _paidAmountCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _newVendorCtrl = TextEditingController();

  static const List<String> _commonUnits = [
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

  late List<MaterialCategoryPreset> _categories;

  int? _selectedProject;
  int? _selectedVendor;
  String? _selectedCategory;
  PaymentStatus _paymentStatus = PaymentStatus.pending;
  PaymentMode? _paymentMode;
  int? _selectedBankAccountId;
  DateTime _date = DateTime.now();
  bool _isAdvanceStock = false;
  bool _loading = false;
  bool _showAddVendor = false;

  bool get _isEditing => widget.purchaseId != null;

  @override
  void initState() {
    super.initState();
    _categories = List.from(kStandardMaterialCategories);
    _selectedProject = ref.read(selectedProjectIdProvider);
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPurchase());
    }
  }

  Future<void> _loadPurchase() async {
    final repo = ref.read(purchaseRepositoryProvider);
    final pd = await repo.getPurchaseById(widget.purchaseId!);
    if (pd != null && mounted) {
      setState(() {
        _selectedProject = pd.project.id;
        _selectedVendor = pd.vendor.id;
        _date = pd.transaction.date;
        _descCtrl.text = pd.purchase.itemDescription;
        _qtyCtrl.text = pd.purchase.quantity % 1 == 0
            ? pd.purchase.quantity.toInt().toString()
            : pd.purchase.quantity.toString();
        _rateCtrl.text = pd.purchase.unitRate % 1 == 0
            ? pd.purchase.unitRate.toInt().toString()
            : pd.purchase.unitRate.toStringAsFixed(2);
        _unitCtrl.text = pd.purchase.unit ?? 'Nos';
        _amountCtrl.text = pd.transaction.amount % 1 == 0
            ? pd.transaction.amount.toInt().toString()
            : pd.transaction.amount.toStringAsFixed(2);
        _paidAmountCtrl.text = pd.purchase.paidAmount % 1 == 0
            ? pd.purchase.paidAmount.toInt().toString()
            : pd.purchase.paidAmount.toStringAsFixed(2);
        _paymentStatus = pd.purchase.paymentStatus;
        _paymentMode = pd.transaction.paymentMode?.normalized;
        _selectedBankAccountId = pd.transaction.bankAccountId;
        _narrationCtrl.text = pd.transaction.narration ?? '';
        _refCtrl.text = pd.transaction.referenceNo ?? '';
        _isAdvanceStock = pd.purchase.isAdvanceStock;
        _selectedCategory = pd.purchase.materialCategory;

        if (pd.purchase.materialCategory != null &&
            !_categories.any((c) => c.name == pd.purchase.materialCategory)) {
          _categories.insert(
            0,
            MaterialCategoryPreset(
              name: pd.purchase.materialCategory!,
              defaultUnit: pd.purchase.unit ?? 'Nos',
              icon: Icons.category_rounded,
              color: const Color(0xFF1F5FBF),
              commonItems: [pd.purchase.itemDescription],
            ),
          );
        }
      });
    }
  }

  Future<void> _openAddCustomCategoryDialog({String? prefillName}) async {
    final nameCtrl = TextEditingController(text: prefillName ?? '');
    final itemsCtrl = TextEditingController();
    String selectedUnit = 'Nos';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FB),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.category_rounded,
                      color: const Color(0xFF1F5FBF), size: 20.sp),
                ),
                SizedBox(width: 10.w),
                const Text('Add Custom Material Category'),
              ],
            ),
            content: SizedBox(
              width: 440.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Define a custom material or service category with a default unit of measurement.',
                    style: TextStyle(
                        fontSize: 12.sp, color: const Color(0xFF64748B)),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Category Name *',
                      hintText: 'e.g. UPVC Windows, Solar Panels, Scaffolding',
                      prefixIcon: Icon(Icons.label_outline_rounded),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Default Unit of Measurement *',
                      prefixIcon: Icon(Icons.straighten_rounded),
                    ),
                    items: _commonUnits
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (u) {
                      if (u != null) setDialogState(() => selectedUnit = u);
                    },
                  ),
                  SizedBox(height: 14.h),
                  TextField(
                    controller: itemsCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Quick Item Presets (comma separated, optional)',
                      hintText: 'e.g. 540W Solar Panel, 5kW Hybrid Inverter',
                      prefixIcon: Icon(Icons.format_list_bulleted_rounded),
                    ),
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
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;

                  final items = itemsCtrl.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  final newCat = MaterialCategoryPreset(
                    name: name,
                    defaultUnit: selectedUnit,
                    icon: Icons.category_rounded,
                    color: const Color(0xFF1F5FBF),
                    commonItems: items.isNotEmpty ? items : [name],
                  );

                  setState(() {
                    _categories.insert(0, newCat);
                    _selectedCategory = name;
                    _unitCtrl.text = selectedUnit;
                    if (items.isNotEmpty && _descCtrl.text.isEmpty) {
                      _descCtrl.text = items.first;
                    } else if (_descCtrl.text.isEmpty) {
                      _descCtrl.text = name;
                    }
                  });

                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1F5FBF)),
                child: const Text('Add & Select Category'),
              ),
            ],
          );
        },
      ),
    );
    nameCtrl.dispose();
    itemsCtrl.dispose();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _unitCtrl.dispose();
    _amountCtrl.dispose();
    _paidAmountCtrl.dispose();
    _narrationCtrl.dispose();
    _refCtrl.dispose();
    _newVendorCtrl.dispose();
    super.dispose();
  }

  void _onQtyOrRateChanged() {
    final qty =
        double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final rate =
        double.tryParse(_rateCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    if (qty > 0 && rate > 0) {
      final total = qty * rate;
      _amountCtrl.text =
          total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(2);
      if (_paymentStatus == PaymentStatus.paid) {
        _paidAmountCtrl.text = _amountCtrl.text;
      }
    }
  }

  Future<void> _addVendor() async {
    if (_newVendorCtrl.text.isEmpty) return;
    final repo = ref.read(purchaseRepositoryProvider);
    final id = await repo.addVendor(_newVendorCtrl.text.trim());
    setState(() {
      _selectedVendor = id;
      _showAddVendor = false;
      _newVendorCtrl.clear();
    });
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

  Future<void> _submit({bool addNew = false}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target project.')),
      );
      return;
    }
    if (_selectedVendor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add a vendor.')),
      );
      return;
    }

    final cleanAmountStr =
        _amountCtrl.text.replaceAll(',', '').replaceAll(' ', '').trim();
    final amount = double.tryParse(cleanAmountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    final qty =
        double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 1.0;
    final unitRate =
        double.tryParse(_rateCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final unit =
        _unitCtrl.text.trim().isNotEmpty ? _unitCtrl.text.trim() : null;

    double paidAmount = 0.0;
    if (_paymentStatus == PaymentStatus.paid) {
      paidAmount = amount;
    } else if (_paymentStatus == PaymentStatus.partial) {
      final cleanPaidStr =
          _paidAmountCtrl.text.replaceAll(',', '').replaceAll(' ', '').trim();
      paidAmount = double.tryParse(cleanPaidStr) ?? 0.0;
      if (paidAmount < 0 || paidAmount >= amount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paidAmount >= amount
                  ? 'Paid amount equals/exceeds total bill. Select "Paid in Full" instead.'
                  : 'Please enter a valid advance paid amount.',
            ),
          ),
        );
        return;
      }
    }

    // Negative balance check on cash payment
    if (paidAmount > 0) {
      final accountsWithBalances =
          ref.read(bankAccountsWithBalancesProvider).asData?.value;
      if (accountsWithBalances != null && accountsWithBalances.isNotEmpty) {
        final targetAcc =
            accountsWithBalances.cast<BankAccountWithBalance?>().firstWhere(
                  (a) => a?.account.id == _selectedBankAccountId,
                  orElse: () => null,
                );
        final currentBal = targetAcc != null
            ? targetAcc.currentBalance
            : (ref
                    .read(liquiditySummaryProvider)
                    .asData
                    ?.value
                    .totalLiquidity ??
                0.0);

        if (currentBal - paidAmount < 0) {
          final proceed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  const Text('Negative Balance Warning'),
                ],
              ),
              content: Text(
                'This purchase cash outflow of ${CurrencyFormatter.format(paidAmount)} exceeds your current balance in ${targetAcc?.account.accountName ?? 'Total Liquidity'} (${CurrencyFormatter.format(currentBal)}).\n\n'
                'Recording this will make your balance negative (${CurrencyFormatter.format(currentBal - paidAmount)}).\n\n'
                'Do you wish to proceed anyway?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel / Change Account'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange.shade800),
                  child: const Text('Proceed Anyway'),
                ),
              ],
            ),
          );
          if (proceed != true) return;
        }
      }
    }

    setState(() => _loading = true);
    try {
      if (_isEditing) {
        await ref.read(purchaseRepositoryProvider).updatePurchase(
              purchaseId: widget.purchaseId!,
              projectId: _selectedProject!,
              vendorId: _selectedVendor!,
              date: _date,
              itemDescription: _descCtrl.text.trim(),
              amount: amount,
              quantity: qty,
              unitRate: unitRate,
              unit: unit,
              materialCategory: _selectedCategory,
              paidAmount: paidAmount,
              paymentStatus: _paymentStatus,
              paymentMode: _paymentMode,
              bankAccountId: _selectedBankAccountId,
              narration: _narrationCtrl.text.isNotEmpty
                  ? _narrationCtrl.text.trim()
                  : null,
              referenceNo:
                  _refCtrl.text.isNotEmpty ? _refCtrl.text.trim() : null,
              isAdvanceStock: _isAdvanceStock,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Purchase entry updated successfully!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
          context.go('/purchases');
        }
        return;
      }

      await ref.read(purchaseRepositoryProvider).addPurchase(
            projectId: _selectedProject!,
            vendorId: _selectedVendor!,
            date: _date,
            itemDescription: _descCtrl.text.trim(),
            amount: amount,
            quantity: qty,
            unitRate: unitRate,
            unit: unit,
            materialCategory: _selectedCategory,
            paidAmount: paidAmount,
            paymentStatus: _paymentStatus,
            paymentMode: _paymentMode,
            bankAccountId: _selectedBankAccountId,
            narration: _narrationCtrl.text.isNotEmpty
                ? _narrationCtrl.text.trim()
                : null,
            referenceNo: _refCtrl.text.isNotEmpty ? _refCtrl.text.trim() : null,
            isAdvanceStock: _isAdvanceStock,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Purchase entry recorded successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        if (addNew) {
          _formKey.currentState?.reset();
          setState(_resetForNewEntry);
        } else {
          context.go('/purchases');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving purchase: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').replaceAll(' ', '').trim()) ??
      0.0;

  InputDecoration _dec({String? hint, String? prefix, Widget? suffix}) =>
      InputDecoration(hintText: hint, prefixText: prefix, suffixIcon: suffix);

  String get _dateText => '${_date.day.toString().padLeft(2, '0')}-'
      '${_date.month.toString().padLeft(2, '0')}-${_date.year}';

  void _resetForNewEntry() {
    _descCtrl.clear();
    _qtyCtrl.text = '1';
    _rateCtrl.clear();
    _unitCtrl.text = 'Nos';
    _amountCtrl.clear();
    _paidAmountCtrl.clear();
    _narrationCtrl.clear();
    _refCtrl.clear();
    _selectedCategory = null;
    _paymentStatus = PaymentStatus.pending;
    _paymentMode = null;
    _isAdvanceStock = false;
  }

  Widget _tableHead(String text, {TextAlign align = TextAlign.left}) => Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMain,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);
    final vendorsAsync = ref.watch(vendorListProvider);
    final accountsAsync = ref.watch(bankAccountsWithBalancesProvider);

    final total = _parse(_amountCtrl);
    final paid = switch (_paymentStatus) {
      PaymentStatus.paid => total,
      PaymentStatus.partial => _parse(_paidAmountCtrl),
      PaymentStatus.pending => 0.0,
    };
    final balance = (total - paid).clamp(0.0, double.infinity);

    void goBack() => context.go('/purchases');

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): goBack,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppTheme.surfaceBg,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ErpPageHeader(
                          title: _isEditing
                              ? 'Edit Purchase Entry'
                              : 'Purchase Entry',
                          subtitle:
                              'Record materials, equipment, petty expenses and vendor bills',
                          onClose: goBack,
                        ),
                        SizedBox(height: 16.h),

                        // ── Header details ───────────────────────────────
                        ErpPanel(
                          child: ErpColumns(
                            children: [
                              Column(children: [
                                ErpField(
                                  label: 'Purchase Date',
                                  required: true,
                                  child: InkWell(
                                    onTap: _pickDate,
                                    child: InputDecorator(
                                      decoration: _dec(
                                        suffix: Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16.sp),
                                      ),
                                      child: Text(_dateText,
                                          style: TextStyle(fontSize: 13.sp)),
                                    ),
                                  ),
                                ),
                                ErpField(
                                  label: 'Bill / Challan No.',
                                  child: TextFormField(
                                    controller: _refCtrl,
                                    decoration:
                                        _dec(hint: 'Invoice or challan number'),
                                  ),
                                ),
                                ErpField(
                                  label: 'Category',
                                  child: Row(children: [
                                    Expanded(child: _buildCategoryDropdown()),
                                    SizedBox(width: 6.w),
                                    IconButton.outlined(
                                      tooltip: 'Add custom category',
                                      onPressed: () =>
                                          _openAddCustomCategoryDialog(),
                                      icon: Icon(Icons.add, size: 18.sp),
                                    ),
                                  ]),
                                ),
                              ]),
                              Column(children: [
                                ErpField(
                                  label: 'Project / Site',
                                  required: true,
                                  child: projectsAsync.when(
                                    loading: () =>
                                        const LinearProgressIndicator(),
                                    error: (e, _) => Text('Error: $e'),
                                    data: _buildProjectDropdown,
                                  ),
                                ),
                                ErpField(
                                  label: 'Supplier / Vendor',
                                  required: true,
                                  child: vendorsAsync.when(
                                    loading: () =>
                                        const LinearProgressIndicator(),
                                    error: (e, _) => Text('Error: $e'),
                                    data: _buildVendorField,
                                  ),
                                ),
                                if (_showAddVendor)
                                  ErpField(
                                    label: 'New Vendor',
                                    child: Row(children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _newVendorCtrl,
                                          decoration: _dec(
                                              hint: 'e.g. ABC Steel Suppliers'),
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      FilledButton(
                                        onPressed: _addVendor,
                                        child: const Text('Add'),
                                      ),
                                    ]),
                                  ),
                              ]),
                              Column(children: [
                                ErpField(
                                  label: 'Payment Terms',
                                  child: DropdownButtonFormField<PaymentStatus>(
                                    value: _paymentStatus,
                                    isExpanded: true,
                                    decoration: _dec(),
                                    items: const [
                                      DropdownMenuItem(
                                        value: PaymentStatus.pending,
                                        child: Text('Credit (Unpaid)'),
                                      ),
                                      DropdownMenuItem(
                                        value: PaymentStatus.partial,
                                        child: Text('Partial Advance'),
                                      ),
                                      DropdownMenuItem(
                                        value: PaymentStatus.paid,
                                        child: Text('Paid in Full'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() {
                                        _paymentStatus = v;
                                        if (v == PaymentStatus.paid) {
                                          _paidAmountCtrl.text =
                                              _amountCtrl.text;
                                        } else if (v == PaymentStatus.pending) {
                                          _paidAmountCtrl.text = '0';
                                        }
                                      });
                                    },
                                  ),
                                ),
                                if (_paymentStatus !=
                                    PaymentStatus.pending) ...[
                                  ErpField(
                                    label: 'Payment Mode',
                                    child:
                                        DropdownButtonFormField<PaymentMode?>(
                                      value: _paymentMode,
                                      isExpanded: true,
                                      decoration: _dec(),
                                      items: [
                                        const DropdownMenuItem(
                                            value: null,
                                            child: Text('— Select Mode —')),
                                        ...kSelectablePaymentModes.map(
                                          (m) => DropdownMenuItem(
                                              value: m,
                                              child: Text(m.displayName)),
                                        ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => _paymentMode = v),
                                    ),
                                  ),
                                  accountsAsync.maybeWhen(
                                    data: _buildAccountField,
                                    orElse: () => const SizedBox.shrink(),
                                  ),
                                ],
                                if (_paymentStatus == PaymentStatus.partial)
                                  ErpField(
                                    label: 'Paid Today',
                                    required: true,
                                    child: TextFormField(
                                      controller: _paidAmountCtrl,
                                      decoration: _dec(prefix: '₹ '),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                              ]),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ── Material details ─────────────────────────────
                        const ErpSectionTitle('Material Details'),
                        SizedBox(height: 8.h),
                        _buildItemTable(),
                        if (_selectedCategory != null) _buildQuickItems(),
                        if (_selectedProject != null &&
                            _selectedCategory != null &&
                            !_isAdvanceStock) ...[
                          SizedBox(height: 10.h),
                          _buildLiveMaterialConsumptionCard(context),
                        ],
                        if (_selectedProject != null && !_isAdvanceStock)
                          BudgetWarningBanner(
                            projectId: _selectedProject,
                            costHead: BudgetCostHead.materials,
                            addedAmount: total,
                          ),
                        SizedBox(height: 16.h),

                        // ── Bottom: options / remarks / totals ───────────
                        LayoutBuilder(builder: (context, c) {
                          final options = _buildOptionsPanel();
                          final remarks = ErpPanel(
                            title: 'Remarks',
                            child: TextFormField(
                              controller: _narrationCtrl,
                              minLines: 4,
                              maxLines: 4,
                              decoration:
                                  _dec(hint: 'Remarks / narration (optional)'),
                            ),
                          );
                          final totals =
                              _buildTotalsPanel(total, paid, balance);
                          if (c.maxWidth < 900) {
                            return Column(children: [
                              options,
                              SizedBox(height: 12.h),
                              remarks,
                              SizedBox(height: 12.h),
                              totals,
                            ]);
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 4, child: options),
                              SizedBox(width: 14.w),
                              Expanded(flex: 4, child: remarks),
                              SizedBox(width: 14.w),
                              Expanded(flex: 4, child: totals),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              ErpActionBar(
                onCancel: goBack,
                loading: _loading,
                onSaveAndNew: _isEditing ? null : () => _submit(addNew: true),
                onSaveAndClose: _submit,
                saveLabel: _isEditing ? 'Update & Close' : 'Save & Close',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header pieces ───────────────────────────────────────────────────────

  Widget _buildProjectDropdown(List<Project> projects) {
    final value =
        projects.any((p) => p.id == _selectedProject) ? _selectedProject : null;
    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      decoration: _dec(hint: 'Select project'),
      items: projects
          .map((p) => DropdownMenuItem(
                value: p.id,
                child: Text('${p.code} — ${p.name}',
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedProject = v),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildVendorField(List<Vendor> vendors) {
    final value =
        vendors.any((v) => v.id == _selectedVendor) ? _selectedVendor : null;
    return Row(children: [
      Expanded(
        child: DropdownButtonFormField<int>(
          value: value,
          isExpanded: true,
          decoration: _dec(hint: 'Select supplier'),
          items: vendors
              .map((v) => DropdownMenuItem(
                    value: v.id,
                    child: Text(v.name, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedVendor = v),
          validator: (v) => v == null ? 'Required' : null,
        ),
      ),
      SizedBox(width: 6.w),
      IconButton.outlined(
        tooltip: _showAddVendor ? 'Cancel' : 'Add new vendor',
        onPressed: () => setState(() => _showAddVendor = !_showAddVendor),
        icon: Icon(_showAddVendor ? Icons.close : Icons.add, size: 18.sp),
      ),
    ]);
  }

  Widget _buildAccountField(List<BankAccountWithBalance> accounts) {
    if (accounts.isEmpty) return const SizedBox.shrink();
    return ErpField(
      label: 'Paid From',
      child: DropdownButtonFormField<int?>(
        value: _selectedBankAccountId,
        isExpanded: true,
        decoration: _dec(),
        items: [
          const DropdownMenuItem(
              value: null, child: Text('— Auto (Default) —')),
          ...accounts.map(
            (a) => DropdownMenuItem(
              value: a.account.id,
              child: Row(children: [
                Expanded(
                  child: Text(
                    '${a.account.accountName} (${a.account.isCashAccount ? 'Cash' : 'Bank'})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(a.currentBalance),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: a.currentBalance >= 0
                        ? AppTheme.successGreen
                        : AppTheme.dangerRed,
                  ),
                ),
              ]),
            ),
          ),
        ],
        onChanged: (v) => setState(() {
          _selectedBankAccountId = v;
          // Keep Payment Mode in step with the chosen account.
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

  Widget _buildCategoryDropdown() {
    final value = _categories.any((c) => c.name == _selectedCategory)
        ? _selectedCategory
        : null;
    return DropdownButtonFormField<String?>(
      value: value,
      isExpanded: true,
      decoration: _dec(hint: 'Select category'),
      items: [
        const DropdownMenuItem(value: null, child: Text('— None —')),
        ..._categories.map(
          (c) => DropdownMenuItem(
            value: c.name,
            child: Row(children: [
              Icon(c.icon, size: 16.sp, color: c.color),
              SizedBox(width: 8.w),
              Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis)),
              Text(c.defaultUnit,
                  style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
            ]),
          ),
        ),
      ],
      onChanged: (name) {
        setState(() {
          _selectedCategory = name;
          final preset = _categories.where((c) => c.name == name).firstOrNull;
          if (preset != null) {
            _unitCtrl.text = preset.defaultUnit;
            if (_descCtrl.text.isEmpty) {
              _descCtrl.text = preset.commonItems.isNotEmpty
                  ? preset.commonItems.first
                  : preset.name;
            }
          }
        });
      },
    );
  }

  // ── Item table ──────────────────────────────────────────────────────────

  Widget _buildItemTable() {
    const flexes = [6, 2, 2, 2, 3];
    Widget cell(int i, Widget child) => Expanded(
          flex: flexes[i],
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: child,
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        Container(
          color: AppTheme.tableHeaderBg,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
          child: Row(children: [
            cell(0, _tableHead('Item / Material / Service *')),
            cell(1, _tableHead('Qty *', align: TextAlign.right)),
            cell(2, _tableHead('Unit')),
            cell(3, _tableHead('Rate (₹)', align: TextAlign.right)),
            cell(4, _tableHead('Amount (₹) *', align: TextAlign.right)),
          ]),
        ),
        Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            cell(
              0,
              TextFormField(
                controller: _descCtrl,
                decoration: _dec(hint: 'e.g. 53 Grade Cement, 12mm TMT Steel'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ),
            cell(
              1,
              TextFormField(
                controller: _qtyCtrl,
                textAlign: TextAlign.right,
                decoration: _dec(hint: '1'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(_onQtyOrRateChanged),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = double.tryParse(v.replaceAll(',', ''));
                  return (n == null || n <= 0) ? 'Invalid' : null;
                },
              ),
            ),
            cell(
              2,
              DropdownButtonFormField<String>(
                value: _commonUnits.contains(_unitCtrl.text)
                    ? _unitCtrl.text
                    : 'Nos',
                isExpanded: true,
                decoration: _dec(),
                items: _commonUnits
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _unitCtrl.text = v);
                },
              ),
            ),
            cell(
              3,
              TextFormField(
                controller: _rateCtrl,
                textAlign: TextAlign.right,
                decoration: _dec(hint: '0.00'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(_onQtyOrRateChanged),
              ),
            ),
            cell(
              4,
              TextFormField(
                controller: _amountCtrl,
                textAlign: TextAlign.right,
                decoration: _dec(hint: 'Auto or enter total'),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  return double.tryParse(v.replaceAll(',', '')) == null
                      ? 'Invalid'
                      : null;
                },
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildQuickItems() {
    final preset =
        _categories.where((c) => c.name == _selectedCategory).firstOrNull;
    if (preset == null || preset.commonItems.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Quick items:',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted)),
          ...preset.commonItems.map((item) {
            final selected = _descCtrl.text == item;
            return ChoiceChip(
              label: Text(item),
              selected: selected,
              showCheckmark: false,
              selectedColor: AppTheme.primaryBlue,
              backgroundColor: Colors.white,
              side: BorderSide(
                  color:
                      selected ? AppTheme.primaryBlue : AppTheme.borderColor),
              labelStyle: TextStyle(
                fontSize: 12.sp,
                color: selected ? Colors.white : AppTheme.textMain,
              ),
              onSelected: (_) => setState(() {
                _descCtrl.text = item;
                _unitCtrl.text = preset.defaultUnit;
              }),
            );
          }),
        ],
      ),
    );
  }

  // ── Bottom panels ───────────────────────────────────────────────────────

  Widget _buildOptionsPanel() {
    final pending = _paymentStatus == PaymentStatus.pending;
    return ErpPanel(
      title: 'Treatment & Notes',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color:
                _isAdvanceStock ? const Color(0xFFFEF3C7) : AppTheme.surfaceBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _isAdvanceStock
                  ? const Color(0xFFD97706)
                  : AppTheme.borderColor,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _isAdvanceStock,
              title: Text('Hold as Advance Stock / Asset',
                  style:
                      TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
              subtitle: Text(
                _isAdvanceStock
                    ? 'Bulk stock for future allocation. Does not hit P&L now.'
                    : 'Standard site purchase — hits project P&L immediately.',
                style: TextStyle(fontSize: 11.sp),
              ),
              onChanged: (v) => setState(() => _isAdvanceStock = v),
            ),
          ),
        ),
        if (pending) ...[
          SizedBox(height: 10.h),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline,
                size: 16.sp, color: const Color(0xFFB45309)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Credit purchase: full amount is recorded as Accounts Payable. '
                'Project P&L recognises the cost now; cash falls only when you pay.',
                style: TextStyle(
                    fontSize: 11.5.sp, color: const Color(0xFF92400E)),
              ),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _buildTotalsPanel(double total, double paid, double balance) {
    return ErpPanel(
      color: AppTheme.totalsBg,
      borderColor: AppTheme.totalsBorder,
      child: Column(children: [
        ErpTotalLine(
            label: 'Total Bill Amount', value: CurrencyFormatter.format(total)),
        ErpTotalLine(label: 'Paid Now', value: CurrencyFormatter.format(paid)),
        Divider(color: AppTheme.totalsBorder, height: 16.h),
        ErpTotalLine(
          label: 'Balance Payable (Credit)',
          value: CurrencyFormatter.format(balance),
          bold: true,
          color: balance > 0 ? AppTheme.dangerRed : AppTheme.textMain,
        ),
        Divider(color: AppTheme.totalsBorder, height: 20.h),
        Row(children: [
          Expanded(
            child: Text('Grand Total',
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBlue)),
          ),
          Text(CurrencyFormatter.format(total),
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue)),
        ]),
      ]),
    );
  }

  Widget _buildLiveMaterialConsumptionCard(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final statsAsync = ref.watch(projectSingleMaterialConsumptionProvider(
          (projectId: _selectedProject!, category: _selectedCategory!),
        ));

        return statsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (summary) {
            if (summary == null || summary.totalQuantity <= 0) {
              return Container(
                margin: EdgeInsets.only(bottom: 14.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'First entry for $_selectedCategory under this project. No previous bills.',
                        style: TextStyle(
                            fontSize: 11.sp, color: const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              );
            }

            final qtyStr = summary.totalQuantity % 1 == 0
                ? summary.totalQuantity.toInt().toString()
                : summary.totalQuantity.toStringAsFixed(1);

            return Container(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(Icons.analytics_outlined,
                        size: 18.sp, color: const Color(0xFF2563EB)),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project History: $qtyStr ${summary.unit} of $_selectedCategory already procured',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Total spend: ${CurrencyFormatter.format(summary.totalAmount)} across ${summary.billCount} bills • Avg Rate: ${CurrencyFormatter.format(summary.avgUnitRate)}/${summary.unit}${summary.lastVendorName != null ? ' • Last vendor: ${summary.lastVendorName}' : ''}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
