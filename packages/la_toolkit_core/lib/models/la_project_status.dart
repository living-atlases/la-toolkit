
enum LAProjectStatus {
  created,
  basicDefined,
  advancedDefined,
  reachable,
  firstDeploy,
  inProduction,
}

extension LAProjectStatusExtension on LAProjectStatus {
  String title(bool isHub) {
    switch (this) {
      case LAProjectStatus.created:
        return 'Creation';
      case LAProjectStatus.basicDefined:
        return 'Servers Definition';
      case LAProjectStatus.advancedDefined:
        return "${isHub ? 'Hub' : 'Portal'} Configured";
      case LAProjectStatus.reachable:
        return 'Servers Reachable';
      case LAProjectStatus.firstDeploy:
        return '1st Deploy';
      case LAProjectStatus.inProduction:
        return 'In Production';
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
    }
  }
}
