import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/services/database/database.dart';
import 'package:lilt/domain/models/ranking.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/session_repository.dart';

Future<void> _seedNames(AppDatabase db, List<String> ids) async {
  await db.namesDao.insertNames(ids
      .map((id) => NameEntriesCompanion.insert(
            id: id,
            display: id.split('-').first,
            gender: id.split('-').last,
            variants: '[]',
          ))
      .toList());
}

void main() {
  late AppDatabase db;
  late NamesRepository namesRepo;
  late SessionRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    namesRepo = NamesRepository(db.namesDao);
    repo = SessionRepository(db.sessionDao, db.eloMatchesDao, namesRepo);
    await _seedNames(db, ['eliot-m', 'james-m', 'henry-m']);
  });

  tearDown(() => db.close());

  // lilt:design-of-everyday-things-01 — the couple pairing used to live only
  // in a URL parameter and a timestamp guess. It is now a persisted fact.
  test('createPartnerSession copies the pool and links both sessions',
      () async {
    final a = await repo.createSession(
      participantLabel: 'Partner A',
      poolIds: ['eliot-m', 'james-m', 'henry-m'],
      genderFilter: 'm',
      poolSize: 3,
    );
    final b = await repo.createPartnerSession(a.id);

    expect(b.participantLabel, 'Partner B');
    expect(b.poolIds, a.poolIds);
    expect(b.genderFilter, 'm');
    expect(b.poolSize, 3);
    expect(b.partnerSessionId, a.id);
    expect((await repo.getSession(a.id))!.partnerSessionId, b.id);
  });

  test('createPartnerSession throws for an unknown Partner A', () async {
    expect(() => repo.createPartnerSession('missing'), throwsStateError);
  });

  test('createSession persists and returns a NameSession', () async {
    final session = await repo.createSession(
      poolIds: ['eliot-m', 'james-m'],
      genderFilter: 'm',
      poolSize: 2,
    );
    expect(session.id, isNotEmpty);
    expect(session.poolIds, ['eliot-m', 'james-m']);
    expect(session.isComplete, isFalse);
    expect(session.resultsLocked, isTrue);
  });

  test('buildEngine starts with no history and correct items', () async {
    final session = await repo.createSession(
      poolIds: ['eliot-m', 'james-m'],
      genderFilter: 'm',
      poolSize: 2,
    );
    final engine = await repo.buildEngine(session.id);
    expect(engine.rankings.map((i) => i.id).toSet(), {'eliot-m', 'james-m'});
    expect(engine.isConverged, isFalse);
  });

  test('recordMatch persists and engine reflects the outcome', () async {
    final session = await repo.createSession(
      poolIds: ['eliot-m', 'james-m'],
      genderFilter: 'm',
      poolSize: 2,
    );
    await repo.recordMatch(
      sessionId: session.id,
      idA: 'eliot-m',
      idB: 'james-m',
      outcome: ComparisonOutcome.aWins,
    );
    final ranking = await repo.ranking(session.id);
    expect(ranking.ranked.first.id, 'eliot-m');
    expect(ranking.rankOf('james-m'), 2);
  });

  test('undoLastMatch removes the most recent match', () async {
    final session = await repo.createSession(
      poolIds: ['eliot-m', 'james-m'],
      genderFilter: 'm',
      poolSize: 2,
    );
    await repo.recordMatch(
      sessionId: session.id,
      idA: 'eliot-m',
      idB: 'james-m',
      outcome: ComparisonOutcome.aWins,
    );
    await repo.undoLastMatch(session.id);
    final ranking = await repo.ranking(session.id);
    expect(ranking.ranked.first.rating, 1200.0);
    expect(ranking.ranked.last.rating, 1200.0);
  });

  test('markComplete flips isComplete on the session row', () async {
    final session = await repo.createSession(
      poolIds: ['eliot-m', 'james-m'],
      genderFilter: 'm',
      poolSize: 2,
    );
    await repo.markComplete(session.id);
    final updated = await repo.getSession(session.id);
    expect(updated!.isComplete, isTrue);
  });

  test('getNonSkipMatchCount excludes skips', () async {
    final session = await repo.createSession(
      poolIds: ['eliot-m', 'james-m', 'henry-m'],
      genderFilter: 'm',
      poolSize: 3,
    );
    await repo.recordMatch(
        sessionId: session.id,
        idA: 'eliot-m', idB: 'james-m',
        outcome: ComparisonOutcome.aWins);
    await repo.recordMatch(
        sessionId: session.id,
        idA: 'eliot-m', idB: 'henry-m',
        outcome: ComparisonOutcome.skip);
    expect(await repo.getNonSkipMatchCount(session.id), 1);
  });

  // Clear sessions is a deliberate delete: no dialog, a soft delete, and a
  // lasting Recently cleared list (fleet delete ruling). It covers sessions
  // in progress too, so an abandoned couple can always be cleared.
  group('soft delete', () {
    Future<List<String>> seedThree() async {
      final done = await repo.createSession(
          poolIds: ['eliot-m', 'james-m'], genderFilter: 'm', poolSize: 2);
      await repo.recordMatch(
          sessionId: done.id,
          idA: 'eliot-m',
          idB: 'james-m',
          outcome: ComparisonOutcome.aWins);
      await repo.markComplete(done.id);
      final a = await repo.createSession(
          participantLabel: 'Partner A',
          poolIds: ['eliot-m', 'henry-m'],
          genderFilter: 'm',
          poolSize: 2);
      final b = await repo.createPartnerSession(a.id);
      return [done.id, a.id, b.id];
    }

    test('clearAllSessions hides every session, finished or not', () async {
      final ids = await seedThree();
      final cleared = await repo.clearAllSessions();
      expect(cleared.toSet(), ids.toSet());
      expect(await repo.getAllSessions(), isEmpty);
      for (final id in ids) {
        expect(await repo.getSession(id), isNull,
            reason: 'a cleared session is gone to every screen and guard');
      }
      expect((await repo.clearedSessions()).map((s) => s.id).toSet(),
          ids.toSet());
    });

    test('restoreSessions brings sessions back with their history',
        () async {
      final ids = await seedThree();
      await repo.clearAllSessions();
      await repo.restoreSessions(ids);
      expect((await repo.getAllSessions()).map((s) => s.id).toSet(),
          ids.toSet());
      expect(await repo.clearedSessions(), isEmpty);
      final engine = await repo.buildEngine(ids.first);
      expect(engine.history, hasLength(1));
    });

    test('deleteForever removes only cleared sessions, with their matches',
        () async {
      final ids = await seedThree();
      await repo.clearAllSessions();
      final keep = await repo.createSession(
          poolIds: ['eliot-m', 'james-m'], genderFilter: 'm', poolSize: 2);
      await repo.deleteClearedForever();
      expect(await repo.clearedSessions(), isEmpty);
      expect((await repo.getAllSessions()).single.id, keep.id);
      expect(await db.eloMatchesDao.getMatchesForSession(ids.first),
          isEmpty);
    });
  });

  // The bar on Your Rankings is drawn from winChance, so it must be a true
  // proportion: ties sit at half, and a clear order spreads around it.
  group('ranking', () {
    test('an untouched pool puts every name at an even chance', () async {
      final session = await repo.createSession(
          poolIds: ['eliot-m', 'james-m', 'henry-m'],
          genderFilter: 'm',
          poolSize: 3);
      final r = await repo.ranking(session.id);
      expect(r.ranked.map((n) => n.winChance), everyElement(closeTo(0.5, 1e-9)));
      expect(r.next, isNotNull);
    });

    test('a winner is above even and a loser below, in order', () async {
      final session = await repo.createSession(
          poolIds: ['eliot-m', 'james-m', 'henry-m'],
          genderFilter: 'm',
          poolSize: 3);
      for (final (a, b) in [
        ('eliot-m', 'james-m'),
        ('eliot-m', 'henry-m'),
        ('james-m', 'henry-m'),
      ]) {
        await repo.recordMatch(
            sessionId: session.id,
            idA: a,
            idB: b,
            outcome: ComparisonOutcome.aWins);
      }
      final r = await repo.ranking(session.id);
      expect(r.ranked.map((n) => n.id), ['eliot-m', 'james-m', 'henry-m']);
      expect(r.ranked.first.winChance, greaterThan(0.5));
      expect(r.ranked.last.winChance, lessThan(0.5));
      expect(r.ranked.last.winChance, greaterThan(0),
          reason: 'last place is not drawn as zero');
    });
  });

  test('methodology names each disagreement by method name', () async {
    final session = await repo.createSession(
        poolIds: ['eliot-m', 'james-m', 'henry-m'],
        genderFilter: 'm',
        poolSize: 3);
    await repo.recordMatch(
        sessionId: session.id,
        idA: 'eliot-m',
        idB: 'james-m',
        outcome: ComparisonOutcome.aWins);
    final m = await repo.methodology(session.id);
    expect(m.kendallTau, inInclusiveRange(-1, 1));
    for (final d in m.disagreements) {
      expect(d.rankByMethod.keys, everyElement(isNot(contains('AlgorithmId'))));
    }
  });
}
