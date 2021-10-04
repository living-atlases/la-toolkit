import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  final Function(String, String) onSoftwareSelected;
  const LAReleasesSelectors({Key? key, required this.onSoftwareSelected})
      : super(key: key);

  @override
  _LAReleasesSelectorsState createState() => _LAReleasesSelectorsState();
}

class _LAReleasesSelectorsState extends State<LAReleasesSelectors> {
  final debouncer = Debouncer(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LAReleasesSelectorsViewModel>(
        converter: (store) {
      return _LAReleasesSelectorsViewModel(
          project: store.state.currentProject,
          laReleases: store.state.laReleases,
          onSaveProject: (project) {
            debouncer.run(() => store.dispatch(SaveCurrentProject(project)));
          });
    }, builder: (BuildContext context, _LAReleasesSelectorsViewModel vm) {
      LAProject project = vm.project;
      List<LAServiceDesc> services = LAServiceDesc.listSorted(project.isHub);
      List<Widget> selectors = [];

      for (LAServiceDesc serviceDesc in services) {
        String serviceNameInt = serviceDesc.nameInt;
        LAReleases? releases = vm.laReleases[serviceNameInt];
        void onChange(String value) {
          widget.onSoftwareSelected(serviceNameInt, value);
        }

        LAService serviceOrParent = !serviceDesc.isSubService
            ? project.getService(serviceNameInt)
            : project.getService(serviceDesc.parentService!.toS());
        if (serviceOrParent.use &&
            serviceDesc.artifact != null &&
            releases != null) {
          Map<String, Color> highlight = {};
          String initialValue =
              _getInitialValue(project, serviceNameInt, releases, onChange);
          String? runningVersion = project.runningVersions[serviceNameInt];
          for (String version in releases.versions) {
            if (version == initialValue) {
              highlight[version] = Colors.red;
            }

            if (version == runningVersion) {
              highlight[version] = LAColorTheme.laPalette;
            } else if (version == releases.latest) {
              // Current latest marked versions are quite outdated and unuseful
              //  highlight[version] = Colors.orange;
            }
          }
          Widget swWidget = _createSoftwareSelector(
              serviceName:
                  LAServiceDesc.swNameWithAliasForHumans(serviceDesc.nameInt),
              initialValue: initialValue,
              highlight: highlight,
              versions: releases.versions,
              onChange: onChange);
          selectors.add(swWidget);
        } else {
          if (releases == null) {
            // print("No releases available for $serviceNameInt");
          }
        }
      }

      return Column(children: [
        const SizedBox(height: 10),
        ListTile(
          title: Text(
              "Here you can select which version of each LA component do you want to deploy in order to keep your portal updated. ${(project.inProduction || project.allServicesAssignedToServers()) ? 'In green we try to show your current running versions. ' : ''}You can verify also which versions are running other LA portals."),
          trailing: HelpIcon(wikipage: "Components-versioning"),
        ),
        Wrap(children: selectors)
      ]);
    });
  }

  String _getInitialValue(LAProject project, String swName, LAReleases releases,
      Function(String value) onChange) {
    String? storedVersion = project.getServiceDeployRelease(swName);
    if (storedVersion == null) {
      assert(releases.versions.isNotEmpty,
          "There is not releases for $swName for some reason");
      String defVersion = releases.versions[0];
      onChange(defVersion);
      return defVersion;
    } else {
      return storedVersion;
    }
  }

  Widget _createSoftwareSelector(
      {required String serviceName,
      required String initialValue,
      Map<String, Color>? highlight,
      required List<String> versions,
      required Function(String) onChange}) {
    Widget swWidget = SizedBox(
        width: 230,
        child: SoftwareSelector(
          label: serviceName,
          highlight: highlight,
          versions: versions,
          initialValue: initialValue,
          onChange: (String? value) {
            if (value != null) {
              onChange(value);
            }
          },
          roundStyle: false,
          useBadge: false,
        ));
    return swWidget;
  }
}

class _LAReleasesSelectorsViewModel {
  final Map<String, LAReleases> laReleases;
  final LAProject project;
  final void Function(LAProject project) onSaveProject;

  _LAReleasesSelectorsViewModel(
      {required this.laReleases,
      required this.project,
      required this.onSaveProject});
}
