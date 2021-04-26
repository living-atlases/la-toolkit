// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laProject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAProjectCopyWith on LAProject {
  LAProject copyWith({
    String? additionalVariables,
    bool? advancedEdit,
    bool? advancedTune,
    String? alaInstallRelease,
    List<CmdHistoryEntry>? cmdHistoryEntries,
    String? dirName,
    String? domain,
    bool? fstDeployed,
    String? generatorRelease,
    String? id,
    bool? isCreated,
    bool? isHub,
    CmdHistoryDetails? lastCmdDetails,
    CmdHistoryEntry? lastCmdEntry,
    String? longName,
    LALatLng? mapBoundsFstPoint,
    LALatLng? mapBoundsSndPoint,
    double? mapZoom,
    Map<String, List<String>>? serverServices,
    List<LAServer>? servers,
    Map<String, LAServer>? serversMap,
    Map<String, LAService>? servicesMap,
    String? shortName,
    LAProjectStatus? status,
    String? theme,
    bool? useSSL,
    Map<String, LAVariable>? variablesMap,
  }) {
    return LAProject(
      additionalVariables: additionalVariables ?? this.additionalVariables,
      advancedEdit: advancedEdit ?? this.advancedEdit,
      advancedTune: advancedTune ?? this.advancedTune,
      alaInstallRelease: alaInstallRelease ?? this.alaInstallRelease,
      cmdHistoryEntries: cmdHistoryEntries ?? this.cmdHistoryEntries,
      dirName: dirName ?? this.dirName,
      domain: domain ?? this.domain,
      fstDeployed: fstDeployed ?? this.fstDeployed,
      generatorRelease: generatorRelease ?? this.generatorRelease,
      id: id ?? this.id,
      isCreated: isCreated ?? this.isCreated,
      isHub: isHub ?? this.isHub,
      lastCmdDetails: lastCmdDetails ?? this.lastCmdDetails,
      lastCmdEntry: lastCmdEntry ?? this.lastCmdEntry,
      longName: longName ?? this.longName,
      mapBoundsFstPoint: mapBoundsFstPoint ?? this.mapBoundsFstPoint,
      mapBoundsSndPoint: mapBoundsSndPoint ?? this.mapBoundsSndPoint,
      mapZoom: mapZoom ?? this.mapZoom,
      serverServices: serverServices ?? this.serverServices,
      servers: servers ?? this.servers,
      serversMap: serversMap ?? this.serversMap,
      servicesMap: servicesMap ?? this.servicesMap,
      shortName: shortName ?? this.shortName,
      status: status ?? this.status,
      theme: theme ?? this.theme,
      useSSL: useSSL ?? this.useSSL,
      variablesMap: variablesMap ?? this.variablesMap,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAProject _$LAProjectFromJson(Map<String, dynamic> json) {
  return LAProject(
    id: json['id'] as String?,
    longName: json['longName'] as String,
    shortName: json['shortName'] as String,
    domain: json['domain'] as String,
    dirName: json['dirName'] as String?,
    useSSL: json['useSSL'] as bool,
    isCreated: json['isCreated'] as bool,
    isHub: json['isHub'] as bool,
    fstDeployed: json['fstDeployed'] as bool?,
    servers: (json['servers'] as List<dynamic>?)
        ?.map((e) => LAServer.fromJson(e as Map<String, dynamic>))
        .toList(),
    servicesMap: (json['servicesMap'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, LAService.fromJson(e as Map<String, dynamic>)),
    ),
    serversMap: (json['serversMap'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, LAServer.fromJson(e as Map<String, dynamic>)),
    ),
    variablesMap: (json['variablesMap'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, LAVariable.fromJson(e as Map<String, dynamic>)),
    ),
    serverServices: (json['serverServices'] as Map<String, dynamic>?)?.map(
      (k, e) =>
          MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
    ),
    additionalVariables: json['additionalVariables'] as String,
    alaInstallRelease: json['alaInstallRelease'] as String?,
    generatorRelease: json['generatorRelease'] as String?,
    mapBoundsFstPoint: json['mapBoundsFstPoint'] == null
        ? null
        : LALatLng.fromJson(json['mapBoundsFstPoint'] as Map<String, dynamic>),
    mapBoundsSndPoint: json['mapBoundsSndPoint'] == null
        ? null
        : LALatLng.fromJson(json['mapBoundsSndPoint'] as Map<String, dynamic>),
    theme: json['theme'] as String,
    mapZoom: (json['mapZoom'] as num?)?.toDouble(),
    lastCmdEntry: json['lastCmdEntry'] == null
        ? null
        : CmdHistoryEntry.fromJson(
            json['lastCmdEntry'] as Map<String, dynamic>),
    cmdHistoryEntries: (json['cmdHistoryEntries'] as List<dynamic>?)
        ?.map((e) => CmdHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
    advancedEdit: json['advancedEdit'] as bool?,
    advancedTune: json['advancedTune'] as bool?,
  );
}

Map<String, dynamic> _$LAProjectToJson(LAProject instance) => <String, dynamic>{
      'id': instance.id,
      'longName': instance.longName,
      'shortName': instance.shortName,
      'dirName': instance.dirName,
      'domain': instance.domain,
      'useSSL': instance.useSSL,
      'isHub': instance.isHub,
      'theme': instance.theme,
      'mapBoundsFstPoint': instance.mapBoundsFstPoint.toJson(),
      'mapBoundsSndPoint': instance.mapBoundsSndPoint.toJson(),
      'mapZoom': instance.mapZoom,
      'additionalVariables': instance.additionalVariables,
      'alaInstallRelease': instance.alaInstallRelease,
      'generatorRelease': instance.generatorRelease,
      'isCreated': instance.isCreated,
      'fstDeployed': instance.fstDeployed,
      'advancedEdit': instance.advancedEdit,
      'advancedTune': instance.advancedTune,
      'servers': instance.servers.map((e) => e.toJson()).toList(),
      'serversMap': instance.serversMap.map((k, e) => MapEntry(k, e.toJson())),
      'servicesMap':
          instance.servicesMap.map((k, e) => MapEntry(k, e.toJson())),
      'variablesMap':
          instance.variablesMap.map((k, e) => MapEntry(k, e.toJson())),
      'serverServices': instance.serverServices,
      'cmdHistoryEntries':
          instance.cmdHistoryEntries.map((e) => e.toJson()).toList(),
      'lastCmdEntry': instance.lastCmdEntry?.toJson(),
    };
