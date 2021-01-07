import 'package:flutter/material.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:la_toolkit/components/servicesChipPanel.dart';

class SandboxPage extends StatefulWidget {
  static const routeName = "sandbox";
  @override
  _SandboxPageState createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    /* var searchServerList = List<DropdownMenuItem<String>>.empty(growable: true);
    searchServerList.add(DropdownMenuItem(child: Text('vm1'), value: 'vm1'));
    searchServerList.add(DropdownMenuItem(child: Text('vm2'), value: 'vm2')); */
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
            /*SearchChoices.single(
                items: searchServerList,
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
              )*/
          ],
        ));
  }
}
