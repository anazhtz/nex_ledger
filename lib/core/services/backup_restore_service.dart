import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:nex_ledger/core/database/app_database.dart';

class BackupFileInfo {
  final String path;
  final String fileName;
  final int sizeBytes;
  final DateTime lastModified;
  final bool isValidSqlite;

  const BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.sizeBytes,
    required this.lastModified,
    required this.isValidSqlite,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get formattedDate =>
      DateFormat('dd MMM yyyy, hh:mm a').format(lastModified);
}

class RestoreResult {
  final bool success;
  final String message;
  final String? restoredFromPath;
  final String? emergencySnapshotPath;
  final int? restoredSizeBytes;

  const RestoreResult({
    required this.success,
    required this.message,
    this.restoredFromPath,
    this.emergencySnapshotPath,
    this.restoredSizeBytes,
  });
}

class BackupResult {
  final bool success;
  final String message;
  final String destinationPath;
  final int sizeBytes;

  const BackupResult({
    required this.success,
    required this.message,
    required this.destinationPath,
    required this.sizeBytes,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class DatabaseBackupRestoreService {
  DatabaseBackupRestoreService._();

  /// Export a timestamped copy of the active database to the target directory.
  static Future<BackupResult> backupDatabase({
    String? customTargetDir,
    bool isQuickToDownloads = false,
  }) async {
    String? destDir = customTargetDir;

    if (destDir == null && isQuickToDownloads) {
      if (Platform.isMacOS) {
        final home = Platform.environment['HOME'] ?? '';
        final realHome = home.split('/Library/Containers').first;
        final userDownloads = '$realHome/Downloads';
        if (Directory(userDownloads).existsSync()) {
          destDir = userDownloads;
        }
      }
      destDir ??= (await getDownloadsDirectory())?.path;
      destDir ??= (await getApplicationDocumentsDirectory()).path;
    }

    if (destDir == null) {
      throw Exception('No destination directory provided for backup.');
    }

    final targetDir = Directory(destDir);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final sourcePath = await AppDatabase.getDatabasePath();
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('Active database file not found at: $sourcePath');
    }

    final now = DateTime.now();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);
    final destPath = p.join(destDir, 'nex_ledger_backup_$timestamp.db');

    final copiedFile = await sourceFile.copy(destPath);
    final size = await copiedFile.length();

    return BackupResult(
      success: true,
      message: 'Database backup created successfully',
      destinationPath: destPath,
      sizeBytes: size,
    );
  }

  /// Inspect and validate a selected backup file.
  static Future<BackupFileInfo> inspectBackupFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', filePath);
    }

    final size = await file.length();
    final modified = await file.lastModified();

    // Check SQLite header signature (first 16 bytes: "SQLite format 3\000")
    bool isValid = false;
    if (size >= 16) {
      RandomAccessFile? raf;
      try {
        raf = await file.open(mode: FileMode.read);
        final headerBytes = await raf.read(16);
        final headerStr = String.fromCharCodes(headerBytes);
        isValid = headerStr.startsWith('SQLite format 3');
      } catch (_) {
        isValid = false;
      } finally {
        await raf?.close();
      }
    }

    return BackupFileInfo(
      path: filePath,
      fileName: p.basename(filePath),
      sizeBytes: size,
      lastModified: modified,
      isValidSqlite: isValid,
    );
  }

  /// Restores database from a verified backup file.
  /// Safely creates an emergency snapshot of current state, closes active connections,
  /// removes obsolete WAL/SHM locks, and replaces the database file.
  static Future<RestoreResult> restoreDatabase({
    required String sourceBackupPath,
    required AppDatabase currentDb,
  }) async {
    // 1. Inspect source file
    final info = await inspectBackupFile(sourceBackupPath);
    if (!info.isValidSqlite) {
      throw FormatException(
        'The selected file "${info.fileName}" is not a valid SQLite database. '
        'Missing SQLite format signature.',
      );
    }

    final liveDbPath = await AppDatabase.getDatabasePath();
    final liveDbFile = File(liveDbPath);
    String? emergencySnapshotPath;

    // 2. Create emergency pre-restore snapshot if live database exists
    if (await liveDbFile.exists() && (await liveDbFile.length()) > 0) {
      final appDir = await getApplicationSupportDirectory();
      final now = DateTime.now();
      final snapshotTimestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now);
      emergencySnapshotPath = p.join(
        appDir.path,
        'nex_ledger_prerestore_emergency_$snapshotTimestamp.sqlite',
      );
      try {
        await liveDbFile.copy(emergencySnapshotPath);
      } catch (_) {
        // Fallback non-fatal snapshot attempt
      }
    }

    // 3. Safely close database to release file locks on Windows / macOS
    try {
      await currentDb.close();
    } catch (_) {
      // Ignored if already closed
    }

    // Small delay to allow OS file handles to release on Windows
    await Future.delayed(const Duration(milliseconds: 150));

    // 4. Clean up any active WAL / SHM files to prevent journal corruption
    final walFile = File('$liveDbPath-wal');
    if (await walFile.exists()) {
      try {
        await walFile.delete();
      } catch (_) {}
    }

    final shmFile = File('$liveDbPath-shm');
    if (await shmFile.exists()) {
      try {
        await shmFile.delete();
      } catch (_) {}
    }

    // 5. Copy the restored backup file into place
    final backupSourceFile = File(sourceBackupPath);
    final restoredFile = await backupSourceFile.copy(liveDbPath);
    final restoredSize = await restoredFile.length();

    return RestoreResult(
      success: true,
      message: 'Database restored successfully from "${info.fileName}".',
      restoredFromPath: sourceBackupPath,
      emergencySnapshotPath: emergencySnapshotPath,
      restoredSizeBytes: restoredSize,
    );
  }
}
