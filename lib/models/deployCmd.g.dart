// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension DeployCmdCopyWith on DeployCmd {
  DeployCmd copyWith({
    bool? advanced,
    bool? continueEvenIfFails,
    bool? debug,
    List<String>? deployServices,
    bool? dryRun,
    List<String>? limitToServers,
    bool? onlyProperties,
    List<String>? skipTags,
    List<String>? tags,
    CmdType? type,
  }) {
    return DeployCmd(
      advanced: advanced ?? this.advanced,
      continueEvenIfFails: continueEvenIfFails ?? this.continueEvenIfFails,
      debug: debug ?? this.debug,
      deployServices: deployServices ?? this.deployServices,
      dryRun: dryRun ?? this.dryRun,
      limitToServers: limitToServers ?? this.limitToServers,
      onlyProperties: onlyProperties ?? this.onlyProperties,
      skipTags: skipTags ?? this.skipTags,
      tags: tags ?? this.tags,
      type: type ?? this.type,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeployCmd _$DeployCmdFromJson(Map<String, dynamic> json) {
  return DeployCmd(
    type: _$enumDecodeNullable(_$CmdTypeEnumMap, json['type']),
    deployServices: (json['deployServices'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    limitToServers: (json['limitToServers'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    skipTags:
        (json['skipTags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    advanced: json['advanced'] as bool,
    onlyProperties: json['onlyProperties'] as bool,
    continueEvenIfFails: json['continueEvenIfFails'] as bool,
    debug: json['debug'] as bool,
    dryRun: json['dryRun'] as bool,
  );
}

Map<String, dynamic> _$DeployCmdToJson(DeployCmd instance) => <String, dynamic>{
      'deployServices': instance.deployServices,
      'limitToServers': instance.limitToServers,
      'skipTags': instance.skipTags,
      'tags': instance.tags,
      'advanced': instance.advanced,
      'onlyProperties': instance.onlyProperties,
      'continueEvenIfFails': instance.continueEvenIfFails,
      'debug': instance.debug,
      'dryRun': instance.dryRun,
      'type': _$CmdTypeEnumMap[instance.type],
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

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$CmdTypeEnumMap = {
  CmdType.ansible: 'ansible',
  CmdType.deploy: 'deploy',
  CmdType.preDeploy: 'preDeploy',
  CmdType.postDeploy: 'postDeploy',
  CmdType.laPipelines: 'laPipelines',
  CmdType.bash: 'bash',
};
