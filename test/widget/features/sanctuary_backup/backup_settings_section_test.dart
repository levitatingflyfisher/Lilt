import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';

Widget _wrapWithProviders(
  Widget child, {
  required SecureKeyStore store,
}) {
  return ProviderScope(
    overrides: [
      secureKeyStoreProvider.overrideWithValue(store),
      // Deterministic + fast — skips real PBKDF2 so tests don't need a
      // multi-second pumpAndSettle to let key derivation finish.
      cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
      sanctuaryAppDomainProvider.overrideWithValue('lilt'),
      // Lilt's real backup wiring (SANCTUARY-BRIEF §4.W2).
      sanctuaryBackupConfigProvider.overrideWithValue(
        const SanctuaryBackupConfig(
          appId: 'lilt',
          aadContext: 'lilt-backup/v1',
          appDisplayName: 'Lilt',
        ),
      ),
      backupSerializerProvider.overrideWithValue(FakeBackupSerializer()),
    ],
    child: MaterialApp(home: Scaffold(body: ListView(children: [child]))),
  );
}

void main() {
  group('BackupSettingsSection', () {
    testWidgets('shows "Set up encrypted backup" in ghost state',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const BackupSettingsSection(),
          store: InMemorySecureKeyStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set up encrypted backup'), findsOneWidget);
      expect(find.text('Export backup'), findsNothing);
    });

    testWidgets('shows "Restore from backup" always', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const BackupSettingsSection(),
          store: InMemorySecureKeyStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Restore from backup'), findsOneWidget);
    });

    testWidgets('shows Export button after seed acknowledged', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const BackupSettingsSection(),
          store: InMemorySecureKeyStore(
            mnemonic: 'abandon abandon abandon abandon abandon abandon '
                'abandon abandon abandon abandon abandon about',
            acknowledged: true,
          ),
        ),
      );
      // AuthNotifier needs time to derive keys from the mnemonic.
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Export backup'), findsOneWidget);
      expect(find.text('Set up encrypted backup'), findsNothing);
    });

    testWidgets('shows section header', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const BackupSettingsSection(),
          store: InMemorySecureKeyStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Encrypted Backup'), findsOneWidget);
    });
  });
}
