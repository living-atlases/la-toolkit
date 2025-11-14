// import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../components/app_snack_bar_message.dart';
import './common_cmd.dart';
import './la_releases.dart';
import './ssh_key.dart';
import 'la_project.dart';

part 'app_state.g.dart';

enum LAProjectViewStatus { view, edit, servers, tune, create }

extension ParseToString on LAProjectViewStatus {
  String toS() {
    return toString().split('.').last;
  }
}

extension LAProjectStatusExtension on LAProjectViewStatus {
  String getTitle(bool isHub) {
    switch (this) {
      case LAProjectViewStatus.edit:
        return "Editing ${isHub ? 'Data Hub' : 'Project'}";
      case LAProjectViewStatus.servers:
        return "Defining your LA ${isHub ? 'data hub' : 'project'} servers";
      case LAProjectViewStatus.create:
        return "Creating a new LA ${isHub ? 'Data Hub' : 'Project'}";
      case LAProjectViewStatus.tune:
        return "Tune your LA ${isHub ? 'Data Hub' : 'Project'}";
      case LAProjectViewStatus.view:
        return "${isHub ? 'Data Hub' : 'Project'} details";
    }
  }
}

@immutable
@JsonSerializable(explicitToJson: true)
@CopyWith()
class AppState {
  AppState(
      {List<LAProject>? projects,
      this.failedLoad = false,
      this.firstUsage = true,
      LAProject? currentProject,
      this.currentStep = 0,
      this.currentTuneTab = 0,
      LAProjectViewStatus? status,
      List<String>? alaInstallReleases,
      List<String>? generatorReleases,
      List<AppSnackBarMessage>? appSnackBarMessages,
      Map<String, LAReleases>? laReleases,
      CommonCmd? repeatCmd,
      this.pkgInfo,
      this.backendVersion,
      this.lastSwCheck,
      bool? loading,
      bool? depsLoading,
      List<SshKey>? sshKeys,
      Map<String, Map<String, dynamic>>? serviceCheckProgress})
      : projects = projects ?? <LAProject>[],
        sshKeys = sshKeys ?? <SshKey>[],
        status = status ?? LAProjectViewStatus.view,
        currentProject = currentProject ?? LAProject(),
        alaInstallReleases = alaInstallReleases ?? <String>[],
        generatorReleases = generatorReleases ?? <String>[],
        repeatCmd = repeatCmd ?? CommonCmd(),
        laReleases = laReleases ?? <String, LAReleases>{},
        loading = loading ?? false,
        depsLoading = depsLoading ?? false,
        serviceCheckProgress =
            serviceCheckProgress ?? <String, Map<String, dynamic>>{},
        appSnackBarMessages = appSnackBarMessages ?? <AppSnackBarMessage>[];

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool failedLoad;
  final bool firstUsage;
  final LAProject currentProject;
  final LAProjectViewStatus status;
  final int currentStep;
  final int currentTuneTab;
  final List<LAProject> projects;
  final List<String> alaInstallReleases;
  final List<String> generatorReleases;
  final Map<String, LAReleases> laReleases;
  final List<SshKey> sshKeys;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final List<AppSnackBarMessage> appSnackBarMessages;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final CommonCmd repeatCmd;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final PackageInfo? pkgInfo;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? backendVersion;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool loading;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool depsLoading;
  @JsonKey(includeToJson: false, includeFromJson: false)
  final Map<String, Map<String, dynamic>> serviceCheckProgress;
  final DateTime? lastSwCheck;

  Map<String, dynamic> toJson() => _$AppStateToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          firstUsage == other.firstUsage &&
          failedLoad == other.failedLoad &&
          currentProject == other.currentProject &&
          status == other.status &&
          currentStep == other.currentStep &&
          currentTuneTab == other.currentTuneTab &&
          repeatCmd == other.repeatCmd &&
          pkgInfo == other.pkgInfo &&
          loading == other.loading &&
          depsLoading == other.depsLoading &&
          backendVersion == other.backendVersion &&
          lastSwCheck == other.lastSwCheck &&
          listEquals(projects, other.projects) &&
          listEquals(alaInstallReleases, other.alaInstallReleases) &&
          listEquals(generatorReleases, other.generatorReleases) &&
          listEquals(appSnackBarMessages, other.appSnackBarMessages) &&
          const DeepCollectionEquality.unordered()
              .equals(laReleases, other.laReleases) &&
          const DeepCollectionEquality.unordered()
              .equals(serviceCheckProgress, other.serviceCheckProgress) &&
          listEquals(sshKeys, other.sshKeys);

  @override
  int get hashCode =>
      firstUsage.hashCode ^
      failedLoad.hashCode ^
      currentProject.hashCode ^
      status.hashCode ^
      currentStep.hashCode ^
      currentTuneTab.hashCode ^
      repeatCmd.hashCode ^
      pkgInfo.hashCode ^
      backendVersion.hashCode ^
      loading.hashCode ^
      depsLoading.hashCode ^
      lastSwCheck.hashCode ^
      const ListEquality().hash(appSnackBarMessages) ^
      const ListEquality().hash(projects) ^
      const ListEquality().hash(alaInstallReleases) ^
      const ListEquality().hash(generatorReleases) ^
      const DeepCollectionEquality.unordered().hash(laReleases) ^
      const DeepCollectionEquality.unordered().hash(serviceCheckProgress) ^
      const ListEquality().hash(sshKeys);

  static LAProjectViewStatus statusFromString(String s) {
    switch (s) {
      case 'edit':
        return LAProjectViewStatus.edit;
      case 'create':
        return LAProjectViewStatus.create;
      case 'tune':
        return LAProjectViewStatus.tune;
      case 'view':
        return LAProjectViewStatus.view;
      default:
        return LAProjectViewStatus.view;
    }
  }

  String debugPrintShort() {
    return '''=== AppState ${loading ? '(loading)' : ''} ${depsLoading ? '(depsLoading)' : ''} ===''';
  }

  @override
  String toString() {
    return '''

=== AppState ${loading ? '(loading)' : ''} ${depsLoading ? '(depsLoading)' : ''} ===
view status: $status , currentStep: $currentStep, currentTuneStep: $currentTuneTab, failedToLoad: $failedLoad, appVersion: ${pkgInfo != null ? pkgInfo!.version : 'unknown'}, backendVersion ${backendVersion ?? ''}
LA projects: ${projects.length} 
ala-install releases: ${alaInstallReleases.length}, generator releases: ${generatorReleases.length}, sshKeys: ${sshKeys.length}
snackMessages: ${appSnackBarMessages.length} repeatCmd: $repeatCmd
currentProject of ${projects.length} -----
$currentProject
===''';
  }
}
