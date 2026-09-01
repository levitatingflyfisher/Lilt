import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/root_overrides.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../navigation/nav_harness.dart';

/// First-run ruling: open straight into the task; unfinished setup (no
/// backup words yet) gets a persistent, dismissible "finish setup" line so
/// it is never forgotten.
void main() {
  testWidgets('Home shows the Finish setup line until backup is set up',
      (tester) async {
    final h = await NavHarness.create();
    addTearDown(h.dispose);
    await h.pumpApp(tester);
    expect(find.byType(BackupSetupReminder), findsOneWidget);
    expect(find.text("Backup isn't set up. Your data is only on this device."),
        findsOneWidget);
    // The task still comes first: the start button is on screen.
    expect(find.text('New Session'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await NavHarness.settle(tester);
    expect(find.text('Dismiss'), findsNothing);
  });

  test('the root overrides scope the key store per app on web', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
        overrides: liltRootOverrides(prefs: prefs, web: true));
    addTearDown(c.dispose);
    expect(c.read(secureKeyStoreProvider), isA<AppScopedSecureKeyStore>(),
        reason: 'fleet PWAs share an origin; without this, Lilt would read '
            "another app's recovery words");
  });
}
