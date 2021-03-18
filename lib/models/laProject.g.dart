// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laProject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAProjectCopyWith on LAProject {
  LAProject copyWith({
    String additionalVariables,
    bool advancedEdit,
    bool advancedTune,
    String alaInstallRelease,
    String domain,
    String generatorRelease,
    bool isCreated,
    List<dynamic> lastDeploymentResults,
    String longName,
    List<double> mapBounds1stPoint,
    List<double> mapBounds2ndPoint,
    double mapZoom,
    Map<String, List<String>> serverServices,
    List<LAServer> servers,
    Map<String, LAServer> serversMap,
    Map<String, LAService> services,
    String shortName,
    LAProjectStatus status,
    String theme,
    bool useSSL,
    String uuid,
    Map<String, LAVariable> variables,
  }) {
    return LAProject(
      additionalVariables: additionalVariables ?? this.additionalVariables,
      advancedEdit: advancedEdit ?? this.advancedEdit,
      advancedTune: advancedTune ?? this.advancedTune,
      alaInstallRelease: alaInstallRelease ?? this.alaInstallRelease,
      domain: domain ?? this.domain,
      generatorRelease: generatorRelease ?? this.generatorRelease,
      isCreated: isCreated ?? this.isCreated,
      lastDeploymentResults:
          lastDeploymentResults ?? this.lastDeploymentResults,
      longName: longName ?? this.longName,
      mapBounds1stPoint: mapBounds1stPoint ?? this.mapBounds1stPoint,
      mapBounds2ndPoint: mapBounds2ndPoint ?? this.mapBounds2ndPoint,
      mapZoom: mapZoom ?? this.mapZoom,
      serverServices: serverServices ?? this.serverServices,
      servers: servers ?? this.servers,
      serversMap: serversMap ?? this.serversMap,
      services: services ?? this.services,
      shortName: shortName ?? this.shortName,
      status: status ?? this.status,
      theme: theme ?? this.theme,
      useSSL: useSSL ?? this.useSSL,
      uuid: uuid ?? this.uuid,
      variables: variables ?? this.variables,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAProject _$LAProjectFromJson(Map<String, dynamic> json) {
  return LAProject(
    uuid: json['uuid'] as String,
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
    serversMap: (json['serversMap'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : LAServer.fromJson(e as Map<String, dynamic>)),
    ),
    variables: (json['variables'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k, e == null ? null : LAVariable.fromJson(e as Map<String, dynamic>)),
    ),
    additionalVariables: json['additionalVariables'] as String,
    serverServices: (json['serverServices'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, (e as List)?.map((e) => e as String)?.toList()),
    ),
    status: _$enumDecodeNullable(_$LAProjectStatusEnumMap, json['status']),
    alaInstallRelease: json['alaInstallRelease'] as String,
    generatorRelease: json['generatorRelease'] as String,
    mapBounds1stPoint: (json['mapBounds1stPoint'] as List)
        ?.map((e) => (e as num)?.toDouble())
        ?.toList(),
    mapBounds2ndPoint: (json['mapBounds2ndPoint'] as List)
        ?.map((e) => (e as num)?.toDouble())
        ?.toList(),
    theme: json['theme'] as String,
    mapZoom: (json['mapZoom'] as num)?.toDouble(),
    lastDeploymentResults: json['lastDeploymentResults'] as List,
    advancedEdit: json['advancedEdit'] as bool,
    advancedTune: json['advancedTune'] as bool,
  );
}

Map<String, dynamic> _$LAProjectToJson(LAProject instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'longName': instance.longName,
      'shortName': instance.shortName,
      'domain': instance.domain,
      'useSSL': instance.useSSL,
      'servers': instance.servers?.map((e) => e?.toJson())?.toList(),
      'serversMap':
          instance.serversMap?.map((k, e) => MapEntry(k, e?.toJson())),
      'services': instance.services?.map((k, e) => MapEntry(k, e?.toJson())),
      'variables': instance.variables?.map((k, e) => MapEntry(k, e?.toJson())),
      'additionalVariables': instance.additionalVariables,
      'serverServices': instance.serverServices,
      'advancedEdit': instance.advancedEdit,
      'advancedTune': instance.advancedTune,
      'status': _$LAProjectStatusEnumMap[instance.status],
      'theme': instance.theme,
      'alaInstallRelease': instance.alaInstallRelease,
      'generatorRelease': instance.generatorRelease,
      'mapBounds1stPoint': instance.mapBounds1stPoint,
      'mapBounds2ndPoint': instance.mapBounds2ndPoint,
      'mapZoom': instance.mapZoom,
      'lastDeploymentResults': instance.lastDeploymentResults,
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
