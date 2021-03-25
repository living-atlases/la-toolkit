class AnsibleError {
  final String host;
  final String playName;
  final String action;
  final String msg;

  AnsibleError(
      {required this.host,
      required this.playName,
      required this.action,
      required this.msg});
}
