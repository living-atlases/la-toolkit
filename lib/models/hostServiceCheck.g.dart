// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hostServiceCheck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HostServiceCheck _$HostServiceCheckFromJson(Map<String, dynamic> json) =>
    HostServiceCheck(
      id: json['id'] as String?,
      name: json['name'] as String,
      type: $enumDecode(_$ServiceCheckTypeEnumMap, json['type']),
      host: json['host'] as String? ?? "localhost",
      serviceDeploys: json['serviceDeploys'],
      services: json['services'],
      args: json['args'] as String? ?? "",
    );

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

const _$ServiceCheckTypeEnumMap = {
  ServiceCheckType.tcp: 'tcp',
  ServiceCheckType.udp: 'udp',
  ServiceCheckType.url: 'url',
  ServiceCheckType.other: 'other',
};
