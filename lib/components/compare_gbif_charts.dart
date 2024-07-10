import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
                    topTitles: const AxisTitles(
                        // sideTitles: SideTitles(
                        //   showTitles: false),
                        ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const TextStyle style = TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('scientificName', style: style);
                              break;
                            case 1:
                              text = const Text('kingdom', style: style);
                              break;
                            case 2:
                              text = const Text('phylum', style: style);
                              break;
                            case 3:
                              text = const Text('class', style: style);
                              break;
                            case 4:
                              text = const Text('order', style: style);
                              break;
                            case 5:
                              text = const Text('family', style: style);
                              break;
                            case 6:
                              text = const Text('genus', style: style);
                              break;
                            case 7:
                              text = const Text('species', style: style);
                              break;
                            case 8:
                              text = const Text('country', style: style);
                              break;
                            case 9:
                              text = const Text('stateProvince', style: style);
                              break;
                            case 10:
                              text = const Text('locality', style: style);
                              break;
                            case 11:
                              text = const Text('eventDate', style: style);
                              break;
                            case 12:
                              text = const Text('recordedBy', style: style);
                              break;
                            case 13:
                              text = const Text('catalogNumber', style: style);
                              break;
                            case 14:
                              text = const Text('basisOfRecord', style: style);
                              break;
                            case 15:
                              text = const Text('collectionCode', style: style);
                              break;
                            case 16:
                              text =
                                  const Text('occurrenceStatus', style: style);
                              break;
                            case 17:
                              text = const Text('habitat', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: text,
                            ),
                          );
                        },
                        reservedSize: 60,
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
                    /*show: true,
                    drawVerticalLine: true,*/
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
                      // width: 1,
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (BarChartGroupData group, int groupIndex,
                          BarChartRodData rod, int rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toString(),
                          const TextStyle(
                            color: Colors.white,
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
            borderRadius: BorderRadius.circular(8),
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
    final List<String> keys = matches.keys.toList();

    return List<BarChartGroupData>.generate(keys.length, (int i) {
      return BarChartGroupData(
        x: i,
        barRods: <BarChartRodData>[
          BarChartRodData(
            fromY: 0,
            toY: matches[keys[i]]!.toDouble(),
            color: Colors.green,
            width: 8,
          ),
          BarChartRodData(
            fromY: 0,
            toY: mismatches[keys[i]]!.toDouble(),
            color: Colors.red,
            width: 8,
          ),
          BarChartRodData(
            fromY: 0,
            toY: nulls[keys[i]]!.toDouble(),
            color: Colors.grey,
            width: 8,
          ),
        ],
        showingTooltipIndicators: <int>[0, 1, 2],
      );
    });
  }
}
