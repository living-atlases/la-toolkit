// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hostServiceCheck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HostServiceCheck _$HostServiceCheckFromJson(Map<String, dynamic> json) {
  return HostServiceCheck(
    id: json['id'] as String?,
    name: json['name'] as String,
    type: _$enumDecode(_$ServiceCheckTypeEnumMap, json['type']),
    host: json['host'] as String,
    serviceDeploys: json['serviceDeploys'],
    services: json['services'],
    args: json['args'] as String,
  );
}

Map<String, dynamic> _$HostServiceCheckToJson(HostServiceCheck instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ServiceCheckTypeEnumMap[instance.type],
      'host': instance.host,
      'args': instance.args,
      'serviceDeploys': instance.serviceDeploys.toList(),
      'services': instance.services.toList(),
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

const _$ServiceCheckTypeEnumMap = {
  ServiceCheckType.tcp: 'tcp',
  ServiceCheckType.udp: 'udp',
  ServiceCheckType.url: 'url',
  ServiceCheckType.other: 'other',
};
