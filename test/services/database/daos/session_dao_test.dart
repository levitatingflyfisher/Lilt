import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:lilt/services/database/database.dart';

SessionsCompanion _session(String id, {String? label}) =>
    SessionsCompanion.insert(
      id: id,
      participantLabel: Value(label),
      poolIds: jsonEncode(['eliot-m', 'james-m']),
      genderFilter: 'm',
      poolSize: 2,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('insertSession + getSession round-trip', () async {
    await db.sessionDao.insertSession(_session('s1', label: 'Partner A'));
    final row = await db.sessionDao.getSession('s1');
    expect(row, isNotNull);
    expect(row!.participantLabel, 'Partner A');
    expect(row.isComplete, isFalse);
    expect(row.resultsLocked, isTrue);
  });

  test('getSession returns null for unknown id', () async {
    expect(await db.sessionDao.getSession('nope'), isNull);
  });

  test('markComplete sets isComplete and completedAt', () async {
    await db.sessionDao.insertSession(_session('s1'));
    await db.sessionDao.markComplete('s1');
    final row = await db.sessionDao.getSession('s1');
    expect(row!.isComplete, isTrue);
    expect(row.completedAt, isNotNull);
  });

  test('getAllSessions returns all rows', () async {
    await db.sessionDao.insertSession(_session('s1'));
    await db.sessionDao.insertSession(_session('s2'));
    expect((await db.sessionDao.getAllSessions()).length, 2);
  });

  test('deleteSession removes the row', () async {
    await db.sessionDao.insertSession(_session('s1'));
    await db.sessionDao.deleteSession('s1');
    expect(await db.sessionDao.getSession('s1'), isNull);
  });
}
