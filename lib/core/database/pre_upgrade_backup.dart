import 'dart:io';

import 'package:path/path.dart' as p;

/// Copies the database file to `pre_update_backups/` before the app changes
/// its format (a schema upgrade), so a bad update can never cost the client
/// their data. Keeps only the newest [keep] copies.
///
/// Returns the backup file, or null when nothing needed backing up (new
/// install, same version, or a database that is newer than this app).
File? backupBeforeUpgrade({
  required String dbPath,
  required int oldVersion,
  required int newVersion,
  int keep = 5,
  DateTime? now,
}) {
  if (oldVersion <= 0 || oldVersion >= newVersion) return null;
  final source = File(dbPath);
  if (!source.existsSync()) return null;

  final dir = Directory(p.join(p.dirname(dbPath), 'pre_update_backups'))
    ..createSync(recursive: true);
  final t = (now ?? DateTime.now());
  String two(int v) => v.toString().padLeft(2, '0');
  final stamp =
      '${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}${two(t.second)}';
  final target = File(p.join(
      dir.path,
      'before_v${newVersion}_from_v$oldVersion'
      '_$stamp.sqlite'));
  source.copySync(target.path);

  final old = dir
      .listSync()
      .whereType<File>()
      .where((f) => p.basename(f.path).startsWith('before_v'))
      .toList()
    ..sort((a, b) => b.path.compareTo(a.path)); // newest name first
  for (final f in old.skip(keep)) {
    try {
      f.deleteSync();
    } catch (_) {}
  }
  return target;
}
