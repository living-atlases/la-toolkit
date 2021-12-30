// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmdHistoryEntry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfCmdHistoryEntry.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfCmdHistoryEntry.copyWith.fieldName(...)`
class _CmdHistoryEntryCWProxy {
  final CmdHistoryEntry _value;

  const _CmdHistoryEntryCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `CmdHistoryEntry(...).copyWithNull(...)` to set certain fields to `null`. Prefer `CmdHistoryEntry(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CmdHistoryEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  CmdHistoryEntry call({
    Cmd? cmd,
    int? createdAt,
    String? cwd,
    String? desc,
    double? duration,
    String? id,
    String? invDir,
    String? logsPrefix,
    String? logsSuffix,
    String? rawCmd,
    CmdResult? result,
  }) {
    return CmdHistoryEntry(
      cmd: cmd ?? _value.cmd,
      createdAt: createdAt ?? _value.createdAt,
      cwd: cwd ?? _value.cwd,
      desc: desc ?? _value.desc,
      duration: duration ?? _value.duration,
      id: id ?? _value.id,
      invDir: invDir ?? _value.invDir,
      logsPrefix: logsPrefix ?? _value.logsPrefix,
      logsSuffix: logsSuffix ?? _value.logsSuffix,
      rawCmd: rawCmd ?? _value.rawCmd,
      result: result ?? _value.result,
    );
  }

  CmdHistoryEntry createdAt(int? createdAt) => createdAt == null
      ? _value._copyWithNull(createdAt: true)
      : this(createdAt: createdAt);

  CmdHistoryEntry cwd(String? cwd) =>
      cwd == null ? _value._copyWithNull(cwd: true) : this(cwd: cwd);

  CmdHistoryEntry desc(String? desc) =>
      desc == null ? _value._copyWithNull(desc: true) : this(desc: desc);

  CmdHistoryEntry duration(double? duration) => duration == null
      ? _value._copyWithNull(duration: true)
      : this(duration: duration);

  CmdHistoryEntry id(String? id) =>
      id == null ? _value._copyWithNull(id: true) : this(id: id);

  CmdHistoryEntry invDir(String? invDir) => invDir == null
      ? _value._copyWithNull(invDir: true)
      : this(invDir: invDir);

  CmdHistoryEntry cmd(Cmd cmd) => this(cmd: cmd);

  CmdHistoryEntry logsPrefix(String logsPrefix) => this(logsPrefix: logsPrefix);

  CmdHistoryEntry logsSuffix(String logsSuffix) => this(logsSuffix: logsSuffix);

  CmdHistoryEntry rawCmd(String rawCmd) => this(rawCmd: rawCmd);

  CmdHistoryEntry result(CmdResult result) => this(result: result);
}

extension CmdHistoryEntryCopyWith on CmdHistoryEntry {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass CmdHistoryEntry implements IsJsonSerializable<dynamic>.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass CmdHistoryEntry implements IsJsonSerializable<dynamic>.name.copyWith.fieldName(...)`
  _CmdHistoryEntryCWProxy get copyWith => _CmdHistoryEntryCWProxy(this);

  CmdHistoryEntry _copyWithNull({
    bool createdAt = false,
    bool cwd = false,
    bool desc = false,
    bool duration = false,
    bool id = false,
    bool invDir = false,
  }) {
    return CmdHistoryEntry(
      cmd: cmd,
      createdAt: createdAt == true ? null : this.createdAt,
      cwd: cwd == true ? null : this.cwd,
      desc: desc == true ? null : this.desc,
      duration: duration == true ? null : this.duration,
      id: id == true ? null : this.id,
      invDir: invDir == true ? null : this.invDir,
      logsPrefix: logsPrefix,
      logsSuffix: logsSuffix,
      rawCmd: rawCmd,
      result: result,
    );
  }
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
      'result': _$CmdResultEnumMap[instance.result],
      'createdAt': instance.createdAt,
      'duration': instance.duration,
    };

const _$CmdResultEnumMap = {
  CmdResult.unknown: 'unknown',
  CmdResult.aborted: 'aborted',
  CmdResult.success: 'success',
  CmdResult.failed: 'failed',
};
