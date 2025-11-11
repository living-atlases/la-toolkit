import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'basic_service.dart';
import 'laServiceDeploy.dart';
import 'la_service.dart';

class ProdServiceDesc {
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
      required this.status,
      this.withoutUrl = false}) {
    // Only add URL checks if the service is configured to have them
    if (withoutUrl != null && !withoutUrl!) {
      urls.add(url);
      if (alaAdmin) urls.add('$url/alaAdmin/');
      if (admin) urls.add('$url/admin/');
    }
  }

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
  final List<String> urls = <String>[];
  final ServiceStatus status;
  final bool? withoutUrl;

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
          withoutUrl == other.withoutUrl &&
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
      withoutUrl.hashCode ^
      const ListEquality().hash(serviceDeploys) ^
      const ListEquality().hash(deps) ^
      const ListEquality().hash(urls) ^
      status.hashCode;
}
