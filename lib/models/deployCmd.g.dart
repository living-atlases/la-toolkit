// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DeployCmdCWProxy {
  DeployCmd deployServices(List<String>? deployServices);

  DeployCmd limitToServers(List<String>? limitToServers);

  DeployCmd skipTags(List<String>? skipTags);

  DeployCmd tags(List<String>? tags);

  DeployCmd advanced(bool advanced);

  DeployCmd onlyProperties(bool onlyProperties);

  DeployCmd continueEvenIfFails(bool continueEvenIfFails);

  DeployCmd debug(bool debug);

  DeployCmd dryRun(bool dryRun);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  DeployCmd call({
    List<String>? deployServices,
    List<String>? limitToServers,
    List<String>? skipTags,
    List<String>? tags,
    bool advanced,
    bool onlyProperties,
    bool continueEvenIfFails,
    bool debug,
    bool dryRun,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDeployCmd.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDeployCmd.copyWith.fieldName(...)`
class _$DeployCmdCWProxyImpl implements _$DeployCmdCWProxy {
  const _$DeployCmdCWProxyImpl(this._value);

  final DeployCmd _value;

  @override
  DeployCmd deployServices(List<String>? deployServices) =>
      this(deployServices: deployServices);

  @override
  DeployCmd limitToServers(List<String>? limitToServers) =>
      this(limitToServers: limitToServers);

  @override
  DeployCmd skipTags(List<String>? skipTags) => this(skipTags: skipTags);

  @override
  DeployCmd tags(List<String>? tags) => this(tags: tags);

  @override
  DeployCmd advanced(bool advanced) => this(advanced: advanced);

  @override
  DeployCmd onlyProperties(bool onlyProperties) =>
      this(onlyProperties: onlyProperties);

  @override
  DeployCmd continueEvenIfFails(bool continueEvenIfFails) =>
      this(continueEvenIfFails: continueEvenIfFails);

  @override
  DeployCmd debug(bool debug) => this(debug: debug);

  @override
  DeployCmd dryRun(bool dryRun) => this(dryRun: dryRun);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  DeployCmd call({
    Object? deployServices = const $CopyWithPlaceholder(),
    Object? limitToServers = const $CopyWithPlaceholder(),
    Object? skipTags = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? advanced = const $CopyWithPlaceholder(),
    Object? onlyProperties = const $CopyWithPlaceholder(),
    Object? continueEvenIfFails = const $CopyWithPlaceholder(),
    Object? debug = const $CopyWithPlaceholder(),
    Object? dryRun = const $CopyWithPlaceholder(),
  }) {
    return DeployCmd(
      deployServices: deployServices == const $CopyWithPlaceholder()
          ? _value.deployServices
          // ignore: cast_nullable_to_non_nullable
          : deployServices as List<String>?,
      limitToServers: limitToServers == const $CopyWithPlaceholder()
          ? _value.limitToServers
          // ignore: cast_nullable_to_non_nullable
          : limitToServers as List<String>?,
      skipTags: skipTags == const $CopyWithPlaceholder()
          ? _value.skipTags
          // ignore: cast_nullable_to_non_nullable
          : skipTags as List<String>?,
      tags: tags == const $CopyWithPlaceholder()
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as List<String>?,
      advanced: advanced == const $CopyWithPlaceholder()
          ? _value.advanced
          // ignore: cast_nullable_to_non_nullable
          : advanced as bool,
      onlyProperties: onlyProperties == const $CopyWithPlaceholder()
          ? _value.onlyProperties
          // ignore: cast_nullable_to_non_nullable
          : onlyProperties as bool,
      continueEvenIfFails: continueEvenIfFails == const $CopyWithPlaceholder()
          ? _value.continueEvenIfFails
          // ignore: cast_nullable_to_non_nullable
          : continueEvenIfFails as bool,
      debug: debug == const $CopyWithPlaceholder()
          ? _value.debug
          // ignore: cast_nullable_to_non_nullable
          : debug as bool,
      dryRun: dryRun == const $CopyWithPlaceholder()
          ? _value.dryRun
          // ignore: cast_nullable_to_non_nullable
          : dryRun as bool,
    );
  }
}

extension $DeployCmdCopyWith on DeployCmd {
  /// Returns a callable class that can be used as follows: `instanceOfDeployCmd.copyWith(...)` or like so:`instanceOfDeployCmd.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DeployCmdCWProxy get copyWith => _$DeployCmdCWProxyImpl(this);
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
