// See in the future
// https://github.com/kb0/maps_toolkit
import 'package:area/area.dart';

class MapUtils {
  // https://pub.dev/packages/area
  static List<double> center(double p01, double p00, double p11, double p10) {
    return [(p00 + p10) / 2, (p01 + p11) / 2];
  }

  static List<List<double>> toSquare(
      double p01, double p00, double p11, double p10) {
    double x1 = p01;
    double y1 = p00;
    double x2 = p11;
    double y2 = p10;
    List<List<double>> area = [
      [p00, p01],
      [y2 - (y2 - y1), x2],
      [p10, p11],
      [y2, x2 - (x2 - x1)]
    ];
    return area;
  }

  static Map<String, dynamic> toInvVariables(
      double? p10, double? p11, double? p20, double? p21) {
    if (p10 == null || p11 == null || p20 == null || p21 == null) return {};
    List<double> center = MapUtils.center(p11, p10, p21, p20);
    List<double> bbox = [p10, p11, p20, p21];
    List<List<double>> square = MapUtils.toSquare(p11, p10, p21, p20);

    Map<String, Object> polygon = {
      'type': 'Polygon',
      'coordinates': [
        [square[0], square[1], square[2], square[3], square[0]]
      ]
    };
    return {
      'LA_collectory_map_centreMapLat': center[0],
      'LA_collectory_map_centreMapLng': center[1],
      'LA_spatial_map_lan': center[0],
      'LA_spatial_map_lng': center[1],
      'LA_regions_map_bounds': '$bbox',
      'LA_spatial_map_bbox': '$bbox',
      "LA_spatial_map_areaSqKm": MapUtils.areaKm2(polygon)
    };
  }

  static double areaKm2(Map<String, Object> geojson) {
    return area(geojson) / 1000000;
  }
}
