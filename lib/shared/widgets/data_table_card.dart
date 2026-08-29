import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Wraps a DataTable in a high-end ERP styled Card with header, empty state,
/// and responsive vertical + horizontal scrolling support.
class DataTableCard extends StatelessWidget {
  final String? title;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Widget? action;
  final String? emptyMessage;
  final bool showBorder;
  final double? minWidth;

  const DataTableCard({
    super.key,
    this.title,
    required this.columns,
    required this.rows,
    this.action,
    this.emptyMessage,
    this.showBorder = true,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: showBorder
            ? const BorderSide(color: Color(0xFFE2E8F0), width: 1)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.hasBoundedHeight;
          final cardWidth = constraints.maxWidth;

          // Calculate dynamic column spacing so table columns span 100% of card width without trailing empty space
          double computedSpacing = 20.w;
          final numCols = columns.length;
          if (numCols > 1 && cardWidth.isFinite && cardWidth > 0) {
            final targetWidth = math.max(minWidth ?? 0.0, cardWidth);
            final double approxColWidth = 110.w;
            final double totalContentWidth = numCols * approxColWidth;
            final double totalMargins = 32.w;
            final double spaceForGaps =
                targetWidth - totalContentWidth - totalMargins;
            if (spaceForGaps > 0) {
              computedSpacing = (spaceForGaps / (numCols - 1)).clamp(16.w, 32.w);
            }
          }

          Widget tableContent;
          if (rows.isEmpty) {
            tableContent = Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 40.sp, color: const Color(0xFF94A3B8)),
                    SizedBox(height: 10.h),
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
            );
          } else {
            tableContent = SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: math.max(minWidth ?? 600.w, cardWidth)),
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF334155),
                    fontSize: 12.sp,
                    letterSpacing: 0.3,
                  ),
                  dataTextStyle: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                  dividerThickness: 1,
                  columnSpacing: computedSpacing,
                  horizontalMargin: 16.w,
                  columns: columns,
                  rows: rows,
                ),
              ),
            );

            if (hasBoundedHeight) {
              tableContent = Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: tableContent,
                ),
              );
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize:
                hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (title != null || action != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12.w,
                    runSpacing: 8.h,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      if (action != null) action!,
                    ],
                  ),
                ),
              tableContent,
            ],
          );
        },
      ),
    );
  }
}
