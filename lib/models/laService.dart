import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:objectid/objectid.dart';

import 'isJsonSerializable.dart';

part 'laService.g.dart';

enum ServiceStatus { unknown, success, failed }

extension ParseToString on ServiceStatus {
  String toS() {
    return toString().split('.').last;
  }

  String toSforHumans() {
    switch (this) {
      case ServiceStatus.failed:
        return "Some check failed";
      case ServiceStatus.unknown:
        return "checking";
      case ServiceStatus.success:
        return "No issues detected";
    }
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

  Color get backColor {
    switch (this) {
      case ServiceStatus.failed:
        return Colors.red.shade100;
      case ServiceStatus.unknown:
        return Colors.grey.shade100;
      case ServiceStatus.success:
        return Colors.green.shade100;
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceStatus.failed:
        return Icons.warning_amber_outlined;
      case ServiceStatus.unknown:
        return Icons.check;
      case ServiceStatus.success:
        return Icons.check;
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

  // Relations ----
  String projectId;

  LAService(
      {String? id,
      required this.nameInt,
      required this.iniPath,
      required this.use,
      required this.usesSubdomain,
      ServiceStatus? status,
      required this.suburl,
      required this.projectId})
      : id = id ?? ObjectId().toString(),
        status = status ?? ServiceStatus.unknown;

  LAService.fromDesc(LAServiceDesc desc, this.projectId)
      : id = ObjectId().toString(),
        nameInt = desc.nameInt,
        iniPath = desc.iniPath ?? desc.path,
        use = !desc.optional ? true : desc.initUse,
        usesSubdomain = true,
        status = ServiceStatus.unknown,
        suburl = desc.name;

  String get path => usesSubdomain
      ? iniPath.startsWith("/")
          ? iniPath
          : "/" + iniPath
      : suburl.startsWith("/")
          ? suburl
          : "/" + suburl;
  String url(domain) =>
      usesSubdomain ? (suburl.isNotEmpty ? suburl + "." : '') + domain : domain;
  String fullUrl(ssl, domain) => 'http${ssl ? "s" : ""}://${url(domain)}$path';

  factory LAService.fromJson(Map<String, dynamic> json) =>
      _$LAServiceFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$LAServiceToJson(this);

  @override
  String toString() {
    if (use) {
      return 'LAService ($nameInt, use: $use, project: (${projectId.length > 8 ? projectId.substring(0, 8) : ""}))';
    } else {
      return "$nameInt not used";
    }
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
          projectId == other.projectId &&
          suburl == other.suburl;

  @override
  int get hashCode =>
      nameInt.hashCode ^
      iniPath.hashCode ^
      use.hashCode ^
      usesSubdomain.hashCode ^
      id.hashCode ^
      status.hashCode ^
      projectId.hashCode ^
      suburl.hashCode;

  @override
  LAService fromJson(Map<String, dynamic> json) => LAService.fromJson(json);

  static List<String> removeSimpleServices(List<String> services) {
    return services
        .where((nameInt) =>
            nameInt != apikey &&
            nameInt != userdetails &&
            nameInt != casManagement &&
            nameInt != spatialService &&
            nameInt != geoserver &&
            nameInt != biocacheCli &&
            nameInt != spark &&
            nameInt != hadoop &&
            nameInt != nameindexer)
        .toList();
  }

  static List<String> removeServicesDeployedTogether(List<String> services) {
    return services
        .where((nameInt) =>
            nameInt != apikey &&
            nameInt != userdetails &&
            nameInt != casManagement &&
            nameInt != spatialService &&
            nameInt != geoserver &&
            nameInt != spark &&
            nameInt != hadoop &&
            nameInt != zookeeper)
        .toList();
  }

  static String servicesForHumans(List<LAService> services) {
    return services
        .map((service) =>
            StringUtils.capitalize(LAServiceDesc.get(service.nameInt).name))
        .toList()
        .join(', ');
  }
}
