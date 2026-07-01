import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/theme.dart';

/// WCAG 2.x contrast for the roles Lilt actually paints its accent with.
///
/// The light-tuned taupe (#8B6F47) reads fine on linen, but passed
/// unchanged into `OhTheme.hearthDark` it becomes BOTH the filled-button
/// background under `linen900` labels (onPrimary-over-primary) and
/// accent text/outlines on the brown-black card surface
/// (primary-over-surface). Both pairings must clear WCAG AA for normal
/// text, 4.5:1 — computed here from the real [ThemeData], not eyeballed,
/// so a future accent tweak that regresses dark mode fails this test.
///
/// Contrast ratio per WCAG: (L_lighter + 0.05) / (L_darker + 0.05), with
/// relative luminance from [Color.computeLuminance] (the same sRGB
/// linearization WCAG 2.x specifies).
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('dark theme accent contrast (WCAG AA, 4.5:1)', () {
    final dark = LiltTheme.dark();
    final cs = dark.colorScheme;

    test('filled-button labels: onPrimary over primary', () {
      expect(
        _contrast(cs.onPrimary, cs.primary),
        greaterThanOrEqualTo(4.5),
        reason: 'dark-mode FilledButton paints onPrimary '
            '(${cs.onPrimary}) on primary (${cs.primary}) — button labels '
            'must clear WCAG AA for normal text',
      );
    });

    test('accent as text: primary over surface', () {
      expect(
        _contrast(cs.primary, cs.surface),
        greaterThanOrEqualTo(4.5),
        reason: 'dark-mode accent text/icons paint primary '
            '(${cs.primary}) on the card surface (${cs.surface}) — accent '
            'text must clear WCAG AA for normal text',
      );
    });
  });

  group('light theme accent contrast (guard: the fix is dark-only)', () {
    final light = LiltTheme.light();
    final cs = light.colorScheme;

    test('filled-button labels: onPrimary over primary', () {
      expect(_contrast(cs.onPrimary, cs.primary), greaterThanOrEqualTo(4.5));
    });

    test('light keeps the original v1 taupe seed', () {
      expect(cs.primary, const Color(0xFF8B6F47),
          reason: 'the light accent is Lilt\'s signature and already '
              'passes — only the dark theme needed a tuned variant');
    });
  });
}
