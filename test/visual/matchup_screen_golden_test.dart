import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/theme.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/session_repository.dart';
import 'package:lilt/features/matchup/matchup_notifier.dart';
import 'package:lilt/features/matchup/matchup_screen.dart';
import 'package:lilt/services/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'visual_golden_helper.dart';

/// Full-screen visual golden for the real [MatchupScreen].
///
/// This renders the SHIPPED screen — `_MatchupBody`, the two private
/// `_NameCard`s, the `ConvergenceBar`, and the action row — against an
/// in-memory Drift DB seeded with three names, mirroring
/// `test/features/matchup/matchup_notifier_test.dart` exactly. No private
/// widget is copied, so the golden cannot drift from the source.
///
/// `MatchupScreen` uses `context.push`/`pushReplacement` only inside tap
/// callbacks, never during build, so a plain `MaterialApp.home` (supplied by
/// `goldenAtSizes`) renders the initial matchup view without a GoRouter.
Future<(AppDatabase, ProviderContainer, String)> _seed() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());

  await db.namesDao.insertNames([
    NameEntriesCompanion.insert(
      id: 'a-m',
      display: 'Alexander',
      gender: 'm',
      variants: '[]',
    ),
    NameEntriesCompanion.insert(
      id: 'b-m',
      display: 'Benjamin',
      gender: 'm',
      variants: '[]',
    ),
    NameEntriesCompanion.insert(
      id: 'c-m',
      display: 'Charlie',
      gender: 'm',
      variants: '[]',
    ),
  ]);

  final namesRepo = NamesRepository(db.namesDao);
  final sessionRepo = SessionRepository(
    db.sessionDao,
    db.eloMatchesDao,
    namesRepo,
  );
  final session = await sessionRepo.createSession(
    poolIds: ['a-m', 'b-m', 'c-m'],
    genderFilter: 'm',
    poolSize: 3,
  );

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  return (db, container, session.id);
}

void main() {
  // The real app themes (lib/app/theme.dart) — goldens render the shipped
  // openhearth_design grammar, not a hand-rolled mirror that can drift.
  // Both brightnesses are swept: dark mode ships to users too, and its
  // AA-tuned accent (LiltTheme.accentDark) has its own legibility story
  // the light goldens cannot vouch for. The light variant keeps the
  // original unsuffixed golden names.
  final themes = <String, ThemeData Function()>{
    'light': LiltTheme.light,
    'dark': LiltTheme.dark,
  };

  late AppDatabase db;
  late ProviderContainer container;
  late String sessionId;

  setUp(() async {
    (db, container, sessionId) = await _seed();
    // Warm the matchup provider so the screen's first frame shows the
    // matchup body (not the loading spinner) when rendered below.
    await container.read(matchupProvider(sessionId).future);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  for (final MapEntry<String, ThemeData Function()> entry in themes.entries) {
    testWidgets(
      'MatchupScreen renders across sizes and text scales (${entry.key})',
      (tester) async {
        await goldenAtSizes(
          tester,
          name: entry.key == 'light' ? 'matchup_screen' : 'matchup_screen_dark',
          home: UncontrolledProviderScope(
            container: container,
            child: MatchupScreen(sessionId: sessionId),
          ),
          sizes: const <String, Size>{
            'phone': Size(360, 800),
            'narrow': Size(320, 800),
          },
          textScales: const <double>[1.0, 3.0],
          theme: entry.value(),
        );
      },
    );
  }
}
