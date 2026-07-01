import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/providers/database_provider.dart';
import 'core/providers/settings_providers.dart';
import 'features/home/home_screen.dart';
import 'features/sanctuary_backup/data/backup_serializer.dart';
import 'features/shortlist/shortlist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Encrypted-backup wiring (sanctuary_backup_ui). Lilt is a new app,
        // so it gets its own isolated key material (appDomain 'lilt') and its
        // own AEAD context — no legacy-compat constraint like Lullaby's
        // (SANCTUARY-BRIEF §2.1, §2.3, §4.W2).
        sanctuaryAppDomainProvider.overrideWithValue('lilt'),
        sanctuaryBackupConfigProvider.overrideWithValue(
          SanctuaryBackupConfig(
            appId: 'lilt',
            aadContext: 'lilt-backup/v1',
            appDisplayName: 'Lilt',
            restoreReplaceConsequence:
                'Restoring will delete all custom names, ranking sessions, '
                'comparison history, and your shortlist on this device, then '
                'replace them with data from the backup file. The bundled '
                'name catalog is not affected.',
            // The list screens read via one-shot FutureProviders (not Drift
            // watch streams), so they do not self-refresh after a destructive
            // restore — invalidate them explicitly (scout-Lilt.md's
            // invalidation set: home's session list + the shortlist).
            onAfterRestore: (ref) {
              ref.invalidate(allSessionsProvider);
              ref.invalidate(shortlistEntriesProvider);
            },
          ),
        ),
        backupSerializerProvider.overrideWith(
          (ref) => LiltBackupSerializer(ref.watch(databaseProvider)),
        ),
      ],
      child: const LiltApp(),
    ),
  );
}
