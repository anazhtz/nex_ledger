import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/services/backup_restore_service.dart';
import 'package:nex_ledger/features/projects/data/project_repository.dart';
import 'package:nex_ledger/features/settings/presentation/widgets/restore_database_dialog.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nex_ledger_test_');
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Database Backup & Restore Cross-Platform Engine Audit', () {
    test('1. SQLite File Header Validation & Format Inspection', () async {
      // 1. Create a simulated valid SQLite database file (first 16 bytes: 'SQLite format 3\0')
      final validSqlitePath = p.join(tempDir.path, 'valid_test.sqlite');
      final validFile = File(validSqlitePath);
      final validBytes = [
        ...('SQLite format 3'.codeUnits),
        0, // null terminator = 16 bytes
        ...List.filled(100, 42),
      ];
      await validFile.writeAsBytes(validBytes);

      final validInfo = await DatabaseBackupRestoreService.inspectBackupFile(validSqlitePath);
      expect(validInfo.isValidSqlite, isTrue);
      expect(validInfo.fileName, 'valid_test.sqlite');
      expect(validInfo.sizeBytes, validBytes.length);
      expect(validInfo.formattedSize, contains('B'));

      // 2. Create an invalid/corrupted dummy text file
      final invalidPath = p.join(tempDir.path, 'corrupted.txt');
      final invalidFile = File(invalidPath);
      await invalidFile.writeAsString('This is just a text file, not a sqlite DB');

      final invalidInfo = await DatabaseBackupRestoreService.inspectBackupFile(invalidPath);
      expect(invalidInfo.isValidSqlite, isFalse);
      expect(invalidInfo.fileName, 'corrupted.txt');
    });

    test('2. Inspect Non-Existent File Throws FileSystemException', () async {
      final nonExistentPath = p.join(tempDir.path, 'ghost_file.db');
      expect(
        () => DatabaseBackupRestoreService.inspectBackupFile(nonExistentPath),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('3. Restore Invalid File Throws FormatException with Clear Message', () async {
      final corruptFilePath = p.join(tempDir.path, 'invalid_backup.db');
      await File(corruptFilePath).writeAsString('Random gibberish bytes without sqlite header');

      expect(
        () => DatabaseBackupRestoreService.restoreDatabase(
          sourceBackupPath: corruptFilePath,
          currentDb: db,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('4. BackupFileInfo size formatting helper test', () {
      final infoSmall = BackupFileInfo(
        path: '/tmp/test.db',
        fileName: 'test.db',
        sizeBytes: 500,
        lastModified: DateTime.now(),
        isValidSqlite: true,
      );
      expect(infoSmall.formattedSize, '500 B');

      final infoKb = BackupFileInfo(
        path: '/tmp/test.db',
        fileName: 'test.db',
        sizeBytes: 2048,
        lastModified: DateTime.now(),
        isValidSqlite: true,
      );
      expect(infoKb.formattedSize, '2.0 KB');

      final infoMb = BackupFileInfo(
        path: '/tmp/test.db',
        fileName: 'test.db',
        sizeBytes: 5 * 1024 * 1024,
        lastModified: DateTime.now(),
        isValidSqlite: true,
      );
      expect(infoMb.formattedSize, '5.00 MB');
    });

    testWidgets('5. RestoreDatabaseDialog UI Rendering & File Picker Interface', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: ScreenUtilInit(
            designSize: const Size(1280, 800),
            minTextAdapt: true,
            builder: (context, child) => const MaterialApp(
              home: Scaffold(
                body: RestoreDatabaseDialog(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header
      expect(find.text('Restore Database from Backup'), findsOneWidget);
      expect(find.textContaining('Replace current database records'), findsOneWidget);

      // Check file picker action button
      expect(find.textContaining('Click to Choose Backup File'), findsOneWidget);

      // Check safety guarantee notice
      expect(find.textContaining('Safety Guarantee:'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
