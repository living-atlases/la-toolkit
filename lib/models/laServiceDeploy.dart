import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'laProject.dart';
import 'laServer.dart';
import 'laService.dart';

part 'laServiceDeploy.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAServiceDeploy {
  LAService service;
  LAServer server;
  LAProject project;
  String additionalVariables;
  ServiceStatus status;

  LAServiceDeploy(
      {required this.service,
      required this.server,
      this.additionalVariables = "",
      required this.project,
      ServiceStatus? status})
      : status = status ?? ServiceStatus.unknown;
}
