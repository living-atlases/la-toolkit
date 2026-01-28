import 'package:flutter/material.dart';

class CardConstants {
  static EdgeInsets defaultSeparation = const EdgeInsets.fromLTRB(0, 0, 0, 30);
  static const double defaultElevation = 2;
  static RoundedRectangleBorder defaultShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(3),
  );
  static RoundedRectangleBorder defaultClusterShape = RoundedRectangleBorder(
    side: BorderSide(color: Colors.blue[100]!, width: 3.0),
    borderRadius: BorderRadius.circular(4),
  );

  static RoundedRectangleBorder deprecatedClusterShape = RoundedRectangleBorder(
    side: BorderSide(color: Colors.orange[300]!, width: 3.0),
    borderRadius: BorderRadius.circular(4),
  );
}
