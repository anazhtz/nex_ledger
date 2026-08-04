import 'package:flutter/material.dart';

/// Wraps a DataTable in a themed Card with an optional title and action widget.
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || action != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
              child: Row(
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Spacer(),
                  if (action != null) action!,
                ],
              ),
            ),
          if (title != null || action != null) const SizedBox(height: 8),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  emptyMessage ?? 'No records found.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 400),
                child: DataTable(
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
