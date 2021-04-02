import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/basicService.dart';

part 'hostServicesChecks.g.dart';

@JsonSerializable(explicitToJson: true)
class HostsServicesChecks {
  Map<String, HostServicesChecks> map = {};
  HostsServicesChecks();

  factory HostsServicesChecks.fromJson(Map<String, dynamic> json) =>
      _$HostsServicesChecksFromJson(json);
  Map<String, dynamic> toJson() => _$HostsServicesChecksToJson(this);

  void add(String server, List<BasicService>? deps) {
    HostServicesChecks hostServices;
    if (!map.containsKey(server)) {
      hostServices = HostServicesChecks();
      map[server] = hostServices;
    } else {
      hostServices = map[server]!;
    }
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

@JsonSerializable(explicitToJson: true)
class HostServicesChecks {
  final HashSet<num> tcpPorts = HashSet<num>();
  final HashSet<num> udpPorts = HashSet<num>();
  final HashSet<String> otherChecks = HashSet<String>();
  HostServicesChecks();

  factory HostServicesChecks.fromJson(Map<String, dynamic> json) =>
      _$HostServicesChecksFromJson(json);

  @override
  String toString() {
    return 'HostServicesChecks{tcpPorts: $tcpPorts, udpPorts: $udpPorts, checks: $otherChecks}';
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> toJ = {};
    toJ['tcpPorts'] = jsonEncode(tcpPorts.toList());
    toJ['udpPorts'] = jsonEncode(udpPorts.toList());
    toJ['otherChecks'] = jsonEncode(otherChecks.toList());
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
              .equals(otherChecks, other.otherChecks);

  @override
  int get hashCode =>
      DeepCollectionEquality.unordered().hash(tcpPorts) ^
      DeepCollectionEquality.unordered().hash(udpPorts) ^
      DeepCollectionEquality.unordered().hash(otherChecks);
}
