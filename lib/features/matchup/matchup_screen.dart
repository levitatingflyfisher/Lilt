import 'package:elo_engine/elo_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'matchup_notifier.dart';

class MatchupScreen extends ConsumerWidget {
  final String sessionId;
  final String? partnerASessionId;

  const MatchupScreen({
    super.key,
    required this.sessionId,
    this.partnerASessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchupProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lilt'),
        actions: [
          state.when(
            data: (s) => IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: s.matchCount > 0
                  ? () =>
                      ref.read(matchupProvider(sessionId).notifier).undo()
                  : null,
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (s) => _MatchupBody(
          sessionId: sessionId,
          state: s,
          partnerASessionId: partnerASessionId,
        ),
      ),
    );
  }
}

class _MatchupBody extends ConsumerWidget {
  final String sessionId;
  final MatchupState state;
  final String? partnerASessionId;

  const _MatchupBody({
    required this.sessionId,
    required this.state,
    this.partnerASessionId,
  });

  /// Extract display name from ID, stripping the trailing gender code.
  static String _fallbackDisplay(String id) {
    final lastDash = id.lastIndexOf('-');
    if (lastDash < 0) return id;
    return id.substring(0, lastDash);
  }

  void _record(WidgetRef ref, MatchOutcome outcome) {
    final proposal = state.nextMatch;
    if (proposal == null) return;
    ref.read(matchupProvider(sessionId).notifier).record(
          proposal.itemA.id,
          proposal.itemB.id,
          outcome,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposal = state.nextMatch;

    if (proposal == null || state.isConverged) {
      return _ConvergedView(
        sessionId: sessionId,
        state: state,
        partnerASessionId: partnerASessionId,
      );
    }

    return Column(
      children: [
        ConvergenceBar(state: state),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! < -300) {
                    _record(ref, MatchOutcome.bWins);
                  } else if (details.primaryVelocity! > 300) {
                    _record(ref, MatchOutcome.aWins);
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _NameCard(
                          display: state.idToDisplay[proposal.itemA.id] ??
                              _fallbackDisplay(proposal.itemA.id),
                          onTap: () => _record(ref, MatchOutcome.aWins),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _NameCard(
                          display: state.idToDisplay[proposal.itemB.id] ??
                              _fallbackDisplay(proposal.itemB.id),
                          onTap: () => _record(ref, MatchOutcome.bWins),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _record(ref, MatchOutcome.tie),
                    child: const Text('Tie'),
                  ),
                  OutlinedButton(
                    onPressed: () => _record(ref, MatchOutcome.tie),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.outline,
                    ),
                    child: const Text("Don't care"),
                  ),
                  TextButton(
                    onPressed: () => _record(ref, MatchOutcome.skip),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              if (state.canExitEarly) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  onPressed: () async {
                    final sessionRepo =
                        ref.read(sessionRepositoryProvider);
                    await sessionRepo.markComplete(sessionId);
                    if (!context.mounted) return;
                    ref.invalidate(allSessionsProvider);
                    context.pushReplacement('/results/solo/$sessionId');
                  },
                  label: const Text("I'm done — see results"),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Name card — large typography, warm tonal card, auto-scaling text.
class _NameCard extends StatelessWidget {
  final String display;
  final VoidCallback onTap;

  const _NameCard({required this.display, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                display,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Battery-style convergence indicator.
@visibleForTesting
class ConvergenceBar extends StatelessWidget {
  final MatchupState state;
  const ConvergenceBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: state.progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 6),
          Text(
            state.progressLabel,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Shown when the session has converged or all pairs exhausted.
class _ConvergedView extends ConsumerStatefulWidget {
  final String sessionId;
  final MatchupState state;
  final String? partnerASessionId;

  const _ConvergedView({
    required this.sessionId,
    required this.state,
    this.partnerASessionId,
  });

  @override
  ConsumerState<_ConvergedView> createState() => _ConvergedViewState();
}

class _ConvergedViewState extends ConsumerState<_ConvergedView> {
  bool _navigating = false;

  Future<void> _completeAndGo(String route, {bool replace = true}) async {
    if (_navigating) return;
    setState(() => _navigating = true);
    final sessionRepo = ref.read(sessionRepositoryProvider);
    await sessionRepo.markComplete(widget.sessionId);
    if (!mounted) return;
    ref.invalidate(allSessionsProvider);
    if (replace) {
      context.pushReplacement(route);
    } else {
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = widget.sessionId;
    final partnerASessionId = widget.partnerASessionId;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You're done — but keep refining if you want.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 32),

            // If this is Partner B, show "See Results Together"
            if (partnerASessionId != null) ...[
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondary),
                onPressed: _navigating
                    ? null
                    : () => _completeAndGo(
                        '/results/couple?a=$partnerASessionId&b=$sessionId'),
                child: const Text('See Results Together'),
              ),
              const SizedBox(height: 12),
            ],

            FilledButton(
              onPressed: _navigating
                  ? null
                  : () => _completeAndGo('/results/solo/$sessionId'),
              child: const Text('See My Results'),
            ),

            // "Pass Phone to Partner" — only for solo/Partner A
            if (partnerASessionId == null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _navigating
                    ? null
                    : () => _completeAndGo(
                        '/pool-config?partnerB=1&partnerA=$sessionId',
                        replace: false),
                child: const Text('Pass Phone to Partner'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
