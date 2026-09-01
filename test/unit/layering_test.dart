import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// AGENTS.md and VISION invariant 5: the UI never touches the ranking
/// engine. Exactly one file imports elo_engine (the session repository),
/// and no screen or notifier rebuilds an engine itself.
void main() {
  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .toList();

  test('exactly one file imports elo_engine', () {
    final importers = [
      for (final f in dartFiles)
        if (f.readAsStringSync().contains("package:elo_engine/")) f.path,
    ];
    expect(importers, ['lib/domain/repositories/session_repository.dart']);
  });

  test('no feature builds an engine; they read domain models', () {
    final callers = [
      for (final f in dartFiles)
        if (f.path.startsWith('lib/features/') &&
            f.readAsStringSync().contains('buildEngine('))
          f.path,
    ];
    expect(callers, isEmpty);
  });
}
