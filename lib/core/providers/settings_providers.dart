import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initialized in main.dart before runApp.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

const _tauKey = 'convergence_tau';
const defaultTau = 0.90;

/// Current convergence tau setting. Reads from SharedPreferences.
final convergenceTauProvider = Provider<double>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getDouble(_tauKey) ?? defaultTau;
});

/// Where the theme choice is stored. Lilt stored no theme before this key
/// (it always followed the system), so there is nothing older to migrate.
const themePreferenceKey = 'lilt.themeMode';

/// Light, dark or follow the phone (the default), per the fleet theme
/// ruling. Switched from the app bar's OhThemeToggle.
final themePreferenceProvider =
    NotifierProvider<ThemePreferenceNotifier, OhThemeModePreference>(
        ThemePreferenceNotifier.new);

class ThemePreferenceNotifier extends Notifier<OhThemeModePreference> {
  @override
  OhThemeModePreference build() => OhThemeModePreference.fromStorage(
      ref.watch(sharedPreferencesProvider).getString(themePreferenceKey));

  Future<void> set(OhThemeModePreference value) async {
    state = value;
    await ref
        .read(sharedPreferencesProvider)
        .setString(themePreferenceKey, value.storageValue);
  }
}
