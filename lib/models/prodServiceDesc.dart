import 'package:flutter/cupertino.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';

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
  final List<String> urls = [];
  final ServiceStatus status;

  ProdServiceDesc(
      {required this.icon,
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
      required this.status}) {
    if (nameInt != LAServiceName.biocache_backend.toS() &&
        nameInt != LAServiceName.nameindexer.toS() &&
        nameInt != LAServiceName.biocache_cli.toS()) {
      urls.add(url);
      if (alaAdmin) urls.add(url + '/alaAdmin/');
      if (admin) urls.add(url + '/admin/');
    }
  }
}
