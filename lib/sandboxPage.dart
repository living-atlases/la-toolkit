import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:la_toolkit/components/servicesChipPanel.dart';
import 'package:latlong/latlong.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'components/defDivider.dart';
import 'laTheme.dart';
import 'maps/scale_layer_plugin_option.dart';
import 'maps/zoombuttons_plugin_option.dart';
import 'models/appState.dart';

class SandboxPage extends StatefulWidget {
  static const routeName = "sandbox";
  @override
  _SandboxPageState createState() => _SandboxPageState();
}

class _SandboxPageState extends State<SandboxPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<LatLng> area = []..length = 5;
  bool firstPoint = true;

  @override
  Widget build(BuildContext context) {
    /*
    searchServerList.add(DropdownMenuItem(child: Text('vm1'), value: 'vm1'));
    searchServerList.add(DropdownMenuItem(child: Text('vm2'), value: 'vm2'));*/
    MapController mapController;

    return StoreConnector<AppState, _SandboxViewModel>(converter: (store) {
      return _SandboxViewModel(
        state: store.state,
      );
    }, builder: (BuildContext context, _SandboxViewModel vm) {
      List<DropdownMenuItem<String>> releases = [];
      vm.state.alaInstallReleases.forEach((element) =>
          releases.add(DropdownMenuItem(child: Text(element), value: element)));
      var markers = area.map((latlng) {
        return Marker(
          width: 80.0,
          height: 80.0,
          point: latlng,
          builder: (ctx) => Container(
            child: new Icon(Icons.circle, size: 16, color: Colors.blueGrey),
          ),
        );
      }).toList();
      mapController = MapController();
      return Scaffold(
          key: _scaffoldKey,
          // backgroundColor: Colors.white,
          appBar: LAAppBar(
            context: context,
            title: 'Sandbox',
            actions: [
              new CircularPercentIndicator(
                radius: 45.0,
                lineWidth: 6.0,
                percent: 0.9,
                center: new Text("90%",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                progressColor: Colors.white,
              )
            ],
          ),
          body: Column(
            children: [
              Container(
                child: Column(
                  children: [ServicesChipPanel()],
                ),
              ),
              Column(
                children: <Widget>[
                  const SizedBox(height: 7),
                  DefDivider(),
                  // ServicesInServerChooser(server: "biocache-store-0.gbif.es"),
                  const SizedBox(height: 7),
                  Container(
                      height: 500,
                      width: 500,
                      child: Tooltip(
                          message:
                              "Tap two points to select the default map area of your LA portal",
                          child: new FlutterMap(
                            mapController: mapController,
                            options: new MapOptions(
                                center: new LatLng(-28.2, 134),
                                zoom: 4.0,
                                plugins: [
                                  ZoomButtonsPlugin(),
                                  ScaleLayerPlugin(),
                                ],
                                onTap: (latLng) {
                                  if (firstPoint) {
                                    area = [latLng, null, null, null, latLng];
                                  } else
                                    area[2] = latLng;
                                  setState(() {
                                    firstPoint = !firstPoint;
                                    if (area[0] != null && area[2] != null)
                                      _calSquare();
                                    print("first: $firstPoint $area");
                                  });
                                },
                                maxZoom: 19.0,
                                minZoom: 3.0),
                            layers: [
                              TileLayerOptions(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c']),
                              MarkerLayerOptions(markers: markers),
                              PolylineLayerOptions(
                                polylines: [
                                  if (area[0] != null && area[1] != null)
                                    Polyline(
                                        points: area,
                                        strokeWidth: 4.0,
                                        isDotted: true,
                                        color: LAColorTheme.laPalette),
                                ],
                              ),
                              ZoomButtonsPluginOption(
                                  minZoom: 3,
                                  maxZoom: 19,
                                  mini: true,
                                  padding: 10,
                                  alignment: Alignment.bottomRight),
                              ScaleLayerPluginOption(
                                lineColor: Colors.blue,
                                lineWidth: 2,
                                textStyle:
                                    TextStyle(color: Colors.blue, fontSize: 12),
                                padding: EdgeInsets.all(10),
                              )
                            ],
                          )))
                ],
              ),
            ],
          ));
    });
  }

  _calSquare() {
    var x1 = area[0].longitude;
    var y1 = area[0].latitude;
    var x2 = area[2].longitude;
    var y2 = area[2].latitude;

    area[1] = LatLng(y2 - (y2 - y1), x2);
    area[3] = LatLng(y2, x2 - (x2 - x1));
  }
}

class _SandboxViewModel {
  final AppState state;

  _SandboxViewModel({this.state});
}
