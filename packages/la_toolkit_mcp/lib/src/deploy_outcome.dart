import 'dart:convert';

import 'projects.dart';

/// Mirrors `unknownExitCode` in the backend's `api/libs/deploy-outcome.js`:
/// "nobody ever found out", not a failure.
const int unknownExitCode = 100;

/// What `deploy-cancel` records for a run it killed.
const int cancelledExitCode = 143;

/// The ansible JSON callback's per-host recap, summed over plays.
Map<String, Map<String, int>> recap(List<dynamic> results) {
  final Map<String, Map<String, int>> out = <String, Map<String, int>>{};
  for (final dynamic play in results) {
    final Map<String, dynamic> stats =
        (play as Json)['stats'] as Map<String, dynamic>? ?? <String, dynamic>{};
    stats.forEach((String host, dynamic s) {
      final Map<String, int> acc = out.putIfAbsent(host, () => <String, int>{});
      (s as Json).forEach((String k, dynamic v) {
        if (v is int) acc[k] = (acc[k] ?? 0) + v;
      });
    });
  }
  return out;
}

int _failures(Map<String, Map<String, int>> r) => r.values.fold(
  0,
  (int acc, Map<String, int> s) =>
      acc + (s['failures'] ?? 0) + (s['unreachable'] ?? 0),
);

/// Same verdict as `cmdResultFor` in the backend, so the agent and the UI's
/// history badge cannot disagree about a run, plus the two states the badge
/// has no word for: still running, and cancelled.
String verdict({
  required int code,
  required bool running,
  required int failures,
}) {
  if (running) return 'running';
  if (code == cancelledExitCode) return 'cancelled';
  if (code == 0 && failures == 0) return 'success';
  if (code == unknownExitCode) return 'aborted';
  return failures > 0 ? 'failed' : 'unknown';
}

String decodeLog(Object? b64) {
  if (b64 is! String || b64.isEmpty) return '';
  return utf8.decode(base64.decode(b64), allowMalformed: true);
}

/// Colour codes survive in the "plain" log: echo-bash's sed only strips
/// `ESC[<n>m`, not `ESC[<n>;<m>m`, and the ESC itself is sometimes gone.
final RegExp _ansi = RegExp(r'\x1b?\[[0-9;]*m');

String stripAnsi(String s) => s.replaceAll(_ansi, '');

/// Compact status for a run: no log, just what an agent needs to decide
/// whether to wait, celebrate or dig in.
Json summarizeRun(Json entry, Json cmdResults) {
  final Map<String, Map<String, int>> r = recap(
    cmdResults['results'] as List<dynamic>? ?? const <dynamic>[],
  );
  final int code = (cmdResults['code'] as num?)?.toInt() ?? unknownExitCode;
  final bool running = cmdResults['running'] == true;
  final String log = stripAnsi(decodeLog(cmdResults['logs']));
  return <String, dynamic>{
    'runId': entry['id'],
    'desc': entry['desc'],
    'started': entry['logsSuffix'],
    'verdict': verdict(code: code, running: running, failures: _failures(r)),
    if (!running) 'exitCode': code,
    if (cmdResults['duration'] is num)
      'durationMin': ((cmdResults['duration'] as num) / 60000).round(),
    if (r.isNotEmpty) 'recap': r,
    if (running) 'currentTask': lastTask(log),
    if (!running && log.trim().isEmpty) 'hint': noOutputHint(code),
    'command': entry['rawCmd'],
  };
}

/// Why a finished run can have printed nothing at all.
String noOutputHint(int code) => code == 127
    ? 'Exit 127 with no output: the command was not found, usually because '
          'the inventories (and their ansiblew) were never generated. Run again '
          'with prepare: true (it checks out this project\'s pinned releases in '
          'the toolkit, shared by every project: ask the user first).'
    : 'The run printed nothing; it never got to start ansible.';

final RegExp _taskHeader = RegExp(r'^(TASK|RUNNING HANDLER) \[(.+?)\]');

String? lastTask(String log) {
  final List<String> lines = log.split('\n');
  for (int i = lines.length - 1; i >= 0; i--) {
    final RegExpMatch? m = _taskHeader.firstMatch(lines[i]);
    if (m != null) return m.group(2);
  }
  return null;
}

String _clip(String s, int max) => s.length <= max
    ? s
    : '${s.substring(0, max)}… [${s.length - max} more chars]';

/// Failed tasks of a run, most recent last, capped so they fit in a context
/// window whatever the size of the log.
///
/// Prefers the ansible JSON callback (structured, but only written at the play
/// recap) and falls back to scanning the log for `fatal:` / `failed:` lines,
/// which also covers runs that are still going or died before the recap.
/// Failures ansible reported as `...ignoring` are dropped in both paths.
List<Json> failedTasks(Json cmdResults, {int max = 8, int maxChars = 1500}) {
  final String log = stripAnsi(decodeLog(cmdResults['logs']));
  final Set<String> ignored = ignoredFailures(log);
  final List<Json> fromJson = <Json>[];
  for (final dynamic play
      in cmdResults['results'] as List<dynamic>? ?? const <dynamic>[]) {
    for (final dynamic p
        in (play as Json)['plays'] as List<dynamic>? ?? const <dynamic>[]) {
      for (final dynamic t
          in (p as Json)['tasks'] as List<dynamic>? ?? const <dynamic>[]) {
        final Json task = t as Json;
        final String? name = (task['task'] as Json?)?['name'] as String?;
        final Json hosts = task['hosts'] as Json? ?? <String, dynamic>{};
        hosts.forEach((String host, dynamic res) {
          final Json r = res as Json;
          if (r['failed'] != true && r['unreachable'] != true) return;
          if (ignored.contains('$name|$host')) return;
          fromJson.add(<String, dynamic>{
            'task': name,
            'host': host,
            if (r['unreachable'] == true) 'unreachable': true,
            if (r['rc'] is int) 'rc': r['rc'],
            'detail': _clip(resultDetail(r), maxChars),
          });
        });
      }
    }
  }
  if (fromJson.isNotEmpty) return _last(fromJson, max);
  return _last(failedTasksFromLog(log, maxChars: maxChars), max);
}

/// The useful part of a failed result. For `command`/`shell` tasks ansible's
/// `msg` is just "non-zero return code" and the story is in stderr, or in
/// stdout for scripts that report there; keep the end, where errors land.
String resultDetail(Json r) {
  String tail(Object? o) {
    if (o is! String || o.trim().isEmpty) return '';
    final List<String> l = o.trimRight().split('\n');
    return l.sublist(l.length > 15 ? l.length - 15 : 0).join('\n');
  }

  final String err = tail(r['stderr']);
  return <String>[
    if (r['msg'] is String) r['msg'] as String,
    if (err.isNotEmpty) err else tail(r['stdout']),
  ].where((String s) => s.isNotEmpty).join('\n');
}

/// `task|host` pairs whose failure ansible printed as `...ignoring`: the JSON
/// callback marks them failed like any other, only the log tells them apart.
Set<String> ignoredFailures(String log) {
  final Set<String> out = <String>{};
  final List<String> lines = log.split('\n');
  String? task;
  for (int i = 0; i + 1 < lines.length; i++) {
    final RegExpMatch? h = _taskHeader.firstMatch(lines[i]);
    if (h != null) {
      task = h.group(2);
      continue;
    }
    final RegExpMatch? f = _fatal.firstMatch(lines[i].trimLeft());
    if (f != null && lines[i + 1].trim() == '...ignoring')
      out.add('$task|${f.group(2)}');
  }
  return out;
}

List<Json> _last(List<Json> l, int max) =>
    l.length <= max ? l : l.sublist(l.length - max);

final RegExp _fatal = RegExp(r'^(fatal|failed): \[([^\]]+)\](?:[^=]*)=> (.*)$');

List<Json> failedTasksFromLog(String log, {int maxChars = 1500}) {
  final List<String> lines = log.split('\n');
  final List<Json> out = <Json>[];
  final Set<String> seen = <String>{};
  String? task;
  for (int i = 0; i < lines.length; i++) {
    final String line = lines[i];
    final RegExpMatch? h = _taskHeader.firstMatch(line);
    if (h != null) {
      task = h.group(2);
      continue;
    }
    final RegExpMatch? f = _fatal.firstMatch(line.trimLeft());
    if (f == null) continue;
    // Ansible prints the result, then "...ignoring" on the next line.
    if (i + 1 < lines.length && lines[i + 1].trim() == '...ignoring') continue;
    final String host = f.group(2)!;
    String detail = f.group(3)!;
    try {
      final Object? parsed = json.decode(detail);
      if (parsed is Json) detail = resultDetail(parsed);
    } on FormatException {
      // Multi-line or truncated result; keep the raw text.
    }
    // The toolkit's log file can hold the same run twice (ansible's own log
    // and the echo-bash tee point at one path).
    if (!seen.add('$task|$host|$detail')) continue;
    out.add(<String, dynamic>{
      'task': task,
      'host': host,
      'detail': _clip(detail, maxChars),
    });
  }
  return out;
}

/// The last [lines] lines of the log, for when a run failed without any
/// failed task (a syntax error, a missing inventory, a killed process).
String logTail(Json cmdResults, {int lines = 40}) {
  final List<String> all = stripAnsi(
    decodeLog(cmdResults['logs']),
  ).trimRight().split('\n');
  return all.sublist(all.length > lines ? all.length - lines : 0).join('\n');
}
