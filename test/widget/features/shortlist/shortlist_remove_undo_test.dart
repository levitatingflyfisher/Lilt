import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/shortlist_repository.dart';

import '../../navigation/nav_harness.dart';

/// Removing a shortlisted name is a deliberate tap, so it does not ask; it
/// offers an Undo that stays until the person acts or leaves the screen,
/// and Undo brings back the same entry, note and all.
void main() {
  late NavHarness h;
  late ShortlistRepository shortlist;
  setUp(() async {
    h = await NavHarness.create();
    shortlist =
        ShortlistRepository(h.db.shortlistDao, NamesRepository(h.db.namesDao));
  });
  tearDown(() async => h.dispose());

  testWidgets('Remove acts at once and Undo restores the note',
      (tester) async {
    final before = await tester.runAsync(() async {
      await shortlist.add(NavHarness.idOf('Beatrice'), note: 'Grandma');
      return (await shortlist.getAll()).single;
    });
    await h.pumpApp(tester);
    h.container.read(routerProvider).push('/shortlist');
    await NavHarness.settle(tester);

    await tester.tap(find.byTooltip('Remove Beatrice'));
    await NavHarness.settle(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect((await tester.runAsync(shortlist.getAll))!, isEmpty);
    expect(find.text('Removed Beatrice'), findsOneWidget);

    await tester.pump(const Duration(hours: 1));
    await tester.tap(find.text('Undo'));
    await NavHarness.settle(tester);

    final after = (await tester.runAsync(shortlist.getAll))!.single;
    expect(after.id, before!.id);
    expect(after.note, 'Grandma');
    expect(after.addedAt, before.addedAt);
    expect(find.text('Beatrice'), findsOneWidget);
  });
}
