import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/shared/widgets/project_picker.dart';
import 'package:nex_ledger/shared/widgets/searchable_select.dart';

Project project(int id, String code, String name,
        {String? client, ProjectStatus status = ProjectStatus.active}) =>
    Project(
      id: id,
      code: code,
      name: name,
      type: ProjectType.project,
      status: status,
      startDate: DateTime(2026, 1, 1),
      clientName: client,
      clientContractValue: 0,
      clientRetentionPercentage: 0,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  final projects = [
    project(1, 'PRJ-001', 'Malabar Tower', client: 'Aldrich Homes'),
    project(2, 'PRJ-002', 'Luxury Villa Renovation', client: 'Mr. Nair'),
    project(3, 'GVHSS-01', 'Thamarassery School Building',
        client: 'PWD Kerala', status: ProjectStatus.onHold),
    project(4, 'OLD-9', 'Old Mall Fitout', status: ProjectStatus.closed),
  ];

  Future<void> pumpPicker(
    WidgetTester tester, {
    int? value,
    String? allLabel,
    bool required = false,
    required ValueChanged<int?> onChanged,
    GlobalKey<FormState>? formKey,
    Size size = const Size(900, 700),
    Alignment alignment = Alignment.topCenter,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    var current = value;
    await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) => MaterialApp(
              theme: AppTheme.light,
              home: Scaffold(
                body: Align(
                  alignment: alignment,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: StatefulBuilder(
                      builder: (context, setState) => SizedBox(
                        width: 360,
                        child: Form(
                          key: formKey,
                          child: ProjectPickerField(
                            projects: projects,
                            value: current,
                            labelText: 'Project',
                            allLabel: allLabel,
                            required: required,
                            onChanged: (v) {
                              setState(() => current = v);
                              onChanged(v);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )));
  }

  group('filtering', () {
    final options = projectOptions(projects);
    List<int> ids(String q) =>
        filterSelectOptions(options, q).map((o) => o.value).toList();

    test('finds by code, name or client; every word must match', () {
      expect(ids('malabar'), [1]);
      expect(ids('prj-00'), [1, 2]);
      expect(ids('nair'), [2]);
      expect(ids('school kerala'), [3], reason: 'words from name and client');
      expect(ids('villa tower'), isEmpty);
      expect(ids('  MALABAR  '), [1]);
      expect(ids('zzz'), isEmpty);
      expect(ids(''), [1, 2, 3, 4]);
    });

    test('matches at the start of the code or name come first', () {
      final opts = projectOptions([
        project(1, 'A-1', 'Tower in Malabar'),
        project(2, 'MAL-2', 'Other'),
        project(3, 'B-3', 'Malabar Heights'),
      ]);
      expect(filterSelectOptions(opts, 'mal').map((o) => o.value), [2, 3, 1]);
    });
  });

  group('picker', () {
    testWidgets(
        'shows the hint, opens on click with the search box ready, and selects',
        (tester) async {
      int? picked;
      await pumpPicker(tester, onChanged: (v) => picked = v);
      expect(find.text('Select project'), findsOneWidget);

      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('select_search')), findsOneWidget);
      expect(find.text('Malabar Tower'), findsOneWidget);
      expect(find.text('Client: Aldrich Homes'), findsOneWidget);
      expect(find.text('On Hold'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);

      await tester.tap(find.text('Luxury Villa Renovation'));
      await tester.pumpAndSettle();
      expect(picked, 2);
      expect(find.byKey(const Key('select_search')), findsNothing,
          reason: 'closes after choosing');
      expect(find.text('PRJ-002'), findsOneWidget,
          reason: 'badge shows in the field');
      expect(find.text('Luxury Villa Renovation'), findsOneWidget);
    });

    testWidgets('typing filters at once and Enter picks the first match',
        (tester) async {
      int? picked;
      await pumpPicker(tester, onChanged: (v) => picked = v);
      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('select_search')), 'thamar');
      await tester.pump();
      expect(find.text('Thamarassery School Building'), findsOneWidget);
      expect(find.text('Malabar Tower'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, 3);
    });

    testWidgets(
        'arrow keys move, Enter chooses, Escape closes without choosing',
        (tester) async {
      int? picked;
      await pumpPicker(tester, onChanged: (v) => picked = v);
      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, 2, reason: 'down, down, up lands on the second row');

      picked = null;
      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('select_search')), findsNothing);
      expect(picked, isNull);
    });

    testWidgets('clicking outside closes it', (tester) async {
      await pumpPicker(tester, onChanged: (_) {});
      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(800, 600));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('select_search')), findsNothing);
    });

    testWidgets(
        'no match shows a friendly message, and the clear button resets the search',
        (tester) async {
      await pumpPicker(tester, onChanged: (_) {});
      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('select_search')), 'xyz');
      await tester.pump();
      expect(find.text('No project matches "xyz"'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear'));
      await tester.pump();
      expect(find.text('Malabar Tower'), findsOneWidget);
    });

    testWidgets('the chosen project is marked and the list opens on it',
        (tester) async {
      await pumpPicker(tester, value: 2, onChanged: (_) {});
      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('an "All" option lets a filter go back to no project',
        (tester) async {
      int? picked = 1;
      await pumpPicker(tester,
          value: 1, allLabel: 'All Projects', onChanged: (v) => picked = v);
      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Projects'));
      await tester.pumpAndSettle();
      expect(picked, isNull);
      expect(find.text('All Projects'), findsOneWidget,
          reason: 'the field now reads "All Projects"');
    });

    testWidgets(
        'as a required form field it says so, and stops complaining once chosen',
        (tester) async {
      final key = GlobalKey<FormState>();
      await pumpPicker(tester, required: true, formKey: key, onChanged: (_) {});
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Please select a project'), findsOneWidget);

      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Malabar Tower'));
      await tester.pumpAndSettle();
      expect(key.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Please select a project'), findsNothing);
    });

    testWidgets('keyboard: the focused field opens with Enter', (tester) async {
      await pumpPicker(tester, onChanged: (_) {});
      Focus.of(tester.element(find.byKey(const Key('project_picker'))))
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('select_search')), findsOneWidget);
    });

    testWidgets('opens upward when there is no room below', (tester) async {
      await pumpPicker(tester,
          onChanged: (_) {},
          alignment: Alignment.bottomCenter,
          size: const Size(900, 500));
      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();
      final field = tester.getTopLeft(find.byKey(const Key('project_picker')));
      final search = tester.getTopLeft(find.byKey(const Key('select_search')));
      expect(search.dy, lessThan(field.dy),
          reason: 'the list sits above the field');
      expect(tester.takeException(), isNull);
    });

    testWidgets('a value that no longer exists shows as nothing selected',
        (tester) async {
      await pumpPicker(tester, value: 999, onChanged: (_) {});
      expect(find.text('Select project'), findsOneWidget);
    });

    testWidgets('long names do not overflow in a narrow field', (tester) async {
      tester.view.physicalSize = const Size(500, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ScreenUtilInit(
          designSize: const Size(1440, 900),
          builder: (context, _) => MaterialApp(
                theme: AppTheme.light,
                home: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 220,
                      child: ProjectPickerField(
                        projects: [
                          project(1, 'PRJ-LONG',
                              'A very long project name that keeps going and going and going',
                              client: 'An equally long client name for testing')
                        ],
                        value: 1,
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                ),
              )));
      await tester.tap(find.byKey(const Key('project_picker')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
