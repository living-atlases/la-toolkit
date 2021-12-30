import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/brandingDeployCmd.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/pipelinesCmd.dart';
import 'package:la_toolkit/models/postDeployCmd.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:objectid/objectid.dart';

import 'cmd.dart';
import 'isJsonSerializable.dart';

part 'cmdHistoryEntry.g.dart';

enum CmdResult { unknown, aborted, success, failed }

extension CmdResultToString on CmdResult {
  String toS() {
    return toString().split('.').last;
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

extension CmdResultToServiceStatus on CmdResult {
  String toServiceForHumans() {
    switch (this) {
      case CmdResult.unknown:
        return "checking";
      case CmdResult.aborted:
        return "aborted";
      case CmdResult.success:
        return "No issues detected";
      case CmdResult.failed:
        return "Some check failed";
    }
  }
}

@JsonSerializable(explicitToJson: true)
@CopyWith()
class CmdHistoryEntry implements IsJsonSerializable {
  String id;
  String? desc;
  String logsPrefix;
  String logsSuffix;
  String rawCmd;
  String invDir;
  String? cwd;
  Cmd cmd;
  @JsonKey(ignore: true)
  DateTime date;
  CmdResult result;
  int createdAt;
  @JsonKey(ignore: true)
  DeployCmd? parsedDeployCmd;
  @JsonKey(ignore: true)
  BrandingDeployCmd? parsedBrandingDeployCmd;
  @JsonKey(ignore: true)
  PipelinesCmd? pipelinesCmd;
  double? duration;

  CmdHistoryEntry(
      {String? id,
      required this.logsPrefix,
      required this.logsSuffix,
      required this.desc,
      String? invDir,
      String? cwd,
      required this.rawCmd,
      required this.cmd,
      int? createdAt,
      this.duration,
      this.result = CmdResult.unknown})
      : id = id ?? ObjectId().toString(),
        invDir = invDir ?? "",
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        date = createdAt != null
            ? DateTime.fromMillisecondsSinceEpoch(createdAt)
            : DateTime.now() {
    if (isAnsibleDeploy()) {
      if (cmd.type == CmdType.preDeploy) {
        parsedDeployCmd = PreDeployCmd.fromJson(cmd.properties);
      } else if (cmd.type == CmdType.postDeploy) {
        parsedDeployCmd = PostDeployCmd.fromJson(cmd.properties);
      } else {
        /* if (cmd.type == CmdType.deploy) { */
        parsedDeployCmd = DeployCmd.fromJson(cmd.properties);
      }
    } else if (cmd.type == CmdType.brandingDeploy) {
      parsedBrandingDeployCmd = BrandingDeployCmd.fromJson(cmd.properties);
    } else if (cmd.type == CmdType.laPipelines) {
      pipelinesCmd = PipelinesCmd.fromJson(cmd.properties);
    }
  }

  bool isAnsibleDeploy() {
    return cmd.type.isAnsibleDeploy;
  }

  factory CmdHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryEntryFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CmdHistoryEntryToJson(this);

  DeployCmd? get deployCmd {
    return parsedDeployCmd;
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
          cmd == other.cmd &&
          cwd == other.cwd &&
          date == other.date &&
          invDir == other.invDir &&
          desc == other.desc &&
          duration == other.duration &&
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
      cmd.hashCode ^
      cwd.hashCode ^
      duration.hashCode ^
      result.hashCode;

  @override
  fromJson(Map<String, dynamic> json) {
    return CmdHistoryEntry.fromJson(json);
  }

  String getTitle() {
    return isAnsibleDeploy()
        ? deployCmd!.getTitle()
        : cmd.type == CmdType.brandingDeploy
            ? parsedBrandingDeployCmd!.getTitle()
            : cmd.type == CmdType.laPipelines
                ? pipelinesCmd!.getTitle()
                : "TODO FIXME";
  }

  String getDesc() {
    return isAnsibleDeploy()
        ? deployCmd!.desc
        : cmd.type == CmdType.brandingDeploy
            ? parsedBrandingDeployCmd!.desc
            : cmd.type == CmdType.laPipelines
                ? pipelinesCmd!.desc
                : "TODO FIXME";
  }
}
