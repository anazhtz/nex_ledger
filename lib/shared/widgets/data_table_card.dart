import 'package:flutter/material.dart';

/// Wraps a DataTable in a high-end ERP styled Card with header and empty state handling.
class DataTableCard extends StatelessWidget {
  final String? title;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Widget? action;
  final String? emptyMessage;
  final bool showBorder;

  const DataTableCard({
    super.key,
    this.title,
    required this.columns,
    required this.rows,
    this.action,
    this.emptyMessage,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || action != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  const Spacer(),
                  if (action != null) action!,
                ],
              ),
            ),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 10),
                    Text(
                      emptyMessage ?? 'No records found.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 500),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                  dividerThickness: 1,
                  columnSpacing: 28,
                  horizontalMargin: 20,
                  columns: columns,
                  rows: rows,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
