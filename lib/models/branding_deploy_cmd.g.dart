// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branding_deploy_cmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BrandingDeployCmdCWProxy {
  BrandingDeployCmd debug(bool debug);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BrandingDeployCmd(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BrandingDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ```
  BrandingDeployCmd call({bool debug});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBrandingDeployCmd.copyWith(...)` or call `instanceOfBrandingDeployCmd.copyWith.fieldName(value)` for a single field.
class _$BrandingDeployCmdCWProxyImpl implements _$BrandingDeployCmdCWProxy {
  const _$BrandingDeployCmdCWProxyImpl(this._value);

  final BrandingDeployCmd _value;

  @override
  BrandingDeployCmd debug(bool debug) => call(debug: debug);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BrandingDeployCmd(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BrandingDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ```
  BrandingDeployCmd call({Object? debug = const $CopyWithPlaceholder()}) {
    return BrandingDeployCmd(
      debug: debug == const $CopyWithPlaceholder() || debug == null
          ? _value.debug
          // ignore: cast_nullable_to_non_nullable
          : debug as bool,
    );
  }
}

extension $BrandingDeployCmdCopyWith on BrandingDeployCmd {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBrandingDeployCmd.copyWith(...)` or `instanceOfBrandingDeployCmd.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BrandingDeployCmdCWProxy get copyWith =>
      _$BrandingDeployCmdCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandingDeployCmd _$BrandingDeployCmdFromJson(Map<String, dynamic> json) =>
    BrandingDeployCmd(debug: json['debug'] as bool? ?? false);

Map<String, dynamic> _$BrandingDeployCmdToJson(BrandingDeployCmd instance) =>
    <String, dynamic>{'debug': instance.debug};
