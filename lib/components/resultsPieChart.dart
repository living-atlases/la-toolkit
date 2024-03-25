import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/resultTypes.dart';

import 'indicator.dart';

class ResultsPieChart extends StatefulWidget {

  const ResultsPieChart(this.results, {super.key});
  final Map<String, num> results;

  @override
  State<StatefulWidget> createState() => ResultsPieChartState();
}

class ResultsPieChartState extends State<ResultsPieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                    pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    }),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 50,
                    sections: showingSections()),
              ),
            ),
          ),
          const SizedBox(width: 100),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final ResultType type in ResultType.values)
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Indicator(
                      color: type.color,
                      text: '${type.title()} (${widget.results[type.toS()]})',
                      isSquare: false,
                    )),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    int i = 0;
    return ResultType.values
        .where((ResultType t) =>
            widget.results[t.toS()] != null && widget.results[t.toS()] != 0)
        .map((ResultType type) {
      final bool isTouched = i == touchedIndex;
      i += 1;
      final double fontSize = isTouched ? 12 : 12;
      final double radius = isTouched ? 60 : 50;
      return PieChartSectionData(
          color: type.color,
          value: 0.0 + (widget.results[type.toS()] ?? 0.0),
          title: type.title(),
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.normal,
              color: type.textColor));
    }).toList();
  }

  List<PieChartSectionData> showingSectionsExample() {
    return List.generate(4, (int i) {
      final bool isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 60 : 50;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: 4,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: 3,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
        default:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: 1,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
      }
    });
  }
}
