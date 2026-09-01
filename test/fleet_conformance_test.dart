import 'package:oh_fleet_conformance/oh_fleet_conformance.dart';

/// Lilt's recorded fleet posture: full OhTheme adoption, zero Android
/// permissions (the local-first claim as a test, both directions).
void main() => runFleetConformance(const FleetAppConfig(
      appId: 'lilt',
      // Bundles its own type, so nothing falls back to a web font — a
      // character the bundled families cannot draw is a box on a
      // real phone. C7 sweeps lib/ for any.
      // C8: full OhTheme adoption means the ambient iconTheme really is
      // wired up, so a bare IconButton.filled really would go invisible.
      // Filled icon buttons must come from OhIconButton.
      checks: {
        ...FleetAppConfig.withBundledFonts,
        FleetCheck.c8IconButtons,
        // C10: no raw exception text on screen; failures use OhErrorState.
        FleetCheck.c10RawErrors,
        // C11: every app-bar action has a name; Lilt's all show one.
        FleetCheck.c11IconLabels,
        // C9: every GoRoute has a way in (Name Detail once had none).
        FleetCheck.c9Routes,
        // C12: the accent is not the error red (CIEDE2000 >= 12).
        FleetCheck.c12AccentVsError,
        // C5: the primary-action screens are swept at 360dp x 1.3 and
        // 320dp x 3.0 in test/a11y/primary_action_sweep_test.dart.
        FleetCheck.c5PrimaryScreens,
      },
      primaryActionScreens: {
        'HomeScreen',
        'PoolConfigScreen',
        'MatchupScreen',
        'SoloResultsScreen',
        'CoupleResultsScreen',
        'NameDetailScreen',
        'SettingsScreen',
      },
      styleTier: StyleTier.full,
      androidPermissions: {},
      // C4 v2 — the release MERGED surface: source permissions plus
      // what plugins and the manifest merge inject. Bites when an APK
      // build has left a merged manifest under build/ (dev box).
      mergedAndroidPermissions: {
        'org.openhearth.lilt.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION',
      },
    ));
