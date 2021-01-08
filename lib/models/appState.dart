// import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laProject.dart';

part 'appState.g.dart';

enum LAProjectStatus {
  view,
  edit,
  create,
}

extension LAProjectStatusExtension on LAProjectStatus {
  String get title {
    switch (this) {
      case LAProjectStatus.edit:
        return 'Editing project';
      case LAProjectStatus.create:
        return 'Creating a new LA Project';
      case LAProjectStatus.view:
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
  final LAProjectStatus status;
  @JsonKey(nullable: true)
  final int currentStep;
  // from server api call
  final List<LAProject> projects;

  AppState(
      {this.projects,
      this.firstUsage = true,
      this.currentProject,
      this.currentStep,
      this.status});

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  Map<String, dynamic> toJson() => _$AppStateToJson(this);

  @override
  String toString() {
    return '''firstUse: $firstUsage,
    projects: ${projects.length} 
    currentProject: $currentProject, 
    status: $status, 
    ''';
  }
}
