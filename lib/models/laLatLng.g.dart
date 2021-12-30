// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laLatLng.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfLALatLng.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfLALatLng.copyWith.fieldName(...)`
class _LALatLngCWProxy {
  final LALatLng _value;

  const _LALatLngCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `LALatLng(...).copyWithNull(...)` to set certain fields to `null`. Prefer `LALatLng(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LALatLng(...).copyWith(id: 12, name: "My name")
  /// ````
  LALatLng call({
    double? latitude,
    double? longitude,
  }) {
    return LALatLng(
      latitude: latitude ?? _value.latitude,
      longitude: longitude ?? _value.longitude,
    );
  }

  LALatLng latitude(double latitude) => this(latitude: latitude);

  LALatLng longitude(double longitude) => this(longitude: longitude);
}

extension LALatLngCopyWith on LALatLng {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass LALatLng extends LatLng.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass LALatLng extends LatLng.name.copyWith.fieldName(...)`
  _LALatLngCWProxy get copyWith => _LALatLngCWProxy(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LALatLng _$LALatLngFromJson(Map<String, dynamic> json) => LALatLng(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$LALatLngToJson(LALatLng instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
