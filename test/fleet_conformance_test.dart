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
