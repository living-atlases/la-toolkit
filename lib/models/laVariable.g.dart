// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laVariable.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAVariableCopyWith on LAVariable {
  LAVariable copyWith({
    String? id,
    String? nameInt,
    String? projectId,
    LAServiceName? service,
    Object? value,
  }) {
    return LAVariable(
      id: id ?? this.id,
      nameInt: nameInt ?? this.nameInt,
      projectId: projectId ?? this.projectId,
      service: service ?? this.service,
      value: value ?? this.value,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAVariable _$LAVariableFromJson(Map<String, dynamic> json) {
  return LAVariable(
    id: json['id'] as String?,
    nameInt: json['nameInt'] as String,
    service: _$enumDecode(_$LAServiceNameEnumMap, json['service']),
    value: json['value'],
    projectId: json['projectId'] as String,
  )..status = _$enumDecode(_$LAVariableStatusEnumMap, json['status']);
}

Map<String, dynamic> _$LAVariableToJson(LAVariable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameInt': instance.nameInt,
      'service': _$LAServiceNameEnumMap[instance.service],
      'value': instance.value,
      'projectId': instance.projectId,
      'status': _$LAVariableStatusEnumMap[instance.status],
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

const _$LAServiceNameEnumMap = {
  LAServiceName.all: 'all',
  LAServiceName.collectory: 'collectory',
  LAServiceName.ala_hub: 'ala_hub',
  LAServiceName.biocache_service: 'biocache_service',
  LAServiceName.ala_bie: 'ala_bie',
  LAServiceName.bie_index: 'bie_index',
  LAServiceName.images: 'images',
  LAServiceName.species_lists: 'species_lists',
  LAServiceName.regions: 'regions',
  LAServiceName.logger: 'logger',
  LAServiceName.solr: 'solr',
  LAServiceName.cas: 'cas',
  LAServiceName.spatial: 'spatial',
  LAServiceName.webapi: 'webapi',
  LAServiceName.dashboard: 'dashboard',
  LAServiceName.sds: 'sds',
  LAServiceName.alerts: 'alerts',
  LAServiceName.doi: 'doi',
  LAServiceName.biocache_backend: 'biocache_backend',
  LAServiceName.branding: 'branding',
  LAServiceName.biocache_cli: 'biocache_cli',
  LAServiceName.nameindexer: 'nameindexer',
};

const _$LAVariableStatusEnumMap = {
  LAVariableStatus.deployed: 'deployed',
  LAVariableStatus.undeployed: 'undeployed',
};
