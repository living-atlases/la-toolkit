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

/// What one host did in one ansible run: its recap counters (`ok`,
/// `changed`, `failures`...) and the tasks that failed on it.
class HostDeployResult {
  HostDeployResult({
    required this.host,
    required this.title,
    required this.results,
    required this.errors,
  });

  final String host;

  /// The plays of the run, joined.
  final String title;
  final Map<String, dynamic> results;
  final List<AnsibleError> errors;
}
