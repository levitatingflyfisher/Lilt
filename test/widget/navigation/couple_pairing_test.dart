import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/features/matchup/matchup_screen.dart';

import 'nav_harness.dart';

/// lilt:design-of-everyday-things-01 — Home used to guess couples from
/// creation timestamps (stored to the second), and a Partner B resumed from
/// Home lost `partnerA` and was offered "Pass Phone to Partner". Both now
/// come from the persisted pairing.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  testWidgets('Home pairs a couple created within the same second',
      (tester) async {
    await tester.runAsync(() => h.couple());
    await h.pumpApp(tester);
    expect(find.text('Couple session'), findsOneWidget);
    expect(find.text('Partner A'), findsNothing);
    expect(find.text('Partner B'), findsNothing);
  });

  testWidgets('a Partner B resumed from Home keeps the couple flow',
      (tester) async {
    final (a, _) = await tester
        .runAsync(() => h.couple(bRanked: false, bComplete: false))
        .then((v) => v!);
    await h.pumpApp(tester);

    await tester.tap(find.text('Partner B'));
    await NavHarness.settle(tester);

    // The matchup screen only offers "See Results Together" (and withholds
    // "Pass Phone to Partner") when it knows Partner A's session.
    final screen = tester.widget<MatchupScreen>(find.byType(MatchupScreen));
    expect(screen.partnerASessionId, a);
  });
}
