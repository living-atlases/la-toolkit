import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

class CompareDataTimeline extends StatefulWidget {
  const CompareDataTimeline({super.key, required this.currentPhase});

  final CompareDataPagePhase currentPhase;

  @override
  State<CompareDataTimeline> createState() => _CompareDataTimelineState();
}

enum CompareDataPagePhase {
  getSolrHosts,
  getCores,
  getDrs,
  getRandomLARecords,
  getGBIFRecords,
  finished
}

extension CompareDataPagePhaseTitle on CompareDataPagePhase {
  String title() {
    switch (this) {
      case CompareDataPagePhase.getSolrHosts:
        return 'Get Solr Hosts';
      case CompareDataPagePhase.getCores:
        return 'Get Cores/Collections';
      case CompareDataPagePhase.getDrs:
        return 'Get all drs';
      case CompareDataPagePhase.getRandomLARecords:
        return 'Get Random LA Records';
      case CompareDataPagePhase.getGBIFRecords:
        return 'Get GBIF Records';
      case CompareDataPagePhase.finished:
        return 'Finished';
    }
  }
}

class _CompareDataTimelineState extends State<CompareDataTimeline> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: CompareDataPagePhase.values.map((phase) {
            final bool isActive = widget.currentPhase == phase;
            final bool isComplete =
                CompareDataPagePhase.values.indexOf(widget.currentPhase) >
                    CompareDataPagePhase.values.indexOf(phase);
            return TimelineTile(
              direction: Axis.horizontal,
              nodeAlign: TimelineNodeAlign.start,
              contents: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  phase.title(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              node: TimelineNode(
                  indicator: DotIndicator(
                    color: isActive
                        ? Colors.green
                        : isComplete
                            ? Colors.blue
                            : Colors.grey,
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
