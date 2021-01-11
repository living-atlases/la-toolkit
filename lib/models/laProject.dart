import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:uuid/uuid.dart';

import 'laServer.dart';
import 'laService.dart';

part 'laProject.g.dart';

@immutable
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
  bool isCreated;
  @JsonSerializable(nullable: false)
  LAProjectStatus status;

  LAProject(
      {uuid,
      this.longName = "",
      this.shortName = "",
      this.domain = "",
      this.useSSL = true,
      this.isCreated = false,
      List<LAServer> servers,
      Map<String, LAService> services,
      LAProjectStatus status})
      : uuid = uuid ?? Uuid().v4(),
        servers = servers ?? [],
        // _serversNameList = _serversNameList ?? [],
        services = services ?? initialServices,
        status = status ?? LAProjectStatus.created;

  int numServers() => servers.length;

  // List<LAServer> get servers => _servers;
  //  set servers(servers) => _servers = servers;

  bool validateCreation(int currentStep) {
    bool valid = true;
    if (currentStep >= 0)
      valid = valid &&
          LARegExp.projectNameRegexp.hasMatch(longName) &&
          LARegExp.shortNameRegexp.hasMatch(shortName) &&
          LARegExp.domainRegexp.hasMatch(domain);
    if (currentStep >= 1) {
      valid = valid && servers.length > 0;
      if (valid)
        servers.forEach((s) {
          valid = valid && LARegExp.hostnameRegexp.hasMatch(s.name);
        });
    }
    if (valid && currentStep >= 2) {
      // If the previous steps are correct, this is also correct
    }
    if (valid && currentStep >= 3) {
      valid = valid &&
          (getServicesNameListInUse().length > 0 &&
              getServicesNameListNotInUse().length == 0);
    }
    if (valid && currentStep >= 4) {
      if (valid)
        servers.forEach((s) {
          valid = valid && LARegExp.ipv4.hasMatch(s.ipv4);
        });
    }
    isCreated = valid && currentStep == 4;
    setProjectStatus(LAProjectStatus.advancedDefined);
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

  factory LAProject.fromJson(Map<String, dynamic> json) =>
      _$LAProjectFromJson(json);
  Map<String, dynamic> toJson() => _$LAProjectToJson(this);

  @override
  String toString() {
    return '''longName: $longName ($shortName), domain: $domain, 
    isCreated: $isCreated, status: ${status.title}
    servers: $servers, 
    valid: ${validateCreation(0)} ${validateCreation(1)} ${validateCreation(2)} ${validateCreation(3)} ${validateCreation(4)}
    services selected: [${getServicesNameListSelected().join(', ')}]
    services in use: [${getServicesNameListInUse().join(', ')}].
    services not in use: [${getServicesNameListNotInUse().join(', ')}].''';
  }

  static Map<String, LAService> initialServices = getInitialServices();

  static Map<String, LAService> getInitialServices() {
    final Map<String, LAService> services = {};
    LAServiceDesc.map.forEach((key, desc) {
      services[key] = LAService.fromDesc(desc);
    });
    return services;
  }

  LAService getService(String nameInt) {
    if (nameInt == null) return null;
    return services[nameInt] ?? LAService.fromDesc(LAServiceDesc.map[nameInt]);
  }

  List<String> getServicesNameListInServer(String serverName) {
    return services.values
        .where((service) =>
            (service.use && service.getServersNameList().contains(serverName)))
        .map((service) => service.nameInt)
        .toList();
  }

  void upsert(LAServer laServer) {
    if (servers.contains(laServer)) {
      servers.map((current) => current == laServer ? laServer : current);
    } else {
      servers.add(laServer);
    }
  }

  void setProjectStatus(LAProjectStatus status) {
    if (this.status == null || this.status.value < status.value) {
      // only set if the new status is higher
      this.status = status;
    }
  }
}
