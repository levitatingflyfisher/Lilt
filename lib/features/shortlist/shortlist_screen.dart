import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/shortlist_entry.dart';
import 'package:share_plus/share_plus.dart' show Share;

/// Public so other screens (and the post-restore invalidation set — see
/// main.dart's sanctuaryBackupConfigProvider override) can refresh it after
/// mutations, matching allSessionsProvider's convention.
final shortlistEntriesProvider = FutureProvider<List<ShortlistEntry>>((ref) {
  return ref.watch(shortlistRepositoryProvider).getAll();
});

class ShortlistScreen extends ConsumerWidget {
  const ShortlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(shortlistEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shortlist'),
        actions: [
          entries.whenData((list) => list.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.ios_share_outlined),
                      tooltip: 'Export',
                      onPressed: () => _export(list),
                    )).valueOrNull ??
              const SizedBox.shrink(),
        ],
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('No names saved yet.\n'
                    'Tap "Add to Shortlist" on any name.'))
            : _ShortlistBody(entries: list),
      ),
    );
  }

  void _export(List<ShortlistEntry> entries) {
    final text = entries.map((e) {
      final note = e.note?.isNotEmpty == true ? '  \u2014 ${e.note}' : '';
      return '${e.name.display}$note';
    }).join('\n');
    Share.share('Our shortlist:\n$text');
  }
}

class _ShortlistBody extends ConsumerWidget {
  final List<ShortlistEntry> entries;
  const _ShortlistBody({required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final entry = entries[i];
        return ListTile(
          title: Text(entry.name.display),
          subtitle: entry.note != null ? Text(entry.note!) : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_note_outlined),
                tooltip: 'Edit note',
                onPressed: () => _editNote(context, ref, entry),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove',
                onPressed: () => ref
                    .read(shortlistRepositoryProvider)
                    .remove(entry.id)
                    .then((_) => ref.invalidate(shortlistEntriesProvider)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editNote(
      BuildContext context, WidgetRef ref, ShortlistEntry entry) async {
    final controller = TextEditingController(text: entry.note);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Note for ${entry.name.display}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Optional note'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null) {
      await ref
          .read(shortlistRepositoryProvider)
          .updateNote(entry.id, result.isEmpty ? null : result);
      ref.invalidate(shortlistEntriesProvider);
    }
    controller.dispose();
  }
}
