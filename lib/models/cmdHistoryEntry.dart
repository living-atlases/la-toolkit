import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/postDeployCmd.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:objectid/objectid.dart';

import 'cmd.dart';

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
  String id;
  String? desc;
  String logsPrefix;
  String logsSuffix;
  String rawCmd;
  String invDir;
  Cmd cmd;
  @JsonKey(ignore: true)
  DateTime date;
  CmdResult result;
  int createdAt;

  CmdHistoryEntry(
      {String? id,
      required this.logsPrefix,
      required this.logsSuffix,
      String? desc,
      String? invDir,
      required this.rawCmd,
      required this.cmd,
      int? createdAt,
      this.result: CmdResult.unknown})
      : id = id ?? new ObjectId().toString(),
        invDir = invDir ?? "",
        createdAt = createdAt ?? DateTime.now().millisecond,
        this.date = createdAt != null
            ? DateTime.fromMillisecondsSinceEpoch(createdAt)
            : DateTime.now();

  factory CmdHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$CmdHistoryEntryToJson(this);

  DeployCmd get deployCmd {
    DeployCmd parsedCmd;
    if (cmd.type == CmdType.preDeploy) {
      parsedCmd = PreDeployCmd.fromJson(cmd.properties);
    } else if (cmd.type == CmdType.preDeploy) {
      parsedCmd = PostDeployCmd.fromJson(cmd.properties);
    } else /* if (cmd.type == CmdType.deploy) { */
      parsedCmd = DeployCmd.fromJson(cmd.properties);
    /* } */
    return parsedCmd;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CmdHistoryEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          logsPrefix == other.logsPrefix &&
          logsSuffix == other.logsSuffix &&
          rawCmd == other.rawCmd &&
          date == other.date &&
          invDir == other.invDir &&
          desc == other.desc &&
          result == other.result;

  @override
  int get hashCode =>
      id.hashCode ^
      invDir.hashCode ^
      logsPrefix.hashCode ^
      logsSuffix.hashCode ^
      desc.hashCode ^
      rawCmd.hashCode ^
      date.hashCode ^
      result.hashCode;
}
