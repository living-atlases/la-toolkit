// import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/sshKey.dart';

part 'appState.g.dart';

enum LAProjectViewStatus {
  view,
  edit,
  tune,
  create,
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
      default:
        return null;
    }
  }
}

@immutable
@JsonSerializable(explicitToJson: true)
@CopyWith()
class AppState {
  // from SharedPreferences
  final bool firstUsage;
  @JsonKey(nullable: true)
  final LAProject currentProject;
  @JsonKey(nullable: true)
  final LAProjectViewStatus status;
  @JsonKey(nullable: true)
  final int currentStep;
  // from server api call
  final List<LAProject> projects;
  final List<String> alaInstallReleases;
  final List<String> generatorReleases;
  @JsonSerializable(nullable: false)
  final List<SshKey> sshKeys;

  AppState(
      {this.projects,
      this.firstUsage = true,
      this.currentProject,
      this.currentStep,
      this.status,
      this.alaInstallReleases,
      this.generatorReleases,
      this.sshKeys});
  /*
      sshKeys})
      : sshKeys = sshKeys ?? []; */

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  Map<String, dynamic> toJson() => _$AppStateToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          firstUsage == other.firstUsage &&
          currentProject == other.currentProject &&
          status == other.status &&
          currentStep == other.currentStep &&
          listEquals(projects, other.projects) &&
          listEquals(alaInstallReleases, other.alaInstallReleases) &&
          listEquals(generatorReleases, other.generatorReleases) &&
          listEquals(sshKeys, other.sshKeys);

  @override
  int get hashCode =>
      firstUsage.hashCode ^
      currentProject.hashCode ^
      status.hashCode ^
      currentStep.hashCode ^
      ListEquality().hash(projects) ^
      ListEquality().hash(alaInstallReleases) ^
      ListEquality().hash(generatorReleases) ^
      ListEquality().hash(sshKeys);

  @override
  String toString() {
    return '''

=== AppState ===
LA projects: ${projects.length} 
view status: $status , currentStep: $currentStep
ala-install releases: ${alaInstallReleases.length}, generator releases: ${generatorReleases.length}, sshkeys: ${sshKeys == null ? 0 : sshKeys.length}
currentProject of ${projects.length} -----
$currentProject
''';
//    $projects
//    currentProject of ${projects.length} -----
//    $currentProject
  }
}
