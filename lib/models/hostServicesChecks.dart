import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/basicService.dart';

import 'hostServiceCheck.dart';
import 'laServiceDeploy.dart';

part 'hostServicesChecks.g.dart';

@JsonSerializable(explicitToJson: true)
class HostsServicesChecks {
  // Server Id to check
  Map<String, Map<String, HostServiceCheck>> checks = {};
  HostsServicesChecks();

  factory HostsServicesChecks.fromJson(Map<String, dynamic> json) =>
      _$HostsServicesChecksFromJson(json);
  Map<String, dynamic> toJson() => _$HostsServicesChecksToJson(this);

  void setUrls(LAServiceDeploy sd, List<String> urls, String name) {
    Map<String, HostServiceCheck> hChecks = _getServiceCheck(sd.serverId);
    urls.forEach((url) {
      HostServiceCheck ch = hChecks.values
          .firstWhere((ch) => ch.type == ServiceCheckType.url && ch.args == url,
              orElse: () {
        var ch =
            HostServiceCheck(name: name, type: ServiceCheckType.url, args: url);
        hChecks[ch.id] = ch;
        return ch;
      });
      ch.serviceDeploys.add(sd.id);
      ch.services.add(sd.serviceId);
      hChecks[ch.id] = ch;
    });
  }

  void add(LAServiceDeploy sd, List<BasicService>? deps, String name) {
    Map<String, HostServiceCheck> hChecks = _getServiceCheck(sd.serverId);
    if (deps != null) {
      BasicService.toCheck(deps).forEach((dep) {
        dep.tcp.forEach((tcp) {
          HostServiceCheck ch = hChecks.values.firstWhere(
              (ch) => ch.type == ServiceCheckType.tcp && ch.args == "$tcp",
              orElse: () {
            var ch = HostServiceCheck(
                name: name, type: ServiceCheckType.tcp, args: "$tcp");
            hChecks[ch.id] = ch;
            return ch;
          });
          ch.serviceDeploys.add(sd.id);
          ch.services.add(sd.serviceId);
          hChecks[ch.id] = ch;
        });
        dep.udp.forEach((udp) {
          HostServiceCheck ch = hChecks.values.firstWhere(
              (ch) => ch.type == ServiceCheckType.udp && ch.args == "$udp",
              orElse: () {
            var ch = HostServiceCheck(
                name: name, type: ServiceCheckType.udp, args: "$udp");
            hChecks[ch.id] = ch;
            return ch;
          });
          ch.serviceDeploys.add(sd.id);
          ch.services.add(sd.serviceId);
          hChecks[ch.id] = ch;
        });
        HostServiceCheck ch = hChecks.values.firstWhere(
            (ch) => ch.type == ServiceCheckType.other && ch.args == dep.name,
            orElse: () {
          var ch = HostServiceCheck(
              name: name, type: ServiceCheckType.other, args: dep.name);
          hChecks[ch.id] = ch;
          return ch;
        });
        ch.serviceDeploys.add(sd.id);
        ch.services.add(sd.serviceId);
        hChecks[ch.id] = ch;

        checks[sd.serverId] = hChecks;
      });
    }
  }

  Map<String, HostServiceCheck> _getServiceCheck(String server) {
    return checks.putIfAbsent(server, () => {});
  }

  @override
  String toString() {
    return 'HostsServicesChecks{checks: $checks}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HostsServicesChecks &&
          runtimeType == other.runtimeType &&
          DeepCollectionEquality.unordered().equals(checks, other.checks);

  @override
  int get hashCode => DeepCollectionEquality.unordered().hash(checks);
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
