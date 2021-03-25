import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/utils/constants.dart';

import 'cmdHistoryEntry.dart';

part 'cmdHistoryDetails.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class CmdHistoryDetails {
  int code;
  List<dynamic> results;
  String logs;
  String logsColorized;
  bool fstRetrieved;
  @JsonKey(ignore: true)
  Map<String, num>? _resultsTotals;

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

  Map<String, num> get resultsTotals {
    if (_resultsTotals == null) {
      _resultsTotals = {};
      Result.types.forEach((type) => _resultsTotals![type] = 0);
      results.forEach((result) {
        result['stats'].keys.forEach((key) {
          Result.types.forEach((type) => _resultsTotals![type] =
              _resultsTotals![type]! + result['stats'][key][type]);
        });
      });
    }
    return _resultsTotals!;
  }

  bool get failed {
    return !(code == 0 && resultsTotals['failures'] == 0);
  }

  CmdResult get result => !failed ? CmdResult.success : CmdResult.failed;

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
