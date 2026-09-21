// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'la_service_deploy.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LAServiceDeployCWProxy {
  LAServiceDeploy id(String? id);

  LAServiceDeploy serviceId(String serviceId);

  LAServiceDeploy serverId(String? serverId);

  LAServiceDeploy clusterId(String? clusterId);

  LAServiceDeploy additionalVariables(String additionalVariables);

  LAServiceDeploy projectId(String projectId);

  LAServiceDeploy softwareVersions(Map<String, String>? softwareVersions);

  LAServiceDeploy checkedAt(int? checkedAt);

  LAServiceDeploy type(DeploymentType? type);

  LAServiceDeploy status(ServiceStatus? status);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `LAServiceDeploy(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// LAServiceDeploy(...).copyWith(id: 12, name: "My name")
  /// ```
  LAServiceDeploy call({
    String? id,
    String serviceId,
    String? serverId,
    String? clusterId,
    String additionalVariables,
    String projectId,
    Map<String, String>? softwareVersions,
    int? checkedAt,
    DeploymentType? type,
    ServiceStatus? status,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfLAServiceDeploy.copyWith(...)` or call `instanceOfLAServiceDeploy.copyWith.fieldName(value)` for a single field.
class _$LAServiceDeployCWProxyImpl implements _$LAServiceDeployCWProxy {
  const _$LAServiceDeployCWProxyImpl(this._value);

  final LAServiceDeploy _value;

  @override
  LAServiceDeploy id(String? id) => call(id: id);

  @override
  LAServiceDeploy serviceId(String serviceId) => call(serviceId: serviceId);

  @override
  LAServiceDeploy serverId(String? serverId) => call(serverId: serverId);

  @override
  LAServiceDeploy clusterId(String? clusterId) => call(clusterId: clusterId);

  @override
  LAServiceDeploy additionalVariables(String additionalVariables) =>
      call(additionalVariables: additionalVariables);

  @override
  LAServiceDeploy projectId(String projectId) => call(projectId: projectId);

  @override
  LAServiceDeploy softwareVersions(Map<String, String>? softwareVersions) =>
      call(softwareVersions: softwareVersions);

  @override
  LAServiceDeploy checkedAt(int? checkedAt) => call(checkedAt: checkedAt);

  @override
  LAServiceDeploy type(DeploymentType? type) => call(type: type);

  @override
  LAServiceDeploy status(ServiceStatus? status) => call(status: status);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `LAServiceDeploy(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// LAServiceDeploy(...).copyWith(id: 12, name: "My name")
  /// ```
  LAServiceDeploy call({
    Object? id = const $CopyWithPlaceholder(),
    Object? serviceId = const $CopyWithPlaceholder(),
    Object? serverId = const $CopyWithPlaceholder(),
    Object? clusterId = const $CopyWithPlaceholder(),
    Object? additionalVariables = const $CopyWithPlaceholder(),
    Object? projectId = const $CopyWithPlaceholder(),
    Object? softwareVersions = const $CopyWithPlaceholder(),
    Object? checkedAt = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return LAServiceDeploy(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      serviceId: serviceId == const $CopyWithPlaceholder() || serviceId == null
          ? _value.serviceId
          // ignore: cast_nullable_to_non_nullable
          : serviceId as String,
      serverId: serverId == const $CopyWithPlaceholder()
          ? _value.serverId
          // ignore: cast_nullable_to_non_nullable
          : serverId as String?,
      clusterId: clusterId == const $CopyWithPlaceholder()
          ? _value.clusterId
          // ignore: cast_nullable_to_non_nullable
          : clusterId as String?,
      additionalVariables:
          additionalVariables == const $CopyWithPlaceholder() ||
              additionalVariables == null
          ? _value.additionalVariables
          // ignore: cast_nullable_to_non_nullable
          : additionalVariables as String,
      projectId: projectId == const $CopyWithPlaceholder() || projectId == null
          ? _value.projectId
          // ignore: cast_nullable_to_non_nullable
          : projectId as String,
      softwareVersions: softwareVersions == const $CopyWithPlaceholder()
          ? _value.softwareVersions
          // ignore: cast_nullable_to_non_nullable
          : softwareVersions as Map<String, String>?,
      checkedAt: checkedAt == const $CopyWithPlaceholder()
          ? _value.checkedAt
          // ignore: cast_nullable_to_non_nullable
          : checkedAt as int?,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as DeploymentType?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ServiceStatus?,
    );
  }
}

extension $LAServiceDeployCopyWith on LAServiceDeploy {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfLAServiceDeploy.copyWith(...)` or `instanceOfLAServiceDeploy.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LAServiceDeployCWProxy get copyWith => _$LAServiceDeployCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAServiceDeploy _$LAServiceDeployFromJson(Map<String, dynamic> json) =>
    LAServiceDeploy(
      id: json['id'] as String?,
      serviceId: json['serviceId'] as String,
      serverId: json['serverId'] as String?,
      clusterId: json['clusterId'] as String?,
      additionalVariables: json['additionalVariables'] as String? ?? '',
      projectId: json['projectId'] as String,
      softwareVersions: (json['softwareVersions'] as Map<String, dynamic>?)
          ?.map((k, e) => MapEntry(k, e as String)),
      checkedAt: (json['checkedAt'] as num?)?.toInt(),
      type: $enumDecodeNullable(_$DeploymentTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$ServiceStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$LAServiceDeployToJson(LAServiceDeploy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'serverId': instance.serverId,
      'clusterId': instance.clusterId,
      'projectId': instance.projectId,
      'additionalVariables': instance.additionalVariables,
      'softwareVersions': instance.softwareVersions,
      'status': _$ServiceStatusEnumMap[instance.status]!,
      'checkedAt': instance.checkedAt,
      'type': _$DeploymentTypeEnumMap[instance.type]!,
    };

const _$DeploymentTypeEnumMap = {
  DeploymentType.vm: 'vm',
  DeploymentType.dockerSwarm: 'dockerSwarm',
  DeploymentType.k8s: 'k8s',
  DeploymentType.dockerCompose: 'dockerCompose',
};

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};
