import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _rateCtrl = TextEditingController();
  int? _editingId;
  bool _showForm = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _openForm({int? id, String? name, String? code, double? rate}) {
    setState(() {
      _editingId = id;
      _nameCtrl.text = name ?? '';
      _codeCtrl.text = code ?? '';
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
        dailyRate: rate,
      );
    } else {
      await repo.addWorker(
        name: _nameCtrl.text,
        workerCode: _codeCtrl.text.isNotEmpty ? _codeCtrl.text : null,
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
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
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
                      Text(
                        'Workers',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () => _openForm(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Worker'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: workersAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (workers) => DataTableCard(
                        emptyMessage:
                            'No workers yet. Add your first worker.',
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Code')),
                          DataColumn(
                              label: Text('Daily Rate (₹)'), numeric: true),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: workers.map((w) {
                          return DataRow(cells: [
                            DataCell(Text(w.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500))),
                            DataCell(Text(w.workerCode ?? '—')),
                            DataCell(Text(
                                '₹${w.dailyRate.toStringAsFixed(0)}')),
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
                width: 300,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingId != null
                              ? 'Edit Worker'
                              : 'New Worker',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Name *'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _codeCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Worker Code'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _rateCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Daily Rate (₹)',
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
                                  ? 'Save'
                                  : 'Add'),
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
