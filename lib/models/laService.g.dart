// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laService.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServiceCopyWith on LAService {
  LAService copyWith({
    String? id,
    String? iniPath,
    String? nameInt,
    String? projectId,
    ServiceStatus? status,
    String? suburl,
    bool? use,
    bool? usesSubdomain,
  }) {
    return LAService(
      id: id ?? this.id,
      iniPath: iniPath ?? this.iniPath,
      nameInt: nameInt ?? this.nameInt,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      suburl: suburl ?? this.suburl,
      use: use ?? this.use,
      usesSubdomain: usesSubdomain ?? this.usesSubdomain,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAService _$LAServiceFromJson(Map<String, dynamic> json) {
  return LAService(
    id: json['id'] as String?,
    nameInt: json['nameInt'] as String,
    iniPath: json['iniPath'] as String,
    use: json['use'] as bool,
    usesSubdomain: json['usesSubdomain'] as bool,
    status: _$enumDecodeNullable(_$ServiceStatusEnumMap, json['status']),
    suburl: json['suburl'] as String,
    projectId: json['projectId'] as String,
  );
}

Map<String, dynamic> _$LAServiceToJson(LAService instance) => <String, dynamic>{
      'id': instance.id,
      'nameInt': instance.nameInt,
      'use': instance.use,
      'usesSubdomain': instance.usesSubdomain,
      'iniPath': instance.iniPath,
      'suburl': instance.suburl,
      'status': _$ServiceStatusEnumMap[instance.status],
      'projectId': instance.projectId,
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

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};
