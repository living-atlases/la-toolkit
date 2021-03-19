import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/genericTextFormField.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';

import 'helpIcon.dart';

class LaServiceWidget extends StatelessWidget {
  final String serviceName;
  final FocusNode? collectoryFocusNode;

  LaServiceWidget(
      {Key? key, required this.serviceName, required this.collectoryFocusNode})
      : super(key: key);
  final domainTextStyle =
      TextStyle(fontSize: 16, color: LAColorTheme.laThemeData.hintColor);
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LAServiceViewModel>(
        // It seems that the comparison of projects are not working properly
        // distinct: true,
        converter: (store) {
      return _LAServiceViewModel(
          currentProject: store.state.currentProject,
          onEditService: (service) => store.dispatch(EditService(service)),
          onSaveProject: (project) =>
              store.dispatch(SaveCurrentProject(project)));
    }, builder: (BuildContext context, _LAServiceViewModel vm) {
      LAProject currentProject = vm.currentProject;
      LAService service = vm.currentProject.getService(serviceName);
      LAServiceDesc serviceDesc = LAServiceDesc.get(serviceName);
      bool visible = (serviceDesc.depends == null ||
              vm.currentProject.getServiceE(serviceDesc.depends).use) &&
          !serviceDesc.withoutUrl;
      bool optional = serviceDesc.optional;
      bool canUseSubdomain =
          !serviceDesc.forceSubdomain && !serviceDesc.withoutUrl;

      String domain = vm.currentProject.domain;
      bool usesSubdomain = !serviceDesc.withoutUrl && service.usesSubdomain;
      var domainSwitchController = AdvancedSwitchController();
      domainSwitchController.value = !service.usesSubdomain;
      domainSwitchController.addListener(() {
        if (canUseSubdomain) {
          service.usesSubdomain = !domainSwitchController.value;
          vm.onEditService(service);
        }
      });
      return visible
          ? Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Container(
                  padding: EdgeInsets.fromLTRB(20.0, 0, 10.0, 20.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // const DefDivider(),
                        ListTile(
                          // leading: Icon(serviceDesc.icon),
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  serviceDesc.icon,
                                  color: Colors.grey,
                                  // color: LAColorTheme.inactive
                                ),
                                const SizedBox(
                                  width:
                                      10, // here put the desired space between the icon and the text
                                ),
                                if (optional)
                                  Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Text(
                                              "Use the ${serviceDesc.name} service?"),
                                          Transform.scale(
                                              scale: 0.8,
                                              child: Switch(
                                                value: service.use,
                                                // activeColor: Color(0xFF6200EE),
                                                onChanged: (bool newValue) {
                                                  currentProject.serviceInUse(
                                                      serviceName, newValue);
                                                  vm.onSaveProject(
                                                      currentProject);
                                                },
                                              ))
                                        ]),
                                        const SizedBox(
                                          height:
                                              0, // here put the desired space between the icon and the text
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6,
                                            child: Wrap(children: [
                                              Text(
                                                  "${StringUtils.capitalize(serviceDesc.desc)}",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600]))
                                            ])),
                                        SizedBox(height: 10)
                                      ]),
                                if (!optional)
                                  Text(
                                      "${StringUtils.capitalize(serviceDesc.desc)}:")
                              ]),
                          trailing: serviceDesc.sample != null
                              ? HelpIcon.url(
                                  url: serviceDesc.sample!,
                                  tooltip:
                                      "See a similar service in production")
                              : null,
                        ),

                        if (!optional || service.use)
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Tooltip(
                                    message: canUseSubdomain
                                        ? "Use a subdomain for this service?"
                                        : "This service requires a subdomain",
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(0, 3, 20, 0),
                                      child: AdvancedSwitch(
                                        controller: domainSwitchController,
                                        height: 16.0,
                                        width: 60.0,
                                        activeColor: LAColorTheme.inactive,
                                        inactiveColor: LAColorTheme.laPalette,
                                        // activeColor: Color(0xFF009688),
                                        inactiveChild: Text('SUBD'),
                                        activeChild: Text('PATH'),
                                        borderRadius: BorderRadius.all(
                                            const Radius.circular(4)),
                                      ),
                                    )),
                                /* Switch(
                                value: service.usesSubdomain,
                                activeColor: Color(0xFF009688),
                                onChanged: (bool newValue) {
                                  service.usesSubdomain = newValue;
                                  vm.onEditService(service);
                                },
                              ) */
                                if (!serviceDesc.withoutUrl)
                                  Container(
                                      padding: EdgeInsets.fromLTRB(
                                          0, 0, usesSubdomain ? 0 : 0, 0),
                                      child: Text(
                                          "http${vm.currentProject.useSSL ? 's' : ''}://",
                                          style: domainTextStyle)),
                                if (!serviceDesc.withoutUrl && usesSubdomain)
                                  _createSubUrlField(service, serviceDesc, vm,
                                      'Invalid subdomain.'),
                                if (!serviceDesc.withoutUrl && usesSubdomain)
                                  Text('.$domain/', style: domainTextStyle),
                                if (!serviceDesc.withoutUrl && usesSubdomain)
                                  _createPathField(service, serviceDesc, vm,
                                      'Invalid path.'),
                                if (!serviceDesc.withoutUrl && !usesSubdomain)
                                  Text('$domain/', style: domainTextStyle),
                                if (!serviceDesc.withoutUrl && !usesSubdomain)
                                  _createSubUrlField(service, serviceDesc, vm,
                                      'Invalid path.'),
                                if (!serviceDesc.withoutUrl && !usesSubdomain)
                                  Text("/", style: domainTextStyle),
                                /* SearchChoices.single(
                              items: searchServerList,
                              // vm.state.currentProject.servers.toList(),
                              // value: service.servers[0] ??
                              //  searchServerList[0].value,
                              hint: "deploy it in",
                              searchHint:
                                  "Select one server to deploy this service:",
                              onChanged: (value) {
                                print(value);
                                // service.servers[0] = value;
                              },
                              /* dialogBox: false,
                              menuConstraints:
                                  BoxConstraints.tight(Size.fromHeight(350)), */
                              isExpanded: false,
                            ) */
                              ]),
                        SizedBox(height: 10)
                      ])))
          : Container();
    });
  }

  Widget _wrapField({required Widget child}) {
    return IntrinsicWidth(
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
          ConstrainedBox(
              constraints: new BoxConstraints(
                minWidth: 60.0,
              ),
              child: child)
        ]));
  }

  Widget _createSubUrlField(LAService service, LAServiceDesc serviceDesc,
      _LAServiceViewModel vm, String error) {
    return _wrapField(
        child: GenericTextFormField(
            initialValue: service.suburl,
            focusNode: service.nameInt == LAServiceName.collectory.toS()
                ? collectoryFocusNode
                : null,
            // This
            // hint: serviceDesc.hint,
            isDense: false,
            isCollapsed: true,
            regexp: LARegExp.subdomain,
            error: error,
            onChanged: (value) {
              service.suburl = value;
              vm.onEditService(service);
            }));
  }

  Widget _createPathField(LAService service, LAServiceDesc serviceDesc,
      _LAServiceViewModel vm, String error) {
    return _wrapField(
        child: GenericTextFormField(
            initialValue: service.iniPath,
            focusNode: service.nameInt == LAServiceName.collectory.toS() &&
                    !service.usesSubdomain
                ? collectoryFocusNode
                : null,
            isDense: false,
            isCollapsed: true,
            regexp: LARegExp.subdomain,
            allowEmpty: true,
            error: error,
            onChanged: (value) {
              service.iniPath = value;
              vm.onEditService(service);
            }));
  }
}

class _LAServiceViewModel {
  final LAProject currentProject;
  final void Function(LAService service) onEditService;
  final void Function(LAProject project) onSaveProject;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LAServiceViewModel &&
          runtimeType == other.runtimeType &&
          currentProject == other.currentProject;

  @override
  int get hashCode => currentProject.hashCode;

  _LAServiceViewModel(
      {required this.currentProject,
      required this.onEditService,
      required this.onSaveProject});
}
