class AnsibleError {
  AnsibleError({
    required this.host,
    required this.playName,
    required this.taskName,
    required this.msg,
  });
  final String host;
  final String playName;
  final String taskName;
  final String msg;
}
