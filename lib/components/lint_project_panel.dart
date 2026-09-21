import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit_core/lint/project_lint.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_project_status.dart';
import 'package:la_toolkit_core/models/ssh_key.dart';
import 'package:redux/redux.dart';

import '../models/app_state.dart';
import '../redux/app_actions.dart';
import '../routes.dart';
import 'alert_card.dart';
import 'lint_error_panel.dart';

class LintProjectPanel extends StatefulWidget {
  const LintProjectPanel({
    super.key,
    this.showLADeps = true,
    this.showToolkitDeps = true,
    this.showOthers = true,
  });

  final bool showLADeps;
  final bool showToolkitDeps;
  final bool showOthers;

  @override
  State<LintProjectPanel> createState() => _LintProjectPanelState();
}

class _LintProjectPanelState extends State<LintProjectPanel> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LintProjectPanelViewModel>(
      // distinct: true,
      converter: (Store<AppState> store) {
        return _LintProjectPanelViewModel(
          project: store.state.currentProject,
          alaInstallReleases: store.state.alaInstallReleases,
          generatorReleases: store.state.generatorReleases,
          backendVersion: store.state.backendVersion,
          sshKeys: store.state.sshKeys,
          status: store.state.currentProject.status,
        );
      },
      builder: (BuildContext context, _LintProjectPanelViewModel vm) {
        final LAProject project = vm.project;
        final Map<String, String> selectedVersions = lintSelectedVersions(
          project,
          backendVersion: vm.backendVersion,
          alaInstallReleases: vm.alaInstallReleases,
          generatorReleases: vm.generatorReleases,
          laDeps: widget.showLADeps,
          toolkitDeps: widget.showToolkitDeps,
        );
        final List<Widget> lints = <Widget>[
          for (final List<String> errors in lintDependencies(
            project,
            selectedVersions,
            backendVersion: vm.backendVersion,
            laDeps: widget.showLADeps,
          ))
            LintErrorPanel(errors),
        ];
        if (widget.showOthers) {
          debugPrint(
            'ala-install ${project.alaInstallRelease}, generator: ${project.generatorRelease}',
          );
          lints.insertAll(0, <Widget>[
            for (final LintFinding finding in lintProject(
              project,
              hasSshKeys: vm.sshKeys.isNotEmpty,
            ))
              _alertCard(context, project, finding),
          ]);
        }
        return Column(children: lints);
      },
    );
  }

  Widget _alertCard(
    BuildContext context,
    LAProject project,
    LintFinding finding,
  ) {
    switch (finding.fix) {
      case null:
        return AlertCard(message: finding.message);
      case LintFix.sshKeys:
        return AlertCard(
          message: finding.message,
          actionText: 'SOLVE',
          action: () => BeamerCond.of(context, SshKeysLocation()),
        );
      case LintFix.tuneProject:
        return AlertCard(
          message: finding.message,
          actionText: 'SOLVE',
          action: () => BeamerCond.of(context, LAProjectTuneLocation()),
        );
      case LintFix.editProject:
        return AlertCard(
          message: finding.message,
          actionText: 'SOLVE',
          action: () => BeamerCond.of(context, LAProjectEditLocation()),
        );
      case LintFix.openParent:
        final LAProject parent = project.parent!;
        return AlertCard(
          message: finding.message,
          actionText: 'GO TO ${parent.shortName.toUpperCase()}',
          action: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(OpenProjectTools(parent)),
        );
    }
  }
}

@immutable
class _LintProjectPanelViewModel {
  const _LintProjectPanelViewModel({
    required this.project,
    required this.sshKeys,
    required this.status,
    required this.alaInstallReleases,
    required this.generatorReleases,
    required this.backendVersion,
  });

  final LAProject project;
  final String? backendVersion;
  final List<SshKey> sshKeys;
  final List<String> alaInstallReleases;
  final List<String> generatorReleases;
  final LAProjectStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LintProjectPanelViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          backendVersion == other.backendVersion &&
          sshKeys == other.sshKeys &&
          const ListEquality<String>().equals(
            generatorReleases,
            other.generatorReleases,
          ) &&
          const ListEquality<String>().equals(
            alaInstallReleases,
            other.alaInstallReleases,
          ) &&
          status == other.status;

  @override
  int get hashCode =>
      project.hashCode ^
      backendVersion.hashCode ^
      sshKeys.hashCode ^
      const ListEquality<String>().hash(generatorReleases) ^
      const ListEquality<String>().hash(alaInstallReleases) ^
      status.hashCode;
}
