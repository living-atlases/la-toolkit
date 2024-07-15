import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

class CompareDataTimeline<T extends CompareDataTimelinePhase>
    extends StatefulWidget {
  const CompareDataTimeline(
      {super.key,
      required this.currentPhase,
      required this.phaseValues,
      required this.failed});

  final T currentPhase;

  final bool failed;

  final List<T> phaseValues;

  @override
  State<CompareDataTimeline<T>> createState() => CompareDataTimelineState<T>();
}

abstract class CompareDataTimelinePhase {
  String title();
}

enum CompareWithGbifDataPhase implements CompareDataTimelinePhase {
  getSolrHosts,
  getCores,
  getDrs,
  getRandomLARecords,
  getGBIFRecords,
  finished;

  @override
  String title() {
    switch (this) {
      case getSolrHosts:
        return 'Get Solr Hosts';
      case getCores:
        return 'Get Cores/Collections';
      case getDrs:
        return 'Get all drs';
      case getRandomLARecords:
        return 'Get Random LA Records';
      case getGBIFRecords:
        return 'Get GBIF Records';
      case finished:
        return 'Finished';
    }
  }
}

enum CompareSolrIndexesPhase implements CompareDataTimelinePhase {
  getSolrHosts,
  getCores,
  compareIndexes,
  finished;

  @override
  String title() {
    switch (this) {
      case getSolrHosts:
        return 'Get Solr Hosts';
      case getCores:
        return 'Get Cores/Collections';
      case compareIndexes:
        return 'Compare indexes';
      case finished:
        return 'Finished';
    }
  }
}

class CompareDataTimelineState<T extends CompareDataTimelinePhase>
    extends State<CompareDataTimeline<T>> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.phaseValues.map((phase) {
            final bool isActive = widget.currentPhase == phase;
            final bool isComplete =
                widget.phaseValues.indexOf(widget.currentPhase) >
                    widget.phaseValues.indexOf(phase);
            final bool isFailed = widget.failed && isActive;
            return TimelineTile(
              direction: Axis.horizontal,
              nodeAlign: TimelineNodeAlign.start,
              contents: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  phase.title(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isFailed
                        ? Colors.red
                        : isActive
                            ? Colors.green
                            : Colors.grey,
                  ),
                ),
              ),
              node: TimelineNode(
                  indicator: CustomPaint(
                    size: const Size(20.0, 20.0),
                    painter: IconPainter(
                      icon: isFailed
                          ? Icons.error
                          : isActive
                              ? Icons.check_circle
                              : isComplete
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                      color: isFailed
                          ? Colors.red
                          : isActive
                              ? Colors.green
                              : isComplete
                                  ? Colors.blue
                                  : Colors.grey,
                    ),
                  ),
                  startConnector: const SolidLineConnector(
                    color: Colors.blue,
                  ),
                  endConnector: SolidLineConnector(
                    color: isActive ? Colors.green : Colors.blue,
                  )),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class IconPainter extends CustomPainter {
  IconPainter({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter textPainter =
        TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
            fontSize: size.width, fontFamily: icon.fontFamily, color: color));
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
