import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/name_session.dart';

/// Provides all persisted sessions (most-recent first).
/// Public so other screens can invalidate after mutations (markComplete, delete).
final allSessionsProvider = FutureProvider<List<NameSession>>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final all = await repo.getAllSessions();
  all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return all;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(allSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lilt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_outlined),
            tooltip: 'Shortlist',
            onPressed: () => context.push('/shortlist'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: sessions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) => _HomeBody(sessions: all),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final List<NameSession> sessions;
  const _HomeBody({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final incomplete = sessions.where((s) => !s.isComplete).toList();
    final complete = sessions.where((s) => s.isComplete).toList();

    // Pair completed couple sessions by matching Partner A/B labels by time.
    final couples = <(NameSession, NameSession)>[];
    final soloComplete = <NameSession>[];
    final pairedIds = <String>{};

    final partnerBs =
        complete.where((s) => s.participantLabel == 'Partner B').toList();
    final partnerAs =
        complete.where((s) => s.participantLabel == 'Partner A').toList();

    for (final b in partnerBs) {
      // Find the closest Partner A created before this Partner B.
      final candidates = partnerAs
          .where((a) =>
              !pairedIds.contains(a.id) &&
              a.createdAt.isBefore(b.createdAt))
          .toList();
      if (candidates.isNotEmpty) {
        // Most recent Partner A that preceded this Partner B.
        final a = candidates.first; // already sorted most-recent first
        couples.add((a, b));
        pairedIds.addAll([a.id, b.id]);
      }
    }

    for (final s in complete) {
      if (!pairedIds.contains(s.id)) soloComplete.add(s);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (incomplete.isNotEmpty) ...[
            Text('In Progress',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final session in incomplete)
              _SessionTile(session: session),
            const SizedBox(height: 24),
          ],
          if (couples.isNotEmpty || soloComplete.isNotEmpty) ...[
            Text('Completed',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final (a, b) in couples)
              _CompletedCoupleTile(a: a, b: b),
            for (final session in soloComplete)
              _SessionTile(session: session),
            const SizedBox(height: 24),
          ],
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('New Session'),
            onPressed: () => context.push('/pool-config'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.people_outline),
            label: const Text('Same-device two-player'),
            onPressed: () => context.push('/pool-config?couple=1'),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final NameSession session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final label = session.participantLabel ?? 'Solo';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text('${session.poolSize} names · '
          '${session.isComplete ? "Complete" : "In progress"}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(session.isComplete
          ? '/results/solo/${session.id}'
          : '/matchup/${session.id}'),
    );
  }
}

class _CompletedCoupleTile extends StatelessWidget {
  final NameSession a;
  final NameSession b;
  const _CompletedCoupleTile({required this.a, required this.b});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Couple session'),
        subtitle: Text('${a.poolSize} names'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/results/couple?a=${a.id}&b=${b.id}'),
      );
}
