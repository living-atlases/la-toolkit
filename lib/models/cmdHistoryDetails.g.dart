// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmdHistoryDetails.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension CmdHistoryDetailsCopyWith on CmdHistoryDetails {
  CmdHistoryDetails copyWith({
    int? code,
    String? logs,
    String? logsColorized,
    List<dynamic>? results,
  }) {
    return CmdHistoryDetails(
      code: code ?? this.code,
      logs: logs ?? this.logs,
      logsColorized: logsColorized ?? this.logsColorized,
      results: results ?? this.results,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CmdHistoryDetails _$CmdHistoryDetailsFromJson(Map<String, dynamic> json) {
  return CmdHistoryDetails(
    code: json['code'] as int,
    results: json['results'] as List<dynamic>,
    logs: json['logs'] as String,
    logsColorized: json['logsColorized'] as String,
  );
}

Map<String, dynamic> _$CmdHistoryDetailsToJson(CmdHistoryDetails instance) =>
    <String, dynamic>{
      'code': instance.code,
      'results': instance.results,
      'logs': instance.logs,
      'logsColorized': instance.logsColorized,
    };
