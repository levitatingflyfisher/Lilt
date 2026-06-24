import 'package:drift/native.dart';
import 'package:elo_engine/elo_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/session_repository.dart';
import 'package:lilt/features/matchup/matchup_notifier.dart';
import 'package:lilt/services/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

late AppDatabase _db;
late ProviderContainer _container;
late String _sessionId;

Future<ProviderContainer> _buildContainer() async {
  _db = AppDatabase.forTesting(NativeDatabase.memory());

  // Seed names
  await _db.namesDao.insertNames([
    NameEntriesCompanion.insert(
        id: 'a-m', display: 'Alpha', gender: 'm', variants: '[]'),
    NameEntriesCompanion.insert(
        id: 'b-m', display: 'Beta', gender: 'm', variants: '[]'),
    NameEntriesCompanion.insert(
        id: 'c-m', display: 'Charlie', gender: 'm', variants: '[]'),
  ]);

  // Create a session
  final namesRepo = NamesRepository(_db.namesDao);
  final sessionRepo =
      SessionRepository(_db.sessionDao, _db.eloMatchesDao, namesRepo);
  final session = await sessionRepo.createSession(
    poolIds: ['a-m', 'b-m', 'c-m'],
    genderFilter: 'm',
    poolSize: 3,
  );
  _sessionId = session.id;

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(_db),
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  return container;
}

void main() {
  setUp(() async {
    _container = await _buildContainer();
  });

  tearDown(() async {
    _container.dispose();
    await _db.close();
  });

  test('initial state has a next match proposal', () async {
    final state = await _container.read(matchupProvider(_sessionId).future);
    expect(state.nextMatch, isNotNull);
    expect(state.isConverged, isFalse);
    expect(state.matchCount, 0);
  });

  test('initial state carries idToDisplay map', () async {
    final state = await _container.read(matchupProvider(_sessionId).future);
    expect(state.idToDisplay['a-m'], 'Alpha');
    expect(state.idToDisplay['b-m'], 'Beta');
    expect(state.idToDisplay['c-m'], 'Charlie');
  });

  test('record updates match count and returns a new proposal', () async {
    await _container.read(matchupProvider(_sessionId).future);
    final notifier =
        _container.read(matchupProvider(_sessionId).notifier);
    final initial =
        await _container.read(matchupProvider(_sessionId).future);
    final proposal = initial.nextMatch!;

    await notifier.record(
        proposal.itemA.id, proposal.itemB.id, MatchOutcome.aWins);

    final updated =
        await _container.read(matchupProvider(_sessionId).future);
    expect(updated.matchCount, 1);
  });

  test('undo decrements match count', () async {
    await _container.read(matchupProvider(_sessionId).future);
    final notifier =
        _container.read(matchupProvider(_sessionId).notifier);
    final initial =
        await _container.read(matchupProvider(_sessionId).future);
    final proposal = initial.nextMatch!;

    await notifier.record(
        proposal.itemA.id, proposal.itemB.id, MatchOutcome.aWins);
    await notifier.undo();

    final reverted =
        await _container.read(matchupProvider(_sessionId).future);
    expect(reverted.matchCount, 0);
  });
}
