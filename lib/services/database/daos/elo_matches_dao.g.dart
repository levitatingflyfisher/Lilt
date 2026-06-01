// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elo_matches_dao.dart';

// ignore_for_file: type=lint
mixin _$EloMatchesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SessionsTable get sessions => attachedDatabase.sessions;
  $EloMatchRowsTable get eloMatchRows => attachedDatabase.eloMatchRows;
  EloMatchesDaoManager get managers => EloMatchesDaoManager(this);
}

class EloMatchesDaoManager {
  final _$EloMatchesDaoMixin _db;
  EloMatchesDaoManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
  $$EloMatchRowsTableTableManager get eloMatchRows =>
      $$EloMatchRowsTableTableManager(_db.attachedDatabase, _db.eloMatchRows);
}
