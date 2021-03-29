// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension PreDeployCmdCopyWith on PreDeployCmd {
  PreDeployCmd copyWith({
    bool? addUbuntuUser,
    dynamic? advanced,
    dynamic? continueEvenIfFails,
    dynamic? debug,
    dynamic? dryRun,
    bool? etcHost,
    bool? giveSudo,
    dynamic? limitToServers,
    dynamic? skipTags,
    bool? solrLimits,
    dynamic? tags,
  }) {
    return PreDeployCmd(
      addAnsibleUser: addUbuntuUser ?? this.addAnsibleUser,
      advanced: advanced ?? this.advanced,
      continueEvenIfFails: continueEvenIfFails ?? this.continueEvenIfFails,
      debug: debug ?? this.debug,
      dryRun: dryRun ?? this.dryRun,
      etcHosts: etcHost ?? this.etcHosts,
      giveSudo: giveSudo ?? this.giveSudo,
      limitToServers: limitToServers ?? this.limitToServers,
      skipTags: skipTags ?? this.skipTags,
      solrLimits: solrLimits ?? this.solrLimits,
      tags: tags ?? this.tags,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreDeployCmd _$PreDeployCmdFromJson(Map<String, dynamic> json) {
  return PreDeployCmd(
    addAnsibleUser: json['addUbuntuUser'] as bool,
    giveSudo: json['giveSudo'] as bool,
    etcHosts: json['etcHost'] as bool,
    solrLimits: json['solrLimits'] as bool,
    limitToServers: json['limitToServers'],
    skipTags: json['skipTags'],
    tags: json['tags'],
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
      'addUbuntuUser': instance.addAnsibleUser,
      'giveSudo': instance.giveSudo,
      'etcHost': instance.etcHosts,
      'solrLimits': instance.solrLimits,
    };
