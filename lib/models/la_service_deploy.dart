import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';
import './deployment_type.dart';
import './is_json_serializable.dart';
import 'la_service.dart';

part 'la_service_deploy.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAServiceDeploy implements IsJsonSerializable<LAServiceDeploy> {
  LAServiceDeploy(
      {String? id,
      required this.serviceId,
      required this.serverId,
      required this.clusterId,
      this.additionalVariables = '',
      required this.projectId,
      Map<String, String>? softwareVersions,
      this.checkedAt,
      DeploymentType? type,
      ServiceStatus? status})
      : id = id ?? ObjectId().toString(),
        softwareVersions = softwareVersions ?? <String, String>{},
        type = type ?? DeploymentType.vm,
        status = status ?? ServiceStatus.unknown;

  factory LAServiceDeploy.fromJson(Map<String, dynamic> json) =>
      _$LAServiceDeployFromJson(json);
  String id;
  String serviceId;
  String? serverId;
  String? clusterId;
  String projectId;
  String additionalVariables;
  Map<String, String> softwareVersions;
  ServiceStatus status;
  int? checkedAt;
  DeploymentType type;

  @override
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
          serviceId == other.serviceId &&
          serverId == other.serverId &&
          clusterId == other.clusterId &&
          projectId == other.projectId &&
          type == other.type &&
          additionalVariables == other.additionalVariables &&
          checkedAt == other.checkedAt &&
          const DeepCollectionEquality.unordered()
              .equals(softwareVersions, other.softwareVersions) &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      serviceId.hashCode ^
      serverId.hashCode ^
      clusterId.hashCode ^
      projectId.hashCode ^
      checkedAt.hashCode ^
      type.hashCode ^
      additionalVariables.hashCode ^
      const DeepCollectionEquality.unordered().hash(softwareVersions) ^
      status.hashCode;

  @override
  String toString() {
    return 'LAServiceDeploy{id: $id, status: $status, serviceId: $serviceId, serverId: $serverId, clusterId: $clusterId, projectId: $projectId, checkedAt: $checkedAt, type: $type}';
  }
}
