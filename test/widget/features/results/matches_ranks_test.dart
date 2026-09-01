import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/domain/models/ranking.dart';
import 'package:lilt/services/database/database.dart';

import '../../navigation/nav_harness.dart';

/// dashboard-design-03: the reveal sorted matches by both partners' ranks
/// and then withheld the ranks. visual-display-07: a match in both top
/// fives was told apart from other matches by a second brown alone, with
/// no key.
void main() {
  late NavHarness h;
  setUp(() async => h = await NavHarness.create());
  tearDown(() async => h.dispose());

  testWidgets('each match shows both ranks; columns are numbered',
      (tester) async {
    final (a, b) = (await tester.runAsync(() => h.couple()))!;
    await h.pumpApp(tester);
    h.container.read(routerProvider).go('/results/couple?a=$a&b=$b');
    await NavHarness.settle(tester);

    // Both partners ranked Alexander > Beatrice > Cyrus > Delphine.
    expect(find.text('A 1 · B 1'), findsOneWidget);
    expect(find.text('A 4 · B 4'), findsOneWidget);
    // The two partners' columns print rank numbers too.
    expect(find.text('1'), findsNWidgets(2));
  });

  testWidgets('matches share one colour; order is carried by the numbers',
      (tester) async {
    // Eight names, ranked in opposite orders, so some matches sit in both
    // top fives and some do not.
    const extra = ['Eleanor', 'Felix', 'Greta', 'Hugo'];
    final ids = [
      ...NavHarness.poolIds,
      for (final n in extra) NavHarness.idOf(n),
    ];
    final (a, b) = (await tester.runAsync(() async {
      await h.db.namesDao.insertNames([
        for (final n in extra)
          NameEntriesCompanion.insert(
              id: NavHarness.idOf(n), display: n, gender: 'n', variants: '[]'),
      ]);
      Future<String> ranked(String label, List<String> order) async {
        final s = await h.sessions.createSession(
            participantLabel: label,
            poolIds: ids,
            genderFilter: 'all',
            poolSize: ids.length);
        for (var i = 0; i < order.length; i++) {
          for (var j = i + 1; j < order.length; j++) {
            await h.sessions.recordMatch(
                sessionId: s.id,
                idA: order[i],
                idB: order[j],
                outcome: ComparisonOutcome.aWins);
          }
        }
        await h.sessions.markComplete(s.id);
        return s.id;
      }

      final a = await ranked('Partner A', ids);
      final b = await ranked('Partner B', ids.reversed.toList());
      return (a, b);
    }))!;
    await h.pumpApp(tester);
    h.container.read(routerProvider).go('/results/couple?a=$a&b=$b');
    await NavHarness.settle(tester);

    final matchColumn = find.byKey(const Key('matches-column'));
    final colours = {
      for (final t in tester.widgetList<Text>(
          find.descendant(of: matchColumn, matching: find.byType(Text))))
        if (!t.data!.startsWith('A ') && t.data != 'Matches') t.style?.color,
    };
    expect(colours, hasLength(1));
  });
}
