import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:uuid/uuid.dart';

part 'cmdHistoryEntry.g.dart';

enum CmdResult { unknown, aborted, success, failed }

extension CmdResultToString on CmdResult {
  String toS() {
    return this.toString().split('.').last;
  }
}

extension CmdResultToIconData on CmdResult {
  Color get iconColor {
    switch (this) {
      case CmdResult.unknown:
        return Colors.grey;
      case CmdResult.aborted:
        return Colors.black12;
      case CmdResult.success:
        return ResultType.ok.color;
      case CmdResult.failed:
        return ResultType.failures.color;
    }
  }
}

@JsonSerializable(explicitToJson: true)
@CopyWith()
class CmdHistoryEntry {
  String uuid;
  String logsPrefix;
  String logsSuffix;
  String cmd;
  String invDir;
  DeployCmd deployCmd;
  DeployCmd preDeployCmd;
  DeployCmd postDeployCmd;
  DateTime date;
  CmdResult result;

  CmdHistoryEntry(
      {String? uuid,
      required this.logsPrefix,
      required this.logsSuffix,
      String? invDir,
      required this.cmd,
      required this.deployCmd,
      DateTime? date,
      this.result: CmdResult.unknown})
      : uuid = uuid ?? Uuid().v4(),
        invDir = invDir ?? "",
        this.date = date ?? DateTime.now();

  factory CmdHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$CmdHistoryEntryToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CmdHistoryEntry &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid &&
          logsPrefix == other.logsPrefix &&
          logsSuffix == other.logsSuffix &&
          cmd == other.cmd &&
          deployCmd == other.deployCmd &&
          date == other.date &&
          invDir == other.invDir &&
          result == other.result;

  @override
  int get hashCode =>
      uuid.hashCode ^
      invDir.hashCode ^
      logsPrefix.hashCode ^
      logsSuffix.hashCode ^
      cmd.hashCode ^
      deployCmd.hashCode ^
      date.hashCode ^
      result.hashCode;
}
