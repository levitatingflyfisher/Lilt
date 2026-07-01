import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:lilt/services/database/database.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';

/// End-to-end net for Lilt's wiring: the real serializer + real crypto,
/// driven through the package's BackupController with Lilt's actual config
/// (appId 'lilt', appDomain 'lilt', context 'lilt-backup/v1'). The generic
/// controller behaviour (RestoreOutcome mapping, seed flows) is unit-tested
/// in the package; this proves Lilt's wiring works against the real
/// sanctuary_auth_core (SANCTUARY-BRIEF §4.W2).
const _validPhrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 7, 12);

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer makeContainer({
    required AppDatabase database,
    required SecureKeyStore store,
    void Function(Ref ref)? onAfterRestore,
  }) {
    final c = ProviderContainer(overrides: [
      secureKeyStoreProvider.overrideWithValue(store),
      cryptoServiceProvider.overrideWithValue(const DefaultCryptoService()),
      sanctuaryAppDomainProvider.overrideWithValue('lilt'),
      // v0.2.0's mandatory pre-restore snapshot writes to the vault before
      // any destructive apply — without an in-memory store the platform
      // vault (path_provider) is unavailable in tests and every restore
      // fails closed as RestoreOutcome.snapshotFailed.
      vaultStoreProvider.overrideWithValue(InMemoryVaultStore()),
      backupSerializerProvider
          .overrideWith((ref) => LiltBackupSerializer(database)),
      sanctuaryBackupConfigProvider.overrideWithValue(
        SanctuaryBackupConfig(
          appId: 'lilt',
          aadContext: 'lilt-backup/v1',
          appDisplayName: 'Lilt',
          onAfterRestore: onAfterRestore,
        ),
      ),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  test('export → restore round-trips Lilt data through the controller',
      () async {
    await db.into(db.nameEntries).insert(NameEntriesCompanion.insert(
          id: 'eliot-m',
          display: 'Eliot',
          gender: 'm',
          variants: '[]',
        ));
    await db.into(db.nameEntries).insert(NameEntriesCompanion.insert(
          id: 'zephyr-m',
          display: 'Zephyr',
          gender: 'm',
          variants: '[]',
          isCustom: const Value(true),
        ));
    await db.into(db.shortlistEntries).insert(ShortlistEntriesCompanion.insert(
          id: 'sh1',
          nameId: 'zephyr-m',
          addedAt: now,
        ));

    final src = makeContainer(
      database: db,
      store: InMemorySecureKeyStore(
          mnemonic: _validPhrase, acknowledged: true),
    );
    final result =
        await src.read(backupControllerProvider.notifier).exportBackup();
    expect(result, isNotNull);
    expect(result!.filename,
        matches(RegExp(r'^lilt-backup-\d{4}-\d{2}-\d{2}\.ohbk$')));
    expect(result.bytes.sublist(0, 4), equals([0x4F, 0x48, 0x42, 0x4B]));

    // Restore into a fresh DB (with the bundled catalog already seeded, as
    // it would be on first launch) and a fresh (empty) keychain, by phrase.
    final db2 = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db2.close);
    await db2.into(db2.nameEntries).insert(NameEntriesCompanion.insert(
          id: 'eliot-m',
          display: 'Eliot',
          gender: 'm',
          variants: '[]',
        ));

    var refreshed = false;
    final dst = makeContainer(
      database: db2,
      store: InMemorySecureKeyStore(),
      onAfterRestore: (_) => refreshed = true,
    );
    final outcome = await dst
        .read(backupControllerProvider.notifier)
        .restoreWithPhrase(result.bytes, _validPhrase);

    expect(outcome, RestoreOutcome.success);
    expect(refreshed, isTrue, reason: 'onAfterRestore must fire');

    final names = await db2.select(db2.nameEntries).get();
    expect(names.map((n) => n.id).toSet(), {'eliot-m', 'zephyr-m'});

    final shortlist = await db2.select(db2.shortlistEntries).get();
    expect(shortlist, hasLength(1));
    expect(shortlist.single.nameId, equals('zephyr-m'));
  });

  test('a non-OHBK blob restores as corruptFile', () async {
    final c = makeContainer(database: db, store: InMemorySecureKeyStore());
    final outcome = await c
        .read(backupControllerProvider.notifier)
        .restoreWithPhrase(Uint8List.fromList(List.filled(64, 0)), _validPhrase);
    expect(outcome, RestoreOutcome.corruptFile);
  });

  test('a backup encrypted for a different appDomain fails to decrypt',
      () async {
    // Export under appDomain 'lilt' (the container default above)...
    final src = makeContainer(
      database: db,
      store: InMemorySecureKeyStore(
          mnemonic: _validPhrase, acknowledged: true),
    );
    final result =
        await src.read(backupControllerProvider.notifier).exportBackup();

    // ...restoring under no domain (legacy/null) must not silently succeed:
    // the derived key differs, so this is the wrong-phrase path.
    final db2 = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db2.close);
    final c = ProviderContainer(overrides: [
      secureKeyStoreProvider.overrideWithValue(InMemorySecureKeyStore()),
      cryptoServiceProvider.overrideWithValue(const DefaultCryptoService()),
      vaultStoreProvider.overrideWithValue(InMemoryVaultStore()),
      // No sanctuaryAppDomainProvider override — stays at the null default.
      backupSerializerProvider
          .overrideWith((ref) => LiltBackupSerializer(db2)),
      sanctuaryBackupConfigProvider.overrideWithValue(
        const SanctuaryBackupConfig(
          appId: 'lilt',
          aadContext: 'lilt-backup/v1',
          appDisplayName: 'Lilt',
        ),
      ),
    ]);
    addTearDown(c.dispose);

    final outcome = await c
        .read(backupControllerProvider.notifier)
        .restoreWithPhrase(result!.bytes, _validPhrase);

    expect(outcome, RestoreOutcome.wrongPhrase);
  });
}
