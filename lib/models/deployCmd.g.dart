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
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeployCmd _$DeployCmdFromJson(Map<String, dynamic> json) {
  return DeployCmd(
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
    };
