// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CmdCWProxy {
  Cmd id(String? id);

  Cmd type(CmdType type);

  Cmd properties(Map<String, dynamic> properties);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Cmd(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Cmd(...).copyWith(id: 12, name: "My name")
  /// ```
  Cmd call({String? id, CmdType type, Map<String, dynamic> properties});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfCmd.copyWith(...)` or call `instanceOfCmd.copyWith.fieldName(value)` for a single field.
class _$CmdCWProxyImpl implements _$CmdCWProxy {
  const _$CmdCWProxyImpl(this._value);

  final Cmd _value;

  @override
  Cmd id(String? id) => call(id: id);

  @override
  Cmd type(CmdType type) => call(type: type);

  @override
  Cmd properties(Map<String, dynamic> properties) =>
      call(properties: properties);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Cmd(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Cmd(...).copyWith(id: 12, name: "My name")
  /// ```
  Cmd call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? properties = const $CopyWithPlaceholder(),
  }) {
    return Cmd(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as CmdType,
      properties:
          properties == const $CopyWithPlaceholder() || properties == null
          ? _value.properties
          // ignore: cast_nullable_to_non_nullable
          : properties as Map<String, dynamic>,
    );
  }
}

extension $CmdCopyWith on Cmd {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfCmd.copyWith(...)` or `instanceOfCmd.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CmdCWProxy get copyWith => _$CmdCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cmd _$CmdFromJson(Map<String, dynamic> json) => Cmd(
  id: json['id'] as String?,
  type: $enumDecode(_$CmdTypeEnumMap, json['type']),
  properties: json['properties'] as Map<String, dynamic>,
);

Map<String, dynamic> _$CmdToJson(Cmd instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$CmdTypeEnumMap[instance.type]!,
  'properties': instance.properties,
};

const _$CmdTypeEnumMap = {
  CmdType.brandingDeploy: 'brandingDeploy',
  CmdType.deploy: 'deploy',
  CmdType.preDeploy: 'preDeploy',
  CmdType.postDeploy: 'postDeploy',
  CmdType.laPipelines: 'laPipelines',
  CmdType.bash: 'bash',
};
