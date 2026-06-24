import 'package:drift/drift.dart';
import '../database.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  Future<SessionRow?> getSession(String id) =>
      (select(sessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<SessionRow>> getAllSessions() => select(sessions).get();

  Future<void> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session);

  Future<void> markComplete(String id) =>
      (update(sessions)..where((t) => t.id.equals(id))).write(
        SessionsCompanion(
          isComplete: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );

  Future<void> deleteSession(String id) =>
      (delete(sessions)..where((t) => t.id.equals(id))).go();
}
