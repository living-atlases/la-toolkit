import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/basicService.dart';

part 'hostServicesChecks.g.dart';

@JsonSerializable(explicitToJson: true)
class HostsServicesChecks {
  // ServiceDeploy Id to check
  Map<String, HostServicesChecks> map = {};
  HostsServicesChecks();

  factory HostsServicesChecks.fromJson(Map<String, dynamic> json) =>
      _$HostsServicesChecksFromJson(json);
  Map<String, dynamic> toJson() => _$HostsServicesChecksToJson(this);

  void setUrls(String sdId, List<String> urls) {
    HostServicesChecks hostServices = _getServiceDeploy(sdId);
    hostServices.setUrls(urls);
  }

  void add(String sdId, List<BasicService>? deps) {
    HostServicesChecks hostServices = _getServiceDeploy(sdId);
    if (deps != null) {
      deps.forEach((dep) {
        hostServices.tcpPorts.addAll(dep.tcp);
        hostServices.udpPorts.addAll(dep.udp);
        if (dep.name != Java.v8.name && dep.name != PostGis.v2_4.name) {
          hostServices.otherChecks.add(dep.name);
        }
      });
    }
  }

  HostServicesChecks _getServiceDeploy(String sdId) {
    HostServicesChecks hostServices;
    if (!map.containsKey(sdId)) {
      hostServices = HostServicesChecks();
      map[sdId] = hostServices;
    } else {
      hostServices = map[sdId]!;
    }
    return hostServices;
  }

  @override
  String toString() {
    return 'HostsServicesChecks{map: $map}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HostsServicesChecks &&
          runtimeType == other.runtimeType &&
          DeepCollectionEquality.unordered().equals(map, other.map);

  @override
  int get hashCode => DeepCollectionEquality.unordered().hash(map);
}

@JsonSerializable(createToJson: false)
class HostServicesChecks {
  final HashSet<num> tcpPorts = HashSet<num>();
  final HashSet<num> udpPorts = HashSet<num>();
  final HashSet<String> otherChecks = HashSet<String>();
  final List<String> urls = [];

  HostServicesChecks();

  factory HostServicesChecks.fromJson(Map<String, dynamic> json) =>
      _$HostServicesChecksFromJson(json);

  @override
  String toString() {
    return 'HostServicesChecks{tcpPorts: $tcpPorts, udpPorts: $udpPorts, checks: $otherChecks}';
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> toJ = {};
    // jsonEncode(
    toJ['tcpPorts'] = tcpPorts.toList();
    toJ['udpPorts'] = udpPorts.toList();
    toJ['otherChecks'] = otherChecks.toList();
    toJ['urls'] = urls;
    return toJ;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HostServicesChecks &&
          runtimeType == other.runtimeType &&
          DeepCollectionEquality.unordered().equals(tcpPorts, other.tcpPorts) &&
          DeepCollectionEquality.unordered().equals(udpPorts, other.udpPorts) &&
          DeepCollectionEquality.unordered()
              .equals(otherChecks, other.otherChecks) &&
          listEquals(urls, other.urls);

  @override
  int get hashCode =>
      DeepCollectionEquality.unordered().hash(tcpPorts) ^
      DeepCollectionEquality.unordered().hash(udpPorts) ^
      DeepCollectionEquality.unordered().hash(otherChecks) ^
      ListEquality().hash(urls);

  void setUrls(List<String> urls) {
    this.urls.addAll(urls);
  }
}
