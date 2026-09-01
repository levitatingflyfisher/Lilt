import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/features/results/solo_results_screen.dart';

import 'nav_harness.dart';

/// The /results/solo guard's cost: if Partner B abandons, Partner A's own
/// ranking would stay locked forever. "End pairing" on A's locked tile is
/// the way out; it must not touch B's session or comparisons.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  testWidgets('End pairing, confirmed, unlocks A and keeps B intact',
      (tester) async {
    final (a, b) = await tester
        .runAsync(() => h.couple(bRanked: true, bComplete: false))
        .then((v) => v!);
    final bMatchesBefore = await tester
        .runAsync(() => h.db.eloMatchesDao.getMatchesForSession(b))
        .then((v) => v!.length);
    await h.pumpApp(tester);

    await tester.tap(find.text('End pairing'));
    await NavHarness.settle(tester);
    // Confirm dialog: the tile button is an easy tap, so it must ask.
    expect(find.text('End pairing?'), findsOneWidget);
    await tester.tap(find.text('End pairing').last);
    await NavHarness.settle(tester);

    expect(find.textContaining('Locked until'), findsNothing);
    await tester.tap(find.text('Partner A'));
    await NavHarness.settle(tester);
    expect(find.byType(SoloResultsScreen), findsOneWidget);

    final (bSession, bMatchesAfter) = await tester.runAsync(() async => (
          await h.sessions.getSession(b),
          (await h.db.eloMatchesDao.getMatchesForSession(b)).length,
        )).then((v) => v!);
    expect(bSession, isNotNull);
    expect(bSession!.isComplete, isFalse);
    expect(bMatchesAfter, bMatchesBefore);
    expect((await tester.runAsync(() => h.sessions.getSession(a)))!
        .partnerSessionId, isNull);
  });

  testWidgets('cancelling End pairing keeps the lock', (tester) async {
    await tester.runAsync(() => h.couple(bRanked: false, bComplete: false));
    await h.pumpApp(tester);

    await tester.tap(find.text('End pairing'));
    await NavHarness.settle(tester);
    await tester.tap(find.text('Cancel'));
    await NavHarness.settle(tester);

    expect(find.textContaining('Locked until Partner B finishes'),
        findsOneWidget);
  });

  testWidgets('the locked tile does not overflow at 320dp / textScale 3.0',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 800);
    await tester.runAsync(() => h.couple(bRanked: false, bComplete: false));
    await tester.pumpWidget(UncontrolledProviderScope(
      container: h.container,
      child: MaterialApp.router(
        routerConfig: h.container.read(routerProvider),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(3.0)),
          child: child!,
        ),
      ),
    ));
    await NavHarness.settle(tester);
    expect(find.text('End pairing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
