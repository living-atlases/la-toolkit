import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/genericTextFormField.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:la_toolkit/components/servicesChipPanel.dart';
import 'package:la_toolkit/components/textWithHelp.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:latlong/latlong.dart';
import 'package:mdi/mdi.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:xterm/flutter.dart';
import 'package:xterm/frontend/terminal_view.dart';
import 'package:xterm/theme/terminal_themes.dart';
import 'package:xterm/xterm.dart';

import 'components/defDivider.dart';
import 'components/themeSelector.dart';
import 'models/appState.dart';
import 'models/laServiceDesc.dart';

class SandboxPage extends StatefulWidget {
  static const routeName = "sandbox";
  @override
  _SandboxPageState createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<LatLng> area = []..length = 5;
  bool firstPoint = true;

  Terminal terminal;

  @override
  void initState() {
    super.initState();
    terminal = Terminal(onInput: onInput, theme: TerminalThemes.defaultTheme);
    terminal.write('🧭 🏳️\u200d🌈🐣🐣￼  xterm.dart demo\r\n');
    for (var i = 0; i < 100; i++) {
      terminal.write('\x1B[${i}mHello World \x1B[0m\r\n');
    }
    terminal.write('\r\n');
    terminal.write('\$ ');
  }

  void onInput(String input) {
    if (input == '\r') {
      terminal.write('\r\n');
      terminal.write('\$ ');
    } else {
      terminal.write(input);
    }
  }

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
              new CircularPercentIndicator(
                radius: 45.0,
                lineWidth: 6.0,
                percent: 0.9,
                center: new Text("90%",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                progressColor: Colors.white,
              )
            ],
          ),
          body: Column(
            children: [
              Container(
                child: Column(
                  children: [ServicesChipPanel()],
                ),
              ),
              Column(
                children: <Widget>[
                  const SizedBox(height: 7),
                  DefDivider(),
                  // ServicesInServerChooser(server: "biocache-store-0.gbif.es"),
                  const SizedBox(height: 7),
                  Container(child: ThemeSelector()),
                  RaisedButton.icon(
                    icon: Icon(Mdi.key),
                    label: Text('SSH keys'),
                    onPressed: () => _onAlertWithCustomContentPressed(context),
                  ),
                  Wrap(
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
                      )),
                ],
              ),
            ],
          ));
    });
  }

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
  }

  _onAlertWithCustomContentPressed(context) {
    Alert(
        context: context,
        closeIcon: Icon(Icons.close),
        image: Icon(Mdi.key, size: 60, color: LAColorTheme.inactive),
        title: "Your SSH Keys",
        style: AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 600)),
        content: Column(
          children: <Widget>[
            FlatButton(
                onPressed: () => Api.genSshKey("test"),
                child: Text("Gen a SSH key")),
            FlatButton(
                onPressed: () => Api.sshKeysScan(),
                child: Text("Scan SSH keys")),
            DefDivider(),
            TextWithHelp(text: "Add a new ssh public key:", helpPage: "Ssh"),
            GenericTextFormField(
                initialValue: "",
                regexp: LARegExp.sshPubKey,
                error: "This is not a valid ssh public key",
                keyboardType: TextInputType.multiline,
                // filled: true,
                minLines:
                    3, // any number you need (It works as the rows for the textarea)
                maxLines: null,
                hint:
                    "Something like: ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9(...)",
                onChanged: (value) {
                  print(value);
                }),
            SizedBox(
              height: 20,
            ),
            Text("Your keys:"),
            /* TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: 'Username',
              ),
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                icon: Icon(Icons.lock),
                labelText: 'Password',
              ),
            ), */
          ],
        ),
        buttons: [
          DialogButton(
            width: 500,
            onPressed: () => Navigator.pop(context),
            child: Text(
              "FINISH",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}

class _SandboxViewModel {
  final AppState state;

  _SandboxViewModel({this.state});
}
