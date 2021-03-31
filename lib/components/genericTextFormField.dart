import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/utils/debounce.dart';

import 'helpIcon.dart';

class GenericTextFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextStyle? hintStyle;
  final String? initialValue;
  final String? prefixText;
  final String? wikipage;
  final RegExp? regexp;
  final String? error;
  final bool isDense;
  final bool isCollapsed;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final bool allowEmpty;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final Color? fillColor;
  final bool enabledBorder;
  final bool monoSpaceFont;
  final bool deployed;
  final bool obscureText;

  GenericTextFormField({
    this.label,
    this.hint,
    this.hintStyle,
    required this.initialValue,
    this.prefixText,
    this.wikipage,
    this.regexp,
    required this.error,
    required this.onChanged,
    this.isDense = false,
    this.isCollapsed = false,
    this.focusNode,
    this.minLines,
    this.maxLines = 1,
    this.fillColor,
    this.allowEmpty = false,
    this.enabledBorder = false,
    this.monoSpaceFont = false,
    this.obscureText = false,
    this.keyboardType,
    this.deployed = false,
  });

  @override
  _GenericTextFormFieldState createState() => _GenericTextFormFieldState();
}

class _GenericTextFormFieldState extends State<GenericTextFormField>
    with AutomaticKeepAliveClientMixin {
  final debouncer = Debouncer(milliseconds: 1000);
  late GlobalKey<FormState> formKey;
  String? delayedValue;
  late bool obscureTextState;

  @override
  void initState() {
    formKey = GlobalKey<FormState>();
    obscureTextState = widget.obscureText;
    super.initState();
  }

  void showPass(bool state) {
    setState(() {
      obscureTextState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final decoration = InputDecoration(
        fillColor: widget.fillColor,
        labelText: widget.label,
        hintText: widget.hint,
        isCollapsed: widget.isCollapsed,
        isDense: widget.isDense,
        labelStyle: widget.hintStyle ?? null,
        prefixText: widget.prefixText,
        filled: widget.fillColor != null,
        suffixIcon: widget.wikipage == null
            ? widget.obscureText
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        child: Icon(obscureTextState
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onTapUp: (tap) => showPass(true),
                        onTapDown: (tap) => showPass(false)))
                : null
            : Padding(
                padding: EdgeInsets.only(top: 5), // add padding to adjust icon
                child: HelpIcon(wikipage: widget.wikipage!)),
        enabledBorder: widget.enabledBorder
            ? OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[500]!))
            : null // , width: 1.0),
        );
    final onChange = (String value) => debouncer.run(() {
          setState(() {
            delayedValue = value;
            if (formKey.currentState != null &&
                formKey.currentState!.validate()) {
              widget.onChanged(value);
            }
          });
        });
    final validator = (_) => widget.regexp != null &&
            delayedValue != null &&
            !widget.regexp!.hasMatch(delayedValue!) &&
            !(widget.allowEmpty && delayedValue!.isEmpty)
        ? widget.error
        : null;
    final style = widget.deployed
        ? !widget.monoSpaceFont
            ? LAColorTheme.deployedTextStyle
            : LAColorTheme.fixedDeployedTextStyle
        : !widget.monoSpaceFont
            ? LAColorTheme.unDeployedTextStyle
            : LAColorTheme.fixedUnDeployedTextStyle;
    return Form(
        key: formKey,
        child: Column(
            // Need this to align correctly error with text field
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextFormField(
                  decoration: decoration,
                  onChanged: onChange,
                  style: style,
                  focusNode: widget.focusNode,
                  obscureText: obscureTextState,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
                  initialValue: widget.initialValue,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validator)
            ]));
  }

  @override
  bool get wantKeepAlive => false;
}
