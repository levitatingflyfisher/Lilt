import 'package:drift/drift.dart';
import '../database.dart';

part 'elo_matches_dao.g.dart';

@DriftAccessor(tables: [EloMatchRows])
class EloMatchesDao extends DatabaseAccessor<AppDatabase>
    with _$EloMatchesDaoMixin {
  EloMatchesDao(super.db);

  Future<List<EloMatchRow>> getMatchesForSession(String sessionId) =>
      (select(eloMatchRows)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<void> insertMatch(EloMatchRowsCompanion match) =>
      into(eloMatchRows).insert(match);

  Future<void> deleteLastMatch(String sessionId) async {
    final last = await (select(eloMatchRows)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    if (last != null) {
      await (delete(eloMatchRows)..where((t) => t.id.equals(last.id))).go();
    }
  }

  Future<int> getNonSkipMatchCount(String sessionId) async {
    final countExpr = eloMatchRows.id.count();
    final query = selectOnly(eloMatchRows)
      ..addColumns([countExpr])
      ..where(eloMatchRows.sessionId.equals(sessionId) &
          eloMatchRows.outcome.isNotIn(['skip']));
    return (await query.map((r) => r.read(countExpr)!).getSingle());
  }
}
