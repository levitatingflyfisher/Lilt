import 'package:oh_fleet_conformance/oh_fleet_conformance.dart';

/// Lilt's recorded fleet posture: full OhTheme adoption, zero Android
/// permissions (the local-first claim as a test, both directions).
void main() => runFleetConformance(const FleetAppConfig(
      appId: 'lilt',
      styleTier: StyleTier.full,
      androidPermissions: {},
    ));
