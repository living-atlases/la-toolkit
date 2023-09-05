// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'postDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PostDeployCmdCWProxy {
  PostDeployCmd configurePostfix(bool configurePostfix);

  PostDeployCmd limitToServers(List<String>? limitToServers);

  PostDeployCmd skipTags(List<String>? skipTags);

  PostDeployCmd tags(List<String>? tags);

  PostDeployCmd advanced(bool advanced);

  PostDeployCmd continueEvenIfFails(bool continueEvenIfFails);

  PostDeployCmd debug(bool debug);

  PostDeployCmd dryRun(bool dryRun);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostDeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  PostDeployCmd call({
    bool? configurePostfix,
    List<String>? limitToServers,
    List<String>? skipTags,
    List<String>? tags,
    bool? advanced,
    bool? continueEvenIfFails,
    bool? debug,
    bool? dryRun,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostDeployCmd.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPostDeployCmd.copyWith.fieldName(...)`
class _$PostDeployCmdCWProxyImpl implements _$PostDeployCmdCWProxy {
  const _$PostDeployCmdCWProxyImpl(this._value);

  final PostDeployCmd _value;

  @override
  PostDeployCmd configurePostfix(bool configurePostfix) =>
      this(configurePostfix: configurePostfix);

  @override
  PostDeployCmd limitToServers(List<String>? limitToServers) =>
      this(limitToServers: limitToServers);

  @override
  PostDeployCmd skipTags(List<String>? skipTags) => this(skipTags: skipTags);

  @override
  PostDeployCmd tags(List<String>? tags) => this(tags: tags);

  @override
  PostDeployCmd advanced(bool advanced) => this(advanced: advanced);

  @override
  PostDeployCmd continueEvenIfFails(bool continueEvenIfFails) =>
      this(continueEvenIfFails: continueEvenIfFails);

  @override
  PostDeployCmd debug(bool debug) => this(debug: debug);

  @override
  PostDeployCmd dryRun(bool dryRun) => this(dryRun: dryRun);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostDeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  PostDeployCmd call({
    Object? configurePostfix = const $CopyWithPlaceholder(),
    Object? limitToServers = const $CopyWithPlaceholder(),
    Object? skipTags = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? advanced = const $CopyWithPlaceholder(),
    Object? continueEvenIfFails = const $CopyWithPlaceholder(),
    Object? debug = const $CopyWithPlaceholder(),
    Object? dryRun = const $CopyWithPlaceholder(),
  }) {
    return PostDeployCmd(
      configurePostfix: configurePostfix == const $CopyWithPlaceholder() ||
              configurePostfix == null
          ? _value.configurePostfix
          // ignore: cast_nullable_to_non_nullable
          : configurePostfix as bool,
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
      advanced: advanced == const $CopyWithPlaceholder() || advanced == null
          ? _value.advanced
          // ignore: cast_nullable_to_non_nullable
          : advanced as bool,
      continueEvenIfFails:
          continueEvenIfFails == const $CopyWithPlaceholder() ||
                  continueEvenIfFails == null
              ? _value.continueEvenIfFails
              // ignore: cast_nullable_to_non_nullable
              : continueEvenIfFails as bool,
      debug: debug == const $CopyWithPlaceholder() || debug == null
          ? _value.debug
          // ignore: cast_nullable_to_non_nullable
          : debug as bool,
      dryRun: dryRun == const $CopyWithPlaceholder() || dryRun == null
          ? _value.dryRun
          // ignore: cast_nullable_to_non_nullable
          : dryRun as bool,
    );
  }
}

extension $PostDeployCmdCopyWith on PostDeployCmd {
  /// Returns a callable class that can be used as follows: `instanceOfPostDeployCmd.copyWith(...)` or like so:`instanceOfPostDeployCmd.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PostDeployCmdCWProxy get copyWith => _$PostDeployCmdCWProxyImpl(this);
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
