// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sshKey.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SshKeyCWProxy {
  SshKey name(String name);

  SshKey privateKey(String privateKey);

  SshKey publicKey(String publicKey);

  SshKey type(String? type);

  SshKey size(int? size);

  SshKey desc(String desc);

  SshKey fingerprint(String? fingerprint);

  SshKey encrypted(bool encrypted);

  SshKey missing(bool missing);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SshKey(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SshKey(...).copyWith(id: 12, name: "My name")
  /// ````
  SshKey call({
    String? name,
    String? privateKey,
    String? publicKey,
    String? type,
    int? size,
    String? desc,
    String? fingerprint,
    bool? encrypted,
    bool? missing,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSshKey.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSshKey.copyWith.fieldName(...)`
class _$SshKeyCWProxyImpl implements _$SshKeyCWProxy {
  const _$SshKeyCWProxyImpl(this._value);

  final SshKey _value;

  @override
  SshKey name(String name) => this(name: name);

  @override
  SshKey privateKey(String privateKey) => this(privateKey: privateKey);

  @override
  SshKey publicKey(String publicKey) => this(publicKey: publicKey);

  @override
  SshKey type(String? type) => this(type: type);

  @override
  SshKey size(int? size) => this(size: size);

  @override
  SshKey desc(String desc) => this(desc: desc);

  @override
  SshKey fingerprint(String? fingerprint) => this(fingerprint: fingerprint);

  @override
  SshKey encrypted(bool encrypted) => this(encrypted: encrypted);

  @override
  SshKey missing(bool missing) => this(missing: missing);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SshKey(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SshKey(...).copyWith(id: 12, name: "My name")
  /// ````
  SshKey call({
    Object? name = const $CopyWithPlaceholder(),
    Object? privateKey = const $CopyWithPlaceholder(),
    Object? publicKey = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? desc = const $CopyWithPlaceholder(),
    Object? fingerprint = const $CopyWithPlaceholder(),
    Object? encrypted = const $CopyWithPlaceholder(),
    Object? missing = const $CopyWithPlaceholder(),
  }) {
    return SshKey(
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      privateKey:
          privateKey == const $CopyWithPlaceholder() || privateKey == null
              ? _value.privateKey
              // ignore: cast_nullable_to_non_nullable
              : privateKey as String,
      publicKey: publicKey == const $CopyWithPlaceholder() || publicKey == null
          ? _value.publicKey
          // ignore: cast_nullable_to_non_nullable
          : publicKey as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String?,
      size: size == const $CopyWithPlaceholder()
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int?,
      desc: desc == const $CopyWithPlaceholder() || desc == null
          ? _value.desc
          // ignore: cast_nullable_to_non_nullable
          : desc as String,
      fingerprint: fingerprint == const $CopyWithPlaceholder()
          ? _value.fingerprint
          // ignore: cast_nullable_to_non_nullable
          : fingerprint as String?,
      encrypted: encrypted == const $CopyWithPlaceholder() || encrypted == null
          ? _value.encrypted
          // ignore: cast_nullable_to_non_nullable
          : encrypted as bool,
      missing: missing == const $CopyWithPlaceholder() || missing == null
          ? _value.missing
          // ignore: cast_nullable_to_non_nullable
          : missing as bool,
    );
  }
}

extension $SshKeyCopyWith on SshKey {
  /// Returns a callable class that can be used as follows: `instanceOfSshKey.copyWith(...)` or like so:`instanceOfSshKey.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SshKeyCWProxy get copyWith => _$SshKeyCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SshKey _$SshKeyFromJson(Map<String, dynamic> json) => SshKey(
      name: json['name'] as String,
      publicKey: json['publicKey'] as String? ?? '',
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
