// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServiceDeploy.dart';

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

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAServiceDeploy(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAServiceDeploy(...).copyWith(id: 12, name: "My name")
  /// ````
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

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAServiceDeploy.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLAServiceDeploy.copyWith.fieldName(...)`
class _$LAServiceDeployCWProxyImpl implements _$LAServiceDeployCWProxy {
  const _$LAServiceDeployCWProxyImpl(this._value);

  final LAServiceDeploy _value;

  @override
  LAServiceDeploy id(String? id) => this(id: id);

  @override
  LAServiceDeploy serviceId(String serviceId) => this(serviceId: serviceId);

  @override
  LAServiceDeploy serverId(String? serverId) => this(serverId: serverId);

  @override
  LAServiceDeploy clusterId(String? clusterId) => this(clusterId: clusterId);

  @override
  LAServiceDeploy additionalVariables(String additionalVariables) =>
      this(additionalVariables: additionalVariables);

  @override
  LAServiceDeploy projectId(String projectId) => this(projectId: projectId);

  @override
  LAServiceDeploy softwareVersions(Map<String, String>? softwareVersions) =>
      this(softwareVersions: softwareVersions);

  @override
  LAServiceDeploy checkedAt(int? checkedAt) => this(checkedAt: checkedAt);

  @override
  LAServiceDeploy type(DeploymentType? type) => this(type: type);

  @override
  LAServiceDeploy status(ServiceStatus? status) => this(status: status);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAServiceDeploy(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAServiceDeploy(...).copyWith(id: 12, name: "My name")
  /// ````
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
      serviceId: serviceId == const $CopyWithPlaceholder()
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
      additionalVariables: additionalVariables == const $CopyWithPlaceholder()
          ? _value.additionalVariables
          // ignore: cast_nullable_to_non_nullable
          : additionalVariables as String,
      projectId: projectId == const $CopyWithPlaceholder()
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
  /// Returns a callable class that can be used as follows: `instanceOfLAServiceDeploy.copyWith(...)` or like so:`instanceOfLAServiceDeploy.copyWith.fieldName(...)`.
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
      softwareVersions:
          (json['softwareVersions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
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
};

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};
