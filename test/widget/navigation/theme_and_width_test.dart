import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:openhearth_design/openhearth_design.dart';

import 'nav_harness.dart';

/// Theme ruling: the switch is one tap, at most two, from any primary
/// screen. Wide screens: OhPage caps and centres each screen instead of the
/// app-wide 760px clamp, so a phone layout is not stretched at 1024.
///
/// Matchup and the veto pass are deliberately left without the toggle: they
/// are the screens handed across the table mid-sitting, and a mode change
/// there changes the interface under the next person (humane-07, Mantle's
/// precedent). They still get OhPage.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  Future<void> at(WidgetTester tester, String location) async {
    h.container.read(routerProvider).go(location);
    await NavHarness.settle(tester);
  }

  testWidgets('every primary screen carries the theme toggle and OhPage',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final (a, b) =
        await tester.runAsync(() => h.couple()).then((v) => v!);
    final nameId = NavHarness.idOf('Beatrice');
    await h.pumpApp(tester);

    for (final loc in [
      '/',
      '/pool-config',
      '/results/solo/$a',
      '/results/couple?a=$a&b=$b',
      '/name/$nameId?a=$a',
      '/shortlist',
      '/settings',
    ]) {
      await at(tester, loc);
      expect(find.byType(OhThemeToggle), findsOneWidget, reason: loc);
      expect(find.byType(OhPage), findsOneWidget, reason: loc);
      final page = tester.getSize(find.byType(OhPage));
      expect(page.width, 1024, reason: '$loc: OhPage fills the window');
      // The content itself is capped, not the window.
      final capped = tester
          .widgetList<ConstrainedBox>(find.descendant(
              of: find.byType(OhPage), matching: find.byType(ConstrainedBox)))
          .any((c) => c.constraints.maxWidth <= OhPage.phoneMaxWidth);
      expect(capped, isTrue, reason: '$loc: content is width-capped');
    }
  });

  testWidgets('the toggle switches theme in two taps', (tester) async {
    await h.pumpApp(tester);
    expect(h.container.read(themePreferenceProvider),
        OhThemeModePreference.system);
    await tester.tap(find.byType(OhThemeToggle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();
    expect(h.container.read(themePreferenceProvider),
        OhThemeModePreference.dark);
  });

  testWidgets('the pass-the-phone matchup has OhPage but no toggle',
      (tester) async {
    final id = await tester
        .runAsync(() => h.rankedSession(complete: false))
        .then((v) => v!);
    await h.pumpApp(tester);
    await at(tester, '/matchup/$id');
    expect(find.byType(OhPage), findsOneWidget);
    expect(find.byType(OhThemeToggle), findsNothing);
  });
}
