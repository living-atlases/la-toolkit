// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sshKey.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfSshKey.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfSshKey.copyWith.fieldName(...)`
class _SshKeyCWProxy {
  final SshKey _value;

  const _SshKeyCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `SshKey(...).copyWithNull(...)` to set certain fields to `null`. Prefer `SshKey(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SshKey(...).copyWith(id: 12, name: "My name")
  /// ````
  SshKey call({
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
      desc: desc ?? _value.desc,
      encrypted: encrypted ?? _value.encrypted,
      fingerprint: fingerprint ?? _value.fingerprint,
      missing: missing ?? _value.missing,
      name: name ?? _value.name,
      privateKey: privateKey ?? _value.privateKey,
      publicKey: publicKey ?? _value.publicKey,
      size: size ?? _value.size,
      type: type ?? _value.type,
    );
  }

  SshKey fingerprint(String? fingerprint) => fingerprint == null
      ? _value._copyWithNull(fingerprint: true)
      : this(fingerprint: fingerprint);

  SshKey size(int? size) =>
      size == null ? _value._copyWithNull(size: true) : this(size: size);

  SshKey type(String? type) =>
      type == null ? _value._copyWithNull(type: true) : this(type: type);

  SshKey desc(String desc) => this(desc: desc);

  SshKey encrypted(bool encrypted) => this(encrypted: encrypted);

  SshKey missing(bool missing) => this(missing: missing);

  SshKey name(String name) => this(name: name);

  SshKey privateKey(String privateKey) => this(privateKey: privateKey);

  SshKey publicKey(String publicKey) => this(publicKey: publicKey);
}

extension SshKeyCopyWith on SshKey {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass SshKey.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass SshKey.name.copyWith.fieldName(...)`
  _SshKeyCWProxy get copyWith => _SshKeyCWProxy(this);

  SshKey _copyWithNull({
    bool fingerprint = false,
    bool size = false,
    bool type = false,
  }) {
    return SshKey(
      desc: desc,
      encrypted: encrypted,
      fingerprint: fingerprint == true ? null : this.fingerprint,
      missing: missing,
      name: name,
      privateKey: privateKey,
      publicKey: publicKey,
      size: size == true ? null : this.size,
      type: type == true ? null : this.type,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SshKey _$SshKeyFromJson(Map<String, dynamic> json) => SshKey(
      name: json['name'] as String,
      publicKey: json['publicKey'] as String? ?? "",
      type: json['type'] as String?,
      size: json['size'] as int?,
      desc: json['desc'] as String,
      fingerprint: json['fingerprint'] as String?,
      encrypted: json['encrypted'] as bool,
      missing: json['missing'] as bool? ?? false,
    );

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
