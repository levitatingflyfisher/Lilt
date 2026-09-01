import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// openhearth_design ships Lora 400/400i/500/700 and Nunito 400/500/600/700
/// only. A lighter weight has no face, so the engine synthesises or falls
/// back and the type drawn is not the type designed (design-for-hackers-10:
/// Lora was requested at 300 with no 300 bundled).
void main() {
  test('lib/ never asks for a font weight lighter than the bundled 400', () {
    final light = RegExp(r'FontWeight\.w[1-3]00');
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (light.hasMatch(lines[i])) offenders.add('${f.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty,
        reason: 'no bundled face for these weights: $offenders');
  });

  // design-for-hackers-03/-04: sizes come from the one type ladder
  // (openhearth_design's text theme). A literal size is off the ladder.
  test('lib/ never sets a literal font size', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('fontSize:')) offenders.add('${f.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty, reason: 'off the type ladder: $offenders');
  });
}
