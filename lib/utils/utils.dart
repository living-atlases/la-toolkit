import 'package:area/area.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

class ListUtils {
  static bool notNull(Object o) => o != null;

// What is the best way to optionally include a widget in a list of children
// https://github.com/flutter/flutter/issues/3783

  static List<Widget> listWithoutNulls(List<Widget> children) =>
      children.where(notNull).toList();
}

class AppUtils {
  static bool isDev() {
    return !kReleaseMode;
  }

  static bool isDemo() {
    return env['DEMO'].parseBool();
  }

  static String proxyImg(imgUrl) {
    return "${env['BACKEND']}api/v1/image-proxy/${Uri.encodeFull(imgUrl)}";
  }
}

class MapUtils {
  // https://pub.dev/packages/area
  static List<double> center(List<double> p1, List<double> p2) {
    return [(p1[0] + p2[0]) / 2, (p1[1] + p2[1]) / 2];
  }

  static List<List<double>> toSquare(List<double> p1, List<double> p2) {
    List<List<double>> area = []..length = 4;
    area[0] = p1;
    area[2] = p2;
    var x1 = area[0][1];
    var y1 = area[0][0];
    var x2 = area[2][1];
    var y2 = area[2][0];

    area[1] = [y2 - (y2 - y1), x2];
    area[3] = [y2, x2 - (x2 - x1)];
    return area;
  }

  static Map<String, dynamic> toInvVariables(List<double> p1, List<double> p2) {
    if (p1 == null || p2 == null) return {};
    var center = MapUtils.center(p1, p2);
    var bbox = [p1[0], p1[1], p2[0], p2[1]];
    var square = MapUtils.toSquare(p1, p2);

    var polygon = {
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
