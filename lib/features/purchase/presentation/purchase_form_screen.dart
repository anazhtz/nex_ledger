import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/constants/material_constants.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/budget_warning_banner.dart';
import 'package:nex_ledger/features/purchase/models/material_consumption.dart';
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
        _paymentMode = pd.transaction.paymentMode;
        _selectedBankAccountId = pd.transaction.bankAccountId;
        _narrationCtrl.text = pd.transaction.narration ?? '';
        _refCtrl.text = pd.transaction.referenceNo ?? '';
        _isAdvanceStock = pd.purchase.isAdvanceStock;
        _selectedCategory = pd.purchase.materialCategory;
      });
    }
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
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final rate = double.tryParse(_rateCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    if (qty > 0 && rate > 0) {
      final total = qty * rate;
      _amountCtrl.text = total % 1 == 0 ? total.toInt().toString() : total.toStringAsFixed(2);
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

  Future<void> _submit() async {
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

    final cleanAmountStr = _amountCtrl.text.replaceAll(',', '').replaceAll(' ', '').trim();
    final amount = double.tryParse(cleanAmountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '').trim()) ?? 1.0;
    final unitRate = double.tryParse(_rateCtrl.text.replaceAll(',', '').trim()) ?? 0.0;
    final unit = _unitCtrl.text.trim().isNotEmpty ? _unitCtrl.text.trim() : null;

    double paidAmount = 0.0;
    if (_paymentStatus == PaymentStatus.paid) {
      paidAmount = amount;
    } else if (_paymentStatus == PaymentStatus.partial) {
      final cleanPaidStr = _paidAmountCtrl.text.replaceAll(',', '').replaceAll(' ', '').trim();
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
            narration: _narrationCtrl.text.isNotEmpty ? _narrationCtrl.text.trim() : null,
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
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
        const SingleActivator(LogicalKeyboardKey.escape): () => context.go('/purchases'),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: theme.colorScheme.surfaceContainerLowest,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/purchases'),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Edit Purchase Entry' : 'New Purchase Entry',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _isEditing
                              ? 'Modify purchase details, rates, payment status, or vendor bills'
                              : 'Record materials, equipment, petty expenses, and vendor credit bills',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 720.w),
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
                              Text(
                                'Project & Vendor Details',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              projectsAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error: (e, _) => Text('Error loading projects: $e'),
                                data: (projects) => _buildProjectSelector(
                                  projects,
                                  ref.watch(selectedProjectIdProvider),
                                  theme,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              vendorsAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                                data: (vendors) {
                                  final selectedVendorValue =
                                      vendors.any((v) => v.id == _selectedVendor)
                                          ? _selectedVendor
                                          : null;
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<int>(
                                              value: selectedVendorValue,
                                              decoration: const InputDecoration(
                                                labelText: 'Vendor / Supplier *',
                                                prefixIcon: Icon(Icons.store_outlined),
                                              ),
                                              items: vendors
                                                  .map((v) => DropdownMenuItem(
                                                        value: v.id,
                                                        child: Text(v.name),
                                                      ))
                                                  .toList(),
                                              onChanged: (v) =>
                                                  setState(() => _selectedVendor = v),
                                              validator: (v) =>
                                                  v == null ? 'Required' : null,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          TextButton.icon(
                                            onPressed: () => setState(
                                                () => _showAddVendor = !_showAddVendor),
                                            icon: Icon(
                                              _showAddVendor ? Icons.close : Icons.add,
                                              size: 16.sp,
                                            ),
                                            label: Text(
                                              _showAddVendor ? 'Cancel' : 'New Vendor',
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_showAddVendor)
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.h),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _newVendorCtrl,
                                                  decoration: const InputDecoration(
                                                    labelText: 'New Vendor Name',
                                                    hintText: 'e.g. ABC Steel Suppliers',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              FilledButton(
                                                onPressed: _addVendor,
                                                child: const Text('Add'),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(height: 24.h),
                               const Divider(color: Color(0xFFE2E8F0)),
                              SizedBox(height: 16.h),
                              Text(
                                'Material Category & Item Details',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Select Category (Auto-sets unit & displays project consumption):',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: kStandardMaterialCategories.map((cat) {
                                    final isSelected = _selectedCategory == cat.name;
                                    return Padding(
                                      padding: EdgeInsets.only(right: 8.w),
                                      child: ChoiceChip(
                                        avatar: Icon(
                                          cat.icon,
                                          size: 16.sp,
                                          color: isSelected ? Colors.white : cat.color,
                                        ),
                                        label: Text(cat.name),
                                        selected: isSelected,
                                        selectedColor: const Color(0xFF4F46E5),
                                        labelStyle: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected ? Colors.white : const Color(0xFF334155),
                                        ),
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedCategory = cat.name;
                                              _unitCtrl.text = cat.defaultUnit;
                                              if (_descCtrl.text.isEmpty) {
                                                _descCtrl.text = cat.name;
                                              }
                                            } else {
                                              _selectedCategory = null;
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // ─── Live In-Form Project Material Consumption Alert ───
                              if (_selectedProject != null && _selectedCategory != null && !_isAdvanceStock)
                                _buildLiveMaterialConsumptionCard(context),

                              TextFormField(
                                controller: _descCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Item / Material / Service Description *',
                                  hintText: 'e.g. 53 Grade Cement, 12mm TMT Steel, Sand',
                                  prefixIcon: Icon(Icons.inventory_2_outlined),
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'Required' : null,
                              ),
                              SizedBox(height: 14.h),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: _qtyCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Qty *',
                                        hintText: '1.0',
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => _onQtyOrRateChanged(),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return 'Required';
                                        final num = double.tryParse(v.replaceAll(',', ''));
                                        if (num == null || num <= 0) return 'Invalid';
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<String>(
                                      value: _commonUnits.contains(_unitCtrl.text)
                                          ? _unitCtrl.text
                                          : 'Nos',
                                      isExpanded: true,
                                      decoration: const InputDecoration(labelText: 'Unit'),
                                      items: _commonUnits
                                          .map((u) => DropdownMenuItem(
                                                value: u,
                                                child: Text(u),
                                              ))
                                          .toList(),
                                      onChanged: (v) {
                                        if (v != null) {
                                          setState(() => _unitCtrl.text = v);
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: _rateCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Unit Rate (₹)',
                                        hintText: '0.00',
                                        prefixText: '₹ ',
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => _onQtyOrRateChanged(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: _pickDate,
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Purchase Date *',
                                          prefixIcon: Icon(Icons.calendar_today_outlined),
                                        ),
                                        child: Text(
                                          '${_date.day.toString().padLeft(2, '0')}/'
                                          '${_date.month.toString().padLeft(2, '0')}/'
                                          '${_date.year}',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _amountCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Total Bill Amount (₹) *',
                                        prefixText: '₹ ',
                                        helperText: 'Auto-calculated or enter total bill',
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(decimal: true),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return 'Required';
                                        if (double.tryParse(v.replaceAll(',', '')) == null) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),

                              // ─── Real-Time Project Budget Impact Warning ────────
                              if (_selectedProject != null && !_isAdvanceStock)
                                BudgetWarningBanner(
                                  projectId: _selectedProject,
                                  costHead: BudgetCostHead.materials,
                                  addedAmount:
                                      double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0.0,
                                ),

                              SizedBox(height: 16.h),
                              const Divider(color: Color(0xFFE2E8F0)),
                              SizedBox(height: 16.h),
                              Text(
                                'Payment Terms & Credit Options',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                padding: EdgeInsets.all(6.w),
                                child: SegmentedButton<PaymentStatus>(
                                  segments: const [
                                    ButtonSegment(
                                      value: PaymentStatus.pending,
                                      label: Text('Vendor Credit (Unpaid)'),
                                      icon: Icon(Icons.schedule_outlined, size: 16),
                                    ),
                                    ButtonSegment(
                                      value: PaymentStatus.partial,
                                      label: Text('Partial Advance'),
                                      icon: Icon(Icons.pie_chart_outline, size: 16),
                                    ),
                                    ButtonSegment(
                                      value: PaymentStatus.paid,
                                      label: Text('Paid in Full'),
                                      icon: Icon(Icons.check_circle_outline, size: 16),
                                    ),
                                  ],
                                  selected: {_paymentStatus},
                                  onSelectionChanged: (newSelection) {
                                    setState(() {
                                      _paymentStatus = newSelection.first;
                                      if (_paymentStatus == PaymentStatus.paid) {
                                        _paidAmountCtrl.text = _amountCtrl.text;
                                      } else if (_paymentStatus == PaymentStatus.pending) {
                                        _paidAmountCtrl.text = '0';
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 14.h),
                              if (_paymentStatus == PaymentStatus.partial) ...[
                                Container(
                                  padding: EdgeInsets.all(14.w),
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
                                          Icon(Icons.account_balance_wallet_outlined,
                                              color: const Color(0xFF1D4ED8), size: 18.sp),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Partial Advance Payment Breakdown',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1E40AF),
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _paidAmountCtrl,
                                              decoration: const InputDecoration(
                                                labelText: 'Paid Today (₹) *',
                                                prefixText: '₹ ',
                                                fillColor: Colors.white,
                                                filled: true,
                                              ),
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                      decimal: true),
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                          SizedBox(width: 14.w),
                                          Expanded(
                                            child: Builder(
                                              builder: (_) {
                                                final total = double.tryParse(
                                                        _amountCtrl.text.replaceAll(',', '')) ??
                                                    0.0;
                                                final paid = double.tryParse(_paidAmountCtrl
                                                        .text
                                                        .replaceAll(',', '')) ??
                                                    0.0;
                                                final due = (total - paid).clamp(0.0, double.infinity);
                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 14.w, vertical: 12.h),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(8.r),
                                                    border: Border.all(
                                                        color: const Color(0xFFCBD5E1)),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Remaining Credit Due:',
                                                        style: TextStyle(
                                                          fontSize: 11.sp,
                                                          color: const Color(0xFF64748B),
                                                        ),
                                                      ),
                                                      Text(
                                                        CurrencyFormatter.format(due),
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          fontWeight: FontWeight.bold,
                                                          color: const Color(0xFFDC2626),
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
                                    ],
                                  ),
                                ),
                                SizedBox(height: 14.h),
                              ],
                              if (_paymentStatus == PaymentStatus.pending) ...[
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: const Color(0xFFB45309), size: 18.sp),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          'Vendor Credit: Full amount recorded as Accounts Payable liability. Project P&L recognizes the cost immediately; cash will only decrease when payments are recorded.',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: const Color(0xFF92400E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 14.h),
                              ],
                              Row(
                                children: [
                                  if (_paymentStatus != PaymentStatus.pending) ...[
                                    Expanded(
                                      child: DropdownButtonFormField<PaymentMode?>(
                                        value: _paymentMode,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Payment Mode',
                                          prefixIcon: Icon(Icons.payments_outlined),
                                        ),
                                        items: [
                                          const DropdownMenuItem(
                                              value: null,
                                              child: Text('— Select Mode —',
                                                  overflow: TextOverflow.ellipsis)),
                                          ...PaymentMode.values.map(
                                            (m) => DropdownMenuItem(
                                              value: m,
                                              child: Text(m.displayName,
                                                  overflow: TextOverflow.ellipsis),
                                            ),
                                          ),
                                        ],
                                        onChanged: (v) =>
                                            setState(() => _paymentMode = v),
                                      ),
                                    ),
                                    accountsAsync.maybeWhen(
                                      data: (accounts) {
                                        if (accounts.isEmpty) return const SizedBox.shrink();
                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 14.w),
                                            child: DropdownButtonFormField<int?>(
                                              value: _selectedBankAccountId,
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                labelText: 'Paid From (Account)',
                                                prefixIcon: Icon(
                                                    Icons.account_balance_outlined),
                                              ),
                                              items: [
                                                const DropdownMenuItem(
                                                  value: null,
                                                  child: Text('— Auto (Default) —',
                                                      overflow:
                                                          TextOverflow.ellipsis),
                                                ),
                                                ...accounts.map(
                                                  (a) => DropdownMenuItem(
                                                    value: a.account.id,
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            '${a.account.accountName} (${a.account.isCashAccount ? 'Cash' : 'Bank'})',
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Text(
                                                          CurrencyFormatter.format(
                                                              a.currentBalance),
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: a.currentBalance >= 0
                                                                ? const Color(0xFF059669)
                                                                : const Color(0xFFDC2626),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              onChanged: (v) =>
                                                  setState(() => _selectedBankAccountId = v),
                                            ),
                                          ),
                                        );
                                      },
                                      orElse: () => const SizedBox.shrink(),
                                    ),
                                    SizedBox(width: 14.w),
                                  ],
                                  Expanded(
                                    child: TextFormField(
                                      controller: _refCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Bill / Invoice / Challan No.',
                                        prefixIcon: Icon(Icons.receipt_long_outlined),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14.h),
                              TextFormField(
                                controller: _narrationCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Remarks / Narration (optional)',
                                  prefixIcon: Icon(Icons.notes_outlined),
                                ),
                                maxLines: 2,
                              ),
                              SizedBox(height: 18.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: _isAdvanceStock
                                      ? const Color(0xFFFEF3C7)
                                      : theme.colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: _isAdvanceStock
                                        ? const Color(0xFFD97706)
                                        : theme.colorScheme.outlineVariant,
                                    width: _isAdvanceStock ? 1.5 : 1,
                                  ),
                                ),
                                child: SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  value: _isAdvanceStock,
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 20.sp,
                                        color: _isAdvanceStock
                                            ? const Color(0xFFD97706)
                                            : theme.colorScheme.onSurface,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'Hold as Advance Stock / Asset',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _isAdvanceStock
                                                ? const Color(0xFF92400E)
                                                : theme.colorScheme.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: EdgeInsets.only(top: 4.h),
                                    child: Text(
                                      _isAdvanceStock
                                          ? 'Held as company stock asset. Does NOT affect project P&L now. You can allocate it to projects later.'
                                          : 'Standard purchase: Recognized as an immediate cost in project P&L.',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: _isAdvanceStock
                                            ? const Color(0xFFB45309)
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) => setState(() => _isAdvanceStock = v),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => context.go('/purchases'),
                                    child: const Text('Cancel'),
                                  ),
                                  SizedBox(width: 12.w),
                                  FilledButton(
                                    onPressed: _loading ? null : _submit,
                                    child: _loading
                                        ? SizedBox(
                                            width: 18.w,
                                            height: 18.h,
                                            child: const CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : Text(_isEditing
                                            ? 'Update Purchase (Ctrl+Enter)'
                                            : 'Save Purchase (Ctrl+Enter)'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectSelector(
      List<Project> projects, int? globalId, ThemeData theme) {
    if (globalId != null) {
      final activeProject =
          projects.where((p) => p.id == globalId).firstOrNull;
      if (activeProject != null) {
        _selectedProject = activeProject.id;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_special_rounded,
                  color: theme.colorScheme.primary, size: 20.sp),
              SizedBox(width: 10.w),
              Text(
                'Target Project: ',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${activeProject.code} — ${activeProject.name}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Auto-Assigned',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
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
      decoration: const InputDecoration(
        labelText: 'Select Target Project *',
        prefixIcon: Icon(Icons.folder_outlined),
      ),
      items: projects
          .map((p) => DropdownMenuItem(
                value: p.id,
                child: Text('${p.code} — ${p.name}', overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedProject = v),
      validator: (v) => v == null ? 'Required' : null,
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
                    Icon(Icons.info_outline_rounded, size: 16.sp, color: const Color(0xFF64748B)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'First entry for $_selectedCategory under this project. No previous bills.',
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
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
                    child: Icon(Icons.analytics_outlined, size: 18.sp, color: const Color(0xFF2563EB)),
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
