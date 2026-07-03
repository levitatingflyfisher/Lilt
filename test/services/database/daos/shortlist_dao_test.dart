import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/services/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.namesDao.insertNames([
      NameEntriesCompanion.insert(
          id: 'eliot-m', display: 'Eliot', gender: 'm', variants: '[]'),
    ]);
  });

  tearDown(() => db.close());

  test('add + getAll round-trip', () async {
    await db.shortlistDao.add(ShortlistEntriesCompanion.insert(
      id: 'entry-1',
      nameId: 'eliot-m',
      addedAt: DateTime(2026),
    ));
    final all = await db.shortlistDao.getAll();
    expect(all.length, 1);
    expect(all.first.nameId, 'eliot-m');
    expect(all.first.note, isNull);
  });

  test('isInShortlist returns false when absent', () async {
    expect(await db.shortlistDao.isInShortlist('eliot-m'), isFalse);
  });

  test('isInShortlist returns true when present', () async {
    await db.shortlistDao.add(ShortlistEntriesCompanion.insert(
      id: 'entry-1', nameId: 'eliot-m', addedAt: DateTime(2026),
    ));
    expect(await db.shortlistDao.isInShortlist('eliot-m'), isTrue);
  });

  test('isInShortlist is robust to duplicate rows (double-tap)', () async {
    // A double-tap can insert two rows for the same name; isInShortlist must
    // not crash (getSingleOrNull throws on >1 row).
    await db.shortlistDao.add(ShortlistEntriesCompanion.insert(
      id: 'e1', nameId: 'eliot-m', addedAt: DateTime(2026),
    ));
    await db.shortlistDao.add(ShortlistEntriesCompanion.insert(
      id: 'e2', nameId: 'eliot-m', addedAt: DateTime(2026),
    ));
    expect(await db.shortlistDao.isInShortlist('eliot-m'), isTrue,
        reason: 'duplicate rows must be tolerated, not crash');
  });

  test('updateNote sets note on existing entry', () async {
    await db.shortlistDao.add(ShortlistEntriesCompanion.insert(
      id: 'entry-1', nameId: 'eliot-m', addedAt: DateTime(2026),
    ));
    await db.shortlistDao.updateNote('entry-1', 'Dad loves this one');
    final all = await db.shortlistDao.getAll();
    expect(all.first.note, 'Dad loves this one');
  });

  test('remove deletes the entry', () async {
    await db.shortlistDao.add(ShortlistEntriesCompanion.insert(
      id: 'entry-1', nameId: 'eliot-m', addedAt: DateTime(2026),
    ));
    await db.shortlistDao.remove('entry-1');
    expect(await db.shortlistDao.getAll(), isEmpty);
  });
}
