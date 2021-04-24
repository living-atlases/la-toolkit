// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension PreDeployCmdCopyWith on PreDeployCmd {
  PreDeployCmd copyWith({
    bool? addAdditionalDeps,
    bool? addAnsibleUser,
    bool? addSshKeys,
    dynamic? advanced,
    dynamic? continueEvenIfFails,
    dynamic? debug,
    dynamic? dryRun,
    bool? etcHosts,
    bool? giveSudo,
    List<String>? limitToServers,
    List<String>? skipTags,
    bool? solrLimits,
    List<String>? tags,
    CmdType? type,
  }) {
    return PreDeployCmd(
      addAdditionalDeps: addAdditionalDeps ?? this.addAdditionalDeps,
      addAnsibleUser: addAnsibleUser ?? this.addAnsibleUser,
      addSshKeys: addSshKeys ?? this.addSshKeys,
      advanced: advanced ?? this.advanced,
      continueEvenIfFails: continueEvenIfFails ?? this.continueEvenIfFails,
      debug: debug ?? this.debug,
      dryRun: dryRun ?? this.dryRun,
      etcHosts: etcHosts ?? this.etcHosts,
      giveSudo: giveSudo ?? this.giveSudo,
      limitToServers: limitToServers ?? this.limitToServers,
      skipTags: skipTags ?? this.skipTags,
      solrLimits: solrLimits ?? this.solrLimits,
      tags: tags ?? this.tags,
      type: type ?? this.type,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreDeployCmd _$PreDeployCmdFromJson(Map<String, dynamic> json) {
  return PreDeployCmd(
    type: _$enumDecodeNullable(_$CmdTypeEnumMap, json['type']),
    addAnsibleUser: json['addAnsibleUser'] as bool,
    addSshKeys: json['addSshKeys'] as bool,
    giveSudo: json['giveSudo'] as bool,
    etcHosts: json['etcHosts'] as bool,
    solrLimits: json['solrLimits'] as bool,
    addAdditionalDeps: json['addAdditionalDeps'] as bool,
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

Map<String, dynamic> _$PreDeployCmdToJson(PreDeployCmd instance) =>
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
      'addAnsibleUser': instance.addAnsibleUser,
      'addSshKeys': instance.addSshKeys,
      'giveSudo': instance.giveSudo,
      'etcHosts': instance.etcHosts,
      'solrLimits': instance.solrLimits,
      'addAdditionalDeps': instance.addAdditionalDeps,
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
