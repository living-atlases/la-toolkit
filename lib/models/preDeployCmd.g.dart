// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfPreDeployCmd.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfPreDeployCmd.copyWith.fieldName(...)`
class _PreDeployCmdCWProxy {
  final PreDeployCmd _value;

  const _PreDeployCmdCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `PreDeployCmd(...).copyWithNull(...)` to set certain fields to `null`. Prefer `PreDeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PreDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  PreDeployCmd call({
    bool? addAdditionalDeps,
    bool? addAnsibleUser,
    bool? addSshKeys,
    bool? advanced,
    bool? continueEvenIfFails,
    bool? debug,
    bool? dryRun,
    bool? etcHosts,
    bool? giveSudo,
    List<String>? limitToServers,
    bool? rootBecome,
    List<String>? skipTags,
    bool? solrLimits,
    List<String>? tags,
  }) {
    return PreDeployCmd(
      addAdditionalDeps: addAdditionalDeps ?? _value.addAdditionalDeps,
      addAnsibleUser: addAnsibleUser ?? _value.addAnsibleUser,
      addSshKeys: addSshKeys ?? _value.addSshKeys,
      advanced: advanced ?? _value.advanced,
      continueEvenIfFails: continueEvenIfFails ?? _value.continueEvenIfFails,
      debug: debug ?? _value.debug,
      dryRun: dryRun ?? _value.dryRun,
      etcHosts: etcHosts ?? _value.etcHosts,
      giveSudo: giveSudo ?? _value.giveSudo,
      limitToServers: limitToServers ?? _value.limitToServers,
      rootBecome: rootBecome ?? _value.rootBecome,
      skipTags: skipTags ?? _value.skipTags,
      solrLimits: solrLimits ?? _value.solrLimits,
      tags: tags ?? _value.tags,
    );
  }

  PreDeployCmd limitToServers(List<String>? limitToServers) =>
      limitToServers == null
          ? _value._copyWithNull(limitToServers: true)
          : this(limitToServers: limitToServers);

  PreDeployCmd rootBecome(bool? rootBecome) => rootBecome == null
      ? _value._copyWithNull(rootBecome: true)
      : this(rootBecome: rootBecome);

  PreDeployCmd skipTags(List<String>? skipTags) => skipTags == null
      ? _value._copyWithNull(skipTags: true)
      : this(skipTags: skipTags);

  PreDeployCmd tags(List<String>? tags) =>
      tags == null ? _value._copyWithNull(tags: true) : this(tags: tags);

  PreDeployCmd addAdditionalDeps(bool addAdditionalDeps) =>
      this(addAdditionalDeps: addAdditionalDeps);

  PreDeployCmd addAnsibleUser(bool addAnsibleUser) =>
      this(addAnsibleUser: addAnsibleUser);

  PreDeployCmd addSshKeys(bool addSshKeys) => this(addSshKeys: addSshKeys);

  PreDeployCmd advanced(bool advanced) => this(advanced: advanced);

  PreDeployCmd continueEvenIfFails(bool continueEvenIfFails) =>
      this(continueEvenIfFails: continueEvenIfFails);

  PreDeployCmd debug(bool debug) => this(debug: debug);

  PreDeployCmd dryRun(bool dryRun) => this(dryRun: dryRun);

  PreDeployCmd etcHosts(bool etcHosts) => this(etcHosts: etcHosts);

  PreDeployCmd giveSudo(bool giveSudo) => this(giveSudo: giveSudo);

  PreDeployCmd solrLimits(bool solrLimits) => this(solrLimits: solrLimits);
}

extension PreDeployCmdCopyWith on PreDeployCmd {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass PreDeployCmd extends DeployCmd.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass PreDeployCmd extends DeployCmd.name.copyWith.fieldName(...)`
  _PreDeployCmdCWProxy get copyWith => _PreDeployCmdCWProxy(this);

  PreDeployCmd _copyWithNull({
    bool limitToServers = false,
    bool rootBecome = false,
    bool skipTags = false,
    bool tags = false,
  }) {
    return PreDeployCmd(
      addAdditionalDeps: addAdditionalDeps,
      addAnsibleUser: addAnsibleUser,
      addSshKeys: addSshKeys,
      advanced: advanced,
      continueEvenIfFails: continueEvenIfFails,
      debug: debug,
      dryRun: dryRun,
      etcHosts: etcHosts,
      giveSudo: giveSudo,
      limitToServers: limitToServers == true ? null : this.limitToServers,
      rootBecome: rootBecome == true ? null : this.rootBecome,
      skipTags: skipTags == true ? null : this.skipTags,
      solrLimits: solrLimits,
      tags: tags == true ? null : this.tags,
    );
  }
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

Map<String, dynamic> _$PreDeployCmdToJson(PreDeployCmd instance) =>
    <String, dynamic>{
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
