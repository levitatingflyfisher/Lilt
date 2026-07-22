import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/theme.dart';
import 'package:lilt/core/providers/database_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/session_repository.dart';
import 'package:lilt/features/matchup/matchup_screen.dart';
import 'package:lilt/services/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The "Don't care" action is deliberately de-emphasized, but it is an
/// ENABLED, tappable button — its label must use the secondary-text role
/// (`onSurfaceVariant`), not the `outline` border token. Under the old
/// seed-derived scheme `outline` happened to resolve to a readable gray;
/// under the openhearth_design grammar `outline` is linen300, a border
/// color that is unreadable as text on the linen background (~1.9:1).
///
/// Swept over BOTH app themes: dark mode has its own scheme (linen300
/// text on brown-black, darkBorderDefault outlines), so light-only
/// coverage would let a dark-mode regression through.
void main() {
  final themes = <String, ThemeData Function()>{
    'light': LiltTheme.light,
    'dark': LiltTheme.dark,
  };

  for (final MapEntry<String, ThemeData Function()> entry in themes.entries) {
    testWidgets("Don't care label uses the secondary-text role, not the "
        'outline border token (${entry.key})', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.namesDao.insertNames([
        NameEntriesCompanion.insert(
          id: 'a-m',
          display: 'Alexander',
          gender: 'm',
          variants: '[]',
        ),
        NameEntriesCompanion.insert(
          id: 'b-m',
          display: 'Benjamin',
          gender: 'm',
          variants: '[]',
        ),
        NameEntriesCompanion.insert(
          id: 'c-m',
          display: 'Charlie',
          gender: 'm',
          variants: '[]',
        ),
      ]);
      final namesRepo = NamesRepository(db.namesDao);
      final sessionRepo = SessionRepository(
        db.sessionDao,
        db.eloMatchesDao,
        namesRepo,
      );
      final session = await sessionRepo.createSession(
        poolIds: ['a-m', 'b-m', 'c-m'],
        genderFilter: 'm',
        poolSize: 3,
      );

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final theme = entry.value();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            theme: theme,
            home: MatchupScreen(sessionId: session.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, "Don't care"),
      );
      final fg = button.style!.foregroundColor!.resolve(<WidgetState>{});
      expect(
        fg,
        theme.colorScheme.onSurfaceVariant,
        reason:
            'enabled button text must be readable — the secondary-text '
            'role, not the border token',
      );
      expect(fg, isNot(theme.colorScheme.outline));
    });
  }
}
