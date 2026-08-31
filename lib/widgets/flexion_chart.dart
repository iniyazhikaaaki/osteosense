// lib/widgets/flexion_chart.dart
// Dynamic screenshot-matching Knee Flexion Trajectory Chart & Extracted Gait Markers Dashboard Widget.
// Prevents clipping/overflow by dynamically scaling X-axis (0-frames) and Y-axis (0-deg).

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/gait_features.dart';
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

    if (leftTrajectory.isEmpty || rightTrajectory.isEmpty) {
      return const SizedBox.shrink();
    }

    List<FlSpot> spotsLeft = [];
    List<FlSpot> spotsRight = [];
    int maxFrames = max(leftTrajectory.length, rightTrajectory.length);
    int step = (maxFrames / 120).ceil().clamp(1, 10);

    double maxDegL = leftTrajectory.reduce(max);
    double maxDegR = rightTrajectory.reduce(max);
    double maxDeg = max(maxDegL, maxDegR);

    // Dynamic Y-axis upper limit (padded nicely so curves never clip out of bounds)
    double maxY = (maxDeg * 1.15).clamp(30.0, 140.0).ceilToDouble();
    double yInterval = (maxY / 5).ceilToDouble().clamp(5.0, 30.0);

    // Dynamic X-axis upper limit (exact frame count)
    double maxX = maxFrames.toDouble();
    double xInterval = (maxX / 6).ceilToDouble().clamp(10.0, 200.0);

    for (int i = 0; i < leftTrajectory.length; i += step) {
      spotsLeft.add(FlSpot(i.toDouble(), leftTrajectory[i].clamp(0.0, maxY)));
    }
    for (int i = 0; i < rightTrajectory.length; i += step) {
      spotsRight.add(FlSpot(i.toDouble(), rightTrajectory[i].clamp(0.0, maxY)));
    }

    // Reference screenshot colors
    const Color darkBlueLine = Color(0xFF0055A5);
    const Color lightBlueLine = Color(0xFF40B5E5);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 750;

        Widget chartSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                t('chart_header', lang),
                style: const TextStyle(
                  fontSize: 20,
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
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (val) => const FlLine(
                      color: Color(0xFFF1F5F9),
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
                        interval: xInterval,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}°',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: maxY,
                  minX: 0,
                  maxX: maxX,
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
                _buildLegendItem(t('left_leg', lang), darkBlueLine),
                const SizedBox(width: 24),
                _buildLegendItem(t('right_leg', lang), lightBlueLine),
              ],
            ),
          ],
        );

        Widget tableSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                t('gait_markers', lang),
                style: const TextStyle(
                  fontSize: 20,
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
