// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_service_check.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HostServiceCheck _$HostServiceCheckFromJson(Map<String, dynamic> json) =>
    HostServiceCheck(
      id: json['id'] as String?,
      name: json['name'] as String,
      type: $enumDecode(_$ServiceCheckTypeEnumMap, json['type']),
      host: json['host'] as String? ?? 'localhost',
      serviceDeploys:
          HostServiceCheck._fromJson(json['serviceDeploys'] as List?),
      services: HostServiceCheck._fromJson(json['services'] as List?),
      args: json['args'] as String? ?? '',
    );

Map<String, dynamic> _$HostServiceCheckToJson(HostServiceCheck instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ServiceCheckTypeEnumMap[instance.type]!,
      'host': instance.host,
      'args': instance.args,
      'serviceDeploys': HostServiceCheck._toJson(instance.serviceDeploys),
      'services': HostServiceCheck._toJson(instance.services),
    };

const _$ServiceCheckTypeEnumMap = {
  ServiceCheckType.tcp: 'tcp',
  ServiceCheckType.udp: 'udp',
  ServiceCheckType.url: 'url',
  ServiceCheckType.other: 'other',
};
