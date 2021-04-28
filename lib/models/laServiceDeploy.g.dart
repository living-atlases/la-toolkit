// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServiceDeploy.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServiceDeployCopyWith on LAServiceDeploy {
  LAServiceDeploy copyWith({
    String? additionalVariables,
    String? id,
    LAProject? project,
    LAServer? server,
    LAService? service,
    ServiceStatus? status,
  }) {
    return LAServiceDeploy(
      additionalVariables: additionalVariables ?? this.additionalVariables,
      id: id ?? this.id,
      project: project ?? this.project,
      server: server ?? this.server,
      service: service ?? this.service,
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
    service: LAService.fromJson(json['service'] as Map<String, dynamic>),
    server: LAServer.fromJson(json['server'] as Map<String, dynamic>),
    additionalVariables: json['additionalVariables'] as String,
    project: LAProject.fromJson(json['project'] as Map<String, dynamic>),
    status: _$enumDecodeNullable(_$ServiceStatusEnumMap, json['status']),
  );
}

Map<String, dynamic> _$LAServiceDeployToJson(LAServiceDeploy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'service': instance.service.toJson(),
      'server': instance.server.toJson(),
      'project': instance.project.toJson(),
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
