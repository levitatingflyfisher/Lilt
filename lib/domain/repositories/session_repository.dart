import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:elo_engine/elo_engine.dart';
import 'package:uuid/uuid.dart';
import 'package:lilt/services/database/daos/session_dao.dart';
import 'package:lilt/services/database/daos/elo_matches_dao.dart';
import 'package:lilt/services/database/database.dart'
    show SessionsCompanion, EloMatchRowsCompanion, SessionRow;
import '../models/name_session.dart';
import 'names_repository.dart';

class SessionRepository {
  final SessionDao _sessionDao;
  final EloMatchesDao _matchesDao;
  final NamesRepository _namesRepo;
  final _uuid = const Uuid();

  SessionRepository(this._sessionDao, this._matchesDao, this._namesRepo);

  Future<NameSession> createSession({
    String? participantLabel,
    required List<String> poolIds,
    required String genderFilter,
    required int poolSize,
  }) async {
    final id = _uuid.v4();
    await _sessionDao.insertSession(SessionsCompanion.insert(
      id: id,
      participantLabel: Value(participantLabel),
      poolIds: jsonEncode(poolIds),
      genderFilter: genderFilter,
      poolSize: poolSize,
      createdAt: DateTime.now(),
    ));
    return (await getSession(id))!;
  }

  Future<NameSession?> getSession(String id) async {
    final row = await _sessionDao.getSession(id);
    return row == null ? null : _toModel(row);
  }

  Future<List<NameSession>> getAllSessions() async {
    final rows = await _sessionDao.getAllSessions();
    return rows.map(_toModel).toList();
  }

  /// Constructs an EloEngine from the persisted match history for [sessionId].
  /// Ratings are never stored — always replayed from normalized match rows.
  Future<EloEngine> buildEngine(String sessionId,
      {double convergenceTau = 0.90}) async {
    final row = await _sessionDao.getSession(sessionId);
    if (row == null) throw StateError('Session $sessionId not found');

    final poolIds = (jsonDecode(row.poolIds) as List).cast<String>();
    final names = await _namesRepo.getByIds(poolIds);
    final matchRows = await _matchesDao.getMatchesForSession(sessionId);

    final items = names.map((n) => EloItem(id: n.id)).toList();
    final history = matchRows
        .map((m) => EloMatch(
              idA: m.nameIdA,
              idB: m.nameIdB,
              outcome: MatchOutcome.values.byName(m.outcome),
              timestamp: m.matchedAt,
            ))
        .toList();

    return EloEngine(
      items: items,
      history: history,
      config: EloConfig(convergenceTau: convergenceTau),
    );
  }

  /// Records a match, persists it, and returns the updated engine.
  Future<EloEngine> recordMatch({
    required String sessionId,
    required String idA,
    required String idB,
    required MatchOutcome outcome,
  }) async {
    await _matchesDao.insertMatch(EloMatchRowsCompanion.insert(
      sessionId: sessionId,
      nameIdA: idA,
      nameIdB: idB,
      outcome: outcome.name,
      matchedAt: DateTime.now(),
    ));
    return buildEngine(sessionId);
  }

  /// Removes the last recorded match and returns the rebuilt engine.
  Future<EloEngine> undoLastMatch(String sessionId) async {
    await _matchesDao.deleteLastMatch(sessionId);
    return buildEngine(sessionId);
  }

  Future<void> markComplete(String sessionId) =>
      _sessionDao.markComplete(sessionId);

  Future<void> deleteSession(String sessionId) =>
      _sessionDao.deleteSession(sessionId);

  Future<int> getNonSkipMatchCount(String sessionId) =>
      _matchesDao.getNonSkipMatchCount(sessionId);

  NameSession _toModel(SessionRow row) => NameSession(
        id: row.id,
        participantLabel: row.participantLabel,
        poolIds: (jsonDecode(row.poolIds) as List).cast<String>(),
        genderFilter: row.genderFilter,
        poolSize: row.poolSize,
        isComplete: row.isComplete,
        resultsLocked: row.resultsLocked,
        createdAt: row.createdAt,
        completedAt: row.completedAt,
      );
}
