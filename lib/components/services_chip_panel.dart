import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import '../models/la_service_desc.dart';
import '../utils/string_utils.dart';

class ServicesChipPanel extends StatefulWidget {
  const ServicesChipPanel(
      {super.key, required this.onChange, required this.services, required this.initialValue, required this.isHub});

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
  final C2ChipStyle allStyle = const C2ChipStyle(
    // labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    // color: Colors.red,
    // margin: EdgeInsets.fromLTRB(0, 40, 40, 20),

    borderRadius: BorderRadius.all(Radius.circular(15)),
    padding: EdgeInsets.fromLTRB(10, 0, 10, 2),

    // showCheckmark: true,
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
                    child: ChipsChoice<String>.multiple(
                        key: _chipsKey,
                        wrapped: true,
                        choiceCheckmark: true,
                        value: formValue,
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
                            disabled: (int i, LAServiceDesc v) => false)
                          ..add(C2Choice<String>(value: 'all', label: 'all', style: allStyle)),
                        choiceBuilder: (C2Choice<String> item, int i) {
                          if (item.value == 'all') {
                            return CustomChip(
                                label: item.label,
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
                        choiceStyle: C2ChipStyle.outlined(
                          // borderWidth: 1,
                          borderRadius: const BorderRadius.all(Radius.circular(25)),
                          margin: margin,
                          height: 40,
                          padding: padding,
                          selectedStyle: C2ChipStyle.filled(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25),
                            ),
                          ),
                          // labelStyle: TextStyle(fontSize: 12),
                        ) //borderOpacity: .9),
                        /*   choiceActiveStyle: const C2ChipStyle(
                        // color: Colors.indigo,
                        margin: margin,
                        padding: padding,
                        labelStyle: TextStyle(fontSize: 12),
                        brightness: Brightness.dark,
                      ), */
                        ),
                  )
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
    this.width,
    required this.height,
    this.margin,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final Color? color;
  final double? width;
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
        color: selected ? (color ?? Theme.of(context).primaryColor) : Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(selected ? 20 : 20)),
        border: Border.all(
          color: selected ? (color ?? Theme.of(context).primaryColor) : Colors.grey,
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
