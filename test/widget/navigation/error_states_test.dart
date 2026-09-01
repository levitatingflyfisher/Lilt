import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

import 'nav_harness.dart';

/// Audit rank 5 (humane-interface-05): a failure is a plain sentence with a
/// way out, never "Error: Bad state: …" on an empty scaffold. The raw text
/// may sit behind Details, and nowhere else.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  Future<void> goTo(WidgetTester tester, String location) async {
    await h.pumpApp(tester);
    h.container.read(routerProvider).go(location);
    await NavHarness.settle(tester);
  }

  testWidgets('an unknown name shows a plain failure with a way home',
      (tester) async {
    await goTo(tester, '/name/does-not-exist-xyz');

    expect(find.byType(OhErrorState), findsOneWidget);
    expect(find.textContaining('Bad state'), findsNothing);
    expect(find.textContaining('Error:'), findsNothing);
    expect(find.byType(AppBar), findsOneWidget,
        reason: 'the failure keeps its screen chrome, so Back still works');

    await tester.tap(find.text('Back to your sessions'));
    await NavHarness.settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('the raw exception is only behind Details', (tester) async {
    await goTo(tester, '/name/does-not-exist-xyz');
    expect(find.textContaining('does-not-exist-xyz'), findsNothing);
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.textContaining('does-not-exist-xyz'), findsWidgets);
  });

  testWidgets('an unknown route is a plain page with a way home',
      (tester) async {
    await goTo(tester, '/no/such/place');

    expect(find.textContaining('Route not found'), findsNothing);
    expect(find.textContaining('/no/such/place'), findsNothing);
    await tester.tap(find.text('Back to your sessions'));
    await NavHarness.settle(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(h.container.read(routerProvider).state.uri.path, '/');
  });

  testWidgets('a missing session on results fails plainly', (tester) async {
    // Solo results for a session that does not exist: the guard lets an
    // unknown id through (nothing to protect), the screen must not crash.
    await goTo(tester, '/results/solo/nope');
    expect(find.textContaining('Bad state'), findsNothing);
    expect(find.byType(OhErrorState), findsOneWidget);
  });
}
