import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LAColorTheme {
  static const MaterialColor laPalette = MaterialColor(primary, <int, Color>{
    50: Color(0xFFEFF6EF),
    100: Color(0xFFD7E9D7),
    200: Color(0xFFBCDABC),
    300: Color(0xFFA1CBA1),
    400: Color(0xFF8CC08C),
    500: Color(primary),
    600: Color(0xFF70AE70),
    700: Color(0xFF65A565),
    800: Color(0xFF5B9D5B),
    900: Color(0xFF488D48),
  });

  static const int primary = 0xFF78B578;

  static const MaterialColor laPaletteAccent =
      MaterialColor(_laPaletteAccentValue, <int, Color>{
    100: Color(0xFFE9FFE9),
    200: Color(_laPaletteAccentValue),
    400: Color(0xFF83FF83),
    700: Color(0xFF69FF69),
  });
  static const int _laPaletteAccentValue = 0xFFB6FFB6;

  static ThemeData laThemeData = ThemeData(
      primarySwatch: LAColorTheme.laPalette, // Color(0xFF78B578),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        // splashColor: Colors.white.withOpacity(0.25),
      ),
      buttonTheme: const ButtonThemeData(
        // buttonColor: Colors.deepPurple, //  <-- dark color
        textTheme:
            ButtonTextTheme.primary, //  <-- this auto selects the right color
      ));

  static const inactive = Colors.blueGrey;
  static final Color link = Colors.blueAccent.shade100;
  static final unDeployedColor = LAColorTheme.laPalette.shade800;
  static final deployedColor = Colors.blueAccent;
  static final up = Colors.green.shade400;
  static final down = Colors.red.shade300;
  static final unDeployedTextStyle = TextStyle(color: unDeployedColor);
  static final deployedTextStyle = TextStyle(color: deployedColor);
  static final fixedUnDeployedTextStyle = GoogleFonts.ibmPlexMono(
    textStyle: TextStyle(color: unDeployedColor),
  );
  static final fixedDeployedTextStyle = GoogleFonts.ibmPlexMono(
    textStyle: TextStyle(color: deployedColor),
  );
}
