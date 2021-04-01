import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'components/defDivider.dart';
import 'models/appState.dart';

class SandboxPage extends StatefulWidget {
  static const routeName = "sandbox";
  @override
  _SandboxPageState createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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
      vm.state.alaInstallReleases.forEach((element) =>
          releases.add(DropdownMenuItem(child: Text(element), value: element)));
      return Scaffold(
          key: _scaffoldKey,
          // backgroundColor: Colors.white,

          appBar: LAAppBar(
            context: context,
            title: 'Sandbox',
            showBack: true,
            actions: [],
          ),
          body: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    // FilePickerDemo(),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  const SizedBox(height: 7),
                  DefDivider(),
                  // ServicesInServerChooser(server: "biocache-store-0.gbif.es"),
                  const SizedBox(height: 7),
                  //
                ],
              ),
            ],
          ));
    });
  }

  Future<T> showFloatingModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
  }) async {
    final result = await showCustomModalBottomSheet(
        context: context,
        builder: builder,
        containerWidget: (_, animation, child) => FloatingModal(
              child: child,
            ),
        expand: false);

    return result;
  }
}

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingModal({Key? key, required this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(100, 100, 100, 0),
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

class _SandboxViewModel {
  final AppState state;

  _SandboxViewModel({required this.state});
}
