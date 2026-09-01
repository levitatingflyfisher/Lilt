import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/app/router.dart' show handOffToPartner;
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/ranking.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'matchup_notifier.dart';
import 'package:openhearth_design/openhearth_design.dart';

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
        actions: [OhBarActions(children: [
          state.when(
            data: (s) => OhBarAction(
              icon: Icons.undo,
              label: 'Undo',
              onPressed: s.matchCount > 0
                  ? () =>
                      ref.read(matchupProvider(sessionId).notifier).undo()
                  : null,
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ])],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => OhErrorState.fromError(e,
              stackTrace: st,
              title: 'Couldn’t load this session',
              message: 'Your comparisons so far are saved. Try again, or go '
                  'back and reopen the session.',
              icon: Icons.error_outline,
              onRetry: () => ref.invalidate(matchupProvider(sessionId))),
          data: (s) => _MatchupBody(
            sessionId: sessionId,
            state: s,
            partnerASessionId: partnerASessionId,
          ),
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

  void _record(WidgetRef ref, ComparisonOutcome outcome) {
    final pair = state.next;
    if (pair == null) return;
    ref.read(matchupProvider(sessionId).notifier).record(
          pair.firstId,
          pair.secondId,
          outcome,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposal = state.next;

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
                    _record(ref, ComparisonOutcome.bWins);
                  } else if (details.primaryVelocity! > 300) {
                    _record(ref, ComparisonOutcome.aWins);
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
                          key: const Key('name-card-a'),
                          display: state.idToDisplay[proposal.firstId] ??
                              _fallbackDisplay(proposal.firstId),
                          onTap: () => _record(ref, ComparisonOutcome.aWins),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _NameCard(
                          key: const Key('name-card-b'),
                          display: state.idToDisplay[proposal.secondId] ??
                              _fallbackDisplay(proposal.secondId),
                          onTap: () => _record(ref, ComparisonOutcome.bWins),
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
                    onPressed: () => _record(ref, ComparisonOutcome.tie),
                    child: const Text('Tie'),
                  ),
                  OutlinedButton(
                    onPressed: () => _record(ref, ComparisonOutcome.tie),
                    style: OutlinedButton.styleFrom(
                      // De-emphasized but ENABLED: use the secondary-text
                      // role. `outline` is a border token — under the
                      // openhearth_design grammar it resolves to linen300,
                      // unreadable as text on the linen background.
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    child: const Text('Don’t care'),
                  ),
                  TextButton(
                    onPressed: () => _record(ref, ComparisonOutcome.skip),
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
                    // Partner B finishing with A already done is the moment
                    // the couple flow exists for: go to the reveal.
                    final partnerA = partnerASessionId;
                    final aDone = partnerA != null &&
                        ((await sessionRepo.getSession(partnerA))
                                ?.isComplete ??
                            false);
                    if (!context.mounted) return;
                    ref.invalidate(allSessionsProvider);
                    context.pushReplacement(aDone
                        ? '/results/couple?a=$partnerA&b=$sessionId'
                        : '/results/solo/$sessionId');
                  },
                  label: const Text('I’m done, see results'),
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

  const _NameCard({super.key, required this.display, required this.onTap});

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
                  fontWeight: FontWeight.w400,
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

  Future<void> _completeAndGo(String route) async {
    if (!await _complete()) return;
    if (!mounted) return;
    context.pushReplacement(route);
  }

  Future<void> _completeAndHandOff() async {
    if (!await _complete()) return;
    if (!mounted) return;
    handOffToPartner(context, widget.sessionId);
  }

  Future<bool> _complete() async {
    if (_navigating) return false;
    setState(() => _navigating = true);
    final sessionRepo = ref.read(sessionRepositoryProvider);
    await sessionRepo.markComplete(widget.sessionId);
    if (!mounted) return false;
    ref.invalidate(allSessionsProvider);
    return true;
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
            Text('You’re done.',
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
                    : _completeAndHandOff,
                child: const Text('Pass Phone to Partner'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
