// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmdHistoryDetails.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfCmdHistoryDetails.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfCmdHistoryDetails.copyWith.fieldName(...)`
class _CmdHistoryDetailsCWProxy {
  final CmdHistoryDetails _value;

  const _CmdHistoryDetailsCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `CmdHistoryDetails(...).copyWithNull(...)` to set certain fields to `null`. Prefer `CmdHistoryDetails(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CmdHistoryDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  CmdHistoryDetails call({
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
      cmd: cmd ?? _value.cmd,
      code: code ?? _value.code,
      duration: duration ?? _value.duration,
      fstRetrieved: fstRetrieved ?? _value.fstRetrieved,
      logs: logs ?? _value.logs,
      logsColorized: logsColorized ?? _value.logsColorized,
      pid: pid ?? _value.pid,
      port: port ?? _value.port,
      results: results ?? _value.results,
    );
  }

  CmdHistoryDetails cmd(CmdHistoryEntry? cmd) =>
      cmd == null ? _value._copyWithNull(cmd: true) : this(cmd: cmd);

  CmdHistoryDetails duration(double? duration) => duration == null
      ? _value._copyWithNull(duration: true)
      : this(duration: duration);

  CmdHistoryDetails fstRetrieved(bool? fstRetrieved) => fstRetrieved == null
      ? _value._copyWithNull(fstRetrieved: true)
      : this(fstRetrieved: fstRetrieved);

  CmdHistoryDetails pid(int? pid) =>
      pid == null ? _value._copyWithNull(pid: true) : this(pid: pid);

  CmdHistoryDetails port(int? port) =>
      port == null ? _value._copyWithNull(port: true) : this(port: port);

  CmdHistoryDetails code(int code) => this(code: code);

  CmdHistoryDetails logs(String logs) => this(logs: logs);

  CmdHistoryDetails logsColorized(String logsColorized) =>
      this(logsColorized: logsColorized);

  CmdHistoryDetails results(List<dynamic> results) => this(results: results);
}

extension CmdHistoryDetailsCopyWith on CmdHistoryDetails {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass CmdHistoryDetails.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass CmdHistoryDetails.name.copyWith.fieldName(...)`
  _CmdHistoryDetailsCWProxy get copyWith => _CmdHistoryDetailsCWProxy(this);

  CmdHistoryDetails _copyWithNull({
    bool cmd = false,
    bool duration = false,
    bool fstRetrieved = false,
    bool pid = false,
    bool port = false,
  }) {
    return CmdHistoryDetails(
      cmd: cmd == true ? null : this.cmd,
      code: code,
      duration: duration == true ? null : this.duration,
      fstRetrieved: fstRetrieved == true ? null : this.fstRetrieved,
      logs: logs,
      logsColorized: logsColorized,
      pid: pid == true ? null : this.pid,
      port: port == true ? null : this.port,
      results: results,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CmdHistoryDetails _$CmdHistoryDetailsFromJson(Map<String, dynamic> json) =>
    CmdHistoryDetails(
      port: json['port'] as int?,
      pid: json['pid'] as int?,
      duration: (json['duration'] as num?)?.toDouble(),
      code: json['code'] as int,
      results: json['results'] as List<dynamic>,
      logs: json['logs'] as String,
      logsColorized: json['logsColorized'] as String,
      fstRetrieved: json['fstRetrieved'] as bool?,
    );

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
