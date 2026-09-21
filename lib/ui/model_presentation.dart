// How the model looks: colours and icons of statuses, results and services.
//
// The model itself lives in the Flutter-free `la_toolkit_core` package (it is
// shared with the CLI and the MCP server), so everything that needs
// `package:flutter` is attached here as extensions. Import this file wherever
// a widget reads `.color`, `.icon` and friends.
import 'package:flutter/material.dart';
import 'package:la_toolkit_core/models/ansible_error.dart';
import 'package:la_toolkit_core/models/cmd_history_details.dart';
import 'package:la_toolkit_core/models/cmd_history_entry.dart';
import 'package:la_toolkit_core/models/la_project_status.dart';
import 'package:la_toolkit_core/models/la_service.dart';
import 'package:la_toolkit_core/models/la_service_constants.dart';
import 'package:la_toolkit_core/models/la_service_desc.dart';
import 'package:la_toolkit_core/models/prod_service_desc.dart';
import 'package:la_toolkit_core/utils/result_types.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../components/deploy_sub_result_widget.dart';

extension ResultTypeUI on ResultType {
  Color get color {
    switch (this) {
      case ResultType.changed:
        return Colors.brown;
      case ResultType.failures:
        return Colors.redAccent;
      case ResultType.ignored:
        return Colors.grey;
      case ResultType.ok:
        return Colors.green;
      case ResultType.rescued:
        return Colors.blueGrey;
      case ResultType.skipped:
        return Colors.grey;
      case ResultType.unreachable:
        return Colors.deepOrange;
    }
  }
  Color get textColor {
    switch (this) {
      case ResultType.changed:
        return Colors.white;
      case ResultType.failures:
        return Colors.black;
      case ResultType.ignored:
        return Colors.black;
      case ResultType.ok:
        return Colors.white;
      case ResultType.rescued:
        return Colors.white;
      case ResultType.skipped:
        return Colors.black;
      case ResultType.unreachable:
        return Colors.black;
    }
  }
}

extension ServiceStatusUI on ServiceStatus {
  Color get color {
    switch (this) {
      case ServiceStatus.failed:
        return ResultType.failures.color;
      case ServiceStatus.unknown:
        return ResultType.ignored.color;
      case ServiceStatus.success:
        return ResultType.ok.color;
    }
  }
  Color get backColor {
    switch (this) {
      case ServiceStatus.failed:
        return Colors.red.shade100;
      case ServiceStatus.unknown:
        return Colors.grey.shade100;
      case ServiceStatus.success:
        return Colors.green.shade100;
    }
  }
  IconData get icon {
    switch (this) {
      case ServiceStatus.failed:
        return Icons.warning_amber_outlined;
      case ServiceStatus.unknown:
        return Icons.check;
      case ServiceStatus.success:
        return Icons.check;
    }
  }
}

extension LAProjectStatusIconExtension on LAProjectStatus {
  IconData get icon {
    switch (this) {
      case LAProjectStatus.created:
        return Icons.create;
      case LAProjectStatus.basicDefined:
        return Icons.dns;
      case LAProjectStatus.advancedDefined:
        return Icons.playlist_add_check;
      case LAProjectStatus.reachable:
        return Icons.settings_ethernet;
      case LAProjectStatus.firstDeploy:
        return MdiIcons.rocketLaunch;
      case LAProjectStatus.inProduction:
        return Icons.cached;
    }
  }
}

extension CmdResultToIconData on CmdResult {
  Color get iconColor {
    switch (this) {
      case CmdResult.unknown:
        return Colors.grey;
      case CmdResult.aborted:
        return Colors.black12;
      case CmdResult.success:
        return ResultType.ok.color;
      case CmdResult.failed:
        return ResultType.failures.color;
    }
  }
}

final Map<String, IconData> _serviceIcons = <String, IconData>{
  dockerSwarm: MdiIcons.ferry,
  dockerCompose: MdiIcons.docker,
  collectory: MdiIcons.formatListBulletedType,
  'ala_hub': Icons.web,
  'biocache_service': MdiIcons.databaseSearchOutline,
  'ala_bie': MdiIcons.beeFlower,
  'bie_index': MdiIcons.familyTree,
  'images': MdiIcons.imageMultipleOutline,
  'species_lists': Icons.playlist_add_outlined,
  regions: MdiIcons.foodSteak,
  'logger': MdiIcons.mathLog,
  solr: MdiIcons.weatherSunny,
  cas: MdiIcons.accountCheckOutline,
  userdetails: MdiIcons.accountGroup,
  apikey: MdiIcons.api,
  casManagement: MdiIcons.accountNetwork,
  'spatial': MdiIcons.layers,
  spatialService: MdiIcons.layersPlus,
  'geoserver': MdiIcons.layersSearch,
  'webapi': Icons.integration_instructions_outlined,
  'dashboard': MdiIcons.tabletDashboard,
  'sds': Icons.blur_circular,
  'alerts': Icons.notifications_active_outlined,
  'doi': MdiIcons.link,
  'branding': Icons.format_paint,
  'biocache_cli': MdiIcons.powershell,
  'nameindexer': MdiIcons.tournament,
  namematchingService: MdiIcons.textSearch,
  sensitiveDataService: MdiIcons.blurLinear,
  dataQuality: MdiIcons.filterPlusOutline,
  biocacheBackend: MdiIcons.eyeOutline,
  pipelines: MdiIcons.pipe,
  events: Icons.event,
  eventsElasticSearch: Icons.manage_search,
  spark: MdiIcons.shape,
  hadoop: MdiIcons.elephant,
  pipelinesJenkins: MdiIcons.accountMinusOutline,
  airflow: MdiIcons.pinwheel,
  solrcloud: MdiIcons.weatherSunny,
  zookeeper: MdiIcons.shovel,
  biocollect: Icons.compost,
  pdfgen: MdiIcons.filePdfBox,
  ecodata: Icons.playlist_add_circle,
  ecodataReporting: Icons.playlist_add_check_circle,
  dockerCommon: Icons.share,
  gatus: MdiIcons.listStatus,
  cassandra: MdiIcons.eyeOutline,
};

extension LAServiceDescUI on LAServiceDesc {
  // Unknown services (LAServiceDesc.get's fallback) get a question mark.
  IconData get icon => _serviceIcons[nameInt] ?? Icons.help_outline;
}

extension ProdServiceDescUI on ProdServiceDesc {
  IconData get icon => LAServiceDesc.get(nameInt).icon;
}

extension CmdHistoryDetailsUI on CmdHistoryDetails {
  /// One card per host and ansible run.
  List<Widget> get detailsWidgetList => hostResults
      .map(
        (HostDeployResult r) => DeploySubResultWidget(
          host: r.host,
          title: r.title,
          results: r.results,
          errors: r.errors,
        ),
      )
      .toList();
}
