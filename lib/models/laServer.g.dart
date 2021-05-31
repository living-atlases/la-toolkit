// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServerCopyWith on LAServer {
  LAServer copyWith({
    List<String>? aliases,
    List<String>? gateways,
    String? id,
    String? ip,
    String? name,
    String? osName,
    String? osVersion,
    String? projectId,
    ServiceStatus? reachable,
    SshKey? sshKey,
    int? sshPort,
    ServiceStatus? sshReachable,
    String? sshUser,
    ServiceStatus? sudoEnabled,
  }) {
    return LAServer(
      aliases: aliases ?? this.aliases,
      gateways: gateways ?? this.gateways,
      id: id ?? this.id,
      ip: ip ?? this.ip,
      name: name ?? this.name,
      osName: osName ?? this.osName,
      osVersion: osVersion ?? this.osVersion,
      projectId: projectId ?? this.projectId,
      reachable: reachable ?? this.reachable,
      sshKey: sshKey ?? this.sshKey,
      sshPort: sshPort ?? this.sshPort,
      sshReachable: sshReachable ?? this.sshReachable,
      sshUser: sshUser ?? this.sshUser,
      sudoEnabled: sudoEnabled ?? this.sudoEnabled,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAServer _$LAServerFromJson(Map<String, dynamic> json) {
  return LAServer(
    id: json['id'] as String?,
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
    projectId: json['projectId'] as String,
  );
}

Map<String, dynamic> _$LAServerToJson(LAServer instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'aliases': instance.aliases,
      'ip': instance.ip,
      'sshPort': instance.sshPort,
      'sshUser': instance.sshUser,
      'sshKey': instance.sshKey?.toJson(),
      'gateways': instance.gateways,
      'reachable': _$ServiceStatusEnumMap[instance.reachable],
      'sshReachable': _$ServiceStatusEnumMap[instance.sshReachable],
      'sudoEnabled': _$ServiceStatusEnumMap[instance.sudoEnabled],
      'osName': instance.osName,
      'osVersion': instance.osVersion,
      'projectId': instance.projectId,
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
