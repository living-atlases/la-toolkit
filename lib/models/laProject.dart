import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
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

  static final def2 = LAProject(
      longName: "Living Atlas of Wakanda",
      shortName: "LA Wakanda",
      domain: "your.l-a.site");

  LAProject({
    uuid,
    this.longName = "",
    this.shortName = "",
    this.domain = "",
    this.useSSL = true,
    List<LAServer> servers,
    // List<String> serversNameList,
    Map<String, LAService> services,
    // List<String> servicesNameList
  })  : uuid = uuid ?? Uuid().v4(),
        servers = servers ?? [],
        // serversNameList = serversNameList ?? [],
        services = services ?? initialServices;

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
          .map((service) => service.name)
          .toList();
    return _servicesInUseNameList;
  }

  List<String> getServicesNameListNotInUse() {
    // If we change services map we'll set servicesNameList to null
    if (_servicesNotInUseNameList == null)
      _servicesNotInUseNameList = services.values
          .where((service) => !service.use)
          .map((service) => service.name)
          .toList();
    return _servicesNotInUseNameList;
  }

  List<String> getServicesNameListSelected() {
    // If we change services map we'll set servicesNameList to null
    if (_servicesSelectedNameList == null)
      _servicesSelectedNameList = services.values
          .where((service) => service.use && service.servers.length > 0)
          .map((service) => service.name)
          .toList();
    return _servicesSelectedNameList;
  }

  factory LAProject.fromJson(Map<String, dynamic> json) =>
      _$LAProjectFromJson(json);
  Map<String, dynamic> toJson() => _$LAProjectToJson(this);

  @override
  String toString() {
    return '''longName: $longName ($shortName), domain: $domain, 
    servers: $servers, 
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
        .map((service) => service.name)
        .toList();
  }
}
