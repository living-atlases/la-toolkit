import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

import '../utils/result_types.dart';
import './branding_deploy_cmd.dart';
import './deploy_cmd.dart';
import './is_json_serializable.dart';
import './pipelines_cmd.dart';
import './post_deploy_cmd.dart';
import './pre_deploy_cmd.dart';
import 'cmd.dart';

part 'cmd_history_entry.g.dart';

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
        return 'checking';
      case CmdResult.aborted:
        return 'aborted';
      case CmdResult.success:
        return 'No issues detected';
      case CmdResult.failed:
        return 'Some check failed';
    }
  }
}

@JsonSerializable(explicitToJson: true)
@CopyWith()
class CmdHistoryEntry implements IsJsonSerializable<CmdHistoryEntry> {
  CmdHistoryEntry({
    String? id,
    required this.logsPrefix,
    required this.logsSuffix,
    required this.desc,
    String? invDir,
    String? cwd,
    required this.rawCmd,
    required this.cmd,
    int? createdAt,
    this.duration,
    this.result = CmdResult.unknown,
  }) : id = id ?? ObjectId().toString(),
       invDir = invDir ?? '',
       cwd = cwd ?? '',
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

  factory CmdHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryEntryFromJson(json);
  String id;
  String? desc;
  String logsPrefix;
  String logsSuffix;
  String rawCmd;
  String invDir;
  String? cwd;
  Cmd cmd;
  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime date;
  CmdResult result;
  int createdAt;
  @JsonKey(includeToJson: false, includeFromJson: false)
  DeployCmd? parsedDeployCmd;
  @JsonKey(includeToJson: false, includeFromJson: false)
  BrandingDeployCmd? parsedBrandingDeployCmd;
  @JsonKey(includeToJson: false, includeFromJson: false)
  PipelinesCmd? pipelinesCmd;
  double? duration;

  bool isAnsibleDeploy() {
    return cmd.type.isAnsibleDeploy;
  }

  @override
  Map<String, dynamic> toJson() => _$CmdHistoryEntryToJson(this);

  DeployCmd? get deployCmd {
    return parsedDeployCmd;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
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
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
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
  CmdHistoryEntry fromJson(Map<String, dynamic> json) {
    return CmdHistoryEntry.fromJson(json);
  }

  String getTitle() {
    return isAnsibleDeploy()
        ? deployCmd!.getTitle()
        : cmd.type == CmdType.brandingDeploy
        ? parsedBrandingDeployCmd!.getTitle()
        : cmd.type == CmdType.laPipelines
        ? pipelinesCmd!.getTitle()
        : 'TODO FIXME';
  }

  String getDesc() {
    return isAnsibleDeploy()
        ? deployCmd!.desc
        : cmd.type == CmdType.brandingDeploy
        ? parsedBrandingDeployCmd!.desc
        : cmd.type == CmdType.laPipelines
        ? pipelinesCmd!.desc
        : 'TODO FIXME';
  }
}
