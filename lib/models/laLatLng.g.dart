// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laLatLng.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LALatLngCopyWith on LALatLng {
  LALatLng copyWith({
    double? latitude,
    double? longitude,
  }) {
    return LALatLng(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LALatLng _$LALatLngFromJson(Map<String, dynamic> json) {
  return LALatLng(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );
}

Map<String, dynamic> _$LALatLngToJson(LALatLng instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
