import 'package:flutter/widgets.dart';

class LASubServiceDesc {
  String name;
  String nameInt;
  String desc;
  IconData icon;
  String path;
  bool admin;
  bool alaAdmin;
  String? artifact;
  String? artifactAnsibleVar;

  LASubServiceDesc(
      {required this.name,
      required this.nameInt,
      this.desc = "",
      required this.path,
      required this.icon,
      this.admin = false,
      this.artifact,
      this.artifactAnsibleVar,
      this.alaAdmin = false});
}
