import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/genericTextFormField.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/laServiceDescList.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';

import 'helpIcon.dart';

class LaServiceWidget extends StatelessWidget {
  final LAService service;
  final LAService dependsOn;

  LaServiceWidget({Key key, this.service, this.dependsOn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var serviceDesc = serviceDescList[service.name];
    bool visible = serviceDesc.depends == null || dependsOn.use;
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
                    ));
              })
              .values
              .toList();
      print("Server list: ${searchServerList.length}"); */
      print('Processing service ${serviceDesc.nameInt}');
      return visible
          ? Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Container(
                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 20.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: (optional)
                                  ? [
                                      Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Use the ${serviceDesc.name} service?"),
                                            Text(
                                                "${StringUtils.capitalize(serviceDesc.desc)}",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600])),
                                          ]),
                                      Switch(
                                        value: service.use,
                                        // activeColor: Color(0xFF6200EE),
                                        onChanged: (bool newValue) {
                                          service.use = newValue;
                                          vm.onEditService(service);
                                        },
                                      )
                                    ]
                                  : [
                                      Text(
                                          "${StringUtils.capitalize(serviceDesc.desc)}:")
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
                                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: Text(
                                      "http${vm.state.currentProject.useSSL ? 's' : ''}://")),
                            if (usesSubdomain)
                              _createSubUrlField(service, serviceDesc, vm,
                                  'Invalid subdomain.'),
                            if (usesSubdomain) Text('.$domain'),
                            if (!usesSubdomain) Text('$domain/'),
                            if (!usesSubdomain)
                              _createSubUrlField(
                                  service, serviceDesc, vm, 'Invalid path.'),
                            if (!usesSubdomain) Text("/"),
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
                          ])
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
            hint: serviceDesc.hint,
            isCollapsed: true,
            regexp: FieldValidators.subdomain,
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
