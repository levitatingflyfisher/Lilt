import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/router.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../navigation/nav_harness.dart';

/// Fleet delete ruling: a deliberate delete does not ask; it deletes softly
/// and offers an Undo that never times out, and a lasting Recently cleared
/// list keeps the way back. Clear covers sessions in progress too, so a
/// couple abandoned half-way can always be cleared (item-09 concern 8).
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  Future<void> openSettings(WidgetTester tester) async {
    h.container.read(routerProvider).push('/settings');
    await NavHarness.settle(tester);
  }

  Future<void> tapClear(WidgetTester tester) async {
    final clear = find.text('Clear all sessions');
    await tester.scrollUntilVisible(clear, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(clear);
    await NavHarness.settle(tester);
  }

  Future<int> liveCount(WidgetTester tester) async =>
      (await tester.runAsync(() => h.sessions.getAllSessions()))!.length;

  testWidgets('Clear acts at once, clears in-progress too, and Undo stays',
      (tester) async {
    await tester.runAsync(() async {
      await h.rankedSession();
      await h.couple(bRanked: false, bComplete: false);
    });
    await h.pumpApp(tester);
    await openSettings(tester);

    await tapClear(tester);
    expect(find.byType(AlertDialog), findsNothing,
        reason: 'a deliberate delete does not ask first');
    expect(await liveCount(tester), 0,
        reason: 'finished and in-progress sessions are both cleared');
    expect(find.text('Cleared 3 sessions'), findsOneWidget);

    // No timer: an hour later the offer is still there.
    await tester.pump(const Duration(hours: 1));
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await NavHarness.settle(tester);
    expect(await liveCount(tester), 3);
    expect(find.text('Cleared 3 sessions'), findsNothing);
  });

  testWidgets('Recently cleared outlives the screen: restore, delete forever',
      (tester) async {
    await tester.runAsync(() async {
      await h.rankedSession();
      await h.rankedSession();
    });
    await h.pumpApp(tester);
    await openSettings(tester);
    await tapClear(tester);

    // Leave Settings (the Undo lapses) and come back.
    h.container.read(routerProvider).pop();
    await NavHarness.settle(tester);
    await openSettings(tester);

    final heading = find.text('Recently cleared');
    await tester.scrollUntilVisible(heading, 200,
        scrollable: find.byType(Scrollable).first);
    expect(heading, findsOneWidget);

    final restore = find.text('Restore').first;
    await tester.ensureVisible(restore);
    await tester.tap(restore);
    await NavHarness.settle(tester);
    expect(await liveCount(tester), 1);

    final forever = find.text('Delete forever');
    await tester.ensureVisible(forever);
    await tester.tap(forever);
    await NavHarness.settle(tester);
    // Permanent, so it asks, and the button names the act.
    expect(find.text('Delete 1 session'), findsOneWidget);
    await tester.tap(find.text('Delete 1 session'));
    await NavHarness.settle(tester);

    expect(
        (await tester.runAsync(() => h.sessions.clearedSessions()))!, isEmpty);
    expect(await liveCount(tester), 1);
    expect(find.text('Recently cleared'), findsNothing);
  });

  testWidgets('Clear with nothing to clear offers no Undo',
      (tester) async {
    await h.pumpApp(tester);
    await openSettings(tester);
    await tapClear(tester);
    expect(find.byType(OhUndoBar), findsOneWidget);
    expect(find.text('Undo'), findsNothing);
  });
}
