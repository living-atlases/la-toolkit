// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension CmdCopyWith on Cmd {
  Cmd copyWith({
    String? id,
    Map<String, dynamic>? properties,
    CmdType? type,
  }) {
    return Cmd(
      id: id ?? this.id,
      properties: properties ?? this.properties,
      type: type ?? this.type,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cmd _$CmdFromJson(Map<String, dynamic> json) {
  return Cmd(
    id: json['id'] as String?,
    type: _$enumDecode(_$CmdTypeEnumMap, json['type']),
    properties: json['properties'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$CmdToJson(Cmd instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$CmdTypeEnumMap[instance.type],
      'properties': instance.properties,
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

const _$CmdTypeEnumMap = {
  CmdType.brandingDeploy: 'brandingDeploy',
  CmdType.deploy: 'deploy',
  CmdType.preDeploy: 'preDeploy',
  CmdType.postDeploy: 'postDeploy',
  CmdType.laPipelines: 'laPipelines',
  CmdType.bash: 'bash',
};
