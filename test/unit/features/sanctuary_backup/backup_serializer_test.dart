import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:lilt/services/database/database.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

void main() {
  late AppDatabase db;
  late LiltBackupSerializer serializer;

  final now = DateTime(2026, 7, 12);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    serializer = LiltBackupSerializer(db);
  });

  tearDown(() => db.close());

  /// Seeds a bundled-catalog name (isCustom = false, as ensureLoaded() would
  /// write it from assets/data/names.json), a custom name, one session with
  /// a match, and a shortlist entry pointing at EACH kind of name.
  Future<void> seedData() async {
    await db.into(db.nameEntries).insert(NameEntriesCompanion.insert(
          id: 'eliot-m',
          display: 'Eliot',
          gender: 'm',
          variants: '["Elliott"]',
        ));
    await db.into(db.nameEntries).insert(NameEntriesCompanion.insert(
          id: 'zephyr-m',
          display: 'Zephyr',
          gender: 'm',
          variants: '[]',
          isCustom: const Value(true),
        ));

    await db.into(db.sessions).insert(SessionsCompanion.insert(
          id: 's1',
          poolIds: '["eliot-m","zephyr-m"]',
          genderFilter: 'm',
          poolSize: 2,
          isComplete: const Value(true),
          resultsLocked: const Value(false),
          createdAt: now,
          completedAt: Value(now),
        ));

    await db.into(db.eloMatchRows).insert(EloMatchRowsCompanion.insert(
          sessionId: 's1',
          nameIdA: 'eliot-m',
          nameIdB: 'zephyr-m',
          outcome: 'aWins',
          matchedAt: now,
        ));

    await db.into(db.shortlistEntries).insert(ShortlistEntriesCompanion.insert(
          id: 'sh-catalog',
          nameId: 'eliot-m',
          note: const Value('catalog name pick'),
          addedAt: now,
        ));
    await db.into(db.shortlistEntries).insert(ShortlistEntriesCompanion.insert(
          id: 'sh-custom',
          nameId: 'zephyr-m',
          addedAt: now,
        ));
  }

  group('BackupSerializer', () {
    test('dumpAll carries app + schemaVersion envelope', () async {
      final bytes = await serializer.dumpAll();
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

      expect(json['app'], equals('lilt'));
      expect(json['schemaVersion'], equals(db.schemaVersion));
      expect(json['exportedAt'], isNotNull);
    });

    test('dumpAll includes only custom names, never the bundled catalog',
        () async {
      await seedData();
      final bytes = await serializer.dumpAll();
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final tables = json['tables'] as Map<String, dynamic>;

      final names = (tables['nameEntries'] as List).cast<Map<String, dynamic>>();
      expect(names, hasLength(1));
      expect(names.single['id'], equals('zephyr-m'));
      expect(names.single['isCustom'], isTrue);
    });

    test('dumpAll includes sessions, matches, and shortlist', () async {
      await seedData();
      final bytes = await serializer.dumpAll();
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final tables = json['tables'] as Map<String, dynamic>;

      expect(tables['sessions'], hasLength(1));
      expect(tables['eloMatchRows'], hasLength(1));
      expect(tables['shortlistEntries'], hasLength(2));
    });

    test(
        'restoreAll preserves the bundled catalog and the shortlist entry '
        'that references it', () async {
      await seedData();
      final bytes = await serializer.dumpAll();

      await serializer.restoreAll(bytes);

      final names = await db.select(db.nameEntries).get();
      // Catalog row (eliot-m, isCustom=false) untouched + custom row restored.
      expect(names.map((n) => n.id).toSet(), {'eliot-m', 'zephyr-m'});
      expect(names.firstWhere((n) => n.id == 'eliot-m').isCustom, isFalse);
      expect(names.firstWhere((n) => n.id == 'zephyr-m').isCustom, isTrue);

      final shortlist = await db.select(db.shortlistEntries).get();
      expect(shortlist.map((s) => s.nameId).toSet(), {'eliot-m', 'zephyr-m'});
    });

    test('restoreAll round-trips session peeking-prevention state exactly',
        () async {
      await seedData();
      final bytes = await serializer.dumpAll();

      await serializer.restoreAll(bytes);

      final sessions = await db.select(db.sessions).get();
      expect(sessions, hasLength(1));
      expect(sessions.single.isComplete, isTrue);
      expect(sessions.single.resultsLocked, isFalse);
    });

    test('restoreAll round-trips match history', () async {
      await seedData();
      final bytes = await serializer.dumpAll();

      await serializer.restoreAll(bytes);

      final matches = await db.select(db.eloMatchRows).get();
      expect(matches, hasLength(1));
      expect(matches.single.nameIdA, equals('eliot-m'));
      expect(matches.single.nameIdB, equals('zephyr-m'));
      expect(matches.single.outcome, equals('aWins'));
    });

    test('restoreAll wipes existing custom/session data before inserting',
        () async {
      await seedData();

      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      final serializer2 = LiltBackupSerializer(db2);
      await db2.into(db2.nameEntries).insert(NameEntriesCompanion.insert(
            id: 'mara-f',
            display: 'Mara',
            gender: 'f',
            variants: '[]',
            isCustom: const Value(true),
          ));
      final otherDump = await serializer2.dumpAll();
      await db2.close();

      await serializer.restoreAll(otherDump);

      final names = await db.select(db.nameEntries).get();
      // Old custom name (zephyr-m) gone; catalog (eliot-m) preserved; new
      // custom name (mara-f) present.
      expect(names.map((n) => n.id).toSet(), {'eliot-m', 'mara-f'});

      final sessions = await db.select(db.sessions).get();
      expect(sessions, isEmpty);
    });

    test('restoreAll rejects a backup from a different app', () async {
      final payload = jsonEncode({
        'app': 'lullaby',
        'schemaVersion': 1,
        'exportedAt': now.toIso8601String(),
        'tables': {
          'nameEntries': <dynamic>[],
          'sessions': <dynamic>[],
          'eloMatchRows': <dynamic>[],
          'shortlistEntries': <dynamic>[],
        },
      });
      final bytes = Uint8List.fromList(utf8.encode(payload));

      expect(
        () => serializer.restoreAll(bytes),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('restoreAll rejects a future schema version', () async {
      final payload = jsonEncode({
        'app': 'lilt',
        'schemaVersion': 999,
        'exportedAt': now.toIso8601String(),
        'tables': {
          'nameEntries': <dynamic>[],
          'sessions': <dynamic>[],
          'eloMatchRows': <dynamic>[],
          'shortlistEntries': <dynamic>[],
        },
      });
      final bytes = Uint8List.fromList(utf8.encode(payload));

      expect(
        () => serializer.restoreAll(bytes),
        throwsA(isA<BackupSchemaException>()),
      );
    });

    test('restoreAll rejects missing schemaVersion', () async {
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode({
        'app': 'lilt',
        'tables': <String, dynamic>{},
      })));

      expect(
        () => serializer.restoreAll(bytes),
        throwsA(isA<FormatException>()),
      );
    });

    test('restoreAll rejects missing tables key', () async {
      final bytes = Uint8List.fromList(utf8.encode(jsonEncode({
        'app': 'lilt',
        'schemaVersion': 1,
      })));

      expect(
        () => serializer.restoreAll(bytes),
        throwsA(isA<FormatException>()),
      );
    });

    test('a rejected restore never touches existing data (fail closed)',
        () async {
      await seedData();

      final badPayload = jsonEncode({
        'app': 'lilt',
        'schemaVersion': 999,
        'tables': {
          'nameEntries': <dynamic>[],
          'sessions': <dynamic>[],
          'eloMatchRows': <dynamic>[],
          'shortlistEntries': <dynamic>[],
        },
      });
      final bytes = Uint8List.fromList(utf8.encode(badPayload));

      await expectLater(
        () => serializer.restoreAll(bytes),
        throwsA(isA<BackupSchemaException>()),
      );

      final sessions = await db.select(db.sessions).get();
      expect(sessions, hasLength(1), reason: 'original data must survive');
    });
  });
}
