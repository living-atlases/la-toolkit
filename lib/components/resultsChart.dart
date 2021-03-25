import 'package:flutter/material.dart';
import 'package:la_toolkit/utils/constants.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ResultsChart extends StatelessWidget {
  final Map<String, num> values;

  ResultsChart(this.values);
  Widget build(BuildContext context) {
    return Center(
        child: Column(children: [
      SfCircularChart(
          title: ChartTitle(
              text: 'Ansible tasks result totals:',
              textStyle: DeployUtils.subtitleStyle),
          legend: Legend(isVisible: true),
          series: <PieSeries<_PieData, String>>[
            PieSeries<_PieData, String>(
                explode: true,
                explodeIndex: 0,
                dataSource: <_PieData>[
                  _PieData(
                      values['changed'] ?? 0, ResultsColors.changed, 'Changed'),
                  _PieData(
                      values['failures'] ?? 0, ResultsColors.failure, 'Failed'),
                  _PieData(
                      values['ignored'] ?? 0, ResultsColors.ignored, 'Ignored'),
                  _PieData(values['ok'] ?? 0, ResultsColors.ok, 'Success'),
                  _PieData(
                      values['rescued'] ?? 0, ResultsColors.rescued, 'Rescued'),
                  _PieData(
                      values['skipped'] ?? 0, ResultsColors.skipped, 'Skipped'),
                  _PieData(values['unreachable'] ?? 0, Colors.deepOrange,
                      'Unreachable')
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
  _PieData(this.yData, this.color, this.text) : this.xData = "$text ($yData)";
}
