import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/app/theme.dart';
import 'package:lilt/core/providers/bootstrap_provider.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:openhearth_design/openhearth_design.dart';

class LiltApp extends ConsumerStatefulWidget {
  const LiltApp({super.key});

  @override
  ConsumerState<LiltApp> createState() => _LiltAppState();
}

class _LiltAppState extends ConsumerState<LiltApp> {
  @override
  void initState() {
    super.initState();
    // Silent freshness snapshot (BACKUP_RETENTION_SPEC §3): if the newest
    // vault snapshot is >7 days old and a key exists, take one. Post-frame
    // + fire-and-forget — never blocks boot, never surfaces errors (the
    // Sundial/Lullaby app-bootstrap pattern).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupControllerProvider.notifier).runStartupMaintenance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(bootstrapProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Lilt',
      theme: LiltTheme.light(),
      darkTheme: LiltTheme.dark(),
      themeMode: ref.watch(themePreferenceProvider).themeMode,
      routerConfig: router,
      builder: (context, child) {
        final resolved = bootstrap.when(
          loading: () => const _BootstrapSplash(),
          error: (e, st) => _BootstrapError(error: e, stackTrace: st),
          data: (_) => child ?? const SizedBox.shrink(),
        );
        // No app-wide width clamp: each screen caps its own content with
        // OhPage, so app bars and backgrounds still span the window.
        return resolved;
      },
    );
  }
}

class _BootstrapSplash extends StatelessWidget {
  const _BootstrapSplash();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // On the ladder and in the design face, not a bare 32px.
              Text('Lilt', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
}

class _BootstrapError extends ConsumerWidget {
  final Object error;
  final StackTrace stackTrace;
  const _BootstrapError({required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: OhErrorState.fromError(
          error,
          stackTrace: stackTrace,
          title: 'Couldn’t load the name list',
          message: 'Lilt keeps its names on this device, and reading them '
              'failed. Try again, or restart the app.',
          icon: Icons.error_outline,
          onRetry: () => ref.invalidate(bootstrapProvider),
        ),
      );
}
