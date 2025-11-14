import 'package:flutter/material.dart';

import '../models/cmdHistoryEntry.dart';

import 'shadow_icon.dart';

class StatusIcon extends StatelessWidget {
  const StatusIcon(this.type, {super.key, this.size = 12});
  final CmdResult type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShadowIcon(icon: Icons.circle, size: size, color: type.iconColor);
  }
}
