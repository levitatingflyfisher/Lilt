import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/name.dart';

final _nameDetailProvider = FutureProvider.family<_NameDetailData,
    ({String nameId, String? sessionAId, String? sessionBId})>(
    (ref, args) async {
  final namesRepo = ref.watch(namesRepositoryProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);

  final names = await namesRepo.getByIds([args.nameId]);
  if (names.isEmpty) throw StateError('Name not found: ${args.nameId}');
  final name = names.first;

  int? rankA, rankB;
  if (args.sessionAId != null) {
    final engine = await sessionRepo.buildEngine(args.sessionAId!);
    final idx = engine.rankings.indexWhere((i) => i.id == args.nameId);
    if (idx >= 0) rankA = idx + 1;
  }
  if (args.sessionBId != null) {
    final engine = await sessionRepo.buildEngine(args.sessionBId!);
    final idx = engine.rankings.indexWhere((i) => i.id == args.nameId);
    if (idx >= 0) rankB = idx + 1;
  }

  return _NameDetailData(name: name, rankA: rankA, rankB: rankB);
});

class _NameDetailData {
  final Name name;
  final int? rankA;
  final int? rankB;
  const _NameDetailData({required this.name, this.rankA, this.rankB});
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
      appBar: AppBar(),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (d) => _NameDetailBody(data: d),
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

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              name.display,
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w200,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (data.rankA != null || data.rankB != null) ...[
            Text('Rankings', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (data.rankA != null) Text('Partner A: #${data.rankA}'),
            if (data.rankB != null) Text('Partner B: #${data.rankB}'),
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
              final repo = ref.read(shortlistRepositoryProvider);
              await repo.add(widget.nameId);
              if (mounted) setState(() => _inList = true);
            },
    );
  }
}
