import 'package:flutter/material.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';

class StatusIcon extends StatelessWidget {
  final CmdResult type;
  final double size;
  const StatusIcon(this.type, {this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size),
        ),
        child: SizedBox(
            width: size,
            height: size,
            child: Icon(Icons.circle, size: size, color: type.iconColor)));
  }
}
