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
  bool fstRetrieved;

  CmdHistoryDetails(
      {required this.code,
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
          results == other.results &&
          logs == other.logs &&
          fstRetrieved == other.fstRetrieved &&
          logsColorized == other.logsColorized;

  @override
  String toString() {
    return 'CmdHistoryDetails{code: $code, results: $results, logs: $logs, logsColorized: $logsColorized, fstRetrieved: $fstRetrieved}';
  }

  @override
  int get hashCode =>
      code.hashCode ^
      results.hashCode ^
      logs.hashCode ^
      logsColorized.hashCode ^
      fstRetrieved.hashCode;

  factory CmdHistoryDetails.fromJson(Map<String, dynamic> json) =>
      _$CmdHistoryDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$CmdHistoryDetailsToJson(this);
}
