import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/app/theme.dart';
import 'package:openhearth_design/openhearth_design.dart';

/// design-for-hackers-01: the PWA shipped Flutter's template shell ("A new
/// Flutter project.", theme #0175C2, name "lilt"), which is what a browser
/// shows on install and in the tab. deploy-pwa.sh refuses the template
/// strings; this pins the real ones, and ties the colours to the theme.
String _hex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

void main() {
  final manifest = jsonDecode(File('web/manifest.json').readAsStringSync())
      as Map<String, dynamic>;
  final index = File('web/index.html').readAsStringSync();

  test('no Flutter template text anywhere in the shell', () {
    for (final text in [jsonEncode(manifest), index]) {
      expect(text, isNot(contains('A new Flutter project')));
      expect(text.toUpperCase(), isNot(contains('#0175C2')));
    }
  });

  test('the manifest names and describes Lilt', () {
    expect(manifest['name'], 'Lilt');
    expect(manifest['short_name'], 'Lilt');
    expect(manifest['description'], contains('baby name'));
  });

  test('the shell colours are the app theme colours', () {
    expect(manifest['theme_color'], _hex(LiltTheme.accent.toARGB32()));
    expect(manifest['background_color'], _hex(OhColors.linen50.toARGB32()));
  });

  test('index.html carries the same name and description', () {
    expect(index, contains('<title>Lilt</title>'));
    expect(index, contains('content="${manifest['description']}"'));
    expect(index, contains('apple-mobile-web-app-title" content="Lilt"'));
    expect(index,
        contains('<meta name="theme-color" content="${manifest['theme_color']}">'));
  });
}
