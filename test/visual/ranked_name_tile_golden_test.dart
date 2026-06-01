import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/domain/models/name.dart';
import 'package:lilt/features/results/solo_results_screen.dart'
    show RankedNameTile;

import 'visual_golden_helper.dart';

/// Visual golden coverage for the real `RankedNameTile`
/// (lib/features/results/solo_results_screen.dart).
///
/// The widget is exported via `@visibleForTesting`, so this exercises the
/// shipped ranking row directly (rank number, bolded top-ten name, the
/// progress-bar "score" indicator) — no copy that can drift. It is a plain
/// StatelessWidget, so no Riverpod/DB is needed.
void main() {
  // Mirrors the real app theme (lib/app/app.dart).
  final theme = ThemeData(
    colorSchemeSeed: const Color(0xFF8B6F47),
    useMaterial3: true,
  );

  // Render two rows: a #1 top-ten name (full bar, bold, primary colour) and a
  // mid-pack name (partial bar, normal weight, secondary colour) so both
  // styling branches are captured.
  const alice = Name(
    id: 'alice-f',
    display: 'Alice',
    gender: NameGender.female,
  );
  const maximilian = Name(
    id: 'maximilian-m',
    display: 'Maximilian',
    gender: NameGender.male,
  );

  testWidgets('RankedNameTile renders across sizes and text scales',
      (tester) async {
    await goldenAtSizes(
      tester,
      name: 'ranked_name_tile',
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                RankedNameTile(
                  rank: 1,
                  name: alice,
                  barFraction: 1.0,
                  isTopTen: true,
                ),
                SizedBox(height: 8),
                RankedNameTile(
                  rank: 14,
                  name: maximilian,
                  barFraction: 0.35,
                  isTopTen: false,
                ),
              ],
            ),
          ),
        ),
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
