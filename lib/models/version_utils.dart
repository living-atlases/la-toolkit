import 'package:pub_semver/pub_semver.dart';


import '../utils/string_utils.dart';

VersionConstraint vc(String c) =>
    VersionConstraint.parse(StringUtils.semantize(c));

Version v(String c) => Version.parse(StringUtils.semantize(c));

bool alaInstallIsNotTagged(String alaInstallS) =>
    alaInstallS == 'custom' ||
    alaInstallS == 'upstream' ||
    alaInstallS == 'la-develop';
