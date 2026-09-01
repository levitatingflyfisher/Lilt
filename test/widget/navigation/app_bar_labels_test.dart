import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/services/database/database.dart';

import 'nav_harness.dart';

/// Top-bar ruling (humane-interface-11): icon plus a short visible label; a
/// tooltip is never a command's only name. C11 accepts a tooltip, so this is
/// Lilt's stricter check: no icon-only button in any app bar, on every
/// screen, at the audit's 360dp phone width.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  testWidgets('no app bar anywhere holds an icon-only button',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final (a, b) = await tester.runAsync(() async {
      final pair = await h.couple();
      await h.rankedSession(complete: false);
      return pair;
    }).then((v) => v!);
    final inProgress = (await tester.runAsync(h.sessions.getAllSessions))!
        .firstWhere((s) => !s.isComplete)
        .id;
    await tester.runAsync(() => h.db.shortlistDao.add(
        ShortlistEntriesCompanion.insert(
            id: 'e1', nameId: NavHarness.idOf('Cyrus'), addedAt: DateTime(2026))));
    await h.pumpApp(tester);

    for (final loc in [
      '/',
      '/pool-config',
      '/matchup/$inProgress',
      '/results/solo/$a',
      '/results/couple?a=$a&b=$b',
      '/name/${NavHarness.idOf('Cyrus')}?a=$a',
      '/shortlist',
      '/settings',
    ]) {
      h.container.read(routerProvider).go(loc);
      await NavHarness.settle(tester);
      final bar = find.byType(AppBar);
      expect(bar, findsOneWidget, reason: loc);
      // The system back arrow is a leading control, not an action.
      final back = find
          .descendant(
              of: find.byWidgetPredicate(
                  (w) => w is BackButton || w is CloseButton),
              matching: find.byType(IconButton))
          .evaluate()
          .toSet();
      final iconOnly = find
          .descendant(of: bar, matching: find.byType(IconButton))
          .evaluate()
          .where((e) => !back.contains(e))
          .map((e) => (e.widget as IconButton).tooltip)
          .toList();
      expect(iconOnly, isEmpty, reason: '$loc has icon-only actions');
      expect(tester.takeException(), isNull, reason: loc);
    }
  });
}
