import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:latlong2/latlong.dart';

import 'components/defDivider.dart';
import 'models/appState.dart';

class SandboxPage extends StatefulWidget {
  static const routeName = "sandbox";

  const SandboxPage({Key? key}) : super(key: key);
  @override
  _SandboxPageState createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<LatLng> area = []..length = 5;
  bool firstPoint = true;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _SandboxViewModel>(converter: (store) {
      return _SandboxViewModel(
        state: store.state,
      );
    }, builder: (BuildContext context, _SandboxViewModel vm) {
      List<DropdownMenuItem<String>> releases = [];
      for (var element in vm.state.alaInstallReleases) {
        releases.add(DropdownMenuItem(child: Text(element), value: element));
      }
      return Scaffold(
          key: _scaffoldKey,
          // backgroundColor: Colors.white,

          appBar: LAAppBar(
            context: context,
            title: 'Sandbox',
            showBack: true,
            actions: const [],
          ),
          body: Column(
            children: [
              Column(
                children: const [
                  // FilePickerDemo(),
                  //  BrandingDialog(),
                ],
              ),
              Column(
                children: <Widget>[
                  const SizedBox(height: 7),
                  const DefDivider(),
                  // ServicesInServerChooser(server: "biocache-store-0.gbif.es"),
                  // BrandingSelector(),
                  const SizedBox(height: 7),
                  Container(),
                ],
              ),
            ],
          ));
    });
  }
}

class _SandboxViewModel {
  final AppState state;

  _SandboxViewModel({required this.state});
}
