import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'laIcon.dart';

class LAAppBar extends AppBar {
  LAAppBar({String title, bool showLaIcon: false})
      : super(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            showLaIcon ? Icon(LAIcon.la, size: 32, color: Colors.white) : null,
            Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(title,
                    style: GoogleFonts.signika(
                        textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w400))))
          ],
        ));
}
