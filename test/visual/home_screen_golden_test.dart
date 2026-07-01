import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/theme.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/session_repository.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'package:lilt/services/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'visual_golden_helper.dart';

/// Full-screen visual golden for the real [HomeScreen].
///
/// Renders the SHIPPED screen — `_HomeBody`'s "In Progress"/"Completed"
/// grouping, the private `_SessionTile`s and `_CompletedCoupleTile`, and the
/// two CTA buttons — against an in-memory Drift DB seeded with a mix of
/// sessions, mirroring `test/features/matchup/matchup_notifier_test.dart`'s
/// override pattern. No private widget is copied, so the golden cannot drift.
///
/// The seed exercises every grouping branch: one in-progress solo session, one
/// completed solo session, and a completed Partner A/B pair (rendered as a
/// single "Couple session" tile).
///
/// `HomeScreen` uses `context.push` only inside tap callbacks, never during
/// build, so a plain `MaterialApp.home` renders without a GoRouter.
Future<(AppDatabase, ProviderContainer)> _seed() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());

  await db.namesDao.insertNames([
    NameEntriesCompanion.insert(
        id: 'a-m', display: 'Alexander', gender: 'm', variants: '[]'),
    NameEntriesCompanion.insert(
        id: 'b-m', display: 'Benjamin', gender: 'm', variants: '[]'),
    NameEntriesCompanion.insert(
        id: 'c-m', display: 'Charlie', gender: 'm', variants: '[]'),
  ]);

  final namesRepo = NamesRepository(db.namesDao);
  final sessionRepo =
      SessionRepository(db.sessionDao, db.eloMatchesDao, namesRepo);
  final pool = ['a-m', 'b-m', 'c-m'];

  // In-progress solo session.
  await sessionRepo.createSession(
      poolIds: pool, genderFilter: 'm', poolSize: 60);

  // Completed solo session.
  final solo = await sessionRepo.createSession(
      poolIds: pool, genderFilter: 'm', poolSize: 30);
  await sessionRepo.markComplete(solo.id);

  // Completed couple pair. Insert with explicit, distinct createdAt so A
  // strictly precedes B — `_HomeBody` only pairs a Partner A created *before*
  // a Partner B, and back-to-back DateTime.now() calls can collide in tests.
  await db.sessionDao.insertSession(SessionsCompanion.insert(
    id: 'partner-a',
    participantLabel: const Value('Partner A'),
    poolIds: '["a-m","b-m","c-m"]',
    genderFilter: 'm',
    poolSize: 120,
    createdAt: DateTime(2026, 1, 1, 10),
  ));
  await db.sessionDao.markComplete('partner-a');
  await db.sessionDao.insertSession(SessionsCompanion.insert(
    id: 'partner-b',
    participantLabel: const Value('Partner B'),
    poolIds: '["a-m","b-m","c-m"]',
    genderFilter: 'm',
    poolSize: 120,
    createdAt: DateTime(2026, 1, 1, 11),
  ));
  await db.sessionDao.markComplete('partner-b');

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  return (db, container);
}

void main() {
  // The real app theme (lib/app/theme.dart) — goldens render the shipped
  // openhearth_design grammar, not a hand-rolled mirror that can drift.
  final theme = LiltTheme.light();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    (db, container) = await _seed();
    // Warm the sessions provider so the first frame shows the populated body.
    await container.read(allSessionsProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  testWidgets('HomeScreen renders across sizes and text scales',
      (tester) async {
    await goldenAtSizes(
      tester,
      name: 'home_screen',
      home: UncontrolledProviderScope(
        container: container,
        child: const HomeScreen(),
      ),
      sizes: const <String, Size>{
        'phone': Size(360, 800),
        'narrow': Size(320, 800),
      },
      textScales: const <double>[1.0, 3.0],
      theme: theme,
    );
  });
}
