import 'package:drift/drift.dart';
import '../database.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  /// A live session by id; a cleared (soft-deleted) one reads as null.
  Future<SessionRow?> getSession(String id) => (select(sessions)
        ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
      .getSingleOrNull();

  /// Every live session; cleared ones are left out.
  Future<List<SessionRow>> getAllSessions() =>
      (select(sessions)..where((t) => t.deletedAt.isNull())).get();

  /// Sessions cleared but not yet deleted forever, most recent first.
  Future<List<SessionRow>> getClearedSessions() => (select(sessions)
        ..where((t) => t.deletedAt.isNotNull())
        ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
      .get();

  /// Soft-deletes every live session in one write; returns their ids.
  Future<List<String>> clearAll(DateTime at) => transaction(() async {
        final live = await getAllSessions();
        await (update(sessions)..where((t) => t.deletedAt.isNull()))
            .write(SessionsCompanion(deletedAt: Value(at)));
        return [for (final s in live) s.id];
      });

  /// Restores [ids] and, with them, the other half of any couple among
  /// them. A couple is live together or cleared together: a cleared partner
  /// reads as deleted, and the /results/solo guard lets a session whose
  /// partner is gone open its results, so restoring Partner A alone would
  /// let Partner B read A's list mid-ranking.
  Future<void> restore(List<String> ids) => transaction(() async {
        final rows = await (select(sessions)
              ..where((t) => t.id.isIn(ids) | t.partnerSessionId.isIn(ids)))
            .get();
        final all = {
          ...ids,
          for (final r in rows) ...[r.id, ?r.partnerSessionId],
        };
        await (update(sessions)..where((t) => t.id.isIn(all))).write(
          const SessionsCompanion(deletedAt: Value(null)),
        );
      });

  /// Hard-deletes cleared sessions only; their comparisons go with them
  /// through the ON DELETE CASCADE (foreign keys are on, see AppDatabase).
  /// A live session can never be deleted forever by this call.
  Future<void> deleteClearedForever() =>
      (delete(sessions)..where((t) => t.deletedAt.isNotNull())).go();

  Future<void> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session);

  /// Inserts [partner] and links it with [partnerOfId] in both directions,
  /// atomically: a half-linked couple never exists.
  Future<void> insertLinkedPartner(
          SessionsCompanion partner, String partnerOfId) =>
      transaction(() async {
        await into(sessions).insert(partner);
        await (update(sessions)..where((t) => t.id.equals(partnerOfId)))
            .write(SessionsCompanion(partnerSessionId: partner.id));
      });

  /// Clears [id]'s side of a couple link only; the partner row is untouched.
  Future<void> clearPartner(String id) =>
      (update(sessions)..where((t) => t.id.equals(id))).write(
        const SessionsCompanion(partnerSessionId: Value(null)),
      );

  Future<void> markComplete(String id) =>
      (update(sessions)..where((t) => t.id.equals(id))).write(
        SessionsCompanion(
          isComplete: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );
}
