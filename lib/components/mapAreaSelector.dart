import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/maps/scale_layer_plugin_option.dart';
import 'package:la_toolkit/maps/zoombuttons_plugin_option.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:latlong/latlong.dart';

import '../laTheme.dart';

class MapAreaSelector extends StatefulWidget {
  MapAreaSelector({Key key}) : super(key: key);

  @override
  _MapAreaSelectorState createState() => _MapAreaSelectorState();
}

class _MapAreaSelectorState extends State<MapAreaSelector> {
  List<LatLng> area = []..length = 5;
  List<LatLng> projectArea = []..length = 5;
  bool firstPoint = true;
  MapController mapController = MapController();
  LAProject _project;
  static const _minZoom = 1.0;
  static const _maxZoom = 20.0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _MapAreaSelectorViewModel>(
        converter: (store) {
      return _MapAreaSelectorViewModel(
          state: store.state,
          onUpdateProject: (project) => store.dispatch(UpdateProject(project)));
    }, builder: (BuildContext context, _MapAreaSelectorViewModel vm) {
      _project = vm.state.currentProject;
      if (_project.mapBounds1stPoint != null &&
          _project.mapBounds2ndPoint != null) {
        var fstPoint = LatLng(
            _project.mapBounds1stPoint[0], _project.mapBounds1stPoint[1]);
        var sndPoint = LatLng(
            _project.mapBounds2ndPoint[0], _project.mapBounds2ndPoint[1]);
        projectArea = [fstPoint, null, sndPoint, null, fstPoint];
        _calSquare(projectArea);
      } else {}
      var markers = area.map((latLng) {
        return Marker(
          width: 80.0,
          height: 80.0,
          point: latLng,
          builder: (ctx) => Container(
            child: new Icon(Icons.circle, size: 16, color: Colors.blueGrey),
          ),
        );
      }).toList();
      return Container(
          height: 470, // size of collectory
          width: MediaQuery.of(context).size.width * 0.8,
          child: Tooltip(
              message:
                  "Tap two points to select the default map area of your LA portal",
              child: new FlutterMap(
                mapController: mapController,
                options: new MapOptions(
                    center: vm.state.currentProject.getCenter(),
                    zoom: vm.state.currentProject.mapZoom ?? 1.0,
                    /* center: LatLng(-28.2, 134),
                    zoom: 3.0, */
                    boundsOptions:
                        FitBoundsOptions(padding: EdgeInsets.all(20)),
                    plugins: [
                      ZoomButtonsPlugin(),
                      ScaleLayerPlugin(),
                    ],
                    onTap: (latLng) {
                      setState(() {
                        if (firstPoint) {
                          area = [latLng, null, null, null, latLng];
                        } else {
                          area[2] = latLng;
                        }
                        firstPoint = !firstPoint;
                        print("area: $firstPoint $area");
                        if (area[0] != null && area[2] != null) {
                          _calSquare(area);
                          Future.delayed(
                              const Duration(milliseconds: 1000), () => _fit());
                          _project.setMap(area[0], area[2], mapController.zoom);
                          vm.onUpdateProject(_project);
                        }
                      });
                    },
                    maxZoom: _maxZoom,
                    minZoom: _minZoom),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(markers: markers),
                  PolylineLayerOptions(
                    polylines: [
                      if (projectArea[0] != null && projectArea[2] != null)
                        Polyline(
                            points: projectArea,
                            strokeWidth: 4.0,
                            isDotted: false,
                            color: LAColorTheme.laPalette),
                    ],
                  ),
                  PolylineLayerOptions(polylines: [
                    if (area[0] != null && area[2] != null)
                      Polyline(
                          points: area,
                          strokeWidth: 4.0,
                          isDotted: true,
                          color: LAColorTheme.laPalette)
                  ]),
                  ZoomButtonsPluginOption(
                      minZoom: _minZoom.toInt(),
                      maxZoom: _maxZoom.toInt(),
                      mini: true,
                      padding: 10,
                      alignment: Alignment.bottomRight),
                  ScaleLayerPluginOption(
                    lineColor: Colors.blue,
                    lineWidth: 2,
                    textStyle: TextStyle(color: Colors.blue, fontSize: 12),
                    padding: EdgeInsets.all(10),
                  )
                ],
              )));
    });
  }

  _calSquare(List<LatLng> area) {
    var x1 = area[0].longitude;
    var y1 = area[0].latitude;
    var x2 = area[2].longitude;
    var y2 = area[2].latitude;

    area[1] = LatLng(y2 - (y2 - y1), x2);
    area[3] = LatLng(y2, x2 - (x2 - x1));
  }

  _fit() {
    var bounds = LatLngBounds();
    bounds.extend(area[0]);
    bounds.extend(area[1]);
    bounds.extend(area[2]);
    bounds.extend(area[3]);
    mapController.fitBounds(
      bounds,
      options: FitBoundsOptions(
        padding: EdgeInsets.all(40),
      ),
    );
  }
}

class _MapAreaSelectorViewModel {
  final AppState state;
  final void Function(LAProject project) onUpdateProject;

  _MapAreaSelectorViewModel({this.state, this.onUpdateProject});
}
