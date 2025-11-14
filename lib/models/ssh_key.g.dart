// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssh_key.dart';

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

  SshKey fingerdebugPrint(String? fingerdebugPrint);

  SshKey encrypted(bool encrypted);

  SshKey missing(bool missing);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SshKey(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SshKey(...).copyWith(id: 12, name: "My name")
  /// ```
  SshKey call({
    String name,
    String privateKey,
    String publicKey,
    String? type,
    int? size,
    String desc,
    String? fingerdebugPrint,
    bool encrypted,
    bool missing,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSshKey.copyWith(...)` or call `instanceOfSshKey.copyWith.fieldName(value)` for a single field.
class _$SshKeyCWProxyImpl implements _$SshKeyCWProxy {
  const _$SshKeyCWProxyImpl(this._value);

  final SshKey _value;

  @override
  SshKey name(String name) => call(name: name);

  @override
  SshKey privateKey(String privateKey) => call(privateKey: privateKey);

  @override
  SshKey publicKey(String publicKey) => call(publicKey: publicKey);

  @override
  SshKey type(String? type) => call(type: type);

  @override
  SshKey size(int? size) => call(size: size);

  @override
  SshKey desc(String desc) => call(desc: desc);

  @override
  SshKey fingerdebugPrint(String? fingerdebugPrint) => call(fingerdebugPrint: fingerdebugPrint);

  @override
  SshKey encrypted(bool encrypted) => call(encrypted: encrypted);

  @override
  SshKey missing(bool missing) => call(missing: missing);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SshKey(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SshKey(...).copyWith(id: 12, name: "My name")
  /// ```
  SshKey call({
    Object? name = const $CopyWithPlaceholder(),
    Object? privateKey = const $CopyWithPlaceholder(),
    Object? publicKey = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? desc = const $CopyWithPlaceholder(),
    Object? fingerdebugPrint = const $CopyWithPlaceholder(),
    Object? encrypted = const $CopyWithPlaceholder(),
    Object? missing = const $CopyWithPlaceholder(),
  }) {
    return SshKey(
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      privateKey: privateKey == const $CopyWithPlaceholder() || privateKey == null
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
      fingerdebugPrint: fingerdebugPrint == const $CopyWithPlaceholder()
          ? _value.fingerdebugPrint
          // ignore: cast_nullable_to_non_nullable
          : fingerdebugPrint as String?,
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
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSshKey.copyWith(...)` or `instanceOfSshKey.copyWith.fieldName(...)`.
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
      size: (json['size'] as num?)?.toInt(),
      desc: json['desc'] as String,
      fingerdebugPrint: json['fingerdebugPrint'] as String?,
      encrypted: json['encrypted'] as bool,
      missing: json['missing'] as bool? ?? false,
    );

Map<String, dynamic> _$SshKeyToJson(SshKey instance) => <String, dynamic>{
      'name': instance.name,
      'publicKey': instance.publicKey,
      'type': instance.type,
      'size': instance.size,
      'desc': instance.desc,
      'fingerdebugPrint': instance.fingerdebugPrint,
      'encrypted': instance.encrypted,
      'missing': instance.missing,
    };
