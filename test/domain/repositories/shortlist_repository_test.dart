import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/services/database/database.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/shortlist_repository.dart';

void main() {
  late AppDatabase db;
  late ShortlistRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.namesDao.insertNames([
      NameEntriesCompanion.insert(
          id: 'eliot-m', display: 'Eliot', gender: 'm', variants: '[]'),
      NameEntriesCompanion.insert(
          id: 'clara-f', display: 'Clara', gender: 'f', variants: '[]'),
    ]);
    repo = ShortlistRepository(db.shortlistDao, NamesRepository(db.namesDao));
  });

  tearDown(() => db.close());

  test('add + getAll returns entries with hydrated Name', () async {
    await repo.add('eliot-m');
    final entries = await repo.getAll();
    expect(entries.length, 1);
    expect(entries.first.name.display, 'Eliot');
    expect(entries.first.note, isNull);
  });

  test('isInShortlist false when absent', () async {
    expect(await repo.isInShortlist('eliot-m'), isFalse);
  });

  test('isInShortlist true after add', () async {
    await repo.add('eliot-m');
    expect(await repo.isInShortlist('eliot-m'), isTrue);
  });

  test('updateNote persists note', () async {
    await repo.add('eliot-m');
    final id = (await repo.getAll()).first.id;
    await repo.updateNote(id, 'Top pick');
    expect((await repo.getAll()).first.note, 'Top pick');
  });

  test('remove deletes entry', () async {
    await repo.add('eliot-m');
    final id = (await repo.getAll()).first.id;
    await repo.remove(id);
    expect(await repo.getAll(), isEmpty);
  });
}
