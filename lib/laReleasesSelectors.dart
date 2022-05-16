import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/softwareSelector.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/laServiceName.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/debounce.dart';

import 'components/helpIcon.dart';
import 'models/laReleases.dart';
import 'models/laService.dart';

class LAReleasesSelectors extends StatefulWidget {
  final Function(String, String, bool) onSoftwareSelected;
  const LAReleasesSelectors({Key? key, required this.onSoftwareSelected})
      : super(key: key);

  @override
  _LAReleasesSelectorsState createState() => _LAReleasesSelectorsState();
}

class _LAReleasesSelectorsState extends State<LAReleasesSelectors> {
  final debouncer = Debouncer(milliseconds: 1000);
  late bool _loading;

  @override
  void initState() {
    super.initState();
    _loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LAReleasesSelectorsViewModel>(
        distinct: false,
        converter: (store) {
          return _LAReleasesSelectorsViewModel(
              project: store.state.currentProject,
              runningVersionsRetrieved:
                  store.state.currentProject.runningVersions.isNotEmpty,
              laReleases: store.state.laReleases,
              onSaveProject: (project) {
                debouncer
                    .run(() => store.dispatch(SaveCurrentProject(project)));
              },
              refreshSWVersions: () => store.dispatch(OnFetchSoftwareDepsState(
                  force: true,
                  onReady: () => setState(() {
                        _loading = false;
                      }))));
        },
        builder: (BuildContext context, _LAReleasesSelectorsViewModel vm) {
          LAProject project = vm.project;
          List<LAServiceDesc> services =
              LAServiceDesc.listSorted(project.isHub);
          List<Widget> selectors = [];
          for (LAServiceDesc serviceDesc in services) {
            String serviceNameInt = serviceDesc.nameInt;
            LAReleases? releases = vm.laReleases[serviceNameInt];
            void onChange(String value, bool save) {
              widget.onSoftwareSelected(serviceNameInt, value, save);
            }

            LAService serviceOrParent = !serviceDesc.isSubService
                ? project.getService(serviceNameInt)
                : project.getService(serviceDesc.parentService!.toS());
            if (serviceOrParent.use &&
                serviceDesc.artifacts != null &&
                releases != null) {
              Map<String, TextStyle> highlight = {};
              String? runningVersion = vm.runningVersionsRetrieved
                  ? project.runningVersions[serviceNameInt]
                  : null;
              String initialValue = _getInitialValue(
                  project, serviceNameInt, releases, runningVersion);
              if (vm.runningVersionsRetrieved) {
                for (String version in releases.versions) {
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
                    label: LAServiceDesc.swNameWithAliasForHumans(
                        serviceDesc.nameInt),
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
                print("No releases available for $serviceNameInt");
              }
            }
          }

          return Column(children: [
            const SizedBox(height: 10),
            ListTile(
              title: Text(
                  "Here you can select which version of each LA component do you want to deploy in order to keep your portal updated. ${(project.inProduction || project.allServicesAssignedToServers()) ? 'In green services that need to be deployed, and in blue your current running versions. ' : ''}You can verify also which versions are running other LA portals."),
              trailing: HelpIcon(wikipage: "Components-versioning"),
            ),
            Wrap(children: selectors),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: TextButton.icon(
                    onPressed: _loading ? null : () => _onPressed(vm),
                    label: const Text("Refresh"),
                    icon: const Icon(Icons.refresh)))
          ]);
        });
  }

  String _getInitialValue(LAProject project, String swName, LAReleases releases,
      String? currentVersion) {
    String? storedVersion = project.getServiceDeployRelease(swName);
    if (storedVersion == null) {
      assert(releases.versions.isNotEmpty,
          "There is not releases for $swName for some reason");
      bool setCurrentVersion =
          currentVersion != null && releases.versions.contains(currentVersion);
      String defVersion =
          setCurrentVersion ? currentVersion : releases.versions[0];
      return defVersion;
    } else {
      return storedVersion;
    }
  }

  _onPressed(vm) {
    setState(() {
      _loading = true;
    });
    vm.refreshSWVersions();
  }
}

class _LAReleasesSelectorsViewModel {
  final Map<String, LAReleases> laReleases;
  final Function() refreshSWVersions;
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

  _LAReleasesSelectorsViewModel(
      {required this.laReleases,
      required this.project,
      required this.runningVersionsRetrieved,
      required this.refreshSWVersions,
      required this.onSaveProject});
}
