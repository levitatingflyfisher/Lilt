import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/session_repository.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'package:lilt/services/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression: the home body Column overflowed ~512px vertically at large
/// accessibility text (textScale 3.0) because the session list + CTAs were a
/// non-scrolling Column. Asserts no layout exception at that worst-case.
Future<(AppDatabase, ProviderContainer)> _seed() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.namesDao.insertNames([
    NameEntriesCompanion.insert(
        id: 'a-m', display: 'Alexander', gender: 'm', variants: '[]'),
  ]);
  final namesRepo = NamesRepository(db.namesDao);
  final sessionRepo =
      SessionRepository(db.sessionDao, db.eloMatchesDao, namesRepo);
  // Two in-progress + one complete to give the body real height.
  await sessionRepo.createSession(
      poolIds: ['a-m'], genderFilter: 'm', poolSize: 60);
  await sessionRepo.createSession(
      poolIds: ['a-m'], genderFilter: 'm', poolSize: 30);
  final done = await sessionRepo.createSession(
      poolIds: ['a-m'], genderFilter: 'm', poolSize: 30);
  await sessionRepo.markComplete(done.id);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  return (db, container);
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    (db, container) = await _seed();
    await container.read(allSessionsProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  testWidgets('home body does not overflow at 320dp / textScale 3.0',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 800);

    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(3.0)),
        child: child!,
      ),
      home: UncontrolledProviderScope(
        container: container,
        child: const HomeScreen(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
