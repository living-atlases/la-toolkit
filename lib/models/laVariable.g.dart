// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laVariable.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAVariableCopyWith on LAVariable {
  LAVariable copyWith({
    String nameInt,
    LAServiceName service,
    Object value,
  }) {
    return LAVariable(
      nameInt: nameInt ?? this.nameInt,
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
    nameInt: json['nameInt'] as String,
    service: _$enumDecodeNullable(_$LAServiceNameEnumMap, json['service']),
    value: json['value'],
  )..status = _$enumDecodeNullable(_$LAVariableStatusEnumMap, json['status']);
}

Map<String, dynamic> _$LAVariableToJson(LAVariable instance) =>
    <String, dynamic>{
      'nameInt': instance.nameInt,
      'service': _$LAServiceNameEnumMap[instance.service],
      'value': instance.value,
      'status': _$LAVariableStatusEnumMap[instance.status],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
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
