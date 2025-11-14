// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'la_lat_lng..dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LALatLngCWProxy {
  LALatLng latitude(double latitude);

  LALatLng longitude(double longitude);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `LALatLng(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// LALatLng(...).copyWith(id: 12, name: "My name")
  /// ```
  LALatLng call({
    double latitude,
    double longitude,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfLALatLng.copyWith(...)` or call `instanceOfLALatLng.copyWith.fieldName(value)` for a single field.
class _$LALatLngCWProxyImpl implements _$LALatLngCWProxy {
  const _$LALatLngCWProxyImpl(this._value);

  final LALatLng _value;

  @override
  LALatLng latitude(double latitude) => call(latitude: latitude);

  @override
  LALatLng longitude(double longitude) => call(longitude: longitude);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `LALatLng(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// LALatLng(...).copyWith(id: 12, name: "My name")
  /// ```
  LALatLng call({
    Object? latitude = const $CopyWithPlaceholder(),
    Object? longitude = const $CopyWithPlaceholder(),
  }) {
    return LALatLng(
      latitude: latitude == const $CopyWithPlaceholder() || latitude == null
          ? _value.latitude
          // ignore: cast_nullable_to_non_nullable
          : latitude as double,
      longitude: longitude == const $CopyWithPlaceholder() || longitude == null
          ? _value.longitude
          // ignore: cast_nullable_to_non_nullable
          : longitude as double,
    );
  }
}

extension $LALatLngCopyWith on LALatLng {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfLALatLng.copyWith(...)` or `instanceOfLALatLng.copyWith.fieldName(...)`.
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
