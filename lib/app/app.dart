import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/core/providers/bootstrap_provider.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

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
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF8B6F47),
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: (context, child) {
        final resolved = bootstrap.when(
          loading: () => const _BootstrapSplash(),
          error: (e, st) => _BootstrapError(error: e),
          data: (_) => child ?? const SizedBox.shrink(),
        );
        final inner = resolved;
        if (MediaQuery.of(context).size.width <= 760) return inner;
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(child: SizedBox(width: 760, child: inner)),
        );
      },
    );
  }
}

class _BootstrapSplash extends StatelessWidget {
  const _BootstrapSplash();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lilt', style: TextStyle(fontSize: 32)),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
}

class _BootstrapError extends StatelessWidget {
  final Object error;
  const _BootstrapError({required this.error});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load name data:\n$error'),
          ),
        ),
      );
}
