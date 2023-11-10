import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'components/help_icon.dart';
import 'components/software_selector.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/laReleases.dart';
import 'models/laServiceDesc.dart';
import 'models/laServiceName.dart';
import 'models/la_project.dart';
import 'models/la_service.dart';
import 'redux/app_actions.dart';
import 'utils/debounce.dart';

class LAReleasesSelectors extends StatefulWidget {
  const LAReleasesSelectors({super.key, required this.onSoftwareSelected});

  final Function(String, String, bool) onSoftwareSelected;

  @override
  State<LAReleasesSelectors> createState() => _LAReleasesSelectorsState();
}

class _LAReleasesSelectorsState extends State<LAReleasesSelectors> {
  final Debouncer debouncer = Debouncer(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LAReleasesSelectorsViewModel>(
        // distinct: false,
        converter: (Store<AppState> store) {
      return _LAReleasesSelectorsViewModel(
          project: store.state.currentProject,
          runningVersionsRetrieved:
              store.state.currentProject.runningVersions.isNotEmpty,
          laReleases: store.state.laReleases,
          onSaveProject: (LAProject project) {
            debouncer.run(() => store.dispatch(SaveCurrentProject(project)));
          });
    }, builder: (BuildContext context, _LAReleasesSelectorsViewModel vm) {
      final LAProject project = vm.project;
      final List<LAServiceDesc> services =
          LAServiceDesc.listSorted(project.isHub);
      final List<Widget> selectors = <Widget>[];
      for (final LAServiceDesc serviceDesc in services) {
        final String serviceNameInt = serviceDesc.nameInt;
        final LAReleases? releases = vm.laReleases[serviceNameInt];
        void onChange(String value, bool save) {
          widget.onSoftwareSelected(serviceNameInt, value, save);
        }

        final LAService serviceOrParent = !serviceDesc.isSubService
            ? project.getService(serviceNameInt)
            : project.getService(serviceDesc.parentService!.toS());
        if (serviceOrParent.use &&
            serviceDesc.artifacts != null &&
            releases != null &&
            releases.versions.isNotEmpty) {
          final Map<String, TextStyle> highlight = <String, TextStyle>{};
          final String? runningVersion = vm.runningVersionsRetrieved
              ? project.runningVersions[serviceNameInt]
              : null;
          final String initialValue = _getInitialValue(
              project, serviceNameInt, releases, runningVersion);
          if (vm.runningVersionsRetrieved) {
            for (final String version in releases.versions) {
              if (version == initialValue) {
                highlight[version] = TextStyle(
                  color: LAColorTheme.unDeployedColor,
                  // fontStyle: FontStyle.italic
                );
              }
              if (version == runningVersion) {
                highlight[version] = const TextStyle(
                    color: LAColorTheme.deployedColor,
                    fontWeight: FontWeight.w400);
              } else if (version == releases.latest) {
                // Current latest marked versions are quite outdated and unuseful
                //  highlight[version] = Colors.orange;
              }
            }
          }
          selectors.add(SizedBox(
              width: 230,
              child: SoftwareSelector(
                label:
                    LAServiceDesc.swNameWithAliasForHumans(serviceDesc.nameInt),
                highlight: highlight,
                versions: releases.versions,
                initialValue: initialValue,
                onChange: (String? value) {
                  if (value != null) {
                    onChange(value, true);
                  }
                },
                roundStyle: false,
                useBadge: false,
              )));
        } else {
          if (releases == null) {
            log('No releases available for $serviceNameInt');
          }
        }
      }

      return Column(children: <Widget>[
        const SizedBox(height: 10),
        ListTile(
          title: Text(
              "Here you can select which version of each LA component do you want to deploy in order to keep your portal updated. ${(project.inProduction || project.allServicesAssigned()) ? 'In green services that need to be deployed, and in blue your current running versions. ' : ''}You can verify also which versions are running other LA portals."),
          trailing: HelpIcon(wikipage: 'Components-versioning'),
        ),
        Wrap(children: selectors),
      ]);
    });
  }

  String _getInitialValue(LAProject project, String swName, LAReleases releases,
      String? currentVersion) {
    final String? storedVersion = project.getServiceDeployRelease(swName);
    if (storedVersion == null) {
      assert(releases.versions.isNotEmpty,
          'There is not releases for $swName for some reason');
      final bool setCurrentVersion =
          currentVersion != null && releases.versions.contains(currentVersion);
      final String defVersion =
          setCurrentVersion ? currentVersion : releases.versions[0];
      return defVersion;
    } else {
      return storedVersion;
    }
  }
}

@immutable
class _LAReleasesSelectorsViewModel {
  const _LAReleasesSelectorsViewModel(
      {required this.laReleases,
      required this.project,
      required this.runningVersionsRetrieved,
      required this.onSaveProject});

  final Map<String, LAReleases> laReleases;
  final LAProject project;
  final bool runningVersionsRetrieved;
  final void Function(LAProject project) onSaveProject;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LAReleasesSelectorsViewModel &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality.unordered()
              .equals(laReleases, other.laReleases) &&
          project == other.project &&
          runningVersionsRetrieved == other.runningVersionsRetrieved;

  @override
  int get hashCode =>
      laReleases.hashCode ^
      project.hashCode ^
      runningVersionsRetrieved.hashCode ^
      const DeepCollectionEquality.unordered().hash(laReleases);
}
