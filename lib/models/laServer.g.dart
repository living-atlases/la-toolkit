// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServerCopyWith on LAServer {
  LAServer copyWith({
    List<String> aliases,
    String ipv4,
    String name,
    String proxyJump,
    int proxyJumpPort,
    String proxyJumpUser,
    ServiceStatus reachable,
    int sshPort,
    String sshPrivateKey,
    ServiceStatus sshReachable,
    ServiceStatus sudoEnabled,
  }) {
    return LAServer(
      aliases: aliases ?? this.aliases,
      ipv4: ipv4 ?? this.ipv4,
      name: name ?? this.name,
      proxyJump: proxyJump ?? this.proxyJump,
      proxyJumpPort: proxyJumpPort ?? this.proxyJumpPort,
      proxyJumpUser: proxyJumpUser ?? this.proxyJumpUser,
      reachable: reachable ?? this.reachable,
      sshPort: sshPort ?? this.sshPort,
      sshPrivateKey: sshPrivateKey ?? this.sshPrivateKey,
      sshReachable: sshReachable ?? this.sshReachable,
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
    ipv4: json['ipv4'] as String,
    sshPort: json['sshPort'] as int,
    aliases: (json['aliases'] as List)?.map((e) => e as String)?.toList(),
    sshPrivateKey: json['sshPrivateKey'] as String,
    proxyJump: json['proxyJump'] as String,
    proxyJumpPort: json['proxyJumpPort'] as int,
    proxyJumpUser: json['proxyJumpUser'] as String,
    reachable: _$enumDecodeNullable(_$ServiceStatusEnumMap, json['reachable']),
    sshReachable:
        _$enumDecodeNullable(_$ServiceStatusEnumMap, json['sshReachable']),
    sudoEnabled:
        _$enumDecodeNullable(_$ServiceStatusEnumMap, json['sudoEnabled']),
  );
}

Map<String, dynamic> _$LAServerToJson(LAServer instance) => <String, dynamic>{
      'name': instance.name,
      'ipv4': instance.ipv4,
      'sshPort': instance.sshPort,
      'aliases': instance.aliases,
      'sshPrivateKey': instance.sshPrivateKey,
      'proxyJump': instance.proxyJump,
      'proxyJumpPort': instance.proxyJumpPort,
      'proxyJumpUser': instance.proxyJumpUser,
      'reachable': _$ServiceStatusEnumMap[instance.reachable],
      'sshReachable': _$ServiceStatusEnumMap[instance.sshReachable],
      'sudoEnabled': _$ServiceStatusEnumMap[instance.sudoEnabled],
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
