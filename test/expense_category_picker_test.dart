import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/cash_book/presentation/widgets/expense_category_picker.dart';

ExpenseCategory cat(int id, String name, {String group = 'G'}) =>
    ExpenseCategory(
        id: id,
        groupName: group,
        subCategory: name,
        isDefault: true,
        isActive: true,
        sortOrder: id);

void main() {
  final cats = [
    cat(1, 'Tea & Snacks'),
    cat(2, 'fuel (Vehicle)'),
    cat(3, 'Accounting Fees'),
    cat(4, 'Transport'),
    cat(5, '24x7 Security'),
  ];

  test('sorts A-Z ignoring case, with a header per letter', () {
    final e = buildCategoryIndex(cats);
    final labels =
        e.map((x) => x.isHeader ? '[${x.letter}]' : x.category!.subCategory);
    expect(labels.toList(), [
      '[#]',
      '24x7 Security',
      '[A]',
      'Accounting Fees',
      '[F]',
      'fuel (Vehicle)',
      '[T]',
      'Tea & Snacks',
      'Transport',
    ]);
  });

  test('search filters by name and keeps headers consistent', () {
    final e = buildCategoryIndex(cats, query: 'TR');
    expect(
        e.map((x) => x.isHeader ? x.letter : x.category!.subCategory).toList(),
        ['T', 'Transport']);
    expect(buildCategoryIndex(cats, query: 'zzz'), isEmpty);
  });

  testWidgets('picker returns the chosen head and supports letter jump',
      (tester) async {
    ExpenseCategoryChoice? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result =
              await showExpenseCategoryPicker(context, categories: cats),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Select Expense Head'), findsOneWidget);

    await tester.tap(find.text('T').first); // letter chip
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transport'));
    await tester.pumpAndSettle();
    expect(result?.id, 4);
  });
}
