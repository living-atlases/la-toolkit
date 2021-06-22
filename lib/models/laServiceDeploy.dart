import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

import 'isJsonSerializable.dart';
import 'laService.dart';

part 'laServiceDeploy.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAServiceDeploy implements IsJsonSerializable<LAServiceDeploy> {
  String id;
  String serviceId;
  String serverId;
  String projectId;
  String additionalVariables;
  ServiceStatus status;
  int? checkedAt;

  LAServiceDeploy(
      {String? id,
      required this.serviceId,
      required this.serverId,
      this.additionalVariables = "",
      required this.projectId,
      this.checkedAt,
      ServiceStatus? status})
      : id = id ?? ObjectId().toString(),
        status = status ?? ServiceStatus.unknown;

  factory LAServiceDeploy.fromJson(Map<String, dynamic> json) =>
      _$LAServiceDeployFromJson(json);

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
          projectId == other.projectId &&
          additionalVariables == other.additionalVariables &&
          checkedAt == other.checkedAt &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      serviceId.hashCode ^
      serverId.hashCode ^
      projectId.hashCode ^
      checkedAt.hashCode ^
      additionalVariables.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'LAServiceDeploy{id: $id, status: $status, serviceId: $serviceId, serverId: $serverId, projectId: $projectId, checkedAt: $checkedAt}';
  }
}
