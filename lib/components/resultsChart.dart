import 'package:flutter/material.dart';
import 'package:la_toolkit/utils/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ResultsChart extends StatelessWidget {
  final Map<String, int> values;

  ResultsChart(this.values);
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      SfCircularChart(
          title: ChartTitle(
              text: 'Ansible tasks result totals:',
              textStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
          legend: Legend(isVisible: true),
          series: <PieSeries<_PieData, String>>[
            PieSeries<_PieData, String>(
                explode: true,
                explodeIndex: 0,
                dataSource: <_PieData>[
                  _PieData(values['changed'], ResultsColors.changed, 'Changed'),
                  _PieData(values['failures'], ResultsColors.failure, 'Failed'),
                  _PieData(values['ignored'], ResultsColors.ignored, 'Ignored'),
                  _PieData(values['ok'], ResultsColors.ok, 'Success'),
                  _PieData(values['rescued'], ResultsColors.rescued, 'Rescued'),
                  _PieData(values['skipped'], ResultsColors.skipped, 'Skipped'),
                  _PieData(
                      values['unreachable'], Colors.deepOrange, 'Unreachable')
                ],
                xValueMapper: (_PieData data, _) => data.xData,
                yValueMapper: (_PieData data, _) => data.yData,
                dataLabelMapper: (_PieData data, _) =>
                    data.yData > 0 ? data.text : '',
                pointColorMapper: (_PieData data, _) => data.color,
                dataLabelSettings: DataLabelSettings(isVisible: true)),
          ])
    ]));
  }
}

class _PieData {
  final String xData;
  final num yData;
  final Color color;
  final String text;
  _PieData(this.yData, this.color, [this.text]) : this.xData = "$text ($yData)";
}
