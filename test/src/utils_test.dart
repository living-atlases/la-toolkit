import 'package:la_toolkit/models/la_lat_lng.dart';
import 'package:la_toolkit/utils/map_utils.dart';
import 'package:la_toolkit/utils/string_utils.dart';

import 'package:latlong2/latlong.dart';
import 'package:objectid/objectid.dart';
import 'package:test/test.dart';

void main() {
  test('Capitalize strings', () {
    const String string = 'abc';
    expect(StringUtils.capitalize(string), equals('Abc'));
  });

  test('Capitalize strings', () {
    const String string = 'a';
    expect(StringUtils.capitalize(string), equals('A'));
  });

  test('Capitalize empty strings', () {
    const String string = '';
    expect(StringUtils.capitalize(string), equals(''));
  });

  test(
    'Given two LatLng points should generate LatLng variables for all services',
    () {
      // collectory uses the center:
      //   collectionsMap.centreMapLon=-8.66
      //   collectionsMap.centreMapLat=36.224
      // collectionsMap.defaultZoom=4
      // regions uses:
      //   map.bounds=[26.943, -18.848, 43.948, 4.805]
      // spatial
      //   lat: 38.8794495
      //   lng: -6.9706535
      //   zoom: 5
      //   defaultareas:
      //     - name: 'España'
      //       fqs: ['longitude:[-19.556 TO 5.493]', 'latitude:[26.588 TO 44.434]']
      //       wkt: 'POLYGON((-19.556 26.588, 5.493 26.588, 5.493 44.434, -19.556 44.434, -19.556 26.588))'
      //       areaSqKm: 4491002.4759
      //       bbox: [-19.556, 26.588, 5.493, 44.434]
      // List<double> mapBounds1stPoint = [44.4806, -19.4184];
      // List<double> mapBounds2ndPoint = [26.6767, 5.7989];

      const LatLng mapBounds1stPoint = LatLng(40.0, 20.0);
      const LatLng mapBounds2ndPoint = LatLng(20.0, 10.0);

      final Map<String, dynamic> invVariables = MapUtils.toInvVariables(
        mapBounds1stPoint,
        mapBounds2ndPoint,
      );
      expect(invVariables['LA_collectory_map_centreMapLat'], equals(30));
      expect(invVariables['LA_collectory_map_centreMapLng'], equals(15));
      expect(invVariables['LA_spatial_map_lan'], equals(30));
      expect(invVariables['LA_spatial_map_lng'], equals(15));
      expect(
        invVariables['LA_regions_map_bounds'],
        equals('[40.0, 20.0, 20.0, 10.0]'),
      );
      expect(
        invVariables['LA_spatial_map_areaSqKm'],
        equals(2390918.8297587633),
      );
      expect(
        invVariables['LA_spatial_map_bbox'],
        equals('[40.0, 20.0, 20.0, 10.0]'),
      );
      // print(invVariables);
    },
  );
  test('Area calculation', () {
    const Map<String, Object> world = <String, Object>{
      'type': 'Polygon',
      'coordinates': <List<List<int>>>[
        <List<int>>[
          <int>[-180, -90],
          <int>[-180, 90],
          <int>[180, 90],
          <int>[180, -90],
          <int>[-180, -90],
        ],
      ],
    };
    expect(MapUtils.areaKm2(world), equals(511207893.3958111));
  });

  test('dirName suggestions', () {
    const List<String> shortNames = <String>[
      '回尚芸策出多探政検済浜朝毎。車記隠地実問底欠葉下女保月兄介禄情内線裁。的点回父政埼芸岡',
      'LA Wäkßandâ',
      'ALA',
      'GBIF.ES',
      'LA',
      'Biodiversitäts-Atlas Österreich',
      'Лорем ипсум долор сит амет, фастидии ехпетенда при ид.',
      '議さだや設9売サコヱ助送首し康美イヤエテ決竹ハキ約泣ヘハ式追だじけ',
    ];
    for (final String shortName in shortNames) {
      final String uuid = ObjectId().toString();
      final String dirName = StringUtils.suggestDirName(
        shortName: shortName,
        id: uuid,
      );
      // print("$shortName: $dirName");
      expect(dirName.length >= 2, equals(true));
    }
  });

  test('dirName generated as expected', () {
    const List<List<String>> pairs = <List<String>>[
      <String>['GBIF.ES', 'gbif-es'],
      <String>['LA.TEST', 'la-test'],
      <String>['ALA', 'ala'],
    ];
    for (final List<String> pair in pairs) {
      final String uuid = ObjectId().toString();
      final String dirName = StringUtils.suggestDirName(
        shortName: pair[0],
        id: uuid,
      );
      // Uncomment to get a list of vars
      // print("${pair[0]}: $dirName");
      expect(dirName.length >= 2, equals(true));
      expect(dirName == pair[1], equals(true));
    }
  });

  test('LatLng to from json', () {
    final LALatLng mapBounds1stPoint = LALatLng(
      latitude: 40.0,
      longitude: 20.0,
    );
    // print(mapBounds1stPoint.toJson());
    expect(
      mapBounds1stPoint.toJson().toString().contains('latitude'),
      equals(true),
    );
    expect(
      LALatLng.fromJson(mapBounds1stPoint.toJson()) == mapBounds1stPoint,
      equals(true),
    );
  });
}
