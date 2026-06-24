import 'package:drift/native.dart';
import 'package:elo_engine/elo_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/services/database/database.dart';
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
    final engine = await repo.recordMatch(
      sessionId: session.id,
      idA: 'eliot-m',
      idB: 'james-m',
      outcome: MatchOutcome.aWins,
    );
    expect(engine.rankings.first.id, 'eliot-m');
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
      outcome: MatchOutcome.aWins,
    );
    final engine = await repo.undoLastMatch(session.id);
    expect(engine.rankings.first.rating, 1200.0);
    expect(engine.rankings.last.rating, 1200.0);
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
        outcome: MatchOutcome.aWins);
    await repo.recordMatch(
        sessionId: session.id,
        idA: 'eliot-m', idB: 'henry-m',
        outcome: MatchOutcome.skip);
    expect(await repo.getNonSkipMatchCount(session.id), 1);
  });
}
