import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/versionUtils.dart';
import 'package:pub_semver/pub_semver.dart';

import 'MigrationNotesDesc.dart';

class MigrationNotes {
  static Map<String, Map<VersionConstraint, MigrationNotesDesc>> map = {
    cas: {
      vc(">= 6.5.6-3"): const MigrationNotesDesc(
          text:
              "Check these additional migration steps if you are upgrading your auth services",
          url:
              "https://github.com/AtlasOfLivingAustralia/ala-cas-5/blob/develop/UPGRADE.MD")
    },
    images: {
      vc(">= 1.1"): const MigrationNotesDesc(
          text:
              "Check these additional migration steps if you are upgrading your images service",
          url:
              "https://github.com/AtlasOfLivingAustralia/documentation/wiki/Image-Service-migration")
    },
    logger: {
      vc(">= 4.0"): const MigrationNotesDesc(
          text:
              "Check these additional migration steps if you are upgrading your logger service",
          url:
              "https://github.com/AtlasOfLivingAustralia/documentation/wiki/Logger-Service-migration")
    },
    pipelines: {
      vc(">= 0.1"): const MigrationNotesDesc(
          text:
              "You'll need to perform some additional steps in order to use pipelines",
          url:
              "https://github.com/AtlasOfLivingAustralia/documentation/wiki/pipelines-extra-steps")
    }
  };
}
