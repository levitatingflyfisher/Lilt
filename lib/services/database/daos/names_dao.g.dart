// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'names_dao.dart';

// ignore_for_file: type=lint
mixin _$NamesDaoMixin on DatabaseAccessor<AppDatabase> {
  $NameEntriesTable get nameEntries => attachedDatabase.nameEntries;
  NamesDaoManager get managers => NamesDaoManager(this);
}

class NamesDaoManager {
  final _$NamesDaoMixin _db;
  NamesDaoManager(this._db);
  $$NameEntriesTableTableManager get nameEntries =>
      $$NameEntriesTableTableManager(_db.attachedDatabase, _db.nameEntries);
}
