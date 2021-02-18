import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:timelines/timelines.dart';

import '../laTheme.dart';

var completeColor = LAColorTheme.laPalette.shade400;
var inProgressColor = LAColorTheme.laPalette.shade900;
const todoColor = Colors.grey;
const _iconsVerticalPadding = 4.0;

class LAProjectTimeline extends StatelessWidget {
  final int size = LAProjectStatus.values.length;

  final String uuid;

  LAProjectTimeline({this.uuid});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LAProjectTimelineViewModel>(
        // distinct: true,
        converter: (store) {
      return _LAProjectTimelineViewModel(
        project: store.state.projects
            .where((element) => element.uuid == uuid)
            .toList()[0],
      );
    }, builder: (BuildContext context, _LAProjectTimelineViewModel vm) {
      LAProject project = vm.project;
      bool small = MediaQuery.of(context).size.width < 750;
      return SizedBox(
          height: small ? 600 : 100.0,
          child: Timeline.tileBuilder(
            shrinkWrap: true,
            theme: TimelineThemeData(
              direction: small ? Axis.vertical : Axis.horizontal,
              connectorTheme: ConnectorThemeData(
                space: 30.0,
                thickness: 5.0,
              ),
            ),
            builder: TimelineTileBuilder.connected(
              connectionDirection: ConnectionDirection.before,
              itemExtentBuilder: (_, __) => 100,
              oppositeContentsBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: _iconsVerticalPadding),
                  // steps icons size
                  child: Icon(
                    LAProjectStatus.values[index].icon,
                    // Image.asset(
                    // 'assets/images/process_timeline/status${index + 1}.png',
                    // width: 50.0,
                    size: 25.0,
                    color: getColor(project.status, index),
                  ),
                );
              },
              contentsBuilder: (context, index) {
                return Padding(
                  // Top of step titles
                  padding: EdgeInsets.only(
                      top: small ? 0 : _iconsVerticalPadding,
                      left: small ? 20 : 0),
                  child: Text(
                    LAProjectStatus.values[index].title.replaceAll(' ', '\n'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        color: getColor(project.status, index),
                        fontSize: 11),
                  ),
                );
              },
              indicatorBuilder: (_, index) {
                var color;
                var child;
                if (index == project.status.value) {
                  color = inProgressColor;
                  child = Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  );
                } else if (index < project.status.value) {
                  color = completeColor;
                  child = Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 15.0,
                  );
                } else {
                  color = todoColor;
                }

                // <= to show spinner
                if (index < project.status.value) {
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size(30.0, 30.0),
                        painter: _BezierPainter(
                          color: color,
                          drawStart: index > 0,
                          drawEnd: index < project.status.value,
                        ),
                      ),
                      DotIndicator(
                        size: 30.0,
                        color: color,
                        child: child,
                      ),
                    ],
                  );
                } else {
                  return Stack(
                    children: [
                      CustomPaint(
                        size: Size(15.0, 15.0),
                        painter: _BezierPainter(
                          color: color,
                          drawEnd: index < size - 1,
                        ),
                      ),
                      OutlinedDotIndicator(
                        borderWidth: 4.0,
                        color: color,
                      ),
                    ],
                  );
                }
              },
              connectorBuilder: (_, index, type) {
                if (index > 0) {
                  if (index == project.status.value) {
                    final prevColor = getColor(project.status, index - 1);
                    final color = getColor(project.status, index);
                    var gradientColors;
                    if (type == ConnectorType.start) {
                      gradientColors = [
                        Color.lerp(prevColor, color, 0.5),
                        color
                      ];
                    } else {
                      gradientColors = [
                        prevColor,
                        Color.lerp(prevColor, color, 0.5)
                      ];
                    }
                    return DecoratedLineConnector(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                      ),
                    );
                  } else {
                    return SolidLineConnector(
                      color: getColor(project.status, index),
                    );
                  }
                } else {
                  return null;
                }
              },
              itemCount: size,
            ),
          ));
    });
  }

  Color getColor(LAProjectStatus status, int index) {
    if (index == status.value) {
      return inProgressColor;
    } else if (index < status.value) {
      return completeColor;
    } else {
      return todoColor;
    }
  }
}

class _LAProjectTimelineViewModel {
  final LAProject project;

  _LAProjectTimelineViewModel({this.project});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LAProjectTimelineViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    @required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    var angle;
    var offset1;
    var offset2;

    var path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius,
            radius) // TODO connector start & gradient
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(size.width, size.height / 2, size.width + radius,
            radius) // TODO connector end & gradient
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
