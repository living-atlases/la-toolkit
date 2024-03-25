import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LAColorTheme {
  static MaterialColor laPalette =
      MaterialColor(_primaryValue.value, const <int, Color>{
    50: Color(0xFFEFF6EF),
    100: Color(0xFFD7E9D7),
    200: Color(0xFFBCDABC),
    300: Color(0xFFA1CBA1),
    400: Color(0xFF8CC08C),
    500: _primaryValue,
    600: Color(0xFF70AE70),
    700: Color(0xFF65A565),
    800: Color(0xFF5B9D5B),
    900: Color(0xFF488D48),
  });
  static const Color _primaryValue = Color(0xFF78B578);

  static MaterialColor laPaletteAccent =
      MaterialColor(_laPaletteAccentValue.value, const <int, Color>{
    100: Color(0xFFE9FFE9),
    200: _laPaletteAccentValue,
    400: Color(0xFF83FF83),
    700: Color(0xFF69FF69),
  });
  static const Color _laPaletteAccentValue = Color(0xFFB6FFB6);

  static const MaterialColor inactive = Colors.blueGrey;
  static final Color link = Colors.blueAccent.shade100;
  static final Color unDeployedColor = LAColorTheme.laPalette.shade800;
  static const MaterialAccentColor deployedColor = Colors.blueAccent;
  static final Color up = Colors.green.shade400;
  static final Color down = Colors.red.shade300;
  static final TextStyle unDeployedTextStyle =
      TextStyle(color: unDeployedColor);
  static const TextStyle deployedTextStyle = TextStyle(color: deployedColor);
  static final TextStyle fixedUnDeployedTextStyle = GoogleFonts.ibmPlexMono(
    textStyle: TextStyle(color: unDeployedColor),
  );
  static final TextStyle fixedDeployedTextStyle = GoogleFonts.ibmPlexMono(
    textStyle: const TextStyle(color: deployedColor),
  );
}
