class FieldValidators {
  // https://www.regular-expressions.info/unicode.html
  static final projectNameRegexp = RegExp(r'^[\p{L}\p{N} .]+$', unicode: true);
  static final domainRegexp = RegExp(
      r'^(?!(https:\/\/|http:\/\/|www\.|mailto:|smtp:|ftp:\/\/|ftps:\/\/))(((([a-zA-Z0-9])|([a-zA-Z0-9][a-zA-Z0-9\-]{0,86}[a-zA-Z0-9]))\.(([a-zA-Z0-9])|([a-zA-Z0-9][a-zA-Z0-9\-]{0,73}[a-zA-Z0-9]))\.(([a-zA-Z0-9]{2,12}\.[a-zA-Z0-9]{2,12})|([a-zA-Z0-9]{2,25})))|((([a-zA-Z0-9])|([a-zA-Z0-9][a-zA-Z0-9\-]{0,162}[a-zA-Z0-9]))\.(([a-zA-Z0-9]{2,12}\.[a-zA-Z0-9]{2,12})|([a-zA-Z0-9]{2,25}))))$');
  static final hostnameRegexp = RegExp(r'^[._\-a-z0-9A-Z]+$');
  static final shortNameRegexp =
      projectNameRegexp; //  RegExp(r'\p{L}/u', unicode: true);
  static final aliasesRegexp = RegExp(r'^[._\-a-z0-9A-Z ]*$');
  static final ipv4 = RegExp(
      r'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$');
}
