// See in the future
// https://github.com/kb0/maps_toolkit
import 'dart:math' show sin;

import 'package:latlong2/latlong.dart';

class MapUtils {
  // https://pub.dev/packages/area
  static LatLng center(LatLng p1, LatLng p2) {
    return LatLng(
      (p1.latitude + p2.latitude) / 2,
      (p1.longitude + p2.longitude) / 2,
    );
  }

  static List<List<double>> toSquare(
    double p01,
    double p00,
    double p11,
    double p10,
  ) {
    final double x1 = p01;
    final double y1 = p00;
    final double x2 = p11;
    final double y2 = p10;
    final List<List<double>> area = <List<double>>[
      <double>[p00, p01],
      <double>[y2 - (y2 - y1), x2],
      <double>[p10, p11],
      <double>[y2, x2 - (x2 - x1)],
    ];
    return area;
  }

  static Map<String, dynamic> toInvVariables(LatLng p1, LatLng p2) {
    // double? p10, double? p1.longitude, double? p2.latitude, double? p2.longitude) {

    final LatLng center = MapUtils.center(p1, p2);
    final List<double> bbox = <double>[
      p1.latitude,
      p1.longitude,
      p2.latitude,
      p2.longitude,
    ];
    final List<List<double>> square = MapUtils.toSquare(
      p1.longitude,
      p1.latitude,
      p2.longitude,
      p2.latitude,
    );

    final Map<String, Object> polygon = <String, Object>{
      'type': 'Polygon',
      'coordinates': <List<List<double>>>[
        <List<double>>[square[0], square[1], square[2], square[3], square[0]],
      ],
    };
    return <String, Object>{
      'LA_collectory_map_centreMapLat': center.latitude,
      'LA_collectory_map_centreMapLng': center.longitude,
      'LA_spatial_map_lan': center.latitude,
      'LA_spatial_map_lng': center.longitude,
      'LA_regions_map_bounds': '$bbox',
      'LA_spatial_map_bbox': '$bbox',
      'LA_spatial_map_areaSqKm': MapUtils.areaKm2(polygon),
    };
  }

  /// Area of a GeoJSON Polygon or MultiPolygon, in km2.
  static double areaKm2(Map<String, Object> geojson) {
    final Object? coords = geojson['coordinates'];
    double m2 = 0;
    if (geojson['type'] == 'Polygon') {
      m2 = _polygonArea(coords! as List<dynamic>);
    } else if (geojson['type'] == 'MultiPolygon') {
      for (final dynamic polygon in coords! as List<dynamic>) {
        m2 += _polygonArea(polygon as List<dynamic>);
      }
    }
    return m2 / 1000000;
  }

  static const int _wgs84Radius = 6378137;

  static double _rad(num degrees) => degrees * pi / 180;

  /// The outer ring minus the holes, in m2.
  static double _polygonArea(List<dynamic> rings) {
    if (rings.isEmpty) {
      return 0;
    }
    double a = _ringArea(rings[0] as List<dynamic>).abs();
    for (final dynamic hole in rings.skip(1)) {
      a -= _ringArea(hole as List<dynamic>).abs();
    }
    return a;
  }

  /// Signed area of a ring projected on the sphere, in m2: R. G. Chamberlain
  /// and W. H. Duquette, "Some Algorithms for Polygons on a Sphere", JPL
  /// Publication 07-03 (2007). The same formula (and summation order) as the
  /// `area` package this replaced, whose only fault was requiring Flutter.
  static double _ringArea(List<dynamic> ring) {
    final int n = ring.length;
    if (n <= 2) {
      return 0;
    }
    double a = 0;
    for (int i = 0; i < n; i++) {
      final List<dynamic> p1 =
          ring[i == n - 1 ? n - 1 : (i == n - 2 ? n - 2 : i)] as List<dynamic>;
      final List<dynamic> p2 =
          ring[i == n - 1 ? 0 : (i == n - 2 ? n - 1 : i + 1)] as List<dynamic>;
      final List<dynamic> p3 =
          ring[i == n - 1 ? 1 : (i == n - 2 ? 0 : i + 2)] as List<dynamic>;
      a += (_rad(p3[0] as num) - _rad(p1[0] as num)) * sin(_rad(p2[1] as num));
    }
    return a * _wgs84Radius * _wgs84Radius / 2;
  }
}
