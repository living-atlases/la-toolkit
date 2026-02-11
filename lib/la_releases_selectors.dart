import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import './models/app_state.dart';
import './models/la_releases.dart';
import './models/la_service_desc.dart';
import './models/la_service_name.dart';
import 'components/help_icon.dart';
import 'components/software_selector.dart';
import 'la_theme.dart';
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
          },
        );
      },
      builder: (BuildContext context, _LAReleasesSelectorsViewModel vm) {
        final LAProject project = vm.project;
        final List<LAServiceDesc> services = LAServiceDesc.listSorted(
          project.isHub,
        );
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
            // Prepare versions list
            List<String> versions = List<String>.from(releases.versions);

            // Check if there are nexus versions available
            final String nexusKey = '${serviceNameInt}_nexus';
            if (vm.laReleases.containsKey(nexusKey)) {
              final LAReleases? nexusReleases = vm.laReleases[nexusKey];
              if (nexusReleases != null && nexusReleases.versions.isNotEmpty) {
                if (project.isServiceInDockerCompose(serviceNameInt)) {
                  // If using Docker Compose, show ONLY Nexus versions, excluding Snapshots
                  versions = nexusReleases.versions
                      .where((String v) => !v.contains('SNAPSHOT'))
                      .toList();
                } else {
                  // Otherwise merge them (or keep as is, but user asked for "only nexus if docker")
                  // If NOT using docker, we probably want Apt versions + Nexus?
                  // Or just Apt? Let's assume merge for flexibility if not purely Docker.
                  // Actually, let's keep the merge for non-docker case to be safe,
                  // or just original versions if user implies strict separation.
                  // Given "if I use docker compose, only show nexus",
                  // the inverse "if I use VM, show Apt (and maybe Nexus?)"
                  // Let's stick to: Docker -> Nexus Only. VM/Hybrid -> Merge (safest fallback).
                  versions.addAll(nexusReleases.versions);
                }
              }
            }

            final Map<String, TextStyle> highlight = <String, TextStyle>{};
            final String? runningVersion = vm.runningVersionsRetrieved
                ? project.runningVersions[serviceNameInt]
                : null;
            final String initialValue = _getInitialValue(
              project,
              serviceNameInt,
              versions,
              runningVersion,
            );
            if (vm.runningVersionsRetrieved) {
              for (final String version in versions) {
                if (version == initialValue) {
                  highlight[version] = TextStyle(
                    color: LAColorTheme.unDeployedColor,
                    // fontStyle: FontStyle.italic
                  );
                }
                if (version == runningVersion) {
                  highlight[version] = const TextStyle(
                    color: LAColorTheme.deployedColor,
                    fontWeight: FontWeight.w400,
                  );
                } else if (version == releases.latest) {
                  // Current latest marked versions are quite outdated and unuseful
                  //  highlight[version] = Colors.orange;
                }
              }
            }
            selectors.add(
              SizedBox(
                width: 230,
                child: SoftwareSelector(
                  label: LAServiceDesc.swNameWithAliasForHumans(
                    serviceDesc.nameInt,
                  ),
                  highlight: highlight,
                  versions: versions,
                  initialValue: initialValue,
                  onChange: (String? value) {
                    if (value != null) {
                      onChange(value, true);
                    }
                  },
                  roundStyle: false,
                  useBadge: false,
                ),
              ),
            );
          } else {
            if (releases == null) {
              log('No releases available for $serviceNameInt');
            }
          }
        }

        return Column(
          children: <Widget>[
            const SizedBox(height: 10),
            ListTile(
              title: Text(
                "Here you can select which version of each LA component do you want to deploy in order to keep your portal updated. ${(project.inProduction || project.allServicesAssigned()) ? 'In green services that need to be deployed, and in blue your current running versions. ' : 'Once all services are assigned to servers, you will see which versions are currently running.'}You can verify also which versions are running other LA portals.",
              ),
              trailing: HelpIcon(wikipage: 'Components-versioning'),
            ),
            Wrap(children: selectors),
          ],
        );
      },
    );
  }

  String _getInitialValue(
    LAProject project,
    String swName,
    List<String> finalVersions,
    String? currentVersion,
  ) {
    final String? storedVersion = project.getServiceDeployRelease(swName);
    if (storedVersion == null) {
      assert(
        finalVersions.isNotEmpty,
        'There is not releases for $swName for some reason',
      );
      final bool setCurrentVersion =
          currentVersion != null && finalVersions.contains(currentVersion);
      final String defVersion = setCurrentVersion
          ? currentVersion
          : finalVersions[0];
      return defVersion;
    } else {
      return storedVersion;
    }
  }
}

@immutable
class _LAReleasesSelectorsViewModel {
  const _LAReleasesSelectorsViewModel({
    required this.laReleases,
    required this.project,
    required this.runningVersionsRetrieved,
    required this.onSaveProject,
  });

  final Map<String, LAReleases> laReleases;
  final LAProject project;
  final bool runningVersionsRetrieved;
  final void Function(LAProject project) onSaveProject;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LAReleasesSelectorsViewModel &&
          runtimeType == other.runtimeType &&
          const DeepCollectionEquality.unordered().equals(
            laReleases,
            other.laReleases,
          ) &&
          project == other.project &&
          runningVersionsRetrieved == other.runningVersionsRetrieved;

  @override
  int get hashCode =>
      laReleases.hashCode ^
      project.hashCode ^
      runningVersionsRetrieved.hashCode ^
      const DeepCollectionEquality.unordered().hash(laReleases);
}
