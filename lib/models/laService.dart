import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';

part 'laService.g.dart';

enum ServiceStatus { unknown, success, failed }

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAService {
  String nameInt;
  String iniPath;
  bool use;
  bool usesSubdomain;
  String suburl;

  LAService(
      {this.nameInt, this.iniPath, this.use, this.usesSubdomain, this.suburl});

  LAService.fromDesc(LAServiceDesc desc)
      : nameInt = desc.nameInt,
        iniPath = desc.path,
        use = !desc.optional ? true : desc.initUse,
        usesSubdomain = true,
        suburl = desc.name;

  String get path => usesSubdomain
      ? iniPath.startsWith("/")
          ? ""
          : "/" + iniPath
      : suburl.startsWith("/")
          ? ""
          : "/" + suburl;
  String url(domain) => usesSubdomain ? suburl + "." + domain : domain;
  String fullUrl(ssl, domain) => 'http${ssl ? "s" : ""}://${url(domain)}';

  factory LAService.fromJson(Map<String, dynamic> json) =>
      _$LAServiceFromJson(json);
  Map<String, dynamic> toJson() => _$LAServiceToJson(this);

  @override
  String toString() {
    if (use)
      return 'LAService{name: $nameInt';
    else
      return "not used";
  }
}
