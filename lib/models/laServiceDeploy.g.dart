// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServiceDeploy.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAServiceDeploy.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfLAServiceDeploy.copyWith.fieldName(...)`
class _LAServiceDeployCWProxy {
  final LAServiceDeploy _value;

  const _LAServiceDeployCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `LAServiceDeploy(...).copyWithNull(...)` to set certain fields to `null`. Prefer `LAServiceDeploy(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAServiceDeploy(...).copyWith(id: 12, name: "My name")
  /// ````
  LAServiceDeploy call({
    String? additionalVariables,
    int? checkedAt,
    String? id,
    String? projectId,
    String? serverId,
    String? serviceId,
    Map<String, String>? softwareVersions,
    ServiceStatus? status,
  }) {
    return LAServiceDeploy(
      additionalVariables: additionalVariables ?? _value.additionalVariables,
      checkedAt: checkedAt ?? _value.checkedAt,
      id: id ?? _value.id,
      projectId: projectId ?? _value.projectId,
      serverId: serverId ?? _value.serverId,
      serviceId: serviceId ?? _value.serviceId,
      softwareVersions: softwareVersions ?? _value.softwareVersions,
      status: status ?? _value.status,
    );
  }

  LAServiceDeploy checkedAt(int? checkedAt) => checkedAt == null
      ? _value._copyWithNull(checkedAt: true)
      : this(checkedAt: checkedAt);

  LAServiceDeploy id(String? id) =>
      id == null ? _value._copyWithNull(id: true) : this(id: id);

  LAServiceDeploy softwareVersions(Map<String, String>? softwareVersions) =>
      softwareVersions == null
          ? _value._copyWithNull(softwareVersions: true)
          : this(softwareVersions: softwareVersions);

  LAServiceDeploy status(ServiceStatus? status) => status == null
      ? _value._copyWithNull(status: true)
      : this(status: status);

  LAServiceDeploy additionalVariables(String additionalVariables) =>
      this(additionalVariables: additionalVariables);

  LAServiceDeploy projectId(String projectId) => this(projectId: projectId);

  LAServiceDeploy serverId(String serverId) => this(serverId: serverId);

  LAServiceDeploy serviceId(String serviceId) => this(serviceId: serviceId);
}

extension LAServiceDeployCopyWith on LAServiceDeploy {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass LAServiceDeploy implements IsJsonSerializable<LAServiceDeploy>.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass LAServiceDeploy implements IsJsonSerializable<LAServiceDeploy>.name.copyWith.fieldName(...)`
  _LAServiceDeployCWProxy get copyWith => _LAServiceDeployCWProxy(this);

  LAServiceDeploy _copyWithNull({
    bool checkedAt = false,
    bool id = false,
    bool softwareVersions = false,
    bool status = false,
  }) {
    return LAServiceDeploy(
      additionalVariables: additionalVariables,
      checkedAt: checkedAt == true ? null : this.checkedAt,
      id: id == true ? null : this.id,
      projectId: projectId,
      serverId: serverId,
      serviceId: serviceId,
      softwareVersions: softwareVersions == true ? null : this.softwareVersions,
      status: status == true ? null : this.status,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAServiceDeploy _$LAServiceDeployFromJson(Map<String, dynamic> json) =>
    LAServiceDeploy(
      id: json['id'] as String?,
      serviceId: json['serviceId'] as String,
      serverId: json['serverId'] as String,
      additionalVariables: json['additionalVariables'] as String? ?? "",
      projectId: json['projectId'] as String,
      softwareVersions:
          (json['softwareVersions'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      checkedAt: json['checkedAt'] as int?,
      status: $enumDecodeNullable(_$ServiceStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$LAServiceDeployToJson(LAServiceDeploy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'serverId': instance.serverId,
      'projectId': instance.projectId,
      'additionalVariables': instance.additionalVariables,
      'softwareVersions': instance.softwareVersions,
      'status': _$ServiceStatusEnumMap[instance.status],
      'checkedAt': instance.checkedAt,
    };

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};
