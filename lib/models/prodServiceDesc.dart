import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';

import 'basicService.dart';
import 'laServiceDeploy.dart';

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
  final List<LAServiceDeploy> serviceDeploys;
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
      required this.serviceDeploys,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProdServiceDesc &&
          runtimeType == other.runtimeType &&
          icon == other.icon &&
          name == other.name &&
          nameInt == other.nameInt &&
          tooltip == other.tooltip &&
          url == other.url &&
          admin == other.admin &&
          alaAdmin == other.alaAdmin &&
          help == other.help &&
          subtitle == other.subtitle &&
          const ListEquality().equals(serviceDeploys, other.serviceDeploys) &&
          const ListEquality().equals(deps, other.deps) &&
          const ListEquality().equals(urls, other.urls) &&
          status == other.status;

  @override
  int get hashCode =>
      icon.hashCode ^
      name.hashCode ^
      nameInt.hashCode ^
      tooltip.hashCode ^
      admin.hashCode ^
      alaAdmin.hashCode ^
      help.hashCode ^
      subtitle.hashCode ^
      const ListEquality().hash(serviceDeploys) ^
      const ListEquality().hash(deps) ^
      const ListEquality().hash(urls) ^
      status.hashCode;
}
