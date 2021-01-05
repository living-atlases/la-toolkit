import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDescList.dart';
import 'package:la_toolkit/redux/actions.dart';

import 'formattedTitle.dart';
import 'helpIcon.dart';

class LaServiceWidget extends StatelessWidget {
  final LAService service;
  final LAService dependsOn;

  LaServiceWidget({Key key, this.service, this.dependsOn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool visible = dependsOn == null || dependsOn.use;
    var serviceDesc = serviceDescList[service.name];
    return StoreConnector<AppState, _LAServiceViewModel>(converter: (store) {
      return _LAServiceViewModel(
        state: store.state,
        onEditService: (service) => {store.dispatch(EditService(service))},
      );
    }, builder: (BuildContext context, _LAServiceViewModel vm) {
      return visible
          ? Card(
              elevation: 3,
              child: Container(
                  height: 180.0,
                  margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: serviceDesc.optional
                              ? Switch(
                                  value: service.use,
                                  // activeColor: Color(0xFF6200EE),
                                  onChanged: (bool newValue) {
                                    service.use = newValue;
                                    vm.onEditService(service);
                                  },
                                )
                              : null,
                          contentPadding: EdgeInsets.zero,
                          title: (serviceDesc.optional)
                              ? FormattedTitle(
                                  title:
                                      "Use the ${serviceDesc.name} service (${serviceDesc.desc})?")
                              : FormattedTitle(title: "${serviceDesc.desc}:"),
                          // subtitle: Text('TWICE', style: TextStyle(color: Colors.white)),
                          trailing: HelpIcon.url(
                              url: serviceDesc.sample,
                              tooltip: "See a similar service in production"),
                        ),
                        if (!serviceDesc.optional)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                "Use the ${serviceDesc.name} service (${serviceDesc.desc})?"),
                          ),
                        Text(
                            "http${vm.state.currentProject.useSSL ? 's' : ''}://${service.url(vm.state.currentProject.domain)}")
                      ])))
          : null;
    });
  }
/*
  Widget _formatTitle(String text) {
    return Text("${StringUtils.capitalize(text)}",
        style: GoogleFonts.signika(
            textStyle: TextStyle(
                color: LAColorTheme.laPalette.shade500,
                fontSize: 18,
                fontWeight: FontWeight.w400)));
  } */
}

class _LAServiceViewModel {
  final AppState state;
  final void Function(LAService service) onEditService;

  _LAServiceViewModel({this.state, this.onEditService});
}
