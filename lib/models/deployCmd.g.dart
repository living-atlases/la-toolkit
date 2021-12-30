// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeployCmd.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfDeployCmd.copyWith.fieldName(...)`
class _DeployCmdCWProxy {
  final DeployCmd _value;

  const _DeployCmdCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `DeployCmd(...).copyWithNull(...)` to set certain fields to `null`. Prefer `DeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  DeployCmd call({
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
      advanced: advanced ?? _value.advanced,
      continueEvenIfFails: continueEvenIfFails ?? _value.continueEvenIfFails,
      debug: debug ?? _value.debug,
      deployServices: deployServices ?? _value.deployServices,
      dryRun: dryRun ?? _value.dryRun,
      limitToServers: limitToServers ?? _value.limitToServers,
      onlyProperties: onlyProperties ?? _value.onlyProperties,
      skipTags: skipTags ?? _value.skipTags,
      tags: tags ?? _value.tags,
    );
  }

  DeployCmd deployServices(List<String>? deployServices) =>
      deployServices == null
          ? _value._copyWithNull(deployServices: true)
          : this(deployServices: deployServices);

  DeployCmd limitToServers(List<String>? limitToServers) =>
      limitToServers == null
          ? _value._copyWithNull(limitToServers: true)
          : this(limitToServers: limitToServers);

  DeployCmd skipTags(List<String>? skipTags) => skipTags == null
      ? _value._copyWithNull(skipTags: true)
      : this(skipTags: skipTags);

  DeployCmd tags(List<String>? tags) =>
      tags == null ? _value._copyWithNull(tags: true) : this(tags: tags);

  DeployCmd advanced(bool advanced) => this(advanced: advanced);

  DeployCmd continueEvenIfFails(bool continueEvenIfFails) =>
      this(continueEvenIfFails: continueEvenIfFails);

  DeployCmd debug(bool debug) => this(debug: debug);

  DeployCmd dryRun(bool dryRun) => this(dryRun: dryRun);

  DeployCmd onlyProperties(bool onlyProperties) =>
      this(onlyProperties: onlyProperties);
}

extension DeployCmdCopyWith on DeployCmd {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass DeployCmd extends CommonCmd.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass DeployCmd extends CommonCmd.name.copyWith.fieldName(...)`
  _DeployCmdCWProxy get copyWith => _DeployCmdCWProxy(this);

  DeployCmd _copyWithNull({
    bool deployServices = false,
    bool limitToServers = false,
    bool skipTags = false,
    bool tags = false,
  }) {
    return DeployCmd(
      advanced: advanced,
      continueEvenIfFails: continueEvenIfFails,
      debug: debug,
      deployServices: deployServices == true ? null : this.deployServices,
      dryRun: dryRun,
      limitToServers: limitToServers == true ? null : this.limitToServers,
      onlyProperties: onlyProperties,
      skipTags: skipTags == true ? null : this.skipTags,
      tags: tags == true ? null : this.tags,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeployCmd _$DeployCmdFromJson(Map<String, dynamic> json) => DeployCmd(
      deployServices: (json['deployServices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      limitToServers: (json['limitToServers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      skipTags: (json['skipTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      advanced: json['advanced'] as bool? ?? false,
      onlyProperties: json['onlyProperties'] as bool? ?? false,
      continueEvenIfFails: json['continueEvenIfFails'] as bool? ?? false,
      debug: json['debug'] as bool? ?? false,
      dryRun: json['dryRun'] as bool? ?? false,
    );

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
