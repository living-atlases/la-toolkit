// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmdHistoryEntry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension CmdHistoryEntryCopyWith on CmdHistoryEntry {
  CmdHistoryEntry copyWith({
    Cmd? cmd,
    int? createdAt,
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
      cmd: cmd ?? this.cmd,
      createdAt: createdAt ?? this.createdAt,
      desc: desc ?? this.desc,
      duration: duration ?? this.duration,
      id: id ?? this.id,
      invDir: invDir ?? this.invDir,
      logsPrefix: logsPrefix ?? this.logsPrefix,
      logsSuffix: logsSuffix ?? this.logsSuffix,
      rawCmd: rawCmd ?? this.rawCmd,
      result: result ?? this.result,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CmdHistoryEntry _$CmdHistoryEntryFromJson(Map<String, dynamic> json) {
  return CmdHistoryEntry(
    id: json['id'] as String?,
    logsPrefix: json['logsPrefix'] as String,
    logsSuffix: json['logsSuffix'] as String,
    desc: json['desc'] as String?,
    invDir: json['invDir'] as String?,
    rawCmd: json['rawCmd'] as String,
    cmd: Cmd.fromJson(json['cmd'] as Map<String, dynamic>),
    createdAt: json['createdAt'] as int?,
    duration: (json['duration'] as num?)?.toDouble(),
    result: _$enumDecode(_$CmdResultEnumMap, json['result']),
  );
}

Map<String, dynamic> _$CmdHistoryEntryToJson(CmdHistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'desc': instance.desc,
      'logsPrefix': instance.logsPrefix,
      'logsSuffix': instance.logsSuffix,
      'rawCmd': instance.rawCmd,
      'invDir': instance.invDir,
      'cmd': instance.cmd.toJson(),
      'result': _$CmdResultEnumMap[instance.result],
      'createdAt': instance.createdAt,
      'duration': instance.duration,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$CmdResultEnumMap = {
  CmdResult.unknown: 'unknown',
  CmdResult.aborted: 'aborted',
  CmdResult.success: 'success',
  CmdResult.failed: 'failed',
};
