// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAServer.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfLAServer.copyWith.fieldName(...)`
class _LAServerCWProxy {
  final LAServer _value;

  const _LAServerCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `LAServer(...).copyWithNull(...)` to set certain fields to `null`. Prefer `LAServer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAServer(...).copyWith(id: 12, name: "My name")
  /// ````
  LAServer call({
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
      aliases: aliases ?? _value.aliases,
      gateways: gateways ?? _value.gateways,
      id: id ?? _value.id,
      ip: ip ?? _value.ip,
      name: name ?? _value.name,
      osName: osName ?? _value.osName,
      osVersion: osVersion ?? _value.osVersion,
      projectId: projectId ?? _value.projectId,
      reachable: reachable ?? _value.reachable,
      sshKey: sshKey ?? _value.sshKey,
      sshPort: sshPort ?? _value.sshPort,
      sshReachable: sshReachable ?? _value.sshReachable,
      sshUser: sshUser ?? _value.sshUser,
      sudoEnabled: sudoEnabled ?? _value.sudoEnabled,
    );
  }

  LAServer aliases(List<String>? aliases) => aliases == null
      ? _value._copyWithNull(aliases: true)
      : this(aliases: aliases);

  LAServer gateways(List<String>? gateways) => gateways == null
      ? _value._copyWithNull(gateways: true)
      : this(gateways: gateways);

  LAServer id(String? id) =>
      id == null ? _value._copyWithNull(id: true) : this(id: id);

  LAServer ip(String? ip) =>
      ip == null ? _value._copyWithNull(ip: true) : this(ip: ip);

  LAServer sshKey(SshKey? sshKey) => sshKey == null
      ? _value._copyWithNull(sshKey: true)
      : this(sshKey: sshKey);

  LAServer sshUser(String? sshUser) => sshUser == null
      ? _value._copyWithNull(sshUser: true)
      : this(sshUser: sshUser);

  LAServer name(String name) => this(name: name);

  LAServer osName(String osName) => this(osName: osName);

  LAServer osVersion(String osVersion) => this(osVersion: osVersion);

  LAServer projectId(String projectId) => this(projectId: projectId);

  LAServer reachable(ServiceStatus reachable) => this(reachable: reachable);

  LAServer sshPort(int sshPort) => this(sshPort: sshPort);

  LAServer sshReachable(ServiceStatus sshReachable) =>
      this(sshReachable: sshReachable);

  LAServer sudoEnabled(ServiceStatus sudoEnabled) =>
      this(sudoEnabled: sudoEnabled);
}

extension LAServerCopyWith on LAServer {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass LAServer implements IsJsonSerializable<LAServer>.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass LAServer implements IsJsonSerializable<LAServer>.name.copyWith.fieldName(...)`
  _LAServerCWProxy get copyWith => _LAServerCWProxy(this);

  LAServer _copyWithNull({
    bool aliases = false,
    bool gateways = false,
    bool id = false,
    bool ip = false,
    bool sshKey = false,
    bool sshUser = false,
  }) {
    return LAServer(
      aliases: aliases == true ? null : this.aliases,
      gateways: gateways == true ? null : this.gateways,
      id: id == true ? null : this.id,
      ip: ip == true ? null : this.ip,
      name: name,
      osName: osName,
      osVersion: osVersion,
      projectId: projectId,
      reachable: reachable,
      sshKey: sshKey == true ? null : this.sshKey,
      sshPort: sshPort,
      sshReachable: sshReachable,
      sshUser: sshUser == true ? null : this.sshUser,
      sudoEnabled: sudoEnabled,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAServer _$LAServerFromJson(Map<String, dynamic> json) => LAServer(
      id: json['id'] as String?,
      name: json['name'] as String,
      ip: json['ip'] as String?,
      sshPort: json['sshPort'] as int? ?? 22,
      sshUser: json['sshUser'] as String?,
      aliases:
          (json['aliases'] as List<dynamic>?)?.map((e) => e as String).toList(),
      gateways: (json['gateways'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sshKey: json['sshKey'] == null
          ? null
          : SshKey.fromJson(json['sshKey'] as Map<String, dynamic>),
      reachable:
          $enumDecodeNullable(_$ServiceStatusEnumMap, json['reachable']) ??
              ServiceStatus.unknown,
      sshReachable:
          $enumDecodeNullable(_$ServiceStatusEnumMap, json['sshReachable']) ??
              ServiceStatus.unknown,
      sudoEnabled:
          $enumDecodeNullable(_$ServiceStatusEnumMap, json['sudoEnabled']) ??
              ServiceStatus.unknown,
      osName: json['osName'] as String? ?? "",
      osVersion: json['osVersion'] as String? ?? "",
      projectId: json['projectId'] as String,
    );

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

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};
