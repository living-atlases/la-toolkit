import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/genericTextFormField.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:la_toolkit/components/servicesChipPanel.dart';
import 'package:la_toolkit/components/textWithHelp.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:latlong/latlong.dart';
import 'package:mdi/mdi.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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
                  RaisedButton.icon(
                    icon: Icon(Mdi.key),
                    label: Text('SSH keys'),
                    onPressed: () => _onAlertWithCustomContentPressed(context),
                  ),
                ],
              ),
            ],
          ));
    });
  }

  _onAlertWithCustomContentPressed(context) {
    Alert(
        context: context,
        closeIcon: Icon(Icons.close),
        image: Icon(Mdi.key, size: 60, color: LAColorTheme.inactive),
        title: "Your SSH Public Keys",
        style: AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 600)),
        content: Column(
          children: <Widget>[
            DefDivider(),
            TextWithHelp(text: "Add a new ssh public key:", helpPage: "Ssh"),
            GenericTextFormField(
                initialValue: "",
                regexp: LARegExp.sshPubKey,
                error: "This is not a valid ssh public key",
                keyboardType: TextInputType.multiline,
                filled: true,
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
