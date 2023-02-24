// import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'commonCmd.dart';
import 'laReleases.dart';

part 'appState.g.dart';

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
  @JsonKey(ignore: true)
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
  @JsonKey(ignore: true) //, nullable: true)
  final List<AppSnackBarMessage> appSnackBarMessages;
  @JsonKey(ignore: true)
  final CommonCmd repeatCmd;
  @JsonKey(ignore: true)
  final PackageInfo? pkgInfo;
  @JsonKey(ignore: true)
  final String? backendVersion;
  @JsonKey(ignore: true)
  final bool loading;
  @JsonKey(ignore: true)
  final bool depsLoading;
  final DateTime? lastSwCheck;

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
      List<SshKey>? sshKeys})
      : projects = projects ?? [],
        sshKeys = sshKeys ?? [],
        status = status ?? LAProjectViewStatus.view,
        currentProject = currentProject ?? LAProject(),
        alaInstallReleases = alaInstallReleases ?? [],
        generatorReleases = generatorReleases ?? [],
        repeatCmd = repeatCmd ?? CommonCmd(),
        laReleases = laReleases ?? {},
        loading = loading ?? false,
        depsLoading = loading ?? false,
        appSnackBarMessages = appSnackBarMessages ?? [];

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

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


  String printShort() {
    return '''=== AppState ${loading ? '(loading)' : ''} ${depsLoading
        ? '(depsLoading)'
        : ''} ===''';
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
