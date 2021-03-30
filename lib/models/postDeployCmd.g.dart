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
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDeployCmd _$PostDeployCmdFromJson(Map<String, dynamic> json) {
  return PostDeployCmd(
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
      'configurePostfix': instance.configurePostfix,
    };
