import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:latlong2/latlong.dart';
import 'package:redux/redux.dart';

import '../la_theme.dart';
import '../models/app_state.dart';
import '../models/la_lat_lng.dart';
import '../models/la_project.dart';
import '../redux/actions.dart';
import 'scale_layer_plugin_option.dart';
import 'zoombuttons_plugin_option.dart';

class MapAreaSelector extends StatefulWidget {
  const MapAreaSelector({super.key});

  @override
  State<MapAreaSelector> createState() => _MapAreaSelectorState();
}

class _MapAreaSelectorState extends State<MapAreaSelector> {
  List<LatLng?> area = <LatLng?>[]..length = 5;
  List<LatLng?> projectArea = <LatLng?>[]..length = 5;
  bool firstPoint = true;
  final MapController mapController = MapController();
  LAProject? _project;
  static const double _minZoom = 1.0;
  static const double _maxZoom = 20.0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _MapAreaSelectorViewModel>(
        distinct: true,
        converter: (Store<AppState> store) {
          return _MapAreaSelectorViewModel(
              currentProject: store.state.currentProject,
              onUpdateProject: (LAProject? project) =>
                  store.dispatch(SaveCurrentProject(project!)));
        },
        builder: (BuildContext context, _MapAreaSelectorViewModel vm) {
          _project = vm.currentProject;

          final LALatLng fstPoint = _project!.mapBoundsFstPoint;
          final LALatLng sndPoint = _project!.mapBoundsSndPoint;
          projectArea = <LatLng?>[fstPoint, null, sndPoint, null, fstPoint];
          _calSquare(projectArea);

          final List<Marker> markers = area
              .where((LatLng? latLng) => latLng != null)
              .map((LatLng? latLng) {
            return Marker(
              width: 80.0,
              height: 80.0,
              point: latLng!,
              builder: (BuildContext ctx) =>
                  const Icon(Icons.circle, size: 16, color: Colors.blueGrey),
            );
          }).toList();
          List<LatLng> areaNN = <LatLng>[];
          List<LatLng> projectAreaNN = <LatLng>[];
          if (projectArea[0] != null && projectArea[2] != null) {
            projectAreaNN = projectArea.whereType<LatLng>().toList();
          }
          if (area[0] != null && area[2] != null) {
            areaNN = area.whereType<LatLng>().toList();
          }
          // ignore: sized_box_for_whitespace
          return Container(
              height: 470, // size of collectory
              width: MediaQuery.of(context).size.width * 0.8,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                    center: vm.currentProject!.getCenter(),
                    zoom: vm.currentProject!.mapZoom ?? 1.0,
                    /* center: LatLng(-28.2, 134),
                    zoom: 3.0, */
                    /* boundsOptions:
                        FitBoundsOptions(padding: EdgeInsets.all(20)), */
                    /*  plugins: [
                      ZoomButtonsPlugin(),
                      ScaleLayerPlugin(),
                      DragMarkerPlugin(),
                    ],*/
                    onTap: (TapPosition tapPosition, LatLng latLng) {
                      if (firstPoint) {
                        area = <LatLng?>[latLng, null, null, null, latLng];
                      } else {
                        area[2] = latLng;
                      }
                      firstPoint = !firstPoint;
                      debugPrint('area: $firstPoint $area');
                      _updateArea(vm);
                    },
                    maxZoom: _maxZoom,
                    minZoom: _minZoom),
                children: <Widget>[
                  TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'org.gbif.living-atlases.la-toolkit',
                      subdomains: const <String>['a', 'b', 'c']),
                  if (area.where((LatLng? point) => point != null).length != 5)
                    MarkerLayer(markers: markers),
                  PolylineLayer(
                    polylines: <Polyline>[
                      if (projectArea[0] != null && projectArea[2] != null)
                        Polyline(
                            points: projectAreaNN,
                            strokeWidth: 4.0,
                            color: LAColorTheme.laPalette),
                    ],
                  ),
                  PolylineLayer(polylines: <Polyline>[
                    if (area[0] != null && area[2] != null)
                      Polyline(
                          points: areaNN,
                          strokeWidth: 4.0,
                          isDotted: true,
                          color: LAColorTheme.laPalette)
                  ]),
                  FlutterMapZoomButtons(
                      key: GlobalKey(),
                      maxZoom: _maxZoom,
                      padding: 10,
                      // rebuild: null,
                      //   rebuild: () {}, // new in nullsafety ??
                      alignment: Alignment.bottomRight),
                  ScaleLayerWidget(
                      key: GlobalKey(),
                      options: ScaleLayerPluginOption(
                        lineColor: Colors.blue,
                        textStyle:
                            const TextStyle(color: Colors.blue, fontSize: 12),
                        padding: const EdgeInsets.all(10),
                      )),
                  DragMarkers(markers: <DragMarker>[
                    if (projectArea[0] != null && projectArea[2] != null)
                      _createDragMarker(projectArea[0]!, vm),
                    if (projectArea[0] != null && projectArea[2] != null)
                      _createDragMarker(projectArea[2]!, vm)
                  ])
                ],
              ));
        });
  }

  void _updateArea(_MapAreaSelectorViewModel vm) {
    setState(() {
      if (area[0] != null && area[2] != null) {
        _calSquare(area);

        Future<void>.delayed(const Duration(milliseconds: 1000), () => _fit());
        _project!.setMap(area[0]!, area[2]!, mapController.zoom);
        vm.onUpdateProject!(_project);
      }
    });
  }

  DragMarker _createDragMarker(
      LatLng initialPoint, _MapAreaSelectorViewModel vm) {
    return DragMarker(
      key: GlobalKey<DragMarkerWidgetState>(),
      point: LatLng(initialPoint.latitude, initialPoint.longitude),
      size: const Size(80.0, 80.0),
      builder: (_, __, bool isDragging) {
        if (isDragging) {
          return const Icon(Icons.close, size: 45, color: Colors.orange);
        }
        return Icon(Icons.circle, size: 20, color: LAColorTheme.laPalette);
      },
      onDragStart: (DragStartDetails details, LatLng point) =>
          debugPrint('Start point $point'),
      onDragEnd: (DragEndDetails details, LatLng endPoint) {
        debugPrint('End point $endPoint');
        final List<LatLng?> lArea = projectArea;
        if (initialPoint == area[0]) {
          lArea[0] = lArea[4] = endPoint;
        } else {
          lArea[2] = endPoint;
        }
        area = lArea;
        _updateArea(vm);
        firstPoint = !firstPoint;
        debugPrint('area: $firstPoint $area');
      },
      onDragUpdate: (DragUpdateDetails details, LatLng point) {},
      onTap: (LatLng point) {
        debugPrint('on tap');
      },
      onLongPress: (LatLng point) {
        debugPrint('on long press');
      },
      scrollNearEdgeRatio: 1.0,
    );
  }

  void _calSquare(List<LatLng?> area) {
    final double x1 = area[0]!.longitude;
    final double y1 = area[0]!.latitude;
    final double x2 = area[2]!.longitude;
    final double y2 = area[2]!.latitude;

    area[1] = LatLng(y2 - (y2 - y1), x2);
    area[3] = LatLng(y2, x2 - (x2 - x1));
  }

  void _fit() {
    final LatLngBounds bounds = LatLngBounds(area[0]!, area[1]!);
    bounds.extend(area[2]!);
    bounds.extend(area[3]!);
    mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(
        padding: EdgeInsets.all(40),
      ),
    );
  }
}

class _MapAreaSelectorViewModel {
  _MapAreaSelectorViewModel({this.currentProject, this.onUpdateProject});

  final LAProject? currentProject;
  final void Function(LAProject? project)? onUpdateProject;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MapAreaSelectorViewModel &&
          runtimeType == other.runtimeType &&
          currentProject == other.currentProject;

  @override
  int get hashCode => currentProject.hashCode;
}
