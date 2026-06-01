import 'package:drift/drift.dart';
import '../database.dart';

part 'names_dao.g.dart';

@DriftAccessor(tables: [NameEntries])
class NamesDao extends DatabaseAccessor<AppDatabase> with _$NamesDaoMixin {
  NamesDao(super.db);

  Future<int> countNames() async {
    final countExpr = nameEntries.id.count();
    final query = selectOnly(nameEntries)..addColumns([countExpr]);
    return (await query.map((r) => r.read(countExpr)!).getSingle());
  }

  Future<List<NameEntryRow>> getAllNames() => select(nameEntries).get();

  Future<List<NameEntryRow>> getNamesByGender(String gender) =>
      (select(nameEntries)..where((t) => t.gender.equals(gender))).get();

  Future<List<NameEntryRow>> getNamesByIds(List<String> ids) =>
      (select(nameEntries)..where((t) => t.id.isIn(ids))).get();

  Future<void> insertNames(List<NameEntriesCompanion> names) =>
      batch((b) => b.insertAll(nameEntries, names,
          mode: InsertMode.insertOrIgnore));

  Future<void> insertCustomName(NameEntriesCompanion name) =>
      into(nameEntries).insert(name);
}
