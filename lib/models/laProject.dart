import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'laServer.dart';
import 'laService.dart';
import 'laServiceDescList.dart';

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

  static final def = LAProject(
      longName: "Living Atlas of Wakanda",
      shortName: "LA Wakanda",
      domain: "your.l-a.site");

  LAProject(
      {uuid,
      this.longName = "",
      this.shortName = "",
      this.domain = "",
      this.useSSL = true,
      List<LAServer> servers,
      Map<String, LAService> services})
      : uuid = uuid ?? Uuid().v4(),
        servers = servers ?? List<LAServer>.empty(),
        services = services ?? initialServices;

  factory LAProject.fromJson(Map<String, dynamic> json) =>
      _$LAProjectFromJson(json);
  Map<String, dynamic> toJson() => _$LAProjectToJson(this);

  @override
  String toString() {
    return "longName: $longName ($shortName), domain: $domain, servers: $servers, services: $services";
  }

  static Map<String, LAService> initialServices = getInitialServices();

  static Map<String, LAService> getInitialServices() {
    final Map<String, LAService> services = {};
    serviceDescList.forEach((key, desc) {
      services[key] = LAService.fromDesc(desc);
    });
    return services;
  }

  LAService getService(String nameInt) {
    if (nameInt == null) return null;
    return services[nameInt] ?? LAService.fromDesc(serviceDescList[nameInt]);
  }
}
