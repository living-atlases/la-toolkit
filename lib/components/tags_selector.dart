import 'package:flutter/material.dart';

import 'choices_selector.dart';

class TagsSelector extends StatelessWidget {

  const TagsSelector(
      {super.key,
      required this.selectorKey,
      required this.tags,
      required this.icon,
      required this.initialValue,
      required this.title,
      required this.placeHolder,
      required this.modalTitle,
      required this.onChange});
  final GlobalKey<FormFieldState<dynamic>> selectorKey;
  final List<String> tags;
  final IconData icon;
  final String title;
  final String placeHolder;
  final String modalTitle;
  final List<String> initialValue;
  final Function(List<String>) onChange;

  @override
  Widget build(BuildContext context) {
    return ChoicesSelector(
      selectorKey: selectorKey,
      choices: tags,
      icon: icon,
      initialValue: initialValue,
      title: title,
      placeHolder: placeHolder,
      modalTitle: modalTitle,
      onChange: onChange,
    );
  }
}
