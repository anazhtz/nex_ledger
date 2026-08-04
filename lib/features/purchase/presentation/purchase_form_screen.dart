import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';

class PurchaseFormScreen extends ConsumerStatefulWidget {
  const PurchaseFormScreen({super.key});

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _narrationCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _newVendorCtrl = TextEditingController();

  int? _selectedProject;
  int? _selectedVendor;
  PaymentStatus _paymentStatus = PaymentStatus.pending;
  PaymentMode? _paymentMode;
  DateTime _date = DateTime.now();
  bool _loading = false;
  bool _showAddVendor = false;

  @override
  void initState() {
    super.initState();
    _selectedProject = ref.read(selectedProjectIdProvider);
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _narrationCtrl.dispose();
    _refCtrl.dispose();
    _newVendorCtrl.dispose();
    super.dispose();
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
    if (_selectedProject == null || _selectedVendor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select both project and vendor.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(purchaseRepositoryProvider).addPurchase(
            projectId: _selectedProject!,
            vendorId: _selectedVendor!,
            date: _date,
            itemDescription: _descCtrl.text.trim(),
            amount: double.parse(_amountCtrl.text),
            paymentStatus: _paymentStatus,
            paymentMode: _paymentMode,
            narration: _narrationCtrl.text.isNotEmpty
                ? _narrationCtrl.text
                : null,
            referenceNo:
                _refCtrl.text.isNotEmpty ? _refCtrl.text : null,
          );
      if (mounted) context.go('/purchases');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/purchases'),
                ),
                const SizedBox(width: 8),
                Text(
                  'New Purchase Entry',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Project
                        projectsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (projects) =>
                              DropdownButtonFormField<int>(
                            value: _selectedProject,
                            decoration:
                                const InputDecoration(labelText: 'Project *'),
                            items: projects
                                .map((p) => DropdownMenuItem(
                                      value: p.id,
                                      child: Text(p.name,
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedProject = v),
                            validator: (v) => v == null ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Vendor + add inline
                        vendorsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (vendors) => Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: _selectedVendor,
                                      decoration: const InputDecoration(
                                          labelText: 'Vendor *'),
                                      items: vendors
                                          .map((v) => DropdownMenuItem(
                                                value: v.id,
                                                child: Text(v.name),
                                              ))
                                          .toList(),
                                      onChanged: (v) => setState(
                                          () => _selectedVendor = v),
                                      validator: (v) =>
                                          v == null ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => setState(
                                        () => _showAddVendor = !_showAddVendor),
                                    icon: Icon(
                                        _showAddVendor
                                            ? Icons.close
                                            : Icons.add,
                                        size: 16),
                                    label: Text(
                                        _showAddVendor ? 'Cancel' : 'New'),
                                  ),
                                ],
                              ),
                              if (_showAddVendor)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _newVendorCtrl,
                                          decoration: const InputDecoration(
                                              labelText: 'Vendor Name'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton(
                                        onPressed: _addVendor,
                                        child: const Text('Add'),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Date + Amount
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                    suffixIcon: Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18),
                                  ),
                                  child: Text(
                                    '${_date.day.toString().padLeft(2, '0')}/'
                                    '${_date.month.toString().padLeft(2, '0')}/'
                                    '${_date.year}',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _amountCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Amount (₹) *',
                                  prefixText: '₹ ',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (double.tryParse(v) == null)
                                    return 'Invalid';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Item description
                        TextFormField(
                          controller: _descCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Item / Service Description *'),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Payment status + mode
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<PaymentStatus>(
                                value: _paymentStatus,
                                decoration: const InputDecoration(
                                    labelText: 'Payment Status'),
                                items: PaymentStatus.values
                                    .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s.displayName),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _paymentStatus = v!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<PaymentMode?>(
                                value: _paymentMode,
                                decoration: const InputDecoration(
                                    labelText: 'Payment Mode'),
                                items: [
                                  const DropdownMenuItem(
                                      value: null, child: Text('— Select —')),
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
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _refCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Bill / Invoice No.'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _narrationCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Narration'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/purchases'),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Save Purchase'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
