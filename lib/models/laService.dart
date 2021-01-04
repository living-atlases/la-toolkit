import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'laServer.dart';

part 'laService.g.dart';

enum ServiceStatus { unknown, success, failed }

@JsonSerializable(nullable: false)
@CopyWith()
class LAService {
  String name;
  String get path => usesSubdomain
      ? iniPath.startsWith("/")
          ? ""
          : "/" + iniPath
      : suburl.startsWith("/")
          ? ""
          : "/" + suburl;
  String iniPath;
  bool usesSubdomain;
  List<LAServer> servers;
  String suburl;
  String url(domain) => usesSubdomain ? suburl + "." + domain : domain;

  LAService({this.name, this.iniPath, this.usesSubdomain, servers, this.suburl})
      : servers = servers ?? [];

  factory LAService.fromJson(Map<String, dynamic> json) =>
      _$LAServiceFromJson(json);
  Map<String, dynamic> toJson() => _$LAServiceToJson(this);

  @override
  String toString() {
    return "name: $name, path: $path, usesSubdomain: $usesSubdomain, servers: $servers";
  }
}
