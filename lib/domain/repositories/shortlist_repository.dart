import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:lilt/services/database/daos/shortlist_dao.dart';
import 'package:lilt/services/database/database.dart' show ShortlistEntriesCompanion;
import '../models/shortlist_entry.dart';
import 'names_repository.dart';

class ShortlistRepository {
  final ShortlistDao _dao;
  final NamesRepository _namesRepo;
  final _uuid = const Uuid();

  ShortlistRepository(this._dao, this._namesRepo);

  Future<List<ShortlistEntry>> getAll() async {
    final rows = await _dao.getAll();
    final nameIds = rows.map((r) => r.nameId).toList();
    if (nameIds.isEmpty) return [];
    final names = await _namesRepo.getByIds(nameIds);
    final nameMap = {for (final n in names) n.id: n};
    return rows
        .where((r) => nameMap.containsKey(r.nameId))
        .map((r) => ShortlistEntry(
              id: r.id,
              name: nameMap[r.nameId]!,
              note: r.note,
              addedAt: r.addedAt,
            ))
        .toList();
  }

  Future<bool> isInShortlist(String nameId) => _dao.isInShortlist(nameId);

  Future<void> add(String nameId, {String? note}) => _dao.add(
        ShortlistEntriesCompanion.insert(
          id: _uuid.v4(),
          nameId: nameId,
          note: Value(note),
          addedAt: DateTime.now(),
        ),
      );

  Future<void> updateNote(String id, String? note) =>
      _dao.updateNote(id, note);

  Future<void> remove(String id) => _dao.remove(id);
}
