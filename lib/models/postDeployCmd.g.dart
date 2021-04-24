// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension PostDeployCmdCopyWith on PostDeployCmd {
  PostDeployCmd copyWith({
    dynamic? advanced,
    bool? configurePostfix,
    dynamic? continueEvenIfFails,
    dynamic? debug,
    dynamic? dryRun,
    List<String>? limitToServers,
    List<String>? skipTags,
    List<String>? tags,
    CmdType? type,
  }) {
    return PostDeployCmd(
      advanced: advanced ?? this.advanced,
      configurePostfix: configurePostfix ?? this.configurePostfix,
      continueEvenIfFails: continueEvenIfFails ?? this.continueEvenIfFails,
      debug: debug ?? this.debug,
      dryRun: dryRun ?? this.dryRun,
      limitToServers: limitToServers ?? this.limitToServers,
      skipTags: skipTags ?? this.skipTags,
      tags: tags ?? this.tags,
      type: type ?? this.type,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDeployCmd _$PostDeployCmdFromJson(Map<String, dynamic> json) {
  return PostDeployCmd(
    type: _$enumDecodeNullable(_$CmdTypeEnumMap, json['type']),
    configurePostfix: json['configurePostfix'] as bool,
    limitToServers: (json['limitToServers'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    skipTags:
        (json['skipTags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    advanced: json['advanced'],
    continueEvenIfFails: json['continueEvenIfFails'],
    debug: json['debug'],
    dryRun: json['dryRun'],
  )
    ..deployServices = (json['deployServices'] as List<dynamic>)
        .map((e) => e as String)
        .toList()
    ..onlyProperties = json['onlyProperties'] as bool;
}

Map<String, dynamic> _$PostDeployCmdToJson(PostDeployCmd instance) =>
    <String, dynamic>{
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
      'configurePostfix': instance.configurePostfix,
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
