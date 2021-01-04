class LaServiceDesc {
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

  LaServiceDesc(
      {this.name,
      this.nameInt,
      this.desc,
      this.optional,
      this.withoutUrl,
      this.forceSubdomain,
      this.sample,
      this.hint,
      this.recommended,
      this.path,
      this.depends});
}
