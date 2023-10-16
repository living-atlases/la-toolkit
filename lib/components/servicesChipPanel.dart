import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

class ServicesChipPanel extends StatefulWidget {
  final Function(List<String>) onChange;
  final List<String> services;
  final List<String> initialValue;
  final bool isHub;

  const ServicesChipPanel(
      {super.key,
      required this.onChange,
      required this.services,
      required this.initialValue,
      required this.isHub});

  @override
  State<ServicesChipPanel> createState() => _ServicesChipPanelState();
}

class _ServicesChipPanelState extends State<ServicesChipPanel> {
  static const padding = EdgeInsets.fromLTRB(5, -2, 5, -2);
  static const margin = EdgeInsets.fromLTRB(0, 10, 0, 10);
  final _chipsKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final allStyle = const C2ChoiceStyle(
    labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    // color: Colors.red,
    // margin: EdgeInsets.fromLTRB(0, 40, 40, 20),

    borderRadius: BorderRadius.all(Radius.circular(15)),
    padding: EdgeInsets.fromLTRB(10, 0, 10, 2),
    showCheckmark: true,
  );
  late List<String> formValue; // LAServiceDesc.list[3].name];
  List<String> _selectAllOrElements(List<String> values) {
    List<String> newVal = values.isNotEmpty
        ? values.last == 'all'
            ? ['all']
            : values.where((item) => item != 'all').toList()
        : [];
    // print(newVal);
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
        child: Column(children: [
          FormField<List<String>>(
            autovalidateMode: AutovalidateMode.always,
            initialValue: formValue,
            onSaved: (List<String>? val) {
              setState(() {
                if (val != null) {
                  // print('$val');
                  formValue = val;
                }
              });
            },
            validator: (List<String>? value) {
              return null;
            },
            builder: (state) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child:
                        // alignment: Alignment.centerLeft,
                        ChipsChoice<String>.multiple(
                      key: _chipsKey,
                      value: formValue,
                      // state.value, // _selectAllOrElements(state.value),
                      onChanged: (values) {
                        setState(() {
                          formValue = _selectAllOrElements(values);
                          widget.onChange(formValue);
                        });
                        // print("onChanged: $values");
                        // return state.didChange(values);
                      },
                      runSpacing: -10,
                      choiceItems: C2Choice.listFrom<String, LAServiceDesc>(
                          source: LAServiceDesc.list(widget.isHub)
                              .where((s) => widget.services.contains(s.nameInt))
                              .toList(),
                          value: (i, v) => v.nameInt,
                          label: (i, v) => v.name,
                          tooltip: (i, v) => StringUtils.capitalize(v.desc),
                          /* style: (i, v) {
                            if (i == 0) {
                            return null;
                          }, */
                          disabled: (i, v) => false)
                        ..add(C2Choice<String>(
                            value: 'all',
                            label: 'all',
                            activeStyle: allStyle,
                            style: allStyle)),
                      choiceBuilder: (item) {
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
  final String label;
  final Color? color;
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;
  final bool selected;
  final Function(bool selected) onSelect;

  const CustomChip({
    Key? key,
    required this.label,
    this.color,
    required this.width,
    required this.height,
    this.margin,
    required this.selected,
    required this.onSelect,
  }) : super(key: key);

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
          width: 1,
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
