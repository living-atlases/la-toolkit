// ignore_for_file: avoid_dynamic_calls

import 'dart:collection';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../components/deploy_sub_result_widget.dart';
import '../utils/result_types.dart';
import 'ansibleError.dart';
import 'cmdHistoryEntry.dart';

part 'cmd_history_details.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class CmdHistoryDetails {
  CmdHistoryDetails(
      {this.cmd,
      this.port,
      this.pid,
      this.duration,
      required this.code,
      required this.results,
      required this.logs,
      required this.logsColorized,
      bool? fstRetrieved})
      : fstRetrieved = fstRetrieved ?? false;

  factory CmdHistoryDetails.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryDetailsFromJson(json);

  @JsonKey(includeToJson: false, includeFromJson: false)
  CmdHistoryEntry? cmd;
  int? port;
  int? pid;
  double? duration;
  int code;
  List<dynamic> results;
  String logs;
  String logsColorized;
  bool fstRetrieved;
  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, num>? _resultsTotals;
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Widget>? _details;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CmdHistoryDetails &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          cmd == other.cmd &&
          port == other.port &&
          pid == other.pid &&
          duration == other.duration &&
          results == other.results &&
          logs == other.logs &&
          fstRetrieved == other.fstRetrieved &&
          logsColorized == other.logsColorized;

  Map<String, num> get resultsTotals {
    if (_resultsTotals == null) {
      _resultsTotals = <String, num>{};
      for (final String type in ResultTypes.list) {
        _resultsTotals![type] = 0;
      }
      for (final dynamic result in results) {
        final Map<String, dynamic> rsStats =
            result['stats'] as Map<String, dynamic>;
        for (final String key in rsStats.keys) {
          for (final String type in ResultTypes.list) {
            _resultsTotals![type] =
                _resultsTotals![type]! + (rsStats[key][type] as num);
          }
        }
      }
    }
    return _resultsTotals!;
  }

  num get stepsExec =>
      (resultsTotals[ResultType.changed.toS()] ?? 0) +
      (resultsTotals[ResultType.failures.toS()] ?? 0) +
      (resultsTotals[ResultType.ok.toS()] ?? 0);

  /* +
      (resultsTotals[ResultType.unreachable.toS()] ?? 0 */

  bool get nothingDone => stepsExec == 0;

  List<Widget> get detailsWidgetList {
    if (_details == null) {
      _details = <Widget>[];
      for (final dynamic result in results) {
        final Map<String, List<AnsibleError>> errors =
            <String, List<AnsibleError>>{};
        final HashSet<String> plays = HashSet<String>();
        result['plays'].forEach((dynamic play) {
          final String playName =
              play['play'] != null && play['play']['name'] != null
                  ? play['play']['name'] as String
                  : '';
          plays.add(playName);
          play['tasks'].forEach((dynamic task) {
            task['hosts'].keys.forEach((String host) {
              if (errors[host] == null) {
                errors[host] = <AnsibleError>[];
              }
              if ((task['hosts'][host]['failed'] != null &&
                      task['hosts'][host]['failed'] == true) ||
                  (task['hosts'][host]['unreachable'] != null &&
                      task['hosts'][host]['unreachable'] == true)) {
                final String taskName =
                    task['task'] != null && task['task']['name'] != null
                        ? task['task']['name'] as String
                        : '';
                String msg = task['hosts'][host] != null &&
                        task['hosts'][host]['msg'] != null
                    ? task['hosts'][host]['msg'] as String
                    : '';
                if (task['hosts'][host]['results'] != null) {
                  task['hosts'][host]['results'].forEach((dynamic r) {
                    if (r['stderr'] != null) {
                      msg += "\n${r['stderr']}";
                    }
                  });
                }
                errors[host]!.add(AnsibleError(
                    host: host,
                    playName: playName,
                    taskName: taskName,
                    msg: msg));
              }
            });
          });
        });
        result['stats'].keys.forEach((String host) {
          final DeploySubResultWidget subResult = DeploySubResultWidget(
              host: host,
              title: plays.join(', '),
              results: result['stats'][host] as Map<String, dynamic>,
              errors: errors[host]!);
          _details!.add(subResult);
        });
        /* "tasks": [ { "hosts": {
-                        "ala-install-test-2": {
-                            "_ansible_no_log": false,
-                            "action": "postgresql_db",
-                            "changed": false,
-                            "failed": true,
-                            },
-                            "msg" : "Error"
(...)
               tasks": [
                {
                    "hosts": {
                        "ala-install-test-1": {
                            "action": "gather_facts",
                            "changed": false,
                            "msg": "Data could not be sent to remote host \"ala-install-test-1\". Make sure this host can be reached over ssh: kex_exchange_identification: Connection closed by remote host\r\n",
                            "unreachable": true
                        },

*/
      }
    }
    return _details!;
  }

  bool get failed {
    return !(code == 0 && numFailures() == 0);
  }

  num? numFailures() {
    final num? fails = resultsTotals[ResultType.failures.toS()];
    final num? unReach = resultsTotals[ResultType.unreachable.toS()];
    // It's this needed now with non ansible cmds with no ansible results?
    // if (fails == null && unReach == null) return null;
    return (fails ?? 0) + (unReach ?? 0);
  }

  CmdResult get result => !failed
      ? CmdResult.success
      : code == 100
          ? CmdResult.aborted
          : numFailures() != null && numFailures()! > 0
              ? CmdResult.failed
              : CmdResult.unknown;

  @override
  String toString() {
    return 'CmdHistoryDetails{code: $code, results: $results, logs: $logs, logsColorized: $logsColorized, fstRetrieved: $fstRetrieved}';
  }

  @override
  int get hashCode =>
      code.hashCode ^
      results.hashCode ^
      logs.hashCode ^
      cmd.hashCode ^
      port.hashCode ^
      pid.hashCode ^
      duration.hashCode ^
      logsColorized.hashCode ^
      fstRetrieved.hashCode;

  Map<String, dynamic> toJson() => _$CmdHistoryDetailsToJson(this);
}
