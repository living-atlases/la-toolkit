// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laLatLng.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LALatLngCWProxy {
  LALatLng latitude(double latitude);

  LALatLng longitude(double longitude);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LALatLng(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LALatLng(...).copyWith(id: 12, name: "My name")
  /// ````
  LALatLng call({
    double latitude,
    double longitude,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLALatLng.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLALatLng.copyWith.fieldName(...)`
class _$LALatLngCWProxyImpl implements _$LALatLngCWProxy {
  const _$LALatLngCWProxyImpl(this._value);

  final LALatLng _value;

  @override
  LALatLng latitude(double latitude) => this(latitude: latitude);

  @override
  LALatLng longitude(double longitude) => this(longitude: longitude);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LALatLng(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LALatLng(...).copyWith(id: 12, name: "My name")
  /// ````
  LALatLng call({
    Object? latitude = const $CopyWithPlaceholder(),
    Object? longitude = const $CopyWithPlaceholder(),
  }) {
    return LALatLng(
      latitude: latitude == const $CopyWithPlaceholder()
          ? _value.latitude
          // ignore: cast_nullable_to_non_nullable
          : latitude as double,
      longitude: longitude == const $CopyWithPlaceholder()
          ? _value.longitude
          // ignore: cast_nullable_to_non_nullable
          : longitude as double,
    );
  }
}

extension $LALatLngCopyWith on LALatLng {
  /// Returns a callable class that can be used as follows: `instanceOfLALatLng.copyWith(...)` or like so:`instanceOfLALatLng.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LALatLngCWProxy get copyWith => _$LALatLngCWProxyImpl(this);
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
