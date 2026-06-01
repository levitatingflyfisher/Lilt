import 'package:elo_engine/elo_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/features/matchup/matchup_notifier.dart';
import 'package:lilt/features/matchup/matchup_screen.dart' show ConvergenceBar;

import 'visual_golden_helper.dart';

/// Visual golden coverage for the real `ConvergenceBar`
/// (lib/features/matchup/matchup_screen.dart).
///
/// The widget is exported via `@visibleForTesting`, so this exercises the
/// shipped widget directly — no copy that can drift. It only needs a
/// [MatchupState], which we build from a tiny in-memory [EloEngine] (no DB,
/// no Riverpod required).
void main() {
  // Mirrors the real app theme (lib/app/app.dart).
  final theme = ThemeData(
    colorSchemeSeed: const Color(0xFF8B6F47),
    useMaterial3: true,
  );

  // A mid-progress, not-yet-converged state. `progressLabel` renders
  // "Match 5 of ~12" and the bar fills to ~0.42.
  final engine = EloEngine(
    items: [EloItem(id: 'a-m'), EloItem(id: 'b-m'), EloItem(id: 'c-m')],
  );
  final state = MatchupState(
    engine: engine,
    nextMatch: engine.nextMatch(),
    isConverged: false,
    matchCount: 5,
    estimatedTarget: 12,
    idToDisplay: const {'a-m': 'Alpha', 'b-m': 'Beta', 'c-m': 'Charlie'},
  );

  testWidgets('ConvergenceBar renders across sizes and text scales',
      (tester) async {
    await goldenAtSizes(
      tester,
      name: 'convergence_bar',
      home: Scaffold(
        body: SafeArea(child: ConvergenceBar(state: state)),
      ),
      sizes: const <String, Size>{
        'phone': Size(360, 800),
        'narrow': Size(320, 800),
      },
      textScales: const <double>[1.0, 3.0],
      theme: theme,
    );
  });
}
