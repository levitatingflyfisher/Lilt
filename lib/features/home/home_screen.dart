import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/name_session.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:lilt/app/theme_toggle.dart';

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
        actions: [OhBarActions(children: [
          OhBarAction(
            icon: Icons.list_alt_outlined,
            label: 'Shortlist',
            onPressed: () => context.push('/shortlist'),
          ),
          const LiltThemeToggle(),
        ])],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: sessions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => OhErrorState.fromError(e,
              stackTrace: st,
              title: 'Couldn’t load your sessions',
              icon: Icons.error_outline,
              onRetry: () => ref.invalidate(allSessionsProvider)),
          data: (all) => _HomeBody(sessions: all),
        ),
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
    final byAnyId = {for (final s in sessions) s.id: s};
    final complete = sessions.where((s) => s.isComplete).toList();

    final couples = <(NameSession, NameSession)>[];
    final soloComplete = <NameSession>[];
    final pairedIds = <String>{};

    // Couples are paired by the persisted link (schema v2+).
    final byId = {for (final s in complete) s.id: s};
    for (final b in complete.where((s) => s.participantLabel == 'Partner B')) {
      final a = byId[b.partnerSessionId];
      if (a == null) continue;
      couples.add((a, b));
      pairedIds.addAll([a.id, b.id]);
    }

    // Legacy (pre-v2) rows carry no link: fall back to matching Partner A/B
    // labels by creation time, as before.
    final partnerBs = complete
        .where((s) =>
            s.participantLabel == 'Partner B' && s.partnerSessionId == null)
        .toList();
    final partnerAs = complete
        .where((s) =>
            s.participantLabel == 'Partner A' && s.partnerSessionId == null)
        .toList();

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
              _SessionTile(
                session: session,
                lockedUntil: _lockedUntil(session, byAnyId),
              ),
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
          // First-run ruling: the task comes first; unfinished backup setup
          // waits here as a dismissible line (no space once done/dismissed).
          const SizedBox(height: 16),
          const BackupSetupReminder(),
          const SizedBox(height: 8),
          // Settings is a rare stop, so it waits below the task instead of
          // taking bar space from the app's name, the Shortlist and the
          // theme switch (three labelled actions do not fit a 360dp bar).
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Settings'),
              onPressed: () => context.push('/settings'),
            ),
          ),
        ],
      ),
    );
  }
}

/// The partner whose unfinished ranking keeps [s]'s results closed (the
/// peeking lock the `/results/solo` guard enforces), or null if none.
NameSession? _lockedUntil(NameSession s, Map<String, NameSession> byId) {
  final partner = byId[s.partnerSessionId];
  if (!s.resultsLocked || partner == null || partner.isComplete) return null;
  return partner;
}

class _SessionTile extends ConsumerWidget {
  final NameSession session;
  final NameSession? lockedUntil;
  const _SessionTile({required this.session, this.lockedUntil});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = session.participantLabel ?? 'Solo';
    final waitingOn = lockedUntil;
    if (waitingOn != null) {
      final partnerName = waitingOn.participantLabel ?? 'your partner';
      // Not a link: the results route would refuse it. Say why, and offer
      // the way out for a partner who never finishes.
      return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${session.poolSize} names · Locked until '
                '$partnerName finishes'),
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => _confirmEndPairing(context, ref, partnerName),
              child: const Text('End pairing'),
            ),
          ],
        ),
        trailing: const Icon(Icons.lock_outline),
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text('${session.poolSize} names · '
          '${session.isComplete ? 'Complete' : 'In progress'}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(session.isComplete
          ? '/results/solo/${session.id}'
          : _resumeRoute(session)),
    );
  }

  Future<void> _confirmEndPairing(
      BuildContext context, WidgetRef ref, String partnerName) async {
    // An easy tap on a list tile that gives up independence, so it asks;
    // it deletes nothing, so the confirm is neutral, not destructive.
    final confirmed = await showOhConfirm(
      context,
      title: 'End pairing?',
      message: 'Your results open now. $partnerName’s session is kept, but '
          'if they see your list before finishing, your matches will no '
          'longer be independent.',
      confirmLabel: 'End pairing',
    );
    if (!confirmed) return;
    await ref.read(sessionRepositoryProvider).endPairing(session.id);
    ref.invalidate(allSessionsProvider);
  }
}

/// A resumed Partner B keeps the couple flow: the matchup screen needs
/// Partner A's id to offer "See Results Together" instead of a hand-off.
String _resumeRoute(NameSession s) {
  final partner = s.partnerSessionId;
  if (s.participantLabel == 'Partner B' && partner != null) {
    return '/matchup/${s.id}?partnerA=$partner';
  }
  return '/matchup/${s.id}';
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
