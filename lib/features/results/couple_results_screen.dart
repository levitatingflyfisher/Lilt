import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/name.dart';
import 'package:lilt/domain/models/name_session.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:lilt/app/theme_toggle.dart';

final _coupleResultsProvider = FutureProvider.family<_CoupleData,
    ({String sessionAId, String sessionBId})>((ref, ids) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final namesRepo = ref.watch(namesRepositoryProvider);

  final sessionA = await sessionRepo.getSession(ids.sessionAId);
  final sessionB = await sessionRepo.getSession(ids.sessionBId);
  if (sessionA == null || sessionB == null) {
    throw StateError('Session(s) not found');
  }

  final rankingA = await sessionRepo.ranking(ids.sessionAId);
  final rankingB = await sessionRepo.ranking(ids.sessionBId);

  final allIds = {...sessionA.poolIds, ...sessionB.poolIds}.toList();
  final names = await namesRepo.getByIds(allIds);
  final nameMap = {for (final n in names) n.id: n};

  final rankingsA = rankingA.ranked
      .map((i) => nameMap[i.id])
      .whereType<Name>()
      .toList();
  final rankingsB = rankingB.ranked
      .map((i) => nameMap[i.id])
      .whereType<Name>()
      .toList();

  final topAIds = rankingsA.take(20).map((n) => n.id).toSet();
  final topBIds = rankingsB.take(20).map((n) => n.id).toSet();
  final overlapIds = topAIds.intersection(topBIds);

  final n = rankingsA.length;
  final matchNames = overlapIds
      .map((id) {
        final rankA = rankingsA.indexWhere((nm) => nm.id == id);
        final rankB = rankingsB.indexWhere((nm) => nm.id == id);
        if (rankA < 0 || rankB < 0) return null;
        final scoreA = (n - rankA).toDouble();
        final scoreB = (n - rankB).toDouble();
        final hm = (2 * scoreA * scoreB) / (scoreA + scoreB);
        return _MatchEntry(
            name: nameMap[id]!,
            rankA: rankA,
            rankB: rankB,
            harmonicMean: hm);
      })
      .whereType<_MatchEntry>()
      .toList()
    ..sort((a, b) => b.harmonicMean.compareTo(a.harmonicMean));

  return _CoupleData(
    sessionA: sessionA,
    sessionB: sessionB,
    rankingsA: rankingsA.take(20).toList(),
    rankingsB: rankingsB.take(20).toList(),
    matches: matchNames,
  );
});

class _MatchEntry {
  final Name name;
  final int rankA;
  final int rankB;
  final double harmonicMean;
  const _MatchEntry(
      {required this.name,
      required this.rankA,
      required this.rankB,
      required this.harmonicMean});
}

class _CoupleData {
  final NameSession sessionA;
  final NameSession sessionB;
  final List<Name> rankingsA;
  final List<Name> rankingsB;
  final List<_MatchEntry> matches;
  const _CoupleData({
    required this.sessionA,
    required this.sessionB,
    required this.rankingsA,
    required this.rankingsB,
    required this.matches,
  });
}

class CoupleResultsScreen extends ConsumerWidget {
  final String sessionAId;
  final String sessionBId;

  const CoupleResultsScreen(
      {super.key, required this.sessionAId, required this.sessionBId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = (sessionAId: sessionAId, sessionBId: sessionBId);
    final data = ref.watch(_coupleResultsProvider(ids));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        actions: const [OhBarActions(children: [LiltThemeToggle()])],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => OhErrorState.fromError(e,
              stackTrace: st,
              title: 'Couldn’t load your matches',
              icon: Icons.error_outline,
              onRetry: () => ref.invalidate(_coupleResultsProvider(ids))),
          data: (d) => _CoupleResultsBody(
            data: d,
            onOpenName: (nameId) =>
                context.push('/name/$nameId?a=$sessionAId&b=$sessionBId'),
          ),
        ),
      ),
    );
  }
}

class _CoupleResultsBody extends StatelessWidget {
  final _CoupleData data;
  final ValueChanged<String> onOpenName;
  const _CoupleResultsBody({required this.data, required this.onOpenName});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _RankColumn(
            label: data.sessionA.participantLabel ?? 'Partner A',
            names: data.rankingsA,
            highlightIds: data.matches.map((m) => m.name.id).toSet(),
            onOpenName: onOpenName,
          ),
        ),
        SizedBox(
          width: 120,
          child: _MatchesColumn(
              matches: data.matches, onOpenName: onOpenName),
        ),
        Expanded(
          child: _RankColumn(
            label: data.sessionB.participantLabel ?? 'Partner B',
            names: data.rankingsB,
            highlightIds: data.matches.map((m) => m.name.id).toSet(),
            alignRight: true,
            onOpenName: onOpenName,
          ),
        ),
      ],
    );
  }
}

class _RankColumn extends StatelessWidget {
  final String label;
  final List<Name> names;
  final Set<String> highlightIds;
  final bool alignRight;
  final ValueChanged<String> onOpenName;

  const _RankColumn({
    required this.label,
    required this.names,
    required this.highlightIds,
    required this.onOpenName,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(label,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: alignRight ? TextAlign.right : TextAlign.left),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: names.length,
            itemBuilder: (_, i) {
              final name = names[i];
              final isMatch = highlightIds.contains(name.id);
              final theme = Theme.of(context);
              // The rank is printed, not implied by position alone
              // (dashboard-design-03).
              final rank = Text(
                '${i + 1}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
              final label = Expanded(
                child: Text(
                  name.display,
                  textAlign: alignRight ? TextAlign.right : TextAlign.left,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isMatch ? FontWeight.w600 : FontWeight.normal,
                    color: isMatch ? theme.colorScheme.primary : null,
                  ),
                ),
              );
              return _NameRow(
                onTap: () => onOpenName(name.id),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: alignRight
                      ? [label, const SizedBox(width: 6), rank]
                      : [rank, const SizedBox(width: 6), label],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MatchesColumn extends StatelessWidget {
  final List<_MatchEntry> matches;
  final ValueChanged<String> onOpenName;
  const _MatchesColumn({required this.matches, required this.onOpenName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      key: const Key('matches-column'),
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('Matches',
              style: theme.textTheme.labelMedium,
              textAlign: TextAlign.center),
        ),
        if (matches.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('No overlap in top 20 yet.',
                textAlign: TextAlign.center),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: matches.length,
              itemBuilder: (_, i) {
                final m = matches[i];
                // One colour for every match: the rank pair under the
                // name says how high each partner put it, which a second
                // brown with no key never did (visual-display-07).
                return _NameRow(
                  onTap: () => onOpenName(m.name.id),
                  child: Column(
                    children: [
                      Text(
                        m.name.display,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'A ${m.rankA + 1} · B ${m.rankB + 1}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// A tappable name row that opens Name Detail. Vertical padding brings each
/// row to ~36dp, clearing the WCAG 2.2 AA 24px target floor with room,
/// without redesigning the three-column layout.
class _NameRow extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _NameRow({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: child,
        ),
      );
}
