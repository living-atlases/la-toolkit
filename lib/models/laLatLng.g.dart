// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laLatLng.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LALatLng _$LALatLngFromJson(Map<String, dynamic> json) {
  return LALatLng(
    (json['latitude'] as num).toDouble(),
    (json['longitude'] as num).toDouble(),
  );
}

Map<String, dynamic> _$LALatLngToJson(LALatLng instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
