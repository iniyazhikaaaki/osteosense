// lib/widgets/flexion_chart.dart
// Interactive Line Chart displaying Knee Flexion Angle Trajectory over frames.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../translations.dart';

class FlexionChart extends StatelessWidget {
  final List<double> leftTrajectory;
  final List<double> rightTrajectory;
  final String lang;

  const FlexionChart({
    super.key,
    required this.leftTrajectory,
    required this.rightTrajectory,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    if (leftTrajectory.isEmpty || rightTrajectory.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text('No trajectory data available'),
      );
    }

    // Downsample for rendering performance if frame count is high
    List<FlSpot> spotsLeft = [];
    List<FlSpot> spotsRight = [];
    int step = (leftTrajectory.length / 50).ceil().clamp(1, 10);

    for (int i = 0; i < leftTrajectory.length; i += step) {
      spotsLeft.add(FlSpot(i.toDouble(), leftTrajectory[i]));
    }
    for (int i = 0; i < rightTrajectory.length; i += step) {
      spotsRight.add(FlSpot(i.toDouble(), rightTrajectory[i]));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('flexion_chart_title', lang),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildLegendItem(t('left_leg', lang), Colors.blue.shade700),
                const SizedBox(width: 16),
                _buildLegendItem(t('right_leg', lang), Colors.deepOrange),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 30,
                        getTitlesWidget: (value, meta) => Text(
                          'F${value.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 20,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}°',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minY: -10,
                  maxY: 60,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spotsLeft,
                      isCurved: true,
                      color: Colors.blue.shade700,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: spotsRight,
                      isCurved: true,
                      color: Colors.deepOrange,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
