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
      {required this.nameInt,
      required this.iniPath,
      required this.use,
      required this.usesSubdomain,
      required this.suburl});

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAService &&
          runtimeType == other.runtimeType &&
          nameInt == other.nameInt &&
          iniPath == other.iniPath &&
          use == other.use &&
          usesSubdomain == other.usesSubdomain &&
          suburl == other.suburl;

  @override
  int get hashCode =>
      nameInt.hashCode ^
      iniPath.hashCode ^
      use.hashCode ^
      usesSubdomain.hashCode ^
      suburl.hashCode;
}
