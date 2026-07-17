import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/app.dart';
import 'package:lilt/core/providers/bootstrap_provider.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:lilt/services/database/database.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'LiltApp runs startup maintenance post-frame: with a key present and '
      'no fresh snapshot, a freshness snapshot lands in the vault',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final vault = InMemoryVaultStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
          // The catalog seed reads a bundled asset — irrelevant to this
          // test, so short-circuit bootstrap.
          bootstrapProvider.overrideWith((ref) async {}),
          secureKeyStoreProvider.overrideWithValue(InMemorySecureKeyStore(
            mnemonic: 'abandon abandon abandon abandon abandon abandon '
                'abandon abandon abandon abandon abandon about',
            acknowledged: true,
          )),
          // Deterministic + fast — skips real PBKDF2.
          cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
          sanctuaryAppDomainProvider.overrideWithValue('lilt'),
          sanctuaryBackupConfigProvider.overrideWithValue(
            const SanctuaryBackupConfig(
              appId: 'lilt',
              aadContext: 'lilt-backup/v1',
              appDisplayName: 'Lilt',
            ),
          ),
          backupSerializerProvider
              .overrideWith((ref) => LiltBackupSerializer(db)),
          vaultStoreProvider.overrideWithValue(vault),
        ],
        child: const LiltApp(),
      ),
    );
    // Let the post-frame hook fire and the async export/vault-save finish.
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    final entries = await vault.list();
    expect(entries, hasLength(1),
        reason: 'the silent app-open freshness snapshot must be vaulted');
    expect(entries.single.label, VaultLabel.freshness);
  });
}
