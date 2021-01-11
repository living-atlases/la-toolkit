// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laProject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAProjectCopyWith on LAProject {
  LAProject copyWith({
    String domain,
    bool isCreated,
    String longName,
    List<LAServer> servers,
    Map<String, LAService> services,
    String shortName,
    LAProjectStatus status,
    bool useSSL,
    dynamic uuid,
  }) {
    return LAProject(
      domain: domain ?? this.domain,
      isCreated: isCreated ?? this.isCreated,
      longName: longName ?? this.longName,
      servers: servers ?? this.servers,
      services: services ?? this.services,
      shortName: shortName ?? this.shortName,
      status: status ?? this.status,
      useSSL: useSSL ?? this.useSSL,
      uuid: uuid ?? this.uuid,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAProject _$LAProjectFromJson(Map<String, dynamic> json) {
  return LAProject(
    uuid: json['uuid'],
    longName: json['longName'] as String,
    shortName: json['shortName'] as String,
    domain: json['domain'] as String,
    useSSL: json['useSSL'] as bool,
    servers: (json['servers'] as List)
        ?.map((e) =>
            e == null ? null : LAServer.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    services: (json['services'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : LAService.fromJson(e as Map<String, dynamic>)),
    ),
    status: _$enumDecodeNullable(_$LAProjectStatusEnumMap, json['status']),
  );
}

Map<String, dynamic> _$LAProjectToJson(LAProject instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'longName': instance.longName,
      'shortName': instance.shortName,
      'domain': instance.domain,
      'useSSL': instance.useSSL,
      'servers': instance.servers?.map((e) => e?.toJson())?.toList(),
      'services': instance.services?.map((k, e) => MapEntry(k, e?.toJson())),
      'status': _$LAProjectStatusEnumMap[instance.status],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$LAProjectStatusEnumMap = {
  LAProjectStatus.created: 'created',
  LAProjectStatus.basicDefined: 'basicDefined',
  LAProjectStatus.advancedDefined: 'advancedDefined',
  LAProjectStatus.reachable: 'reachable',
  LAProjectStatus.firstDeploy: 'firstDeploy',
  LAProjectStatus.inProduction: 'inProduction',
};
