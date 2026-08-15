import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/features/labour/providers/labour_providers.dart';
import 'package:nex_ledger/shared/widgets/confirm_dialog.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class WorkersListScreen extends ConsumerStatefulWidget {
  const WorkersListScreen({super.key});

  @override
  ConsumerState<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends ConsumerState<WorkersListScreen> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _tradeCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  int? _editingId;
  bool _showForm = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _tradeCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _openForm({int? id, String? name, String? code, String? trade, double? rate}) {
    setState(() {
      _editingId = id;
      _nameCtrl.text = name ?? '';
      _codeCtrl.text = code ?? '';
      _tradeCtrl.text = trade ?? '';
      _rateCtrl.text = rate?.toStringAsFixed(0) ?? '';
      _showForm = true;
    });
  }

  void _closeForm() {
    setState(() {
      _showForm = false;
      _editingId = null;
      _nameCtrl.clear();
      _codeCtrl.clear();
      _tradeCtrl.clear();
      _rateCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    final repo = ref.read(labourRepositoryProvider);
    final rate = double.tryParse(_rateCtrl.text) ?? 0.0;
    if (_editingId != null) {
      await repo.updateWorker(
        id: _editingId!,
        name: _nameCtrl.text,
        workerCode: _codeCtrl.text.isNotEmpty ? _codeCtrl.text : null,
        trade: _tradeCtrl.text.isNotEmpty ? _tradeCtrl.text : null,
        dailyRate: rate,
      );
    } else {
      await repo.addWorker(
        name: _nameCtrl.text,
        workerCode: _codeCtrl.text.isNotEmpty ? _codeCtrl.text : null,
        trade: _tradeCtrl.text.isNotEmpty ? _tradeCtrl.text : null,
        dailyRate: rate,
      );
    }
    _closeForm();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workersAsync = ref.watch(workerListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workers table
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workers Master',
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Manage site workers, trade skills, and daily wage rates',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Worker'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: workersAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (workers) => DataTableCard(
                        emptyMessage:
                            'No workers registered yet. Click "Add Worker" to create your master list.',
                        columns: const [
                          DataColumn(label: Text('Code')),
                          DataColumn(label: Text('Worker Name')),
                          DataColumn(label: Text('Trade / Work Type')),
                          DataColumn(
                              label: Text('Daily Wage Rate (₹)'), numeric: true),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: workers.map((w) {
                          return DataRow(
                            onSelectChanged: (_) =>
                                context.push('/labour/workers/${w.id}'),
                            cells: [
                            DataCell(Text(
                              w.workerCode ?? '—',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                            )),
                            DataCell(GestureDetector(
                              onTap: () => context.push('/labour/workers/${w.id}'),
                              child: Text(
                                w.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    color: Color(0xFF4F46E5)),
                              ),
                            )),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                w.trade ?? 'General Helper',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            )),
                            DataCell(Text(
                              '₹${w.dailyRate.toStringAsFixed(0)} / day',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                            )),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18),
                                  tooltip: 'Edit',
                                  onPressed: () => _openForm(
                                    id: w.id,
                                    name: w.name,
                                    code: w.workerCode,
                                    trade: w.trade,
                                    rate: w.dailyRate,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  tooltip: 'Delete',
                                  color: theme.colorScheme.error,
                                  onPressed: () async {
                                    final confirmed =
                                        await ConfirmDialog.show(
                                      context,
                                      title: 'Delete Worker?',
                                      message:
                                          'Delete ${w.name}? Their attendance records will also be removed.',
                                      confirmLabel: 'Delete',
                                    );
                                    if (confirmed) {
                                      await ref
                                          .read(labourRepositoryProvider)
                                          .deleteWorker(w.id);
                                    }
                                  },
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Inline form panel
            if (_showForm) ...[
              const SizedBox(width: 24),
              SizedBox(
                width: 320,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingId != null
                              ? 'Edit Worker Details'
                              : 'New Worker Master',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Worker Full Name *'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _codeCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Worker Code (e.g. WRK-001)'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _tradeCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Trade / Work (e.g. Mason, Helper, Carpenter)'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _rateCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Daily Wage Rate (₹) *',
                            prefixText: '₹ ',
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _closeForm,
                              child: const Text('Cancel'),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: _save,
                              child: Text(_editingId != null
                                  ? 'Save Changes'
                                  : 'Add Worker'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
