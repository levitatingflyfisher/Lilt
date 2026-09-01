import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/features/results/couple_results_screen.dart';
import 'package:lilt/features/results/solo_results_screen.dart';

import 'nav_harness.dart';

/// "I'm done — see results" used to send Partner B to B's own solo list,
/// even with Partner A finished; the reveal the couple flow exists for was
/// then only reachable from Home.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  testWidgets("Partner B's I'm done opens the couple reveal", (tester) async {
    await tester.runAsync(() => h.couple(bRanked: true, bComplete: false));
    await h.pumpApp(tester);
    await tester.tap(find.text('Partner B'));
    await NavHarness.settle(tester);

    final done = find.text('I’m done, see results');
    await tester.ensureVisible(done);
    await tester.tap(done);
    await NavHarness.settle(tester);

    expect(find.byType(CoupleResultsScreen), findsOneWidget);
    expect(find.byType(SoloResultsScreen), findsNothing);
  });

  testWidgets("a solo ranker's I'm done still opens their own results",
      (tester) async {
    await tester.runAsync(() => h.rankedSession(complete: false));
    await h.pumpApp(tester);
    await tester.tap(find.text('Solo'));
    await NavHarness.settle(tester);

    final done = find.text('I’m done, see results');
    await tester.ensureVisible(done);
    await tester.tap(done);
    await NavHarness.settle(tester);

    expect(find.byType(SoloResultsScreen), findsOneWidget);
  });
}
