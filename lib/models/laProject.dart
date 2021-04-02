import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laLatLng.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/prodServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/casUtils.dart';
import 'package:la_toolkit/utils/mapUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import 'basicService.dart';
import 'cmdHistoryDetails.dart';
import 'hostServicesChecks.dart';
import 'laServer.dart';
import 'laService.dart';
import 'laServiceDepsDesc.dart';
import 'laVariable.dart';
import 'laVariableDesc.dart';

part 'laProject.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAProject {
  String uuid;
  String longName;
  String shortName;
  String? dirName;
  String domain;
  bool useSSL;
  List<LAServer> servers;
  Map<String, LAServer> serversMap;
  Map<String, LAService> services;
  Map<String, LAVariable> variables;
  String additionalVariables;
  Map<String, List<String>> serverServices;
  @JsonKey(ignore: true)
  bool isCreated;
  bool fstDeployed;
  bool advancedEdit;
  bool advancedTune;
  LAProjectStatus status;
  String theme;
  String? alaInstallRelease;
  String? generatorRelease;
  LALatLng mapBoundsFstPoint;
  LALatLng mapBoundsSndPoint;
  double? mapZoom;
  CmdHistoryEntry? lastCmdEntry;
  @JsonKey(ignore: true)
  CmdHistoryDetails? lastCmdDetails;
  List<CmdHistoryEntry> cmdHistory;

  LAProject(
      {String? uuid,
      this.longName = "",
      this.shortName = "",
      this.domain = "",
      this.dirName = "",
      this.useSSL = true,
      this.isCreated = false,
      bool? fstDeployed,
      List<LAServer>? servers,
      Map<String, LAService>? services,
      Map<String, LAServer>? serversMap,
      Map<String, LAVariable>? variables,
      this.additionalVariables = "",
      Map<String, List<String>>? serverServices,
      this.status = LAProjectStatus.created,
      this.alaInstallRelease,
      this.generatorRelease,
      LALatLng? mapBoundsFstPoint,
      LALatLng? mapBoundsSndPoint,
      this.theme = "clean",
      this.mapZoom,
      this.lastCmdEntry,
      this.lastCmdDetails,
      List<CmdHistoryEntry>? cmdHistory,
      bool? advancedEdit,
      bool? advancedTune})
      : uuid = uuid ?? Uuid().v4(),
        servers = servers ?? [],
        serversMap = serversMap ?? {},
        // _serversNameList = _serversNameList ?? [],
        services = services ?? initialServices,
        variables = variables ?? {},
        serverServices = serverServices ?? {},
        advancedEdit = advancedEdit ?? false,
        advancedTune = advancedTune ?? false,
        cmdHistory = cmdHistory ?? [],
        fstDeployed = fstDeployed ?? false,
        mapBoundsFstPoint = mapBoundsFstPoint ?? LALatLng.from(-44, 112),
        mapBoundsSndPoint = mapBoundsSndPoint ?? LALatLng.from(-9, 154) {
    if (this.serversMap.entries.length != this.servers.length) {
      // serversMap is new
      this.serversMap =
          Map.fromIterable(this.servers, key: (e) => e.uuid, value: (e) => e);
    }
    validateCreation();
  }

  init() async {
    // Try to generate default CAS keys
    String pac4jSignKey = await CASUtils.gen512CasKey();
    String pac4jEncKey = await CASUtils.gen256CasKey();
    String webflowSignKey = await CASUtils.gen512CasKey();
    String webflowEncKey = await CASUtils.gen128CasKey();
    setVariable(LAVariableDesc.get("pac4j_cookie_signing_key"), pac4jSignKey);
    setVariable(LAVariableDesc.get("pac4j_cookie_encryption_key"), pac4jEncKey);
    setVariable(LAVariableDesc.get("cas_webflow_signing_key"), webflowSignKey);
    setVariable(
        LAVariableDesc.get("cas_webflow_encryption_key"), webflowEncKey);
  }

  int numServers() => servers.length;

  LatLng getCenter() {
    return MapUtils.center(mapBoundsFstPoint, mapBoundsSndPoint);
  }

  bool validateCreation({debug: false}) {
    bool valid = true;
    LAProjectStatus status = LAProjectStatus.created;
    if (serverServices.length != serversMap.entries.length ||
        servers.length != serverServices.length)
      throw ('Servers in $longName ($uuid) are inconsistent (serverServices: ${serverServices.length} serversMap: ${serversMap.entries.length} servers: ${servers.length})');

    valid = valid &&
        LARegExp.projectNameRegexp.hasMatch(longName) &&
        LARegExp.shortNameRegexp.hasMatch(shortName) &&
        LARegExp.domainRegexp.hasMatch(domain) &&
        alaInstallRelease != null &&
        generatorRelease != null;
    if (valid) status = LAProjectStatus.basicDefined;
    if (debug) print("Step 1 valid: ${valid ? 'yes' : 'no'}");

    valid = valid && servers.length > 0;
    if (valid)
      servers.forEach((s) {
        valid = valid && LARegExp.hostnameRegexp.hasMatch(s.name);
      });

    if (debug) print("Step 2 valid: ${valid ? 'yes' : 'no'}");
    // If the previous steps are correct, this is also correct

    valid = valid && allServicesAssignedToServers();
    if (debug) print("Step 3 valid: ${valid ? 'yes' : 'no'}");

    if (valid)
      servers.forEach((s) {
        valid = valid && LARegExp.ip.hasMatch(s.ip);
        valid = valid && s.sshKey != null;
      });
    if (debug) print("Step 4 valid: ${valid ? 'yes' : 'no'}");

    isCreated = valid;
    if (isCreated && !allServersWithServicesReady())
      setProjectStatus(LAProjectStatus.advancedDefined);
    if (isCreated && fstDeployed && allServersWithServicesReady()) {
      status = LAProjectStatus.firstDeploy;
    }
    if (isCreated &&
        allServersWithServicesReady() &&
        this.status.value < status.value) setProjectStatus(status);
    // Only update status if is better
    if (status.value > this.status.value) setProjectStatus(status);
    return valid;
  }

  bool allServicesAssignedToServers() {
    bool ok = getServicesNameListInUse().length > 0 &&
        getServicesNameListInUse().length ==
            getServicesNameListSelected().length;
    getServicesNameListInUse().forEach((service) {
      ok && getHostname(service).isNotEmpty;
    });
    return ok;
  }

  List<LAServer> serversWithServices() {
    return servers
        .where((s) =>
            serverServices[s.uuid] != null &&
            serverServices[s.uuid]!.length > 0)
        .toList();
  }

  bool allServersWithIPs() {
    bool allReady = true;
    servers.forEach((s) {
      allReady = allReady && LARegExp.ip.hasMatch(s.ip);
    });
    return allReady;
  }

  bool allServersWithSshKeys() {
    bool allReady = true;
    servers.forEach((s) {
      allReady = allReady && s.sshKey != null;
    });
    return allReady;
  }

  bool allServersWithServicesReady() {
    bool allReady = true && serversWithServices().length > 0;
    serversWithServices().forEach((s) {
      allReady = allReady && s.isReady();
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
    return services.values
        .where((service) => service.use)
        .map((service) => service.nameInt)
        .toList();
  }

  List<String> getServicesNameListNotInUse() {
    return services.values
        .where((service) => !service.use)
        .map((service) => service.nameInt)
        .toList();
  }

  List<String> getServicesNameListSelected() {
    List<String> selected = [];
    serverServices.forEach((uuid, service) => selected.addAll(service));
    return selected;
  }

  factory LAProject.fromJson(Map<String, dynamic> json) =>
      _$LAProjectFromJson(json);

  Map<String, dynamic> toJson() => _$LAProjectToJson(this);

  @override
  String toString() {
    String sToS = serverServices.entries
        .map((entry) => '${serversMap[entry.key]!.name} has ${entry.value}')
        .toList()
        .join(', ');
    return '''PROJECT: longName: $longName ($shortName) dirName: $dirName domain: $domain, ssl: $useSSL, allWServReady: ___${allServersWithServicesReady()}___
isCreated: $isCreated fstDeployed: $fstDeployed validCreated: ${validateCreation()}, status: __${status.title}__, ala-install: $alaInstallRelease, generator: $generatorRelease 
lastCmdEntry ${lastCmdEntry != null ? lastCmdEntry!.inhCmd.toString() : 'none'} map: $mapBoundsFstPoint $mapBoundsSndPoint, zoom: $mapZoom
servers (${servers.length}): ${servers.join('| ')}
servers-services: $sToS  
services selected (${getServicesNameListSelected().length}): [${getServicesNameListSelected().join(', ')}]
services in use (${getServicesNameListInUse().length}): [${getServicesNameListInUse().join(', ')}]
services not in use (${getServicesNameListNotInUse().length}): [${getServicesNameListNotInUse().join(', ')}].''';
  }

  static Map<String, LAService> initialServices = getInitialServices();

  static Map<String, LAService> getInitialServices() {
    final Map<String, LAService> services = {};
    LAServiceDesc.map.forEach((key, desc) {
      services[key] = LAService.fromDesc(desc);
    });
    return services;
  }

  LAService getServiceE(LAServiceName nameInt) {
    return getService(nameInt.toS());
  }

  LAService getService(String nameInt) {
    // getDepends can be null so the getService returns also null. Find a better way to do this
    // if (nameInt == null) return null;
    LAService? curService = services[nameInt];
    if (curService == null)
      services[nameInt] =
          curService = LAService.fromDesc(LAServiceDesc.get(nameInt));
    return curService;
  }

  LAVariable getVariable(String nameInt) {
    if (variables[nameInt] == null) {
      variables[nameInt] = LAVariable.fromDesc(LAVariableDesc.get(nameInt));
    }
    return variables[nameInt]!;
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
    variables[variableDesc.nameInt] = cur;
  }

  List<String> getServicesNameListInServer(String serverName) {
    return serverServices[serverName] ?? [];
  }

  void upsertByName(LAServer laServer) {
    servers = LAServer.upsertByName(servers, laServer);
    LAServer upsertServer =
        servers.firstWhereOrNull((s) => s.name == laServer.name)!;

    serversMap[upsertServer.uuid] = upsertServer;
    _cleanServerServices(upsertServer);
  }

  void upsertById(LAServer laServer) {
    servers = LAServer.upsertById(servers, laServer);
    serversMap[laServer.uuid] = laServer;
    _cleanServerServices(laServer);
  }

  void _cleanServerServices(LAServer laServer) {
    if (!serverServices.containsKey(laServer.uuid)) {
      serverServices[laServer.uuid] = [];
    }
  }

  void setProjectStatus(LAProjectStatus status) {
    this.status = status;
  }

  void assign(LAServer server, List<String> assignedServices) {
    serverServices[server.uuid] = assignedServices;
  }

  void delete(LAServer serverToDelete) {
    serverServices.removeWhere((key, value) => key == serverToDelete.uuid);
    servers.remove(serverToDelete);
    serversMap.remove(serverToDelete.uuid);
  }

  String additionalVariablesDecoded() {
    return additionalVariables.length > 0
        ? utf8.decode(base64.decode(additionalVariables))
        : "";
  }

  List<String> getHostname(String service) {
    List<String> hostnames = [];

    serverServices.forEach((uuid, services) {
      services.forEach((currentService) {
        if (service == currentService) {
          // print(uuid);
          // print("servers map: ${serversMap[uuid]}");
          if (serversMap[uuid] != null) hostnames.add(serversMap[uuid]!.name);
        }
      });
    });
    return hostnames;
  }

  String get etcHostsVar {
    List<String> etcHostLines = [];
    serversWithServices().forEach((server) => etcHostLines.add(
        "      ${server.ip} ${getServerServices(serverUuid: server.uuid).map((sName) => services[sName]!.url(domain)).toList().join(' ')}"));
    return etcHostLines.join('\n');
  }

  String get hostnames {
    List<String> hostList = [];
    serversWithServices().forEach((server) => hostList.add("${server.name}"));
    return hostList.join('|');
  }

  String get sshKeysInUse {
    List<String> sshKeysInUseList = [];
    serversWithServices().forEach((server) {
      if (server.sshKey != null)
        sshKeysInUseList.add("'~/.ssh/${server.sshKey!.name}.pub'");
    });
    // toSet.toList to remove dups
    return sshKeysInUseList.toSet().toList().join(', ');
  }

  bool collectoryAndBiocacheDifferentServers() {
    List<String> colHosts = getHostname(LAServiceName.collectory.toS());
    List<String> biocacheHubHosts = getHostname(LAServiceName.ala_hub.toS());
    List<String> common = List.from(colHosts);
    common.removeWhere((item) => biocacheHubHosts.contains(item));
    return ListEquality().equals(common, colHosts);
  }

  void setMap(LatLng firstPoint, LatLng sndPoint, double zoom) {
    mapBoundsFstPoint =
        LALatLng.from(firstPoint.latitude, firstPoint.longitude);
    mapBoundsSndPoint = LALatLng.from(sndPoint.latitude, sndPoint.longitude);
    mapZoom = zoom;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAProject &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid &&
          longName == other.longName &&
          shortName == other.shortName &&
          dirName == other.dirName &&
          domain == other.domain &&
          useSSL == other.useSSL &&
          DeepCollectionEquality.unordered().equals(servers, other.servers) &&
          DeepCollectionEquality.unordered().equals(services, other.services) &&
          DeepCollectionEquality.unordered()
              .equals(variables, other.variables) &&
          DeepCollectionEquality.unordered()
              .equals(serverServices, other.serverServices) &&
          additionalVariables == other.additionalVariables &&
          isCreated == other.isCreated &&
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
          ListEquality().equals(cmdHistory, other.cmdHistory) &&
          mapZoom == other.mapZoom;

  @override
  int get hashCode =>
      uuid.hashCode ^
      longName.hashCode ^
      shortName.hashCode ^
      dirName.hashCode ^
      domain.hashCode ^
      useSSL.hashCode ^
      DeepCollectionEquality.unordered().hash(servers) ^
      DeepCollectionEquality.unordered().hash(services) ^
      DeepCollectionEquality.unordered().hash(variables) ^
      DeepCollectionEquality.unordered().hash(serverServices) ^
      isCreated.hashCode ^
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
      ListEquality().hash(cmdHistory) ^
      mapZoom.hashCode;

  void serviceInUse(String serviceNameInt, bool use) {
    if (!services.keys.contains(serviceNameInt))
      services[serviceNameInt] ??=
          LAService.fromDesc(LAServiceDesc.map[serviceNameInt]!);
    LAService service = services[serviceNameInt]!;

    service.use = use;
    Iterable<LAServiceDesc> depends = LAServiceDesc.map.values.where((curSer) =>
        (curSer.depends != null && curSer.depends!.toS() == serviceNameInt));
    if (!use) {
      // Remove
      serverServices.forEach((uuid, services) {
        services.remove(serviceNameInt);
      });
      // Disable dependents
      depends.forEach((serviceDesc) => serviceInUse(serviceDesc.nameInt, use));
    } else {
      depends.forEach((serviceDesc) {
        if (!serviceDesc.optional) {
          serviceInUse(serviceDesc.nameInt, use);
        }
      });
    }
  }

  Map<String, dynamic> toGeneratorJson() {
    Map<String, dynamic> conf = {
      "LA_uuid": uuid,
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
      "LA_generate_branding": true
    };
    conf.addAll(MapUtils.toInvVariables(mapBoundsFstPoint, mapBoundsSndPoint));

    List<String> ips = List.empty(growable: true);
    serversWithServices().forEach((server) => ips.add(server.ip));
    conf["LA_server_ips"] = ips.join(',');

    if (additionalVariables != "") {
      conf["LA_additionalVariables"] = additionalVariables;
    }
    services.forEach((key, service) {
      conf["LA_use_${service.nameInt}"] = service.use;
      conf["LA_${service.nameInt}_uses_subdomain"] = service.usesSubdomain;
      conf["LA_${service.nameInt}_hostname"] =
          getHostname(service.nameInt).length > 0
              ? getHostname(service.nameInt)[0]
              : "";
      conf["LA_${service.nameInt}_url"] = service.url(domain);
      conf["LA_${service.nameInt}_path"] = service.path;
    });

    variables.forEach((key, variable) {
      conf["LA_variable_${variable.nameInt}"] = variable.value;
    });
    return conf;
  }

  factory LAProject.import({required String yoRcJson}) {
    Map<String, dynamic> yoRc =
        json.decode(yoRcJson)["generator-living-atlas"]["promptValues"];
    return LAProject.fromObject(yoRc);
  }

  factory LAProject.fromObject(Map<String, dynamic> yoRc, {debug: false}) {
    Function a = (tag) => yoRc["LA_$tag"];
    LAProject p = LAProject(
        longName: yoRc['LA_project_name'],
        shortName: yoRc['LA_project_shortname'],
        domain: yoRc["LA_domain"],
        useSSL: yoRc["LA_enable_ssl"],
        services: {});
    String domain = p.domain;
    Map<String, List<String>> tempServerServices = {};

    LAServiceDesc.list.forEach((service) {
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
      if (debug)
        print(
            "$n (LA_use_$n): $useIt subdomain (LA_${n}_uses_subdomain): $useSub");
      String invPath = a("${n}_path") ?? '';

      projectService.iniPath =
          invPath.startsWith("/") ? invPath.substring(1) : invPath;
      String url = a("${n}_url") ?? a("${n}_hostname") ?? '';

      projectService.suburl = useSub
          ? url.replaceFirst('.$domain', '')
          : url.replaceFirst('$domain/', '');

      String hostname = a("${n}_hostname") ?? '';

      if (debug)
        print(
            "$n: url: $url path: '$invPath' initPath: '${projectService.iniPath}' useSub: $useSub suburl: ${projectService.suburl} hostname: $hostname");

      if (useIt && hostname.length > 0) {
        LAServer s;
        if (!p.getServersNameList().contains(hostname)) {
          // uuid is empty when is new
          s = LAServer(uuid: Uuid().v4(), name: hostname);
          p.upsertByName(s);
        } else {
          s = p.servers.where((c) => c.name == hostname).toList()[0];
        }
        if (!tempServerServices.containsKey(s.uuid))
          tempServerServices[s.uuid] = List<String>.empty(growable: true);
        tempServerServices[s.uuid]!.add(service.nameInt);
      }
    });
    p.servers.forEach(
        (server) => p.assign(server, tempServerServices[server.uuid]!));
    return p;
  }

  List<String> getServerServices({required String serverUuid}) {
    if (!serverServices.containsKey(serverUuid))
      serverServices[serverUuid] = List<String>.empty(growable: true);
    return serverServices[serverUuid]!;
  }

  List<LAService> getServerServicesFull({required String serverUuid}) {
    List<String> listS = getServerServices(serverUuid: serverUuid);
    return services.values.where((s) => listS.contains(s.nameInt)).toList();
  }

  Map<String, List<String>> getServerServicesForTest() {
    return serverServices;
  }

  String suggestDirName() {
    return StringUtils.suggestDirName(shortName: shortName, uuid: uuid);
  }

  List<ProdServiceDesc> get prodServices {
    List<ProdServiceDesc> allServices = [];
    Map<String, LAServiceDepsDesc> depsDesc = getDeps();
    getServicesNameListInUse()
        /* .where((nameInt) =>
            !LAServiceDesc.get(nameInt).withoutUrl &&
            nameInt != LAServiceName.branding.toS()) */
        .forEach((nameInt) {
      LAServiceDesc desc = LAServiceDesc.get(nameInt);
      String url = getService(nameInt).fullUrl(useSSL, domain);
      String name = StringUtils.capitalize(desc.name);
      String? help = nameInt == LAServiceName.solr.toS()
          ? "Secure-your-LA-infrastructure#protect-you-solr-admin-interface"
          : null;
      String tooltip = name != "Index"
          ? serviceTooltip(name)
          : "This is protected by default, see our wiki for more info";
      // LAService service = getService(nameInt);

      LAServiceDepsDesc? mainDeps = depsDesc[nameInt];
      List<BasicService>? deps;
      if (mainDeps != null) deps = getDeps()[nameInt]!.serviceDepends;
      List<String> hostnames = getHostname(nameInt);
      if (nameInt != LAServiceName.cas.toS())
        allServices.add(ProdServiceDesc(
            name: name,
            nameInt: nameInt,
            deps: deps,
            tooltip: tooltip,
            subtitle: hostnames.join(', '),
            hostnames: hostnames,
            icon: desc.icon,
            url: url,
            admin: desc.admin,
            alaAdmin: desc.alaAdmin,
            help: help));
      // This is for userdetails, apikeys, etc
      desc.subServices.forEach((sub) => allServices.add(ProdServiceDesc(
            name: sub.name,
            // This maybe is not correct
            nameInt: nameInt,
            deps: deps,
            tooltip: serviceTooltip(name),
            subtitle: hostnames.join(', '),
            hostnames: hostnames,
            icon: sub.icon,
            url: url + sub.path,
            admin: sub.admin,
            alaAdmin: sub.alaAdmin,
          )));
    });
    return allServices;
  }

  String serviceTooltip(String name) => "Open the $name service";

  HostsServicesChecks getHostServicesChecks(
      List<ProdServiceDesc> prodServices) {
    HostsServicesChecks hostsChecks = HostsServicesChecks();
    prodServices.forEach((service) {
      service.hostnames.forEach((server) {
        service.deps!.forEach((dep) {
          hostsChecks.add(server, service.deps);
          //  tcpPorts.addAll(dep.tcp);
        });
      });
    });
    return hostsChecks;
  }

  Tuple2<List<ProdServiceDesc>, HostsServicesChecks> serverServicesToMonitor() {
    List<ProdServiceDesc> services = prodServices;
    HostsServicesChecks checks = getHostServicesChecks(services);
    return Tuple2(services, checks);
  }

  Map<String, LAServiceDepsDesc> getDeps() =>
      LAServiceDepsDesc.getDeps(alaInstallRelease);
}
