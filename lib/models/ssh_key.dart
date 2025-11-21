import 'package:flutter/foundation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ssh_key.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
@CopyWith()
class SshKey {
  SshKey(
      {required this.name,
      this.privateKey = '',
      this.publicKey = '',
      this.type,
      this.size,
      required this.desc,
      this.fingerdebugPrint,
      required this.encrypted,
      this.missing = false});

  factory SshKey.fromJson(Map<String, dynamic> json) => _$SshKeyFromJson(json);
  String name;
  @JsonKey(includeToJson: false, includeFromJson: false)
  String privateKey;
  String publicKey;
  String? type;
  int? size;
  String desc;
  String? fingerdebugPrint;
  bool encrypted;
  bool missing;

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
          fingerdebugPrint == other.fingerdebugPrint &&
          encrypted == other.encrypted;

  @override
  int get hashCode =>
      name.hashCode ^
      publicKey.hashCode ^
      type.hashCode ^
      size.hashCode ^
      desc.hashCode ^
      fingerdebugPrint.hashCode ^
      encrypted.hashCode;
}
