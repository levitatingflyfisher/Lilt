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

/// lilt:checklist-manifesto-06 / lilt:design-of-everyday-things-01 — the
/// "Peeking Prevention" row was a const ListTile with a padlock and copy
/// starting "When on", but nothing could switch it. It cannot be made a real
/// switch: the /results/couple guard requires resultsLocked on both
/// sessions, so turning it off would dead-end the reveal. The row now states
/// the guarantee as a fact; test/widget/navigation/peeking_lock_test.dart is
/// what makes that fact true.
void main() {
  late ProviderContainer container;
  setUp(() async => container = await _makeContainer());
  tearDown(() => container.dispose());

  testWidgets('Peeking prevention is stated as always on, not as a control',
      (tester) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('When on'), findsNothing);
    expect(find.textContaining('Applies to new sessions'), findsNothing);
    expect(find.textContaining('Always on'), findsOneWidget);

    final row = tester.widget<ListTile>(find.ancestor(
        of: find.text('Peeking prevention'), matching: find.byType(ListTile)));
    expect(row.onTap, isNull);
    expect(row.trailing, isNull,
        reason: 'no padlock or switch dressed as a setting');
  });
}
