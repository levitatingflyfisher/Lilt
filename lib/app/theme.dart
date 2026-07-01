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

  /// The dark-tuned accent: the same ~36° taupe hue, lightened until both
  /// of the roles dark mode paints it in clear WCAG AA (computed in
  /// `test/widget/app/theme_contrast_test.dart`). The light-tuned [accent]
  /// passed straight into `OhTheme.hearthDark` left button labels
  /// (`linen900` on taupe) at 3.58:1 and accent text on the brown-black
  /// card at 3.56:1; this variant sits at ~7.5:1 for both.
  static const Color accentDark = Color(0xFFC9A876);

  /// Daytime theme: taupe on warm linen.
  static ThemeData light() => OhTheme.light(appAccent: accent);

  /// Evening theme: the dark-tuned taupe on the hearth family's brown-black
  /// surfaces.
  static ThemeData dark() => OhTheme.hearthDark(appAccent: accentDark);
}
