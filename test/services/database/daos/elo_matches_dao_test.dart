import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/services/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // Sessions table must exist for FK constraint
    await db.sessionDao.insertSession(SessionsCompanion.insert(
      id: 's1',
      poolIds: jsonEncode(['a', 'b']),
      genderFilter: 'm',
      poolSize: 2,
      createdAt: DateTime(2026),
    ));
  });

  tearDown(() => db.close());

  EloMatchRowsCompanion makeMatch(String idA, String idB, String outcome) =>
      EloMatchRowsCompanion.insert(
        sessionId: 's1',
        nameIdA: idA,
        nameIdB: idB,
        outcome: outcome,
        matchedAt: DateTime.now(),
      );

  test('insertMatch + getMatchesForSession round-trip', () async {
    await db.eloMatchesDao.insertMatch(makeMatch('a', 'b', 'aWins'));
    final matches = await db.eloMatchesDao.getMatchesForSession('s1');
    expect(matches.length, 1);
    expect(matches.first.nameIdA, 'a');
    expect(matches.first.outcome, 'aWins');
  });

  test('getMatchesForSession returns rows in timestamp order', () async {
    await db.eloMatchesDao.insertMatch(EloMatchRowsCompanion.insert(
      sessionId: 's1', nameIdA: 'a', nameIdB: 'b', outcome: 'aWins',
      matchedAt: DateTime(2026, 1, 1, 10, 0, 0),
    ));
    await db.eloMatchesDao.insertMatch(EloMatchRowsCompanion.insert(
      sessionId: 's1', nameIdA: 'b', nameIdB: 'a', outcome: 'bWins',
      matchedAt: DateTime(2026, 1, 1, 10, 0, 1),
    ));
    final matches = await db.eloMatchesDao.getMatchesForSession('s1');
    expect(matches.first.outcome, 'aWins');
    expect(matches.last.outcome, 'bWins');
  });

  test('deleteLastMatch removes only the most recent row', () async {
    await db.eloMatchesDao.insertMatch(EloMatchRowsCompanion.insert(
      sessionId: 's1', nameIdA: 'a', nameIdB: 'b', outcome: 'aWins',
      matchedAt: DateTime(2026, 1, 1, 10, 0, 0),
    ));
    await db.eloMatchesDao.insertMatch(EloMatchRowsCompanion.insert(
      sessionId: 's1', nameIdA: 'b', nameIdB: 'a', outcome: 'tie',
      matchedAt: DateTime(2026, 1, 1, 10, 0, 1),
    ));
    await db.eloMatchesDao.deleteLastMatch('s1');
    final matches = await db.eloMatchesDao.getMatchesForSession('s1');
    expect(matches.length, 1);
    expect(matches.first.outcome, 'aWins');
  });

  test('deleteLastMatch on empty session is a no-op', () async {
    await db.eloMatchesDao.deleteLastMatch('s1'); // should not throw
    expect(await db.eloMatchesDao.getMatchesForSession('s1'), isEmpty);
  });

  test('getMatchCountForSession excludes skips', () async {
    await db.eloMatchesDao.insertMatch(makeMatch('a', 'b', 'aWins'));
    await db.eloMatchesDao.insertMatch(makeMatch('a', 'b', 'skip'));
    expect(await db.eloMatchesDao.getNonSkipMatchCount('s1'), 1);
  });
}
