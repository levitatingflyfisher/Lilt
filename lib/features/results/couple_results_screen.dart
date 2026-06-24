import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/name.dart';
import 'package:lilt/domain/models/name_session.dart';

final _coupleResultsProvider = FutureProvider.family<_CoupleData,
    ({String sessionAId, String sessionBId})>((ref, ids) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final namesRepo = ref.watch(namesRepositoryProvider);

  final sessionA = await sessionRepo.getSession(ids.sessionAId);
  final sessionB = await sessionRepo.getSession(ids.sessionBId);
  if (sessionA == null || sessionB == null) {
    throw StateError('Session(s) not found');
  }

  final engineA = await sessionRepo.buildEngine(ids.sessionAId);
  final engineB = await sessionRepo.buildEngine(ids.sessionBId);

  final allIds = {...sessionA.poolIds, ...sessionB.poolIds}.toList();
  final names = await namesRepo.getByIds(allIds);
  final nameMap = {for (final n in names) n.id: n};

  final rankingsA = engineA.rankings
      .map((i) => nameMap[i.id])
      .whereType<Name>()
      .toList();
  final rankingsB = engineB.rankings
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
      appBar: AppBar(title: const Text('Matches')),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (d) => _CoupleResultsBody(data: d),
      ),
    );
  }
}

class _CoupleResultsBody extends StatelessWidget {
  final _CoupleData data;
  const _CoupleResultsBody({required this.data});

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
          ),
        ),
        SizedBox(
          width: 120,
          child: _MatchesColumn(matches: data.matches),
        ),
        Expanded(
          child: _RankColumn(
            label: data.sessionB.participantLabel ?? 'Partner B',
            names: data.rankingsB,
            highlightIds: data.matches.map((m) => m.name.id).toSet(),
            alignRight: true,
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

  const _RankColumn({
    required this.label,
    required this.names,
    required this.highlightIds,
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
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  name.display,
                  textAlign: alignRight ? TextAlign.right : TextAlign.left,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isMatch ? FontWeight.w600 : FontWeight.normal,
                        color: isMatch
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
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
  const _MatchesColumn({required this.matches});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
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
                final bothTop5 = m.rankA < 5 && m.rankB < 5;
                final color = bothTop5
                    ? theme.colorScheme.primary
                    : theme.colorScheme.secondary;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    m.name.display,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
