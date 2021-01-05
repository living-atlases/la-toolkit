import 'package:flutter/widgets.dart';

bool notNull(Object o) => o != null;

// What is the best way to optionally include a widget in a list of children
// https://github.com/flutter/flutter/issues/3783

List<Widget> listWithoutNulls(List<Widget> children) =>
    children.where(notNull).toList();
