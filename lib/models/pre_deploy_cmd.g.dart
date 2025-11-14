// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_deploy_cmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PreDeployCmdCWProxy {
  PreDeployCmd addAnsibleUser(bool addAnsibleUser);

  PreDeployCmd addSshKeys(bool addSshKeys);

  PreDeployCmd giveSudo(bool giveSudo);

  PreDeployCmd etcHosts(bool etcHosts);

  PreDeployCmd solrLimits(bool solrLimits);

  PreDeployCmd addAdditionalDeps(bool addAdditionalDeps);

  PreDeployCmd rootBecome(bool? rootBecome);

  PreDeployCmd limitToServers(List<String>? limitToServers);

  PreDeployCmd skipTags(List<String>? skipTags);

  PreDeployCmd tags(List<String>? tags);

  PreDeployCmd advanced(bool advanced);

  PreDeployCmd continueEvenIfFails(bool continueEvenIfFails);

  PreDeployCmd debug(bool debug);

  PreDeployCmd dryRun(bool dryRun);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PreDeployCmd(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PreDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ```
  PreDeployCmd call({
    bool addAnsibleUser,
    bool addSshKeys,
    bool giveSudo,
    bool etcHosts,
    bool solrLimits,
    bool addAdditionalDeps,
    bool? rootBecome,
    List<String>? limitToServers,
    List<String>? skipTags,
    List<String>? tags,
    bool advanced,
    bool continueEvenIfFails,
    bool debug,
    bool dryRun,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPreDeployCmd.copyWith(...)` or call `instanceOfPreDeployCmd.copyWith.fieldName(value)` for a single field.
class _$PreDeployCmdCWProxyImpl implements _$PreDeployCmdCWProxy {
  const _$PreDeployCmdCWProxyImpl(this._value);

  final PreDeployCmd _value;

  @override
  PreDeployCmd addAnsibleUser(bool addAnsibleUser) => call(addAnsibleUser: addAnsibleUser);

  @override
  PreDeployCmd addSshKeys(bool addSshKeys) => call(addSshKeys: addSshKeys);

  @override
  PreDeployCmd giveSudo(bool giveSudo) => call(giveSudo: giveSudo);

  @override
  PreDeployCmd etcHosts(bool etcHosts) => call(etcHosts: etcHosts);

  @override
  PreDeployCmd solrLimits(bool solrLimits) => call(solrLimits: solrLimits);

  @override
  PreDeployCmd addAdditionalDeps(bool addAdditionalDeps) => call(addAdditionalDeps: addAdditionalDeps);

  @override
  PreDeployCmd rootBecome(bool? rootBecome) => call(rootBecome: rootBecome);

  @override
  PreDeployCmd limitToServers(List<String>? limitToServers) => call(limitToServers: limitToServers);

  @override
  PreDeployCmd skipTags(List<String>? skipTags) => call(skipTags: skipTags);

  @override
  PreDeployCmd tags(List<String>? tags) => call(tags: tags);

  @override
  PreDeployCmd advanced(bool advanced) => call(advanced: advanced);

  @override
  PreDeployCmd continueEvenIfFails(bool continueEvenIfFails) => call(continueEvenIfFails: continueEvenIfFails);

  @override
  PreDeployCmd debug(bool debug) => call(debug: debug);

  @override
  PreDeployCmd dryRun(bool dryRun) => call(dryRun: dryRun);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PreDeployCmd(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PreDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ```
  PreDeployCmd call({
    Object? addAnsibleUser = const $CopyWithPlaceholder(),
    Object? addSshKeys = const $CopyWithPlaceholder(),
    Object? giveSudo = const $CopyWithPlaceholder(),
    Object? etcHosts = const $CopyWithPlaceholder(),
    Object? solrLimits = const $CopyWithPlaceholder(),
    Object? addAdditionalDeps = const $CopyWithPlaceholder(),
    Object? rootBecome = const $CopyWithPlaceholder(),
    Object? limitToServers = const $CopyWithPlaceholder(),
    Object? skipTags = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? advanced = const $CopyWithPlaceholder(),
    Object? continueEvenIfFails = const $CopyWithPlaceholder(),
    Object? debug = const $CopyWithPlaceholder(),
    Object? dryRun = const $CopyWithPlaceholder(),
  }) {
    return PreDeployCmd(
      addAnsibleUser: addAnsibleUser == const $CopyWithPlaceholder() || addAnsibleUser == null
          ? _value.addAnsibleUser
          // ignore: cast_nullable_to_non_nullable
          : addAnsibleUser as bool,
      addSshKeys: addSshKeys == const $CopyWithPlaceholder() || addSshKeys == null
          ? _value.addSshKeys
          // ignore: cast_nullable_to_non_nullable
          : addSshKeys as bool,
      giveSudo: giveSudo == const $CopyWithPlaceholder() || giveSudo == null
          ? _value.giveSudo
          // ignore: cast_nullable_to_non_nullable
          : giveSudo as bool,
      etcHosts: etcHosts == const $CopyWithPlaceholder() || etcHosts == null
          ? _value.etcHosts
          // ignore: cast_nullable_to_non_nullable
          : etcHosts as bool,
      solrLimits: solrLimits == const $CopyWithPlaceholder() || solrLimits == null
          ? _value.solrLimits
          // ignore: cast_nullable_to_non_nullable
          : solrLimits as bool,
      addAdditionalDeps: addAdditionalDeps == const $CopyWithPlaceholder() || addAdditionalDeps == null
          ? _value.addAdditionalDeps
          // ignore: cast_nullable_to_non_nullable
          : addAdditionalDeps as bool,
      rootBecome: rootBecome == const $CopyWithPlaceholder()
          ? _value.rootBecome
          // ignore: cast_nullable_to_non_nullable
          : rootBecome as bool?,
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
      continueEvenIfFails: continueEvenIfFails == const $CopyWithPlaceholder() || continueEvenIfFails == null
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

extension $PreDeployCmdCopyWith on PreDeployCmd {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPreDeployCmd.copyWith(...)` or `instanceOfPreDeployCmd.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PreDeployCmdCWProxy get copyWith => _$PreDeployCmdCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PreDeployCmd _$PreDeployCmdFromJson(Map<String, dynamic> json) => PreDeployCmd(
      addAnsibleUser: json['addAnsibleUser'] as bool? ?? false,
      addSshKeys: json['addSshKeys'] as bool? ?? false,
      giveSudo: json['giveSudo'] as bool? ?? false,
      etcHosts: json['etcHosts'] as bool? ?? true,
      solrLimits: json['solrLimits'] as bool? ?? true,
      addAdditionalDeps: json['addAdditionalDeps'] as bool? ?? true,
      rootBecome: json['rootBecome'] as bool?,
      limitToServers: (json['limitToServers'] as List<dynamic>?)?.map((e) => e as String).toList(),
      skipTags: (json['skipTags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      advanced: json['advanced'] as bool? ?? false,
      continueEvenIfFails: json['continueEvenIfFails'] as bool? ?? false,
      debug: json['debug'] as bool? ?? false,
      dryRun: json['dryRun'] as bool? ?? false,
    )
      ..deployServices = (json['deployServices'] as List<dynamic>).map((e) => e as String).toList()
      ..onlyProperties = json['onlyProperties'] as bool;

Map<String, dynamic> _$PreDeployCmdToJson(PreDeployCmd instance) => <String, dynamic>{
      'deployServices': instance.deployServices,
      'limitToServers': instance.limitToServers,
      'skipTags': instance.skipTags,
      'advanced': instance.advanced,
      'onlyProperties': instance.onlyProperties,
      'continueEvenIfFails': instance.continueEvenIfFails,
      'debug': instance.debug,
      'dryRun': instance.dryRun,
      'addAnsibleUser': instance.addAnsibleUser,
      'addSshKeys': instance.addSshKeys,
      'giveSudo': instance.giveSudo,
      'etcHosts': instance.etcHosts,
      'solrLimits': instance.solrLimits,
      'addAdditionalDeps': instance.addAdditionalDeps,
      'rootBecome': instance.rootBecome,
      'tags': instance.tags,
    };
