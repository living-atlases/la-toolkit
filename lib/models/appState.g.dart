// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appState.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AppStateCWProxy {
  AppState projects(List<LAProject>? projects);

  AppState failedLoad(bool failedLoad);

  AppState firstUsage(bool firstUsage);

  AppState currentProject(LAProject? currentProject);

  AppState currentStep(int currentStep);

  AppState currentTuneTab(int currentTuneTab);

  AppState status(LAProjectViewStatus? status);

  AppState alaInstallReleases(List<String>? alaInstallReleases);

  AppState generatorReleases(List<String>? generatorReleases);

  AppState appSnackBarMessages(List<AppSnackBarMessage>? appSnackBarMessages);

  AppState laReleases(Map<String, LAReleases>? laReleases);

  AppState repeatCmd(CommonCmd? repeatCmd);

  AppState pkgInfo(PackageInfo? pkgInfo);

  AppState backendVersion(String? backendVersion);

  AppState lastSwCheck(DateTime? lastSwCheck);

  AppState loading(bool? loading);

  AppState depsLoading(bool? depsLoading);

  AppState sshKeys(List<SshKey>? sshKeys);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AppState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppState(...).copyWith(id: 12, name: "My name")
  /// ````
  AppState call({
    List<LAProject>? projects,
    bool? failedLoad,
    bool? firstUsage,
    LAProject? currentProject,
    int? currentStep,
    int? currentTuneTab,
    LAProjectViewStatus? status,
    List<String>? alaInstallReleases,
    List<String>? generatorReleases,
    List<AppSnackBarMessage>? appSnackBarMessages,
    Map<String, LAReleases>? laReleases,
    CommonCmd? repeatCmd,
    PackageInfo? pkgInfo,
    String? backendVersion,
    DateTime? lastSwCheck,
    bool? loading,
    bool? depsLoading,
    List<SshKey>? sshKeys,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAppState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAppState.copyWith.fieldName(...)`
class _$AppStateCWProxyImpl implements _$AppStateCWProxy {
  const _$AppStateCWProxyImpl(this._value);

  final AppState _value;

  @override
  AppState projects(List<LAProject>? projects) => this(projects: projects);

  @override
  AppState failedLoad(bool failedLoad) => this(failedLoad: failedLoad);

  @override
  AppState firstUsage(bool firstUsage) => this(firstUsage: firstUsage);

  @override
  AppState currentProject(LAProject? currentProject) =>
      this(currentProject: currentProject);

  @override
  AppState currentStep(int currentStep) => this(currentStep: currentStep);

  @override
  AppState currentTuneTab(int currentTuneTab) =>
      this(currentTuneTab: currentTuneTab);

  @override
  AppState status(LAProjectViewStatus? status) => this(status: status);

  @override
  AppState alaInstallReleases(List<String>? alaInstallReleases) =>
      this(alaInstallReleases: alaInstallReleases);

  @override
  AppState generatorReleases(List<String>? generatorReleases) =>
      this(generatorReleases: generatorReleases);

  @override
  AppState appSnackBarMessages(List<AppSnackBarMessage>? appSnackBarMessages) =>
      this(appSnackBarMessages: appSnackBarMessages);

  @override
  AppState laReleases(Map<String, LAReleases>? laReleases) =>
      this(laReleases: laReleases);

  @override
  AppState repeatCmd(CommonCmd? repeatCmd) => this(repeatCmd: repeatCmd);

  @override
  AppState pkgInfo(PackageInfo? pkgInfo) => this(pkgInfo: pkgInfo);

  @override
  AppState backendVersion(String? backendVersion) =>
      this(backendVersion: backendVersion);

  @override
  AppState lastSwCheck(DateTime? lastSwCheck) => this(lastSwCheck: lastSwCheck);

  @override
  AppState loading(bool? loading) => this(loading: loading);

  @override
  AppState depsLoading(bool? depsLoading) => this(depsLoading: depsLoading);

  @override
  AppState sshKeys(List<SshKey>? sshKeys) => this(sshKeys: sshKeys);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AppState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AppState(...).copyWith(id: 12, name: "My name")
  /// ````
  AppState call({
    Object? projects = const $CopyWithPlaceholder(),
    Object? failedLoad = const $CopyWithPlaceholder(),
    Object? firstUsage = const $CopyWithPlaceholder(),
    Object? currentProject = const $CopyWithPlaceholder(),
    Object? currentStep = const $CopyWithPlaceholder(),
    Object? currentTuneTab = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? alaInstallReleases = const $CopyWithPlaceholder(),
    Object? generatorReleases = const $CopyWithPlaceholder(),
    Object? appSnackBarMessages = const $CopyWithPlaceholder(),
    Object? laReleases = const $CopyWithPlaceholder(),
    Object? repeatCmd = const $CopyWithPlaceholder(),
    Object? pkgInfo = const $CopyWithPlaceholder(),
    Object? backendVersion = const $CopyWithPlaceholder(),
    Object? lastSwCheck = const $CopyWithPlaceholder(),
    Object? loading = const $CopyWithPlaceholder(),
    Object? depsLoading = const $CopyWithPlaceholder(),
    Object? sshKeys = const $CopyWithPlaceholder(),
  }) {
    return AppState(
      projects: projects == const $CopyWithPlaceholder()
          ? _value.projects
          // ignore: cast_nullable_to_non_nullable
          : projects as List<LAProject>?,
      failedLoad:
          failedLoad == const $CopyWithPlaceholder() || failedLoad == null
              ? _value.failedLoad
              // ignore: cast_nullable_to_non_nullable
              : failedLoad as bool,
      firstUsage:
          firstUsage == const $CopyWithPlaceholder() || firstUsage == null
              ? _value.firstUsage
              // ignore: cast_nullable_to_non_nullable
              : firstUsage as bool,
      currentProject: currentProject == const $CopyWithPlaceholder()
          ? _value.currentProject
          // ignore: cast_nullable_to_non_nullable
          : currentProject as LAProject?,
      currentStep:
          currentStep == const $CopyWithPlaceholder() || currentStep == null
              ? _value.currentStep
              // ignore: cast_nullable_to_non_nullable
              : currentStep as int,
      currentTuneTab: currentTuneTab == const $CopyWithPlaceholder() ||
              currentTuneTab == null
          ? _value.currentTuneTab
          // ignore: cast_nullable_to_non_nullable
          : currentTuneTab as int,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as LAProjectViewStatus?,
      alaInstallReleases: alaInstallReleases == const $CopyWithPlaceholder()
          ? _value.alaInstallReleases
          // ignore: cast_nullable_to_non_nullable
          : alaInstallReleases as List<String>?,
      generatorReleases: generatorReleases == const $CopyWithPlaceholder()
          ? _value.generatorReleases
          // ignore: cast_nullable_to_non_nullable
          : generatorReleases as List<String>?,
      appSnackBarMessages: appSnackBarMessages == const $CopyWithPlaceholder()
          ? _value.appSnackBarMessages
          // ignore: cast_nullable_to_non_nullable
          : appSnackBarMessages as List<AppSnackBarMessage>?,
      laReleases: laReleases == const $CopyWithPlaceholder()
          ? _value.laReleases
          // ignore: cast_nullable_to_non_nullable
          : laReleases as Map<String, LAReleases>?,
      repeatCmd: repeatCmd == const $CopyWithPlaceholder()
          ? _value.repeatCmd
          // ignore: cast_nullable_to_non_nullable
          : repeatCmd as CommonCmd?,
      pkgInfo: pkgInfo == const $CopyWithPlaceholder()
          ? _value.pkgInfo
          // ignore: cast_nullable_to_non_nullable
          : pkgInfo as PackageInfo?,
      backendVersion: backendVersion == const $CopyWithPlaceholder()
          ? _value.backendVersion
          // ignore: cast_nullable_to_non_nullable
          : backendVersion as String?,
      lastSwCheck: lastSwCheck == const $CopyWithPlaceholder()
          ? _value.lastSwCheck
          // ignore: cast_nullable_to_non_nullable
          : lastSwCheck as DateTime?,
      loading: loading == const $CopyWithPlaceholder()
          ? _value.loading
          // ignore: cast_nullable_to_non_nullable
          : loading as bool?,
      depsLoading: depsLoading == const $CopyWithPlaceholder()
          ? _value.depsLoading
          // ignore: cast_nullable_to_non_nullable
          : depsLoading as bool?,
      sshKeys: sshKeys == const $CopyWithPlaceholder()
          ? _value.sshKeys
          // ignore: cast_nullable_to_non_nullable
          : sshKeys as List<SshKey>?,
    );
  }
}

extension $AppStateCopyWith on AppState {
  /// Returns a callable class that can be used as follows: `instanceOfAppState.copyWith(...)` or like so:`instanceOfAppState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AppStateCWProxy get copyWith => _$AppStateCWProxyImpl(this);
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
      'status': _$LAProjectViewStatusEnumMap[instance.status]!,
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
