import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import '../laTheme.dart';
import '../models/laServiceDesc.dart';
import '../utils/StringUtils.dart';

class ServicesChipPanel extends StatefulWidget {

  const ServicesChipPanel(
      {super.key,
      required this.onChange,
      required this.services,
      required this.initialValue,
      required this.isHub});
  final Function(List<String>) onChange;
  final List<String> services;
  final List<String> initialValue;
  final bool isHub;

  @override
  State<ServicesChipPanel> createState() => _ServicesChipPanelState();
}

class _ServicesChipPanelState extends State<ServicesChipPanel> {
  static const EdgeInsets padding = EdgeInsets.fromLTRB(5, -2, 5, -2);
  static const EdgeInsets margin = EdgeInsets.fromLTRB(0, 10, 0, 10);
  final GlobalKey<State<StatefulWidget>> _chipsKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final C2ChoiceStyle allStyle = const C2ChoiceStyle(
    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    // color: Colors.red,
    // margin: EdgeInsets.fromLTRB(0, 40, 40, 20),

    borderRadius: BorderRadius.all(Radius.circular(15)),
    padding: EdgeInsets.fromLTRB(10, 0, 10, 2),
    showCheckmark: true,
  );
  late List<String> formValue; // LAServiceDesc.list[3].name];
  List<String> _selectAllOrElements(List<String> values) {
    final List<String> newVal = values.isNotEmpty
        ? values.last == 'all'
            ? <String>['all']
            : values.where((String item) => item != 'all').toList()
        : <String>[];
    // debugPrint(newVal);
    return newVal;
  }

  @override
  void initState() {
    formValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          FormField<List<String>>(
            autovalidateMode: AutovalidateMode.always,
            initialValue: formValue,
            onSaved: (List<String>? val) {
              setState(() {
                if (val != null) {
                  // debugPrint('$val');
                  formValue = val;
                }
              });
            },
            validator: (List<String>? value) {
              return null;
            },
            builder: (FormFieldState<List<String>> state) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child:
                        // alignment: Alignment.centerLeft,
                        ChipsChoice<String>.multiple(
                      key: _chipsKey,
                      value: formValue,
                      // state.value, // _selectAllOrElements(state.value),
                      onChanged: (List<String> values) {
                        setState(() {
                          formValue = _selectAllOrElements(values);
                          widget.onChange(formValue);
                        });
                        // debugPrint("onChanged: $values");
                        // return state.didChange(values);
                      },
                      runSpacing: -10,
                      choiceItems: C2Choice.listFrom<String, LAServiceDesc>(
                          source: LAServiceDesc.list(widget.isHub)
                              .where((LAServiceDesc s) => widget.services.contains(s.nameInt))
                              .toList(),
                          value: (int i, LAServiceDesc v) => v.nameInt,
                          label: (int i, LAServiceDesc v) => v.name,
                          tooltip: (int i, LAServiceDesc v) => StringUtils.capitalize(v.desc),
                          /* style: (i, v) {
                            if (i == 0) {
                            return null;
                          }, */
                          disabled: (int i, LAServiceDesc v) => false)
                        ..add(C2Choice<String>(
                            value: 'all',
                            label: 'all',
                            activeStyle: allStyle,
                            style: allStyle)),
                      choiceBuilder: (C2Choice<String> item) {
                        if (item.value == 'all') {
                          return CustomChip(
                              label: item.label!,
                              width: double.infinity,
                              height: 40,
                              // color: Colors.redAccent,
                              margin: const EdgeInsets.fromLTRB(0, 15, 30, 5),
                              selected: item.selected,
                              onSelect: item.select!);
                        } else {
                          return null;
                        }
                      },
                      choiceStyle: const C2ChoiceStyle(
                          // color: Colors.indigo,
                          // disabledColor: Colors.grey,
                          margin: margin,
                          labelPadding: padding,
                          showCheckmark: true,
                          labelStyle: TextStyle(fontSize: 12),
                          borderOpacity: .3),
                      choiceActiveStyle: const C2ChoiceStyle(
                        // color: Colors.indigo,
                        margin: margin,
                        showCheckmark: true,
                        labelPadding: padding,
                        labelStyle: TextStyle(fontSize: 12),
                        brightness: Brightness.dark,
                      ),
                      wrapped: true,
                      // mainAxisSize: MainAxisSize.max,
                    ),
                  ),
                ],
              );
            },
          )
        ]));
  }
}

class CustomChip extends StatelessWidget {

  const CustomChip({
    super.key,
    required this.label,
    this.color,
    required this.width,
    required this.height,
    this.margin,
    required this.selected,
    required this.onSelect,
  });
  final String label;
  final Color? color;
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final Function(bool selected) onSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: width,
      height: height,
      margin: margin ??
          const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 5,
          ),
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color:
            selected ? (color ?? LAColorTheme.laPalette) : Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(selected ? 20 : 20)),
        border: Border.all(
          color: selected ? (color ?? LAColorTheme.laPalette) : Colors.grey,
        ),
      ),
      child: InkWell(
        onTap: () => onSelect(!selected),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Visibility(
                visible: selected,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                )),
            Positioned(
              left: 0,
              top: 9,
              right: -46,
              bottom: 7,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
