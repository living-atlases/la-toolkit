import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cmdHistoryDetails.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class CmdHistoryDetails {
  int code;
  List<dynamic> results;
  String logs;
  String logsColorized;

  CmdHistoryDetails(
      {required this.code,
      required this.results,
      required this.logs,
      required this.logsColorized});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CmdHistoryDetails &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          results == other.results &&
          logs == other.logs &&
          logsColorized == other.logsColorized;

  @override
  int get hashCode =>
      code.hashCode ^ results.hashCode ^ logs.hashCode ^ logsColorized.hashCode;

  factory CmdHistoryDetails.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$CmdHistoryDetailsToJson(this);
}
