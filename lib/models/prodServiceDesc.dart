import 'package:flutter/cupertino.dart';

import 'basicService.dart';

class ProdServiceDesc {
  final IconData icon;
  final String name;
  final String nameInt;
  final String tooltip;
  final String url;
  final bool admin;
  final bool alaAdmin;
  final String? help;
  final String subtitle;
  final List<String> hostnames;
  final List<BasicService>? deps;
  ProdServiceDesc({
    required this.icon,
    required this.name,
    required this.nameInt,
    required this.tooltip,
    required this.url,
    required this.admin,
    required this.alaAdmin,
    required this.subtitle,
    required this.hostnames,
    this.help,
    required this.deps,
  });
}
