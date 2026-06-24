import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:lilt/services/database/daos/names_dao.dart';
import 'package:lilt/services/database/database.dart' show NameEntriesCompanion, NameEntryRow;
import '../models/name.dart';

class NamesRepository {
  final NamesDao _dao;

  const NamesRepository(this._dao);

  /// Returns true if the name table has been populated.
  Future<bool> isLoaded() async => (await _dao.countNames()) > 0;

  /// Loads names from the bundled JSON asset into SQLite on first launch.
  /// Safe to call repeatedly — uses insertOrIgnore, no-op if already loaded.
  Future<void> ensureLoaded() async {
    if (await isLoaded()) return;
    final jsonStr = await rootBundle.loadString('assets/data/names.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final list = (data['names'] as List).cast<Map<String, dynamic>>();
    final companions = list
        .map((n) => NameEntriesCompanion.insert(
              id: n['id'] as String,
              display: n['display'] as String,
              gender: n['gender'] as String,
              variants: jsonEncode(n['variants'] ?? <dynamic>[]),
            ))
        .toList();
    await _dao.insertNames(companions);
  }

  Future<List<Name>> getAll() async {
    final rows = await _dao.getAllNames();
    return rows.map(_toModel).toList();
  }

  /// Returns names filtered by [gender]. If null, returns all genders.
  Future<List<Name>> getForFilter({NameGender? gender}) async {
    final rows = gender == null
        ? await _dao.getAllNames()
        : await _dao.getNamesByGender(Name.genderToCode(gender));
    return rows.map(_toModel).toList();
  }

  Future<List<Name>> getByIds(List<String> ids) async {
    final rows = await _dao.getNamesByIds(ids);
    return rows.map(_toModel).toList();
  }

  Future<void> addCustomName(Name name) => _dao.insertCustomName(
        NameEntriesCompanion.insert(
          id: name.id,
          display: name.display,
          gender: Name.genderToCode(name.gender),
          variants: jsonEncode(name.variants),
          isCustom: const Value(true),
        ),
      );

  Name _toModel(NameEntryRow row) => Name(
        id: row.id,
        display: row.display,
        gender: Name.genderFromCode(row.gender),
        variants:
            (jsonDecode(row.variants) as List).cast<String>(),
        isCustom: row.isCustom,
      );
}
