import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/services/database/database.dart';
import 'package:lilt/domain/models/name.dart';
import 'package:lilt/domain/repositories/names_repository.dart';

Future<void> _seed(AppDatabase db) async {
  await db.namesDao.insertNames([
    NameEntriesCompanion.insert(
        id: 'eliot-m', display: 'Eliot', gender: 'm',
        variants: jsonEncode(['Elliott'])),
    NameEntriesCompanion.insert(
        id: 'james-m', display: 'James', gender: 'm', variants: '[]'),
    NameEntriesCompanion.insert(
        id: 'clara-f', display: 'Clara', gender: 'f', variants: '[]'),
    NameEntriesCompanion.insert(
        id: 'sage-n', display: 'Sage', gender: 'n', variants: '[]'),
  ]);
}

void main() {
  late AppDatabase db;
  late NamesRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = NamesRepository(db.namesDao);
  });

  tearDown(() => db.close());

  test('getAll returns all seeded names', () async {
    await _seed(db);
    final names = await repo.getAll();
    expect(names.length, 4);
  });

  test('getForFilter(male) returns only male names', () async {
    await _seed(db);
    final names = await repo.getForFilter(gender: NameGender.male);
    expect(names.every((n) => n.gender == NameGender.male), isTrue);
    expect(names.length, 2);
  });

  test('getForFilter(null) returns all', () async {
    await _seed(db);
    final names = await repo.getForFilter();
    expect(names.length, 4);
  });

  test('getByIds returns only requested names', () async {
    await _seed(db);
    final names = await repo.getByIds(['eliot-m', 'sage-n']);
    expect(names.map((n) => n.id).toSet(), {'eliot-m', 'sage-n'});
  });

  test('variants are decoded from JSON', () async {
    await _seed(db);
    final names = await repo.getByIds(['eliot-m']);
    expect(names.first.variants, ['Elliott']);
  });

  test('addCustomName appears in getAll', () async {
    await repo.addCustomName(const Name(
      id: 'zephyr-m', display: 'Zephyr', gender: NameGender.male,
      isCustom: true,
    ));
    final names = await repo.getAll();
    expect(names.any((n) => n.id == 'zephyr-m' && n.isCustom), isTrue);
  });

  test('isLoaded returns false on empty db', () async {
    expect(await repo.isLoaded(), isFalse);
  });

  test('isLoaded returns true after seed', () async {
    await _seed(db);
    expect(await repo.isLoaded(), isTrue);
  });
}
