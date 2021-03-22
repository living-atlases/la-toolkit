import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/utils/constants.dart';
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
        return ResultsColors.ok;
      case CmdResult.failed:
        return ResultsColors.failure;
    }
  }
}

@JsonSerializable(explicitToJson: true)
@CopyWith()
class CmdHistoryEntry {
  String uuid;
  String title;
  String logsPrefix;
  String logsSuffix;
  String cmd;
  DateTime date;
  CmdResult result;

  CmdHistoryEntry(
      {String? uuid,
      required this.title,
      required this.logsPrefix,
      required this.logsSuffix,
      required this.cmd,
      DateTime? date,
      this.result: CmdResult.unknown})
      : uuid = uuid ?? Uuid().v4(),
        this.date = date ?? DateTime.now();

  factory CmdHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$CmdHistoryEntryToJson(this);
}
