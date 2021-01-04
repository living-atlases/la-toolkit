import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDescList.dart';
import 'package:la_toolkit/redux/actions.dart';

import '../laTheme.dart';
import 'helpIcon.dart';

class LaServiceWidget extends StatelessWidget {
  LAService _service;
  LAService _dependsOn;

  LaServiceWidget({Key key, LAService service, LAService dependsOn})
      : super(key: key) {
    _service = service;
    _dependsOn = dependsOn;
  }

  @override
  Widget build(BuildContext context) {
    bool visible = _dependsOn == null || _dependsOn.use;
    var serviceDesc = serviceDescList[_service.name];
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
                        Text("${StringUtils.capitalize(serviceDesc.desc)}:",
                            style: GoogleFonts.signika(
                                textStyle: TextStyle(
                                    color: LAColorTheme.laPalette.shade500,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400))),
                        HelpIcon.url(
                            url: serviceDesc.sample,
                            tooltip: "See a similar service in production"),
                        if (!serviceDesc.optional)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                "Use the ${_service.name} service (${serviceDesc.desc})?"),
                            trailing: Switch(
                              value: _service.use,
                              // activeColor: Color(0xFF6200EE),
                              onChanged: (bool newValue) {
                                _service.use = newValue;
                                vm.onEditService(_service);
                              },
                            ),
                          ),
                        Text(
                            "http${vm.state.currentProject.useSSL ? 's' : ''}://${_service.url(vm.state.currentProject.domain)}")
                      ])))
          : null;
    });
  }
}

class _LAServiceViewModel {
  final AppState state;
  final void Function(LAService service) onEditService;

  _LAServiceViewModel({this.state, this.onEditService});
}
