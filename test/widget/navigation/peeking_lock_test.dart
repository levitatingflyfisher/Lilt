import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/features/matchup/matchup_screen.dart';
import 'package:lilt/features/results/solo_results_screen.dart';

import 'nav_harness.dart';

/// The peeking lock (ADR-0004), end to end on the real router. Before this,
/// only /results/couple was guarded: Home sent Partner A's completed tile to
/// /results/solo, and both hand-offs pushed B's matchup on top of A's
/// results, one back-press away (lilt:design-of-everyday-things-01,
/// lilt:checklist-manifesto-06).
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  GoRouter router() => h.container.read(routerProvider);

  testWidgets("Partner A's results are closed while Partner B ranks",
      (tester) async {
    final (a, _) = await tester
        .runAsync(() => h.couple(bRanked: false, bComplete: false))
        .then((v) => v!);
    await h.pumpApp(tester);

    router().push('/results/solo/$a');
    await NavHarness.settle(tester);
    expect(find.byType(SoloResultsScreen, skipOffstage: false), findsNothing);
  });

  testWidgets("Home shows Partner A's tile as locked, not as a dead link",
      (tester) async {
    await tester.runAsync(() => h.couple(bRanked: false, bComplete: false));
    await h.pumpApp(tester);

    final tile = tester.widget<ListTile>(
        find.ancestor(of: find.text('Partner A'), matching: find.byType(ListTile)));
    expect(tile.onTap, isNull);
    expect(find.textContaining('Locked until Partner B finishes'),
        findsOneWidget);
  });

  testWidgets('each partner may open their own results once both finish',
      (tester) async {
    final (a, b) = await tester.runAsync(() => h.couple()).then((v) => v!);
    await h.pumpApp(tester);

    router().push('/results/solo/$a');
    await NavHarness.settle(tester);
    expect(find.byType(SoloResultsScreen), findsOneWidget);

    router().go('/results/solo/$b');
    await NavHarness.settle(tester);
    expect(find.byType(SoloResultsScreen), findsOneWidget);
  });

  testWidgets('a solo session is never locked', (tester) async {
    final id = await tester.runAsync(() => h.rankedSession()).then((v) => v!);
    await h.pumpApp(tester);
    router().push('/results/solo/$id');
    await NavHarness.settle(tester);
    expect(find.byType(SoloResultsScreen), findsOneWidget);
  });

  testWidgets("the hand-off leaves nothing of A's beneath Partner B",
      (tester) async {
    await tester.runAsync(() => h.rankedSession(label: 'Partner A'));
    await h.pumpApp(tester);

    await tester.tap(find.text('Partner A'));
    await NavHarness.settle(tester);
    expect(find.byType(SoloResultsScreen), findsOneWidget);

    await tester.tap(find.text('Pass to Partner'));
    await NavHarness.settle(tester);
    expect(find.byType(MatchupScreen), findsOneWidget);
    expect(find.byType(SoloResultsScreen, skipOffstage: false), findsNothing);

    // Backing out of B's matchup lands on Home, not on A's ranking.
    await tester.pageBack();
    await NavHarness.settle(tester);
    expect(find.byType(SoloResultsScreen, skipOffstage: false), findsNothing);
    expect(find.text('New Session'), findsOneWidget);
  });

  // Clear all sessions is a soft delete with a per-session Restore. A cleared
  // partner reads as deleted to the guard, so restoring Partner A alone would
  // let Partner B open A's list mid-ranking. A couple is restored together.
  testWidgets('restoring one half of a cleared couple restores both',
      (tester) async {
    final (a, b) = await tester
        .runAsync(() => h.couple(bRanked: false, bComplete: false))
        .then((v) => v!);
    await tester.runAsync(() async {
      await h.sessions.clearAllSessions();
      await h.sessions.restoreSessions([a]);
    });
    expect(await tester.runAsync(() => h.sessions.getSession(b)), isNotNull,
        reason: "B's half comes back with A's");
    await h.pumpApp(tester);
    expect(find.textContaining('Locked until'), findsOneWidget);

    router().push('/results/solo/$a');
    await NavHarness.settle(tester);
    expect(find.byType(SoloResultsScreen, skipOffstage: false), findsNothing);
  });
}
