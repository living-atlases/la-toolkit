import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sshKey.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class SshKey {
  String name;
  @JsonKey(ignore: true)
  String privateKey;
  String publicKey;
  String type;
  int size;
  String desc;
  String fingerprint;
  bool encrypted;
  bool missing;

  SshKey(
      {this.name,
      this.privateKey = "",
      this.publicKey = "",
      this.type,
      this.size,
      this.desc,
      this.fingerprint,
      this.encrypted,
      this.missing: false});

  factory SshKey.fromJson(Map<String, dynamic> json) => _$SshKeyFromJson(json);
  Map<String, dynamic> toJson() => _$SshKeyToJson(this);

  @override
  String toString() {
    return 'SshKey {name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SshKey &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          publicKey == other.publicKey &&
          type == other.type &&
          size == other.size &&
          desc == other.desc &&
          fingerprint == other.fingerprint &&
          encrypted == other.encrypted;

  @override
  int get hashCode =>
      name.hashCode ^
      publicKey.hashCode ^
      type.hashCode ^
      size.hashCode ^
      desc.hashCode ^
      fingerprint.hashCode ^
      encrypted.hashCode;
}
