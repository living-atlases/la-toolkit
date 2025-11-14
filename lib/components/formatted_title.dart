import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../la_theme.dart';
import '../utils/string_utils.dart';

class FormattedTitle extends StatelessWidget {
  const FormattedTitle({super.key, required this.title, this.fontSize, this.color, this.subtitle});
  final String title;
  final Widget? subtitle;
  final double? fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(StringUtils.capitalize(title),
            style: GoogleFonts.signika(
                textStyle: TextStyle(
                    color: color ?? LAColorTheme.laPalette.shade500,
                    fontSize: fontSize ?? 18,
                    fontWeight: FontWeight.w400))),
        subtitle: subtitle);
  }
}
