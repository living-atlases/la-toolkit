// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'la_project.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LAProjectCWProxy {
  LAProject id(String? id);

  LAProject longName(String longName);

  LAProject shortName(String shortName);

  LAProject domain(String? domain);

  LAProject dirName(String? dirName);

  LAProject useSSL(bool useSSL);

  LAProject isCreated(bool isCreated);

  LAProject isHub(bool isHub);

  LAProject fstDeployed(bool? fstDeployed);

  LAProject additionalVariables(String additionalVariables);

  LAProject status(LAProjectStatus status);

  LAProject alaInstallRelease(String? alaInstallRelease);

  LAProject generatorRelease(String? generatorRelease);

  LAProject mapBoundsFstPoint(LALatLng? mapBoundsFstPoint);

  LAProject mapBoundsSndPoint(LALatLng? mapBoundsSndPoint);

  LAProject theme(String theme);

  LAProject mapZoom(double? mapZoom);

  LAProject lastCmdEntry(CmdHistoryEntry? lastCmdEntry);

  LAProject lastCmdDetails(CmdHistoryDetails? lastCmdDetails);

  LAProject advancedEdit(bool? advancedEdit);

  LAProject advancedTune(bool? advancedTune);

  LAProject variables(List<LAVariable>? variables);

  LAProject cmdHistoryEntries(List<CmdHistoryEntry>? cmdHistoryEntries);

  LAProject servers(List<LAServer>? servers);

  LAProject clusters(List<LACluster>? clusters);

  LAProject services(List<LAService>? services);

  LAProject serviceDeploys(List<LAServiceDeploy>? serviceDeploys);

  LAProject parent(LAProject? parent);

  LAProject hubs(List<LAProject>? hubs);

  LAProject createdAt(int? createdAt);

  LAProject serverServices(Map<String, List<String>>? serverServices);

  LAProject clusterServices(Map<String, List<String>>? clusterServices);

  LAProject checkResults(Map<String, dynamic>? checkResults);

  LAProject runningVersions(Map<String, String>? runningVersions);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAProject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAProject(...).copyWith(id: 12, name: "My name")
  /// ````
  LAProject call({
    String? id,
    String? longName,
    String? shortName,
    String? domain,
    String? dirName,
    bool? useSSL,
    bool? isCreated,
    bool? isHub,
    bool? fstDeployed,
    String? additionalVariables,
    LAProjectStatus? status,
    String? alaInstallRelease,
    String? generatorRelease,
    LALatLng? mapBoundsFstPoint,
    LALatLng? mapBoundsSndPoint,
    String? theme,
    double? mapZoom,
    CmdHistoryEntry? lastCmdEntry,
    CmdHistoryDetails? lastCmdDetails,
    bool? advancedEdit,
    bool? advancedTune,
    List<LAVariable>? variables,
    List<CmdHistoryEntry>? cmdHistoryEntries,
    List<LAServer>? servers,
    List<LACluster>? clusters,
    List<LAService>? services,
    List<LAServiceDeploy>? serviceDeploys,
    LAProject? parent,
    List<LAProject>? hubs,
    int? createdAt,
    Map<String, List<String>>? serverServices,
    Map<String, List<String>>? clusterServices,
    Map<String, dynamic>? checkResults,
    Map<String, String>? runningVersions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAProject.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLAProject.copyWith.fieldName(...)`
class _$LAProjectCWProxyImpl implements _$LAProjectCWProxy {
  const _$LAProjectCWProxyImpl(this._value);

  final LAProject _value;

  @override
  LAProject id(String? id) => this(id: id);

  @override
  LAProject longName(String longName) => this(longName: longName);

  @override
  LAProject shortName(String shortName) => this(shortName: shortName);

  @override
  LAProject domain(String? domain) => this(domain: domain);

  @override
  LAProject dirName(String? dirName) => this(dirName: dirName);

  @override
  LAProject useSSL(bool useSSL) => this(useSSL: useSSL);

  @override
  LAProject isCreated(bool isCreated) => this(isCreated: isCreated);

  @override
  LAProject isHub(bool isHub) => this(isHub: isHub);

  @override
  LAProject fstDeployed(bool? fstDeployed) => this(fstDeployed: fstDeployed);

  @override
  LAProject additionalVariables(String additionalVariables) =>
      this(additionalVariables: additionalVariables);

  @override
  LAProject status(LAProjectStatus status) => this(status: status);

  @override
  LAProject alaInstallRelease(String? alaInstallRelease) =>
      this(alaInstallRelease: alaInstallRelease);

  @override
  LAProject generatorRelease(String? generatorRelease) =>
      this(generatorRelease: generatorRelease);

  @override
  LAProject mapBoundsFstPoint(LALatLng? mapBoundsFstPoint) =>
      this(mapBoundsFstPoint: mapBoundsFstPoint);

  @override
  LAProject mapBoundsSndPoint(LALatLng? mapBoundsSndPoint) =>
      this(mapBoundsSndPoint: mapBoundsSndPoint);

  @override
  LAProject theme(String theme) => this(theme: theme);

  @override
  LAProject mapZoom(double? mapZoom) => this(mapZoom: mapZoom);

  @override
  LAProject lastCmdEntry(CmdHistoryEntry? lastCmdEntry) =>
      this(lastCmdEntry: lastCmdEntry);

  @override
  LAProject lastCmdDetails(CmdHistoryDetails? lastCmdDetails) =>
      this(lastCmdDetails: lastCmdDetails);

  @override
  LAProject advancedEdit(bool? advancedEdit) =>
      this(advancedEdit: advancedEdit);

  @override
  LAProject advancedTune(bool? advancedTune) =>
      this(advancedTune: advancedTune);

  @override
  LAProject variables(List<LAVariable>? variables) =>
      this(variables: variables);

  @override
  LAProject cmdHistoryEntries(List<CmdHistoryEntry>? cmdHistoryEntries) =>
      this(cmdHistoryEntries: cmdHistoryEntries);

  @override
  LAProject servers(List<LAServer>? servers) => this(servers: servers);

  @override
  LAProject clusters(List<LACluster>? clusters) => this(clusters: clusters);

  @override
  LAProject services(List<LAService>? services) => this(services: services);

  @override
  LAProject serviceDeploys(List<LAServiceDeploy>? serviceDeploys) =>
      this(serviceDeploys: serviceDeploys);

  @override
  LAProject parent(LAProject? parent) => this(parent: parent);

  @override
  LAProject hubs(List<LAProject>? hubs) => this(hubs: hubs);

  @override
  LAProject createdAt(int? createdAt) => this(createdAt: createdAt);

  @override
  LAProject serverServices(Map<String, List<String>>? serverServices) =>
      this(serverServices: serverServices);

  @override
  LAProject clusterServices(Map<String, List<String>>? clusterServices) =>
      this(clusterServices: clusterServices);

  @override
  LAProject checkResults(Map<String, dynamic>? checkResults) =>
      this(checkResults: checkResults);

  @override
  LAProject runningVersions(Map<String, String>? runningVersions) =>
      this(runningVersions: runningVersions);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAProject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAProject(...).copyWith(id: 12, name: "My name")
  /// ````
  LAProject call({
    Object? id = const $CopyWithPlaceholder(),
    Object? longName = const $CopyWithPlaceholder(),
    Object? shortName = const $CopyWithPlaceholder(),
    Object? domain = const $CopyWithPlaceholder(),
    Object? dirName = const $CopyWithPlaceholder(),
    Object? useSSL = const $CopyWithPlaceholder(),
    Object? isCreated = const $CopyWithPlaceholder(),
    Object? isHub = const $CopyWithPlaceholder(),
    Object? fstDeployed = const $CopyWithPlaceholder(),
    Object? additionalVariables = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? alaInstallRelease = const $CopyWithPlaceholder(),
    Object? generatorRelease = const $CopyWithPlaceholder(),
    Object? mapBoundsFstPoint = const $CopyWithPlaceholder(),
    Object? mapBoundsSndPoint = const $CopyWithPlaceholder(),
    Object? theme = const $CopyWithPlaceholder(),
    Object? mapZoom = const $CopyWithPlaceholder(),
    Object? lastCmdEntry = const $CopyWithPlaceholder(),
    Object? lastCmdDetails = const $CopyWithPlaceholder(),
    Object? advancedEdit = const $CopyWithPlaceholder(),
    Object? advancedTune = const $CopyWithPlaceholder(),
    Object? variables = const $CopyWithPlaceholder(),
    Object? cmdHistoryEntries = const $CopyWithPlaceholder(),
    Object? servers = const $CopyWithPlaceholder(),
    Object? clusters = const $CopyWithPlaceholder(),
    Object? services = const $CopyWithPlaceholder(),
    Object? serviceDeploys = const $CopyWithPlaceholder(),
    Object? parent = const $CopyWithPlaceholder(),
    Object? hubs = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? serverServices = const $CopyWithPlaceholder(),
    Object? clusterServices = const $CopyWithPlaceholder(),
    Object? checkResults = const $CopyWithPlaceholder(),
    Object? runningVersions = const $CopyWithPlaceholder(),
  }) {
    return LAProject(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      longName: longName == const $CopyWithPlaceholder() || longName == null
          ? _value.longName
          // ignore: cast_nullable_to_non_nullable
          : longName as String,
      shortName: shortName == const $CopyWithPlaceholder() || shortName == null
          ? _value.shortName
          // ignore: cast_nullable_to_non_nullable
          : shortName as String,
      domain: domain == const $CopyWithPlaceholder()
          ? _value.domain
          // ignore: cast_nullable_to_non_nullable
          : domain as String?,
      dirName: dirName == const $CopyWithPlaceholder()
          ? _value.dirName
          // ignore: cast_nullable_to_non_nullable
          : dirName as String?,
      useSSL: useSSL == const $CopyWithPlaceholder() || useSSL == null
          ? _value.useSSL
          // ignore: cast_nullable_to_non_nullable
          : useSSL as bool,
      isCreated: isCreated == const $CopyWithPlaceholder() || isCreated == null
          ? _value.isCreated
          // ignore: cast_nullable_to_non_nullable
          : isCreated as bool,
      isHub: isHub == const $CopyWithPlaceholder() || isHub == null
          ? _value.isHub
          // ignore: cast_nullable_to_non_nullable
          : isHub as bool,
      fstDeployed: fstDeployed == const $CopyWithPlaceholder()
          ? _value.fstDeployed
          // ignore: cast_nullable_to_non_nullable
          : fstDeployed as bool?,
      additionalVariables:
          additionalVariables == const $CopyWithPlaceholder() ||
                  additionalVariables == null
              ? _value.additionalVariables
              // ignore: cast_nullable_to_non_nullable
              : additionalVariables as String,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as LAProjectStatus,
      alaInstallRelease: alaInstallRelease == const $CopyWithPlaceholder()
          ? _value.alaInstallRelease
          // ignore: cast_nullable_to_non_nullable
          : alaInstallRelease as String?,
      generatorRelease: generatorRelease == const $CopyWithPlaceholder()
          ? _value.generatorRelease
          // ignore: cast_nullable_to_non_nullable
          : generatorRelease as String?,
      mapBoundsFstPoint: mapBoundsFstPoint == const $CopyWithPlaceholder()
          ? _value.mapBoundsFstPoint
          // ignore: cast_nullable_to_non_nullable
          : mapBoundsFstPoint as LALatLng?,
      mapBoundsSndPoint: mapBoundsSndPoint == const $CopyWithPlaceholder()
          ? _value.mapBoundsSndPoint
          // ignore: cast_nullable_to_non_nullable
          : mapBoundsSndPoint as LALatLng?,
      theme: theme == const $CopyWithPlaceholder() || theme == null
          ? _value.theme
          // ignore: cast_nullable_to_non_nullable
          : theme as String,
      mapZoom: mapZoom == const $CopyWithPlaceholder()
          ? _value.mapZoom
          // ignore: cast_nullable_to_non_nullable
          : mapZoom as double?,
      lastCmdEntry: lastCmdEntry == const $CopyWithPlaceholder()
          ? _value.lastCmdEntry
          // ignore: cast_nullable_to_non_nullable
          : lastCmdEntry as CmdHistoryEntry?,
      lastCmdDetails: lastCmdDetails == const $CopyWithPlaceholder()
          ? _value.lastCmdDetails
          // ignore: cast_nullable_to_non_nullable
          : lastCmdDetails as CmdHistoryDetails?,
      advancedEdit: advancedEdit == const $CopyWithPlaceholder()
          ? _value.advancedEdit
          // ignore: cast_nullable_to_non_nullable
          : advancedEdit as bool?,
      advancedTune: advancedTune == const $CopyWithPlaceholder()
          ? _value.advancedTune
          // ignore: cast_nullable_to_non_nullable
          : advancedTune as bool?,
      variables: variables == const $CopyWithPlaceholder()
          ? _value.variables
          // ignore: cast_nullable_to_non_nullable
          : variables as List<LAVariable>?,
      cmdHistoryEntries: cmdHistoryEntries == const $CopyWithPlaceholder()
          ? _value.cmdHistoryEntries
          // ignore: cast_nullable_to_non_nullable
          : cmdHistoryEntries as List<CmdHistoryEntry>?,
      servers: servers == const $CopyWithPlaceholder()
          ? _value.servers
          // ignore: cast_nullable_to_non_nullable
          : servers as List<LAServer>?,
      clusters: clusters == const $CopyWithPlaceholder()
          ? _value.clusters
          // ignore: cast_nullable_to_non_nullable
          : clusters as List<LACluster>?,
      services: services == const $CopyWithPlaceholder()
          ? _value.services
          // ignore: cast_nullable_to_non_nullable
          : services as List<LAService>?,
      serviceDeploys: serviceDeploys == const $CopyWithPlaceholder()
          ? _value.serviceDeploys
          // ignore: cast_nullable_to_non_nullable
          : serviceDeploys as List<LAServiceDeploy>?,
      parent: parent == const $CopyWithPlaceholder()
          ? _value.parent
          // ignore: cast_nullable_to_non_nullable
          : parent as LAProject?,
      hubs: hubs == const $CopyWithPlaceholder()
          ? _value.hubs
          // ignore: cast_nullable_to_non_nullable
          : hubs as List<LAProject>?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as int?,
      serverServices: serverServices == const $CopyWithPlaceholder()
          ? _value.serverServices
          // ignore: cast_nullable_to_non_nullable
          : serverServices as Map<String, List<String>>?,
      clusterServices: clusterServices == const $CopyWithPlaceholder()
          ? _value.clusterServices
          // ignore: cast_nullable_to_non_nullable
          : clusterServices as Map<String, List<String>>?,
      checkResults: checkResults == const $CopyWithPlaceholder()
          ? _value.checkResults
          // ignore: cast_nullable_to_non_nullable
          : checkResults as Map<String, dynamic>?,
      runningVersions: runningVersions == const $CopyWithPlaceholder()
          ? _value.runningVersions
          // ignore: cast_nullable_to_non_nullable
          : runningVersions as Map<String, String>?,
    );
  }
}

extension $LAProjectCopyWith on LAProject {
  /// Returns a callable class that can be used as follows: `instanceOfLAProject.copyWith(...)` or like so:`instanceOfLAProject.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LAProjectCWProxy get copyWith => _$LAProjectCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAProject _$LAProjectFromJson(Map<String, dynamic> json) => LAProject(
      id: json['id'] as String?,
      longName: json['longName'] as String? ?? '',
      shortName: json['shortName'] as String? ?? '',
      domain: json['domain'] as String?,
      dirName: json['dirName'] as String? ?? '',
      useSSL: json['useSSL'] as bool? ?? true,
      isCreated: json['isCreated'] as bool? ?? false,
      isHub: json['isHub'] as bool? ?? false,
      fstDeployed: json['fstDeployed'] as bool?,
      additionalVariables: json['additionalVariables'] as String? ?? '',
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
      theme: json['theme'] as String? ?? 'clean',
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
      clusters: (json['clusters'] as List<dynamic>?)
          ?.map((e) => LACluster.fromJson(e as Map<String, dynamic>))
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
      clusterServices: (json['clusterServices'] as Map<String, dynamic>?)?.map(
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
      'status': _$LAProjectStatusEnumMap[instance.status]!,
      'isCreated': instance.isCreated,
      'fstDeployed': instance.fstDeployed,
      'advancedEdit': instance.advancedEdit,
      'advancedTune': instance.advancedTune,
      'servers': instance.servers.map((e) => e.toJson()).toList(),
      'clusters': instance.clusters.map((e) => e.toJson()).toList(),
      'services': instance.services.map((e) => e.toJson()).toList(),
      'serverServices': instance.serverServices,
      'clusterServices': instance.clusterServices,
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
