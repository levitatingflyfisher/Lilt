import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/app/router.dart' show handOffToPartner;
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/name.dart';
import 'package:lilt/domain/models/name_session.dart';
import 'package:lilt/domain/models/ranking.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:openhearth_design/openhearth_design.dart';
import 'package:lilt/app/theme_toggle.dart';

final _soloResultsProvider =
    FutureProvider.family<_SoloResultsData, String>((ref, sessionId) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final namesRepo = ref.watch(namesRepositoryProvider);
  final session = await sessionRepo.getSession(sessionId);
  if (session == null) throw StateError('Session not found');
  final ranking = await sessionRepo.ranking(sessionId);
  final names = await namesRepo.getByIds(session.poolIds);
  final nameMap = {for (final n in names) n.id: n};
  final ranked = ranking.ranked.where((r) => nameMap.containsKey(r.id));
  return _SoloResultsData(
    names: [for (final r in ranked) nameMap[r.id]!],
    ranked: ranked.toList(),
    session: session,
  );
});

/// Built only when "Show methodology" is switched on: the ensemble
/// comparison is the costly part.
final _methodologyProvider = FutureProvider.family<Methodology, String>(
    (ref, sessionId) =>
        ref.watch(sessionRepositoryProvider).methodology(sessionId));

class _SoloResultsData {
  final List<Name> names;

  /// Parallel to [names]: each name's place in the ranking.
  final List<RankedName> ranked;
  final NameSession session;
  const _SoloResultsData(
      {required this.names, required this.ranked, required this.session});
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
        actions: [OhBarActions(children: [
          data.whenData((d) => OhBarAction(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onPressed: () => _share(d.names),
                  )).valueOrNull ??
              const SizedBox.shrink(),
          const LiltThemeToggle(),
        ])],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => OhErrorState.fromError(e,
              stackTrace: st,
              title: 'Couldn’t load these rankings',
              icon: Icons.error_outline,
              onRetry: () =>
                  ref.invalidate(_soloResultsProvider(widget.sessionId))),
          data: (d) => _SoloResultsBody(
            data: d,
            showNerdyMode: _showNerdyMode,
            onToggleNerdy: () =>
                setState(() => _showNerdyMode = !_showNerdyMode),
            onPassToPartner: () => handOffToPartner(context, widget.sessionId),
          ),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.people_outline),
          label: const Text('Pass to Partner'),
          onPressed: onPassToPartner,
        ),
        const SizedBox(height: 16),
        // The bar's scale, said once: a fixed 0-100% with a true zero, so
        // bars compare across names and sessions (visual-display-01).
        Text(
          'Each bar is the chance of beating an average name in this pool.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < data.names.length; i++) ...[
          RankedNameTile(
            rank: i + 1,
            name: data.names[i],
            barFraction: data.ranked[i].winChance,
            isTopTen: i < 10,
            onTap: () => context
                .push('/name/${data.names[i].id}?a=${data.session.id}'),
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
          _NerdyModeWidget(sessionId: data.session.id, names: data.names),
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
  final VoidCallback? onTap;

  const RankedNameTile({
    super.key,
    required this.rank,
    required this.name,
    required this.barFraction,
    required this.isTopTen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The whole full-width row (~38dp tall) opens the name, so no precision
    // is needed; the layout is unchanged from the static tile.
    return InkWell(
      onTap: onTap,
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // One width for every row (so the names line up), grown with the
          // text scale so a three-digit rank never breaks over two lines:
          // 36dp at 1.0, 84dp at 3.0.
          SizedBox(
            width: MediaQuery.textScalerOf(context).scale(24) + 12,
            child: Text(
              '$rank',
              maxLines: 1,
              softWrap: false,
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
                    // One hue for every bar: the rank number and the bold
                    // top-ten names carry the order (visual-display-07).
                    color: theme.colorScheme.primary,
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _NerdyModeWidget extends ConsumerWidget {
  final String sessionId;
  final List<Name> names;
  const _NerdyModeWidget({required this.sessionId, required this.names});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodology = ref.watch(_methodologyProvider(sessionId));
    return methodology.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => OhErrorState.fromError(e,
          stackTrace: st,
          title: 'Couldn’t compare the methods',
          icon: Icons.error_outline,
          onRetry: () => ref.invalidate(_methodologyProvider(sessionId))),
      data: (m) => _methodologyBody(context, m),
    );
  }

  Widget _methodologyBody(BuildContext context, Methodology comparison) {
    final nameMap = {for (final n in names) n.id: n.display};
    final tau = comparison.kendallTau;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text('Algorithm Agreement',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Kendall’s \u03c4 across 15 algorithms: ${tau.toStringAsFixed(2)}.'
          ' ${tau > 0.9 ? 'High confidence.' : tau > 0.7 ? 'Moderate agreement.' : 'Your preferences are nuanced, so hold rankings loosely.'}',
        ),
        const SizedBox(height: 2),
        // Operator ruling: the term stays, in this detail view, explained.
        Text(
          '\u03c4 is how closely two orderings agree, from \u22121 (opposite '
          "orders) to 1 (identical), averaged over the 15 methods' rankings.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if ((comparison.rankability ?? 1.0) < 0.6) ...[
          Text('Note', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          const Text(
            'Your preferences in this pool are less linear than average. '
            'The rankings are a good guide but hold them loosely.',
          ),
          const SizedBox(height: 12),
        ],
        if ((comparison.preferenceDimensions ?? 1) >= 2) ...[
          Text('Two Dimensions Detected',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          const Text(
            'Your preferences have two distinct dimensions. '
            'See the top names in each cluster; you may find a pattern.',
          ),
          const SizedBox(height: 12),
        ],
        if ((comparison.cycleStrength ?? 0.0) > 0.05) ...[
          Text('Preference Cycles',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Cycle strength: ${(comparison.cycleStrength! * 100).toStringAsFixed(0)}%. '
            'Some names are genuinely hard to rank against each other.',
          ),
          const SizedBox(height: 4),
          ...comparison.disagreements
              .where((d) =>
                  d.rankSpread > 5 &&
                  d.invertedAcrossFamilies)
              .take(4)
              .map((d) => Text(
                    '  • ${nameMap[d.nameId] ?? d.nameId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
          const SizedBox(height: 12),
        ],
        Text('Top Disagreements',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        ...comparison.disagreements
            .where((d) => d.rankSpread > 3)
            .take(5)
            .map((d) {
          final name = nameMap[d.nameId] ?? d.nameId;
          final ranks = d.rankByMethod.values.toList()..sort();
          final best = ranks.first + 1; // 0-indexed → 1-indexed
          final worst = ranks.last + 1;
          final entries = d.rankByMethod.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value));
          final bestAlgo = entries.first.key;
          final worstAlgo = entries.last.key;
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
                  '${d.rankByMethod.length} algorithms disagree by ${d.rankSpread} ranks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
