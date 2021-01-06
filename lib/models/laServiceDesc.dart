import 'package:flutter/foundation.dart';

class LAServiceDesc {
  String name;
  String nameInt;
  String desc;
  bool optional;
  bool withoutUrl;
  String depends;
  bool forceSubdomain;
  String sample;
  String hint;
  bool recommended;
  String path;
  bool initUse;

  LAServiceDesc(
      {@required this.name,
      @required this.nameInt,
      @required this.desc,
      @required this.optional,
      this.withoutUrl = false,
      this.forceSubdomain = false,
      // Optional Some backend services don't have sample urls
      this.sample,
      // Optional: Not all services has a hint to show in the textfield
      this.hint,
      this.recommended = false,
      @required this.path,
      this.depends,
      this.initUse});
}
