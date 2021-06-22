import 'package:flutter/material.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';

import 'ShadowIcon.dart';

class StatusIcon extends StatelessWidget {
  final CmdResult type;
  final double size;
  const StatusIcon(this.type, {Key? key, this.size = 12}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShadowIcon(icon: Icons.circle, size: size, color: type.iconColor);
  }
}
