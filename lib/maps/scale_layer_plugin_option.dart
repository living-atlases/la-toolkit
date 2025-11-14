import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

import 'scalebar_utils.dart' as util;

class ScaleLayerPluginOption {
  ScaleLayerPluginOption({
    this.textStyle,
    this.lineColor = Colors.white,
    this.lineWidth = 2,
    this.padding,
  });

  TextStyle? textStyle;
  Color lineColor;
  double lineWidth;
  final EdgeInsets? padding;
}

class ScaleLayerWidget extends StatelessWidget {
  ScaleLayerWidget({super.key, required this.options});

  final ScaleLayerPluginOption options;
  final List<int> scale = <int>[
    25000000,
    15000000,
    8000000,
    4000000,
    2000000,
    1000000,
    500000,
    250000,
    100000,
    50000,
    25000,
    15000,
    8000,
    4000,
    2000,
    1000,
    500,
    250,
    100,
    50,
    25,
    10,
    5
  ];

  @override
  Widget build(BuildContext context) {
    final FlutterMapState map = FlutterMapState.of(context);
    final double zoom = map.zoom;
    final double distance = scale[max(0, min(20, zoom.round() + 2))].toDouble();
    final LatLng center = map.center;
    final CustomPoint<double> start = map.project(center);
    final LatLng targetPoint = util.calculateEndingGlobalCoordinates(center, 90, distance);
    final CustomPoint<double> end = map.project(targetPoint);
    final String displayDistance =
        distance > 999 ? '${(distance / 1000).toStringAsFixed(0)} km' : '${distance.toStringAsFixed(0)} m';
    final double width = end.x - (start.x);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        return CustomPaint(
          painter: ScalePainter(
            width,
            displayDistance,
            lineColor: options.lineColor,
            lineWidth: options.lineWidth,
            padding: options.padding,
            textStyle: options.textStyle,
          ),
        );
      },
    );
  }
}

class ScalePainter extends CustomPainter {
  ScalePainter(this.width, this.text, {this.padding, this.textStyle, this.lineWidth, this.lineColor});

  final double width;
  final EdgeInsets? padding;
  final String text;
  TextStyle? textStyle;
  double? lineWidth;
  Color? lineColor;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final ui.Paint paint = Paint()
      ..color = lineColor!
      ..strokeCap = StrokeCap.square
      ..strokeWidth = lineWidth!;

    const int sizeForStartEnd = 4;
    final double paddingLeft = padding == null ? 0.0 : padding!.left + sizeForStartEnd / 2;
    double paddingTop = padding == null ? 0.0 : padding!.top;

    final TextSpan textSpan = TextSpan(style: textStyle, text: text);
    final TextPainter textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    textPainter.paint(canvas, Offset(width / 2 - textPainter.width / 2 + paddingLeft, paddingTop));
    paddingTop += textPainter.height;
    final ui.Offset p1 = Offset(paddingLeft, sizeForStartEnd + paddingTop);
    final ui.Offset p2 = Offset(paddingLeft + width, sizeForStartEnd + paddingTop);
    // draw start line
    canvas.drawLine(Offset(paddingLeft, paddingTop), Offset(paddingLeft, sizeForStartEnd + paddingTop), paint);
    // draw middle line
    final double middleX = width / 2 + paddingLeft - lineWidth! / 2;
    canvas.drawLine(
        Offset(middleX, paddingTop + sizeForStartEnd / 2), Offset(middleX, sizeForStartEnd + paddingTop), paint);
    // draw end line
    canvas.drawLine(
        Offset(width + paddingLeft, paddingTop), Offset(width + paddingLeft, sizeForStartEnd + paddingTop), paint);
    // draw bottom line
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
