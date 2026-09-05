import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/budget_warning_banner.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';

/// Preset item shortcuts to make entry effortless for site supervisors & employees.
class _QuickItemPreset {
  final String label;
  final String defaultItemName;
  final String defaultUnit;
  final String category;
  final IconData icon;

  const _QuickItemPreset({
    required this.label,
    required this.defaultItemName,
    required this.defaultUnit,
    required this.category,
    required this.icon,
  });
}

const List<_QuickItemPreset> _kQuickItems = [
  _QuickItemPreset(
    label: 'Cement',
    defaultItemName: '53 Grade Cement',
    defaultUnit: 'Bags',
    category: 'Cement',
    icon: Icons.view_in_ar_rounded,
  ),
  _QuickItemPreset(
    label: 'Granite / Tiles',
    defaultItemName: 'Tiles / Granite Slabs',
    defaultUnit: 'Sq.ft',
    category: 'Tiles & Marble',
    icon: Icons.grid_view_rounded,
  ),
  _QuickItemPreset(
    label: 'Sand',
    defaultItemName: 'M-Sand / River Sand',
    defaultUnit: 'CFT',
    category: 'Sand',
    icon: Icons.grain_rounded,
  ),
  _QuickItemPreset(
    label: 'TMT Steel',
    defaultItemName: 'TMT Steel Rods',
    defaultUnit: 'Tons',
    category: 'Steel / TMT / Rebar',
    icon: Icons.line_weight_rounded,
  ),
  _QuickItemPreset(
    label: 'Bricks / Blocks',
    defaultItemName: 'Red Clay Bricks / Solid Blocks',
    defaultUnit: 'Nos',
    category: 'Bricks & Blocks',
    icon: Icons.square_foot_rounded,
  ),
  _QuickItemPreset(
    label: 'Paint / Primer',
    defaultItemName: 'Emulsion Paint / Primer',
    defaultUnit: 'Litres',
    category: 'Paint & Primer',
    icon: Icons.format_paint_rounded,
  ),
  _QuickItemPreset(
    label: 'Electrical / Pipes',
    defaultItemName: 'PVC Pipes / Electrical Wire',
    defaultUnit: 'Meters',
    category: 'Electrical & Plumbing',
    icon: Icons.electrical_services_rounded,
  ),
];

class PurchaseFormScreen extends ConsumerStatefulWidget {
  final int? purchaseId;
  const PurchaseFormScreen({super.key, this.purchaseId});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // GlobalKeys for each section card to allow quick tab navigation
  final _section1Key = GlobalKey();
  final _section2Key = GlobalKey();
  final _section3Key = GlobalKey();
  final _section4Key = GlobalKey();

  // Active section tab index
  int _activeTab = 0;

  // Text Controllers
  final _descCtrl = TextEditingController();
  final _hsnCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _rateCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'Sq.ft');
  final _baseAmountCtrl = TextEditingController();
  final _gstRateCtrl = TextEditingController(text: '18');
  final _gstAmountCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(); // Grand Total
  final _paidAmountCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();
  final _refCtrl = TextEditingController();

  // FocusNodes for seamless Tab & Enter field traversal
  final _refFocus = FocusNode();
  final _descFocus = FocusNode();
  final _qtyFocus = FocusNode();
  final _rateFocus = FocusNode();
  final _baseAmountFocus = FocusNode();
  final _gstRateFocus = FocusNode();
  final _hsnFocus = FocusNode();
  final _gstAmountFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _paidAmountFocus = FocusNode();
  final _narrationFocus = FocusNode();

  static const List<String> _commonUnits = [
    'Sq.ft',
    'Nos',
    'Bags',
    'Tons',
    'Kg',
    'CFT',
    'Cu.m',
    'Litres',
    'Meters',
    'Trips',
    'Hours',
    'Lump sum',
    'Boxes',
    'Brass',
    'Other',
  ];

  static const List<double> _standardGstRates = [5.0, 12.0, 18.0, 28.0];

  int? _selectedProject;
  int? _selectedVendor;
  String? _selectedCategory;
  PaymentStatus _paymentStatus = PaymentStatus.pending;
  PaymentMode? _paymentMode;
  int? _selectedBankAccountId;
  DateTime _date = DateTime.now();
  bool _taxApplicable = false;
  double _selectedGstRate = 18.0;
  bool _isAdvanceStock = false;
  bool _showMoreOptions = false;
  bool _loading = false;

  bool get _isEditing => widget.purchaseId != null;

  @override
  void initState() {
    super.initState();
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
        _hsnCtrl.text = pd.purchase.hsnCode ?? '';
        _qtyCtrl.text = pd.purchase.quantity % 1 == 0
            ? pd.purchase.quantity.toInt().toString()
            : pd.purchase.quantity.toString();
        _rateCtrl.text = pd.purchase.unitRate % 1 == 0
            ? pd.purchase.unitRate.toInt().toString()
            : pd.purchase.unitRate.toStringAsFixed(2);
        _unitCtrl.text = pd.purchase.unit ?? 'Sq.ft';

        _taxApplicable = pd.purchase.taxApplicable;
        _selectedGstRate =
            pd.purchase.gstRate > 0 ? pd.purchase.gstRate : 18.0;
        _gstRateCtrl.text = pd.purchase.gstRate % 1 == 0
            ? pd.purchase.gstRate.toInt().toString()
            : pd.purchase.gstRate.toString();
        _gstAmountCtrl.text = pd.purchase.gstAmount % 1 == 0
            ? pd.purchase.gstAmount.toInt().toString()
            : pd.purchase.gstAmount.toStringAsFixed(2);

        final totalAmt = pd.transaction.amount;
        _amountCtrl.text = totalAmt % 1 == 0
            ? totalAmt.toInt().toString()
            : totalAmt.toStringAsFixed(2);

        final baseAmt = pd.purchase.taxApplicable
            ? (totalAmt - pd.purchase.gstAmount)
            : (pd.purchase.quantity * pd.purchase.unitRate > 0
                ? pd.purchase.quantity * pd.purchase.unitRate
                : totalAmt);
        _baseAmountCtrl.text = baseAmt % 1 == 0
            ? baseAmt.toInt().toString()
            : baseAmt.toStringAsFixed(2);

        _paidAmountCtrl.text = pd.purchase.paidAmount % 1 == 0
            ? pd.purchase.paidAmount.toInt().toString()
            : pd.purchase.paidAmount.toStringAsFixed(2);
        _paymentStatus = pd.purchase.paymentStatus;
        _paymentMode = pd.transaction.paymentMode;
        _selectedBankAccountId = pd.transaction.bankAccountId;
        _narrationCtrl.text = pd.transaction.narration ?? '';
        _refCtrl.text = pd.transaction.referenceNo ?? '';
        _isAdvanceStock = pd.purchase.isAdvanceStock;
        _selectedCategory = pd.purchase.materialCategory;

        if (_narrationCtrl.text.isNotEmpty || _isAdvanceStock) {
          _showMoreOptions = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _hsnCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _unitCtrl.dispose();
    _baseAmountCtrl.dispose();
    _gstRateCtrl.dispose();
    _gstAmountCtrl.dispose();
    _amountCtrl.dispose();
    _paidAmountCtrl.dispose();
    _narrationCtrl.dispose();
    _refCtrl.dispose();

    _refFocus.dispose();
    _descFocus.dispose();
    _qtyFocus.dispose();
    _rateFocus.dispose();
    _baseAmountFocus.dispose();
    _gstRateFocus.dispose();
    _hsnFocus.dispose();
    _gstAmountFocus.dispose();
    _amountFocus.dispose();
    _paidAmountFocus.dispose();
    _narrationFocus.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  // --- Scroll to Section by Tab ---
  void _scrollToSection(GlobalKey key, int tabIndex) {
    setState(() => _activeTab = tabIndex);
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // --- Auto-Calculation Logic ---

  void _onQtyOrRateChanged() {
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final rate = double.tryParse(_rateCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    if (qty > 0 && rate > 0) {
      final base = qty * rate;
      _baseAmountCtrl.text =
          base % 1 == 0 ? base.toInt().toString() : base.toStringAsFixed(2);
    }
    _recalculateTaxAndTotal();
  }

  void _onBaseAmountChanged() {
    _recalculateTaxAndTotal();
  }

  void _recalculateTaxAndTotal() {
    final base =
        double.tryParse(_baseAmountCtrl.text.replaceAll(',', '').trim()) ?? 0.0;

    if (!_taxApplicable) {
      _gstAmountCtrl.text = '0';
      if (base > 0) {
        _amountCtrl.text =
            base % 1 == 0 ? base.toInt().toString() : base.toStringAsFixed(2);
      }
    } else {
      final gstRate =
          double.tryParse(_gstRateCtrl.text.replaceAll(',', '').trim()) ??
              _selectedGstRate;
      final tax = (base * gstRate) / 100.0;
      _gstAmountCtrl.text =
          tax % 1 == 0 ? tax.toInt().toString() : tax.toStringAsFixed(2);
      final total = base + tax;
      _amountCtrl.text =
          total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(2);
    }

    _syncPaidAmountIfFullPaid();
  }

  void _onGstAmountChanged() {
    final base =
        double.tryParse(_baseAmountCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final tax =
        double.tryParse(_gstAmountCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final total = base + tax;
    _amountCtrl.text =
        total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(2);
    _syncPaidAmountIfFullPaid();
  }

  void _onTotalAmountChanged() {
    _syncPaidAmountIfFullPaid();
  }

  void _syncPaidAmountIfFullPaid() {
    if (_paymentStatus == PaymentStatus.paid) {
      _paidAmountCtrl.text = _amountCtrl.text;
    }
  }

  void _selectGstPreset(double rate) {
    setState(() {
      _selectedGstRate = rate;
      _gstRateCtrl.text =
          rate % 1 == 0 ? rate.toInt().toString() : rate.toString();
    });
    _recalculateTaxAndTotal();
  }

  void _applyQuickItem(_QuickItemPreset preset) {
    setState(() {
      _selectedCategory = preset.category;
      _unitCtrl.text = preset.defaultUnit;
      if (_descCtrl.text.trim().isEmpty ||
          _kQuickItems.any((q) => q.defaultItemName == _descCtrl.text.trim())) {
        _descCtrl.text = preset.defaultItemName;
      }
    });
    _onQtyOrRateChanged();
    _qtyFocus.requestFocus();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _refFocus.requestFocus();
    }
  }

  Future<void> _openAddSupplierDialog() async {
    final nameCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.storefront_rounded,
                color: const Color(0xFF2563EB), size: 22.sp),
            SizedBox(width: 8.w),
            const Text('Add New Supplier / Vendor'),
          ],
        ),
        content: SizedBox(
          width: 360.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the supplier or shop name as shown on their bill:',
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Supplier Name *',
                  hintText: 'e.g. Metro Builders Supply Co.',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                onSubmitted: (_) async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  final repo = ref.read(purchaseRepositoryProvider);
                  final id = await repo.addVendor(name);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    setState(() => _selectedVendor = id);
                    _refFocus.requestFocus();
                  }
                },
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
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final repo = ref.read(purchaseRepositoryProvider);
              final id = await repo.addVendor(name);
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                setState(() => _selectedVendor = id);
                _refFocus.requestFocus();
              }
            },
            child: const Text('Save Supplier'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit({bool andAddAnother = false}) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }
    if (_selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project.')),
      );
      _scrollToSection(_section1Key, 0);
      return;
    }
    if (_selectedVendor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add a supplier/vendor.')),
      );
      _scrollToSection(_section1Key, 0);
      return;
    }

    final cleanAmountStr =
        _amountCtrl.text.replaceAll(',', '').replaceAll(' ', '').trim();
    final amount = double.tryParse(cleanAmountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid positive total bill amount.')),
      );
      _scrollToSection(_section3Key, 2);
      _amountFocus.requestFocus();
      return;
    }

    final qty =
        double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 1.0;
    final unitRate =
        double.tryParse(_rateCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final unit =
        _unitCtrl.text.trim().isNotEmpty ? _unitCtrl.text.trim() : null;
    final hsnCode =
        _hsnCtrl.text.trim().isNotEmpty ? _hsnCtrl.text.trim() : null;
    final gstRate = _taxApplicable
        ? (double.tryParse(_gstRateCtrl.text.replaceAll(',', '').trim()) ??
            _selectedGstRate)
        : 0.0;
    final gstAmount = _taxApplicable
        ? (double.tryParse(_gstAmountCtrl.text.replaceAll(',', '').trim()) ?? 0.0)
        : 0.0;

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
                  ? 'Paid amount equals or exceeds total bill. Please select "Paid in Full".'
                  : 'Please enter a valid advance paid amount.',
            ),
          ),
        );
        _scrollToSection(_section4Key, 3);
        _paidAmountFocus.requestFocus();
        return;
      }
    }

    // Check account balance if paying cash or bank
    if (paidAmount > 0) {
      final accountsWithBalances =
          ref.read(bankAccountsWithBalancesProvider).asData?.value;
      if (accountsWithBalances != null && accountsWithBalances.isNotEmpty) {
        final targetAcc = accountsWithBalances
            .cast<BankAccountWithBalance?>()
            .firstWhere(
              (a) => a?.account.id == _selectedBankAccountId,
              orElse: () => null,
            );
        final currentBal = targetAcc != null
            ? targetAcc.currentBalance
            : (ref.read(liquiditySummaryProvider).asData?.value.totalLiquidity ??
                0.0);

        if (currentBal - paidAmount < 0) {
          final proceed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade800),
                  SizedBox(width: 8.w),
                  const Text('Negative Balance Warning'),
                ],
              ),
              content: Text(
                'This purchase cash outflow of ${CurrencyFormatter.format(paidAmount)} exceeds your current balance in ${targetAcc?.account.accountName ?? 'Total Liquidity'} (${CurrencyFormatter.format(currentBal)}).\n\n'
                'Recording this will make your account balance negative (${CurrencyFormatter.format(currentBal - paidAmount)}).\n\n'
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
              hsnCode: hsnCode,
              taxApplicable: _taxApplicable,
              gstRate: gstRate,
              gstAmount: gstAmount,
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
              content: Text('✓ Purchase bill updated successfully!'),
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
            hsnCode: hsnCode,
            taxApplicable: _taxApplicable,
            gstRate: gstRate,
            gstAmount: gstAmount,
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

      if (!mounted) return;

      if (andAddAnother) {
        // Continuous Entry: Reset item & amounts, keep project & date, refocus
        _descCtrl.clear();
        _qtyCtrl.text = '1';
        _rateCtrl.clear();
        _baseAmountCtrl.clear();
        _gstAmountCtrl.clear();
        _amountCtrl.clear();
        _paidAmountCtrl.clear();
        _narrationCtrl.clear();
        _refCtrl.clear();
        _hsnCtrl.clear();

        setState(() {
          _paymentStatus = PaymentStatus.pending;
          _selectedCategory = null;
          _activeTab = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Purchase bill saved! Ready for next entry.'),
            backgroundColor: Color(0xFF059669),
            duration: Duration(seconds: 2),
          ),
        );

        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
        _refFocus.requestFocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Purchase bill recorded successfully!'),
            backgroundColor: Color(0xFF059669),
          ),
        );
        context.go('/purchases');
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectListProvider);
    final vendorsAsync = ref.watch(vendorListProvider);
    final accountsAsync = ref.watch(bankAccountsWithBalancesProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
            _submit(andAddAnother: false),
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): () =>
            _submit(andAddAnother: false),
        const SingleActivator(LogicalKeyboardKey.enter, control: true, shift: true):
            () => _submit(andAddAnother: true),
        const SingleActivator(LogicalKeyboardKey.enter, meta: true, shift: true):
            () => _submit(andAddAnother: true),
        const SingleActivator(LogicalKeyboardKey.keyS, alt: true): () =>
            _submit(andAddAnother: true),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            context.go('/purchases'),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 720.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──
                      _buildHeader(theme),
                      SizedBox(height: 14.h),

                      // ── Section Tabs Bar (1-Click Switch across All Entry Areas) ──
                      _buildSectionTabBar(),
                      SizedBox(height: 16.h),

                      // ── Card 1: Bill Header (Project, Supplier, Date & Ref) ──
                      Container(
                        key: _section1Key,
                        child: _buildCard(
                          stepNumber: '1',
                          title: 'Project & Supplier Details',
                          subtitle:
                              'Who supplied the materials and for which project?',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Project
                              projectsAsync.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (e, _) =>
                                    Text('Error loading projects: $e'),
                                data: (projects) => _buildProjectSelector(
                                  projects,
                                  ref.watch(selectedProjectIdProvider),
                                  theme,
                                ),
                              ),
                              SizedBox(height: 14.h),

                              // Supplier with Quick + Add Button
                              vendorsAsync.when(
                                loading: () => const LinearProgressIndicator(),
                                error: (_, __) => const SizedBox.shrink(),
                                data: (vendors) {
                                  final selectedVendorValue = vendors
                                          .any((v) => v.id == _selectedVendor)
                                      ? _selectedVendor
                                      : null;
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<int>(
                                          value: selectedVendorValue,
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Supplier / Vendor *',
                                            prefixIcon: Icon(
                                                Icons.storefront_outlined),
                                            hintText:
                                                'Select supplier or store',
                                          ),
                                          items: vendors
                                              .map((v) => DropdownMenuItem(
                                                    value: v.id,
                                                    child: Text(v.name),
                                                  ))
                                              .toList(),
                                          onChanged: (v) {
                                            setState(() => _selectedVendor = v);
                                            _refFocus.requestFocus();
                                          },
                                          validator: (v) => v == null
                                              ? 'Please select a supplier'
                                              : null,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      FilledButton.tonalIcon(
                                        onPressed: _openAddSupplierDialog,
                                        icon: Icon(Icons.add, size: 18.sp),
                                        label: const Text('+ New'),
                                        style: FilledButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14.w, vertical: 14.h),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(height: 14.h),

                              // Date & Bill Number
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: _pickDate,
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Purchase / Bill Date *',
                                          prefixIcon: Icon(
                                              Icons.calendar_today_outlined),
                                        ),
                                        child: Text(
                                          '${_date.day.toString().padLeft(2, '0')}/'
                                          '${_date.month.toString().padLeft(2, '0')}/'
                                          '${_date.year}',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _refCtrl,
                                      focusNode: _refFocus,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _descFocus.requestFocus(),
                                      decoration: const InputDecoration(
                                        labelText: 'Bill / Invoice / Challan No.',
                                        hintText: 'e.g. INV-2026-089',
                                        prefixIcon:
                                            Icon(Icons.receipt_outlined),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // ── Card 2: Items & Measurements (Clean & Intuitive) ──
                      Container(
                        key: _section2Key,
                        child: _buildCard(
                          stepNumber: '2',
                          title: 'Item & Measurements',
                          subtitle: 'What was bought, quantity, and unit rate?',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Item Description
                              TextFormField(
                                controller: _descCtrl,
                                focusNode: _descFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) =>
                                    _qtyFocus.requestFocus(),
                                decoration: InputDecoration(
                                  labelText: 'Item Description *',
                                  hintText:
                                      'e.g. 53 Grade Cement, 10mm Tiles, Sand, Red Bricks...',
                                  prefixIcon:
                                      const Icon(Icons.inventory_2_outlined),
                                  suffixIcon: _selectedCategory != null
                                      ? Chip(
                                          label: Text(_selectedCategory!),
                                          labelStyle: TextStyle(
                                              fontSize: 10.sp,
                                              color: const Color(0xFF2563EB)),
                                          backgroundColor:
                                              const Color(0xFFEFF6FF),
                                          deleteIcon: Icon(Icons.close,
                                              size: 12.sp),
                                          onDeleted: () => setState(
                                              () => _selectedCategory = null),
                                          visualDensity: VisualDensity.compact,
                                        )
                                      : null,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Please enter the item name or material'
                                    : null,
                              ),
                              SizedBox(height: 8.h),

                              // Quick Preset Chips (1-click set item, unit & jump to qty)
                              Row(
                                children: [
                                  Text(
                                    'Quick Tap:',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: _kQuickItems.map((preset) {
                                          final isSelected = _selectedCategory ==
                                              preset.category;
                                          return Padding(
                                            padding: EdgeInsets.only(right: 6.w),
                                            child: ActionChip(
                                              avatar: Icon(preset.icon,
                                                  size: 13.sp,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF475569)),
                                              label: Text(preset.label),
                                              labelStyle: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white
                                                    : const Color(0xFF334155),
                                              ),
                                              backgroundColor: isSelected
                                                  ? const Color(0xFF2563EB)
                                                  : const Color(0xFFF1F5F9),
                                              side: BorderSide(
                                                color: isSelected
                                                    ? const Color(0xFF2563EB)
                                                    : const Color(0xFFE2E8F0),
                                              ),
                                              onPressed: () =>
                                                  _applyQuickItem(preset),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14.h),

                              // Quantity, Unit, Unit Rate
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Qty
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: _qtyCtrl,
                                      focusNode: _qtyFocus,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) =>
                                          _rateFocus.requestFocus(),
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity *',
                                        hintText: '1.0',
                                        prefixIcon:
                                            Icon(Icons.numbers_outlined),
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      onChanged: (_) => _onQtyOrRateChanged(),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        final num = double.tryParse(
                                            v.replaceAll(',', ''));
                                        if (num == null || num <= 0) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.w),

                                  // Unit Dropdown
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      value: _commonUnits
                                              .contains(_unitCtrl.text)
                                          ? _unitCtrl.text
                                          : 'Sq.ft',
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Unit *',
                                        prefixIcon:
                                            Icon(Icons.straighten_outlined),
                                      ),
                                      items: _commonUnits
                                          .map((u) => DropdownMenuItem(
                                                value: u,
                                                child: Text(u),
                                              ))
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() => _unitCtrl.text = v);
                                          _rateFocus.requestFocus();
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.w),

                                  // Unit Rate
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: _rateCtrl,
                                      focusNode: _rateFocus,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) {
                                        if (_taxApplicable) {
                                          _hsnFocus.requestFocus();
                                        } else {
                                          _amountFocus.requestFocus();
                                        }
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Unit Rate (₹)',
                                        hintText: '0.00',
                                        prefixText: '₹ ',
                                        prefixIcon: Icon(
                                            Icons.currency_rupee_outlined),
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      onChanged: (_) => _onQtyOrRateChanged(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // Subtotal (Taxable Base)
                              TextFormField(
                                controller: _baseAmountCtrl,
                                focusNode: _baseAmountFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  if (_taxApplicable) {
                                    _hsnFocus.requestFocus();
                                  } else {
                                    _amountFocus.requestFocus();
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Subtotal / Base Amount (₹) *',
                                  prefixText: '₹ ',
                                  helperText:
                                      'Auto-calculated (Qty × Rate) or enter flat amount',
                                  prefixIcon: Icon(Icons.calculate_outlined),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (_) => _onBaseAmountChanged(),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(
                                          v.replaceAll(',', '')) ==
                                      null) {
                                    return 'Invalid amount';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // ── Card 3: GST Tax & Grand Total ──
                      Container(
                        key: _section3Key,
                        child: _buildCard(
                          stepNumber: '3',
                          title: 'GST Tax & Grand Total',
                          subtitle: 'Does this bill include GST tax?',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // GST Toggle Switch Card
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: _taxApplicable
                                      ? const Color(0xFFF0FDF4)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: _taxApplicable
                                        ? const Color(0xFF86EFAC)
                                        : const Color(0xFFE2E8F0),
                                    width: _taxApplicable ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _taxApplicable
                                          ? Icons.verified_rounded
                                          : Icons.receipt_long_outlined,
                                      color: _taxApplicable
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF64748B),
                                      size: 22.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'GST / Tax Applicable on this Bill',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                              color: _taxApplicable
                                                  ? const Color(0xFF15803D)
                                                  : const Color(0xFF1E293B),
                                            ),
                                          ),
                                          Text(
                                            _taxApplicable
                                                ? 'GST rate, HSN code, and tax amount will be recorded'
                                                : 'Standard non-tax / local bill without GST',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: _taxApplicable
                                                  ? const Color(0xFF166534)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _taxApplicable,
                                      activeThumbColor: const Color(0xFF16A34A),
                                      onChanged: (val) {
                                        setState(() => _taxApplicable = val);
                                        _recalculateTaxAndTotal();
                                        if (val) {
                                          _hsnFocus.requestFocus();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // If GST is applicable: show quick rate chips, HSN, and Tax Amount
                              if (_taxApplicable) ...[
                                SizedBox(height: 14.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'GST Rate:',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Wrap(
                                      spacing: 6.w,
                                      children: _standardGstRates.map((rate) {
                                        final isSelected =
                                            _selectedGstRate == rate &&
                                                _gstRateCtrl.text ==
                                                    (rate % 1 == 0
                                                        ? rate.toInt().toString()
                                                        : rate.toString());
                                        return ChoiceChip(
                                          label: Text(
                                              '${rate % 1 == 0 ? rate.toInt() : rate}%'),
                                          selected: isSelected,
                                          selectedColor:
                                              const Color(0xFF16A34A),
                                          labelStyle: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                          ),
                                          onSelected: (_) {
                                            _selectGstPreset(rate);
                                            _hsnFocus.requestFocus();
                                          },
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(width: 8.w),
                                    SizedBox(
                                      width: 80.w,
                                      child: TextFormField(
                                        controller: _gstRateCtrl,
                                        focusNode: _gstRateFocus,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            _hsnFocus.requestFocus(),
                                        decoration: const InputDecoration(
                                          labelText: 'Other %',
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                        ),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        onChanged: (_) {
                                          setState(() {
                                            _selectedGstRate = double.tryParse(
                                                    _gstRateCtrl.text) ??
                                                0.0;
                                          });
                                          _recalculateTaxAndTotal();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),

                                // HSN Code & GST Tax Amount
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _hsnCtrl,
                                        focusNode: _hsnFocus,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            _gstAmountFocus.requestFocus(),
                                        decoration: const InputDecoration(
                                          labelText: 'HSN / SAC Code',
                                          hintText: 'e.g. 6802, 2523',
                                          prefixIcon:
                                              Icon(Icons.pin_outlined),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _gstAmountCtrl,
                                        focusNode: _gstAmountFocus,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) =>
                                            _amountFocus.requestFocus(),
                                        decoration: const InputDecoration(
                                          labelText: 'GST Tax Amount (₹) *',
                                          prefixText: '₹ ',
                                          helperText:
                                              'Auto-calculated or adjust rounding',
                                          prefixIcon:
                                              Icon(Icons.percent_outlined),
                                        ),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        onChanged: (_) =>
                                            _onGstAmountChanged(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(height: 14.h),

                              // Prominent Grand Total Bill Display & Input
                              Container(
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                      color: const Color(0xFFCBD5E1)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TOTAL BILL AMOUNT',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                          Text(
                                            _taxApplicable
                                                ? 'Taxable Base + GST Tax'
                                                : 'Final bill invoice value',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: const Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 220.w,
                                      child: TextFormField(
                                        controller: _amountCtrl,
                                        focusNode: _amountFocus,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: (_) {
                                          _scrollToSection(_section4Key, 3);
                                          if (_paymentStatus ==
                                              PaymentStatus.partial) {
                                            _paidAmountFocus.requestFocus();
                                          } else {
                                            _narrationFocus.requestFocus();
                                          }
                                        },
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        decoration: InputDecoration(
                                          prefixText: '₹ ',
                                          prefixStyle: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12.w, vertical: 10.h),
                                        ),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        onChanged: (_) =>
                                            _onTotalAmountChanged(),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'Required';
                                          }
                                          if (double.tryParse(v.replaceAll(
                                                  ',', '')) ==
                                              null) {
                                            return 'Invalid';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Budget Warning if applicable
                              if (_selectedProject != null &&
                                  !_isAdvanceStock) ...[
                                SizedBox(height: 10.h),
                                BudgetWarningBanner(
                                  projectId: _selectedProject,
                                  costHead: BudgetCostHead.materials,
                                  addedAmount: double.tryParse(_amountCtrl.text
                                          .replaceAll(',', '')) ??
                                      0.0,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // ── Card 4: Payment Terms (Credit vs Paid) ──
                      Container(
                        key: _section4Key,
                        child: _buildCard(
                          stepNumber: '4',
                          title: 'Payment Terms',
                          subtitle:
                              'Was this bill paid today or taken on credit?',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 3 Clear Payment Status Segments
                              Row(
                                children: [
                                  _buildPaymentOption(
                                    status: PaymentStatus.pending,
                                    title: 'Credit (Unpaid)',
                                    subtitle: 'Pay supplier later',
                                    icon: Icons.schedule_rounded,
                                    color: const Color(0xFFD97706),
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildPaymentOption(
                                    status: PaymentStatus.paid,
                                    title: 'Paid in Full',
                                    subtitle: 'Cleared today',
                                    icon: Icons.check_circle_rounded,
                                    color: const Color(0xFF16A34A),
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildPaymentOption(
                                    status: PaymentStatus.partial,
                                    title: 'Partial Advance',
                                    subtitle: 'Part paid today',
                                    icon: Icons.pie_chart_rounded,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              // Partial Payment Details
                              if (_paymentStatus == PaymentStatus.partial) ...[
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                        color: const Color(0xFFBFDBFE)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _paidAmountCtrl,
                                          focusNode: _paidAmountFocus,
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) =>
                                              _narrationFocus.requestFocus(),
                                          decoration: const InputDecoration(
                                            labelText: 'Paid Today (₹) *',
                                            prefixText: '₹ ',
                                            fillColor: Colors.white,
                                            filled: true,
                                          ),
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Builder(
                                          builder: (_) {
                                            final total = double.tryParse(
                                                    _amountCtrl.text.replaceAll(
                                                        ',', '')) ??
                                                0.0;
                                            final paid = double.tryParse(
                                                    _paidAmountCtrl.text
                                                        .replaceAll(',', '')) ??
                                                0.0;
                                            final due = (total - paid)
                                                .clamp(0.0, double.infinity);
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 10.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFCBD5E1)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Remaining Due:',
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color: const Color(
                                                          0xFF64748B),
                                                    ),
                                                  ),
                                                  Text(
                                                    CurrencyFormatter.format(due),
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(
                                                          0xFFDC2626),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),
                              ],

                              // Mode & Bank Account (if paying today)
                              if (_paymentStatus != PaymentStatus.pending) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child:
                                          DropdownButtonFormField<PaymentMode?>(
                                        value: _paymentMode,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Payment Mode',
                                          prefixIcon:
                                              Icon(Icons.payments_outlined),
                                        ),
                                        items: [
                                          const DropdownMenuItem(
                                              value: null,
                                              child: Text('— Select Mode —')),
                                          ...PaymentMode.values.map(
                                            (m) => DropdownMenuItem(
                                              value: m,
                                              child: Text(m.displayName),
                                            ),
                                          ),
                                        ],
                                        onChanged: (v) =>
                                            setState(() => _paymentMode = v),
                                      ),
                                    ),
                                    accountsAsync.maybeWhen(
                                      data: (accounts) {
                                        if (accounts.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 12.w),
                                            child: DropdownButtonFormField<int?>(
                                              value: _selectedBankAccountId,
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                labelText: 'Paid From Account',
                                                prefixIcon: Icon(Icons
                                                    .account_balance_outlined),
                                              ),
                                              items: [
                                                const DropdownMenuItem(
                                                  value: null,
                                                  child: Text('— Auto / Default —'),
                                                ),
                                                ...accounts.map(
                                                  (a) => DropdownMenuItem(
                                                    value: a.account.id,
                                                    child: Text(
                                                      '${a.account.accountName} (${CurrencyFormatter.format(a.currentBalance)})',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              onChanged: (v) => setState(() =>
                                                  _selectedBankAccountId = v),
                                            ),
                                          ),
                                        );
                                      },
                                      orElse: () => const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                        color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: const Color(0xFFB45309),
                                          size: 16.sp),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'Full bill will be recorded under Accounts Payable. You can settle it later via Cash Book.',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: const Color(0xFF92400E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      // ── Optional: More Details (Notes, Advance Stock) ──
                      Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: _showMoreOptions,
                          tilePadding: EdgeInsets.symmetric(horizontal: 4.w),
                          title: Text(
                            'Additional Options & Remarks (Optional)',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          children: [
                            TextFormField(
                              controller: _narrationCtrl,
                              focusNode: _narrationFocus,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  _submit(andAddAnother: false),
                              decoration: const InputDecoration(
                                labelText: 'Notes / Remarks',
                                hintText:
                                    'e.g. Unloaded at Block B, site supervisor checked',
                                prefixIcon: Icon(Icons.notes_outlined),
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 10.h),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _isAdvanceStock,
                              title: const Text('Hold as Advance Stock / Asset'),
                              subtitle: const Text(
                                'Bulk stock held for future project allocation. Does not hit P&L now.',
                              ),
                              onChanged: (val) =>
                                  setState(() => _isAdvanceStock = val),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // ── Action Buttons Bar ──
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go('/purchases'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                            ),
                            child: const Text('Cancel (Esc)'),
                          ),
                          if (!_isEditing)
                            FilledButton.tonalIcon(
                              onPressed: _loading
                                  ? null
                                  : () => _submit(andAddAnother: true),
                              icon: Icon(Icons.add_task_rounded, size: 18.sp),
                              label: Text(
                                'Save & Add Next (Alt+S)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                              ),
                            ),
                          FilledButton.icon(
                            onPressed: _loading
                                ? null
                                : () => _submit(andAddAnother: false),
                            icon: _loading
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isEditing
                                        ? Icons.save_as_rounded
                                        : Icons.check_circle_rounded,
                                    size: 18.sp,
                                  ),
                            label: Text(
                              _isEditing
                                  ? 'Update Purchase Bill'
                                  : 'Save & Close (Ctrl+Enter)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 12.h),
                            ),
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
    );
  }

  // ── Helper Widgets ──

  Widget _buildSectionTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: EdgeInsets.all(4.w),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabItem(0, '1. Supplier & Bill', Icons.storefront_rounded,
                    _section1Key),
                _buildTabItem(
                    1, '2. Item & Rate', Icons.inventory_2_rounded, _section2Key),
                _buildTabItem(2, '3. GST & Total', Icons.receipt_long_rounded,
                    _section3Key),
                _buildTabItem(
                    3, '4. Payment', Icons.payments_rounded, _section4Key),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
      int index, String label, IconData icon, GlobalKey targetKey) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => _scrollToSection(targetKey, index),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15.sp,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Purchases (Esc)',
          onPressed: () => context.go('/purchases'),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Purchase Bill' : 'New Purchase Bill',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _isEditing
                    ? 'Update supplier invoice, quantities, unit rate, and GST tax'
                    : 'Record materials, supplier invoices, GST tax, and credit tracking',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (_isEditing)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: Text(
              'Bill #${widget.purchaseId}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB45309),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCard({
    required String stepNumber,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    stepNumber,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentStatus status,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _paymentStatus == status;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _paymentStatus = status;
            if (status == PaymentStatus.paid) {
              _paidAmountCtrl.text = _amountCtrl.text;
            } else if (status == PaymentStatus.pending) {
              _paidAmountCtrl.text = '0';
            }
          });
        },
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon,
                      size: 16.sp,
                      color: isSelected ? color : const Color(0xFF64748B)),
                  const Spacer(),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, size: 14.sp, color: color),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF1E293B),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectSelector(
      List<Project> projects, int? globalId, ThemeData theme) {
    if (globalId != null && !_isEditing) {
      final activeProject =
          projects.where((p) => p.id == globalId).firstOrNull;
      if (activeProject != null) {
        _selectedProject = activeProject.id;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_special_rounded,
                  color: const Color(0xFF2563EB), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Project: ',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
              Expanded(
                child: Text(
                  '${activeProject.code} — ${activeProject.name}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E40AF),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Auto-Assigned',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    final selectedProjectValue =
        projects.any((p) => p.id == _selectedProject) ? _selectedProject : null;

    return DropdownButtonFormField<int>(
      value: selectedProjectValue,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Select Target Project *',
        prefixIcon: Icon(Icons.folder_outlined),
        hintText: 'Choose which project this purchase belongs to',
      ),
      items: projects
          .map((p) => DropdownMenuItem(
                value: p.id,
                child: Text(
                  '${p.code} — ${p.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (v) {
        setState(() => _selectedProject = v);
        _refFocus.requestFocus();
      },
      validator: (v) => v == null ? 'Please select a project' : null,
    );
  }
}
