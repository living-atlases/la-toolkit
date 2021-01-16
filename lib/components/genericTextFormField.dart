import 'package:flutter/material.dart';
import 'package:la_toolkit/utils/debounce.dart';

import '../projectEditPage.dart';
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
  final FocusNode focusNode;
  final bool allowEmpty;
  final int minLines;
  final int maxLines;
  final TextInputType keyboardType;
  final bool filled;

  GenericTextFormField(
      {this.label,
      this.hint,
      @required this.initialValue,
      this.prefixText,
      this.wikipage,
      @required this.regexp,
      @required this.error,
      @required this.onChanged,
      this.isDense = false,
      this.isCollapsed = false,
      this.focusNode,
      this.minLines,
      this.maxLines,
      this.filled = false,
      this.allowEmpty = false,
      this.keyboardType});

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
        child: Column(
            // Need this to align correctly error with text field
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextFormField(
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hint,
                    isCollapsed: widget.isCollapsed,
                    isDense: widget.isDense,
                    prefixText: widget.prefixText,
                    filled: widget.filled,
                    suffixIcon: widget.wikipage == null
                        ? null
                        : Padding(
                            padding: EdgeInsets.only(
                                top: 5), // add padding to adjust icon
                            child: HelpIcon(wikipage: widget.wikipage)),
                  ),
                  // onChanged: ,
                  onChanged: (String value) => debouncer.run(() {
                        if (formKey.currentState.validate()) {
                          widget.onChanged(value);
                        }
                      }),
                  style: LAProjectEditPage.projectTextStyle,
                  focusNode: widget.focusNode,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
                  initialValue: widget.initialValue,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String value) => !widget.regexp.hasMatch(value) &&
                          !(widget.allowEmpty && value.isEmpty)
                      ? widget.error
                      : null)
            ]));
  }
}
