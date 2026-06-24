import 'package:drift/drift.dart';
import '../database.dart';

part 'shortlist_dao.g.dart';

@DriftAccessor(tables: [ShortlistEntries])
class ShortlistDao extends DatabaseAccessor<AppDatabase>
    with _$ShortlistDaoMixin {
  ShortlistDao(super.db);

  Future<List<ShortlistEntryRow>> getAll() =>
      (select(shortlistEntries)
            ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
          .get();

  Future<bool> isInShortlist(String nameId) async {
    final row = await (select(shortlistEntries)
          ..where((t) => t.nameId.equals(nameId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> add(ShortlistEntriesCompanion entry) =>
      into(shortlistEntries).insert(entry);

  Future<void> updateNote(String id, String? note) =>
      (update(shortlistEntries)..where((t) => t.id.equals(id)))
          .write(ShortlistEntriesCompanion(note: Value(note)));

  Future<void> remove(String id) =>
      (delete(shortlistEntries)..where((t) => t.id.equals(id))).go();
}
