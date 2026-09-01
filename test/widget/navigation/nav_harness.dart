import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/domain/models/ranking.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/session_repository.dart';
import 'package:lilt/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:lilt/services/database/database.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real-router harness for navigation tests: in-memory Drift, the app's own
/// [routerProvider] (so route redirects run exactly as they ship).
class NavHarness {
  final AppDatabase db;
  final ProviderContainer container;
  final SessionRepository sessions;
  NavHarness._(this.db, this.container, this.sessions);

  static const names = ['Alexander', 'Beatrice', 'Cyrus', 'Delphine'];
  static String idOf(String display) => '${display.toLowerCase()}-n';
  static List<String> get poolIds => names.map(idOf).toList();

  static Future<NavHarness> create() async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.namesDao.insertNames([
      for (final n in names)
        NameEntriesCompanion.insert(
            id: idOf(n), display: n, gender: 'n', variants: '[]'),
    ]);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(prefs),
      // Backup wiring faked in memory, so Settings (and Home's Finish
      // setup line) settle without a platform channel.
      secureKeyStoreProvider.overrideWithValue(InMemorySecureKeyStore()),
      cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
      sanctuaryAppDomainProvider.overrideWithValue('lilt'),
      sanctuaryBackupConfigProvider.overrideWithValue(
        const SanctuaryBackupConfig(
            appId: 'lilt', aadContext: 'lilt-backup/v1', appDisplayName: 'Lilt'),
      ),
      backupSerializerProvider.overrideWith((ref) => LiltBackupSerializer(db)),
      vaultStoreProvider.overrideWithValue(InMemoryVaultStore()),
      backupReminderStoreProvider
          .overrideWithValue(InMemoryBackupReminderStore()),
    ]);
    final sessions = SessionRepository(
        db.sessionDao, db.eloMatchesDao, NamesRepository(db.namesDao));
    return NavHarness._(db, container, sessions);
  }

  /// A session over [poolIds] where earlier names beat later ones.
  Future<String> rankedSession(
      {String? label, bool complete = true}) async {
    final s = await sessions.createSession(
        participantLabel: label,
        poolIds: poolIds,
        genderFilter: 'all',
        poolSize: poolIds.length);
    await _rankAll(s.id);
    if (complete) await sessions.markComplete(s.id);
    return s.id;
  }

  Future<void> _rankAll(String sessionId) async {
    final ids = poolIds;
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        await sessions.recordMatch(
            sessionId: sessionId,
            idA: ids[i],
            idB: ids[j],
            outcome: ComparisonOutcome.aWins);
      }
    }
  }

  /// A couple as the app's hand-off builds it: Partner A ranks, then a
  /// persisted Partner B session is created from A's. [bRanked] leaves B's
  /// comparisons recorded (so B is at the "done" screen) but unmarked.
  Future<(String, String)> couple(
      {bool bRanked = true, bool bComplete = true}) async {
    final a = await rankedSession(label: 'Partner A');
    final b = await sessions.createPartnerSession(a);
    if (bRanked) await _rankAll(b.id);
    if (bComplete) await sessions.markComplete(b.id);
    return (a, b.id);
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
          routerConfig: container.read(routerProvider)),
    ));
    await settle(tester);
  }

  /// Drift work completes on real async; alternate real waits with pumps.
  static Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pumpAndSettle();
    }
  }

  Future<void> dispose() async {
    container.dispose();
    await db.close();
  }
}
