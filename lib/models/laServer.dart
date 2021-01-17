import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'laServer.g.dart';

enum ServiceStatus { unknown, success, failed }

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAServer {
  String name;
  String ipv4;
  @JsonSerializable(nullable: false)
  int sshPort;
  @JsonSerializable(nullable: false)
  List<String> aliases;
  String sshPrivateKey;
  String proxyJump;
  int proxyJumpPort;
  String proxyJumpUser;
  ServiceStatus reachable;
  ServiceStatus sshReachable;
  ServiceStatus sudoEnabled;

  LAServer(
      {this.name,
      ipv4,
      this.sshPort: 22,
      List<String> aliases,
      this.sshPrivateKey,
      this.proxyJump,
      this.proxyJumpPort,
      this.proxyJumpUser,
      this.reachable: ServiceStatus.unknown,
      this.sshReachable: ServiceStatus.unknown,
      this.sudoEnabled: ServiceStatus.unknown})
      : this.aliases = aliases ?? [],
        this.ipv4 = ipv4 ?? "";

  factory LAServer.fromJson(Map<String, dynamic> json) =>
      _$LAServerFromJson(json);
  Map<String, dynamic> toJson() => _$LAServerToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAServer &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return "$name${ipv4.length > 0 ? ', ' + ipv4 : ' '} ${aliases.length > 0 ? ', ' + aliases.join(', ') : ''}";
  }

  static List<LAServer> upsert(List<LAServer> servers, LAServer laServer) {
    if (servers.contains(laServer)) {
      servers = servers
          .map((current) => current == laServer ? laServer : current)
          .toList();
    } else {
      servers.add(laServer);
    }
    return servers;
  }
}
