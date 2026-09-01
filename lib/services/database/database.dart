import 'package:drift/drift.dart';

import 'tables.dart';
import 'daos/names_dao.dart';
import 'daos/session_dao.dart';
import 'daos/elo_matches_dao.dart';
import 'daos/shortlist_dao.dart';
import 'connection/connection.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [NameEntries, Sessions, EloMatchRows, ShortlistEntries],
  daos: [NamesDao, SessionDao, EloMatchesDao, ShortlistDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Constructor for in-memory test databases.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        // SQLite enforces the declared links (matches -> sessions ON DELETE
        // CASCADE, shortlist -> names) only when asked, per connection.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onUpgrade: (m, from, to) async {
          // v2: persisted couple pairing (was a URL parameter + a guess).
          if (from < 2) {
            await m.addColumn(sessions, sessions.partnerSessionId);
          }
          // v3: soft delete for Clear all sessions.
          if (from < 3) {
            await m.addColumn(sessions, sessions.deletedAt);
          }
        },
      );
}
