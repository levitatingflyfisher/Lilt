import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:lilt/features/settings/settings_screen.dart';
import 'package:lilt/services/database/database.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression guard for the fleet a11y convention (SANCTUARY-BRIEF §4.W2):
/// the settings screen, now including BackupSettingsSection, must not
/// overflow at the worst-case narrow-width / large-accessibility-text combo.
Future<ProviderContainer> _makeContainer() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    sharedPreferencesProvider.overrideWithValue(prefs),
    secureKeyStoreProvider.overrideWithValue(
      InMemorySecureKeyStore(
        mnemonic: 'abandon abandon abandon abandon abandon abandon '
            'abandon abandon abandon abandon abandon about',
        acknowledged: true,
        lastBackupAt: DateTime(2026, 7, 1),
      ),
    ),
    cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
    sanctuaryAppDomainProvider.overrideWithValue('lilt'),
    sanctuaryBackupConfigProvider.overrideWithValue(
      const SanctuaryBackupConfig(
        appId: 'lilt',
        aadContext: 'lilt-backup/v1',
        appDisplayName: 'Lilt',
      ),
    ),
    backupSerializerProvider.overrideWith(
      (ref) => LiltBackupSerializer(db),
    ),
  ]);
  return container;
}

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = await _makeContainer();
  });

  tearDown(() => container.dispose());

  testWidgets('settings screen does not overflow at 320dp / textScale 3.0',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 800);

    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(3.0)),
        child: child!,
      ),
      home: UncontrolledProviderScope(
        container: container,
        child: const SettingsScreen(),
      ),
    ));
    // Give the auth notifier time to derive keys so the "seed acknowledged"
    // (Export/Reset-identity) branch of BackupSettingsSection renders too.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);

    // Scroll the BackupSettingsSection into view — ListView only builds
    // items within the viewport/cache extent, so this also exercises the
    // widget's own layout at 320dp/textScale 3.0, not just the tiles above
    // the fold.
    await tester.scrollUntilVisible(
      find.text('Encrypted Backup'),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Encrypted Backup'), findsOneWidget);
    expect(find.text('Export backup'), findsOneWidget);
  });
}
