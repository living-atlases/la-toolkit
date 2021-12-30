// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brandingDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfBrandingDeployCmd.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfBrandingDeployCmd.copyWith.fieldName(...)`
class _BrandingDeployCmdCWProxy {
  final BrandingDeployCmd _value;

  const _BrandingDeployCmdCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `BrandingDeployCmd(...).copyWithNull(...)` to set certain fields to `null`. Prefer `BrandingDeployCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BrandingDeployCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  BrandingDeployCmd call({
    bool? debug,
  }) {
    return BrandingDeployCmd(
      debug: debug ?? _value.debug,
    );
  }

  BrandingDeployCmd debug(bool debug) => this(debug: debug);
}

extension BrandingDeployCmdCopyWith on BrandingDeployCmd {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass BrandingDeployCmd extends CommonCmd.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass BrandingDeployCmd extends CommonCmd.name.copyWith.fieldName(...)`
  _BrandingDeployCmdCWProxy get copyWith => _BrandingDeployCmdCWProxy(this);
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
