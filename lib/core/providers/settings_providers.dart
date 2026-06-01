import 'package:flutter_riverpod/flutter_riverpod.dart';
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
