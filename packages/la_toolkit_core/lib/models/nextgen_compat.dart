import 'package:pub_semver/pub_semver.dart';

/// "Nextgen" ALA app releases that require platform capabilities the community
/// Living Atlas stack does not provide yet (currently: the new ala-bootstrap5
/// branding). Loaded at runtime from:
/// https://raw.githubusercontent.com/living-atlases/la-toolkit-backend/master/assets/nextgen-compat.yaml
class NextgenCompat {
  // service (internal name) -> compatibility entry
  static Map<String, NextgenCompatEntry> map = <String, NextgenCompatEntry>{};
}

class NextgenCompatEntry {
  const NextgenCompatEntry({
    required this.from,
    required this.lastSafe,
    required this.reason,
  });

  /// Versions considered nextgen / not yet supported by the community stack.
  final VersionConstraint from;

  /// Last community-supported version, shown in the warning.
  final String lastSafe;

  /// Reason key (e.g. `bootstrap5-branding`) mapped to an explanation by the
  /// toolkit in [DependenciesManager.verifyNextgen].
  final String reason;
}
