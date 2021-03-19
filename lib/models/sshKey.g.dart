// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sshKey.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension SshKeyCopyWith on SshKey {
  SshKey copyWith({
    String? desc,
    bool? encrypted,
    String? fingerprint,
    bool? missing,
    String? name,
    String? privateKey,
    String? publicKey,
    int? size,
    String? type,
  }) {
    return SshKey(
      desc: desc ?? this.desc,
      encrypted: encrypted ?? this.encrypted,
      fingerprint: fingerprint ?? this.fingerprint,
      missing: missing ?? this.missing,
      name: name ?? this.name,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      size: size ?? this.size,
      type: type ?? this.type,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SshKey _$SshKeyFromJson(Map<String, dynamic> json) {
  return SshKey(
    name: json['name'] as String,
    publicKey: json['publicKey'] as String,
    type: json['type'] as String?,
    size: json['size'] as int?,
    desc: json['desc'] as String,
    fingerprint: json['fingerprint'] as String?,
    encrypted: json['encrypted'] as bool,
    missing: json['missing'] as bool,
  );
}

Map<String, dynamic> _$SshKeyToJson(SshKey instance) => <String, dynamic>{
      'name': instance.name,
      'publicKey': instance.publicKey,
      'type': instance.type,
      'size': instance.size,
      'desc': instance.desc,
      'fingerprint': instance.fingerprint,
      'encrypted': instance.encrypted,
      'missing': instance.missing,
    };
