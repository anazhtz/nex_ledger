import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/shared/widgets/app_dropdown.dart';

Widget host(Widget child) => ScreenUtilInit(
      designSize: const Size(1440, 900),
      builder: (context, _) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
            body: Center(child: SizedBox(width: 300, child: child))),
      ),
    );

void main() {
  testWidgets('short list: plain menu without search; picking changes value',
      (tester) async {
    String? picked = 'credit';
    await tester.pumpWidget(host(StatefulBuilder(
      builder: (context, set) => AppDropdownField<String>(
        value: picked,
        decoration: const InputDecoration(labelText: 'Payment Terms'),
        items: const [
          DropdownMenuItem(value: 'credit', child: Text('Credit (Unpaid)')),
          DropdownMenuItem(value: 'part', child: Text('Partial Advance')),
          DropdownMenuItem(value: 'paid', child: Text('Paid in Full')),
        ],
        onChanged: (v) => set(() => picked = v),
      ),
    )));
    await tester.tap(find.text('Credit (Unpaid)'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('select_search')), findsNothing);
    await tester.tap(find.text('Paid in Full'));
    await tester.pumpAndSettle();
    expect(picked, 'paid');
  });

  testWidgets('long list gets a search box; null item acts as "All"',
      (tester) async {
    int? picked;
    await tester.pumpWidget(host(StatefulBuilder(
      builder: (context, set) => AppDropdownField<int?>(
        value: picked,
        items: [
          const DropdownMenuItem(value: null, child: Text('All Categories')),
          for (var i = 1; i <= 10; i++)
            DropdownMenuItem(value: i, child: Text('Item number $i')),
        ],
        onChanged: (v) => set(() => picked = v),
      ),
    )));
    expect(find.text('All Categories'), findsOneWidget);
    await tester.tap(find.text('All Categories'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('select_search')), 'number 7');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Item number 7'));
    await tester.pumpAndSettle();
    expect(picked, 7);
  });

  testWidgets('disabled when onChanged is null', (tester) async {
    await tester.pumpWidget(host(const AppDropdownField<String>(
      value: 'a',
      onChanged: null,
      items: [DropdownMenuItem(value: 'a', child: Text('Alpha'))],
    )));
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.byType(Material).evaluate().length, greaterThan(0));
    expect(find.text('Esc to close'), findsNothing);
  });
}
