import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:lilt/services/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('countNames returns 0 on empty database', () async {
    expect(await db.namesDao.countNames(), 0);
  });

  test('insertNames bulk-inserts and countNames returns correct total', () async {
    await db.namesDao.insertNames([
      NameEntriesCompanion.insert(
          id: 'eliot-m', display: 'Eliot', gender: 'm', variants: '[]'),
      NameEntriesCompanion.insert(
          id: 'clara-f', display: 'Clara', gender: 'f', variants: '[]'),
    ]);
    expect(await db.namesDao.countNames(), 2);
  });

  test('insertNames is idempotent (insertOrIgnore)', () async {
    final companion = NameEntriesCompanion.insert(
        id: 'eliot-m', display: 'Eliot', gender: 'm', variants: '[]');
    await db.namesDao.insertNames([companion]);
    await db.namesDao.insertNames([companion]); // duplicate
    expect(await db.namesDao.countNames(), 1);
  });

  test('getNamesByGender returns only matching gender', () async {
    await db.namesDao.insertNames([
      NameEntriesCompanion.insert(
          id: 'eliot-m', display: 'Eliot', gender: 'm', variants: '[]'),
      NameEntriesCompanion.insert(
          id: 'clara-f', display: 'Clara', gender: 'f', variants: '[]'),
    ]);
    final males = await db.namesDao.getNamesByGender('m');
    expect(males.length, 1);
    expect(males.first.id, 'eliot-m');
  });

  test('getNamesByIds returns only requested IDs', () async {
    await db.namesDao.insertNames([
      NameEntriesCompanion.insert(
          id: 'eliot-m', display: 'Eliot', gender: 'm', variants: '[]'),
      NameEntriesCompanion.insert(
          id: 'clara-f', display: 'Clara', gender: 'f', variants: '[]'),
      NameEntriesCompanion.insert(
          id: 'james-m', display: 'James', gender: 'm', variants: '[]'),
    ]);
    final result = await db.namesDao.getNamesByIds(['eliot-m', 'james-m']);
    expect(result.map((r) => r.id).toSet(), {'eliot-m', 'james-m'});
  });

  test('insertCustomName inserts with isCustom = true', () async {
    await db.namesDao.insertCustomName(NameEntriesCompanion.insert(
      id: 'zephyr-m',
      display: 'Zephyr',
      gender: 'm',
      variants: '[]',
      isCustom: const Value(true),
    ));
    final all = await db.namesDao.getAllNames();
    expect(all.length, 1);
    expect(all.first.isCustom, isTrue);
  });
}
