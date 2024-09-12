import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:objectid/objectid.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:tuple/tuple.dart';

import '../utils/StringUtils.dart';
import '../utils/mapUtils.dart';
import '../utils/regexp.dart';
import '../utils/utils.dart';
import 'LAServiceConstants.dart';
import 'basic_service.dart';
import 'cmdHistoryEntry.dart';
import 'cmd_history_details.dart';
import 'defaultVersions.dart';
import 'deploymentType.dart';
import 'hostServicesChecks.dart';
import 'isJsonSerializable.dart';
import 'laCluster.dart';
import 'laLatLng.dart';
import 'laProjectStatus.dart';
import 'laServer.dart';
import 'laServiceDeploy.dart';
import 'laServiceDepsDesc.dart';
import 'laServiceDesc.dart';
import 'laServiceName.dart';
import 'laVariable.dart';
import 'laVariableDesc.dart';
import 'la_service.dart';
import 'prodServiceDesc.dart';
import 'versionUtils.dart';

part 'la_project.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAProject implements IsJsonSerializable<LAProject> {
  LAProject(
      {String? id,
      this.longName = '',
      this.shortName = '',
      String? domain,
      this.dirName = '',
      this.useSSL = true,
      this.isCreated = false,
      this.isHub = false,
      bool? fstDeployed,
      this.additionalVariables = '',
      this.status = LAProjectStatus.created,
      this.alaInstallRelease,
      this.generatorRelease,
      LALatLng? mapBoundsFstPoint,
      LALatLng? mapBoundsSndPoint,
      this.theme = 'clean',
      this.mapZoom,
      this.lastCmdEntry,
      this.lastCmdDetails,
      bool? advancedEdit,
      bool? advancedTune,
      List<LAVariable>? variables,
      List<CmdHistoryEntry>? cmdHistoryEntries,
      List<LAServer>? servers,
      List<LACluster>? clusters,
      List<LAService>? services,
      List<LAServiceDeploy>? serviceDeploys,
      this.parent,
      List<LAProject>? hubs,
      int? createdAt,
      Map<String, List<String>>? serverServices,
      Map<String, List<String>>? clusterServices,
      Map<String, dynamic>? checkResults,
      Map<String, String>? runningVersions})
      : id = id ?? ObjectId().toString(),
        domain = domain ?? (isHub ? 'somehubname.${parent!.domain}' : ''),
        servers = servers ?? <LAServer>[],
        clusters = clusters ?? <LACluster>[],
        services = services ?? getInitialServices(isHub),
        serviceDeploys = serviceDeploys ?? <LAServiceDeploy>[],
        variables = variables ?? <LAVariable>[],
        hubs = hubs ?? <LAProject>[],
        createdAt = createdAt ?? DateTime.now().microsecondsSinceEpoch,
        checkResults = checkResults ?? <String, dynamic>{},
        serverServices = serverServices ?? <String, List<String>>{},
        clusterServices = clusterServices ?? <String, List<String>>{},
        runningVersions = runningVersions ?? <String, String>{},
        advancedEdit = advancedEdit ?? false,
        advancedTune = advancedTune ?? false,
        cmdHistoryEntries = cmdHistoryEntries ?? <CmdHistoryEntry>[],
        fstDeployed = fstDeployed ?? false,
        mapBoundsFstPoint = mapBoundsFstPoint ?? LALatLng.from(-44, 112),
        mapBoundsSndPoint = mapBoundsSndPoint ?? LALatLng.from(-9, 154) {
    this.services = this.services.map((LAService s) {
      s.projectId = this.id;
      return s;
    }).toList();
    if ((dirName == null || dirName!.isEmpty) && shortName.isNotEmpty) {
      dirName = suggestDirName();
    }
    // _setDefSwVersions();
    validateCreation();
  }

  factory LAProject.fromJson(Map<String, dynamic> json) =>
      _$LAProjectFromJson(json);

  factory LAProject.fromObject(Map<String, dynamic> yoRc,
      {bool debug = false}) {
    dynamic a(String tag) => yoRc['LA_$tag'];
    final LAProject p = LAProject(
        longName: yoRc['LA_project_name'] as String,
        shortName: yoRc['LA_project_shortname'] as String,
        domain: yoRc['LA_domain'] as String,
        useSSL: yoRc['LA_enable_ssl'] as bool,
        services: <LAService>[]);
    final String domain = p.domain;
    final Map<String, List<String>> tempServerServices =
        <String, List<String>>{};

    for (final LAServiceDesc serviceDesc in LAServiceDesc.list(false)) {
      String n = serviceDesc.nameInt == 'cas' ? 'CAS' : serviceDesc.nameInt;
      // ala_bie and images was not optional in the past
      // ignore: avoid_bool_literals_in_conditional_expressions
      final bool useIt = !serviceDesc.optional
          ? true
          // ignore: avoid_bool_literals_in_conditional_expressions
          : a('use_$n') as bool? ??
                  n == 'ala_bie' ||
                      n == 'images' ||
                      n == biocacheCli ||
                      n == biocacheBackend ||
                      n == nameindexer
              ? true
              : false;
      final LAService service = p.getService(serviceDesc.nameInt);
      p.serviceInUse(serviceDesc.nameInt, useIt);
      n = serviceDesc.nameInt == 'species_lists'
          ? 'lists'
          : serviceDesc.nameInt;
      // ignore: avoid_bool_literals_in_conditional_expressions
      final bool useSub = serviceDesc.forceSubdomain
          ? true
          : a('${n}_uses_subdomain') as bool? ?? true;
      service.usesSubdomain = useSub;
      if (debug) {
        if (kDebugMode) {
          debugPrint('domain: $domain');
        }
      }
      if (debug) {
        if (kDebugMode) {
          debugPrint(
              '$n (LA_use_$n): $useIt subdomain (LA_${n}_uses_subdomain): $useSub');
        }
      }
      final String invPath = a('${n}_path') as String? ?? '';

      final String iniPath =
          invPath.startsWith('/') ? invPath.substring(1) : invPath;
      final String url =
          a('${n}_url') as String? ?? a('${n}_hostname') as String? ?? '';

      if (useSub) {
        service.suburl = url.replaceFirst('.$domain', '');
        service.iniPath = iniPath;
      } else {
        service.suburl = iniPath;
      }

      final String hostnames = a('${n}_hostname') as String? ?? '';

      if (debug) {
        if (kDebugMode) {
          debugPrint(
              "$n: url: $url path: '$invPath' initPath: '${service.iniPath}' useSub: $useSub suburl: ${service.suburl} hostname: $hostnames");
        }
      }

      if (useIt && hostnames.isNotEmpty) {
        LAServer s;
        for (final String hostname in hostnames.split(RegExp(r'[, ]+'))) {
          if (!p.getServersNameList().contains(hostname)) {
            // id is empty when is new
            s = LAServer(
                id: ObjectId().toString(), name: hostname, projectId: p.id);
            p.upsertServer(s);
          } else {
            s = p.servers.where((LAServer c) => c.name == hostname).toList()[0];
          }
          if (!tempServerServices.containsKey(s.id)) {
            tempServerServices[s.id] = List<String>.empty(growable: true);
          }
          tempServerServices[s.id]!.add(serviceDesc.nameInt);
        }
      }
    }
    for (final LAServer server in p.servers) {
      if (debug) {
        // debugPrint("server ${server.name} has ${tempServerServices[server.id]!}");
      }
      final Map<String, String> swVersions = <String, String>{};
      final dynamic impVersions = a('software_versions');
      if (impVersions != null) {
        final List<dynamic> swVersionsList =
            a('software_versions') as List<dynamic>;
        for (final dynamic swVersion in swVersionsList) {
          swVersions[swVersion[0] as String] = swVersion[1] as String;
        }
      }
      p.assign(server, tempServerServices[server.id]!, swVersions);
    }

    // Other variables
    LAVariableDesc.map.forEach((String name, LAVariableDesc laVar) {
      final Object? varInGenJson = a('variable_$name') as Object?;
      if (varInGenJson != null) {
        p.setVariable(laVar, varInGenJson);
      }
    });
    p.additionalVariables = a('additionalVariables') as String? ?? '';
    final String? regionsMap = a('regions_map_bounds') as String?;
    if (regionsMap != null) {
      final List<dynamic> bboxD = json.decode(regionsMap) as List<dynamic>;
      final List<String> bbox =
          bboxD.map((dynamic item) => item.toString()).toList();
      p.mapBoundsFstPoint = LALatLng(
          latitude: double.parse(bbox[0]), longitude: double.parse(bbox[1]));
      p.mapBoundsSndPoint = LALatLng(
          latitude: double.parse(bbox[2]), longitude: double.parse(bbox[3]));
    }
    if (p.dirName == null || p.dirName!.isEmpty) {
      p.dirName = p.suggestDirName();
    }

    if (p.getService(cas).use) {
      p.serviceInUse(apikey, true);
      p.serviceInUse(userdetails, true);
      p.serviceInUse(casManagement, true);
    }
    if (p.getService(spatial).use) {
      p.serviceInUse(spatialService, true);
      p.serviceInUse(geoserver, true);
    }
    if (p.getService(pipelines).use) {
      p.serviceInUse(spark, true);
      p.serviceInUse(hadoop, true);
    }
    if (p.getService(events).use) {
      p.serviceInUse(eventsElasticSearch, true);
    }
    final String? biocacheHostname = a('biocache_backend_hostname') as String?;
    if (biocacheHostname != null) {
      p.getService(biocacheBackend).use = true;
      p.getService(pipelines).use = false;
    }
    // TODO(vjrj): map zoom
    return p;
  }

  // Basic -----
  String id;
  String longName;
  String shortName;
  String? dirName;
  String domain;
  bool useSSL;
  bool isHub;

  // Additional -----
  String theme;
  LALatLng mapBoundsFstPoint;
  LALatLng mapBoundsSndPoint;
  double? mapZoom;
  String additionalVariables;
  int createdAt;

  // Software -----
  String? alaInstallRelease;
  String? generatorRelease;

  // Status -----
  // @JsonKey(ignore: true)
  LAProjectStatus status;
  bool isCreated;
  bool fstDeployed;
  bool advancedEdit;
  bool advancedTune;
  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, dynamic> checkResults;

  // Relations -----
  List<LAServer> servers;
  List<LACluster> clusters;
  List<LAService> services;

  // Mapped by server.id - serviceNames
  Map<String, List<String>> serverServices;

  // Mapped by cluster.id - serviceNames
  Map<String, List<String>> clusterServices;
  List<CmdHistoryEntry> cmdHistoryEntries;
  List<LAServiceDeploy> serviceDeploys;
  List<LAVariable> variables;
  List<LAProject> hubs;
  @JsonKey(includeToJson: false, includeFromJson: false)
  LAProject? parent;
  @JsonKey(includeToJson: false, includeFromJson: false)
  Map<String, String> runningVersions;

  // Logs history -----
  CmdHistoryEntry? lastCmdEntry;
  @JsonKey(includeToJson: false, includeFromJson: false)
  CmdHistoryDetails? lastCmdDetails;
  @JsonKey(includeToJson: false, includeFromJson: false)
  Tuple2<List<ProdServiceDesc>, HostsServicesChecks>? servicesToMonitor;

  int? clientMigration;

  DateTime? lastSwCheck;

  @JsonKey(includeToJson: false, includeFromJson: false)
  LAServer? masterPipelinesServer;

  int numServers() => servers.length;

  LatLng getCenter() {
    return MapUtils.center(mapBoundsFstPoint, mapBoundsSndPoint);
  }

  bool validateCreation({bool debug = false}) {
    bool valid = true;
    LAProjectStatus tempStatus = LAProjectStatus.created;
    if (servers.length != serverServices.length ||
        clusters.length != clusterServices.length) {
      String msgErr =
          'Servers in $longName ($id) are inconsistent (serverServices: ${serverServices.length} servers: ${servers.length})';
      msgErr +=
          ' or Clusters are inconsistent (clusterServices: ${clusterServices.length} clusters: ${clusters.length})';
      if (kDebugMode) {
        debugPrint(msgErr);
        debugPrint('servers (${servers.length}): $servers');
        debugPrint(
            'serverServices (${serverServices.length}): $serverServices');
        debugPrint('clusters (${clusters.length}): $clusters');
        debugPrint(
            'clusterServices (${clusterServices.length}): $clusterServices');
      }
      debugPrint(msgErr);
      debugPrint('Remove orphans');
      // FIXME: In the backend, there are still inconsistencies
      serverServices.removeWhere((String serverId, _) =>
          !servers.any((LAServer server) => server.id == serverId));
      clusterServices.removeWhere((String clusterId, _) =>
          !clusters.any((LACluster cluster) => cluster.id == clusterId));
      // final Exception error = Exception(msgErr);
      // throw error;
    }

    valid = valid &&
        LARegExp.projectNameRegexp.hasMatch(longName) &&
        LARegExp.shortNameRegexp.hasMatch(shortName) &&
        LARegExp.domainRegexp.hasMatch(domain) &&
        alaInstallRelease != null &&
        generatorRelease != null;
    if (valid) {
      tempStatus = LAProjectStatus.basicDefined;
    }
    if (debug) {
      if (kDebugMode) {
        debugPrint("Step 1 valid: ${valid ? 'yes' : 'no'}");
      }
    }

    valid = valid && servers.isNotEmpty;
    if (valid) {
      for (final LAServer s in servers) {
        valid = valid && LARegExp.hostnameRegexp.hasMatch(s.name);
      }
    }
    if (debug) {
      if (kDebugMode) {
        debugPrint("Step 2 valid: ${valid ? 'yes' : 'no'}");
      }
    }
    // If the previous steps are correct, this is also correct

    valid = valid && allServicesAssigned();
    if (debug) {
      if (kDebugMode) {
        debugPrint("Step 3 valid: ${valid ? 'yes' : 'no'}");
      }
    }

    if (valid) {
      for (final LAServer s in servers) {
        valid = valid && LARegExp.ip.hasMatch(s.ip);
        valid = valid && s.sshKey != null;
      }
    }
    if (debug) {
      if (kDebugMode) {
        debugPrint("Step 4 valid: ${valid ? 'yes' : 'no'}");
      }
    }

    isCreated = valid;
    if (isCreated && !allServersWithServicesReady()) {
      tempStatus = LAProjectStatus.advancedDefined;
    }
    if (isCreated && fstDeployed && allServersWithServicesReady()) {
      tempStatus = LAProjectStatus.firstDeploy;
    }
    /* if (isCreated &&
        allServersWithServicesReady() &&
        this.tempStatus.value < tempStatus.value) setProjectStatus(tempStatus); */
    // Only update tempStatus if is better
    if (status.value < tempStatus.value) {
      status = tempStatus;
    }
    if (debug) {
      if (kDebugMode) {
        debugPrint(
            "Valid at end: ${valid ? 'yes' : 'no'}, tempStatus: ${status.title}");
      }
    }
    return valid;
  }

  bool allServicesAssigned({bool debug = false}) {
    final List<String> difference = servicesNotAssigned();
    final bool ok = difference.isEmpty;

    if (!ok && debug) {
      if (kDebugMode) {
        debugPrint(
            'Not the same services in use ${getServicesNameListInUse().length} as assigned ${getServicesAssigned().length}');
        debugPrint(
            "Services unassigned: ${getServicesNameListInUse().where((String s) => !getServicesAssigned().contains(s)).toList().join(',')}");
      }
    }
    getServicesNameListInUse().forEach((String service) {
      ok && getHostnames(service).isNotEmpty;
    });
    return ok;
  }

  List<String> servicesNotAssigned() {
    final List<String> difference = getServicesNameListInUse()
        .toSet()
        .difference(getServicesAssigned().toSet())
        .toList();
    return difference;
  }

  List<LAServer> serversWithServices() {
    return servers
        .where((LAServer s) =>
            serverServices[s.id] != null && serverServices[s.id]!.isNotEmpty)
        .toList();
  }

  bool allServersWithIPs() {
    bool allReady = true;
    for (final LAServer s in servers) {
      allReady = allReady && LARegExp.ip.hasMatch(s.ip);
    }
    return allReady;
  }

  bool allServersWithSshKeys() {
    bool allReady = true;
    for (final LAServer s in servers) {
      allReady = allReady && s.sshKey != null;
    }
    return allReady;
  }

  bool allServersWithServicesReady() {
    bool allReady = true && serversWithServices().isNotEmpty;
    serversWithServices().forEach((LAServer s) {
      allReady = allReady && s.isReady();
    });
    return allReady;
  }

  bool allServersWithSshReady() {
    bool allReady = true && serversWithServices().isNotEmpty;
    serversWithServices().forEach((LAServer s) {
      allReady = allReady && s.isSshReady();
    });
    return allReady;
  }

  bool allServersWithSupportedOs(String name, String version) {
    for (final LAServer s in serversWithServices()) {
      if (s.osName != name || v(s.osVersion).compareTo(v(version)) < 0) {
        return false;
      }
    }
    return true;
  }

  List<String> getServersNameList() {
    return servers.map((LAServer s) => s.name).toList();
  }

  List<String> getServicesNameListInUse() {
    return services
        .where((LAService service) => service.use)
        .map((LAService service) => service.nameInt)
        .toList();
  }

  List<String> getServicesNameListNotInUse() {
    return services
        .where((LAService service) => !service.use)
        .map((LAService service) => service.nameInt)
        .toList();
  }

  List<String> getServicesAssigned([bool onlyDocker = false]) {
    final Set<String> selected = <String>{};
    if (!onlyDocker) {
      serverServices.forEach(
          (String id, List<String> service) => selected.addAll(service));
    }
    clusterServices
        .forEach((String id, List<String> service) => selected.addAll(service));
    return selected.toList();
  }

  @override
  Map<String, dynamic> toJson() => _$LAProjectToJson(this);

  @override
  String toString() {
    String? sToS;
    String? cToS;
    try {
      sToS = serverServices.entries
          .map((MapEntry<String, List<String>> entry) =>
              '${servers.firstWhere((LAServer server) => server.id == entry.key).name} has ${entry.value}')
          .toList()
          .join('\n');
      cToS = clusterServices.entries
          .map((MapEntry<String, List<String>> entry) =>
              '${clusters.firstWhere((LACluster cluster) => cluster.id == entry.key).name} has ${entry.value}')
          .toList()
          .join('\n');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in toString: $e');
      }
    }
    return '''
PROJECT: longName: $longName ($shortName) dirName: $dirName domain: $domain, ssl: $useSSL, hub: $isHub, allWServReady: ___${allServersWithServicesReady()}___
isHub: $isHub isCreated: $isCreated fstDeployed: $fstDeployed validCreated: ${validateCreation()}, status: __${status.title}__, ala-install: $alaInstallRelease, generator: $generatorRelease
lastCmdEntry ${lastCmdEntry != null ? lastCmdEntry!.deployCmd.toString() : 'none'} map: $mapBoundsFstPoint $mapBoundsSndPoint, zoom: $mapZoom
servers (${servers.length}): ${servers.join('| ')}
clusters (${clusters.length}): ${clusters.join('| ')}
services (${services.length})
serviceDeploys (${serviceDeploys.length})
servers-services (${serverServices.length}): 
${sToS ?? "Some error in serversToServices"}
cluster-services (${clusterServices.length}):
${cToS ?? "Some error in clusterToServices"}
services selected (${getServicesAssigned().length}): [${getServicesAssigned().join(', ')}]
services in use (${getServicesNameListInUse().length}): [${getServicesNameListInUse().join(', ')}]
services not in use (${getServicesNameListNotInUse().length}): [${getServicesNameListNotInUse().join(', ')}]
check results length: ${checkResults.length}''';
  }

  //static List<LAService> initialServices = getInitialServices(id);

  static List<LAService> getInitialServices(bool isHub) {
    final List<LAService> services = <LAService>[];
    final List<LAServiceDesc> availableService = LAServiceDesc.list(isHub);
    for (final LAServiceDesc desc in availableService) {
      final LAService initialService = LAService.fromDesc(desc, '');
      if (isHub) {
        initialService.iniPath = initialService.suburl;
        initialService.suburl = 'hub';
        if (initialService.nameInt == 'branding') {
          initialService.iniPath = '';
        }
      }
      services.add(initialService);
    }
    return services;
  }

  LAService getServiceE(LAServiceName nameInt) {
    return getService(nameInt.toS());
  }

  LAService getService(String nameInt) {
    if (AppUtils.isDev()) {
      assert(LAServiceDesc.listS(isHub).contains(nameInt) == true,
          'Trying to get $nameInt service while not present in service lists and hub=$isHub');
    }
    final LAService curService =
        services.firstWhere((LAService s) => s.nameInt == nameInt, orElse: () {
      // debugPrint("Creating service $nameInt as is not present");
      final LAService newService =
          LAService.fromDesc(LAServiceDesc.get(nameInt), id);
      services.add(newService);
      return newService;
    });
    if (AppUtils.isDev()) {
      assert(services.where((LAService s) => s.nameInt == nameInt).length == 1,
          'Warn, duplicate service $nameInt');
    }
    return curService;
  }

  String get projectName => isHub ? 'Data Hub' : 'Project';

  String get portalName => isHub ? 'hub' : 'portal';

  // ignore: non_constant_identifier_names
  String get PortalName => isHub ? 'Hub' : 'Portal';

  LAVariable getVariable(String nameInt) {
    final LAVariable laVar = variables.firstWhere(
        (LAVariable v) => v.nameInt == nameInt,
        orElse: () => LAVariable.fromDesc(LAVariableDesc.get(nameInt), id));
    return laVar;
  }

  LAVariable? getVariableOrNull(String nameInt) {
    final LAVariable? laVar =
        variables.firstWhereOrNull((LAVariable v) => v.nameInt == nameInt);
    return laVar;
  }

  Object? getVariableValue(String nameInt) {
    final LAVariable variable = getVariable(nameInt);
    final bool isEmpty = variable.value == null;
    final LAVariableDesc desc = LAVariableDesc.get(nameInt);
    final Object? value =
        variable.value ??= desc.defValue != null ? desc.defValue!(this) : null;
    if (isEmpty && value != null) {
      setVariable(desc, value);
    }
    return value;
  }

  String? getSwVersionOfService(String nameInt) {
    final List<LAServiceDeploy> deploys =
        getServiceDeploysForSomeService(nameInt);
    final String? swVersion =
        deploys.isEmpty ? null : deploys.first.softwareVersions[nameInt];
    return swVersion;
  }

  bool isStringVariableNullOrEmpty(String nameInt) {
    final LAVariable variable = getVariable(nameInt);
    final bool isNull = variable.value == null;
    if (isNull) {
      return true;
    }
    return variable.value.toString().isEmpty;
  }

  void setVariable(LAVariableDesc variableDesc, Object value) {
    final LAVariable cur = getVariable(variableDesc.nameInt);
    cur.value = value;
    variables.removeWhere((LAVariable v) => v.nameInt == variableDesc.nameInt);
    variables.add(cur);
  }

  List<String> getServicesNameListInServer(String serverId) {
    return serverServices[serverId] ?? <String>[];
  }

  void upsertServer(LAServer laServer) {
    servers = LAServer.upsertByName(servers, laServer);
    final LAServer upsertServer =
        servers.firstWhereOrNull((LAServer s) => s.name == laServer.name)!;
    _cleanServerServices(upsertServer);
  }

  void upsertById(LAServer laServer) {
    servers = LAServer.upsertById(servers, laServer);
    _cleanServerServices(laServer);
  }

  void _cleanServerServices(LAServer laServer) {
    if (!serverServices.containsKey(laServer.id)) {
      serverServices[laServer.id] = <String>[];
    }
  }

  void assign(LAServer server, List<String> assignedServices,
      [Map<String, String>? softwareVersions]) {
    assignByType(
        server.id, DeploymentType.vm, assignedServices, softwareVersions);
  }

  void assignByType(
      String sOrCId, DeploymentType type, List<String> assignedServices,
      [Map<String, String>? softwareVersions]) {
    final bool isServer = type == DeploymentType.vm;
    final String? serverId = isServer ? sOrCId : null;
    final String? clusterId = !isServer ? sOrCId : null;
    HashSet<String> newServices = HashSet<String>();
    newServices.addAll(assignedServices);
    // In the same server nameindexer and biocache_cli
    newServices = _addSubServices(newServices);
    if (isServer) {
      serverServices[sOrCId] = newServices.toList();
    } else {
      clusterServices[sOrCId] = newServices.toList();
    }
    final List<String> serviceIds = <String>[];
    if (assignedServices.contains(dockerSwarm)) {
      _addDockerClusterIfNotExists();
    }
    for (final String sN in newServices) {
      final LAService service = getService(sN);
      serviceIds.add(service.id);
      serviceDeploys.firstWhere(
          (LAServiceDeploy sD) =>
              sD.projectId == id &&
              sD.serverId == serverId &&
              sD.clusterId == clusterId &&
              sD.type == type &&
              sD.serviceId == service.id, orElse: () {
        final Map<String, String> versions = getServiceDefaultVersions(service);
        if (softwareVersions != null) {
          final String? ansibleVar = LAServiceDesc.swToAnsibleVars[sN];
          if (ansibleVar != null) {
            final String? serviceVersion = softwareVersions[ansibleVar];
            if (serviceVersion != null) {
              versions[sN] = serviceVersion;
            }
          }
        }
        final LAServiceDeploy newSd = LAServiceDeploy(
            projectId: id,
            serverId: serverId,
            clusterId: clusterId,
            type: type,
            serviceId: service.id,
            softwareVersions: versions);
        serviceDeploys.add(newSd);
        return newSd;
      });
    }

    // Remove previous deploys
    serviceDeploys.removeWhere((LAServiceDeploy sD) =>
        sD.projectId == id &&
        sD.serverId == serverId &&
        sD.clusterId == clusterId &&
        sD.type == type &&
        !serviceIds.contains(sD.serviceId));
  }

  void unAssign(LAServer server, String serviceName) {
    unAssignByType(server.id, DeploymentType.vm, serviceName);
  }

  void unAssignByType(String id, DeploymentType type, String serviceName) {
    final bool isServer = type == DeploymentType.vm;
    final String? serverId = isServer ? id : null;
    final String? clusterId = !isServer ? id : null;
    HashSet<String> servicesToDel = HashSet<String>();
    servicesToDel.add(serviceName);
    servicesToDel = _addSubServices(servicesToDel);
    if (isServer && serverServices[id] != null) {
      serverServices[id]?.removeWhere((String c) => servicesToDel.contains(c));
    }
    if (!isServer && clusterServices[id] != null) {
      clusterServices[id]?.removeWhere((String c) => servicesToDel.contains(c));
    }
    for (final String sN in servicesToDel) {
      final LAService service = getService(sN);
      serviceDeploys.removeWhere((LAServiceDeploy sD) =>
          sD.projectId == id &&
          sD.serverId == serverId &&
          sD.clusterId == clusterId &&
          sD.type == type &&
          sD.serviceId == service.id);
    }
    if (serviceName == dockerSwarm && isDockerClusterConfigured()) {
      // For now, we remove all cluster because we only support one unique cluster
      if (getServiceDeploysForSomeService(dockerSwarm).isEmpty) {
        clusters.clear();
        clusterServices.clear();
      }
    }
  }

  bool isDockerClusterConfigured() {
    return isDockerEnabled &&
        getServiceDeploysForSomeService(dockerSwarm).isNotEmpty;
  }

  static HashSet<String> _addSubServices(HashSet<String> newServices) {
    // In the same server nameindexer and biocache_cli
    if (newServices.contains(biocacheBackend)) {
      newServices.add(nameindexer);
      newServices.add(biocacheCli);
    }
    if (newServices.contains(cas)) {
      newServices.add(userdetails);
      newServices.add(apikey);
      newServices.add(casManagement);
    }
    if (newServices.contains(spatial)) {
      newServices.add(spatialService);
      newServices.add(geoserver);
    }
    if (newServices.contains(pipelines)) {
      newServices.add(spark);
      newServices.add(hadoop);
      // namematching, and sensitive-data-service
    }
    return newServices;
  }

  List<LAServiceDeploy> getServiceDeploysForSomeService(String serviceNameInt) {
    final List<LAServiceDeploy> sds = <LAServiceDeploy>[];
    final List<LAService> serviceSubset =
        services.where((LAService s) => s.nameInt == serviceNameInt).toList();
    for (final LAService s in serviceSubset) {
      sds.addAll(serviceDeploys
          .where((LAServiceDeploy sD) =>
              sD.projectId == id && sD.serviceId == s.id)
          .toList());
    }
    return sds;
  }

  void setServiceDeployRelease(String serviceName, String release) {
    final List<LAServiceDeploy> serviceDeploysForName =
        getServiceDeploysForSomeService(serviceName);
    if (AppUtils.isDev()) {
      if (kDebugMode) {
        debugPrint(
            'Setting ${serviceDeploysForName.length} service deploys for service $serviceName and release $release');
      }
    }
    for (final LAServiceDeploy sd in serviceDeploysForName) {
      sd.softwareVersions[serviceName] = release;
    }
  }

  // Retrieve first sd with some software version setted for some serviceName
  String? getServiceDeployRelease(String serviceName) {
    String? version;
    for (final LAServiceDeploy sd in serviceDeploys) {
      version = sd.softwareVersions[serviceName];
      if (version != null) {
        return version;
      }
    }
    return version;
  }

  // Each serviceDeploy has a Map of software/versions
  // This list can differ from the runtime version of that software depending on
  // the portal status of deployment:
  // 1) at creation time
  // 2) prior to update a service
  // 3) after a deploy/update a service
  Map<String, String> getServiceDeployReleases([bool onlyDocker = false]) {
    final Map<String, String> versions = <String, String>{};
    for (final LAServiceDeploy sd in serviceDeploys.where(
        (LAServiceDeploy sd) =>
            (onlyDocker && sd.type == DeploymentType.dockerSwarm) ||
            !onlyDocker)) {
      versions.addAll(sd.softwareVersions);
    }
    return versions;
  }

  void delete(LAServer serverToDelete) {
    serverServices.remove(serverToDelete.id);
    serviceDeploys = serviceDeploys
        .where((LAServiceDeploy sd) => sd.serverId != serverToDelete.id)
        .toList();
    servers = servers.where((LAServer s) => s.id != serverToDelete.id).toList();
    // Remove serviceDeploy inconsistencies
    serviceDeploys.removeWhere((LAServiceDeploy sd) =>
        servers.firstWhereOrNull((LAServer s) => s.id == sd.serverId) == null);
    // Remove server from others gateways
    final String deletedId = serverToDelete.id;
    for (final LAServer s in servers) {
      if (s.gateways.contains(deletedId)) {
        s.gateways.remove(deletedId);
        upsertServer(s);
      }
    }
    if (!isDockerClusterConfigured()) {
      clusters.clear();
    }
    validateCreation();
  }

  String additionalVariablesDecoded() {
    return additionalVariables.isNotEmpty
        ? utf8.decode(base64.decode(additionalVariables))
        : '';
  }

  List<String> getHostnames(String serviceName) {
    final Set<String> hostnames = <String>{};

    serverServices.forEach((String id, List<String> serviceNames) {
      for (final String currentService in serviceNames) {
        if (serviceName == currentService) {
          final LAServer server =
              servers.firstWhere((LAServer s) => s.id == id);
          hostnames.add(server.name);
        }
      }
    });

    clusterServices.forEach((String id, List<String> serviceNames) {
      for (final String currentService in serviceNames) {
        final List<String> serverCluster =
            getServiceDeploysForSomeService(dockerSwarm)
                .map((LAServiceDeploy sd) => servers
                    .firstWhere((LAServer s) => s.id == sd.serverId)
                    .name)
                .toList();
        serverCluster.sort();
        if (serviceName == currentService) {
          hostnames.addAll(serverCluster);
        }
      }
    });
    return hostnames.toList();
  }

  String get etcHostsVar {
    final List<String> etcHostLines = <String>[];
    final LAProject p = isHub ? parent! : this;
    final List<LAProject> projects = <LAProject>[p, ...p.hubs];
    for (final LAProject current in projects) {
      current.serversWithServices().forEach((LAServer server) {
        final String hostnames = current
            .getServerServicesFull(id: server.id, type: DeploymentType.vm)
            .where((LAService s) =>
                !LAServiceDesc.subServices.contains(s.nameInt) &&
                s.nameInt != biocacheBackend &&
                s.nameInt != pipelines)
            .map((LAService s) => s.url(current.domain))
            .toSet() // to remove dups
            .toList()
            .join(' ');
        etcHostLines.add('      ${server.ip} ${server.name} $hostnames');
      });
    }
    final String etcHost = etcHostLines.join('\n');
    return etcHost;
  }

  String get hostnames {
    final List<String> hostList = <String>[];
    serversWithServices()
        .forEach((LAServer server) => hostList.add(server.name));
    return hostList.join(', ');
  }

  String get sshKeysInUse {
    final List<String> sshKeysInUseList = <String>[];
    serversWithServices().forEach((LAServer server) {
      if (server.sshKey != null) {
        sshKeysInUseList.add("'~/.ssh/${server.sshKey!.name}.pub'");
      }
    });
    // toSet.toList to remove dups
    return sshKeysInUseList.toSet().toList().join(', ');
  }

  bool servicesInDifferentServers(String serviceA, String serviceB) {
    final List<String> serviceAHosts = getHostnames(serviceA);
    final List<String> serviceBHosts = getHostnames(serviceB);
    final List<String> common = List<String>.from(serviceAHosts);
    common.removeWhere((String item) => serviceBHosts.contains(item));
    return const ListEquality<String>().equals(common, serviceAHosts);
  }

  void setMap(LatLng firstPoint, LatLng sndPoint, double zoom) {
    mapBoundsFstPoint =
        LALatLng.from(firstPoint.latitude, firstPoint.longitude);
    mapBoundsSndPoint = LALatLng.from(sndPoint.latitude, sndPoint.longitude);
    mapZoom = zoom;
  }

  void serviceInUse(String serviceNameInt, bool use) {
    final LAService service = getService(serviceNameInt);
    service.use = use;
    updateService(service);

    final List<LAServiceDesc> childServices =
        LAServiceDesc.childServices(serviceNameInt);

    final Iterable<LAServiceDesc> depends = LAServiceDesc.list(isHub).where(
        (LAServiceDesc curSer) =>
            curSer.depends != null && curSer.depends!.toS() == serviceNameInt);
    if (!use) {
      // Remove
      serverServices.forEach((String id, List<String> services) {
        services.remove(serviceNameInt);
      });
      clusterServices.forEach((String id, List<String> services) {
        services.remove(serviceNameInt);
      });
      serviceDeploys.removeWhere((LAServiceDeploy sd) =>
          sd.projectId == id && sd.serviceId == service.id);
      // Disable dependents
      for (final LAServiceDesc serviceDesc in depends) {
        serviceInUse(serviceDesc.nameInt, use);
      }
    } else {
      for (final LAServiceDesc serviceDesc in depends) {
        if (!serviceDesc.optional) {
          serviceInUse(serviceDesc.nameInt, use);
        }
      }
    }
    for (final LAServiceDesc child in childServices) {
      serviceInUse(child.nameInt, use);
    }
  }

  // In Hubs we use the portal etcHost
  Map<String, dynamic> toGeneratorJson({String? etcHosts}) {
    // Warn: new vars should be added also to transform.js map in backend
    final Map<String, dynamic> conf = <String, dynamic>{
      'LA_id': id,
      'LA_pkg_name': dirName,
      'LA_project_name': longName,
      'LA_project_shortname': shortName,
      'LA_domain': domain,
      'LA_enable_ssl': useSSL,
      'LA_use_git': true,
      'LA_theme': theme,
      'LA_etc_hosts': etcHosts ?? etcHostsVar,
      'LA_ssh_keys': sshKeysInUse,
      'LA_hostnames': hostnames,
      'LA_generate_branding': true,
      'LA_is_hub': isHub
    };
    conf.addAll(MapUtils.toInvVariables(mapBoundsFstPoint, mapBoundsSndPoint));

    // pipelines vars
    if (!isHub) {
      final LAServer? masterServer = getPipelinesMaster();
      if (masterServer != null && masterServer.sshKey != null) {
        masterPipelinesServer = masterServer;
        conf['${LAVariable.varInvPrefix}pipelines_ssh_key'] =
            masterServer.sshKey!.name;
      }
    }

    final List<String> ips = List<String>.empty(growable: true);
    serversWithServices().forEach((LAServer server) => ips.add(server.ip));
    conf['LA_server_ips'] = ips.join(',');

    if (additionalVariables != '') {
      conf['LA_additionalVariables'] = additionalVariables;
    }
    for (final LAService service in services) {
      conf['LA_use_${service.nameInt}'] = service.use;
      conf['LA_${service.nameInt}_uses_subdomain'] = service.usesSubdomain;
      conf['LA_${service.nameInt}_hostname'] =
          getHostnames(service.nameInt).isNotEmpty
              ? getHostnames(service.nameInt).join(', ')
              : '';
      conf['LA_${service.nameInt}_url'] = service.url(domain);
      conf['LA_${service.nameInt}_path'] = service.path;
    }
    // Docker related vars
    if (isDockerClusterConfigured()) {
      final Set<String> nginxDockerInternalAliases = <String>{};
      clusterServices.forEach((String id, List<String> serviceNames) {
        for (final String currentService in serviceNames) {
          final LAService s = getService(currentService);
          nginxDockerInternalAliases.add(s.url(domain));
        }
      });
      conf['LA_nginx_docker_internal_aliases'] =
          nginxDockerInternalAliases.toList();
      final List<String> dockerSolrHosts = dockerServers();
      conf['LA_docker_solr_hosts'] = dockerSolrHosts;
    }

    // Release versions
    final Map<String, List<dynamic>> swVersions = <String, List<dynamic>>{};
    for (final LAServiceDeploy sd in serviceDeploys) {
      sd.softwareVersions.forEach((String sw, String value) {
        if (LAServiceDesc.swToAnsibleVars[sw] != null) {
          // LAServer server = servers.firstWhere((s) => s.id == sd.serverId);
          swVersions[sw] = <dynamic>[LAServiceDesc.swToAnsibleVars[sw], value];

          if (sw == 'collectory') {
            conf['LA_collectory_version_ge_3'] =
                vc('>= 3.0.0').allows(v(value));
          }
        }
      });
    }
    conf['LA_software_versions'] = swVersions.values.toList()
      ..sort((List<dynamic> a, List<dynamic> b) =>
          compareAsciiUpperCase(a[0] as String, b[0] as String));

    for (final LAVariable variable in variables) {
      conf['${LAVariable.varInvPrefix}${variable.nameInt}'] = variable.value;
    }

    // Hubs
    if (hubs.isNotEmpty) {
      final List<Map<String, dynamic>> hubsConf = <Map<String, dynamic>>[];
      for (final LAProject hub in hubs) {
        hubsConf.add(
            hub.toGeneratorJson(etcHosts: conf['LA_etc_hosts'] as String?));
      }
      conf['LA_hubs'] = hubsConf;
    }
    return conf;
  }

  List<String> dockerServers() {
    final List<String> dList = getServiceDeploysForSomeService(dockerSwarm)
        .map((LAServiceDeploy sd) =>
            servers.firstWhere((LAServer s) => s.id == sd.serverId).name)
        .toSet()
        .toList();
    dList.sort();
    return dList;
  }

  List<String> getServerServices({required String serverId}) {
    if (!serverServices.containsKey(serverId)) {
      serverServices[serverId] = List<String>.empty(growable: true);
    }
    return serverServices[serverId]!;
  }

  List<String> getClusterServices({required String clusterId}) {
    if (!clusterServices.containsKey(clusterId)) {
      clusterServices[clusterId] = List<String>.empty(growable: true);
    }
    return clusterServices[clusterId]!;
  }

  List<LAService> getServerServicesFull(
      {required String id, required DeploymentType type}) {
    final List<String> listS = type == DeploymentType.vm
        ? getServerServices(serverId: id)
        : getClusterServices(clusterId: id);
    return services.where((LAService s) => listS.contains(s.nameInt)).toList();
  }

  Map<String, List<LAService>> getServerServicesAssignable(
      DeploymentType type) {
    final List<String> canBeRedeployed = getServicesAssigned()
        .where((String s) =>
            LAServiceDesc.get(s).allowMultipleDeploys &&
            LAServiceDesc.get(s).parentService == null)
        .toList();
    final List<String> notAssigned = servicesNotAssigned();
    final List<LAService> eligible = services
        .where((LAService s) =>
            (canBeRedeployed.contains(s.nameInt) ||
                notAssigned.contains(s.nameInt)) &&
            (type == DeploymentType.vm ||
                (type == DeploymentType.dockerSwarm &&
                    LAServiceDesc.listDockerCapableS.contains(s.nameInt))))
        .toList();
    final Map<String, List<LAService>> results = <String, List<LAService>>{};
    if (type == DeploymentType.vm) {
      for (final LAServer server in servers) {
        final List<String> currentServerServicesIds =
            getServerServicesFull(id: server.id, type: type)
                .map((LAService service) => service.id)
                .toList();
        results[server.id] = eligible
            .where((LAService sv) => !currentServerServicesIds.contains(sv.id))
            .toList();
      }
    } else {
      for (final LACluster cluster in clusters) {
        final List<String> currentClusterServicesIds =
            getServerServicesFull(id: cluster.id, type: type)
                .map((LAService service) => service.id)
                .toList();
        results[cluster.id] = eligible
            .where((LAService sv) => !currentClusterServicesIds.contains(sv.id))
            .toList();
      }
    }

    return results;
  }

  Map<String, List<String>> getServerServicesForTest() {
    return serverServices;
  }

  String suggestDirName() {
    return StringUtils.suggestDirName(shortName: shortName, id: id);
  }

  List<ProdServiceDesc> get prodServices {
    final List<ProdServiceDesc> allServices = <ProdServiceDesc>[];
    final Map<String, LAServiceDepsDesc> depsDesc = getDeps();
    getServicesNameListInUse().forEach((String nameInt) {
      final LAServiceDesc desc = LAServiceDesc.get(nameInt);
      final LAService service = getService(nameInt);
      String url = serviceFullUrl(desc, service);
      final String name = StringUtils.capitalize(desc.name);
      final String? help = nameInt == solr || nameInt == solrcloud
          ? 'Secure-your-LA-infrastructure#protect-you-solr-admin-interface'
          : nameInt == pipelines || nameInt == zookeeper
              ? 'Accessing-your-internal-web-interfaces'
              : null;
      final String tooltip = name != 'Index'
          ? serviceTooltip(name)
          : 'This is protected by default, see our wiki for more info';
      if (nameInt == solr) {
        url =
            "${StringUtils.removeLastSlash(url.replaceFirst("https", "http"))}:8983";
      }
      if (nameInt == cas) {
        url += 'cas';
      }
      final LAServiceDepsDesc? mainDeps = depsDesc[nameInt];
      List<BasicService>? deps;
      if (mainDeps != null) {
        deps = getDeps()[nameInt]!.serviceDepends;
      }
      final List<String> hostnames = getHostnames(nameInt);
      final List<LAServiceDeploy> sd = serviceDeploys
          .where((LAServiceDeploy sd) => sd.serviceId == service.id)
          .toList();
      final ServiceStatus st =
          sd.isNotEmpty ? sd[0].status : ServiceStatus.unknown;
      // if (nameInt != cas) {
      allServices.add(ProdServiceDesc(
          name: name,
          nameInt: nameInt,
          deps: deps,
          tooltip: tooltip,
          subtitle: hostnames.join(', '),
          serviceDeploys: sd,
          icon: desc.icon,
          url: url,
          admin: desc.admin,
          alaAdmin: desc.alaAdmin,
          status: st,
          help: help));
    });
    return allServices;
  }

  String serviceFullUrl(LAServiceDesc desc, LAService service) {
    final String url = desc.isSubService
        ? getServiceE(desc.parentService!).fullUrl(useSSL, domain) +
            desc.path.replaceFirst(RegExp(r'^/'), '')
        : service.fullUrl(useSSL, domain);
    return url;
  }

  String serviceTooltip(String name) => 'Open the $name service';

  HostsServicesChecks _getHostServicesChecks(List<ProdServiceDesc> prodServices,
      [bool full = true]) {
    final HostsServicesChecks hostsChecks = HostsServicesChecks();
    final List<String> serversIds =
        serversWithServices().map((LAServer s) => s.id).toList();
    for (final ProdServiceDesc service in prodServices) {
      for (final LAServiceDeploy sd in service.serviceDeploys) {
        hostsChecks.setUrls(
            sd, service.urls, service.nameInt, serversIds, full);
        try {
          final LAServer server =
              servers.firstWhere((LAServer s) => s.id == sd.serverId);
          hostsChecks.add(
              sd, server, service.deps, service.nameInt, serversIds, full);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error in _getHostServicesChecks: $e with SD: $sd');
          }
        }
      }
    }
    return hostsChecks;
  }

  Tuple2<List<ProdServiceDesc>, HostsServicesChecks> serverServicesToMonitor() {
    final List<ProdServiceDesc> services = prodServices;
    if (servicesToMonitor == null ||
        !const ListEquality<ProdServiceDesc>()
            .equals(servicesToMonitor!.item1, prodServices)) {
      final HostsServicesChecks checks =
          _getHostServicesChecks(services, false);
      servicesToMonitor =
          Tuple2<List<ProdServiceDesc>, HostsServicesChecks>(services, checks);
    }
    return servicesToMonitor!;
  }

  Map<String, LAServiceDepsDesc> getDeps() =>
      LAServiceDepsDesc.getDeps(alaInstallRelease);

  @override
  LAProject fromJson(Map<String, dynamic> json) => LAProject.fromJson(json);

  void updateService(LAService service) {
    final String serviceNameInt = service.nameInt;
    final int serviceInUse = getServicesNameListInUse().length;
    services = services
        .map((LAService s) => s.nameInt == serviceNameInt ? service : s)
        .toList();
    assert(serviceInUse == getServicesNameListInUse().length);
  }

  static List<LAProject> import({required String yoRcJson}) {
    final List<LAProject> list = <LAProject>[];
    final Map<String, dynamic> yoRc =
        json.decode(yoRcJson)['generator-living-atlas']['promptValues']
            as Map<String, dynamic>;
    final LAProject p = LAProject.fromObject(yoRc);
    final List<LAProject> hubs = _importHubs(yoRc, p);
    p.hubs = hubs;
    list.add(p);
    list.addAll(hubs);
    return list;
  }

  static Future<List<LAProject>> importTemplates(String file) async {
    // https://flutter.dev/docs/development/ui/assets-and-images#loading-text-assets

    final List<LAProject> list = <LAProject>[];
    final String templatesS = await rootBundle.loadString(file);
    final List<dynamic> projectsJ = jsonDecode(templatesS) as List<dynamic>;

    for (final dynamic genJson in projectsJ) {
      final Map<String, dynamic> pJson = genJson['generator-living-atlas']
          ['promptValues'] as Map<String, dynamic>;
      pJson['LA_id'] = null;
      final LAProject p = LAProject.fromObject(pJson);
      final List<LAProject> hubs = _importHubs(pJson, p);
      p.hubs = hubs;
      list.add(p);
      list.addAll(hubs);
    }
    return list;
  }

  static List<LAProject> _importHubs(
      Map<String, dynamic> pJson, LAProject parent) {
    final List<LAProject> hubs = <LAProject>[];
    if (pJson['LA_hubs'] != null) {
      for (final dynamic hubJson in pJson['LA_hubs'] as List<dynamic>) {
        final LAProject hub =
            LAProject.fromObject(hubJson as Map<String, dynamic>);
        hub.isHub = true;
        hub.parent = parent;
        hubs.add(hub);
      }
    }
    return hubs;
  }

  bool get inProduction => status == LAProjectStatus.inProduction;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAProject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          longName == other.longName &&
          shortName == other.shortName &&
          dirName == other.dirName &&
          domain == other.domain &&
          useSSL == other.useSSL &&
          const DeepCollectionEquality.unordered()
              .equals(serverServices, other.serverServices) &&
          additionalVariables == other.additionalVariables &&
          isCreated == other.isCreated &&
          isHub == other.isHub &&
          fstDeployed == other.fstDeployed &&
          advancedEdit == other.advancedEdit &&
          advancedTune == other.advancedTune &&
          status == other.status &&
          alaInstallRelease == other.alaInstallRelease &&
          generatorRelease == other.generatorRelease &&
          mapBoundsFstPoint == other.mapBoundsFstPoint &&
          mapBoundsSndPoint == other.mapBoundsSndPoint &&
          lastCmdEntry == other.lastCmdEntry &&
          lastCmdDetails == other.lastCmdDetails &&
          parent == other.parent &&
          createdAt == other.createdAt &&
          const ListEquality<CmdHistoryEntry>()
              .equals(cmdHistoryEntries, other.cmdHistoryEntries) &&
          const ListEquality<LAServer>().equals(servers, other.servers) &&
          const ListEquality<LAService>().equals(services, other.services) &&
          const ListEquality<LAVariable>().equals(variables, other.variables) &&
          const ListEquality<LAServiceDeploy>()
              .equals(serviceDeploys, other.serviceDeploys) &&
          const ListEquality<LAProject>().equals(hubs, other.hubs) &&
          const DeepCollectionEquality.unordered()
              .equals(checkResults, other.checkResults) &&
          const DeepCollectionEquality.unordered()
              .equals(runningVersions, other.runningVersions) &&
          mapZoom == other.mapZoom;

  @override
  int get hashCode =>
      id.hashCode ^
      longName.hashCode ^
      shortName.hashCode ^
      dirName.hashCode ^
      domain.hashCode ^
      useSSL.hashCode ^
      const DeepCollectionEquality.unordered().hash(serverServices) ^
      isCreated.hashCode ^
      isHub.hashCode ^
      fstDeployed.hashCode ^
      advancedEdit.hashCode ^
      advancedTune.hashCode ^
      additionalVariables.hashCode ^
      status.hashCode ^
      alaInstallRelease.hashCode ^
      generatorRelease.hashCode ^
      mapBoundsFstPoint.hashCode ^
      mapBoundsSndPoint.hashCode ^
      lastCmdDetails.hashCode ^
      parent.hashCode ^
      const ListEquality<CmdHistoryEntry>().hash(cmdHistoryEntries) ^
      const ListEquality<LAServer>().hash(servers) ^
      const ListEquality<LAService>().hash(services) ^
      const ListEquality<LAVariable>().hash(variables) ^
      const ListEquality<LAServiceDeploy>().hash(serviceDeploys) ^
      const DeepCollectionEquality.unordered().hash(checkResults) ^
      const DeepCollectionEquality.unordered().hash(runningVersions) ^
      createdAt.hashCode ^
      mapZoom.hashCode;

  Map<String, String> getServiceDefaultVersions(LAService service) {
    final Map<String, String> defVersions = <String, String>{};
    final String nameInt = service.nameInt;
    if (alaInstallRelease != null) {
      defVersions[nameInt] = _setDefSwVersion(nameInt);
    }
    defVersions.removeWhere((String key, String value) => value == '');
    return defVersions;
  }

  String _setDefSwVersion(String nameInt) {
    final String? version = (alaInstallIsNotTagged(alaInstallRelease!)
            ? DefaultVersions.map.entries.first
            : DefaultVersions.map.entries.firstWhere(
                (MapEntry<VersionConstraint, Map<String, String>> e) =>
                    e.key.allows(v(alaInstallRelease!))))
        .value[nameInt];
    return version ?? '';
  }

  Map<String, dynamic> getServiceDetailsForVersionCheck() {
    final Map<String, dynamic> versions = <String, dynamic>{};
    for (final LAServiceDeploy sd in serviceDeploys) {
      final LAService service = services
          .firstWhere((LAService s) => s.id == sd.serviceId, orElse: () {
        final String msg = 'Missing serviceId ${sd.serviceId}';
        if (kDebugMode) {
          debugPrint(msg);
        }
        throw Exception(msg);
      });
      final String serviceName = service.nameInt;
      final LAServiceDesc desc = LAServiceDesc.get(serviceName);
      if (!desc.withoutUrl) {
        versions[serviceName] = <String, String>{
          'server': sd.serviceId,
          'url': serviceName == cas
              ? '${serviceFullUrl(desc, service)}/cas/'
              : serviceFullUrl(desc, service)
        };
      }
    }
    return versions;
  }

  LAServer? getServerByName(String name) {
    return servers.firstWhereOrNull((LAServer s) => s.name == name);
  }

  LAServer? getServerById(String id) {
    return servers.firstWhereOrNull((LAServer s) => s.id == id);
  }

  bool get isPipelinesInUse => !isHub && getService(pipelines).use;

  bool get isDockerEnabled => !isHub && getService(dockerSwarm).use;

  LAServer? getPipelinesMaster() {
    if (isPipelinesInUse && getVariableOrNull('pipelines_master') != null) {
      // && getServiceDeploysForSomeService(pipelines).length > 0) {
      final String? masterName =
          getVariableOrNull('pipelines_master')!.value as String?;
      if (masterName != null) {
        masterPipelinesServer = getServerByName(masterName);
        return masterPipelinesServer;
      }
    }
    return null;
  }

  List<String> getIncompatibilities() {
    final List<String> allIncompatibilities = <String>[];
    for (final List<String> serverServices in serverServices.values) {
      if (serverServices.isNotEmpty) {
        final Set<String> incompatible = <String>{};
        for (final String first in serverServices) {
          for (final String second in serverServices) {
            // debugPrint("$first compatible with $second");
            if (first != second &&
                !LAServiceDesc.get(first).isCompatibleWith(
                    alaInstallRelease, LAServiceDesc.get(second))) {
              incompatible.addAll(<String>{first, second});
            }
          }
        }
        if (incompatible.isNotEmpty) {
          allIncompatibilities.add(incompatible.length == 2
              ? "Services ${incompatible.join(' and ')} can't be installed together"
              : "Services ${incompatible.join(', ')} can't be installed together");
        }
      }
    }
    return allIncompatibilities;
  }

  bool get showSoftwareVersions => !isHub && allServicesAssigned();

  bool get showToolkitDeps => !isHub;

  void _addDockerClusterIfNotExists() {
    if (clusters.isEmpty) {
      clusters.add(LACluster(
        id: ObjectId().toString(),
        projectId: id,
      ));
    }
  }
}
