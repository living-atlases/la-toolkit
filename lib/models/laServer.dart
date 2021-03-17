import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:uuid/uuid.dart';

part 'laServer.g.dart';

enum ServiceStatus { unknown, success, failed }

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAServer {
  String uuid;
  String name;
  String ip;
  @JsonSerializable(nullable: false)
  int sshPort;
  String sshUser;
  @JsonSerializable(nullable: false)
  List<String> aliases;
  SshKey sshKey;
  @JsonSerializable(nullable: false)
  List<String> gateways;
  ServiceStatus reachable;
  ServiceStatus sshReachable;
  ServiceStatus sudoEnabled;
  String osName;
  String osVersion;

  LAServer(
      {String uuid,
      this.name,
      String ip,
      this.sshPort: 22,
      this.sshUser,
      List<String> aliases,
      List<String> gateways,
      this.sshKey,
      this.reachable: ServiceStatus.unknown,
      this.sshReachable: ServiceStatus.unknown,
      this.sudoEnabled: ServiceStatus.unknown,
      this.osName = "",
      this.osVersion = ""})
      : uuid = uuid ?? Uuid().v4(),
        this.aliases = aliases ?? [],
        this.gateways = gateways ?? [],
        this.ip = ip ?? "";

  factory LAServer.fromJson(Map<String, dynamic> json) =>
      _$LAServerFromJson(json);
  Map<String, dynamic> toJson() => _$LAServerToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAServer &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          uuid == other.uuid &&
          ip == other.ip &&
          sshPort == other.sshPort &&
          sshUser == other.sshUser &&
          sshKey == other.sshKey &&
          listEquals(aliases, other.aliases) &&
          listEquals(gateways, other.gateways) &&
          osName == other.osName &&
          osVersion == other.osVersion &&
          reachable == other.reachable &&
          sshReachable == other.sshReachable &&
          sudoEnabled == other.sudoEnabled;

  @override
  int get hashCode =>
      name.hashCode ^
      uuid.hashCode ^
      ip.hashCode ^
      sshPort.hashCode ^
      sshUser.hashCode ^
      sshKey.hashCode ^
      DeepCollectionEquality.unordered().hash(aliases) ^
      DeepCollectionEquality.unordered().hash(gateways) ^
      osName.hashCode ^
      osVersion.hashCode ^
      reachable.hashCode ^
      sshReachable.hashCode ^
      sudoEnabled.hashCode;

  bool isReady() {
    return this.reachable == ServiceStatus.success &&
        this.sshReachable == ServiceStatus.success &&
        this.sudoEnabled == ServiceStatus.success;
  }

  @override
  String toString() {
    return '''
$name ($uuid)${ip.length > 0 ? ', ' + ip : ' '}, isReady: ${isReady()} osName: $osName osVersion: $osVersion ${aliases.length > 0 ? ' ' + aliases.join(' ') : ''}
''';
  }

  static List<LAServer> upsert(List<LAServer> servers, LAServer laServer) {
    if (servers.map((s) => s.uuid).toList().contains(laServer.uuid)) {
      servers = servers
          .map((current) => current.uuid == laServer.uuid ? laServer : current)
          .toList();
    } else {
      servers.add(laServer);
    }
    return servers;
  }
}
