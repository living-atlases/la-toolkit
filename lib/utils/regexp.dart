class LARegExp {
  // https://www.regular-expressions.info/unicode.html
  static final projectNameRegexp = RegExp(r'^[\p{L}\p{N} -.]+$', unicode: true);
  static final domainRegexp = RegExp(
      r'^(?!(https:\/\/|http:\/\/|www\.|mailto:|smtp:|ftp:\/\/|ftps:\/\/))(((([a-zA-Z0-9])|([a-zA-Z0-9][a-zA-Z0-9\-]{0,86}[a-zA-Z0-9]))\.(([a-zA-Z0-9])|([a-zA-Z0-9][a-zA-Z0-9\-]{0,73}[a-zA-Z0-9]))\.(([a-zA-Z0-9]{2,12}\.[a-zA-Z0-9]{2,12})|([a-zA-Z0-9]{2,25})))|((([a-zA-Z0-9])|([a-zA-Z0-9][a-zA-Z0-9\-]{0,162}[a-zA-Z0-9]))\.(([a-zA-Z0-9]{2,12}\.[a-zA-Z0-9]{2,12})|([a-zA-Z0-9]{2,25}))))$');
  static final hostnameRegexp = RegExp(r'^[._\-a-z0-9A-Z]+$');
  static final multiHostnameRegexp = RegExp(r'^[._\-a-z0-9A-Z, ]+$');
  static final shortNameRegexp =
      projectNameRegexp; //  RegExp(r'\p{L}/u', unicode: true);
  static final aliasesRegexp = RegExp(r'^[._\-a-z0-9A-Z ]*$');
  static final ipv4 = RegExp(
      r'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$');
  static final ipv6 = RegExp(
      r'(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))');
  static final privateIp = RegExp(
      r'(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^::1$)|(^[fF][cCdD])');
  static final subdomain = RegExp(r'^[a-z0-9_.\-]+');
  // static final path = RegExp(r'^[a-z0-9_.\-]*');
  static final sshPubKey = RegExp(
      r'^(ssh-rsa AAAAB3NzaC1yc2|ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNT|ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzOD|ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1Mj|ssh-ed25519 AAAAC3NzaC1lZDI1NTE5|ssh-dss AAAAB3NzaC1kc3)[0-9A-Za-z+/]+[=]{0,3}( .*)?$');
  static final url = RegExp(
      r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})');
  static final email = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  // https://stackoverflow.com/questions/1221985/how-to-validate-a-user-name-with-regex
  static final username = RegExp(r'^[a-zA-Z0-9]+([_ -]?[a-zA-Z0-9])*$');
  static final int = RegExp(r'^[-+]?\d+$');
  static final double = RegExp(r'^[-+]?[0-9]*\.?[0-9]+$');
  static final ip = RegExp(
      r'((\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])))');
  static final portNumber = RegExp(
      r'^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$');
  static final anyThing = RegExp(r'.+');
}
