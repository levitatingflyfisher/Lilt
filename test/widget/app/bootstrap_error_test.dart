import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/app.dart';
import 'package:lilt/core/providers/bootstrap_provider.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'package:lilt/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:lilt/services/database/database.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// C10 finding app.dart:83: a failed catalog load printed
/// "Failed to load name data" followed by the raw exception with no way to try again.
void main() {
  testWidgets('a failed catalog load is a plain failure that can retry',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    var attempts = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        bootstrapProvider.overrideWith((ref) async {
          attempts++;
          if (attempts == 1) throw const FormatException('names.json: bad');
        }),
        secureKeyStoreProvider.overrideWithValue(InMemorySecureKeyStore()),
        cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
        sanctuaryAppDomainProvider.overrideWithValue('lilt'),
        sanctuaryBackupConfigProvider.overrideWithValue(
          const SanctuaryBackupConfig(
              appId: 'lilt',
              aadContext: 'lilt-backup/v1',
              appDisplayName: 'Lilt'),
        ),
        backupSerializerProvider.overrideWith((ref) => LiltBackupSerializer(db)),
        vaultStoreProvider.overrideWithValue(InMemoryVaultStore()),
        backupReminderStoreProvider
            .overrideWithValue(InMemoryBackupReminderStore()),
      ],
      child: const LiltApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(OhErrorState), findsOneWidget);
    expect(find.textContaining('names.json'), findsNothing,
        reason: 'the raw exception belongs behind Details');

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
