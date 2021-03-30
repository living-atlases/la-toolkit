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
  @JsonKey(ignore: true)
  CmdHistoryEntry? cmd;
  int code;
  List<dynamic> results;
  String logs;
  String logsColorized;
  bool fstRetrieved;
  @JsonKey(ignore: true)
  Map<String, num>? _resultsTotals;
  @JsonKey(ignore: true)
  List<Widget>? _details;

  CmdHistoryDetails(
      {this.cmd,
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
          results == other.results &&
          logs == other.logs &&
          fstRetrieved == other.fstRetrieved &&
          logsColorized == other.logsColorized;

  Map<String, num> get resultsTotals {
    if (_resultsTotals == null) {
      _resultsTotals = {};
      ResultTypes.list.forEach((type) => _resultsTotals![type] = 0);
      results.forEach((result) {
        result['stats'].keys.forEach((key) {
          ResultTypes.list.forEach((type) => _resultsTotals![type] =
              _resultsTotals![type]! + result['stats'][key][type]);
        });
      });
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
      results.forEach((result) {
        List<String> playNames = [];
        List<AnsibleError> errors = [];
        result['plays'].forEach((play) {
          String name = play['play']['name'];
          if (name != 'all') playNames.add(name);
          play['tasks'].forEach((task) {
            task['hosts'].keys.forEach((host) {
              if (task['hosts'][host]['failed'] != null &&
                  task['hosts'][host]['failed'] == true) {
                String taskName =
                    task['task'] != null ? task['task']['name'] : '';
                String msg = task['hosts'][host] != null
                    ? task['hosts'][host]['msg']
                    : '';
                errors.add(AnsibleError(
                    host: host, playName: name, taskName: taskName, msg: msg));
              }
            });
          });
        });

        /* "tasks": [ { "hosts": {
-                        "ala-install-test-2": {
-                            "_ansible_no_log": false,
-                            "action": "postgresql_db",
-                            "changed": false,
-                            "failed": true,
-                            },
-                            "msg" : "Error" */

        result['stats'].keys.forEach((key) {
          DeploySubResultWidget subResult = DeploySubResultWidget(
              title: playNames.join(', '),
              name: key,
              results: result['stats'][key],
              errors: errors);
          _details!.add(subResult);
        });
      });
    }
    return _details!;
  }

  bool get failed {
    return !(code == 0 && numFailures() == 0);
  }

  num? numFailures() {
    num? fails = resultsTotals[ResultType.failures.toS()];
    num? unReach = resultsTotals[ResultType.unreachable.toS()];
    if (fails == null && unReach == null) return null;
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
      logsColorized.hashCode ^
      fstRetrieved.hashCode;

  factory CmdHistoryDetails.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$CmdHistoryDetailsToJson(this);
}
