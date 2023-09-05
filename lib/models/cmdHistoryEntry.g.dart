// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmdHistoryEntry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CmdHistoryEntryCWProxy {
  CmdHistoryEntry id(String? id);

  CmdHistoryEntry logsPrefix(String logsPrefix);

  CmdHistoryEntry logsSuffix(String logsSuffix);

  CmdHistoryEntry desc(String? desc);

  CmdHistoryEntry invDir(String? invDir);

  CmdHistoryEntry cwd(String? cwd);

  CmdHistoryEntry rawCmd(String rawCmd);

  CmdHistoryEntry cmd(Cmd cmd);

  CmdHistoryEntry createdAt(int? createdAt);

  CmdHistoryEntry duration(double? duration);

  CmdHistoryEntry result(CmdResult result);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CmdHistoryEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CmdHistoryEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  CmdHistoryEntry call({
    String? id,
    String? logsPrefix,
    String? logsSuffix,
    String? desc,
    String? invDir,
    String? cwd,
    String? rawCmd,
    Cmd? cmd,
    int? createdAt,
    double? duration,
    CmdResult? result,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCmdHistoryEntry.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCmdHistoryEntry.copyWith.fieldName(...)`
class _$CmdHistoryEntryCWProxyImpl implements _$CmdHistoryEntryCWProxy {
  const _$CmdHistoryEntryCWProxyImpl(this._value);

  final CmdHistoryEntry _value;

  @override
  CmdHistoryEntry id(String? id) => this(id: id);

  @override
  CmdHistoryEntry logsPrefix(String logsPrefix) => this(logsPrefix: logsPrefix);

  @override
  CmdHistoryEntry logsSuffix(String logsSuffix) => this(logsSuffix: logsSuffix);

  @override
  CmdHistoryEntry desc(String? desc) => this(desc: desc);

  @override
  CmdHistoryEntry invDir(String? invDir) => this(invDir: invDir);

  @override
  CmdHistoryEntry cwd(String? cwd) => this(cwd: cwd);

  @override
  CmdHistoryEntry rawCmd(String rawCmd) => this(rawCmd: rawCmd);

  @override
  CmdHistoryEntry cmd(Cmd cmd) => this(cmd: cmd);

  @override
  CmdHistoryEntry createdAt(int? createdAt) => this(createdAt: createdAt);

  @override
  CmdHistoryEntry duration(double? duration) => this(duration: duration);

  @override
  CmdHistoryEntry result(CmdResult result) => this(result: result);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CmdHistoryEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CmdHistoryEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  CmdHistoryEntry call({
    Object? id = const $CopyWithPlaceholder(),
    Object? logsPrefix = const $CopyWithPlaceholder(),
    Object? logsSuffix = const $CopyWithPlaceholder(),
    Object? desc = const $CopyWithPlaceholder(),
    Object? invDir = const $CopyWithPlaceholder(),
    Object? cwd = const $CopyWithPlaceholder(),
    Object? rawCmd = const $CopyWithPlaceholder(),
    Object? cmd = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? duration = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
  }) {
    return CmdHistoryEntry(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      logsPrefix:
          logsPrefix == const $CopyWithPlaceholder() || logsPrefix == null
              ? _value.logsPrefix
              // ignore: cast_nullable_to_non_nullable
              : logsPrefix as String,
      logsSuffix:
          logsSuffix == const $CopyWithPlaceholder() || logsSuffix == null
              ? _value.logsSuffix
              // ignore: cast_nullable_to_non_nullable
              : logsSuffix as String,
      desc: desc == const $CopyWithPlaceholder()
          ? _value.desc
          // ignore: cast_nullable_to_non_nullable
          : desc as String?,
      invDir: invDir == const $CopyWithPlaceholder()
          ? _value.invDir
          // ignore: cast_nullable_to_non_nullable
          : invDir as String?,
      cwd: cwd == const $CopyWithPlaceholder()
          ? _value.cwd
          // ignore: cast_nullable_to_non_nullable
          : cwd as String?,
      rawCmd: rawCmd == const $CopyWithPlaceholder() || rawCmd == null
          ? _value.rawCmd
          // ignore: cast_nullable_to_non_nullable
          : rawCmd as String,
      cmd: cmd == const $CopyWithPlaceholder() || cmd == null
          ? _value.cmd
          // ignore: cast_nullable_to_non_nullable
          : cmd as Cmd,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as int?,
      duration: duration == const $CopyWithPlaceholder()
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as double?,
      result: result == const $CopyWithPlaceholder() || result == null
          ? _value.result
          // ignore: cast_nullable_to_non_nullable
          : result as CmdResult,
    );
  }
}

extension $CmdHistoryEntryCopyWith on CmdHistoryEntry {
  /// Returns a callable class that can be used as follows: `instanceOfCmdHistoryEntry.copyWith(...)` or like so:`instanceOfCmdHistoryEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CmdHistoryEntryCWProxy get copyWith => _$CmdHistoryEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CmdHistoryEntry _$CmdHistoryEntryFromJson(Map<String, dynamic> json) =>
    CmdHistoryEntry(
      id: json['id'] as String?,
      logsPrefix: json['logsPrefix'] as String,
      logsSuffix: json['logsSuffix'] as String,
      desc: json['desc'] as String?,
      invDir: json['invDir'] as String?,
      cwd: json['cwd'] as String?,
      rawCmd: json['rawCmd'] as String,
      cmd: Cmd.fromJson(json['cmd'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as int?,
      duration: (json['duration'] as num?)?.toDouble(),
      result: $enumDecodeNullable(_$CmdResultEnumMap, json['result']) ??
          CmdResult.unknown,
    );

Map<String, dynamic> _$CmdHistoryEntryToJson(CmdHistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'desc': instance.desc,
      'logsPrefix': instance.logsPrefix,
      'logsSuffix': instance.logsSuffix,
      'rawCmd': instance.rawCmd,
      'invDir': instance.invDir,
      'cwd': instance.cwd,
      'cmd': instance.cmd.toJson(),
      'result': _$CmdResultEnumMap[instance.result]!,
      'createdAt': instance.createdAt,
      'duration': instance.duration,
    };

const _$CmdResultEnumMap = {
  CmdResult.unknown: 'unknown',
  CmdResult.aborted: 'aborted',
  CmdResult.success: 'success',
  CmdResult.failed: 'failed',
};
