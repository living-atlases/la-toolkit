import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'laLatLng.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LALatLng extends LatLng {
  LALatLng({required double latitude, required double longitude})
      : super(latitude, longitude);

  LALatLng.from(double latitude, double longitude) : super(latitude, longitude);

  @override
  factory LALatLng.fromJson(Map<String, dynamic> json) =>
      _$LALatLngFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LALatLngToJson(this);
}
