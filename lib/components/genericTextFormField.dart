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
  final bool enabledBorder;
  final bool monoSpaceFont;

  GenericTextFormField(
      {this.label,
      this.hint,
      @required this.initialValue,
      this.prefixText,
      this.wikipage,
      this.regexp,
      @required this.error,
      @required this.onChanged,
      this.isDense = false,
      this.isCollapsed = false,
      this.focusNode,
      this.minLines,
      this.maxLines = 1,
      this.filled = false,
      this.allowEmpty = false,
      this.enabledBorder = false,
      this.monoSpaceFont = false,
      this.keyboardType});

  @override
  _GenericTextFormFieldState createState() => _GenericTextFormFieldState();
}

class _GenericTextFormFieldState extends State<GenericTextFormField> {
  final debouncer = Debouncer(milliseconds: 1000);
  var formKey;
  String delayedValue;

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
                    enabledBorder: widget.enabledBorder
                        ? OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]))
                        : null // , width: 1.0),
                    ,
                  ),
                  // onChanged: ,
                  onChanged: (String value) => debouncer.run(() {
                        setState(() {
                          delayedValue = value;
                          if (formKey.currentState.validate()) {
                            widget.onChanged(value);
                          }
                        });
                      }),
                  style: !widget.monoSpaceFont
                      ? LAProjectEditPage.projectTextStyle
                      : LAProjectEditPage.projectFixedTextStyle,
                  focusNode: widget.focusNode,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
                  initialValue: widget.initialValue,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (_) => widget.regexp != null &&
                          delayedValue != null &&
                          !widget.regexp.hasMatch(delayedValue) &&
                          !(widget.allowEmpty && delayedValue.isEmpty)
                      ? widget.error
                      : null)
            ]));
  }
}
