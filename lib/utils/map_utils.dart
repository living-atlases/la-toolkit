// See in the future
// https://github.com/kb0/maps_toolkit
import 'package:area/area.dart';
import 'package:latlong2/latlong.dart';

class MapUtils {
  // https://pub.dev/packages/area
  static LatLng center(LatLng p1, LatLng p2) {
    return LatLng((p1.latitude + p2.latitude) / 2, (p1.longitude + p2.longitude) / 2);
  }

  static List<List<double>> toSquare(double p01, double p00, double p11, double p10) {
    final double x1 = p01;
    final double y1 = p00;
    final double x2 = p11;
    final double y2 = p10;
    final List<List<double>> area = <List<double>>[
      <double>[p00, p01],
      <double>[y2 - (y2 - y1), x2],
      <double>[p10, p11],
      <double>[y2, x2 - (x2 - x1)]
    ];
    return area;
  }

  static Map<String, dynamic> toInvVariables(LatLng p1, LatLng p2) {
    // double? p10, double? p1.longitude, double? p2.latitude, double? p2.longitude) {

    final LatLng center = MapUtils.center(p1, p2);
    final List<double> bbox = <double>[p1.latitude, p1.longitude, p2.latitude, p2.longitude];
    final List<List<double>> square = MapUtils.toSquare(p1.longitude, p1.latitude, p2.longitude, p2.latitude);

    final Map<String, Object> polygon = <String, Object>{
      'type': 'Polygon',
      'coordinates': <List<List<double>>>[
        <List<double>>[square[0], square[1], square[2], square[3], square[0]]
      ]
    };
    return <String, Object>{
      'LA_collectory_map_centreMapLat': center.latitude,
      'LA_collectory_map_centreMapLng': center.longitude,
      'LA_spatial_map_lan': center.latitude,
      'LA_spatial_map_lng': center.longitude,
      'LA_regions_map_bounds': '$bbox',
      'LA_spatial_map_bbox': '$bbox',
      'LA_spatial_map_areaSqKm': MapUtils.areaKm2(polygon)
    };
  }

  static double areaKm2(Map<String, Object> geojson) {
    return area(geojson) / 1000000;
  }
}
