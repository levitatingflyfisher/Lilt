// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortlist_dao.dart';

// ignore_for_file: type=lint
mixin _$ShortlistDaoMixin on DatabaseAccessor<AppDatabase> {
  $NameEntriesTable get nameEntries => attachedDatabase.nameEntries;
  $ShortlistEntriesTable get shortlistEntries =>
      attachedDatabase.shortlistEntries;
  ShortlistDaoManager get managers => ShortlistDaoManager(this);
}

class ShortlistDaoManager {
  final _$ShortlistDaoMixin _db;
  ShortlistDaoManager(this._db);
  $$NameEntriesTableTableManager get nameEntries =>
      $$NameEntriesTableTableManager(_db.attachedDatabase, _db.nameEntries);
  $$ShortlistEntriesTableTableManager get shortlistEntries =>
      $$ShortlistEntriesTableTableManager(
        _db.attachedDatabase,
        _db.shortlistEntries,
      );
}
