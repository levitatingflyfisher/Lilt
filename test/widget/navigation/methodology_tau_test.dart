import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'nav_harness.dart';

/// Operator ruling (roadmap #47): real technical terms such as Kendall tau
/// stay, in detail views only, with a short plain explanation.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  testWidgets('Show methodology explains Kendall tau in plain words',
      (tester) async {
    await tester.runAsync(() => h.rankedSession());
    await h.pumpApp(tester);
    await tester.tap(find.text('Solo'));
    await NavHarness.settle(tester);

    // Not on the main surface.
    expect(find.textContaining('Kendall'), findsNothing);

    final toggle = find.byType(Switch);
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await NavHarness.settle(tester);

    final tau = find.textContaining('Kendall');
    await tester.ensureVisible(tau);
    expect(tau, findsOneWidget);
    expect(find.textContaining('from −1 (opposite orders) to 1'),
        findsOneWidget);
  });
}
