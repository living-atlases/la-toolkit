import 'dart:collection';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/components/deploySubResultWidget.dart';
import 'package:la_toolkit/models/ansibleError.dart';
import 'package:la_toolkit/utils/resultTypes.dart';

import 'cmdHistoryEntry.dart';

part 'cmdHistoryDetails.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class CmdHistoryDetails {
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
      _resultsTotals = {};
      for (var type in ResultTypes.list) {
        _resultsTotals![type] = 0;
      }
      for (var result in results) {
        for (var key in result['stats'].keys) {
          for (var type in ResultTypes.list) {
            _resultsTotals![type] =
                _resultsTotals![type]! + result['stats'][key][type];
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
      _details = [];
      for (var result in results) {
        Map<String, List<AnsibleError>> errors = {};
        HashSet<String> plays = HashSet<String>();
        result['plays'].forEach((play) {
          String playName = play['play']['name'];
          plays.add(playName);
          play['tasks'].forEach((task) {
            task['hosts'].keys.forEach((host) {
              if (errors[host] == null) errors[host] = [];
              if ((task['hosts'][host]['failed'] != null &&
                      task['hosts'][host]['failed'] == true) ||
                  (task['hosts'][host]['unreachable'] != null &&
                      task['hosts'][host]['unreachable'] == true)) {
                String taskName =
                    task['task'] != null ? task['task']['name'] : '';
                String msg = task['hosts'][host] != null
                    ? task['hosts'][host]['msg']
                    : '';
                if (task['hosts'][host]['results'] != null) {
                  task['hosts'][host]['results'].forEach((r) {
                    if (r['stderr'] != null) msg += "\n${r['stderr']}";
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
        result['stats'].keys.forEach((host) {
          DeploySubResultWidget subResult = DeploySubResultWidget(
              host: host,
              title: plays.join(', '),
              results: result['stats'][host],
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
    num? fails = resultsTotals[ResultType.failures.toS()];
    num? unReach = resultsTotals[ResultType.unreachable.toS()];
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

  factory CmdHistoryDetails.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CmdHistoryDetailsToJson(this);
}
