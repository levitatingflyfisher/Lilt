import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/app/router.dart';
import 'package:lilt/core/providers/bootstrap_provider.dart';

class LiltApp extends ConsumerWidget {
  const LiltApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        return bootstrap.when(
          loading: () => const _BootstrapSplash(),
          error: (e, st) => _BootstrapError(error: e),
          data: (_) => child ?? const SizedBox.shrink(),
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
