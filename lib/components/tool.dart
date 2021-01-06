import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Tool {
  final Widget icon;
  final String title;
  final String tooltip;
  final bool enabled;
  final bool askConfirmation;
  final int grid;
  VoidCallback action;

  Tool(
      {this.icon,
      this.title,
      this.tooltip,
      this.action,
      this.enabled = false,
      this.askConfirmation = false,
      this.grid = 2});
}
