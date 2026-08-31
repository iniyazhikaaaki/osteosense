// lib/widgets/flexion_chart.dart
// Aesthetic screenshot-matching Knee Flexion Trajectory Chart & Extracted Markers Dashboard Widget.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/gait_features.dart';
import '../theme/app_theme.dart';
import '../translations.dart';

class FlexionChart extends StatelessWidget {
  final GaitFeatures features;
  final String lang;

  const FlexionChart({
    super.key,
    required this.features,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final leftTrajectory = features.leftTrajectory;
    final rightTrajectory = features.rightTrajectory;

    List<FlSpot> spotsLeft = [];
    List<FlSpot> spotsRight = [];
    int step = (leftTrajectory.length / 100).ceil().clamp(1, 10);

    for (int i = 0; i < leftTrajectory.length; i += step) {
      spotsLeft.add(FlSpot(i.toDouble(), leftTrajectory[i]));
    }
    for (int i = 0; i < rightTrajectory.length; i += step) {
      spotsRight.add(FlSpot(i.toDouble(), rightTrajectory[i]));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 700;

        Widget chartWidget = Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('chart_header', lang),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 260,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 50,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 2,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      maxY: 24,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spotsLeft,
                          isCurved: true,
                          color: AppTheme.leftKneeDarkBlue,
                          barWidth: 2.2,
                          dotData: const FlDotData(show: false),
                        ),
                        LineChartBarData(
                          spots: spotsRight,
                          isCurved: true,
                          color: AppTheme.rightKneeLightBlue,
                          barWidth: 2.2,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildLegendItem(t('left_leg', lang), AppTheme.leftKneeDarkBlue),
                    const SizedBox(width: 20),
                    _buildLegendItem(t('right_leg', lang), AppTheme.rightKneeLightBlue),
                  ],
                ),
              ],
            ),
          ),
        );

        Widget markersWidget = Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('gait_markers', lang),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 16),
                Table(
                  border: TableBorder.symmetric(
                    inside: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade50),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Marker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Value', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                        ),
                      ],
                    ),
                    _buildTableRow(t('marker_rom_l', lang), features.romLeft.toStringAsFixed(1)),
                    _buildTableRow(t('marker_rom_r', lang), features.romRight.toStringAsFixed(1)),
                    _buildTableRow(t('marker_asymmetry', lang), features.romAsymmetry.toStringAsFixed(3)),
                    _buildTableRow(t('marker_peak_r', lang), features.peakFlexionRight.toStringAsFixed(1)),
                    _buildTableRow(t('marker_cadence', lang), features.cadence.toStringAsFixed(1)),
                    _buildTableRow(t('marker_jerk_l', lang), features.jerkLeft.toStringAsFixed(2)),
                    _buildTableRow(t('marker_jerk_r', lang), features.jerkRight.toStringAsFixed(3)),
                  ],
                ),
              ],
            ),
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: chartWidget),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: markersWidget),
            ],
          );
        }

        return Column(
          children: [
            chartWidget,
            const SizedBox(height: 16),
            markersWidget,
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryNavy,
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String val) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.primaryNavy)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryNavy),
          ),
        ),
      ],
    );
  }
}
