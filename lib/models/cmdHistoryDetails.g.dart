// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmdHistoryDetails.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension CmdHistoryDetailsCopyWith on CmdHistoryDetails {
  CmdHistoryDetails copyWith({
    CmdHistoryEntry? cmd,
    int? code,
    double? duration,
    bool? fstRetrieved,
    String? logs,
    String? logsColorized,
    int? pid,
    int? port,
    List<dynamic>? results,
  }) {
    return CmdHistoryDetails(
      cmd: cmd ?? this.cmd,
      code: code ?? this.code,
      duration: duration ?? this.duration,
      fstRetrieved: fstRetrieved ?? this.fstRetrieved,
      logs: logs ?? this.logs,
      logsColorized: logsColorized ?? this.logsColorized,
      pid: pid ?? this.pid,
      port: port ?? this.port,
      results: results ?? this.results,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CmdHistoryDetails _$CmdHistoryDetailsFromJson(Map<String, dynamic> json) {
  return CmdHistoryDetails(
    port: json['port'] as int?,
    pid: json['pid'] as int?,
    duration: (json['duration'] as num?)?.toDouble(),
    code: json['code'] as int,
    results: json['results'] as List<dynamic>,
    logs: json['logs'] as String,
    logsColorized: json['logsColorized'] as String,
    fstRetrieved: json['fstRetrieved'] as bool?,
  );
}

Map<String, dynamic> _$CmdHistoryDetailsToJson(CmdHistoryDetails instance) =>
    <String, dynamic>{
      'port': instance.port,
      'pid': instance.pid,
      'duration': instance.duration,
      'code': instance.code,
      'results': instance.results,
      'logs': instance.logs,
      'logsColorized': instance.logsColorized,
      'fstRetrieved': instance.fstRetrieved,
    };
