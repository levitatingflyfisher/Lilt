// The release gate for Lilt's primary-action screens (C5-primaryScreens):
// at 360dp x 1.3 text the primary action is on screen and tappable, and at
// 320dp x 3.0 nothing overflows. Rendered with Lilt's real light theme.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/theme.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'package:lilt/features/matchup/matchup_screen.dart';
import 'package:lilt/features/name_detail/name_detail_screen.dart';
import 'package:lilt/features/pool_config/pool_config_screen.dart';
import 'package:lilt/features/results/couple_results_screen.dart';
import 'package:lilt/features/results/solo_results_screen.dart';
import 'package:lilt/features/settings/settings_screen.dart';
import 'package:oh_fleet_conformance/oh_fleet_conformance.dart';

import '../widget/navigation/nav_harness.dart';

void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: h.container,
      child: MaterialApp(theme: LiltTheme.light(), home: screen),
    ));
    await NavHarness.settle(tester);
  }

  testWidgets('Home: New Session is reachable', (tester) async {
    await tester.runAsync(() async {
      for (var i = 0; i < 4; i++) {
        await h.rankedSession(complete: i.isEven);
      }
    });
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => pump(tester, const HomeScreen()),
      primaryAction: find.text('New Session'),
    );
  });

  testWidgets('Pool setup: Start Ranking is reachable', (tester) async {
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => pump(tester, const PoolConfigScreen()),
      primaryAction: find.text('Start Ranking'),
    );
  });

  testWidgets('Matchup: both name cards are reachable', (tester) async {
    final id = (await tester
        .runAsync(() => h.rankedSession(complete: false)))!;
    // A fresh session so there is a pair to choose between.
    final fresh = (await tester.runAsync(() => h.sessions.createSession(
        poolIds: NavHarness.poolIds, genderFilter: 'all', poolSize: 4)))!;
    expect(id, isNotEmpty);
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => pump(tester, MatchupScreen(sessionId: fresh.id)),
      primaryAction: find.byKey(const Key('name-card-b')),
    );
  });

  testWidgets('Your Rankings: Pass to Partner is reachable', (tester) async {
    final id = (await tester.runAsync(() => h.rankedSession()))!;
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => pump(tester, SoloResultsScreen(sessionId: id)),
      primaryAction: find.text('Pass to Partner'),
    );
  });

  testWidgets('Matches: the top match is reachable', (tester) async {
    final (a, b) = (await tester.runAsync(() => h.couple()))!;
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => pump(
          tester, CoupleResultsScreen(sessionAId: a, sessionBId: b)),
      primaryAction: find.text('Alexander'),
    );
  });

  testWidgets('Name Detail: Add to Shortlist is reachable', (tester) async {
    final a = (await tester.runAsync(() => h.rankedSession()))!;
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => pump(tester,
          NameDetailScreen(nameId: NavHarness.idOf('Delphine'), sessionAId: a)),
      primaryAction: find.text('Add to Shortlist'),
    );
  });

  testWidgets('Settings: Clear all sessions is reachable', (tester) async {
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => pump(tester, const SettingsScreen()),
      primaryAction: find.text('Clear all sessions'),
    );
  });
}
