import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'daos/names_dao.dart';
import 'daos/session_dao.dart';
import 'daos/elo_matches_dao.dart';
import 'daos/shortlist_dao.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [NameEntries, Sessions, EloMatchRows, ShortlistEntries],
  daos: [NamesDao, SessionDao, EloMatchesDao, ShortlistDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for in-memory test databases.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lilt.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
