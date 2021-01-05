import 'package:flutter/material.dart';
import 'package:la_toolkit/utils/debounce.dart';

import 'helpIcon.dart';

class GenericTextFormField extends StatefulWidget {
  final String label;
  final String hint;
  final String initialValue;
  final String prefixText;
  final String wikipage;
  final RegExp regexp;
  final String error;
  final bool isDense;
  final bool isCollapsed;
  final ValueChanged<String> onChanged;

  GenericTextFormField({
    this.label,
    this.hint,
    @required this.initialValue,
    this.prefixText,
    this.wikipage,
    @required this.regexp,
    @required this.error,
    @required this.onChanged,
    this.isDense = false,
    this.isCollapsed = false,
  });

  @override
  _GenericTextFormFieldState createState() => _GenericTextFormFieldState();
}

class _GenericTextFormFieldState extends State<GenericTextFormField> {
  final debouncer = Debouncer(milliseconds: 2000);
  var formKey;

  @override
  void initState() {
    formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: TextFormField(
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              isCollapsed: widget.isCollapsed,
              isDense: widget.isDense,
              prefixText: widget.prefixText,
              suffixIcon: widget.wikipage == null
                  ? null
                  : Padding(
                      padding:
                          EdgeInsets.only(top: 5), // add padding to adjust icon
                      child: HelpIcon(wikipage: widget.wikipage)),
            ),
            // onChanged: ,
            onChanged: (String value) => debouncer.run(() {
                  if (formKey.currentState.validate()) {
                    widget.onChanged(value);
                  }
                }),
            initialValue: widget.initialValue,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String value) =>
                !widget.regexp.hasMatch(value) ? widget.error : null));
  }
}
