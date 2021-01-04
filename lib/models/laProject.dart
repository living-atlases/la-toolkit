import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'laServer.dart';
import 'laService.dart';

part 'laProject.g.dart';

@JsonSerializable(nullable: false)
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
  List<LAService> services;

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
      List<LAService> services})
      : uuid = uuid ?? Uuid().v4(),
        servers = servers ?? [],
        services = servers ?? [];

  factory LAProject.fromJson(Map<String, dynamic> json) =>
      _$LAProjectFromJson(json);
  Map<String, dynamic> toJson() => _$LAProjectToJson(this);

  @override
  String toString() {
    return "longName: $longName ($shortName), domain: $domain, servers: $servers";
  }
}
