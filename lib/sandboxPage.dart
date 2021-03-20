import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/*import 'package:xterm/theme/terminal_themes.dart';
import 'package:xterm/xterm.dart';*/

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

  // late Terminal terminal;

  @override
  void initState() {
    super.initState();
    /*terminal = Terminal(onInput: onInput, theme: TerminalThemes.defaultTheme);
    terminal.write('🧭 🏳️\u200d🌈🐣🐣￼  xterm.dart demo\r\n');
    for (int i = 0; i < 100; i++) {
      terminal.write('\x1B[${i}mHello World \x1B[0m\r\n');
    }
    terminal.write('\r\n');
    terminal.write('\$ ');*/
  }

/*  void onInput(String input) {
    if (input == '\r') {
      terminal.write('\r\n');
      terminal.write('\$ ');
    } else {
      terminal.write(input);
    }
  }*/

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
            actions: [
              /* new CircularPercentIndicator(
                radius: 45.0,
                lineWidth: 6.0,
                percent: 0.9,
                center: new Text("90%",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                progressColor: Colors.white,
              ) */
            ],
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

                  /* ElevatedButton.icon(
                      icon: Icon(Mdi.console),
                      label: Text('CONSOLE'),
                      onPressed: () => showFloatingModalBottomSheet(
                          // showBarModalBottomSheet(
                          //)showCupertinoModalBottomSheet(
                          //expand: false,
                          context: context,

                          //isDismissible: true,
                          //useRootNavigator: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Material(
                                child: Scaffold(
                                  appBar: AppBar(
                                    leading: Icon(
                                      Mdi.console,
                                      color: Colors.white,
                                    ),
                                    title: Text(
                                      'CONSOLE',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    actions: [
                                      Tooltip(
                                        message: "Close the console",
                                        child: TextButton(
                                            child: const Icon(Icons.close,
                                                color: Colors.white),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }),
                                      ),
                                    ],
                                  ),
                                  body: SafeArea(
                                      bottom: false,
                                      child: Container(
                                          color: LAColorTheme.laPalette,
                                          padding:
                                              EdgeInsets.fromLTRB(3, 0, 8, 0),
                                          child: WebBrowser(
                                            initialUrl:
                                                'http://localhost:8081/',
                                            interactionSettings:
                                                WebBrowserInteractionSettings(
                                                    topBar: null,
                                                    bottomBar: null),
                                            javascriptEnabled: true,
                                          ))),
                                ),
                              )

                          */ /*
                                SafeArea(
                                child: Column(children: [
                              Container(
                                  color: LAColorTheme.laPalette, height: 40),
                              WebBrowser(
                                initialUrl: 'http://localhost:8081/',
                                interactionSettings:
                                    WebBrowserInteractionSettings(
                                        topBar: null, bottomBar: null),
                                javascriptEnabled: true,
                              )
                            ])), */ /*
                          ))*/

                  /* Wrap(
                      spacing: 6,
                      children: vm.state.currentProject
                          .getServicesNameListInUse()
                          .map((service) =>
                              _buildChip(LAServiceDesc.map[service].name))
                          .toList()),
                  Container(
                      height: 400,
                      child: SafeArea(
                        child: TerminalView(terminal: terminal),
                      )), */
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

  /*
  Widget _buildChip(String label) {
    return Chip(
      // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: EdgeInsets.fromLTRB(6, 0, 0, 0),
      avatar: Icon(Icons.done, color: Colors.green, size: 18),
      label: Text(
        label,
        style: TextStyle(
          color: LAColorTheme.inactive,
        ),
      ),
      // backgroundColor: Colors.white,
      elevation: 2.0,
      // shadowColor: Colors.grey[60],
      padding: EdgeInsets.all(8.0),
    );
  } */
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
/*
class ModalWithPageView extends StatelessWidget {
  const ModalWithPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar:
            AppBar(leading: Container(), title: Text('TERM')),
        body: SafeArea(
          bottom: false,
          child: Container()
        ),
      ),
    );
  }
}
*/
