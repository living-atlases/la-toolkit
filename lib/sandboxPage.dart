import 'package:flutter/material.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:search_choices/search_choices.dart';

class SandboxPage extends StatelessWidget {
  static const routeName = "sandbox";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var searchServerList = List<DropdownMenuItem<String>>.empty(growable: true);
    searchServerList.add(DropdownMenuItem(child: Text('vm1'), value: 'vm1'));
    searchServerList.add(DropdownMenuItem(child: Text('vm2'), value: 'vm2'));
    return Scaffold(
        key: _scaffoldKey,
        // backgroundColor: Colors.white,
        appBar: LAAppBar(title: 'Sandbox'),
        body: Column(children: [
          Container(
              child: Column(
            children: [
              SearchChoices.single(
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
              )

              // IconButton(icon: Icon(Icons.swap_horiz))
              /* NeumorphicCheckbox(
                // margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                onChanged: (value) {},

                value: true,
              ),
              NeumorphicCheckbox(
                // margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                onChanged: (value) {},
                value: false,
              )*/
            ],
          ))
        ]));
  }

  Color _textColor(BuildContext context) {
    //if (NeumorphicTheme.isUsingDark(context)) {
    return Colors.black;
    ////return Colors.black;
    //}
  }
}
