// lib/widgets/flexion_chart.dart
// Exact screenshot-matching Knee Flexion Trajectory Chart & Extracted Markers Dashboard Widget.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/gait_features.dart';

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
    int step = (leftTrajectory.length / 120).ceil().clamp(1, 10);

    for (int i = 0; i < leftTrajectory.length; i += step) {
      spotsLeft.add(FlSpot(i.toDouble(), leftTrajectory[i]));
    }
    for (int i = 0; i < rightTrajectory.length; i += step) {
      spotsRight.add(FlSpot(i.toDouble(), rightTrajectory[i]));
    }

    // Exact screenshot colors
    const Color darkBlueLine = Color(0xFF0055A5);
    const Color lightBlueLine = Color(0xFF40B5E5);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 750;

        Widget chartSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Knee flexion over time',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            Container(
              height: 280,
              padding: const EdgeInsets.only(top: 10, right: 16, bottom: 4),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: const Color(0xFFF1F5F9),
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
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 2,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: 22,
                  minX: 0,
                  maxX: 650,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spotsLeft,
                      isCurved: true,
                      color: darkBlueLine,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: spotsRight,
                      isCurved: true,
                      color: lightBlueLine,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegendItem('Left knee', darkBlueLine),
                const SizedBox(width: 24),
                _buildLegendItem('Right knee', lightBlueLine),
              ],
            ),
          ],
        );

        Widget tableSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Extracted gait markers',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Table(
                border: TableBorder.symmetric(
                  inside: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Color(0xFFF8FAFC)),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        child: Text('Marker', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B))),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        child: Text('Value', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B))),
                      ),
                    ],
                  ),
                  _buildTableRow('Flexion ROM left (deg)', features.romLeft.toStringAsFixed(1)),
                  _buildTableRow('Flexion ROM right (deg)', features.romRight.toStringAsFixed(1)),
                  _buildTableRow('ROM asymmetry', features.romAsymmetry.toStringAsFixed(3)),
                  _buildTableRow('Peak flexion right (deg)', features.peakFlexionRight.toStringAsFixed(1)),
                  _buildTableRow('Cadence (steps/min)', features.cadence.toStringAsFixed(1)),
                  _buildTableRow('Jerk left', features.jerkLeft.toStringAsFixed(2)),
                  _buildTableRow('Jerk right', features.jerkRight.toStringAsFixed(3)),
                ],
              ),
            ),
          ],
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: chartSection),
              const SizedBox(width: 32),
              Expanded(flex: 5, child: tableSection),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            chartSection,
            const SizedBox(height: 32),
            tableSection,
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
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String val) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
          child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }
}
