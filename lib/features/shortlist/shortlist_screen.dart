import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/domain/models/shortlist_entry.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:openhearth_design/openhearth_design.dart';
import 'package:lilt/app/theme_toggle.dart';

/// Public so other screens (and the post-restore invalidation set — see
/// main.dart's sanctuaryBackupConfigProvider override) can refresh it after
/// mutations, matching allSessionsProvider's convention.
final shortlistEntriesProvider = FutureProvider<List<ShortlistEntry>>((ref) {
  return ref.watch(shortlistRepositoryProvider).getAll();
});

class ShortlistScreen extends ConsumerStatefulWidget {
  const ShortlistScreen({super.key});

  @override
  ConsumerState<ShortlistScreen> createState() => _ShortlistScreenState();
}

class _ShortlistScreenState extends ConsumerState<ShortlistScreen> {
  // Remove is a deliberate tap, so it does not ask; this Undo stays until
  // the person acts, removes another name, or leaves the screen.
  final _undo = OhUndoController();

  @override
  void dispose() {
    _undo.dispose();
    super.dispose();
  }

  Future<void> _remove(ShortlistEntry entry) async {
    final repo = ref.read(shortlistRepositoryProvider);
    await repo.remove(entry.id);
    ref.invalidate(shortlistEntriesProvider);
    _undo.show(
      message: 'Removed ${entry.name.display}',
      onUndo: () async {
        await repo.restore(entry);
        ref.invalidate(shortlistEntriesProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(shortlistEntriesProvider);

    return Scaffold(
      bottomSheet: OhUndoBar(controller: _undo),
      appBar: AppBar(
        title: const Text('Shortlist'),
        actions: [OhBarActions(children: [
          entries.whenData((list) => list.isEmpty
                  ? const SizedBox.shrink()
                  : OhBarAction(
                      icon: Icons.ios_share_outlined,
                      label: 'Share',
                      onPressed: () => _export(list),
                    )).valueOrNull ??
              const SizedBox.shrink(),
          const LiltThemeToggle(),
        ])],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: entries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => OhErrorState.fromError(e,
              stackTrace: st,
              title: 'Couldn’t load your shortlist',
              icon: Icons.error_outline,
              onRetry: () => ref.invalidate(shortlistEntriesProvider)),
          data: (list) => list.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No names saved yet.\n'
                      'Open a name from your rankings and tap '
                      '“Add to Shortlist”.',
                      textAlign: TextAlign.center,
                    ),
                  ))
              : _ShortlistBody(entries: list, onRemove: _remove),
        ),
      ),
    );
  }

  void _export(List<ShortlistEntry> entries) {
    final text = entries.map((e) {
      final note = e.note?.isNotEmpty == true ? ': ${e.note}' : '';
      return '${e.name.display}$note';
    }).join('\n');
    Share.share('Our shortlist:\n$text');
  }
}

class _ShortlistBody extends ConsumerWidget {
  final List<ShortlistEntry> entries;
  final ValueChanged<ShortlistEntry> onRemove;
  const _ShortlistBody({required this.entries, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      // Room for the Undo bar so it never covers the last name.
      padding: const EdgeInsets.only(bottom: 72),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final entry = entries[i];
        return ListTile(
          title: Text(entry.name.display),
          subtitle: entry.note != null ? Text(entry.note!) : null,
          onTap: () => context.push('/name/${entry.name.id}'),
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
                tooltip: 'Remove ${entry.name.display}',
                onPressed: () => onRemove(entry),
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
