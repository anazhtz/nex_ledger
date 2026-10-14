import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/pre_upgrade_backup.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory dir;
  late String dbPath;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('nex_backup_test');
    dbPath = p.join(dir.path, 'nex_ledger.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Directory backups() => Directory(p.join(dir.path, 'pre_update_backups'));

  test('older database is copied before upgrading, content identical', () {
    File(dbPath).writeAsStringSync('client data');
    final copy =
        backupBeforeUpgrade(dbPath: dbPath, oldVersion: 19, newVersion: 20);
    expect(copy, isNotNull);
    expect(copy!.readAsStringSync(), 'client data');
    expect(p.basename(copy.path), startsWith('before_v20_from_v19_'));
  });

  test('no backup for a new install, the same version or a newer database', () {
    File(dbPath).writeAsStringSync('x');
    expect(backupBeforeUpgrade(dbPath: dbPath, oldVersion: 0, newVersion: 20),
        isNull);
    expect(backupBeforeUpgrade(dbPath: dbPath, oldVersion: 20, newVersion: 20),
        isNull);
    expect(backupBeforeUpgrade(dbPath: dbPath, oldVersion: 21, newVersion: 20),
        isNull);
    expect(backups().existsSync(), isFalse);
  });

  test('no file, no backup, no crash', () {
    expect(backupBeforeUpgrade(dbPath: dbPath, oldVersion: 5, newVersion: 20),
        isNull);
  });

  test('only the newest 5 backups are kept', () {
    File(dbPath).writeAsStringSync('x');
    for (var i = 0; i < 8; i++) {
      backupBeforeUpgrade(
          dbPath: dbPath,
          oldVersion: 10 + i,
          newVersion: 30,
          now: DateTime(2026, 1, 1, 10, 0, i));
    }
    final names = backups().listSync().map((f) => p.basename(f.path)).toList()
      ..sort();
    expect(names.length, 5);
    expect(names.first, contains('from_v13')); // v10..v12 were dropped
  });

  test('opening a current database through the app creates no backup',
      () async {
    final db = AppDatabase(AppDatabase.openFile(File(dbPath)));
    await db.projectDao.getAllProjects(); // forces open + create
    await db.close();
    final again = AppDatabase(AppDatabase.openFile(File(dbPath)));
    await again.projectDao.getAllProjects();
    await again.close();
    expect(backups().existsSync(), isFalse);
    expect(File(dbPath).existsSync(), isTrue);
  });
}
