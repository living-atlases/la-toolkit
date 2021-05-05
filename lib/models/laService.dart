import 'dart:ui';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:objectid/objectid.dart';

import 'isJsonSerializable.dart';

part 'laService.g.dart';

enum ServiceStatus { unknown, success, failed }

extension ParseToString on ServiceStatus {
  String toS() {
    return this.toString().split('.').last;
  }

  Color get color {
    switch (this) {
      case ServiceStatus.failed:
        return ResultType.failures.color;
      case ServiceStatus.unknown:
        return ResultType.ignored.color;
      case ServiceStatus.success:
        return ResultType.ok.color;
    }
  }
}

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAService implements IsJsonSerializable<LAService> {
  // Basic -----
  String id;
  String nameInt;
  bool use;

  // Urs related -----
  bool usesSubdomain;
  String iniPath;
  String suburl;

  // Status -----
  ServiceStatus status;

  LAService(
      {String? id,
      required this.nameInt,
      required this.iniPath,
      required this.use,
      required this.usesSubdomain,
      ServiceStatus? status,
      required this.suburl})
      : id = id ?? new ObjectId().toString(),
        status = status ?? ServiceStatus.unknown;

  LAService.fromDesc(LAServiceDesc desc)
      : id = new ObjectId().toString(),
        nameInt = desc.nameInt,
        iniPath = desc.path,
        use = !desc.optional ? true : desc.initUse,
        usesSubdomain = true,
        this.status = ServiceStatus.unknown,
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
      return 'LAService ($nameInt)';
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
          id == other.id &&
          status == other.status &&
          usesSubdomain == other.usesSubdomain &&
          suburl == other.suburl;

  @override
  int get hashCode =>
      nameInt.hashCode ^
      iniPath.hashCode ^
      use.hashCode ^
      usesSubdomain.hashCode ^
      id.hashCode ^
      status.hashCode ^
      suburl.hashCode;

  @override
  LAService fromJson(Map<String, dynamic> json) => LAService.fromJson(json);
}
