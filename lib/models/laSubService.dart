import 'package:flutter/widgets.dart';

class LASubServiceDesc {
  String name;
  String desc;
  IconData icon;
  String path;
  bool admin;
  bool alaAdmin;

  LASubServiceDesc(
      {required this.name,
      this.desc = "",
      required this.path,
      required this.icon,
      this.admin = false,
      this.alaAdmin = false});
}
