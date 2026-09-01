import 'dart:convert';
import 'dart:math' as math;
import 'package:drift/drift.dart';
import 'package:elo_engine/elo_engine.dart';
import 'package:uuid/uuid.dart';
import 'package:lilt/services/database/daos/session_dao.dart';
import 'package:lilt/services/database/daos/elo_matches_dao.dart';
import 'package:lilt/services/database/database.dart'
    show SessionsCompanion, EloMatchRowsCompanion, SessionRow;
import '../models/name_session.dart';
import '../models/ranking.dart';
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

  /// Creates Partner B's session over Partner A's exact pool and persists the
  /// pairing on both rows. Throws [StateError] if [partnerAId] is unknown.
  Future<NameSession> createPartnerSession(String partnerAId) async {
    final a = await _sessionDao.getSession(partnerAId);
    if (a == null) throw StateError('Session $partnerAId not found');
    final id = _uuid.v4();
    await _sessionDao.insertLinkedPartner(
      SessionsCompanion.insert(
        id: id,
        participantLabel: const Value('Partner B'),
        poolIds: a.poolIds,
        genderFilter: a.genderFilter,
        poolSize: a.poolSize,
        partnerSessionId: Value(partnerAId),
        createdAt: DateTime.now(),
      ),
      partnerAId,
    );
    return (await getSession(id))!;
  }

  /// Ends [sessionId]'s side of a couple pairing, which unlocks its own
  /// results (the `/results/solo` guard only locks a linked session). The
  /// partner's session, comparisons and link back are kept, so Partner B can
  /// still finish and open the reveal.
  Future<void> endPairing(String sessionId) =>
      _sessionDao.clearPartner(sessionId);

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
  ///
  /// Domain-internal: screens read [ranking] and [methodology] instead, so
  /// the engine's types never reach the UI (VISION invariant 5).
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

  /// The session's ranking, best first, with the next pair to compare.
  Future<SessionRanking> ranking(String sessionId,
      {double convergenceTau = 0.90}) async {
    final engine =
        await buildEngine(sessionId, convergenceTau: convergenceTau);
    final rankings = engine.rankings;
    final mean = rankings.isEmpty
        ? 0.0
        : rankings.map((i) => i.rating).reduce((a, b) => a + b) /
            rankings.length;
    final next = engine.nextMatch();
    return SessionRanking(
      ranked: [
        for (final i in rankings)
          RankedName(
            id: i.id,
            rating: i.rating,
            // Elo expectation against a name of the pool's mean rating.
            winChance:
                1 / (1 + math.pow(10, (mean - i.rating) / 400).toDouble()),
          ),
      ],
      next: next == null ? null : NamePair(next.itemA.id, next.itemB.id),
      isConverged: engine.isConverged,
    );
  }

  /// The ensemble's agreement for "Show methodology".
  Future<Methodology> methodology(String sessionId) async {
    final c = (await buildEngine(sessionId)).compareAlgorithms();
    return Methodology(
      kendallTau: c.interAlgorithmKendallTau,
      rankability: c.serialRank?.rankability,
      preferenceDimensions: c.matrixFactorization?.bestRank,
      cycleStrength: c.hodge?.cyclicMagnitude,
      disagreements: [
        for (final d in c.divergences)
          RankDisagreement(
            nameId: d.item.id,
            rankByMethod: {
              for (final e in d.rankByAlgorithm.entries)
                _methodName(e.key): e.value,
            },
            rankSpread: d.rankSpread,
            invertedAcrossFamilies: _invertedAcrossFamilies(d.rankByAlgorithm),
          ),
      ],
    );
  }

  /// Short display name for a ranking method.
  static String _methodName(AlgorithmId id) => switch (id) {
        AlgorithmId.elo => 'Elo',
        AlgorithmId.glicko2 => 'Glicko-2',
        AlgorithmId.bradleyTerry => 'Bradley-Terry',
        AlgorithmId.trueskill => 'TrueSkill',
        AlgorithmId.thurstone => 'Thurstone',
        AlgorithmId.springRank => 'SpringRank',
        AlgorithmId.pageRank => 'PageRank',
        AlgorithmId.markov => 'Markov',
        AlgorithmId.copeland => 'Copeland',
        AlgorithmId.schulze => 'Schulze',
        AlgorithmId.rankedPairs => 'Ranked Pairs',
        AlgorithmId.borda => 'Borda',
        AlgorithmId.hodge => 'Hodge',
        AlgorithmId.serialRank => 'SerialRank',
        AlgorithmId.matrixFactorization => 'MatrixFact',
      };

  /// Heuristic: did a rating-based method and a pairwise method put this
  /// name at opposite ends?
  static bool _invertedAcrossFamilies(Map<AlgorithmId, int> rankByAlgorithm) {
    if (rankByAlgorithm.length < 3) return false;
    final sorted = rankByAlgorithm.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    const ratingBased = {
      AlgorithmId.elo,
      AlgorithmId.glicko2,
      AlgorithmId.bradleyTerry,
      AlgorithmId.trueskill,
      AlgorithmId.thurstone,
    };
    return ratingBased.contains(sorted.first.key) !=
        ratingBased.contains(sorted.last.key);
  }

  /// Records one comparison. The engine is rebuilt from history on the
  /// next read, never cached.
  Future<void> recordMatch({
    required String sessionId,
    required String idA,
    required String idB,
    required ComparisonOutcome outcome,
  }) async {
    await _matchesDao.insertMatch(EloMatchRowsCompanion.insert(
      sessionId: sessionId,
      nameIdA: idA,
      nameIdB: idB,
      outcome: outcome.name,
      matchedAt: DateTime.now(),
    ));
  }

  /// Removes the last recorded comparison.
  Future<void> undoLastMatch(String sessionId) =>
      _matchesDao.deleteLastMatch(sessionId);

  Future<void> markComplete(String sessionId) =>
      _sessionDao.markComplete(sessionId);

  /// Clears every live session, finished or in progress (a soft delete).
  /// Returns the cleared ids so the caller can offer Undo.
  Future<List<String>> clearAllSessions() =>
      _sessionDao.clearAll(DateTime.now());

  /// Sessions in Recently cleared, most recently cleared first.
  Future<List<NameSession>> clearedSessions() async =>
      (await _sessionDao.getClearedSessions()).map(_toModel).toList();

  Future<void> restoreSessions(List<String> ids) => _sessionDao.restore(ids);

  /// Empties Recently cleared for good, with every cleared comparison.
  Future<void> deleteClearedForever() => _sessionDao.deleteClearedForever();

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
        partnerSessionId: row.partnerSessionId,
      );
}
