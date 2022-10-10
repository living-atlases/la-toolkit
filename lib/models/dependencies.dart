import 'package:pub_semver/pub_semver.dart';

class Dependencies {
  static Map<String, Map<VersionConstraint, Map<String, VersionConstraint>>>
      map = {};

  // Now dependencies are loaded from:
  // https://raw.githubusercontent.com/living-atlases/la-toolkit-backend/master/assets/dependencies.yaml
}
