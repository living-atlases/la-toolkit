// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostDeployCmd.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfPostDeployCmd.copyWith.fieldName(...)`
class _PostDeployCmdCWProxy {
  final PostDeployCmd _value;

  const _PostDeployCmdCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `PostDeployCmd(...).copyWithNull(...)` to set certain fields to `null`. Prefer `PostDeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  PostDeployCmd call({
    bool? advanced,
    bool? configurePostfix,
    bool? continueEvenIfFails,
    bool? debug,
    bool? dryRun,
    List<String>? limitToServers,
    List<String>? skipTags,
    List<String>? tags,
  }) {
    return PostDeployCmd(
      advanced: advanced ?? _value.advanced,
      configurePostfix: configurePostfix ?? _value.configurePostfix,
      continueEvenIfFails: continueEvenIfFails ?? _value.continueEvenIfFails,
      debug: debug ?? _value.debug,
      dryRun: dryRun ?? _value.dryRun,
      limitToServers: limitToServers ?? _value.limitToServers,
      skipTags: skipTags ?? _value.skipTags,
      tags: tags ?? _value.tags,
    );
  }

  PostDeployCmd limitToServers(List<String>? limitToServers) =>
      limitToServers == null
          ? _value._copyWithNull(limitToServers: true)
          : this(limitToServers: limitToServers);

  PostDeployCmd skipTags(List<String>? skipTags) => skipTags == null
      ? _value._copyWithNull(skipTags: true)
      : this(skipTags: skipTags);

  PostDeployCmd tags(List<String>? tags) =>
      tags == null ? _value._copyWithNull(tags: true) : this(tags: tags);

  PostDeployCmd advanced(bool advanced) => this(advanced: advanced);

  PostDeployCmd configurePostfix(bool configurePostfix) =>
      this(configurePostfix: configurePostfix);

  PostDeployCmd continueEvenIfFails(bool continueEvenIfFails) =>
      this(continueEvenIfFails: continueEvenIfFails);

  PostDeployCmd debug(bool debug) => this(debug: debug);

  PostDeployCmd dryRun(bool dryRun) => this(dryRun: dryRun);
}

extension PostDeployCmdCopyWith on PostDeployCmd {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass PostDeployCmd extends DeployCmd.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass PostDeployCmd extends DeployCmd.name.copyWith.fieldName(...)`
  _PostDeployCmdCWProxy get copyWith => _PostDeployCmdCWProxy(this);

  PostDeployCmd _copyWithNull({
    bool limitToServers = false,
    bool skipTags = false,
    bool tags = false,
  }) {
    return PostDeployCmd(
      advanced: advanced,
      configurePostfix: configurePostfix,
      continueEvenIfFails: continueEvenIfFails,
      debug: debug,
      dryRun: dryRun,
      limitToServers: limitToServers == true ? null : this.limitToServers,
      skipTags: skipTags == true ? null : this.skipTags,
      tags: tags == true ? null : this.tags,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDeployCmd _$PostDeployCmdFromJson(Map<String, dynamic> json) =>
    PostDeployCmd(
      configurePostfix: json['configurePostfix'] as bool? ?? true,
      limitToServers: (json['limitToServers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      skipTags: (json['skipTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      advanced: json['advanced'] as bool? ?? false,
      continueEvenIfFails: json['continueEvenIfFails'] as bool? ?? false,
      debug: json['debug'] as bool? ?? false,
      dryRun: json['dryRun'] as bool? ?? false,
    )
      ..deployServices = (json['deployServices'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..onlyProperties = json['onlyProperties'] as bool;

Map<String, dynamic> _$PostDeployCmdToJson(PostDeployCmd instance) =>
    <String, dynamic>{
      'deployServices': instance.deployServices,
      'limitToServers': instance.limitToServers,
      'skipTags': instance.skipTags,
      'advanced': instance.advanced,
      'onlyProperties': instance.onlyProperties,
      'continueEvenIfFails': instance.continueEvenIfFails,
      'debug': instance.debug,
      'dryRun': instance.dryRun,
      'configurePostfix': instance.configurePostfix,
      'tags': instance.tags,
    };
