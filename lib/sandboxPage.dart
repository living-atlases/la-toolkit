import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:search_choices/search_choices.dart';

import 'models/laServiceDescList.dart';

class SandboxPage extends StatefulWidget {
  static const routeName = "sandbox";
  @override
  _SandboxPageState createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> formValue;

  List<String> tags = ['records'];
  List<LAServiceDesc> options = serviceDescList
      .map((key, value) => MapEntry(value.name, value))
      .values
      .toList();
  /*
  [
    'News',
    'Entertainment',
    'Politics',
    'Automotive',
    'Sports',
    'Education',
    'Fashion',
    'Travel',
    'Food',
    'Tech',
    'Science',
  ];*/

  @override
  Widget build(BuildContext context) {
    var searchServerList = List<DropdownMenuItem<String>>.empty(growable: true);
    searchServerList.add(DropdownMenuItem(child: Text('vm1'), value: 'vm1'));
    searchServerList.add(DropdownMenuItem(child: Text('vm2'), value: 'vm2'));
    const padding = EdgeInsets.fromLTRB(2, -5, 2, -5);
    const margin = EdgeInsets.fromLTRB(0, 0, 0, 0);
    return Scaffold(
        key: _scaffoldKey,
        // backgroundColor: Colors.white,
        appBar: LAAppBar(context: context, title: 'Sandbox'),
        body: Column(children: [
          Container(
              child: Column(
            children: [
              /* ChipsChoice<String>.multiple(
                wrapped: true,
                value: tags,
                onChanged: (val) {
                  setState(() => tags = val);
                },
                choiceStyle: C2ChoiceStyle(
                  showCheckmark: true,

                  labelStyle: const TextStyle(fontSize: 12),
                  //borderRadius: const BorderRadius.all(Radius.circular(5)),
                  //borderColor: Colors.blueGrey.withOpacity(.5),
                ),
                choiceActiveStyle: const C2ChoiceStyle(
                  brightness: Brightness.dark,
                  borderShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      side: BorderSide(color: Colors.lightGreen, width: 0.0)),
                ),
                choiceItems: C2Choice.listFrom<String, LAServiceDesc>(
                    source: options,
                    value: (i, v) => v.nameInt,
                    label: (i, v) => v.name,
                    tooltip: (i, v) => StringUtils.capitalize(v.desc)),
              ), */
              Form(
                key: formKey,
                child: Column(
                  children: [
                    FormField<List<String>>(
                      autovalidate: true,
                      initialValue: formValue,
                      onSaved: (val) => setState(() => formValue = val),
                      validator: (value) {
                        if (value?.isEmpty ?? value == null) {
                          return 'Please select some categories';
                        }
                        if (value.length > 5) {
                          return "Can't select more than 5 categories";
                        }
                        return null;
                      },
                      builder: (state) {
                        return Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              child: ChipsChoice<String>.multiple(
                                value: state.value,
                                onChanged: (val) => state.didChange(val),
                                runSpacing: -15,
                                choiceItems:
                                    C2Choice.listFrom<String, LAServiceDesc>(
                                        source: options,
                                        value: (i, v) => v.nameInt,
                                        label: (i, v) => v.name,
                                        tooltip: (i, v) =>
                                            StringUtils.capitalize(v.desc),
                                        disabled: (i, v) => false),
                                choiceStyle: const C2ChoiceStyle(
                                    // color: Colors.indigo,
                                    // disabledColor: Colors.grey,
                                    margin: margin,
                                    labelPadding: padding,
                                    showCheckmark: false,
                                    labelStyle: const TextStyle(fontSize: 12),
                                    borderOpacity: .3),
                                choiceActiveStyle: const C2ChoiceStyle(
                                  // color: Colors.indigo,
                                  margin: margin,
                                  showCheckmark: false,
                                  labelPadding: padding,
                                  labelStyle: const TextStyle(fontSize: 12),
                                  brightness: Brightness.dark,
                                ),
                                wrapped: true,
                              ),
                            ),
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 0, 15, 10),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  state.errorText ??
                                      state.value.length.toString() +
                                          '/5 selected',
                                  style: TextStyle(
                                      color: state.hasError
                                          ? Colors.redAccent
                                          : Colors.green),
                                ))
                          ],
                        );
                      },
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text('Selected Value:'),
                                  SizedBox(height: 5),
                                  Text('${formValue.toString()}')
                                ]),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          RaisedButton(
                              child: const Text('Submit'),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              onPressed: () {
                                // Validate returns true if the form is valid, or false otherwise.
                                if (formKey.currentState.validate()) {
                                  // If the form is valid, save the value.
                                  formKey.currentState.save();
                                }
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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
}
