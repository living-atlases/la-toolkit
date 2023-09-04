import 'package:flutter/material.dart';
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
  final bool enabled;
  final bool enabledBorder;
  final bool monoSpaceFont;
  final bool deployed;
  final bool obscureText;
  final bool selected;
  final EdgeInsets? contentPadding;

  const GenericTextFormField(
      {Key? key,
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
      this.enabled = true,
      this.selected = true,
      this.contentPadding})
      : super(key: key);

  @override
  State<GenericTextFormField> createState() => _GenericTextFormFieldState();
}

class _GenericTextFormFieldState extends State<GenericTextFormField>
    with AutomaticKeepAliveClientMixin {
  final debouncer = Debouncer(milliseconds: 1000);
  late GlobalKey<FormState> formKey;
  String? delayedValue;
  late bool obscureTextState;
  late TextEditingController _controller;

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    formKey = GlobalKey<FormState>();
    obscureTextState = widget.obscureText;
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
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
        labelStyle: widget.hintStyle,
        hintStyle: const TextStyle(
          height: 1.5, // sets the distance between label and input
        ),
        prefixText: widget.prefixText,
        contentPadding: widget.contentPadding,
        // ?? EdgeInsets.only(top: 2),
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
                padding:
                    const EdgeInsets.only(top: 5), // add padding to adjust icon
                child: HelpIcon(wikipage: widget.wikipage!)),
        enabledBorder: widget.enabledBorder
            ? OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[500]!))
            : null // , width: 1.0),
        );

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
                  enabled: widget.enabled,
                  controller: _controller,
                  onTap: () => widget.selected
                      ? _controller.selection = TextSelection(
                          baseOffset: 0, extentOffset: _controller.text.length)
                      : null,
                  onChanged: (String value) => onChange(value),
                  style: style,
                  focusNode: widget.focusNode,
                  obscureText: obscureTextState,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
                  // Now moved to controller initialization
                  // initialValue: widget.initialValue,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (_) => validator())
            ]));
  }

  onChange(String value) {
    debouncer.run(() {
      setState(() {
        delayedValue = value;
        if (formKey.currentState != null && formKey.currentState!.validate()) {
          widget.onChanged(value);
        }
      });
    });
  }

  String? validator() {
    return widget.regexp != null &&
            delayedValue != null &&
            !widget.regexp!.hasMatch(delayedValue!) &&
            !(widget.allowEmpty && delayedValue!.isEmpty)
        ? widget.error
        : null;
  }

  @override
  bool get wantKeepAlive => false;
}
