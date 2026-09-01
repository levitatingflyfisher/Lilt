import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/features/name_detail/name_detail_screen.dart';
import 'package:lilt/features/shortlist/shortlist_screen.dart';

import 'nav_harness.dart';

/// lilt:dont-make-me-think-04 — Name Detail (and with it "Add to Shortlist")
/// was declared at /name/:nameId but pushed from nowhere. These tests start
/// at Home and reach it the way a user would.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  testWidgets('Home app bar reaches the Shortlist', (tester) async {
    await h.pumpApp(tester);
    await tester.tap(find.text('Shortlist'));
    await NavHarness.settle(tester);
    expect(find.byType(ShortlistScreen), findsOneWidget);
  });

  testWidgets('Home -> solo results -> tap a ranked name -> Name Detail',
      (tester) async {
    await tester.runAsync(() => h.rankedSession());
    await h.pumpApp(tester);

    await tester.tap(find.text('Solo'));
    await NavHarness.settle(tester);
    expect(find.text('Your Rankings'), findsOneWidget);

    await tester.tap(find.text('Beatrice'));
    await NavHarness.settle(tester);
    expect(find.byType(NameDetailScreen), findsOneWidget);
    expect(find.text('Add to Shortlist'), findsOneWidget);
    // A solo ranker is not "Partner A".
    expect(find.textContaining('Partner A'), findsNothing);
    expect(find.text('Your rank: #2'), findsOneWidget);
  });

  testWidgets('Home -> couple Matches -> tap a match -> Name Detail',
      (tester) async {
    await tester.runAsync(() => h.couple());
    await h.pumpApp(tester);

    await tester.tap(find.text('Couple session'));
    await NavHarness.settle(tester);
    expect(find.text('Matches'), findsWidgets);

    // Tap the name in the centre Matches column.
    await tester.tap(find.text('Cyrus').at(1));
    await NavHarness.settle(tester);
    expect(find.byType(NameDetailScreen), findsOneWidget);
    expect(find.text('Partner A: #3'), findsOneWidget);
    expect(find.text('Partner B: #3'), findsOneWidget);
  });

  testWidgets('Name Detail -> Add to Shortlist -> Shortlist row opens it',
      (tester) async {
    await tester.runAsync(() => h.rankedSession());
    await h.pumpApp(tester);
    await tester.tap(find.text('Solo'));
    await NavHarness.settle(tester);
    await tester.tap(find.text('Delphine'));
    await NavHarness.settle(tester);
    await tester.tap(find.text('Add to Shortlist'));
    await NavHarness.settle(tester);

    // Back to Home, then into the Shortlist.
    await tester.pageBack();
    await NavHarness.settle(tester);
    await tester.pageBack();
    await NavHarness.settle(tester);
    await tester.tap(find.text('Shortlist'));
    await NavHarness.settle(tester);
    expect(find.byType(ShortlistScreen), findsOneWidget);

    await tester.tap(find.text('Delphine'));
    await NavHarness.settle(tester);
    expect(find.byType(NameDetailScreen), findsOneWidget);
    expect(find.text('In Shortlist'), findsOneWidget);
  });

  testWidgets('empty Shortlist names a reachable path', (tester) async {
    await h.pumpApp(tester);
    await tester.tap(find.text('Shortlist'));
    await NavHarness.settle(tester);
    expect(find.textContaining('rankings'), findsOneWidget);
    expect(find.byType(Center), findsWidgets);
  });
}
