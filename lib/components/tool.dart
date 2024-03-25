import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Tool {

  Tool(
      {required this.icon,
      required this.title,
      this.tooltip,
      required this.action,
      this.enabled = false,
      this.askConfirmation = false,
      this.grid = 2});
  final Widget icon;
  final String title;
  final String? tooltip;
  final bool enabled;
  final bool askConfirmation;
  final int grid;
  VoidCallback action;
}
