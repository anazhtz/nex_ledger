import 'package:flutter/material.dart';
import 'package:nex_ledger/core/database/app_database.dart';

/// One row of the picker list: either a letter header or an expense head.
class CategoryIndexEntry {
  final String? letter; // set for headers
  final ExpenseCategory? category; // set for rows
  const CategoryIndexEntry.header(String this.letter) : category = null;
  const CategoryIndexEntry.row(ExpenseCategory this.category) : letter = null;

  bool get isHeader => letter != null;
}

/// Letter used to file [name] in the A–Z index ('#' for non-letters).
String categoryLetter(String name) {
  final t = name.trim();
  if (t.isEmpty) return '#';
  final c = t[0].toUpperCase();
  return RegExp(r'[A-Z]').hasMatch(c) ? c : '#';
}

/// Sorts heads alphabetically (case-insensitive) and inserts a header before
/// each new starting letter. An optional [query] filters by name first.
List<CategoryIndexEntry> buildCategoryIndex(
  List<ExpenseCategory> categories, {
  String query = '',
}) {
  final q = query.trim().toLowerCase();
  final sorted = categories
      .where((c) => q.isEmpty || c.subCategory.toLowerCase().contains(q))
      .toList()
    ..sort((a, b) {
      final byName =
          a.subCategory.toLowerCase().compareTo(b.subCategory.toLowerCase());
      return byName != 0 ? byName : a.id.compareTo(b.id);
    });

  final result = <CategoryIndexEntry>[];
  String? current;
  for (final c in sorted) {
    final letter = categoryLetter(c.subCategory);
    if (letter != current) {
      current = letter;
      result.add(CategoryIndexEntry.header(letter));
    }
    result.add(CategoryIndexEntry.row(c));
  }
  return result;
}

/// Result of the picker. Wrapping the id lets "None" differ from "cancelled".
class ExpenseCategoryChoice {
  final int? id;
  const ExpenseCategoryChoice(this.id);
}

/// Opens the A–Z expense head picker. Returns null if the user cancels.
Future<ExpenseCategoryChoice?> showExpenseCategoryPicker(
  BuildContext context, {
  required List<ExpenseCategory> categories,
  int? selectedId,
}) {
  return showDialog<ExpenseCategoryChoice>(
    context: context,
    builder: (_) => _ExpenseCategoryPickerDialog(
      categories: categories,
      selectedId: selectedId,
    ),
  );
}

class _ExpenseCategoryPickerDialog extends StatefulWidget {
  final List<ExpenseCategory> categories;
  final int? selectedId;
  const _ExpenseCategoryPickerDialog({
    required this.categories,
    required this.selectedId,
  });

  @override
  State<_ExpenseCategoryPickerDialog> createState() =>
      _ExpenseCategoryPickerDialogState();
}

class _ExpenseCategoryPickerDialogState
    extends State<_ExpenseCategoryPickerDialog> {
  static const double _rowHeight = 44;
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _jumpTo(String letter, List<CategoryIndexEntry> entries) {
    final index = entries.indexWhere((e) => e.letter == letter);
    if (index < 0 || !_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    _scroll.animateTo(
      (index * _rowHeight).clamp(0.0, max),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = buildCategoryIndex(widget.categories, query: _query);
    final available = {
      for (final e in entries)
        if (e.isHeader) e.letter!,
    };
    const letters = [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ];

    return AlertDialog(
      title: const Text('Select Expense Head'),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      content: SizedBox(
        width: 460,
        height: 460,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search expense head...',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 2,
              runSpacing: 2,
              children: [
                for (final l in letters)
                  SizedBox(
                    width: 32,
                    height: 30,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      onPressed: available.contains(l)
                          ? () => _jumpTo(l, entries)
                          : null,
                      child: Text(l,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
              ],
            ),
            const Divider(height: 12),
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('No matching expense head'))
                  : ListView.builder(
                      controller: _scroll,
                      itemExtent: _rowHeight,
                      itemCount: entries.length,
                      itemBuilder: (context, i) {
                        final e = entries[i];
                        if (e.isHeader) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Text(e.letter!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                          );
                        }
                        final c = e.category!;
                        return ListTile(
                          dense: true,
                          selected: c.id == widget.selectedId,
                          title: Text(c.subCategory,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Text(c.groupName,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                          onTap: () => Navigator.pop(
                              context, ExpenseCategoryChoice(c.id)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const ExpenseCategoryChoice(null)),
          child: const Text('None (Uncategorised)'),
        ),
      ],
    );
  }
}
