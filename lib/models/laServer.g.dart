// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServerCopyWith on LAServer {
  LAServer copyWith({
    List<String> aliases,
    List<String> gateways,
    dynamic ip,
    String name,
    String osName,
    String osVersion,
    ServiceStatus reachable,
    SshKey sshKey,
    int sshPort,
    ServiceStatus sshReachable,
    String sshUser,
    ServiceStatus sudoEnabled,
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
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAServer _$LAServerFromJson(Map<String, dynamic> json) {
  return LAServer(
    name: json['name'] as String,
    ip: json['ip'],
    sshPort: json['sshPort'] as int,
    sshUser: json['sshUser'] as String,
    aliases: (json['aliases'] as List)?.map((e) => e as String)?.toList(),
    gateways: (json['gateways'] as List)?.map((e) => e as String)?.toList(),
    sshKey: json['sshKey'] == null
        ? null
        : SshKey.fromJson(json['sshKey'] as Map<String, dynamic>),
    reachable: _$enumDecodeNullable(_$ServiceStatusEnumMap, json['reachable']),
    sshReachable:
        _$enumDecodeNullable(_$ServiceStatusEnumMap, json['sshReachable']),
    sudoEnabled:
        _$enumDecodeNullable(_$ServiceStatusEnumMap, json['sudoEnabled']),
    osName: json['osName'] as String,
    osVersion: json['osVersion'] as String,
  );
}

Map<String, dynamic> _$LAServerToJson(LAServer instance) => <String, dynamic>{
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

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};
