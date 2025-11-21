import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:latlong2/latlong.dart';
import 'package:redux/redux.dart';

import './models/app_state.dart';
import 'components/generic_selector.dart';
import 'components/la_app_bar.dart';
import 'components/scroll_panel.dart';
import 'components/software_selector.dart';

class SandboxPage extends StatefulWidget {
  const SandboxPage({super.key});

  static const String routeName = 'sandbox';

  @override
  State<SandboxPage> createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<LatLng> area = <LatLng>[]..length = 5;
  bool firstPoint = true;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _SandboxViewModel>(
      converter: (Store<AppState> store) {
        return _SandboxViewModel(state: store.state);
      },
      builder: (BuildContext context, _SandboxViewModel vm) {
        final List<DropdownMenuItem<String>> releases =
            <DropdownMenuItem<String>>[];
        for (final String element in vm.state.alaInstallReleases) {
          releases.add(
            DropdownMenuItem<String>(value: element, child: Text(element)),
          );
        }
        return Scaffold(
          key: _scaffoldKey,

          // backgroundColor: Colors.white,
          appBar: LAAppBar(
            context: context,
            title: 'Sandbox',
            showBack: true,
            actions: const <Widget>[],
          ),
          body: ScrollPanel(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 7),
                  // const DefDivider(),
                  // ServicesInServerChooser(server: "biocache-store-0.gbif.es"),
                  // BrandingSelector(),
                  const SizedBox(height: 7),
                  Container(),
                  GenericSelector<String>(
                    values: const <String>['a', 'b', 'c'],
                    currentValue: 'b',
                    onChange: (String v) {
                      debugPrint(v);
                    },
                  ),
                  SoftwareSelector(
                    versions: const <String>['a', 'b'],
                    onChange: (String? value) {
                      debugPrint(value);
                    },
                    label: 'Test',
                  ),
                  SoftwareSelector(
                    versions: const <String>['a', 'b'],
                    onChange: (String? value) {
                      debugPrint(value);
                    },
                    label: 'Test',
                  ),
                  DropdownButton<String>(
                    value: 'Dept1',
                    elevation: 16,
                    icon: const Icon(Icons.arrow_drop_down_circle),
                    isExpanded: true,
                    items: <String>['Dept1', 'Dept2'].map((String e) {
                      return DropdownMenuItem<String>(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (String? value) {
                      debugPrint(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SandboxViewModel {
  _SandboxViewModel({required this.state});

  final AppState state;
}
