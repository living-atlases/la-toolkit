import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mdi/mdi.dart';

enum LAProjectStatus {
  created,
  basicDefined,
  advancedDefined,
  reachable,
  firstDeploy,
  inProduction
}

extension LAProjectStatusExtension on LAProjectStatus {
  String get title {
    switch (this) {
      case LAProjectStatus.created:
        return 'Creation';
      case LAProjectStatus.basicDefined:
        return 'Servers Definition';
      case LAProjectStatus.advancedDefined:
        return 'Portal Configured';
      case LAProjectStatus.reachable:
        return 'Servers Reachable';
      case LAProjectStatus.firstDeploy:
        return '1st Deploy';
      case LAProjectStatus.inProduction:
        return 'In Production';
      default:
        return null;
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
        return Mdi.rocketLaunch;
      case LAProjectStatus.inProduction:
        return Icons.cached;
      default:
        return null;
    }
  }
}

extension LAProjectStatusValExtension on LAProjectStatus {
  int get value {
    switch (this) {
      case LAProjectStatus.created:
        return 0;
      case LAProjectStatus.basicDefined:
        return 1;
      case LAProjectStatus.advancedDefined:
        return 2;
      case LAProjectStatus.reachable:
        return 3;
      case LAProjectStatus.firstDeploy:
        return 4;
      case LAProjectStatus.inProduction:
        return 5;
      default:
        return null;
    }
  }
}

extension LAProjectStatusPercentExtension on LAProjectStatus {
  int get percent {
    switch (this) {
      case LAProjectStatus.created:
        return 33;
      case LAProjectStatus.basicDefined:
        return 66;
      case LAProjectStatus.advancedDefined:
        return 100;
      case LAProjectStatus.reachable:
        return 100;
      case LAProjectStatus.firstDeploy:
        return 100;
      case LAProjectStatus.inProduction:
        return 100;
      default:
        return null;
    }
  }
}
