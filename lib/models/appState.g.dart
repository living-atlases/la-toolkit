// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appState.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension AppStateCopyWith on AppState {
  AppState copyWith({
    List<String>? alaInstallReleases,
    dynamic? appSnackBarMessage,
    dynamic? currentProject,
    int? currentStep,
    bool? failedLoad,
    bool? firstUsage,
    List<String>? generatorReleases,
    List<LAProject>? projects,
    List<SshKey>? sshKeys,
    LAProjectViewStatus? status,
  }) {
    return AppState(
      alaInstallReleases: alaInstallReleases ?? this.alaInstallReleases,
      appSnackBarMessage: appSnackBarMessage ?? this.appSnackBarMessage,
      currentProject: currentProject ?? this.currentProject,
      currentStep: currentStep ?? this.currentStep,
      failedLoad: failedLoad ?? this.failedLoad,
      firstUsage: firstUsage ?? this.firstUsage,
      generatorReleases: generatorReleases ?? this.generatorReleases,
      projects: projects ?? this.projects,
      sshKeys: sshKeys ?? this.sshKeys,
      status: status ?? this.status,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppState _$AppStateFromJson(Map<String, dynamic> json) {
  return AppState(
    projects: (json['projects'] as List<dynamic>?)
        ?.map((e) => LAProject.fromJson(e as Map<String, dynamic>))
        .toList(),
    failedLoad: json['failedLoad'] as bool,
    firstUsage: json['firstUsage'] as bool,
    currentProject: json['currentProject'],
    currentStep: json['currentStep'] as int,
    status: _$enumDecode(_$LAProjectViewStatusEnumMap, json['status']),
    alaInstallReleases: (json['alaInstallReleases'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    generatorReleases: (json['generatorReleases'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    sshKeys: (json['sshKeys'] as List<dynamic>?)
        ?.map((e) => SshKey.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$AppStateToJson(AppState instance) => <String, dynamic>{
      'failedLoad': instance.failedLoad,
      'firstUsage': instance.firstUsage,
      'currentProject': instance.currentProject.toJson(),
      'status': _$LAProjectViewStatusEnumMap[instance.status],
      'currentStep': instance.currentStep,
      'projects': instance.projects.map((e) => e.toJson()).toList(),
      'alaInstallReleases': instance.alaInstallReleases,
      'generatorReleases': instance.generatorReleases,
      'sshKeys': instance.sshKeys.map((e) => e.toJson()).toList(),
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$LAProjectViewStatusEnumMap = {
  LAProjectViewStatus.view: 'view',
  LAProjectViewStatus.edit: 'edit',
  LAProjectViewStatus.tune: 'tune',
  LAProjectViewStatus.create: 'create',
};
