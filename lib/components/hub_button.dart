import 'package:flutter/material.dart';

import '../la_theme.dart';
import '../redux/actions.dart';

class HubButton extends StatelessWidget {
  const HubButton({
    super.key,
    required this.text,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.isActionBtn,
  });
  final String text;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActionBtn;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton.icon(
        label: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        icon: Icon(icon),
        style: TextButton.styleFrom(
          foregroundColor: isActionBtn ? Colors.white : LAColorTheme.laPalette,
          backgroundColor: isActionBtn
              ? LAColorTheme.laPalette
              : Colors.grey[200]!,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: LAColorTheme.laPalette,
              width: isActionBtn ? 0 : 1,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: () => onPressed(),
      ),
    );
  }
}
