import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

import 'isJsonSerializable.dart';
import 'laProject.dart';
import 'laServer.dart';
import 'laService.dart';

part 'laServiceDeploy.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAServiceDeploy implements IsJsonSerializable<LAServiceDeploy> {
  String id;
  LAService service;
  LAServer server;
  LAProject project;
  String additionalVariables;
  ServiceStatus status;

  LAServiceDeploy(
      {String? id,
      required this.service,
      required this.server,
      this.additionalVariables = "",
      required this.project,
      ServiceStatus? status})
      : id = id ?? new ObjectId().toString(),
        status = status ?? ServiceStatus.unknown;

  factory LAServiceDeploy.fromJson(Map<String, dynamic> json) =>
      _$LAServiceDeployFromJson(json);

  Map<String, dynamic> toJson() => _$LAServiceDeployToJson(this);

  @override
  LAServiceDeploy fromJson(Map<String, dynamic> json) =>
      LAServiceDeploy.fromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAServiceDeploy &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          service == other.service &&
          server == other.server &&
          project == other.project &&
          additionalVariables == other.additionalVariables &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      service.hashCode ^
      server.hashCode ^
      project.hashCode ^
      additionalVariables.hashCode ^
      status.hashCode;
}
