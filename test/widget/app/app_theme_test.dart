import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/app.dart';
import 'package:lilt/core/providers/bootstrap_provider.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:lilt/services/database/database.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lilt's app-signature accent — the taupe that used to live inline in
/// app.dart as a bare colorSchemeSeed.
const Color _liltTaupe = Color(0xFF8B6F47);

/// Pumps the real [LiltApp] with the same provider overrides as the startup
/// maintenance test (bootstrap short-circuited; everything backup-related
/// faked) and returns the [MaterialApp] it builds.
Future<MaterialApp> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        bootstrapProvider.overrideWith((ref) async {}),
        secureKeyStoreProvider.overrideWithValue(InMemorySecureKeyStore()),
        cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
        sanctuaryAppDomainProvider.overrideWithValue('lilt'),
        sanctuaryBackupConfigProvider.overrideWithValue(
          const SanctuaryBackupConfig(
            appId: 'lilt',
            aadContext: 'lilt-backup/v1',
            appDisplayName: 'Lilt',
          ),
        ),
        backupSerializerProvider.overrideWith((ref) => LiltBackupSerializer(db)),
        vaultStoreProvider.overrideWithValue(InMemoryVaultStore()),
      ],
      child: const LiltApp(),
    ),
  );
  await tester.pumpAndSettle();
  return tester.widget<MaterialApp>(find.byType(MaterialApp));
}

void main() {
  testWidgets(
      'LiltApp ships a dark theme and follows the system brightness '
      '(grammar adoption: tier-F)', (tester) async {
    final app = await _pumpApp(tester);

    expect(app.darkTheme, isNotNull,
        reason: 'Lilt must gain its missing dark theme');
    expect(app.themeMode, ThemeMode.system,
        reason: 'dark mode must follow the OS setting');
  });

  testWidgets(
      'both themes derive from the canonical openhearth_design grammar '
      'with the taupe app accent', (tester) async {
    final app = await _pumpApp(tester);

    final light = app.theme!;
    final dark = app.darkTheme!;

    // Distinctive OhTheme.light surfaces: warm linen, not a Material
    // seed-derived neutral.
    expect(light.scaffoldBackgroundColor, OhColors.linen50,
        reason: 'light theme must be OhTheme.light (linen scaffold)');
    expect(light.colorScheme.surface, OhColors.linen100,
        reason: 'light theme must carry the linen card surface');

    // Distinctive OhTheme.hearthDark surfaces: warm brown-black family.
    expect(dark.scaffoldBackgroundColor, OhColors.darkSurfaceBase,
        reason: 'dark theme must be OhTheme.hearthDark (brown-black base)');
    expect(dark.colorScheme.surface, OhColors.darkSurfaceCard,
        reason: 'dark theme must carry the hearth-dark card surface');

    // Lilt's signature accent survives grammar adoption in both themes.
    expect(light.colorScheme.primary, _liltTaupe);
    expect(dark.colorScheme.primary, _liltTaupe);

    // The grammar's faces, not the stock Material ladder.
    expect(light.textTheme.displayLarge!.fontFamily, 'Lora');
    expect(light.textTheme.bodyMedium!.fontFamily, 'Nunito');
    expect(dark.textTheme.displayLarge!.fontFamily, 'Lora');
  });
}
