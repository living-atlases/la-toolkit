import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:timelines/timelines.dart';

import '../laTheme.dart';

Color completeColor = LAColorTheme.laPalette.shade400;
Color inProgressColor = LAColorTheme.laPalette.shade900;
const todoColor = Colors.grey;
const _iconsVerticalPadding = 4.0;

class LAProjectTimeline extends StatelessWidget {
  final int size = LAProjectStatus.values.length;
  final LAProject project;

  LAProjectTimeline({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LAProjectTimelineViewModel>(
        distinct: true,
        converter: (store) {
          return _LAProjectTimelineViewModel(
              status: project.status, isHub: project.isHub);
        },
        builder: (BuildContext context, _LAProjectTimelineViewModel vm) {
          bool small = MediaQuery.of(context).size.width < 750;
          return Visibility(
              visible: !small,
              child: SizedBox(
                  height: small ? 600 : 100.0,
                  child: Timeline.tileBuilder(
                    shrinkWrap: true,
                    theme: TimelineThemeData(
                      direction: small ? Axis.vertical : Axis.horizontal,
                      connectorTheme: const ConnectorThemeData(
                        space: 30.0,
                        thickness: 5.0,
                      ),
                    ),
                    builder: TimelineTileBuilder.connected(
                      connectionDirection: ConnectionDirection.before,
                      itemExtentBuilder: (_, __) => 100,
                      oppositeContentsBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: _iconsVerticalPadding),
                          // steps icons size
                          child: Icon(
                            LAProjectStatus.values[index].icon,
                            // Image.asset(
                            // 'assets/images/process_timeline/status${index + 1}.png',
                            // width: 50.0,
                            size: 25.0,
                            color: getColor(vm.status, index),
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
                            LAProjectStatus.values[index]
                                .title(vm.isHub)
                                .replaceAll(' ', '\n'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                color: getColor(vm.status, index),
                                fontSize: 11),
                          ),
                        );
                      },
                      indicatorBuilder: (_, index) {
                        Color color;
                        Widget? child;
                        if (index == vm.status.value) {
                          color = inProgressColor;
                          child = const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          );
                        } else if (index < vm.status.value) {
                          color = completeColor;
                          child = const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 15.0,
                          );
                        } else {
                          color = todoColor;
                        }

                        // <= to show spinner
                        if (index < vm.status.value) {
                          return Stack(
                            children: [
                              CustomPaint(
                                size: const Size(30.0, 30.0),
                                painter: _BezierPainter(
                                  color: color,
                                  drawStart: index > 0,
                                  drawEnd: index < vm.status.value,
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
                                size: const Size(15.0, 15.0),
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
                          if (index == vm.status.value) {
                            final prevColor = getColor(vm.status, index - 1);
                            final color = getColor(vm.status, index);
                            List<Color> gradientColors;
                            if (type == ConnectorType.start) {
                              gradientColors = [
                                Color.lerp(prevColor, color, 0.5)!,
                                color
                              ];
                            } else {
                              gradientColors = [
                                prevColor,
                                Color.lerp(prevColor, color, 0.5)!
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
                              color: getColor(vm.status, index),
                            );
                          }
                        } else {
                          return const SizedBox(); // Icon(Icons.close); // previously null
                        }
                      },
                      itemCount: size,
                    ),
                  )));
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
  final LAProjectStatus status;
  final bool isHub;

  _LAProjectTimelineViewModel({required this.status, required this.isHub});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LAProjectTimelineViewModel &&
          runtimeType == other.runtimeType &&
          status.value == other.status.value;

  @override
  int get hashCode => status.value.hashCode;
}

/// hardcoded bezier painter
/// TODO: Bezier curve into package component
class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
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

    double angle;
    Offset offset1;
    Offset offset2;
    Path path;

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
