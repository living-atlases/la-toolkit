// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laProject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAProject.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfLAProject.copyWith.fieldName(...)`
class _LAProjectCWProxy {
  final LAProject _value;

  const _LAProjectCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `LAProject(...).copyWithNull(...)` to set certain fields to `null`. Prefer `LAProject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAProject(...).copyWith(id: 12, name: "My name")
  /// ````
  LAProject call({
    String? additionalVariables,
    bool? advancedEdit,
    bool? advancedTune,
    String? alaInstallRelease,
    Map<String, dynamic>? checkResults,
    List<CmdHistoryEntry>? cmdHistoryEntries,
    int? createdAt,
    String? dirName,
    String? domain,
    bool? fstDeployed,
    String? generatorRelease,
    List<LAProject>? hubs,
    String? id,
    bool? isCreated,
    bool? isHub,
    CmdHistoryDetails? lastCmdDetails,
    CmdHistoryEntry? lastCmdEntry,
    String? longName,
    LALatLng? mapBoundsFstPoint,
    LALatLng? mapBoundsSndPoint,
    double? mapZoom,
    LAProject? parent,
    Map<String, String>? runningVersions,
    Map<String, List<String>>? serverServices,
    List<LAServer>? servers,
    List<LAServiceDeploy>? serviceDeploys,
    List<LAService>? services,
    String? shortName,
    LAProjectStatus? status,
    String? theme,
    bool? useSSL,
    List<LAVariable>? variables,
  }) {
    return LAProject(
      additionalVariables: additionalVariables ?? _value.additionalVariables,
      advancedEdit: advancedEdit ?? _value.advancedEdit,
      advancedTune: advancedTune ?? _value.advancedTune,
      alaInstallRelease: alaInstallRelease ?? _value.alaInstallRelease,
      checkResults: checkResults ?? _value.checkResults,
      cmdHistoryEntries: cmdHistoryEntries ?? _value.cmdHistoryEntries,
      createdAt: createdAt ?? _value.createdAt,
      dirName: dirName ?? _value.dirName,
      domain: domain ?? _value.domain,
      fstDeployed: fstDeployed ?? _value.fstDeployed,
      generatorRelease: generatorRelease ?? _value.generatorRelease,
      hubs: hubs ?? _value.hubs,
      id: id ?? _value.id,
      isCreated: isCreated ?? _value.isCreated,
      isHub: isHub ?? _value.isHub,
      lastCmdDetails: lastCmdDetails ?? _value.lastCmdDetails,
      lastCmdEntry: lastCmdEntry ?? _value.lastCmdEntry,
      longName: longName ?? _value.longName,
      mapBoundsFstPoint: mapBoundsFstPoint ?? _value.mapBoundsFstPoint,
      mapBoundsSndPoint: mapBoundsSndPoint ?? _value.mapBoundsSndPoint,
      mapZoom: mapZoom ?? _value.mapZoom,
      parent: parent ?? _value.parent,
      runningVersions: runningVersions ?? _value.runningVersions,
      serverServices: serverServices ?? _value.serverServices,
      servers: servers ?? _value.servers,
      serviceDeploys: serviceDeploys ?? _value.serviceDeploys,
      services: services ?? _value.services,
      shortName: shortName ?? _value.shortName,
      status: status ?? _value.status,
      theme: theme ?? _value.theme,
      useSSL: useSSL ?? _value.useSSL,
      variables: variables ?? _value.variables,
    );
  }

  LAProject advancedEdit(bool? advancedEdit) => advancedEdit == null
      ? _value._copyWithNull(advancedEdit: true)
      : this(advancedEdit: advancedEdit);

  LAProject advancedTune(bool? advancedTune) => advancedTune == null
      ? _value._copyWithNull(advancedTune: true)
      : this(advancedTune: advancedTune);

  LAProject alaInstallRelease(String? alaInstallRelease) =>
      alaInstallRelease == null
          ? _value._copyWithNull(alaInstallRelease: true)
          : this(alaInstallRelease: alaInstallRelease);

  LAProject checkResults(Map<String, dynamic>? checkResults) =>
      checkResults == null
          ? _value._copyWithNull(checkResults: true)
          : this(checkResults: checkResults);

  LAProject cmdHistoryEntries(List<CmdHistoryEntry>? cmdHistoryEntries) =>
      cmdHistoryEntries == null
          ? _value._copyWithNull(cmdHistoryEntries: true)
          : this(cmdHistoryEntries: cmdHistoryEntries);

  LAProject createdAt(int? createdAt) => createdAt == null
      ? _value._copyWithNull(createdAt: true)
      : this(createdAt: createdAt);

  LAProject dirName(String? dirName) => dirName == null
      ? _value._copyWithNull(dirName: true)
      : this(dirName: dirName);

  LAProject domain(String? domain) => domain == null
      ? _value._copyWithNull(domain: true)
      : this(domain: domain);

  LAProject fstDeployed(bool? fstDeployed) => fstDeployed == null
      ? _value._copyWithNull(fstDeployed: true)
      : this(fstDeployed: fstDeployed);

  LAProject generatorRelease(String? generatorRelease) =>
      generatorRelease == null
          ? _value._copyWithNull(generatorRelease: true)
          : this(generatorRelease: generatorRelease);

  LAProject hubs(List<LAProject>? hubs) =>
      hubs == null ? _value._copyWithNull(hubs: true) : this(hubs: hubs);

  LAProject id(String? id) =>
      id == null ? _value._copyWithNull(id: true) : this(id: id);

  LAProject lastCmdDetails(CmdHistoryDetails? lastCmdDetails) =>
      lastCmdDetails == null
          ? _value._copyWithNull(lastCmdDetails: true)
          : this(lastCmdDetails: lastCmdDetails);

  LAProject lastCmdEntry(CmdHistoryEntry? lastCmdEntry) => lastCmdEntry == null
      ? _value._copyWithNull(lastCmdEntry: true)
      : this(lastCmdEntry: lastCmdEntry);

  LAProject mapBoundsFstPoint(LALatLng? mapBoundsFstPoint) =>
      mapBoundsFstPoint == null
          ? _value._copyWithNull(mapBoundsFstPoint: true)
          : this(mapBoundsFstPoint: mapBoundsFstPoint);

  LAProject mapBoundsSndPoint(LALatLng? mapBoundsSndPoint) =>
      mapBoundsSndPoint == null
          ? _value._copyWithNull(mapBoundsSndPoint: true)
          : this(mapBoundsSndPoint: mapBoundsSndPoint);

  LAProject mapZoom(double? mapZoom) => mapZoom == null
      ? _value._copyWithNull(mapZoom: true)
      : this(mapZoom: mapZoom);

  LAProject parent(LAProject? parent) => parent == null
      ? _value._copyWithNull(parent: true)
      : this(parent: parent);

  LAProject runningVersions(Map<String, String>? runningVersions) =>
      runningVersions == null
          ? _value._copyWithNull(runningVersions: true)
          : this(runningVersions: runningVersions);

  LAProject serverServices(Map<String, List<String>>? serverServices) =>
      serverServices == null
          ? _value._copyWithNull(serverServices: true)
          : this(serverServices: serverServices);

  LAProject servers(List<LAServer>? servers) => servers == null
      ? _value._copyWithNull(servers: true)
      : this(servers: servers);

  LAProject serviceDeploys(List<LAServiceDeploy>? serviceDeploys) =>
      serviceDeploys == null
          ? _value._copyWithNull(serviceDeploys: true)
          : this(serviceDeploys: serviceDeploys);

  LAProject services(List<LAService>? services) => services == null
      ? _value._copyWithNull(services: true)
      : this(services: services);

  LAProject variables(List<LAVariable>? variables) => variables == null
      ? _value._copyWithNull(variables: true)
      : this(variables: variables);

  LAProject additionalVariables(String additionalVariables) =>
      this(additionalVariables: additionalVariables);

  LAProject isCreated(bool isCreated) => this(isCreated: isCreated);

  LAProject isHub(bool isHub) => this(isHub: isHub);

  LAProject longName(String longName) => this(longName: longName);

  LAProject shortName(String shortName) => this(shortName: shortName);

  LAProject status(LAProjectStatus status) => this(status: status);

  LAProject theme(String theme) => this(theme: theme);

  LAProject useSSL(bool useSSL) => this(useSSL: useSSL);
}

extension LAProjectCopyWith on LAProject {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass LAProject implements IsJsonSerializable<LAProject>.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass LAProject implements IsJsonSerializable<LAProject>.name.copyWith.fieldName(...)`
  _LAProjectCWProxy get copyWith => _LAProjectCWProxy(this);

  LAProject _copyWithNull({
    bool advancedEdit = false,
    bool advancedTune = false,
    bool alaInstallRelease = false,
    bool checkResults = false,
    bool cmdHistoryEntries = false,
    bool createdAt = false,
    bool dirName = false,
    bool domain = false,
    bool fstDeployed = false,
    bool generatorRelease = false,
    bool hubs = false,
    bool id = false,
    bool lastCmdDetails = false,
    bool lastCmdEntry = false,
    bool mapBoundsFstPoint = false,
    bool mapBoundsSndPoint = false,
    bool mapZoom = false,
    bool parent = false,
    bool runningVersions = false,
    bool serverServices = false,
    bool servers = false,
    bool serviceDeploys = false,
    bool services = false,
    bool variables = false,
  }) {
    return LAProject(
      additionalVariables: additionalVariables,
      advancedEdit: advancedEdit == true ? null : this.advancedEdit,
      advancedTune: advancedTune == true ? null : this.advancedTune,
      alaInstallRelease:
          alaInstallRelease == true ? null : this.alaInstallRelease,
      checkResults: checkResults == true ? null : this.checkResults,
      cmdHistoryEntries:
          cmdHistoryEntries == true ? null : this.cmdHistoryEntries,
      createdAt: createdAt == true ? null : this.createdAt,
      dirName: dirName == true ? null : this.dirName,
      domain: domain == true ? null : this.domain,
      fstDeployed: fstDeployed == true ? null : this.fstDeployed,
      generatorRelease: generatorRelease == true ? null : this.generatorRelease,
      hubs: hubs == true ? null : this.hubs,
      id: id == true ? null : this.id,
      isCreated: isCreated,
      isHub: isHub,
      lastCmdDetails: lastCmdDetails == true ? null : this.lastCmdDetails,
      lastCmdEntry: lastCmdEntry == true ? null : this.lastCmdEntry,
      longName: longName,
      mapBoundsFstPoint:
          mapBoundsFstPoint == true ? null : this.mapBoundsFstPoint,
      mapBoundsSndPoint:
          mapBoundsSndPoint == true ? null : this.mapBoundsSndPoint,
      mapZoom: mapZoom == true ? null : this.mapZoom,
      parent: parent == true ? null : this.parent,
      runningVersions: runningVersions == true ? null : this.runningVersions,
      serverServices: serverServices == true ? null : this.serverServices,
      servers: servers == true ? null : this.servers,
      serviceDeploys: serviceDeploys == true ? null : this.serviceDeploys,
      services: services == true ? null : this.services,
      shortName: shortName,
      status: status,
      theme: theme,
      useSSL: useSSL,
      variables: variables == true ? null : this.variables,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAProject _$LAProjectFromJson(Map<String, dynamic> json) => LAProject(
      id: json['id'] as String?,
      longName: json['longName'] as String? ?? "",
      shortName: json['shortName'] as String? ?? "",
      domain: json['domain'] as String?,
      dirName: json['dirName'] as String? ?? "",
      useSSL: json['useSSL'] as bool? ?? true,
      isCreated: json['isCreated'] as bool? ?? false,
      isHub: json['isHub'] as bool? ?? false,
      fstDeployed: json['fstDeployed'] as bool?,
      additionalVariables: json['additionalVariables'] as String? ?? "",
      status: $enumDecodeNullable(_$LAProjectStatusEnumMap, json['status']) ??
          LAProjectStatus.created,
      alaInstallRelease: json['alaInstallRelease'] as String?,
      generatorRelease: json['generatorRelease'] as String?,
      mapBoundsFstPoint: json['mapBoundsFstPoint'] == null
          ? null
          : LALatLng.fromJson(
              json['mapBoundsFstPoint'] as Map<String, dynamic>),
      mapBoundsSndPoint: json['mapBoundsSndPoint'] == null
          ? null
          : LALatLng.fromJson(
              json['mapBoundsSndPoint'] as Map<String, dynamic>),
      theme: json['theme'] as String? ?? "clean",
      mapZoom: (json['mapZoom'] as num?)?.toDouble(),
      lastCmdEntry: json['lastCmdEntry'] == null
          ? null
          : CmdHistoryEntry.fromJson(
              json['lastCmdEntry'] as Map<String, dynamic>),
      advancedEdit: json['advancedEdit'] as bool?,
      advancedTune: json['advancedTune'] as bool?,
      variables: (json['variables'] as List<dynamic>?)
          ?.map((e) => LAVariable.fromJson(e as Map<String, dynamic>))
          .toList(),
      cmdHistoryEntries: (json['cmdHistoryEntries'] as List<dynamic>?)
          ?.map((e) => CmdHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      servers: (json['servers'] as List<dynamic>?)
          ?.map((e) => LAServer.fromJson(e as Map<String, dynamic>))
          .toList(),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => LAService.fromJson(e as Map<String, dynamic>))
          .toList(),
      serviceDeploys: (json['serviceDeploys'] as List<dynamic>?)
          ?.map((e) => LAServiceDeploy.fromJson(e as Map<String, dynamic>))
          .toList(),
      hubs: (json['hubs'] as List<dynamic>?)
          ?.map((e) => LAProject.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as int?,
      serverServices: (json['serverServices'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    )
      ..clientMigration = json['clientMigration'] as int?
      ..lastSwCheck = json['lastSwCheck'] == null
          ? null
          : DateTime.parse(json['lastSwCheck'] as String);

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
      'createdAt': instance.createdAt,
      'alaInstallRelease': instance.alaInstallRelease,
      'generatorRelease': instance.generatorRelease,
      'status': _$LAProjectStatusEnumMap[instance.status],
      'isCreated': instance.isCreated,
      'fstDeployed': instance.fstDeployed,
      'advancedEdit': instance.advancedEdit,
      'advancedTune': instance.advancedTune,
      'servers': instance.servers.map((e) => e.toJson()).toList(),
      'services': instance.services.map((e) => e.toJson()).toList(),
      'serverServices': instance.serverServices,
      'cmdHistoryEntries':
          instance.cmdHistoryEntries.map((e) => e.toJson()).toList(),
      'serviceDeploys': instance.serviceDeploys.map((e) => e.toJson()).toList(),
      'variables': instance.variables.map((e) => e.toJson()).toList(),
      'hubs': instance.hubs.map((e) => e.toJson()).toList(),
      'lastCmdEntry': instance.lastCmdEntry?.toJson(),
      'clientMigration': instance.clientMigration,
      'lastSwCheck': instance.lastSwCheck?.toIso8601String(),
    };

const _$LAProjectStatusEnumMap = {
  LAProjectStatus.created: 'created',
  LAProjectStatus.basicDefined: 'basicDefined',
  LAProjectStatus.advancedDefined: 'advancedDefined',
  LAProjectStatus.reachable: 'reachable',
  LAProjectStatus.firstDeploy: 'firstDeploy',
  LAProjectStatus.inProduction: 'inProduction',
};
