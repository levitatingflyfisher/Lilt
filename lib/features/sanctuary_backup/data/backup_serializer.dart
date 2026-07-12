import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart' show BackupFormatException;
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

import '../../../services/database/database.dart';

/// Serializes Lilt's user data to/from a JSON [Uint8List] for encrypted
/// backup via sanctuary_backup_ui.
///
/// Implements the package's [BackupSerializer] interface, working directly
/// with [AppDatabase].
///
/// **Scope: custom data only, never the bundled name catalog.** `NameEntries`
/// mixes two very different things — ~1,636 bundled names loaded once from
/// `assets/data/names.json` (`isCustom = false`) and names the user typed in
/// (`isCustom = true`). Only the latter is backed up: the catalog ships with
/// the app and is reseeded by `NamesRepository.ensureLoaded()`, so bundling
/// it would bloat every backup and risk restoring a stale catalog over a
/// newer one. Restore therefore only wipes/re-inserts custom names, sessions,
/// match history, and shortlist entries — the catalog (and any shortlist
/// entry pointing at it) is left untouched and its FK reference still
/// resolves (Sanctuary scout gotcha #4).
class LiltBackupSerializer implements BackupSerializer {
  static const _appId = 'lilt';

  final AppDatabase _db;

  const LiltBackupSerializer(this._db);

  /// Reads custom names, sessions, match history, and shortlist entries and
  /// returns the JSON payload as bytes.
  @override
  Future<Uint8List> dumpAll() async {
    final customNames = await (_db.select(_db.nameEntries)
          ..where((t) => t.isCustom.equals(true)))
        .get();
    final allSessions = await _db.select(_db.sessions).get();
    final allMatches = await _db.select(_db.eloMatchRows).get();
    final allShortlist = await _db.select(_db.shortlistEntries).get();

    final payload = <String, dynamic>{
      'app': _appId,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'tables': {
        'nameEntries': customNames.map((r) => r.toJson()).toList(),
        'sessions': allSessions.map((r) => r.toJson()).toList(),
        'eloMatchRows': allMatches.map((r) => r.toJson()).toList(),
        'shortlistEntries': allShortlist.map((r) => r.toJson()).toList(),
      },
    };

    return Uint8List.fromList(utf8.encode(jsonEncode(payload)));
  }

  /// Restores custom names, sessions, match history, and shortlist entries
  /// from a JSON [Uint8List] previously created by [dumpAll].
  ///
  /// **This is destructive** — existing custom names, sessions, matches, and
  /// shortlist entries are wiped before inserting. The bundled name catalog
  /// (`isCustom = false`) is never touched.
  ///
  /// Throws [BackupFormatException] if the payload is from a different app.
  /// Throws [BackupSchemaException] if the payload's schema version is newer
  /// than the current database version.
  /// Throws [FormatException] if the payload is not valid JSON or is missing
  /// required fields.
  @override
  Future<void> restoreAll(Uint8List data) async {
    final json = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;

    // Checked before the transaction opens — a rejected restore must never
    // touch existing data (SANCTUARY-BRIEF §2.4/§2.8: fail closed).
    final app = json['app'] as String?;
    if (app != _appId) {
      throw BackupFormatException(
        'This backup is from a different app ("${app ?? 'unknown'}"), not Lilt.',
      );
    }

    final version = json['schemaVersion'] as int?;
    if (version == null) {
      throw const FormatException('Missing schemaVersion in backup payload');
    }
    if (version > _db.schemaVersion) {
      throw BackupSchemaException(version, _db.schemaVersion);
    }

    final tables = json['tables'] as Map<String, dynamic>?;
    if (tables == null) {
      throw const FormatException('Missing tables in backup payload');
    }

    await _db.transaction(() async {
      // Wipe in reverse FK order. NameEntries is filtered to isCustom=true
      // only — the bundled catalog (isCustom=false) survives untouched, and
      // any shortlist entry pointing at a catalog name keeps resolving.
      await _db.delete(_db.eloMatchRows).go();
      await _db.delete(_db.shortlistEntries).go();
      await _db.delete(_db.sessions).go();
      await (_db.delete(_db.nameEntries)..where((t) => t.isCustom.equals(true)))
          .go();

      // Insert in FK order: names first (ShortlistEntries.nameId depends on
      // them), then sessions, then their matches, then shortlist entries.
      for (final row in _jsonList(tables, 'nameEntries')) {
        await _db.into(_db.nameEntries).insert(
              NameEntriesCompanion.insert(
                id: row['id'] as String,
                display: row['display'] as String,
                gender: row['gender'] as String,
                variants: row['variants'] as String,
                isCustom: Value(row['isCustom'] as bool? ?? true),
              ),
            );
      }

      for (final row in _jsonList(tables, 'sessions')) {
        await _db.into(_db.sessions).insert(
              SessionsCompanion.insert(
                id: row['id'] as String,
                participantLabel: Value(row['participantLabel'] as String?),
                poolIds: row['poolIds'] as String,
                genderFilter: row['genderFilter'] as String,
                poolSize: row['poolSize'] as int,
                isComplete: Value(row['isComplete'] as bool? ?? false),
                resultsLocked: Value(row['resultsLocked'] as bool? ?? true),
                createdAt: _dateTime(row['createdAt']),
                completedAt: Value(_dateTimeOrNull(row['completedAt'])),
              ),
            );
      }

      for (final row in _jsonList(tables, 'eloMatchRows')) {
        await _db.into(_db.eloMatchRows).insert(
              EloMatchRowsCompanion.insert(
                // id is autoincrement and referenced by nothing else — let
                // SQLite assign a fresh one rather than preserving the old.
                sessionId: row['sessionId'] as String,
                nameIdA: row['nameIdA'] as String,
                nameIdB: row['nameIdB'] as String,
                outcome: row['outcome'] as String,
                matchedAt: _dateTime(row['matchedAt']),
              ),
            );
      }

      for (final row in _jsonList(tables, 'shortlistEntries')) {
        await _db.into(_db.shortlistEntries).insert(
              ShortlistEntriesCompanion.insert(
                id: row['id'] as String,
                nameId: row['nameId'] as String,
                note: Value(row['note'] as String?),
                addedAt: _dateTime(row['addedAt']),
              ),
            );
      }
    });
  }

  List<Map<String, dynamic>> _jsonList(
    Map<String, dynamic> tables,
    String key,
  ) {
    final list = tables[key] as List<dynamic>?;
    if (list == null) return const [];
    return list.cast<Map<String, dynamic>>();
  }

  /// Drift's default serializer encodes DateTime as Unix milliseconds (int).
  DateTime _dateTime(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.parse(value);
    throw FormatException('Cannot parse DateTime from: $value');
  }

  DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) return null;
    return _dateTime(value);
  }
}
