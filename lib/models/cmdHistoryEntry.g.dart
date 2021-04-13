// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmdHistoryEntry.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension CmdHistoryEntryCopyWith on CmdHistoryEntry {
  CmdHistoryEntry copyWith({
    String? cmd,
    DateTime? date,
    DeployCmd? deployCmd,
    String? id,
    String? invDir,
    String? logsPrefix,
    String? logsSuffix,
    PostDeployCmd? postDeployCmd,
    PreDeployCmd? preDeployCmd,
    CmdResult? result,
  }) {
    return CmdHistoryEntry(
      cmd: cmd ?? this.cmd,
      date: date ?? this.date,
      deployCmd: deployCmd ?? this.deployCmd,
      id: id ?? this.id,
      invDir: invDir ?? this.invDir,
      logsPrefix: logsPrefix ?? this.logsPrefix,
      logsSuffix: logsSuffix ?? this.logsSuffix,
      postDeployCmd: postDeployCmd ?? this.postDeployCmd,
      preDeployCmd: preDeployCmd ?? this.preDeployCmd,
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
    invDir: json['invDir'] as String?,
    cmd: json['cmd'] as String,
    deployCmd: DeployCmd.fromJson(json['deployCmd'] as Map<String, dynamic>),
    preDeployCmd: json['preDeployCmd'] == null
        ? null
        : PreDeployCmd.fromJson(json['preDeployCmd'] as Map<String, dynamic>),
    postDeployCmd: json['postDeployCmd'] == null
        ? null
        : PostDeployCmd.fromJson(json['postDeployCmd'] as Map<String, dynamic>),
    date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
    result: _$enumDecode(_$CmdResultEnumMap, json['result']),
  );
}

Map<String, dynamic> _$CmdHistoryEntryToJson(CmdHistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'logsPrefix': instance.logsPrefix,
      'logsSuffix': instance.logsSuffix,
      'cmd': instance.cmd,
      'invDir': instance.invDir,
      'deployCmd': instance.deployCmd.toJson(),
      'preDeployCmd': instance.preDeployCmd?.toJson(),
      'postDeployCmd': instance.postDeployCmd?.toJson(),
      'date': instance.date.toIso8601String(),
      'result': _$CmdResultEnumMap[instance.result],
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
