import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/isJsonSerializable.dart';
import 'package:la_toolkit/models/laLatLng.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/prodServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/mapUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:objectid/objectid.dart';
import 'package:tuple/tuple.dart';

import 'basicService.dart';
import 'cmdHistoryDetails.dart';
import 'defaultVersions.dart';
import 'hostServicesChecks.dart';
import 'laServer.dart';
import 'laService.dart';
import 'laServiceDeploy.dart';
import 'laServiceDepsDesc.dart';
import 'laServiceName.dart';
import 'laVariable.dart';
import 'laVariableDesc.dart';
import 'versionUtils.dart';

part 'laProject.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAProject implements IsJsonSerializable<LAProject> {
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
  @JsonKey(ignore: true)
  Map<String, dynamic> checkResults;

  // Relations -----
  List<LAServer> servers;
  List<LAService> services;

  // Mapped by server.id - serviceNames
  Map<String, List<String>> serverServices;
  List<CmdHistoryEntry> cmdHistoryEntries;
  List<LAServiceDeploy> serviceDeploys;
  List<LAVariable> variables;
  List<LAProject> hubs;
  @JsonKey(ignore: true)
  LAProject? parent;
  @JsonKey(ignore: true)
  Map<String, String> runningVersions;

  // Logs history -----
  CmdHistoryEntry? lastCmdEntry;
  @JsonKey(ignore: true)
  CmdHistoryDetails? lastCmdDetails;
  @JsonKey(ignore: true)
  Tuple2<List<ProdServiceDesc>, HostsServicesChecks>? servicesToMonitor;

  int? clientMigration;

  DateTime? lastSwCheck;

  @JsonKey(ignore: true)
  LAServer? masterPipelinesServer;

  LAProject(
      {String? id,
      this.longName = "",
      this.shortName = "",
      String? domain,
      this.dirName = "",
      this.useSSL = true,
      this.isCreated = false,
      this.isHub = false,
      bool? fstDeployed,
      this.additionalVariables = "",
      this.status = LAProjectStatus.created,
      this.alaInstallRelease,
      this.generatorRelease,
      LALatLng? mapBoundsFstPoint,
      LALatLng? mapBoundsSndPoint,
      this.theme = "clean",
      this.mapZoom,
      this.lastCmdEntry,
      this.lastCmdDetails,
      bool? advancedEdit,
      bool? advancedTune,
      List<LAVariable>? variables,
      List<CmdHistoryEntry>? cmdHistoryEntries,
      List<LAServer>? servers,
      List<LAService>? services,
      List<LAServiceDeploy>? serviceDeploys,
      this.parent,
      List<LAProject>? hubs,
      int? createdAt,
      Map<String, List<String>>? serverServices,
      Map<String, dynamic>? checkResults,
      Map<String, String>? runningVersions})
      : id = id ?? ObjectId().toString(),
        domain = domain ?? (isHub ? 'somehubname.' + parent!.domain : ''),
        servers = servers ?? [],
        services = services ?? getInitialServices(isHub),
        serviceDeploys = serviceDeploys ?? [],
        variables = variables ?? [],
        hubs = hubs ?? [],
        createdAt = createdAt ?? DateTime.now().microsecondsSinceEpoch,
        checkResults = checkResults ?? {},
        serverServices = serverServices ?? {},
        runningVersions = runningVersions ?? {},
        advancedEdit = advancedEdit ?? false,
        advancedTune = advancedTune ?? false,
        cmdHistoryEntries = cmdHistoryEntries ?? [],
        fstDeployed = fstDeployed ?? false,
        mapBoundsFstPoint = mapBoundsFstPoint ?? LALatLng.from(-44, 112),
        mapBoundsSndPoint = mapBoundsSndPoint ?? LALatLng.from(-9, 154) {
    this.services = this.services.map((s) {
      s.projectId = this.id;
      return s;
    }).toList();
    if ((dirName == null || dirName!.isEmpty) && shortName.isNotEmpty) {
      dirName = suggestDirName();
    }
    // _setDefSwVersions();
    validateCreation();
  }

  int numServers() => servers.length;

  LatLng getCenter() {
    return MapUtils.center(mapBoundsFstPoint, mapBoundsSndPoint);
  }

  bool validateCreation({debug = false}) {
    bool valid = true;
    LAProjectStatus tempStatus = LAProjectStatus.created;
    if (servers.length != serverServices.length) {
      String msgErr =
          'Servers in $longName ($id) are inconsistent (serverServices: ${serverServices.length} servers: ${servers.length}';
      print(msgErr);
      print("servers (${servers.length}): $servers");
      print("serverServices (${serverServices.length}): $serverServices");
      throw (msgErr);
    }

    valid = valid &&
        LARegExp.projectNameRegexp.hasMatch(longName) &&
        LARegExp.shortNameRegexp.hasMatch(shortName) &&
        LARegExp.domainRegexp.hasMatch(domain) &&
        alaInstallRelease != null &&
        generatorRelease != null;
    if (valid) tempStatus = LAProjectStatus.basicDefined;
    if (debug) print("Step 1 valid: ${valid ? 'yes' : 'no'}");

    valid = valid && servers.isNotEmpty;
    if (valid) {
      for (LAServer s in servers) {
        valid = valid && LARegExp.hostnameRegexp.hasMatch(s.name);
      }
    }
    if (debug) print("Step 2 valid: ${valid ? 'yes' : 'no'}");
    // If the previous steps are correct, this is also correct

    valid = valid && allServicesAssignedToServers();
    if (debug) print("Step 3 valid: ${valid ? 'yes' : 'no'}");

    if (valid) {
      for (LAServer s in servers) {
        valid = valid && LARegExp.ip.hasMatch(s.ip);
        valid = valid && s.sshKey != null;
      }
    }
    if (debug) print("Step 4 valid: ${valid ? 'yes' : 'no'}");

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
    if (status.value < tempStatus.value) setProjectStatus(tempStatus);
    if (debug) {
      print(
          "Valid at end: ${valid ? 'yes' : 'no'}, tempStatus: ${status.title}");
    }
    return valid;
  }

  bool allServicesAssignedToServers({debug = false}) {
    List<String> difference = servicesNotAssigned();
    bool ok = difference.isEmpty;

    if (!ok && debug) {
      print(
          "Not the same services in use ${getServicesNameListInUse().length} as assigned to servers ${getServicesAssignedToServers().length}");
      print(
          "Services unassigned: ${getServicesNameListInUse().where((s) => !getServicesAssignedToServers().contains(s)).toList().join(',')}");
    }
    getServicesNameListInUse().forEach((service) {
      ok && getHostnames(service).isNotEmpty;
    });
    return ok;
  }

  List<String> servicesNotAssigned() {
    List<String> difference = getServicesNameListInUse()
        .toSet()
        .difference(getServicesAssignedToServers().toSet())
        .toList();
    return difference;
  }

  List<LAServer> serversWithServices() {
    return servers
        .where((s) =>
            serverServices[s.id] != null && serverServices[s.id]!.isNotEmpty)
        .toList();
  }

  bool allServersWithIPs() {
    bool allReady = true;
    for (LAServer s in servers) {
      allReady = allReady && LARegExp.ip.hasMatch(s.ip);
    }
    return allReady;
  }

  bool allServersWithSshKeys() {
    bool allReady = true;
    for (LAServer s in servers) {
      allReady = allReady && s.sshKey != null;
    }
    return allReady;
  }

  bool allServersWithServicesReady() {
    bool allReady = true && serversWithServices().isNotEmpty;
    serversWithServices().forEach((s) {
      allReady = allReady && s.isReady();
    });
    return allReady;
  }

  bool allServersWithSshReady() {
    bool allReady = true && serversWithServices().isNotEmpty;
    serversWithServices().forEach((s) {
      allReady = allReady && s.isSshReady();
    });
    return allReady;
  }

  bool allServersWithOs(name, version) {
    bool allReady = true;
    serversWithServices().forEach((s) {
      allReady = allReady && s.osName == name;
      allReady = allReady && s.osVersion == version;
    });
    return allReady;
  }

  List<String> getServersNameList() {
    return servers.map((s) => s.name).toList();
  }

  List<String> getServicesNameListInUse() {
    return services
        .where((service) => service.use)
        .map((service) => service.nameInt)
        .toList();
  }

  List<String> getServicesNameListNotInUse() {
    return services
        .where((service) => !service.use)
        .map((service) => service.nameInt)
        .toList();
  }

  List<String> getServicesAssignedToServers() {
    Set<String> selected = {};
    serverServices.forEach((id, service) => selected.addAll(service));
    return selected.toList();
  }

  factory LAProject.fromJson(Map<String, dynamic> json) =>
      _$LAProjectFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LAProjectToJson(this);

  @override
  String toString() {
    String? sToS;
    try {
      sToS = serverServices.entries
          .map((entry) =>
              '${servers.firstWhere((server) => server.id == entry.key).name} has ${entry.value}')
          .toList()
          .join('\n');
    } catch (e) {
      print("Error in toString: $e");
    }
    return '''PROJECT: longName: $longName ($shortName) dirName: $dirName domain: $domain, ssl: $useSSL, hub: $isHub, allWServReady: ___${allServersWithServicesReady()}___
isHub: $isHub isCreated: $isCreated fstDeployed: $fstDeployed validCreated: ${validateCreation()}, status: __${status.title}__, ala-install: $alaInstallRelease, generator: $generatorRelease
lastCmdEntry ${lastCmdEntry != null ? lastCmdEntry!.deployCmd.toString() : 'none'} map: $mapBoundsFstPoint $mapBoundsSndPoint, zoom: $mapZoom
servers (${servers.length}): ${servers.join('| ')}
services (${services.length})
serviceDeploys (${serviceDeploys.length})
servers-services (${serverServices.length}): 
${sToS ?? "Some error in serversToServices"}
services selected (${getServicesAssignedToServers().length}): [${getServicesAssignedToServers().join(', ')}]
services in use (${getServicesNameListInUse().length}): [${getServicesNameListInUse().join(', ')}]
services not in use (${getServicesNameListNotInUse().length}): [${getServicesNameListNotInUse().join(', ')}]
check results length: ${checkResults.length}''';
  }

  //static List<LAService> initialServices = getInitialServices(id);

  static List<LAService> getInitialServices(bool isHub) {
    final List<LAService> services = [];
    List<LAServiceDesc> availableService = LAServiceDesc.list(isHub);
    for (LAServiceDesc desc in availableService) {
      var initialService = LAService.fromDesc(desc, "");
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
          "Trying to get $nameInt service while not present in service lists and hub=$isHub");
    }
    LAService curService =
        services.firstWhere((s) => s.nameInt == nameInt, orElse: () {
      // print("Creating service $nameInt as is not present");
      LAService newService = LAService.fromDesc(LAServiceDesc.get(nameInt), id);
      services.add(newService);
      return newService;
    });
    if (AppUtils.isDev()) {
      assert(services.where((s) => s.nameInt == nameInt).length == 1,
          "Warn, duplicate service $nameInt");
    }
    return curService;
  }

  String get projectName => isHub ? 'Data Hub' : 'Project';

  String get portalName => isHub ? 'hub' : 'portal';

  // ignore: non_constant_identifier_names
  String get PortalName => isHub ? 'Hub' : 'Portal';

  LAVariable getVariable(String nameInt) {
    LAVariable laVar = variables.firstWhere((v) => v.nameInt == nameInt,
        orElse: () => LAVariable.fromDesc(LAVariableDesc.get(nameInt), id));
    return laVar;
  }

  LAVariable? getVariableOrNull(String nameInt) {
    LAVariable? laVar = variables.firstWhereOrNull((v) => v.nameInt == nameInt);
    return laVar;
  }

  Object? getVariableValue(String nameInt) {
    LAVariable variable = getVariable(nameInt);
    bool isEmpty = variable.value == null;
    LAVariableDesc desc = LAVariableDesc.get(nameInt);
    Object? value = variable.value ??= desc.defValue != null
        ? LAVariableDesc.get(nameInt).defValue!(this)
        : null;
    if (isEmpty && value != null) setVariable(desc, value);
    return value;
  }

  bool isStringVariableNullOrEmpty(String nameInt) {
    LAVariable variable = getVariable(nameInt);
    bool isNull = variable.value == null;
    if (isNull) return true;
    return variable.value.toString().isEmpty;
  }

  void setVariable(LAVariableDesc variableDesc, Object value) {
    LAVariable cur = getVariable(variableDesc.nameInt);
    cur.value = value;
    variables.removeWhere((v) => v.nameInt == variableDesc.nameInt);
    variables.add(cur);
  }

  List<String> getServicesNameListInServer(String serverId) {
    return serverServices[serverId] ?? [];
  }

  void upsertServer(LAServer laServer) {
    servers = LAServer.upsertByName(servers, laServer);
    LAServer upsertServer =
        servers.firstWhereOrNull((s) => s.name == laServer.name)!;
    _cleanServerServices(upsertServer);
  }

  void upsertById(LAServer laServer) {
    servers = LAServer.upsertById(servers, laServer);
    _cleanServerServices(laServer);
  }

  void _cleanServerServices(LAServer laServer) {
    if (!serverServices.containsKey(laServer.id)) {
      serverServices[laServer.id] = [];
    }
  }

  void setProjectStatus(LAProjectStatus status) {
    this.status = status;
  }

  void assign(LAServer server, List<String> assignedServices) {
    HashSet<String> newServices = HashSet<String>();
    newServices.addAll(assignedServices);
    // In the same server nameindexer and biocache_cli
    newServices = _addSubServices(newServices);
    serverServices[server.id] = newServices.toList();
    List serviceIds = [];
    for (String sN in newServices) {
      LAService service = getService(sN);
      serviceIds.add(service.id);
      serviceDeploys.firstWhere(
          (sD) =>
              sD.projectId == id &&
              sD.serverId == server.id &&
              sD.serviceId == service.id, orElse: () {
        LAServiceDeploy newSd = LAServiceDeploy(
            projectId: id,
            serverId: server.id,
            serviceId: service.id,
            softwareVersions: getServiceDefaultVersions(service));
        serviceDeploys.add(newSd);
        return newSd;
      });
    }

    // Remove previous deploys
    serviceDeploys.removeWhere((sD) =>
        sD.projectId == id &&
        sD.serverId == server.id &&
        !serviceIds.contains(sD.serviceId));
  }

  void unAssign(LAServer server, String serviceName) {
    HashSet<String> servicesToDel = HashSet<String>();
    servicesToDel.add(serviceName);
    servicesToDel = _addSubServices(servicesToDel);
    if (serverServices[server.id] != null) {
      serverServices[server.id]?.removeWhere((c) => servicesToDel.contains(c));
    }
    for (String sN in servicesToDel) {
      LAService service = getService(sN);
      serviceDeploys.removeWhere((sD) =>
          sD.projectId == id &&
          sD.serverId == server.id &&
          sD.serviceId == service.id);
    }
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

  LAServiceDeploy getServiceDeploysById(String serviceId, String serverId) {
    return serviceDeploys.firstWhere((sD) =>
        sD.projectId == id &&
        sD.serverId == serverId &&
        sD.serviceId == serviceId);
  }

  List<LAServiceDeploy> getServiceDeploysForSomeService(String serviceNameInt) {
    List<LAServiceDeploy> sds = [];
    List<LAService> serviceSubset =
        services.where((s) => s.nameInt == serviceNameInt).toList();
    for (LAService s in serviceSubset) {
      sds.addAll(serviceDeploys
          .where((sD) => sD.projectId == id && sD.serviceId == s.id)
          .toList());
    }
    return sds;
  }

  void setServiceDeployRelease(String serviceName, String release) {
    List<LAServiceDeploy> serviceDeploysForName =
        getServiceDeploysForSomeService(serviceName);
    if (AppUtils.isDev()) {
      print(
          "Setting ${serviceDeploysForName.length} service deploys for service $serviceName and release $release");
    }
    for (LAServiceDeploy sd in serviceDeploysForName) {
      sd.softwareVersions[serviceName] = release;
    }
  }

  // Retrieve first sd with some software version setted for some serviceName
  String? getServiceDeployRelease(String serviceName) {
    String? version;
    for (LAServiceDeploy sd in serviceDeploys) {
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
  Map<String, String> getServiceDeployReleases() {
    Map<String, String> versions = {};
    for (LAServiceDeploy sd in serviceDeploys) {
      versions.addAll(sd.softwareVersions);
    }
    return versions;
  }

  void delete(LAServer serverToDelete) {
    serverServices.remove(serverToDelete.id);
    serviceDeploys =
        serviceDeploys.where((sd) => sd.serverId != serverToDelete.id).toList();
    servers = servers.where((s) => s.id != serverToDelete.id).toList();
    // Remove serviceDeploy inconsistencies
    serviceDeploys.removeWhere(
        (sd) => (servers.firstWhereOrNull((s) => s.id == sd.serverId) == null));
    // Remove server from others gateways
    String deletedId = serverToDelete.id;
    for (LAServer s in servers) {
      if (s.gateways.contains(deletedId)) {
        s.gateways.remove(deletedId);
        upsertServer(s);
      }
    }
    validateCreation();
  }

  String additionalVariablesDecoded() {
    return additionalVariables.isNotEmpty
        ? utf8.decode(base64.decode(additionalVariables))
        : "";
  }

  List<String> getHostnames(String serviceName) {
    List<String> hostnames = [];

    serverServices.forEach((id, serviceNames) {
      for (String currentService in serviceNames) {
        if (serviceName == currentService) {
          LAServer server = servers.firstWhere((s) => s.id == id);
          hostnames.add(server.name);
        }
      }
    });
    return hostnames;
  }

  String get etcHostsVar {
    List<String> etcHostLines = [];
    LAProject p = isHub ? parent! : this;
    List<LAProject> projects = [p, ...p.hubs];
    for (LAProject current in projects) {
      current.serversWithServices().forEach((server) {
        String hostnames = current
            .getServerServicesFull(serverId: server.id)
            .where((s) =>
                !LAServiceDesc.subServices.contains(s.nameInt) &&
                s.nameInt != biocacheBackend &&
                s.nameInt != pipelines)
            .map((s) => s.url(current.domain))
            .toSet() // to remove dups
            .toList()
            .join(' ');
        etcHostLines.add("      ${server.ip} ${server.name} $hostnames");
      });
    }
    String etcHost = etcHostLines.join('\n');
    return etcHost;
  }

  String get hostnames {
    List<String> hostList = [];
    serversWithServices().forEach((server) => hostList.add(server.name));
    return hostList.join(', ');
  }

  String get sshKeysInUse {
    List<String> sshKeysInUseList = [];
    serversWithServices().forEach((server) {
      if (server.sshKey != null) {
        sshKeysInUseList.add("'~/.ssh/${server.sshKey!.name}.pub'");
      }
    });
    // toSet.toList to remove dups
    return sshKeysInUseList.toSet().toList().join(', ');
  }

  bool servicesInDifferentServers(String serviceA, String serviceB) {
    List<String> serviceAHosts = getHostnames(serviceA);
    List<String> serviceBHosts = getHostnames(serviceB);
    List<String> common = List.from(serviceAHosts);
    common.removeWhere((item) => serviceBHosts.contains(item));
    return const ListEquality().equals(common, serviceAHosts);
  }

  void setMap(LatLng firstPoint, LatLng sndPoint, double zoom) {
    mapBoundsFstPoint =
        LALatLng.from(firstPoint.latitude, firstPoint.longitude);
    mapBoundsSndPoint = LALatLng.from(sndPoint.latitude, sndPoint.longitude);
    mapZoom = zoom;
  }

  void serviceInUse(String serviceNameInt, bool use) {
    LAService service = getService(serviceNameInt);
    service.use = use;
    updateService(service);

    List<LAServiceDesc> childServices =
        LAServiceDesc.childServices(serviceNameInt);

    Iterable<LAServiceDesc> depends = LAServiceDesc.list(isHub).where(
        (curSer) => (curSer.depends != null &&
            curSer.depends!.toS() == serviceNameInt));
    if (!use) {
      // Remove
      serverServices.forEach((id, services) {
        services.remove(serviceNameInt);
      });
      serviceDeploys.removeWhere(
          (sd) => sd.projectId == id && sd.serviceId == service.id);
      // Disable dependents
      for (LAServiceDesc serviceDesc in depends) {
        serviceInUse(serviceDesc.nameInt, use);
      }
    } else {
      for (LAServiceDesc serviceDesc in depends) {
        if (!serviceDesc.optional) {
          serviceInUse(serviceDesc.nameInt, use);
        }
      }
    }
    for (LAServiceDesc child in childServices) {
      serviceInUse(child.nameInt, use);
    }
  }

  // In Hubs we use the portal etcHost
  Map<String, dynamic> toGeneratorJson({String? etcHosts}) {
    // Warn: new vars should be added also to transform.js map in backend
    Map<String, dynamic> conf = {
      "LA_id": id,
      "LA_pkg_name": dirName,
      "LA_project_name": longName,
      "LA_project_shortname": shortName,
      "LA_domain": domain,
      "LA_enable_ssl": useSSL,
      "LA_use_git": true,
      "LA_theme": theme,
      "LA_etc_hosts": etcHosts ?? etcHostsVar,
      "LA_ssh_keys": sshKeysInUse,
      "LA_hostnames": hostnames,
      "LA_generate_branding": true,
      "LA_is_hub": isHub
    };
    conf.addAll(MapUtils.toInvVariables(mapBoundsFstPoint, mapBoundsSndPoint));

    // pipelines vars
    if (!isHub) {
      LAServer? masterServer = getPipelinesMaster();
      if (masterServer != null && masterServer.sshKey != null) {
        masterPipelinesServer = masterServer;
        conf["${LAVariable.varInvPrefix}pipelines_ssh_key"] =
            masterServer.sshKey!.name;
      }
    }

    List<String> ips = List.empty(growable: true);
    serversWithServices().forEach((server) => ips.add(server.ip));
    conf["LA_server_ips"] = ips.join(',');

    if (additionalVariables != "") {
      conf["LA_additionalVariables"] = additionalVariables;
    }
    for (LAService service in services) {
      conf["LA_use_${service.nameInt}"] = service.use;
      conf["LA_${service.nameInt}_uses_subdomain"] = service.usesSubdomain;
      conf["LA_${service.nameInt}_hostname"] =
          getHostnames(service.nameInt).isNotEmpty
              ? getHostnames(service.nameInt).join(', ')
              : "";
      conf["LA_${service.nameInt}_url"] = service.url(domain);
      conf["LA_${service.nameInt}_path"] = service.path;
    }

    // Release versions
    Map<String, List<dynamic>> swVersions = {};
    for (LAServiceDeploy sd in serviceDeploys) {
      sd.softwareVersions.forEach((sw, value) {
        if (LAServiceDesc.swToAnsibleVars[sw] != null) {
          // LAServer server = servers.firstWhere((s) => s.id == sd.serverId);
          swVersions[sw] = ([LAServiceDesc.swToAnsibleVars[sw]!, value]);

          if (sw == "collectory") {
            conf["LA_collectory_version_ge_3"] =
                vc(">= 3.0.0").allows(v(value));
          }
        }
      });
    }
    conf["LA_software_versions"] = swVersions.values.toList()
      ..sort((a, b) => compareAsciiUpperCase(a[0], b[0]));

    for (LAVariable variable in variables) {
      conf["${LAVariable.varInvPrefix}${variable.nameInt}"] = variable.value;
    }

    // Hubs
    if (hubs.isNotEmpty) {
      List<Map<String, dynamic>> hubsConf = [];
      for (LAProject hub in hubs) {
        hubsConf.add(hub.toGeneratorJson(etcHosts: conf["LA_etc_hosts"]));
      }
      conf['LA_hubs'] = hubsConf;
    }
    return conf;
  }

  factory LAProject.fromObject(Map<String, dynamic> yoRc, {debug = false}) {
    a(String tag) => yoRc["LA_$tag"];
    LAProject p = LAProject(
        longName: yoRc['LA_project_name'],
        shortName: yoRc['LA_project_shortname'],
        domain: yoRc["LA_domain"],
        useSSL: yoRc["LA_enable_ssl"],
        services: []);
    String domain = p.domain;
    Map<String, List<String>> tempServerServices = {};

    for (LAServiceDesc serviceDesc in LAServiceDesc.list(false)) {
      String n = serviceDesc.nameInt == "cas" ? "CAS" : serviceDesc.nameInt;
      // ala_bie and images was not optional in the past
      bool useIt = !serviceDesc.optional
          ? true
          : a("use_$n") ??
                  n == 'ala_bie' ||
                      n == 'images' ||
                      n == biocacheCli ||
                      n == biocacheBackend ||
                      n == nameindexer
              ? true
              : false;
      LAService service = p.getService(serviceDesc.nameInt);
      p.serviceInUse(serviceDesc.nameInt, useIt);
      n = serviceDesc.nameInt == "species_lists"
          ? "lists"
          : serviceDesc.nameInt;
      bool useSub =
          serviceDesc.forceSubdomain ? true : a("${n}_uses_subdomain") ?? true;
      service.usesSubdomain = useSub;
      if (debug) print("domain: $domain");
      if (debug) {
        print(
            "$n (LA_use_$n): $useIt subdomain (LA_${n}_uses_subdomain): $useSub");
      }
      String invPath = a("${n}_path") ?? '';

      String iniPath = invPath.startsWith("/") ? invPath.substring(1) : invPath;
      String url = a("${n}_url") ?? a("${n}_hostname") ?? '';

      if (useSub) {
        service.suburl = url.replaceFirst('.$domain', '');
        service.iniPath = iniPath;
      } else {
        service.suburl = iniPath;
      }

      String hostnames = a("${n}_hostname") ?? '';

      if (debug) {
        print(
            "$n: url: $url path: '$invPath' initPath: '${service.iniPath}' useSub: $useSub suburl: ${service.suburl} hostname: $hostnames");
      }

      if (useIt && hostnames.isNotEmpty) {
        LAServer s;
        for (String hostname in hostnames.split((RegExp(r"[, ]+")))) {
          if (!p.getServersNameList().contains(hostname)) {
            // id is empty when is new
            s = LAServer(
                id: ObjectId().toString(), name: hostname, projectId: p.id);
            p.upsertServer(s);
          } else {
            s = p.servers.where((c) => c.name == hostname).toList()[0];
          }
          if (!tempServerServices.containsKey(s.id)) {
            tempServerServices[s.id] = List<String>.empty(growable: true);
          }
          tempServerServices[s.id]!.add(serviceDesc.nameInt);
        }
      }
    }
    for (LAServer server in p.servers) {
      if (debug) {
        // print("server ${server.name} has ${tempServerServices[server.id]!}");
      }
      p.assign(server, tempServerServices[server.id]!);
    }

    // Other variables
    LAVariableDesc.map.forEach((String name, LAVariableDesc laVar) {
      var varInGenJson = a("variable_$name");
      if (varInGenJson != null) p.setVariable(laVar, varInGenJson);
    });
    p.additionalVariables = a("additionalVariables") ?? "";
    String? regionsMap = a("regions_map_bounds");
    if (regionsMap != null) {
      List<dynamic> bboxD = json.decode(regionsMap);
      List<String> bbox = bboxD.map((item) => item.toString()).toList();
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
    String? biocacheHostname = a('biocache_backend_hostname');
    if (biocacheHostname != null) {
      p.getService(biocacheBackend).use = true;
      p.getService(pipelines).use = false;
    }
    // TODO mapzoom

    return p;
  }

  List<String> getServerServices({required String serverId}) {
    if (!serverServices.containsKey(serverId)) {
      serverServices[serverId] = List<String>.empty(growable: true);
    }
    return serverServices[serverId]!;
  }

  List<LAService> getServerServicesFull({required String serverId}) {
    List<String> listS = getServerServices(serverId: serverId);
    return services.where((s) => listS.contains(s.nameInt)).toList();
  }

  Map<String, List<LAService>> getServerServicesAssignable() {
    List<String> canBeRedeployed = getServicesAssignedToServers()
        .where((s) =>
            LAServiceDesc.get(s).allowMultipleDeploys &&
            LAServiceDesc.get(s).parentService == null)
        .toList();
    List<String> notAssigned = servicesNotAssigned();
    List<LAService> eligible = services
        .where((s) =>
            canBeRedeployed.contains(s.nameInt) ||
            notAssigned.contains(s.nameInt))
        .toList();
    Map<String, List<LAService>> results = {};
    for (LAServer server in servers) {
      List<String> currentServerServicesIds =
          getServerServicesFull(serverId: server.id)
              .map((service) => service.id)
              .toList();
      results[server.id] = eligible
          .where((sv) => !currentServerServicesIds.contains(sv.id))
          .toList();
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
    List<ProdServiceDesc> allServices = [];
    Map<String, LAServiceDepsDesc> depsDesc = getDeps();
    getServicesNameListInUse().forEach((nameInt) {
      LAServiceDesc desc = LAServiceDesc.get(nameInt);
      LAService service = getService(nameInt);
      String url = serviceFullUrl(desc, service);
      String name = StringUtils.capitalize(desc.name);
      String? help = nameInt == solr || nameInt == solrcloud
          ? "Secure-your-LA-infrastructure#protect-you-solr-admin-interface"
          : nameInt == pipelines || nameInt == zookeeper
              ? "Accessing-your-internal-web-interfaces"
              : null;
      String tooltip = name != "Index"
          ? serviceTooltip(name)
          : "This is protected by default, see our wiki for more info";
      if (nameInt == solr) {
        url =
            "${StringUtils.removeLastSlash(url.replaceFirst("https", "http"))}:8983";
      }
      if (nameInt == cas) {
        url += 'cas';
      }
      LAServiceDepsDesc? mainDeps = depsDesc[nameInt];
      List<BasicService>? deps;
      if (mainDeps != null) deps = getDeps()[nameInt]!.serviceDepends;
      List<String> hostnames = getHostnames(nameInt);
      List<LAServiceDeploy> sd =
          serviceDeploys.where((sd) => sd.serviceId == service.id).toList();
      ServiceStatus st = sd.isNotEmpty ? sd[0].status : ServiceStatus.unknown;
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
    String url = desc.isSubService
        ? getServiceE(desc.parentService!).fullUrl(useSSL, domain) +
            desc.path.replaceFirst(RegExp(r'^/'), '')
        : service.fullUrl(useSSL, domain);
    return url;
  }

  String serviceTooltip(String name) => "Open the $name service";

  HostsServicesChecks _getHostServicesChecks(List<ProdServiceDesc> prodServices,
      [bool full = true]) {
    HostsServicesChecks hostsChecks = HostsServicesChecks();
    List<String> serversIds = serversWithServices().map((s) => s.id).toList();
    for (ProdServiceDesc service in prodServices) {
      for (LAServiceDeploy sd in service.serviceDeploys) {
        hostsChecks.setUrls(
            sd, service.urls, service.nameInt, serversIds, full);
        LAServer server = servers.firstWhere((s) => s.id == sd.serverId);
        hostsChecks.add(
            sd, server, service.deps, service.nameInt, serversIds, full);
      }
    }
    return hostsChecks;
  }

  Tuple2<List<ProdServiceDesc>, HostsServicesChecks> serverServicesToMonitor() {
    List<ProdServiceDesc> services = prodServices;
    if (servicesToMonitor == null ||
        !const ListEquality().equals(servicesToMonitor!.item1, prodServices)) {
      HostsServicesChecks checks = _getHostServicesChecks(services, false);
      servicesToMonitor = Tuple2(services, checks);
    }
    return servicesToMonitor!;
  }

  Map<String, LAServiceDepsDesc> getDeps() =>
      LAServiceDepsDesc.getDeps(alaInstallRelease);

  @override
  LAProject fromJson(Map<String, dynamic> json) => LAProject.fromJson(json);

  void updateService(LAService service) {
    String serviceNameInt = service.nameInt;
    int serviceInUse = getServicesNameListInUse().length;
    services =
        services.map((s) => s.nameInt == serviceNameInt ? service : s).toList();
    assert(serviceInUse == getServicesNameListInUse().length);
  }

  static List<LAProject> import({required String yoRcJson}) {
    List<LAProject> list = [];
    Map<String, dynamic> yoRc =
        json.decode(yoRcJson)["generator-living-atlas"]["promptValues"];
    LAProject p = LAProject.fromObject(yoRc);
    List<LAProject> hubs = _importHubs(yoRc, p);
    p.hubs = hubs;
    list.add(p);
    list.addAll(hubs);
    return list;
  }

  static Future<List<LAProject>> importTemplates(String file) async {
    // https://flutter.dev/docs/development/ui/assets-and-images#loading-text-assets

    List<LAProject> list = [];
    String templatesS = await rootBundle.loadString(file);
    List<dynamic> projectsJ = jsonDecode(templatesS);

    for (Map<String, dynamic> genJson in projectsJ) {
      Map<String, dynamic> pJson =
          genJson['generator-living-atlas']['promptValues'];
      pJson['LA_id'] = null;
      LAProject p = LAProject.fromObject(pJson);
      List<LAProject> hubs = _importHubs(pJson, p);
      p.hubs = hubs;
      list.add(p);
      list.addAll(hubs);
    }
    return list;
  }

  static List<LAProject> _importHubs(
      Map<String, dynamic> pJson, LAProject parent) {
    List<LAProject> hubs = [];
    if (pJson['LA_hubs'] != null) {
      for (Map<String, dynamic> hubJson in pJson['LA_hubs']) {
        LAProject hub = LAProject.fromObject(hubJson);
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
          const ListEquality()
              .equals(cmdHistoryEntries, other.cmdHistoryEntries) &&
          const ListEquality().equals(servers, other.servers) &&
          const ListEquality().equals(services, other.services) &&
          const ListEquality().equals(variables, other.variables) &&
          const ListEquality().equals(serviceDeploys, other.serviceDeploys) &&
          const ListEquality().equals(hubs, other.hubs) &&
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
      const ListEquality().hash(cmdHistoryEntries) ^
      const ListEquality().hash(servers) ^
      const ListEquality().hash(services) ^
      const ListEquality().hash(variables) ^
      const ListEquality().hash(serviceDeploys) ^
      const DeepCollectionEquality.unordered().hash(checkResults) ^
      const DeepCollectionEquality.unordered().hash(runningVersions) ^
      createdAt.hashCode ^
      mapZoom.hashCode;

  Map<String, String> getServiceDefaultVersions(LAService service) {
    Map<String, String> defVersions = {};
    String nameInt = service.nameInt;
    if (alaInstallRelease != null) {
      defVersions[nameInt] = _setDefSwVersion(nameInt);
    }
    defVersions.removeWhere((key, value) => value == "");
    return defVersions;
  }

  String _setDefSwVersion(String nameInt) {
    String? version = (alaInstallIsNotTagged(alaInstallRelease!)
            ? DefaultVersions.map.entries.first
            : DefaultVersions.map.entries
                .firstWhere((e) => e.key.allows(v(alaInstallRelease!))))
        .value[nameInt];
    return version ?? "";
  }

  Map<String, dynamic> getServiceDetailsForVersionCheck() {
    Map<String, dynamic> versions = {};
    for (LAServiceDeploy sd in serviceDeploys) {
      LAService service =
          services.firstWhere((s) => s.id == sd.serviceId, orElse: () {
        String msg = 'Missing serviceId ${sd.serviceId}';
        print(msg);
        throw Exception(msg);
      });
      String serviceName = service.nameInt;
      LAServiceDesc desc = LAServiceDesc.get(serviceName);
      if (!desc.withoutUrl) {
        versions[serviceName] = {
          "server": sd.serviceId,
          "url": serviceName == cas
              ? serviceFullUrl(desc, service) + '/cas/'
              : serviceFullUrl(desc, service)
        };
      }
    }
    return versions;
  }

  LAServer? getServerByName(String name) {
    return servers.firstWhereOrNull((LAServer s) => s.name == name);
  }

  bool get isPipelinesInUse => !isHub && getService(pipelines).use;

  LAServer? getPipelinesMaster() {
    if (isPipelinesInUse && getVariableOrNull("pipelines_master") != null) {
      // && getServiceDeploysForSomeService(pipelines).length > 0) {
      String? masterName =
          getVariableOrNull("pipelines_master")!.value as String?;
      if (masterName != null) {
        masterPipelinesServer = getServerByName(masterName);
        return masterPipelinesServer;
      }
    }
    return null;
  }

  List<String> getIncompatibilities() {
    List<String> allIncompatibilities = [];
    for (var serverServices in serverServices.values) {
      if (serverServices.isNotEmpty) {
        Set<String> incompatible = {};
        for (var first in serverServices) {
          for (var second in serverServices) {
            // print("$first compatible with $second");
            if (first != second &&
                !LAServiceDesc.get(first).isCompatibleWith(
                    alaInstallRelease, LAServiceDesc.get(second))) {
              incompatible.addAll({first, second});
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

  bool get showSoftwareVersions => !isHub && allServicesAssignedToServers();

  bool get showToolkitDeps => !isHub;
}
