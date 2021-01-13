import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:la_toolkit/components/servicesChipPanel.dart';
import 'package:search_choices/search_choices.dart';

import 'components/defDivider.dart';
import 'models/appState.dart';

class SandboxPage extends StatefulWidget {
  static const routeName = "sandbox";
  @override
  _SandboxPageState createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    /*
    searchServerList.add(DropdownMenuItem(child: Text('vm1'), value: 'vm1'));
    searchServerList.add(DropdownMenuItem(child: Text('vm2'), value: 'vm2'));*/

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
          appBar: LAAppBar(context: context, title: 'Sandbox'),
          body: Column(
            children: [
              Container(
                child: Column(
                  children: [ServicesChipPanel()],
                ),
              ),
              SearchChoices.single(
                items: releases,
                // searchFn: (value) ,

                // vm.state.currentProject.servers.toList(),
                // value: searchServerList[0].value ?? "vm1",
                hint: "Select one",
                searchHint: "Select one",
                onChanged: (value) {
                  print(value);
                  // service.servers[0] = value;
                },
                isExpanded: false,
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  /* decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)), */
                  child: Tooltip(
                      message:
                          "Choose the latest release to update your portal",
                      child: DropdownButtonFormField(
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 32,
                          // hint: Text("Recommended a recent version"),
                          // underline: SizedBox(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[300],
                            labelText: 'ala-install release',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            // border: new CustomBorderTextFieldSkin().getSkin(),
                          ),
                          // value: _value,
                          items: releases,
                          onChanged: (value) {
                            /* setState(() {
                  _value = value;
                }); */
                            print(value);
                          }))),
              Column(
                children: <Widget>[
                  const SizedBox(height: 7),
                  DefDivider(),
                  // ServicesInServerChooser(server: "biocache-store-0.gbif.es"),
                  const SizedBox(height: 7),
                ],
              ),
            ],
          ));
    });
  }
}

class _SandboxViewModel {
  final AppState state;

  _SandboxViewModel({this.state});
}
