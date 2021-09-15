import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/softwareSelector.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/laSubService.dart';

import 'components/helpIcon.dart';
import 'models/laReleases.dart';

class LAReleasesSelectors extends StatefulWidget {
  const LAReleasesSelectors({Key? key}) : super(key: key);

  @override
  _LAReleasesSelectorsState createState() => _LAReleasesSelectorsState();
}

class _LAReleasesSelectorsState extends State<LAReleasesSelectors> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LAReleasesSelectorsViewModel>(
        converter: (store) {
      return _LAReleasesSelectorsViewModel(
          project: store.state.currentProject,
          laReleases: store.state.laReleases,
          onUpdateProject: (project) {
            // store.dispatch(UpdateProject(project)
          });
    }, builder: (BuildContext context, _LAReleasesSelectorsViewModel vm) {
      LAProject project = vm.project;
      List<LAServiceDesc> services = LAServiceDesc.list(project.isHub);
      List<Widget> selectors = [];
      for (LAServiceDesc service in services) {
        String serviceNameInt = service.nameInt;
        LAReleases? releases = vm.laReleases[serviceNameInt];
        if (project.getService(serviceNameInt).use && releases != null) {
          Widget swWidget = _createSoftwareSelector(
              service.name,
              releases.versions,
              (String value) =>
                  vm.project.setServiceDeployRelease(service.nameInt, value));
          selectors.add(swWidget);
          for (LASubServiceDesc subService in service.subServices) {
            String subServiceName = subService.name;
            LAReleases? releases = vm.laReleases[subServiceName];
            if (releases != null) {
              Widget swWidget = _createSoftwareSelector(
                  subServiceName,
                  vm.laReleases[subServiceName]!.versions,
                  (String value) => vm.project
                      .setServiceDeployRelease(service.nameInt, value));
              selectors.add(swWidget);
            }
          }
        }
      }

      return Column(children: [
        const SizedBox(height: 10),
        ListTile(
          title: const Text(
              "Here you can select which version of each LA component do you want to deploy in order to keep your portal updated. You can verify also which versions are running other LA portals."),
          trailing: HelpIcon(wikipage: "Components-versioning"),
        ),
        Wrap(children: selectors)
      ]);
    });
  }

  Widget _createSoftwareSelector(
      String serviceName, List<String> versions, Function(String) onChange) {
    Widget swWidget = SizedBox(
        width: 200,
        child: SoftwareSelector(
          label: serviceName,
          versions: versions,
          initialValue: "",
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
  final void Function(LAProject project) onUpdateProject;

  _LAReleasesSelectorsViewModel(
      {required this.laReleases,
      required this.project,
      required this.onUpdateProject});
}
