import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/basicService.dart';

import 'hostServiceCheck.dart';
import 'laServer.dart';
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

  void setUrls(LAServiceDeploy sd, List<String> urls, String name,
      List<String> serversIds, bool full) {
    List<String> list = sd.serverId != null ? [sd.serverId!] : [];

    for (String serverId in full ? serversIds : list) {
      Map<String, HostServiceCheck> hChecks = _getServiceCheck(serverId);
      for (String url in urls) {
        HostServiceCheck ch = hChecks.values.firstWhere(
            (ch) => ch.type == ServiceCheckType.url && ch.args == url,
            orElse: () {
          var ch = HostServiceCheck(
              name: name, type: ServiceCheckType.url, args: url);
          hChecks[ch.id] = ch;
          return ch;
        });
        ch.serviceDeploys.add(sd.id);
        ch.services.add(sd.serviceId);
        hChecks[serverId] = ch;
      }
    }
  }

  void add(LAServiceDeploy sd, LAServer server, List<BasicService>? deps,
      String name, List<String> serversIds, bool full) {
    // For now, don't check docker swarm services
    if (sd.serverId == null) return;
    if (deps != null) {
      BasicService.toCheck(deps).forEach((dep) {
        for (num tcp in dep.tcp) {
          // Some services should be checked also from others servers like solr/cassandra
          for (String serverId in full && dep.reachableFromOtherServers
              ? serversIds
              : [sd.serverId!]) {
            Map<String, HostServiceCheck> hChecks = _getServiceCheck(serverId);
            HostServiceCheck ch = hChecks.values.firstWhere(
                (ch) => ch.type == ServiceCheckType.tcp && ch.args == "$tcp",
                orElse: () {
              var ch = HostServiceCheck(
                  name: name,
                  type: ServiceCheckType.tcp,
                  host: tcp == 8983 || tcp == 9000 || server.id != serverId
                      ? server.name
                      : "localhost",
                  args: "$tcp");
              hChecks[ch.id] = ch;
              return ch;
            });
            ch.serviceDeploys.add(sd.id);
            ch.services.add(sd.serviceId);
            hChecks[ch.id] = ch;
          }
        }
        String serverId = sd.serverId!;
        Map<String, HostServiceCheck> hChecks = _getServiceCheck(serverId);
        for (num udp in dep.udp) {
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
        }
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
        checks[serverId] = hChecks;
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
          const DeepCollectionEquality.unordered().equals(checks, other.checks);

  @override
  int get hashCode => const DeepCollectionEquality.unordered().hash(checks);
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
          const DeepCollectionEquality.unordered()
              .equals(tcpPorts, other.tcpPorts) &&
          const DeepCollectionEquality.unordered()
              .equals(udpPorts, other.udpPorts) &&
          const DeepCollectionEquality.unordered()
              .equals(otherChecks, other.otherChecks) &&
          listEquals(urls, other.urls);

  @override
  int get hashCode =>
      const DeepCollectionEquality.unordered().hash(tcpPorts) ^
      const DeepCollectionEquality.unordered().hash(udpPorts) ^
      const DeepCollectionEquality.unordered().hash(otherChecks) ^
      const ListEquality().hash(urls);

  void setUrls(List<String> urls) {
    this.urls.addAll(urls);
  }
}
