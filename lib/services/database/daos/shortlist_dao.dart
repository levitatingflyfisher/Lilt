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
    // Existence check, not getSingleOrNull() — a double-tap can leave more than
    // one row for a name, and getSingleOrNull throws on >1 row.
    final rows = await (select(shortlistEntries)
          ..where((t) => t.nameId.equals(nameId))
          ..limit(1))
        .get();
    return rows.isNotEmpty;
  }

  Future<void> add(ShortlistEntriesCompanion entry) =>
      into(shortlistEntries).insert(entry);

  Future<void> updateNote(String id, String? note) =>
      (update(shortlistEntries)..where((t) => t.id.equals(id)))
          .write(ShortlistEntriesCompanion(note: Value(note)));

  Future<void> remove(String id) =>
      (delete(shortlistEntries)..where((t) => t.id.equals(id))).go();
}
