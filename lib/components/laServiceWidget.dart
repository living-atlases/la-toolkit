import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/genericTextFormField.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';

import 'helpIcon.dart';

class LaServiceWidget extends StatelessWidget {
  final LAService service;
  final LAService dependsOn;
  final FocusNode collectoryFocusNode;
  LaServiceWidget(
      {Key key, this.service, this.dependsOn, this.collectoryFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var serviceDesc = LAServiceDesc.get(service.nameInt);
    bool visible = (serviceDesc.depends == null || dependsOn.use) &&
        !serviceDesc.withoutUrl;
    var optional = serviceDesc.optional;
    bool canUseSubdomain =
        !serviceDesc.forceSubdomain && !serviceDesc.withoutUrl;
    return StoreConnector<AppState, _LAServiceViewModel>(converter: (store) {
      return _LAServiceViewModel(
        state: store.state,
        onEditService: (service) => {store.dispatch(EditService(service))},
      );
    }, builder: (BuildContext context, _LAServiceViewModel vm) {
      var domain = vm.state.currentProject.domain;
      var usesSubdomain = !serviceDesc.withoutUrl && service.usesSubdomain;
      /* List<DropdownMenuItem<LAServer>> serversMap =
          List<DropdownMenuItem<LAServer>>.empty(growable: true); */
      // TODO move this outside
      /* List<DropdownMenuItem<String>> searchServerList =
          vm.state.currentProject.servers
              .asMap()
              .map((i, server) {
                return MapEntry(
                    server.name,
                    DropdownMenuItem<String>(
                      child: Text(server.name),
                      value: server.name,
                    ));color
              })
              .values
              .toList();
      print("Server list: ${searchServerList.length}"); */
      // print('Processing service ${serviceDesc.nameInt}');
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
                                SizedBox(
                                  width:
                                      10, // here put the desired space between the icon and the text
                                ),
                                optional
                                    ? Column(
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
                                                      service.use = newValue;
                                                      vm.onEditService(service);
                                                    },
                                                  ))
                                            ]),
                                            SizedBox(
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
                                                          color:
                                                              Colors.grey[600]))
                                                ])),
                                            SizedBox(height: 10)
                                          ])
                                    : Container(),
                                (!optional)
                                    ? Text(
                                        "${StringUtils.capitalize(serviceDesc.desc)}:")
                                    : Container()
                              ]),
                          trailing: serviceDesc.sample != null
                              ? HelpIcon.url(
                                  url: serviceDesc.sample,
                                  tooltip:
                                      "See a similar service in production")
                              : null,
                        ),
                        if (!optional || service.use)
                          Row(children: [
                            Tooltip(
                              message: canUseSubdomain
                                  ? "Use a subdomain for this service?"
                                  : "This service requires a subdomain",
                              child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: AdvancedSwitch(
                                      value: !service.usesSubdomain, // Boolean
                                      height: 16.0,
                                      width: 60.0,
                                      activeColor: LAColorTheme.inactive,
                                      // activeColor: Color(0xFF009688),
                                      inactiveChild: Text('SUBD'),
                                      activeChild: Text('PATH'),
                                      borderRadius: BorderRadius.all(
                                          const Radius.circular(4)),
                                      onChanged: canUseSubdomain
                                          ? (bool newValue) {
                                              service.usesSubdomain = !newValue;
                                              vm.onEditService(service);
                                            }
                                          : null)),
                              /* Switch(
                                value: service.usesSubdomain,
                                activeColor: Color(0xFF009688),
                                onChanged: (bool newValue) {
                                  service.usesSubdomain = newValue;
                                  vm.onEditService(service);
                                },
                              ) */
                            ),
                            if (!serviceDesc.withoutUrl)
                              Container(
                                  padding: EdgeInsets.fromLTRB(
                                      0, 0, usesSubdomain ? 0 : 0, 0),
                                  child: Text(
                                      "http${vm.state.currentProject.useSSL ? 's' : ''}://")),
                            if (!serviceDesc.withoutUrl && usesSubdomain)
                              _createSubUrlField(service, serviceDesc, vm,
                                  'Invalid subdomain.'),
                            if (!serviceDesc.withoutUrl && usesSubdomain)
                              Text('.$domain'),
                            if (!serviceDesc.withoutUrl && !usesSubdomain)
                              Text('$domain/'),
                            if (!serviceDesc.withoutUrl && !usesSubdomain)
                              _createSubUrlField(
                                  service, serviceDesc, vm, 'Invalid path.'),
                            if (!serviceDesc.withoutUrl && !usesSubdomain)
                              Text("/"),
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

  Widget _createSubUrlField(LAService service, LAServiceDesc serviceDesc,
      _LAServiceViewModel vm, String error) {
    return Container(
        width: 150,
        child: GenericTextFormField(
            initialValue: service.suburl,
            focusNode: service.nameInt == LAServiceName.collectory.toS()
                ? collectoryFocusNode
                : null,
            hint: serviceDesc.hint,
            isCollapsed: true,
            regexp: LARegExp.subdomain,
            error: "Invalid subdomain.",
            onChanged: (value) {
              service.suburl = value;
              vm.onEditService(service);
            }));
  }
}

class _LAServiceViewModel {
  final AppState state;
  final void Function(LAService service) onEditService;

  _LAServiceViewModel({this.state, this.onEditService});
}
