// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laProject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAProjectCopyWith on LAProject {
  LAProject copyWith({
    String alaInstallRelease,
    String domain,
    bool isCreated,
    String longName,
    List<double> mapBounds1stPoint,
    List<double> mapBounds2ndPoint,
    double mapZoom,
    List<LAServer> servers,
    Map<String, LAService> services,
    String shortName,
    LAProjectStatus status,
    bool useSSL,
    dynamic uuid,
  }) {
    return LAProject(
      alaInstallRelease: alaInstallRelease ?? this.alaInstallRelease,
      domain: domain ?? this.domain,
      isCreated: isCreated ?? this.isCreated,
      longName: longName ?? this.longName,
      mapBounds1stPoint: mapBounds1stPoint ?? this.mapBounds1stPoint,
      mapBounds2ndPoint: mapBounds2ndPoint ?? this.mapBounds2ndPoint,
      mapZoom: mapZoom ?? this.mapZoom,
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
    alaInstallRelease: json['alaInstallRelease'] as String,
    mapBounds1stPoint: (json['mapBounds1stPoint'] as List)
        ?.map((e) => (e as num)?.toDouble())
        ?.toList(),
    mapBounds2ndPoint: (json['mapBounds2ndPoint'] as List)
        ?.map((e) => (e as num)?.toDouble())
        ?.toList(),
    mapZoom: (json['mapZoom'] as num)?.toDouble(),
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
      'alaInstallRelease': instance.alaInstallRelease,
      'mapBounds1stPoint': instance.mapBounds1stPoint,
      'mapBounds2ndPoint': instance.mapBounds2ndPoint,
      'mapZoom': instance.mapZoom,
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
