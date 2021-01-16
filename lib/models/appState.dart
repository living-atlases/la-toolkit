// import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laProject.dart';

part 'appState.g.dart';

enum LAProjectViewStatus {
  view,
  edit,
  create,
}

extension LAProjectStatusExtension on LAProjectViewStatus {
  String get title {
    switch (this) {
      case LAProjectViewStatus.edit:
        return 'Editing project';
      case LAProjectViewStatus.create:
        return 'Creating a new LA Project';
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

  AppState(
      {this.projects,
      this.firstUsage = true,
      this.currentProject,
      this.currentStep,
      this.status,
      this.alaInstallReleases});

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  Map<String, dynamic> toJson() => _$AppStateToJson(this);

  @override
  String toString() {
    return '''

=== AppState ===
projects (${projects.length}) ----- 
$projects
currentProject -----
$currentProject
view status: $status, currentStep: $currentStep
ala-install releases: $alaInstallReleases

''';
  }
}
