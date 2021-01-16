import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:latlong/latlong.dart';
import 'package:uuid/uuid.dart';

import 'laServer.dart';
import 'laService.dart';

part 'laProject.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAProject {
  @JsonSerializable(nullable: false)
  String uuid;
  @JsonSerializable(nullable: false)
  String longName;
  @JsonSerializable(nullable: false)
  String shortName;
  @JsonSerializable(nullable: false)
  String domain;
  @JsonSerializable(nullable: false)
  bool useSSL;
  @JsonSerializable(nullable: false)
  List<LAServer> servers;
  @JsonSerializable(nullable: false)
  Map<String, LAService> services;
  @JsonKey(ignore: true)
  List<String> _serversNameList;
  @JsonKey(ignore: true)
  List<String> _servicesInUseNameList;
  @JsonKey(ignore: true)
  List<String> _servicesNotInUseNameList;
  @JsonKey(ignore: true)
  List<String> _servicesSelectedNameList;
  @JsonKey(ignore: true)
  List<String> _servicesNotSelectedNameList;
  @JsonKey(ignore: true)
  bool isCreated;
  @JsonSerializable(nullable: false)
  LAProjectStatus status;
  String alaInstallRelease;
  List<double> mapBounds1stPoint = []..length = 2;
  List<double> mapBounds2ndPoint = []..length = 2;
  double mapZoom;

  LAProject(
      {uuid,
      this.longName = "",
      this.shortName = "",
      this.domain = "",
      this.useSSL = true,
      this.isCreated = false,
      List<LAServer> servers,
      Map<String, LAService> services,
      LAProjectStatus status,
      this.alaInstallRelease,
      this.mapBounds1stPoint,
      this.mapBounds2ndPoint,
      this.mapZoom})
      : uuid = uuid ?? Uuid().v4(),
        servers = servers ?? [],
        // _serversNameList = _serversNameList ?? [],
        services = services ?? initialServices,
        status = status ?? LAProjectStatus.created;

  int numServers() => servers.length;

  LatLng getCenter() {
    return (mapBounds1stPoint != null && mapBounds2ndPoint != null)
        ? LatLng((mapBounds1stPoint[0] + mapBounds2ndPoint[0]) / 2,
            (mapBounds1stPoint[1] + mapBounds2ndPoint[1]) / 2)
        // Australia as default
        : LatLng(-28.2, 134);
  }
  // List<LAServer> get servers => _servers;
  //  set servers(servers) => _servers = servers;

  bool validateCreation() {
    bool valid = true;
    LAProjectStatus status = LAProjectStatus.created;

    valid = valid &&
        LARegExp.projectNameRegexp.hasMatch(longName) &&
        LARegExp.shortNameRegexp.hasMatch(shortName) &&
        LARegExp.domainRegexp.hasMatch(domain);
    if (valid) status = LAProjectStatus.basicDefined;
    print("Step 1 valid: ${valid ? 'yes' : 'no'}");

    valid = valid && servers.length > 0;
    if (valid)
      servers.forEach((s) {
        valid = valid && LARegExp.hostnameRegexp.hasMatch(s.name);
      });

    print("Step 2 valid: ${valid ? 'yes' : 'no'}");
    // If the previous steps are correct, this is also correct

    valid = valid &&
        (getServicesNameListInUse().length > 0 &&
            getServicesNameListInUse().length ==
                getServicesNameListSelected().length);
    print("Step 3 valid: ${valid ? 'yes' : 'no'}");

    if (valid)
      servers.forEach((s) {
        valid = valid && LARegExp.ipv4.hasMatch(s.ipv4);
      });
    print("Step 4 valid: ${valid ? 'yes' : 'no'}");

    isCreated = valid;
    if (isCreated) status = LAProjectStatus.advancedDefined;
    setProjectStatus(status);
    return valid;
  }

  List<String> getServersNameList() {
    // If we change server map we'll set serverNameList to null
    if (_serversNameList == null)
      _serversNameList = servers.map((server) => server.name).toList();
    return _serversNameList;
  }

  void initViews() {
    _serversNameList = null;
    _servicesNotInUseNameList = null;
    _servicesInUseNameList = null;
    _servicesSelectedNameList = null;
    _servicesNotSelectedNameList = null;
  }

  List<String> getServicesNameListInUse() {
    // If we change services map we'll set servicesNameList to null
    if (_servicesInUseNameList == null)
      _servicesInUseNameList = services.values
          .where((service) => service.use)
          .map((service) => service.nameInt)
          .toList();
    return _servicesInUseNameList;
  }

  List<String> getServicesNameListNotInUse() {
    // If we change services map we'll set servicesNameList to null
    if (_servicesNotInUseNameList == null)
      _servicesNotInUseNameList = services.values
          .where((service) => !service.use)
          .map((service) => service.nameInt)
          .toList();
    return _servicesNotInUseNameList;
  }

  List<String> getServicesNameListSelected() {
    // If we change services map we'll set servicesNameList to null
    if (_servicesSelectedNameList == null)
      _servicesSelectedNameList = services.values
          .where((service) => service.use && service.servers.length > 0)
          .map((service) => service.nameInt)
          .toList();
    return _servicesSelectedNameList;
  }

  List<String> getServicesNameListNotSelected() {
    // If we change services map we'll set servicesNameList to null
    if (_servicesNotSelectedNameList == null)
      _servicesNotSelectedNameList = services.values
          .where((service) => service.use && service.servers.length == 0)
          .map((service) => service.nameInt)
          .toList();
    return _servicesNotSelectedNameList;
  }

  factory LAProject.fromJson(Map<String, dynamic> json) =>
      _$LAProjectFromJson(json);
  Map<String, dynamic> toJson() => _$LAProjectToJson(this);

  @override
  String toString() {
    return '''longName: $longName ($shortName), domain: $domain, 
    isCreated: $isCreated, status: ${status.title}, ala-install: $alaInstallRelease
    map: $mapBounds1stPoint $mapBounds2ndPoint, zoom: $mapZoom
    servers: $servers, 
    valid: ${validateCreation()}
    services in use (${getServicesNameListInUse().length}): [${getServicesNameListInUse().map((s) => services[s].nameInt + "(" + (services[s].servers.length > 0 ? services[s].servers[0].name : "") + ")").toList().join(', ')}].
    services not in use (${getServicesNameListNotInUse().length}): [${getServicesNameListNotInUse().join(', ')}].
    services selected (${getServicesNameListSelected().length}): [${getServicesNameListSelected().join(', ')}]
    services not selected (${getServicesNameListNotSelected().length}): [${getServicesNameListNotSelected().join(', ')}]
    ''';
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
    if (nameInt == null) return null;
    return services[nameInt] ?? LAService.fromDesc(LAServiceDesc.get(nameInt));
  }

  List<String> getServicesNameListInServer(String serverName) {
    return services.values
        .where((service) =>
            (service.use && service.getServersNameList().contains(serverName)))
        .map((service) => service.nameInt)
        .toList();
  }

  void upsert(LAServer laServer) {
    servers = LAServer.upsert(servers, laServer);
  }

  void setProjectStatus(LAProjectStatus status) {
    this.status = status;
  }

  void assign(LAServer server, List<String> assignedServices) {
    // Remove previous assignments
    services.forEach((key, service) {
      if (service.servers.length > 0 && service.servers[0] == server)
        service.servers.clear();
    });
    assignedServices.forEach((serviceName) {
      LAService service = getService(serviceName);
      // We remove previously
      service.servers.clear();
      service.servers.add(server);
      assert(service.servers.length > 0);
      services[serviceName] = service;
      assert(services[serviceName].servers[0] == server);
    });
    initViews();
  }

  void delete(LAServer serverToDelete) {
    services.forEach((key, service) => service.servers.removeWhere(
        (currentServer) => currentServer.name == serverToDelete.name));
    servers.removeWhere(
        (currentServer) => currentServer.name == serverToDelete.name);
  }

  Map<String, dynamic> toGeneratorJson() {
    Map<String, dynamic> obj = {
      //   "uuid": uuid.toString(),
    };

    Map<String, dynamic> conf = {
      "LA_project_name": longName,
      "LA_project_shortname": shortName,
      "LA_domain": domain,
      "LA_enable_ssl": useSSL,
      "LA_use_git": true,
      "LA_generate_branding": true
    };
    services.forEach((key, service) {
      conf["LA_use_${service.nameInt}"] = service.use;
      conf["LA_${service.nameInt}_uses_subdomain"] = service.usesSubdomain;
      conf["LA_${service.nameInt}_hostname"] = service.servers[0].name;
      conf["LA_${service.nameInt}_url"] = service.url(domain);
      conf["LA_${service.nameInt}_path"] = service.path;
    });
    obj["conf"] = jsonEncode(conf);
    return obj;
  }

  void setMap(LatLng firstPoint, LatLng sndPoint, double zoom) {
    mapBounds1stPoint = [firstPoint.latitude, firstPoint.longitude];
    mapBounds2ndPoint = [sndPoint.latitude, sndPoint.longitude];
    mapZoom = zoom;
  }
}
