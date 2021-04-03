// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laService.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServiceCopyWith on LAService {
  LAService copyWith({
    String? iniPath,
    String? nameInt,
    ServiceStatus? status,
    String? suburl,
    bool? use,
    bool? usesSubdomain,
    String? uuid,
  }) {
    return LAService(
      iniPath: iniPath ?? this.iniPath,
      nameInt: nameInt ?? this.nameInt,
      status: status ?? this.status,
      suburl: suburl ?? this.suburl,
      use: use ?? this.use,
      usesSubdomain: usesSubdomain ?? this.usesSubdomain,
      uuid: uuid ?? this.uuid,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAService _$LAServiceFromJson(Map<String, dynamic> json) {
  return LAService(
    uuid: json['uuid'] as String?,
    nameInt: json['nameInt'] as String,
    iniPath: json['iniPath'] as String,
    use: json['use'] as bool,
    usesSubdomain: json['usesSubdomain'] as bool,
    status: _$enumDecodeNullable(_$ServiceStatusEnumMap, json['status']),
    suburl: json['suburl'] as String,
  );
}

Map<String, dynamic> _$LAServiceToJson(LAService instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'nameInt': instance.nameInt,
      'iniPath': instance.iniPath,
      'use': instance.use,
      'usesSubdomain': instance.usesSubdomain,
      'suburl': instance.suburl,
      'status': _$ServiceStatusEnumMap[instance.status],
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
