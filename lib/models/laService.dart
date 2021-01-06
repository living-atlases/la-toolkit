import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';

import 'laServer.dart';

part 'laService.g.dart';

enum ServiceStatus { unknown, success, failed }

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAService {
  String name;
  String iniPath;
  bool use;
  bool usesSubdomain;
  // @JsonSerializable(nullable: true)
  List<LAServer> servers;
  String suburl;

  LAService(
      {this.name,
      this.iniPath,
      this.use,
      this.usesSubdomain,
      List<LAServer> servers,
      this.suburl})
      : servers = servers ?? List<LAServer>.empty();

  LAService.fromDesc(LAServiceDesc desc)
      : name = desc.nameInt,
        iniPath = desc.path,
        use = !desc.optional ? true : desc.initUse,
        usesSubdomain = true,
        servers = List<LAServer>.empty(),
        suburl = desc.name;

  String get path => usesSubdomain
      ? iniPath.startsWith("/")
          ? ""
          : "/" + iniPath
      : suburl.startsWith("/")
          ? ""
          : "/" + suburl;
  String url(domain) => usesSubdomain ? suburl + "." + domain : domain;

  factory LAService.fromJson(Map<String, dynamic> json) =>
      _$LAServiceFromJson(json);
  Map<String, dynamic> toJson() => _$LAServiceToJson(this);

  @override
  String toString({String domain = 'somedomain'}) {
    if (use)
      return "http?://${url(domain)}${this.path}";
    else
      return "not used";
  }
}
