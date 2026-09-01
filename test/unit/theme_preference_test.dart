import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme ruling: light, dark or follow the phone, default follow the phone,
/// one tap (at most two) away. Lilt never stored a theme choice before (it
/// always followed the system), so there is no legacy value to migrate:
/// nothing stored means follow the phone.
Future<ProviderContainer> _container(Map<String, Object> stored) async {
  SharedPreferences.setMockInitialValues(stored);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('nothing stored follows the phone', () async {
    final c = await _container({});
    expect(c.read(themePreferenceProvider), OhThemeModePreference.system);
    expect(c.read(themePreferenceProvider).themeMode, ThemeMode.system);
  });

  test('a choice is kept across launches', () async {
    final c = await _container({});
    await c
        .read(themePreferenceProvider.notifier)
        .set(OhThemeModePreference.dark);
    expect(c.read(themePreferenceProvider), OhThemeModePreference.dark);

    final prefs = c.read(sharedPreferencesProvider);
    final again = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(again.dispose);
    expect(again.read(themePreferenceProvider), OhThemeModePreference.dark);
  });

  test('an unknown stored value falls back to following the phone',
      () async {
    final c = await _container({themePreferenceKey: 'sepia'});
    expect(c.read(themePreferenceProvider), OhThemeModePreference.system);
  });
}
