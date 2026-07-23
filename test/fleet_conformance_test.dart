import 'package:oh_fleet_conformance/oh_fleet_conformance.dart';

/// Lilt's recorded fleet posture: full OhTheme adoption, zero Android
/// permissions (the local-first claim as a test, both directions).
void main() => runFleetConformance(const FleetAppConfig(
      appId: 'lilt',
      styleTier: StyleTier.full,
      androidPermissions: {},
      // C4 v2 — the release MERGED surface: source permissions plus
      // what plugins and the manifest merge inject. Bites when an APK
      // build has left a merged manifest under build/ (dev box).
      mergedAndroidPermissions: {
        'org.openhearth.lilt.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION',
      },
    ));
