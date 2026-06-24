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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
      );
}
