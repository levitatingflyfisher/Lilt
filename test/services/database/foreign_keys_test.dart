import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/services/database/database.dart';

/// The schema declares its links (matches -> sessions ON DELETE CASCADE,
/// shortlist -> names), and SQLite enforces them only with
/// PRAGMA foreign_keys = ON, which every connection now sets.
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('foreign keys are on', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.single, 1);
  });

  test('deleting a session removes its comparisons', () async {
    await db.sessionDao.insertSession(SessionsCompanion.insert(
        id: 's1',
        poolIds: '[]',
        genderFilter: 'all',
        poolSize: 0,
        createdAt: DateTime(2026)));
    await db.eloMatchesDao.insertMatch(EloMatchRowsCompanion.insert(
        sessionId: 's1',
        nameIdA: 'a',
        nameIdB: 'b',
        outcome: 'aWins',
        matchedAt: DateTime(2026)));
    await (db.delete(db.sessions)..where((t) => t.id.equals('s1'))).go();
    expect(await db.select(db.eloMatchRows).get(), isEmpty);
  });

  test('a comparison for a session that does not exist is refused',
      () async {
    await expectLater(
      db.eloMatchesDao.insertMatch(EloMatchRowsCompanion.insert(
          sessionId: 'nope',
          nameIdA: 'a',
          nameIdB: 'b',
          outcome: 'aWins',
          matchedAt: DateTime(2026))),
      throwsA(isA<SqliteException>()),
    );
  });

  test('a shortlist entry for an unknown name is refused', () async {
    await expectLater(
      db.shortlistDao.add(ShortlistEntriesCompanion.insert(
          id: 'e1', nameId: 'nobody-n', addedAt: DateTime(2026))),
      throwsA(isA<SqliteException>()),
    );
  });
}
