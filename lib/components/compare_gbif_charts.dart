import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/query_utils.dart';

class CompareGbifCharts extends StatefulWidget {
  const CompareGbifCharts({super.key, required this.statistics});

  final Map<String, Map<String, int>> statistics;

  @override
  State<CompareGbifCharts> createState() => CompareGbifChartsState();
}

class CompareGbifChartsState extends State<CompareGbifCharts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparative in a chart')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(),
                  barGroups: _createBarGroups(),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const TextStyle style = TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          );
                          final ComparisonFields field =
                              ComparisonFields.values[value.toInt()];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(field.name, style: style),
                            ),
                          );
                        },
                        reservedSize: 100,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    getDrawingHorizontalLine: (double value) {
                      return const FlLine(
                        color: Color(0xffe7e8ec),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (double value) {
                      return const FlLine(
                        color: Color(0xffe7e8ec),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: const Color(0xffe7e8ec),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.transparent,
                      getTooltipItem: (BarChartGroupData group, int groupIndex,
                          BarChartRodData rod, int rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toString(),
                          TextStyle(
                            color: rodIndex == 0
                                ? Colors.green
                                : rodIndex == 1
                                    ? Colors.red
                                    : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                      tooltipRoundedRadius: 20,
                      tooltipMargin: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLegend('Matches', Colors.green),
                const SizedBox(width: 10),
                _buildLegend('Mismatches', Colors.red),
                const SizedBox(width: 10),
                _buildLegend('Nulls', Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.black)),
      ],
    );
  }

  double _getMaxY() {
    final Map<String, int> matches = widget.statistics['matches']!;
    final Map<String, int> mismatches = widget.statistics['mismatches']!;
    final Map<String, int> nulls = widget.statistics['nulls']!;
    final List<int> allValues = matches.values.toList()
      ..addAll(mismatches.values)
      ..addAll(nulls.values);

    final int maxVal = allValues.reduce((int a, int b) => a > b ? a : b);
    return maxVal > 0 ? maxVal.toDouble() + 1 : 1.0;
  }

  List<BarChartGroupData> _createBarGroups() {
    final Map<String, int> matches = widget.statistics['matches']!;
    final Map<String, int> mismatches = widget.statistics['mismatches']!;
    final Map<String, int> nulls = widget.statistics['nulls']!;

    return List<BarChartGroupData>.generate(ComparisonFields.values.length,
        (int i) {
      final String key = ComparisonFields.values[i].name;
      return BarChartGroupData(
        x: i,
        barRods: <BarChartRodData>[
          BarChartRodData(
            fromY: 0,
            toY: matches[key]?.toDouble() ?? 0,
            color: Colors.green,
            width: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          BarChartRodData(
            fromY: 0,
            toY: mismatches[key]?.toDouble() ?? 0,
            color: Colors.red,
            width: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          BarChartRodData(
            fromY: 0,
            toY: nulls[key]?.toDouble() ?? 0,
            color: Colors.grey,
            width: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
        showingTooltipIndicators: <int>[0, 1, 2],
      );
    });
  }
}
