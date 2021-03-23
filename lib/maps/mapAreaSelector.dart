import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/maps/scale_layer_plugin_option.dart';
import 'package:la_toolkit/maps/zoombuttons_plugin_option.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:latlong2/latlong.dart';

import '../laTheme.dart';
import 'dragmarker.dart';

class MapAreaSelector extends StatefulWidget {
  MapAreaSelector({Key? key}) : super(key: key);

  @override
  _MapAreaSelectorState createState() => _MapAreaSelectorState();
}

class _MapAreaSelectorState extends State<MapAreaSelector> {
  List<LatLng?> area = []..length = 5;
  List<LatLng?> projectArea = []..length = 5;
  bool firstPoint = true;
  final MapController mapController = MapController();
  LAProject? _project;
  static const _minZoom = 1.0;
  static const _maxZoom = 20.0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _MapAreaSelectorViewModel>(
        distinct: true,
        converter: (store) {
          return _MapAreaSelectorViewModel(
              currentProject: store.state.currentProject,
              onUpdateProject: (project) =>
                  store.dispatch(UpdateProject(project!)));
        },
        builder: (BuildContext context, _MapAreaSelectorViewModel vm) {
          _project = vm.currentProject;

          var fstPoint = _project!.mapBoundsFstPoint;
          var sndPoint = _project!.mapBoundsSndPoint;
          projectArea = [fstPoint, null, sndPoint, null, fstPoint];
          _calSquare(projectArea);

          var markers = area.where((latLng) => latLng != null).map((latLng) {
            return Marker(
              width: 80.0,
              height: 80.0,
              point: latLng!,
              builder: (ctx) => Container(
                child: new Icon(Icons.circle, size: 16, color: Colors.blueGrey),
              ),
            );
          }).toList();
          return Container(
              height: 470, // size of collectory
              width: MediaQuery.of(context).size.width * 0.8,
              child: FlutterMap(
                mapController: mapController,
                options: new MapOptions(
                    center: vm.currentProject!.getCenter(),
                    zoom: vm.currentProject!.mapZoom ?? 1.0,
                    /* center: LatLng(-28.2, 134),
                    zoom: 3.0, */
                    /* boundsOptions:
                        FitBoundsOptions(padding: EdgeInsets.all(20)), */
                    plugins: [
                      ZoomButtonsPlugin(),
                      ScaleLayerPlugin(),
                      DragMarkerPlugin(),
                    ],
                    onTap: (latLng) {
                      if (firstPoint) {
                        area = [latLng, null, null, null, latLng];
                      } else {
                        area[2] = latLng;
                      }
                      firstPoint = !firstPoint;
                      print("area: $firstPoint $area");
                      _updateArea(vm);
                    },
                    maxZoom: _maxZoom,
                    minZoom: _minZoom),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']),
                  if (area.where((point) => point != null).length != 5)
                    MarkerLayerOptions(markers: markers),
                  PolylineLayerOptions(
                    polylines: [
                      if (projectArea[0] != null && projectArea[2] != null)
                        Polyline(
                            points: projectArea as List<LatLng>,
                            strokeWidth: 4.0,
                            isDotted: false,
                            color: LAColorTheme.laPalette),
                    ],
                  ),
                  PolylineLayerOptions(polylines: [
                    if (area[0] != null && area[2] != null)
                      Polyline(
                          points: area as List<LatLng>,
                          strokeWidth: 4.0,
                          isDotted: true,
                          color: LAColorTheme.laPalette)
                  ]),
                  ZoomButtonsPluginOption(
                      key: GlobalKey(),
                      minZoom: _minZoom.toInt(),
                      maxZoom: _maxZoom.toInt(),
                      mini: true,
                      padding: 10,
                      rebuild: null,
                      //   rebuild: () {}, // new in nullsafety ??
                      alignment: Alignment.bottomRight),
                  ScaleLayerPluginOption(
                    key: GlobalKey(),
                    lineColor: Colors.blue,
                    lineWidth: 2,
                    rebuild: null,
                    //   rebuild: () {}, // new in nullsafety ??
                    textStyle: TextStyle(color: Colors.blue, fontSize: 12),
                    padding: EdgeInsets.all(10),
                  ),
                  DragMarkerPluginOptions(markers: [
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
        Future.delayed(const Duration(milliseconds: 1000), () => _fit());
        _project!.setMap(area[0]!, area[2]!, mapController.zoom);
        vm.onUpdateProject!(_project);
      }
    });
  }

  DragMarker _createDragMarker(
      LatLng initialPoint, _MapAreaSelectorViewModel vm) {
    return DragMarker(
      point: LatLng(initialPoint.latitude, initialPoint.longitude),
      width: 80.0,
      height: 80.0,
      offset: Offset(0.0, 0.0),
      builder: (ctx) => Container(
          child: Icon(Icons.circle, size: 20, color: LAColorTheme.laPalette)),
      onDragStart: (details, point) => print("Start point $point"),
      onDragEnd: (details, endPoint) {
        print("End point $endPoint");
        var lArea = projectArea;
        if (initialPoint == area[0]) {
          lArea[0] = lArea[4] = endPoint;
        } else {
          lArea[2] = endPoint;
        }
        area = lArea;
        _updateArea(vm);
        firstPoint = !firstPoint;
        print("area: $firstPoint $area");
      },
      onDragUpdate: (details, point) {},
      onTap: (point) {
        print("on tap");
      },
      onLongPress: (point) {
        print("on long press");
      },
      feedbackBuilder: (ctx) =>
          Container(child: Icon(Icons.close, size: 45, color: Colors.orange)),
      feedbackOffset: Offset(0.0, 0.0),
      updateMapNearEdge: false,
      nearEdgeRatio: 1.0,
      nearEdgeSpeed: 1.0,
    );
  }

  _calSquare(List<LatLng?> area) {
    var x1 = area[0]!.longitude;
    var y1 = area[0]!.latitude;
    var x2 = area[2]!.longitude;
    var y2 = area[2]!.latitude;

    area[1] = LatLng(y2 - (y2 - y1), x2);
    area[3] = LatLng(y2, x2 - (x2 - x1));
  }

  _fit() {
    var bounds = LatLngBounds();
    bounds.extend(area[0]!);
    bounds.extend(area[1]!);
    bounds.extend(area[2]!);
    bounds.extend(area[3]!);
    mapController.fitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: EdgeInsets.all(40),
      ),
    );
  }
}

class _MapAreaSelectorViewModel {
  final LAProject? currentProject;
  final void Function(LAProject? project)? onUpdateProject;

  _MapAreaSelectorViewModel({this.currentProject, this.onUpdateProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MapAreaSelectorViewModel &&
          runtimeType == other.runtimeType &&
          currentProject == other.currentProject;

  @override
  int get hashCode => currentProject.hashCode;
}
