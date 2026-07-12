import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/core/providers/repository_providers.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:lilt/features/home/home_screen.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Peeking Prevention'),
            subtitle: Text(
              'When on, neither partner sees results until both finish. '
              'Applies to new sessions.',
            ),
            trailing: Icon(Icons.lock_outline),
          ),
          const Divider(),
          ListTile(
            title: const Text('Ranking Confidence'),
            subtitle: Text(
              'Higher = more comparisons but more stable results. '
              'Current: ${(ref.watch(convergenceTauProvider) * 100).toStringAsFixed(0)}%',
            ),
          ),
          Slider(
            value: ref.watch(convergenceTauProvider),
            min: 0.80,
            max: 0.99,
            divisions: 19,
            label: '${(ref.watch(convergenceTauProvider) * 100).toStringAsFixed(0)}%',
            onChanged: (val) {
              final prefs = ref.read(sharedPreferencesProvider);
              prefs.setDouble('convergence_tau', val);
              ref.invalidate(convergenceTauProvider);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Clear Completed Sessions'),
            subtitle: const Text(
                'Free up storage by deleting old completed sessions.'),
            trailing: const Icon(Icons.delete_outline),
            onTap: () => _confirmClearSessions(context, ref),
          ),
          const BackupSettingsSection(),
          const Divider(),
          const ListTile(
            title: Text('Version'),
            trailing: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearSessions(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Sessions?'),
        content: const Text(
            'This removes all completed sessions from this device. '
            "Names you've added to your shortlist will be kept."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (confirmed == true) {
      final repo = ref.read(sessionRepositoryProvider);
      final sessions = await repo.getAllSessions();
      for (final s in sessions.where((s) => s.isComplete)) {
        await repo.deleteSession(s.id);
      }
      if (!context.mounted) return;
      ref.invalidate(allSessionsProvider);
    }
  }
}
