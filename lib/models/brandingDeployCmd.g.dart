// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brandingDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BrandingDeployCmdCWProxy {
  BrandingDeployCmd debug(bool debug);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BrandingDeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BrandingDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  BrandingDeployCmd call({
    bool? debug,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBrandingDeployCmd.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBrandingDeployCmd.copyWith.fieldName(...)`
class _$BrandingDeployCmdCWProxyImpl implements _$BrandingDeployCmdCWProxy {
  const _$BrandingDeployCmdCWProxyImpl(this._value);

  final BrandingDeployCmd _value;

  @override
  BrandingDeployCmd debug(bool debug) => this(debug: debug);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BrandingDeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BrandingDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  BrandingDeployCmd call({
    Object? debug = const $CopyWithPlaceholder(),
  }) {
    return BrandingDeployCmd(
      debug: debug == const $CopyWithPlaceholder() || debug == null
          ? _value.debug
          // ignore: cast_nullable_to_non_nullable
          : debug as bool,
    );
  }
}

extension $BrandingDeployCmdCopyWith on BrandingDeployCmd {
  /// Returns a callable class that can be used as follows: `instanceOfBrandingDeployCmd.copyWith(...)` or like so:`instanceOfBrandingDeployCmd.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BrandingDeployCmdCWProxy get copyWith =>
      _$BrandingDeployCmdCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandingDeployCmd _$BrandingDeployCmdFromJson(Map<String, dynamic> json) =>
    BrandingDeployCmd(
      debug: json['debug'] as bool? ?? false,
    );

Map<String, dynamic> _$BrandingDeployCmdToJson(BrandingDeployCmd instance) =>
    <String, dynamic>{
      'debug': instance.debug,
    };
