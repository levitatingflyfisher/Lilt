import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/router.dart';

import '../../navigation/nav_harness.dart';

/// visual-display-01: the bars were scaled from the last-placed name, so
/// last place always drew no ink and a perfect tie drew every bar full.
/// visual-display-07: two browns (primary for the top ten, secondary for
/// the rest) carried an order the numbers already give.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  List<LinearProgressIndicator> bars(WidgetTester tester) => tester
      .widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
      .toList();

  testWidgets('bars are proportional and one colour', (tester) async {
    final id = (await tester.runAsync(() => h.rankedSession()))!;
    await h.pumpApp(tester);
    h.container.read(routerProvider).go('/results/solo/$id');
    await NavHarness.settle(tester);

    final values = [for (final b in bars(tester)) b.value!];
    expect(values, hasLength(4));
    for (var i = 1; i < values.length; i++) {
      expect(values[i], lessThanOrEqualTo(values[i - 1]));
    }
    expect(values.last, greaterThan(0),
        reason: 'last place still has a chance; it is not drawn as zero');
    expect(values.first, lessThan(1),
        reason: 'first place is not certain to win; it is not a full bar');
    expect({for (final b in bars(tester)) b.color}, hasLength(1),
        reason: 'order is carried by position and number, not a second hue');
    expect(find.textContaining('chance of beating'), findsOneWidget,
        reason: 'the bar says what it measures');
  });

  testWidgets('a pool of ties draws every bar at half, not full',
      (tester) async {
    final s = (await tester.runAsync(() => h.sessions.createSession(
        poolIds: NavHarness.poolIds, genderFilter: 'all', poolSize: 4)))!;
    await tester.runAsync(() => h.sessions.markComplete(s.id));
    await h.pumpApp(tester);
    h.container.read(routerProvider).go('/results/solo/${s.id}');
    await NavHarness.settle(tester);

    expect([for (final b in bars(tester)) b.value],
        everyElement(closeTo(0.5, 1e-9)));
  });
}
