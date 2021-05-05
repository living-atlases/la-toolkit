// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServiceDeploy.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServiceDeployCopyWith on LAServiceDeploy {
  LAServiceDeploy copyWith({
    String? additionalVariables,
    String? id,
    String? projectId,
    String? serverId,
    String? serviceId,
    ServiceStatus? status,
  }) {
    return LAServiceDeploy(
      additionalVariables: additionalVariables ?? this.additionalVariables,
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      serverId: serverId ?? this.serverId,
      serviceId: serviceId ?? this.serviceId,
      status: status ?? this.status,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAServiceDeploy _$LAServiceDeployFromJson(Map<String, dynamic> json) {
  return LAServiceDeploy(
    id: json['id'] as String?,
    serviceId: json['serviceId'] as String,
    serverId: json['serverId'] as String,
    additionalVariables: json['additionalVariables'] as String,
    projectId: json['projectId'] as String,
    status: _$enumDecodeNullable(_$ServiceStatusEnumMap, json['status']),
  );
}

Map<String, dynamic> _$LAServiceDeployToJson(LAServiceDeploy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'serviceId': instance.serviceId,
      'serverId': instance.serverId,
      'projectId': instance.projectId,
      'additionalVariables': instance.additionalVariables,
      'status': _$ServiceStatusEnumMap[instance.status],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};
