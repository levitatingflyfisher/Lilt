import 'package:flutter/material.dart';
import 'package:openhearth_design/openhearth_design.dart';

/// Lilt's theming, built on the shared OpenHearth design grammar.
///
/// The grammar (surfaces, type ladder, component shapes) comes from
/// `openhearth_design`; Lilt contributes only its signature accent. This is
/// how the app gained dark mode: `OhTheme.hearthDark` arrives with the
/// grammar rather than being hand-rolled here.
abstract final class LiltTheme {
  /// Lilt's app-signature accent — the warm taupe that has seeded the app's
  /// color scheme since v1 (previously an inline `colorSchemeSeed`).
  static const Color accent = Color(0xFF8B6F47);

  /// Daytime theme: taupe on warm linen.
  static ThemeData light() => OhTheme.light(appAccent: accent);

  /// Evening theme: taupe on the hearth family's brown-black surfaces.
  static ThemeData dark() => OhTheme.hearthDark(appAccent: accent);
}
