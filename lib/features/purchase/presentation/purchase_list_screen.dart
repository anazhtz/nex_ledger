import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(filteredPurchaseListProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final filterProject = ref.watch(purchaseProjectFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchases',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Vendor-linked purchase entries',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.go('/purchases/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Purchase'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (projects) => Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<int?>(
                          value: filterProject,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Project',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All Projects')),
                            ...projects.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: (v) => ref
                              .read(purchaseProjectFilterProvider.notifier)
                              .state = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: purchasesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (purchases) => DataTableCard(
                  emptyMessage: 'No purchases found.',
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Project')),
                    DataColumn(label: Text('Vendor')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Amount'), numeric: true),
                    DataColumn(label: Text('Payment')),
                    DataColumn(label: Text('Mode')),
                  ],
                  rows: purchases.map((pd) {
                    return DataRow(cells: [
                      DataCell(Text(
                          DateFormatter.format(pd.transaction.date))),
                      DataCell(Text(pd.project.name,
                          overflow: TextOverflow.ellipsis)),
                      DataCell(Text(pd.vendor.name)),
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: Text(pd.purchase.itemDescription,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      DataCell(Text(
                          CurrencyFormatter.format(pd.transaction.amount))),
                      DataCell(_PaymentStatusChip(
                          status: pd.purchase.paymentStatus)),
                      DataCell(Text(
                          pd.transaction.paymentMode?.displayName ?? '—')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentStatusChip extends StatelessWidget {
  final PaymentStatus status;
  const _PaymentStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      PaymentStatus.paid => (Colors.green.shade700, Colors.green.shade50),
      PaymentStatus.pending => (Colors.red.shade700, Colors.red.shade50),
      PaymentStatus.partial => (Colors.orange.shade700, Colors.orange.shade50),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
