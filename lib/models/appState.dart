// import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/sshKey.dart';

import 'deployCmd.dart';

part 'appState.g.dart';

enum LAProjectViewStatus { view, edit, tune, create }

extension ParseToString on LAProjectViewStatus {
  String toS() {
    return this.toString().split('.').last;
  }
}

extension LAProjectStatusExtension on LAProjectViewStatus {
  String get title {
    switch (this) {
      case LAProjectViewStatus.edit:
        return 'Editing project';
      case LAProjectViewStatus.create:
        return 'Creating a new LA Project';
      case LAProjectViewStatus.tune:
        return 'Tune your LA Project';
      case LAProjectViewStatus.view:
        return 'Project details';
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
  final List<LAProject> projects;
  final List<String> alaInstallReleases;
  final List<String> generatorReleases;
  final List<SshKey> sshKeys;
  @JsonKey(ignore: true) //, nullable: true)
  final AppSnackBarMessage appSnackBarMessage;
  @JsonKey(ignore: true)
  final DeployCmd repeatCmd;

  AppState(
      {List<LAProject>? projects,
      this.failedLoad = false,
      this.firstUsage = true,
      LAProject? currentProject,
      this.currentStep = 0,
      this.status = LAProjectViewStatus.view,
      List<String>? alaInstallReleases,
      List<String>? generatorReleases,
      AppSnackBarMessage? appSnackBarMessage,
      DeployCmd? repeatCmd,
      List<SshKey>? sshKeys})
      : projects = projects ?? [],
        sshKeys = sshKeys ?? [],
        currentProject = currentProject ?? LAProject(),
        alaInstallReleases = alaInstallReleases ?? [],
        generatorReleases = generatorReleases ?? [],
        repeatCmd = repeatCmd ?? DeployCmd(),
        appSnackBarMessage = appSnackBarMessage ?? AppSnackBarMessage.empty;

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
          repeatCmd == other.repeatCmd &&
          listEquals(projects, other.projects) &&
          listEquals(alaInstallReleases, other.alaInstallReleases) &&
          listEquals(generatorReleases, other.generatorReleases) &&
          listEquals(sshKeys, other.sshKeys);

  @override
  int get hashCode =>
      firstUsage.hashCode ^
      failedLoad.hashCode ^
      currentProject.hashCode ^
      status.hashCode ^
      currentStep.hashCode ^
      repeatCmd.hashCode ^
      ListEquality().hash(projects) ^
      ListEquality().hash(alaInstallReleases) ^
      ListEquality().hash(generatorReleases) ^
      ListEquality().hash(sshKeys);

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

  @override
  String toString() {
    return '''

=== AppState ===
LA projects: ${projects.length} 
view status: $status , currentStep: $currentStep, failedToLoad: $failedLoad
ala-install releases: ${alaInstallReleases.length}, generator releases: ${generatorReleases.length}, sshKeys: ${sshKeys.length}
snackMessage: ${appSnackBarMessage.message} repeatCmd: $repeatCmd
currentProject of ${projects.length} -----
$currentProject
''';
  }
}
