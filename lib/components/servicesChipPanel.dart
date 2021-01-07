import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

class ServicesChipPanel extends StatefulWidget {
  ServicesChipPanel({Key key}) : super(key: key);

  @override
  _ServicesChipPanelState createState() => _ServicesChipPanelState();
}

class _ServicesChipPanelState extends State<ServicesChipPanel> {
  static const padding = EdgeInsets.fromLTRB(2, -5, 2, -5);
  static const margin = EdgeInsets.fromLTRB(0, 0, 0, 0);
  final _formKey = GlobalKey<FormState>();

  List<String> formValue; // LAServiceDesc.list[3].name];

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          FormField<List<String>>(
            autovalidateMode: AutovalidateMode.always,
            //autovalidate: true,
            initialValue: formValue,
            onSaved: (List<String> val) {
              setState(() {
                print('$val');
                formValue = val;
              });
            },
            validator: (List<String> value) {
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
                      choiceItems: C2Choice.listFrom<String, LAServiceDesc>(
                          source: LAServiceDesc.list,
                          value: (i, v) => v.name,
                          label: (i, v) => v.name,
                          tooltip: (i, v) => StringUtils.capitalize(v.desc),
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
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        state.errorText ??
                            state.value.length.toString() + '/5 selected',
                        style: TextStyle(
                            color: state.hasError
                                ? Colors.redAccent
                                : Colors.green),
                      )),
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
                              if (_formKey.currentState.validate()) {
                                // If the form is valid, save the value.
                                _formKey.currentState.save();
                              }
                            }),
                      ],
                    ),
                  ),
                ],
              );
            },
          )
        ]));
  }
}
