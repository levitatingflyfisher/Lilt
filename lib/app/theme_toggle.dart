import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/core/providers/settings_providers.dart';
import 'package:openhearth_design/openhearth_design.dart';

/// The app-bar theme switch (light, dark, follow the phone), bound to the
/// stored preference. Two taps from any screen that carries it.
class LiltThemeToggle extends ConsumerWidget {
  const LiltThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => OhThemeToggle(
        value: ref.watch(themePreferenceProvider),
        onChanged: (v) => ref.read(themePreferenceProvider.notifier).set(v),
      );
}
