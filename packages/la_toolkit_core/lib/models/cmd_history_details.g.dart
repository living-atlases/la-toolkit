// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmd_history_details.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CmdHistoryDetailsCWProxy {
  CmdHistoryDetails cmd(CmdHistoryEntry? cmd);

  CmdHistoryDetails port(int? port);

  CmdHistoryDetails pid(int? pid);

  CmdHistoryDetails duration(double? duration);

  CmdHistoryDetails code(int code);

  CmdHistoryDetails results(List<dynamic> results);

  CmdHistoryDetails logs(String logs);

  CmdHistoryDetails logsColorized(String logsColorized);

  CmdHistoryDetails fstRetrieved(bool? fstRetrieved);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `CmdHistoryDetails(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CmdHistoryDetails(...).copyWith(id: 12, name: "My name")
  /// ```
  CmdHistoryDetails call({
    CmdHistoryEntry? cmd,
    int? port,
    int? pid,
    double? duration,
    int code,
    List<dynamic> results,
    String logs,
    String logsColorized,
    bool? fstRetrieved,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfCmdHistoryDetails.copyWith(...)` or call `instanceOfCmdHistoryDetails.copyWith.fieldName(value)` for a single field.
class _$CmdHistoryDetailsCWProxyImpl implements _$CmdHistoryDetailsCWProxy {
  const _$CmdHistoryDetailsCWProxyImpl(this._value);

  final CmdHistoryDetails _value;

  @override
  CmdHistoryDetails cmd(CmdHistoryEntry? cmd) => call(cmd: cmd);

  @override
  CmdHistoryDetails port(int? port) => call(port: port);

  @override
  CmdHistoryDetails pid(int? pid) => call(pid: pid);

  @override
  CmdHistoryDetails duration(double? duration) => call(duration: duration);

  @override
  CmdHistoryDetails code(int code) => call(code: code);

  @override
  CmdHistoryDetails results(List<dynamic> results) => call(results: results);

  @override
  CmdHistoryDetails logs(String logs) => call(logs: logs);

  @override
  CmdHistoryDetails logsColorized(String logsColorized) =>
      call(logsColorized: logsColorized);

  @override
  CmdHistoryDetails fstRetrieved(bool? fstRetrieved) =>
      call(fstRetrieved: fstRetrieved);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `CmdHistoryDetails(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CmdHistoryDetails(...).copyWith(id: 12, name: "My name")
  /// ```
  CmdHistoryDetails call({
    Object? cmd = const $CopyWithPlaceholder(),
    Object? port = const $CopyWithPlaceholder(),
    Object? pid = const $CopyWithPlaceholder(),
    Object? duration = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? results = const $CopyWithPlaceholder(),
    Object? logs = const $CopyWithPlaceholder(),
    Object? logsColorized = const $CopyWithPlaceholder(),
    Object? fstRetrieved = const $CopyWithPlaceholder(),
  }) {
    return CmdHistoryDetails(
      cmd: cmd == const $CopyWithPlaceholder()
          ? _value.cmd
          // ignore: cast_nullable_to_non_nullable
          : cmd as CmdHistoryEntry?,
      port: port == const $CopyWithPlaceholder()
          ? _value.port
          // ignore: cast_nullable_to_non_nullable
          : port as int?,
      pid: pid == const $CopyWithPlaceholder()
          ? _value.pid
          // ignore: cast_nullable_to_non_nullable
          : pid as int?,
      duration: duration == const $CopyWithPlaceholder()
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as double?,
      code: code == const $CopyWithPlaceholder() || code == null
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as int,
      results: results == const $CopyWithPlaceholder() || results == null
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<dynamic>,
      logs: logs == const $CopyWithPlaceholder() || logs == null
          ? _value.logs
          // ignore: cast_nullable_to_non_nullable
          : logs as String,
      logsColorized:
          logsColorized == const $CopyWithPlaceholder() || logsColorized == null
          ? _value.logsColorized
          // ignore: cast_nullable_to_non_nullable
          : logsColorized as String,
      fstRetrieved: fstRetrieved == const $CopyWithPlaceholder()
          ? _value.fstRetrieved
          // ignore: cast_nullable_to_non_nullable
          : fstRetrieved as bool?,
    );
  }
}

extension $CmdHistoryDetailsCopyWith on CmdHistoryDetails {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfCmdHistoryDetails.copyWith(...)` or `instanceOfCmdHistoryDetails.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CmdHistoryDetailsCWProxy get copyWith =>
      _$CmdHistoryDetailsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CmdHistoryDetails _$CmdHistoryDetailsFromJson(Map<String, dynamic> json) =>
    CmdHistoryDetails(
      port: (json['port'] as num?)?.toInt(),
      pid: (json['pid'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toDouble(),
      code: (json['code'] as num).toInt(),
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
