// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

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

  AppState serviceCheckProgress(Map<String, Map<String, dynamic>>? serviceCheckProgress);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AppState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AppState(...).copyWith(id: 12, name: "My name")
  /// ```
  AppState call({
    List<LAProject>? projects,
    bool failedLoad,
    bool firstUsage,
    LAProject? currentProject,
    int currentStep,
    int currentTuneTab,
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
    Map<String, Map<String, dynamic>>? serviceCheckProgress,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfAppState.copyWith(...)` or call `instanceOfAppState.copyWith.fieldName(value)` for a single field.
class _$AppStateCWProxyImpl implements _$AppStateCWProxy {
  const _$AppStateCWProxyImpl(this._value);

  final AppState _value;

  @override
  AppState projects(List<LAProject>? projects) => call(projects: projects);

  @override
  AppState failedLoad(bool failedLoad) => call(failedLoad: failedLoad);

  @override
  AppState firstUsage(bool firstUsage) => call(firstUsage: firstUsage);

  @override
  AppState currentProject(LAProject? currentProject) => call(currentProject: currentProject);

  @override
  AppState currentStep(int currentStep) => call(currentStep: currentStep);

  @override
  AppState currentTuneTab(int currentTuneTab) => call(currentTuneTab: currentTuneTab);

  @override
  AppState status(LAProjectViewStatus? status) => call(status: status);

  @override
  AppState alaInstallReleases(List<String>? alaInstallReleases) => call(alaInstallReleases: alaInstallReleases);

  @override
  AppState generatorReleases(List<String>? generatorReleases) => call(generatorReleases: generatorReleases);

  @override
  AppState appSnackBarMessages(List<AppSnackBarMessage>? appSnackBarMessages) =>
      call(appSnackBarMessages: appSnackBarMessages);

  @override
  AppState laReleases(Map<String, LAReleases>? laReleases) => call(laReleases: laReleases);

  @override
  AppState repeatCmd(CommonCmd? repeatCmd) => call(repeatCmd: repeatCmd);

  @override
  AppState pkgInfo(PackageInfo? pkgInfo) => call(pkgInfo: pkgInfo);

  @override
  AppState backendVersion(String? backendVersion) => call(backendVersion: backendVersion);

  @override
  AppState lastSwCheck(DateTime? lastSwCheck) => call(lastSwCheck: lastSwCheck);

  @override
  AppState loading(bool? loading) => call(loading: loading);

  @override
  AppState depsLoading(bool? depsLoading) => call(depsLoading: depsLoading);

  @override
  AppState sshKeys(List<SshKey>? sshKeys) => call(sshKeys: sshKeys);

  @override
  AppState serviceCheckProgress(Map<String, Map<String, dynamic>>? serviceCheckProgress) =>
      call(serviceCheckProgress: serviceCheckProgress);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `AppState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// AppState(...).copyWith(id: 12, name: "My name")
  /// ```
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
    Object? serviceCheckProgress = const $CopyWithPlaceholder(),
  }) {
    return AppState(
      projects: projects == const $CopyWithPlaceholder()
          ? _value.projects
          // ignore: cast_nullable_to_non_nullable
          : projects as List<LAProject>?,
      failedLoad: failedLoad == const $CopyWithPlaceholder() || failedLoad == null
          ? _value.failedLoad
          // ignore: cast_nullable_to_non_nullable
          : failedLoad as bool,
      firstUsage: firstUsage == const $CopyWithPlaceholder() || firstUsage == null
          ? _value.firstUsage
          // ignore: cast_nullable_to_non_nullable
          : firstUsage as bool,
      currentProject: currentProject == const $CopyWithPlaceholder()
          ? _value.currentProject
          // ignore: cast_nullable_to_non_nullable
          : currentProject as LAProject?,
      currentStep: currentStep == const $CopyWithPlaceholder() || currentStep == null
          ? _value.currentStep
          // ignore: cast_nullable_to_non_nullable
          : currentStep as int,
      currentTuneTab: currentTuneTab == const $CopyWithPlaceholder() || currentTuneTab == null
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
      serviceCheckProgress: serviceCheckProgress == const $CopyWithPlaceholder()
          ? _value.serviceCheckProgress
          // ignore: cast_nullable_to_non_nullable
          : serviceCheckProgress as Map<String, Map<String, dynamic>>?,
    );
  }
}

extension $AppStateCopyWith on AppState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfAppState.copyWith(...)` or `instanceOfAppState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AppStateCWProxy get copyWith => _$AppStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) => AppState(
      projects:
          (json['projects'] as List<dynamic>?)?.map((e) => LAProject.fromJson(e as Map<String, dynamic>)).toList(),
      firstUsage: json['firstUsage'] as bool? ?? true,
      currentProject:
          json['currentProject'] == null ? null : LAProject.fromJson(json['currentProject'] as Map<String, dynamic>),
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      currentTuneTab: (json['currentTuneTab'] as num?)?.toInt() ?? 0,
      status: $enumDecodeNullable(_$LAProjectViewStatusEnumMap, json['status']),
      alaInstallReleases: (json['alaInstallReleases'] as List<dynamic>?)?.map((e) => e as String).toList(),
      generatorReleases: (json['generatorReleases'] as List<dynamic>?)?.map((e) => e as String).toList(),
      laReleases: (json['laReleases'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, LAReleases.fromJson(e as Map<String, dynamic>)),
      ),
      lastSwCheck: json['lastSwCheck'] == null ? null : DateTime.parse(json['lastSwCheck'] as String),
      sshKeys: (json['sshKeys'] as List<dynamic>?)?.map((e) => SshKey.fromJson(e as Map<String, dynamic>)).toList(),
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
