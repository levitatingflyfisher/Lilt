import 'package:elo_engine/elo_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/name.dart';
import 'package:lilt/domain/models/name_session.dart';
import 'package:share_plus/share_plus.dart' show Share;

final _soloResultsProvider =
    FutureProvider.family<_SoloResultsData, String>((ref, sessionId) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final namesRepo = ref.watch(namesRepositoryProvider);
  final session = await sessionRepo.getSession(sessionId);
  if (session == null) throw StateError('Session not found');
  final engine = await sessionRepo.buildEngine(sessionId);
  final names = await namesRepo.getByIds(session.poolIds);
  final nameMap = {for (final n in names) n.id: n};
  final ranked =
      engine.rankings.map((i) => nameMap[i.id]).whereType<Name>().toList();
  return _SoloResultsData(names: ranked, engine: engine, session: session);
});

class _SoloResultsData {
  final List<Name> names;
  final EloEngine engine;
  final NameSession session;
  const _SoloResultsData(
      {required this.names, required this.engine, required this.session});
}

class SoloResultsScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const SoloResultsScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SoloResultsScreen> createState() => _SoloResultsScreenState();
}

class _SoloResultsScreenState extends ConsumerState<SoloResultsScreen> {
  bool _showNerdyMode = false;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(_soloResultsProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Rankings'),
        actions: [
          data.whenData((d) => IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => _share(d.names),
                  )).valueOrNull ??
              const SizedBox.shrink(),
        ],
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (d) => _SoloResultsBody(
          data: d,
          showNerdyMode: _showNerdyMode,
          onToggleNerdy: () =>
              setState(() => _showNerdyMode = !_showNerdyMode),
          onPassToPartner: () => context
              .push('/pool-config?partnerB=1&partnerA=${widget.sessionId}'),
        ),
      ),
    );
  }

  void _share(List<Name> names) {
    final top10 = names.take(10).map((n) => n.display).join('\n');
    Share.share('My top 10 names:\n$top10');
  }
}

class _SoloResultsBody extends StatelessWidget {
  final _SoloResultsData data;
  final bool showNerdyMode;
  final VoidCallback onToggleNerdy;
  final VoidCallback onPassToPartner;

  const _SoloResultsBody({
    required this.data,
    required this.showNerdyMode,
    required this.onToggleNerdy,
    required this.onPassToPartner,
  });

  @override
  Widget build(BuildContext context) {
    if (data.names.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No rankings yet.',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.people_outline),
                label: const Text('Pass to Partner'),
                onPressed: onPassToPartner,
              ),
            ],
          ),
        ),
      );
    }

    final maxRating = data.engine.rankings.first.rating;
    final minRating = data.engine.rankings.last.rating;
    final ratingSpan = maxRating - minRating;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.people_outline),
          label: const Text('Pass to Partner'),
          onPressed: onPassToPartner,
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < data.names.length; i++) ...[
          RankedNameTile(
            rank: i + 1,
            name: data.names[i],
            barFraction: ratingSpan > 0
                ? (data.engine.rankings[i].rating - minRating) / ratingSpan
                : 1.0,
            isTopTen: i < 10,
          ),
        ],
        const SizedBox(height: 24),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show methodology'),
          trailing:
              Switch(value: showNerdyMode, onChanged: (_) => onToggleNerdy()),
        ),
        if (showNerdyMode)
          _NerdyModeWidget(engine: data.engine, names: data.names),
      ],
    );
  }
}

@visibleForTesting
class RankedNameTile extends StatelessWidget {
  final int rank;
  final Name name;
  final double barFraction;
  final bool isTopTen;

  const RankedNameTile({
    super.key,
    required this.rank,
    required this.name,
    required this.barFraction,
    required this.isTopTen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$rank',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.display,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight:
                        isTopTen ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: barFraction,
                    minHeight: 4,
                    color: isTopTen
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NerdyModeWidget extends StatefulWidget {
  final EloEngine engine;
  final List<Name> names;
  const _NerdyModeWidget({required this.engine, required this.names});

  @override
  State<_NerdyModeWidget> createState() => _NerdyModeWidgetState();
}

class _NerdyModeWidgetState extends State<_NerdyModeWidget> {
  late final _comparison = widget.engine.compareAlgorithms();

  @override
  Widget build(BuildContext context) {
    final nameMap = {for (final n in widget.names) n.id: n.display};
    final tau = _comparison.interAlgorithmKendallTau;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('Algorithm Agreement',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          "Kendall's \u03c4 across 15 algorithms: ${tau.toStringAsFixed(2)}."
          ' ${tau > 0.9 ? "High confidence." : tau > 0.7 ? "Moderate agreement." : "Your preferences are nuanced \u2014 hold rankings loosely."}',
        ),
        const SizedBox(height: 12),
        if ((_comparison.serialRank?.rankability ?? 1.0) < 0.6) ...[
          Text('Note', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          const Text(
            'Your preferences in this pool are less linear than average. '
            'The rankings are a good guide but hold them loosely.',
          ),
          const SizedBox(height: 12),
        ],
        if ((_comparison.matrixFactorization?.bestRank ?? 1) >= 2) ...[
          Text('Two Dimensions Detected',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          const Text(
            'Your preferences have two distinct dimensions. '
            'See the top names in each cluster \u2014 you may find a pattern.',
          ),
          const SizedBox(height: 12),
        ],
        if ((_comparison.hodge?.cyclicMagnitude ?? 0.0) > 0.05) ...[
          Text('Preference Cycles',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Cycle strength: ${((_comparison.hodge!.cyclicMagnitude) * 100).toStringAsFixed(0)}% '
            '— some names are genuinely hard to rank against each other.',
          ),
          const SizedBox(height: 4),
          ..._comparison.divergences
              .where((d) =>
                  d.rankSpread > 5 &&
                  _hasInvertedRanks(d.rankByAlgorithm))
              .take(4)
              .map((d) => Text(
                    '  • ${nameMap[d.item.id] ?? d.item.id}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
          const SizedBox(height: 12),
        ],
        Text('Top Disagreements',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        ..._comparison.divergences
            .where((d) => d.rankSpread > 3)
            .take(5)
            .map((d) {
          final name = nameMap[d.item.id] ?? d.item.id;
          final ranks = d.rankByAlgorithm.values.toList()..sort();
          final best = ranks.first + 1; // 0-indexed → 1-indexed
          final worst = ranks.last + 1;
          final entries = d.rankByAlgorithm.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value));
          final bestAlgo = _algoShortName(entries.first.key);
          final worstAlgo = _algoShortName(entries.last.key);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name: ranked #$best ($bestAlgo) to #$worst ($worstAlgo)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '${d.rankByAlgorithm.length} algorithms disagree by ${d.rankSpread} ranks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Short display name for an algorithm.
  static String _algoShortName(AlgorithmId id) => switch (id) {
        AlgorithmId.elo => 'Elo',
        AlgorithmId.glicko2 => 'Glicko-2',
        AlgorithmId.bradleyTerry => 'Bradley-Terry',
        AlgorithmId.trueskill => 'TrueSkill',
        AlgorithmId.thurstone => 'Thurstone',
        AlgorithmId.springRank => 'SpringRank',
        AlgorithmId.pageRank => 'PageRank',
        AlgorithmId.markov => 'Markov',
        AlgorithmId.copeland => 'Copeland',
        AlgorithmId.schulze => 'Schulze',
        AlgorithmId.rankedPairs => 'Ranked Pairs',
        AlgorithmId.borda => 'Borda',
        AlgorithmId.hodge => 'Hodge',
        AlgorithmId.serialRank => 'SerialRank',
        AlgorithmId.matrixFactorization => 'MatrixFact',
      };

  /// Heuristic: do pairwise algorithms put this item in opposite ends?
  static bool _hasInvertedRanks(Map<AlgorithmId, int> rankByAlgorithm) {
    if (rankByAlgorithm.length < 3) return false;
    final sorted = rankByAlgorithm.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final bestAlgo = sorted.first.key;
    final worstAlgo = sorted.last.key;
    const ratingBased = {
      AlgorithmId.elo,
      AlgorithmId.glicko2,
      AlgorithmId.bradleyTerry,
      AlgorithmId.trueskill,
      AlgorithmId.thurstone,
    };
    return ratingBased.contains(bestAlgo) != ratingBased.contains(worstAlgo);
  }
}
