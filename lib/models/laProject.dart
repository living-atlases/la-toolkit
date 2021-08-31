import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/isJsonSerializable.dart';
import 'package:la_toolkit/models/laLatLng.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/laSubService.dart';
import 'package:la_toolkit/models/prodServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/casUtils.dart';
import 'package:la_toolkit/utils/mapUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:latlong2/latlong.dart';
import 'package:objectid/objectid.dart';
import 'package:tuple/tuple.dart';

import 'basicService.dart';
import 'cmdHistoryDetails.dart';
import 'hostServicesChecks.dart';
import 'laServer.dart';
import 'laService.dart';
import 'laServiceDeploy.dart';
import 'laServiceDepsDesc.dart';
import 'laVariable.dart';
import 'laVariableDesc.dart';

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
  // Mapped by server.id
  Map<String, List<String>> serverServices;
  List<CmdHistoryEntry> cmdHistoryEntries;
  List<LAServiceDeploy> serviceDeploys;
  List<LAVariable> variables;
  List<LAProject> hubs;
  @JsonKey(ignore: true)
  LAProject? parent;

  // Logs history -----
  CmdHistoryEntry? lastCmdEntry;
  @JsonKey(ignore: true)
  CmdHistoryDetails? lastCmdDetails;
  @JsonKey(ignore: true)
  Tuple2<List<ProdServiceDesc>, HostsServicesChecks>? servicesToMonitor;

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
      Map<String, dynamic>? checkResults})
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
    validateCreation();
  }

  init() async {
    if (!isHub) {
      // Try to generate default CAS keys
      String pac4jSignKey = await CASUtils.gen512CasKey();
      String pac4jEncKey = await CASUtils.gen256CasKey();
      String webflowSignKey = await CASUtils.gen512CasKey();
      String webflowEncKey = await CASUtils.gen128CasKey();
      setVariable(LAVariableDesc.get("pac4j_cookie_signing_key"), pac4jSignKey);
      setVariable(
          LAVariableDesc.get("pac4j_cookie_encryption_key"), pac4jEncKey);
      setVariable(
          LAVariableDesc.get("cas_webflow_signing_key"), webflowSignKey);
      setVariable(
          LAVariableDesc.get("cas_webflow_encryption_key"), webflowEncKey);
    }
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
    bool ok = getServicesNameListInUse().isNotEmpty &&
        getServicesNameListInUse().length ==
            getServicesAssignedToServers().length;
    if (!ok && debug) {
      print(
          "Not the same services in use ${getServicesNameListInUse().length} as assigned to servers ${getServicesAssignedToServers().length}");
      print(
          "Services unassigned: ${getServicesNameListInUse().where((s) => !getServicesAssignedToServers().contains(s)).toList().join(',')}");
    }
    getServicesNameListInUse().forEach((service) {
      ok && getHostname(service).isNotEmpty;
    });
    return ok;
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
    List<String> selected = [];
    serverServices.forEach((id, service) => selected.addAll(service));
    return selected;
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
      services.add(LAService.fromDesc(desc, ""));
    }
    return services;
  }

  LAService getServiceE(LAServiceName nameInt) {
    return getService(nameInt.toS());
  }

  LAService getService(String nameInt) {
    LAService curService =
        services.firstWhere((s) => s.nameInt == nameInt, orElse: () {
      LAService newService = LAService.fromDesc(LAServiceDesc.get(nameInt), id);
      services.add(newService);
      return newService;
    });
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

  void setVariable(LAVariableDesc variableDesc, Object value) {
    LAVariable cur = getVariable(variableDesc.nameInt);
    cur.value = value;
    variables.removeWhere((v) => v.nameInt == variableDesc.nameInt);
    variables.add(cur);
  }

  List<String> getServicesNameListInServer(String serverName) {
    return serverServices[serverName] ?? [];
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
    if (newServices.contains(LAServiceName.biocache_backend.toS())) {
      newServices.add(LAServiceName.nameindexer.toS());
      newServices.add(LAServiceName.biocache_cli.toS());
    }
    serverServices[server.id] = newServices.toList();
    List serviceIds = [];
    for (String sN in newServices) {
      LAService service = services.firstWhere((s) => s.nameInt == sN);
      serviceIds.add(service.id);
      serviceDeploys.firstWhere(
          (sD) =>
              sD.projectId == id &&
              sD.serverId == server.id &&
              sD.serviceId == service.id, orElse: () {
        LAServiceDeploy newSd = LAServiceDeploy(
            projectId: id, serverId: server.id, serviceId: service.id);
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

  void delete(LAServer serverToDelete) {
    /* print(servers.length);
    print(serviceDeploys.length);
    print(serverServices.length); */
    serverServices.remove(serverToDelete.id);
    serviceDeploys =
        serviceDeploys.where((sd) => sd.serverId != serverToDelete.id).toList();
    servers = servers.where((s) => s.id != serverToDelete.id).toList();
    // Remove serviceDeploy inconsistencies
    serviceDeploys.removeWhere(
        (sd) => (servers.firstWhereOrNull((s) => s.id == sd.serverId) == null));
    /* print(servers.length);
    print(serviceDeploys.length);
    print(serverServices.length);
    validateCreation(debug: true); */
  }

  String additionalVariablesDecoded() {
    return additionalVariables.isNotEmpty
        ? utf8.decode(base64.decode(additionalVariables))
        : "";
  }

  List<String> getHostname(String service) {
    List<String> hostnames = [];

    serverServices.forEach((id, services) {
      for (String currentService in services) {
        if (service == currentService) {
          LAServer server = servers.firstWhere((s) => s.id == id);
          hostnames.add(server.name);
        }
      }
    });
    return hostnames;
  }

  String get etcHostsVar {
    List<String> etcHostLines = [];
    serversWithServices().forEach((server) {
      String hostnames = getServerServicesFull(serverId: server.id)
          .where((s) =>
              s.nameInt != LAServiceName.biocache_cli.toS() &&
              s.nameInt != LAServiceName.biocache_backend.toS() &&
              s.nameInt != LAServiceName.nameindexer.toS())
          .map((s) => s.url(domain))
          .toList()
          .join(' ');
      etcHostLines.add("      ${server.ip} ${server.name} $hostnames");
    });
    return etcHostLines.join('\n');
  }

  String get hostnames {
    List<String> hostList = [];
    serversWithServices().forEach((server) => hostList.add(server.name));
    return hostList.join('|');
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

  bool collectoryAndBiocacheDifferentServers() {
    List<String> colHosts = getHostname(LAServiceName.collectory.toS());
    List<String> biocacheHubHosts = getHostname(LAServiceName.ala_hub.toS());
    List<String> common = List.from(colHosts);
    common.removeWhere((item) => biocacheHubHosts.contains(item));
    return const ListEquality().equals(common, colHosts);
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
  }

  Map<String, dynamic> toGeneratorJson() {
    Map<String, dynamic> conf = {
      "LA_id": id,
      "LA_pkg_name": dirName,
      "LA_project_name": longName,
      "LA_project_shortname": shortName,
      "LA_domain": domain,
      "LA_enable_ssl": useSSL,
      "LA_use_git": true,
      "LA_theme": theme,
      "LA_etc_hosts": etcHostsVar,
      "LA_ssh_keys": sshKeysInUse,
      "LA_hostnames": hostnames,
      "LA_generate_branding": true,
      "LA_is_hub": isHub
    };
    conf.addAll(MapUtils.toInvVariables(mapBoundsFstPoint, mapBoundsSndPoint));

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
          getHostname(service.nameInt).isNotEmpty
              ? getHostname(service.nameInt)[0]
              : "";
      conf["LA_${service.nameInt}_url"] = service.url(domain);
      conf["LA_${service.nameInt}_path"] = service.path;
    }

    for (LAVariable variable in variables) {
      conf["LA_variable_${variable.nameInt}"] = variable.value;
    }

    // Hubs
    if (hubs.isNotEmpty) {
      List<Map<String, dynamic>> hubsConf = [];
      for (LAProject hub in hubs) {
        hubsConf.add(hub.toGeneratorJson());
      }
      conf['LA_hubs'] = hubsConf;
    }
    return conf;
  }

  factory LAProject.import({required String yoRcJson}) {
    Map<String, dynamic> yoRc =
        json.decode(yoRcJson)["generator-living-atlas"]["promptValues"];
    return LAProject.fromObject(yoRc);
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

    for (LAServiceDesc service in LAServiceDesc.list(false)) {
      String n = service.nameInt == "cas" ? "CAS" : service.nameInt;
      // ala_bie and images was not optional in the past
      bool useIt = !service.optional
          ? true
          : a("use_$n") ?? n == 'ala_bie' || n == 'images'
              ? true
              : false;
      LAService projectService = p.getService(service.nameInt);
      p.serviceInUse(service.nameInt, useIt);
      n = service.nameInt == "species_lists" ? "lists" : service.nameInt;
      bool useSub =
          service.forceSubdomain ? true : a("${n}_uses_subdomain") ?? true;
      projectService.usesSubdomain = useSub;
      if (debug) print("domain: $domain");
      if (debug) {
        print(
            "$n (LA_use_$n): $useIt subdomain (LA_${n}_uses_subdomain): $useSub");
      }
      String invPath = a("${n}_path") ?? '';

      String iniPath = invPath.startsWith("/") ? invPath.substring(1) : invPath;
      String url = a("${n}_url") ?? a("${n}_hostname") ?? '';

      if (useSub) {
        projectService.suburl = url.replaceFirst('.$domain', '');
        projectService.iniPath = iniPath;
      } else {
        projectService.suburl = iniPath;
      }

      String hostname = a("${n}_hostname") ?? '';

      if (debug) {
        print(
            "$n: url: $url path: '$invPath' initPath: '${projectService.iniPath}' useSub: $useSub suburl: ${projectService.suburl} hostname: $hostname");
      }

      if (useIt && hostname.isNotEmpty) {
        LAServer s;
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
        tempServerServices[s.id]!.add(service.nameInt);
      }
    }
    for (LAServer server in p.servers) {
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
      String url = getService(nameInt).fullUrl(useSSL, domain);
      String name = StringUtils.capitalize(desc.name);
      String? help = nameInt == LAServiceName.solr.toS()
          ? "Secure-your-LA-infrastructure#protect-you-solr-admin-interface"
          : null;
      String tooltip = name != "Index"
          ? serviceTooltip(name)
          : "This is protected by default, see our wiki for more info";
      if (nameInt == LAServiceName.solr.toS()) {
        url = "${url.replaceFirst("https", "http")}:8983";
      }
      LAServiceDepsDesc? mainDeps = depsDesc[nameInt];
      List<BasicService>? deps;
      if (mainDeps != null) deps = getDeps()[nameInt]!.serviceDepends;
      List<String> hostnames = getHostname(nameInt);
      List<LAServiceDeploy> sd =
          serviceDeploys.where((sd) => sd.serviceId == service.id).toList();
      ServiceStatus st = sd.isNotEmpty ? sd[0].status : ServiceStatus.unknown;
      if (nameInt != LAServiceName.cas.toS()) {
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
      }
      // This is for userdetails, apikeys, etcetera
      for (LASubServiceDesc sub in desc.subServices) {
        allServices.add(ProdServiceDesc(
          name: sub.name,
          // This maybe is not correct
          nameInt: nameInt,
          deps: deps,
          tooltip: serviceTooltip(name),
          subtitle: hostnames.join(', '),
          serviceDeploys: sd,
          icon: sub.icon,
          url: url + sub.path,
          admin: sub.admin,
          alaAdmin: sub.alaAdmin,
          status: st,
          // status: service.status,
        ));
      }
    });
    return allServices;
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
      list.add(p);
    }

    return list;
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
      createdAt.hashCode ^
      mapZoom.hashCode;
}
