import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/softwareSelector.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/redux/appActions.dart';

import 'components/helpIcon.dart';
import 'models/laReleases.dart';
import 'models/laService.dart';
import 'models/laSubService.dart';

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
          onUpdateProject: (project) => store.dispatch(UpdateProject(project)));
    }, builder: (BuildContext context, _LAReleasesSelectorsViewModel vm) {
      LAProject project = vm.project;
      List<LAServiceDesc> services = LAServiceDesc.list(project.isHub);
      List<Widget> selectors = [];
      for (LAServiceDesc serviceDesc in services) {
        String serviceNameInt = serviceDesc.nameInt;
        LAReleases? releases = vm.laReleases[serviceNameInt];
        LAService service = project.getService(serviceNameInt);
        if (service.use && serviceDesc.artifact != null && releases != null) {
          Widget swWidget = _createSoftwareSelector(
              LAServiceDesc.swNameWithAliasForHumans(serviceDesc.nameInt),
              _getInitialValue(project, serviceNameInt),
              releases.versions, (String value) {
            project.setServiceDeployRelease(serviceDesc.nameInt, value);
            vm.onUpdateProject(project);
          });
          selectors.add(swWidget);
          for (LASubServiceDesc subService in serviceDesc.subServices) {
            String subServiceName = subService.name;
            LAReleases? releases = vm.laReleases[subService.nameInt];
            print(
                "$subServiceName (${subService.nameInt}) has ${releases != null ? releases.versions.length : 0} releases");
            if (releases != null && subService.artifact != null) {
              Widget swWidget = _createSoftwareSelector(
                  LAServiceDesc.swNameWithAliasForHumans(subServiceName),
                  _getInitialValue(project, subService.nameInt),
                  releases.versions, (String value) {
                vm.project.setServiceDeployRelease(subService.nameInt, value);
                vm.onUpdateProject(project);
              });
              selectors.add(swWidget);
            } else {
              // print("No releases available for $subServiceName");
            }
          }
        } else {
          if (releases == null) {
            // print("No releases available for $serviceNameInt");
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

  String _getInitialValue(LAProject project, String swName) {
    return project.getServiceDeployRelease(swName) ?? "";
  }

  Widget _createSoftwareSelector(String serviceName, String initialValue,
      List<String> versions, Function(String) onChange) {
    Widget swWidget = SizedBox(
        width: 230,
        child: SoftwareSelector(
          label: serviceName,
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
  final void Function(LAProject project) onUpdateProject;

  _LAReleasesSelectorsViewModel(
      {required this.laReleases,
      required this.project,
      required this.onUpdateProject});
}
