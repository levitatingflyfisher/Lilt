import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/name.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:lilt/app/theme_toggle.dart';

final _nameDetailProvider = FutureProvider.family<_NameDetailData,
    ({String nameId, String? sessionAId, String? sessionBId})>(
    (ref, args) async {
  final namesRepo = ref.watch(namesRepositoryProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);

  final names = await namesRepo.getByIds([args.nameId]);
  if (names.isEmpty) throw StateError('Name not found: ${args.nameId}');
  final name = names.first;

  int? rankA, rankB;
  String? labelA, labelB;
  if (args.sessionAId != null) {
    labelA =
        (await sessionRepo.getSession(args.sessionAId!))?.participantLabel;
    rankA = (await sessionRepo.ranking(args.sessionAId!)).rankOf(args.nameId);
  }
  if (args.sessionBId != null) {
    labelB =
        (await sessionRepo.getSession(args.sessionBId!))?.participantLabel;
    rankB = (await sessionRepo.ranking(args.sessionBId!)).rankOf(args.nameId);
  }

  return _NameDetailData(
    name: name,
    rankA: rankA,
    rankB: rankB,
    // A solo session has no participant label: it is simply "your" rank.
    labelA: labelA ?? (args.sessionBId == null ? 'Your rank' : 'Partner A'),
    labelB: labelB ?? 'Partner B',
  );
});

class _NameDetailData {
  final Name name;
  final int? rankA;
  final int? rankB;
  final String labelA;
  final String labelB;
  const _NameDetailData({
    required this.name,
    this.rankA,
    this.rankB,
    required this.labelA,
    required this.labelB,
  });
}

class NameDetailScreen extends ConsumerWidget {
  final String nameId;
  final String? sessionAId;
  final String? sessionBId;

  const NameDetailScreen({
    super.key,
    required this.nameId,
    this.sessionAId,
    this.sessionBId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        (nameId: nameId, sessionAId: sessionAId, sessionBId: sessionBId);
    final data = ref.watch(_nameDetailProvider(args));

    return Scaffold(
      appBar: AppBar(actions: const [OhBarActions(children: [LiltThemeToggle()])]),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          // Name ids never come from outside the app, so the likely cause is
          // a name that has since been removed. Retrying cannot help; the way
          // out is home, where every session is intact.
          error: (e, st) => OhErrorState.fromError(e,
              stackTrace: st,
              title: 'Couldn’t open this name',
              message: 'It may have been removed. Your sessions and '
                  'shortlist are safe.',
              icon: Icons.error_outline,
              retryLabel: 'Back to your sessions',
              onRetry: () => context.go('/')),
          data: (d) => _NameDetailBody(data: d),
        ),
      ),
    );
  }
}

class _NameDetailBody extends ConsumerWidget {
  final _NameDetailData data;
  const _NameDetailBody({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final name = data.name;

    // Scrolls, so large text never pushes Add to Shortlist off the screen.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            // A long name at large text shrinks to fit rather than clipping.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name.display,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (data.rankA != null || data.rankB != null) ...[
            Text('Rankings', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (data.rankA != null) Text('${data.labelA}: #${data.rankA}'),
            if (data.rankB != null) Text('${data.labelB}: #${data.rankB}'),
            const SizedBox(height: 24),
          ],
          if (name.variants.isNotEmpty) ...[
            Text('Also spelled', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  name.variants.map((v) => Chip(label: Text(v))).toList(),
            ),
            const SizedBox(height: 24),
          ],
          _ShortlistButton(nameId: name.id),
        ],
      ),
    );
  }
}

/// Tracks shortlist state locally so the button updates after adding.
class _ShortlistButton extends ConsumerStatefulWidget {
  final String nameId;
  const _ShortlistButton({required this.nameId});

  @override
  ConsumerState<_ShortlistButton> createState() => _ShortlistButtonState();
}

class _ShortlistButtonState extends ConsumerState<_ShortlistButton> {
  bool? _inList;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final repo = ref.read(shortlistRepositoryProvider);
    final result = await repo.isInShortlist(widget.nameId);
    if (mounted) setState(() => _inList = result);
  }

  @override
  Widget build(BuildContext context) {
    final inList = _inList;
    if (inList == null) return const SizedBox.shrink();
    return FilledButton.icon(
      icon: Icon(inList ? Icons.bookmark : Icons.bookmark_border_outlined),
      label: Text(inList ? 'In Shortlist' : 'Add to Shortlist'),
      onPressed: inList
          ? null
          : () async {
              // Flip to "in list" synchronously so a rapid second tap hits the
              // now-disabled button (onPressed == null) instead of inserting a
              // duplicate row. Revert if the write fails.
              setState(() => _inList = true);
              final repo = ref.read(shortlistRepositoryProvider);
              try {
                await repo.add(widget.nameId);
              } catch (_) {
                if (mounted) setState(() => _inList = false);
              }
            },
    );
  }
}
