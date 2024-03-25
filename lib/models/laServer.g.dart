// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laServer.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LAServerCWProxy {
  LAServer id(String? id);

  LAServer name(String name);

  LAServer ip(String? ip);

  LAServer sshPort(int sshPort);

  LAServer sshUser(String? sshUser);

  LAServer aliases(List<String>? aliases);

  LAServer gateways(List<String>? gateways);

  LAServer sshKey(SshKey? sshKey);

  LAServer reachable(ServiceStatus reachable);

  LAServer sshReachable(ServiceStatus sshReachable);

  LAServer sudoEnabled(ServiceStatus sudoEnabled);

  LAServer osName(String osName);

  LAServer osVersion(String osVersion);

  LAServer projectId(String projectId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAServer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAServer(...).copyWith(id: 12, name: "My name")
  /// ````
  LAServer call({
    String? id,
    String? name,
    String? ip,
    int? sshPort,
    String? sshUser,
    List<String>? aliases,
    List<String>? gateways,
    SshKey? sshKey,
    ServiceStatus? reachable,
    ServiceStatus? sshReachable,
    ServiceStatus? sudoEnabled,
    String? osName,
    String? osVersion,
    String? projectId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAServer.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLAServer.copyWith.fieldName(...)`
class _$LAServerCWProxyImpl implements _$LAServerCWProxy {
  const _$LAServerCWProxyImpl(this._value);

  final LAServer _value;

  @override
  LAServer id(String? id) => this(id: id);

  @override
  LAServer name(String name) => this(name: name);

  @override
  LAServer ip(String? ip) => this(ip: ip);

  @override
  LAServer sshPort(int sshPort) => this(sshPort: sshPort);

  @override
  LAServer sshUser(String? sshUser) => this(sshUser: sshUser);

  @override
  LAServer aliases(List<String>? aliases) => this(aliases: aliases);

  @override
  LAServer gateways(List<String>? gateways) => this(gateways: gateways);

  @override
  LAServer sshKey(SshKey? sshKey) => this(sshKey: sshKey);

  @override
  LAServer reachable(ServiceStatus reachable) => this(reachable: reachable);

  @override
  LAServer sshReachable(ServiceStatus sshReachable) =>
      this(sshReachable: sshReachable);

  @override
  LAServer sudoEnabled(ServiceStatus sudoEnabled) =>
      this(sudoEnabled: sudoEnabled);

  @override
  LAServer osName(String osName) => this(osName: osName);

  @override
  LAServer osVersion(String osVersion) => this(osVersion: osVersion);

  @override
  LAServer projectId(String projectId) => this(projectId: projectId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAServer(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAServer(...).copyWith(id: 12, name: "My name")
  /// ````
  LAServer call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? ip = const $CopyWithPlaceholder(),
    Object? sshPort = const $CopyWithPlaceholder(),
    Object? sshUser = const $CopyWithPlaceholder(),
    Object? aliases = const $CopyWithPlaceholder(),
    Object? gateways = const $CopyWithPlaceholder(),
    Object? sshKey = const $CopyWithPlaceholder(),
    Object? reachable = const $CopyWithPlaceholder(),
    Object? sshReachable = const $CopyWithPlaceholder(),
    Object? sudoEnabled = const $CopyWithPlaceholder(),
    Object? osName = const $CopyWithPlaceholder(),
    Object? osVersion = const $CopyWithPlaceholder(),
    Object? projectId = const $CopyWithPlaceholder(),
  }) {
    return LAServer(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      ip: ip == const $CopyWithPlaceholder()
          ? _value.ip
          // ignore: cast_nullable_to_non_nullable
          : ip as String?,
      sshPort: sshPort == const $CopyWithPlaceholder() || sshPort == null
          ? _value.sshPort
          // ignore: cast_nullable_to_non_nullable
          : sshPort as int,
      sshUser: sshUser == const $CopyWithPlaceholder()
          ? _value.sshUser
          // ignore: cast_nullable_to_non_nullable
          : sshUser as String?,
      aliases: aliases == const $CopyWithPlaceholder()
          ? _value.aliases
          // ignore: cast_nullable_to_non_nullable
          : aliases as List<String>?,
      gateways: gateways == const $CopyWithPlaceholder()
          ? _value.gateways
          // ignore: cast_nullable_to_non_nullable
          : gateways as List<String>?,
      sshKey: sshKey == const $CopyWithPlaceholder()
          ? _value.sshKey
          // ignore: cast_nullable_to_non_nullable
          : sshKey as SshKey?,
      reachable: reachable == const $CopyWithPlaceholder() || reachable == null
          ? _value.reachable
          // ignore: cast_nullable_to_non_nullable
          : reachable as ServiceStatus,
      sshReachable:
          sshReachable == const $CopyWithPlaceholder() || sshReachable == null
              ? _value.sshReachable
              // ignore: cast_nullable_to_non_nullable
              : sshReachable as ServiceStatus,
      sudoEnabled:
          sudoEnabled == const $CopyWithPlaceholder() || sudoEnabled == null
              ? _value.sudoEnabled
              // ignore: cast_nullable_to_non_nullable
              : sudoEnabled as ServiceStatus,
      osName: osName == const $CopyWithPlaceholder() || osName == null
          ? _value.osName
          // ignore: cast_nullable_to_non_nullable
          : osName as String,
      osVersion: osVersion == const $CopyWithPlaceholder() || osVersion == null
          ? _value.osVersion
          // ignore: cast_nullable_to_non_nullable
          : osVersion as String,
      projectId: projectId == const $CopyWithPlaceholder() || projectId == null
          ? _value.projectId
          // ignore: cast_nullable_to_non_nullable
          : projectId as String,
    );
  }
}

extension $LAServerCopyWith on LAServer {
  /// Returns a callable class that can be used as follows: `instanceOfLAServer.copyWith(...)` or like so:`instanceOfLAServer.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LAServerCWProxy get copyWith => _$LAServerCWProxyImpl(this);
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
      osName: json['osName'] as String? ?? '',
      osVersion: json['osVersion'] as String? ?? '',
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
      'reachable': _$ServiceStatusEnumMap[instance.reachable]!,
      'sshReachable': _$ServiceStatusEnumMap[instance.sshReachable]!,
      'sudoEnabled': _$ServiceStatusEnumMap[instance.sudoEnabled]!,
      'osName': instance.osName,
      'osVersion': instance.osVersion,
      'projectId': instance.projectId,
    };

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};
