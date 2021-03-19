// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServerCopyWith on LAServer {
  LAServer copyWith({
    List<String>? aliases,
    List<String>? gateways,
    String? ip,
    String? name,
    String? osName,
    String? osVersion,
    ServiceStatus? reachable,
    SshKey? sshKey,
    int? sshPort,
    ServiceStatus? sshReachable,
    String? sshUser,
    ServiceStatus? sudoEnabled,
    String? uuid,
  }) {
    return LAServer(
      aliases: aliases ?? this.aliases,
      gateways: gateways ?? this.gateways,
      ip: ip ?? this.ip,
      name: name ?? this.name,
      osName: osName ?? this.osName,
      osVersion: osVersion ?? this.osVersion,
      reachable: reachable ?? this.reachable,
      sshKey: sshKey ?? this.sshKey,
      sshPort: sshPort ?? this.sshPort,
      sshReachable: sshReachable ?? this.sshReachable,
      sshUser: sshUser ?? this.sshUser,
      sudoEnabled: sudoEnabled ?? this.sudoEnabled,
      uuid: uuid ?? this.uuid,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAServer _$LAServerFromJson(Map<String, dynamic> json) {
  return LAServer(
    uuid: json['uuid'] as String?,
    name: json['name'] as String,
    ip: json['ip'] as String?,
    sshPort: json['sshPort'] as int,
    sshUser: json['sshUser'] as String?,
    aliases:
        (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList(),
    gateways:
        (json['gateways'] as List<dynamic>?)?.map((e) => e as String).toList(),
    sshKey: json['sshKey'] == null
        ? null
        : SshKey.fromJson(json['sshKey'] as Map<String, dynamic>),
    reachable: _$enumDecode(_$ServiceStatusEnumMap, json['reachable']),
    sshReachable: _$enumDecode(_$ServiceStatusEnumMap, json['sshReachable']),
    sudoEnabled: _$enumDecode(_$ServiceStatusEnumMap, json['sudoEnabled']),
    osName: json['osName'] as String,
    osVersion: json['osVersion'] as String,
  );
}

Map<String, dynamic> _$LAServerToJson(LAServer instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'ip': instance.ip,
      'sshPort': instance.sshPort,
      'sshUser': instance.sshUser,
      'aliases': instance.aliases,
      'sshKey': instance.sshKey?.toJson(),
      'gateways': instance.gateways,
      'reachable': _$ServiceStatusEnumMap[instance.reachable],
      'sshReachable': _$ServiceStatusEnumMap[instance.sshReachable],
      'sudoEnabled': _$ServiceStatusEnumMap[instance.sudoEnabled],
      'osName': instance.osName,
      'osVersion': instance.osVersion,
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

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};
