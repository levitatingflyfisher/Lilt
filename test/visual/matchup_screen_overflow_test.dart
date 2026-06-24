import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/session_repository.dart';
import 'package:lilt/features/matchup/matchup_notifier.dart';
import 'package:lilt/features/matchup/matchup_screen.dart';
import 'package:lilt/services/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression: the matchup action row ("Tie / Don't care / Skip") overflowed
/// 72px horizontally at a narrow width (320dp) with large accessibility text
/// (textScale 3.0). Asserts no layout exception at that worst-case combination.
Future<(AppDatabase, ProviderContainer, String)> _seed() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.namesDao.insertNames([
    NameEntriesCompanion.insert(
        id: 'a-m', display: 'Alexander', gender: 'm', variants: '[]'),
    NameEntriesCompanion.insert(
        id: 'b-m', display: 'Benjamin', gender: 'm', variants: '[]'),
    NameEntriesCompanion.insert(
        id: 'c-m', display: 'Charlie', gender: 'm', variants: '[]'),
  ]);
  final namesRepo = NamesRepository(db.namesDao);
  final sessionRepo =
      SessionRepository(db.sessionDao, db.eloMatchesDao, namesRepo);
  final session = await sessionRepo.createSession(
      poolIds: ['a-m', 'b-m', 'c-m'], genderFilter: 'm', poolSize: 3);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [
    databaseProvider.overrideWithValue(db),
    sharedPreferencesProvider.overrideWithValue(prefs),
  ]);
  return (db, container, session.id);
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late String sessionId;

  setUp(() async {
    (db, container, sessionId) = await _seed();
    await container.read(matchupProvider(sessionId).future);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  testWidgets('action row does not overflow at 320dp / textScale 3.0',
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
        child: MatchupScreen(sessionId: sessionId),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
