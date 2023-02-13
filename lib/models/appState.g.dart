// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appState.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfAppState.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfAppState.copyWith.fieldName(...)`
class _AppStateCWProxy {
  final AppState _value;

  const _AppStateCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `AppState(...).copyWithNull(...)` to set certain fields to `null`. Prefer `AppState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppState(...).copyWith(id: 12, name: "My name")
  /// ````
  AppState call({
    List<String>? alaInstallReleases,
    List<AppSnackBarMessage>? appSnackBarMessages,
    String? backendVersion,
    LAProject? currentProject,
    int? currentStep,
    int? currentTuneTab,
    bool? failedLoad,
    bool? firstUsage,
    List<String>? generatorReleases,
    Map<String, LAReleases>? laReleases,
    DateTime? lastSwCheck,
    bool? loading,
    PackageInfo? pkgInfo,
    List<LAProject>? projects,
    CommonCmd? repeatCmd,
    List<SshKey>? sshKeys,
    LAProjectViewStatus? status,
  }) {
    return AppState(
      alaInstallReleases: alaInstallReleases ?? _value.alaInstallReleases,
      appSnackBarMessages: appSnackBarMessages ?? _value.appSnackBarMessages,
      backendVersion: backendVersion ?? _value.backendVersion,
      currentProject: currentProject ?? _value.currentProject,
      currentStep: currentStep ?? _value.currentStep,
      currentTuneTab: currentTuneTab ?? _value.currentTuneTab,
      failedLoad: failedLoad ?? _value.failedLoad,
      firstUsage: firstUsage ?? _value.firstUsage,
      generatorReleases: generatorReleases ?? _value.generatorReleases,
      laReleases: laReleases ?? _value.laReleases,
      lastSwCheck: lastSwCheck ?? _value.lastSwCheck,
      loading: loading ?? _value.loading,
      pkgInfo: pkgInfo ?? _value.pkgInfo,
      projects: projects ?? _value.projects,
      repeatCmd: repeatCmd ?? _value.repeatCmd,
      sshKeys: sshKeys ?? _value.sshKeys,
      status: status ?? _value.status,
    );
  }

  AppState alaInstallReleases(List<String>? alaInstallReleases) =>
      alaInstallReleases == null
          ? _value._copyWithNull(alaInstallReleases: true)
          : this(alaInstallReleases: alaInstallReleases);

  AppState appSnackBarMessages(List<AppSnackBarMessage>? appSnackBarMessages) =>
      appSnackBarMessages == null
          ? _value._copyWithNull(appSnackBarMessages: true)
          : this(appSnackBarMessages: appSnackBarMessages);

  AppState backendVersion(String? backendVersion) => backendVersion == null
      ? _value._copyWithNull(backendVersion: true)
      : this(backendVersion: backendVersion);

  AppState currentProject(LAProject? currentProject) => currentProject == null
      ? _value._copyWithNull(currentProject: true)
      : this(currentProject: currentProject);

  AppState generatorReleases(List<String>? generatorReleases) =>
      generatorReleases == null
          ? _value._copyWithNull(generatorReleases: true)
          : this(generatorReleases: generatorReleases);

  AppState laReleases(Map<String, LAReleases>? laReleases) => laReleases == null
      ? _value._copyWithNull(laReleases: true)
      : this(laReleases: laReleases);

  AppState lastSwCheck(DateTime? lastSwCheck) => lastSwCheck == null
      ? _value._copyWithNull(lastSwCheck: true)
      : this(lastSwCheck: lastSwCheck);

  AppState loading(bool? loading) => loading == null
      ? _value._copyWithNull(loading: true)
      : this(loading: loading);

  AppState pkgInfo(PackageInfo? pkgInfo) => pkgInfo == null
      ? _value._copyWithNull(pkgInfo: true)
      : this(pkgInfo: pkgInfo);

  AppState projects(List<LAProject>? projects) => projects == null
      ? _value._copyWithNull(projects: true)
      : this(projects: projects);

  AppState repeatCmd(CommonCmd? repeatCmd) => repeatCmd == null
      ? _value._copyWithNull(repeatCmd: true)
      : this(repeatCmd: repeatCmd);

  AppState sshKeys(List<SshKey>? sshKeys) => sshKeys == null
      ? _value._copyWithNull(sshKeys: true)
      : this(sshKeys: sshKeys);

  AppState status(LAProjectViewStatus? status) => status == null
      ? _value._copyWithNull(status: true)
      : this(status: status);

  AppState currentStep(int currentStep) => this(currentStep: currentStep);

  AppState currentTuneTab(int currentTuneTab) =>
      this(currentTuneTab: currentTuneTab);

  AppState failedLoad(bool failedLoad) => this(failedLoad: failedLoad);

  AppState firstUsage(bool firstUsage) => this(firstUsage: firstUsage);
}

extension AppStateCopyWith on AppState {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass AppState.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass AppState.name.copyWith.fieldName(...)`
  _AppStateCWProxy get copyWith => _AppStateCWProxy(this);

  AppState _copyWithNull({
    bool alaInstallReleases = false,
    bool appSnackBarMessages = false,
    bool backendVersion = false,
    bool currentProject = false,
    bool generatorReleases = false,
    bool laReleases = false,
    bool lastSwCheck = false,
    bool loading = false,
    bool pkgInfo = false,
    bool projects = false,
    bool repeatCmd = false,
    bool sshKeys = false,
    bool status = false,
  }) {
    return AppState(
      alaInstallReleases:
          alaInstallReleases == true ? null : this.alaInstallReleases,
      appSnackBarMessages:
          appSnackBarMessages == true ? null : this.appSnackBarMessages,
      backendVersion: backendVersion == true ? null : this.backendVersion,
      currentProject: currentProject == true ? null : this.currentProject,
      currentStep: currentStep,
      currentTuneTab: currentTuneTab,
      failedLoad: failedLoad,
      firstUsage: firstUsage,
      generatorReleases:
          generatorReleases == true ? null : this.generatorReleases,
      laReleases: laReleases == true ? null : this.laReleases,
      lastSwCheck: lastSwCheck == true ? null : this.lastSwCheck,
      loading: loading == true ? null : this.loading,
      pkgInfo: pkgInfo == true ? null : this.pkgInfo,
      projects: projects == true ? null : this.projects,
      repeatCmd: repeatCmd == true ? null : this.repeatCmd,
      sshKeys: sshKeys == true ? null : this.sshKeys,
      status: status == true ? null : this.status,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) => AppState(
      projects: (json['projects'] as List<dynamic>?)
          ?.map((e) => LAProject.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstUsage: json['firstUsage'] as bool? ?? true,
      currentProject: json['currentProject'] == null
          ? null
          : LAProject.fromJson(json['currentProject'] as Map<String, dynamic>),
      currentStep: json['currentStep'] as int? ?? 0,
      currentTuneTab: json['currentTuneTab'] as int? ?? 0,
      status: $enumDecodeNullable(_$LAProjectViewStatusEnumMap, json['status']),
      alaInstallReleases: (json['alaInstallReleases'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      generatorReleases: (json['generatorReleases'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      laReleases: (json['laReleases'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, LAReleases.fromJson(e as Map<String, dynamic>)),
      ),
      lastSwCheck: json['lastSwCheck'] == null
          ? null
          : DateTime.parse(json['lastSwCheck'] as String),
      sshKeys: (json['sshKeys'] as List<dynamic>?)
          ?.map((e) => SshKey.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AppStateToJson(AppState instance) => <String, dynamic>{
      'firstUsage': instance.firstUsage,
      'currentProject': instance.currentProject.toJson(),
      'status': _$LAProjectViewStatusEnumMap[instance.status],
      'currentStep': instance.currentStep,
      'currentTuneTab': instance.currentTuneTab,
      'projects': instance.projects.map((e) => e.toJson()).toList(),
      'alaInstallReleases': instance.alaInstallReleases,
      'generatorReleases': instance.generatorReleases,
      'laReleases': instance.laReleases.map((k, e) => MapEntry(k, e.toJson())),
      'sshKeys': instance.sshKeys.map((e) => e.toJson()).toList(),
      'lastSwCheck': instance.lastSwCheck?.toIso8601String(),
    };

const _$LAProjectViewStatusEnumMap = {
  LAProjectViewStatus.view: 'view',
  LAProjectViewStatus.edit: 'edit',
  LAProjectViewStatus.servers: 'servers',
  LAProjectViewStatus.tune: 'tune',
  LAProjectViewStatus.create: 'create',
};
