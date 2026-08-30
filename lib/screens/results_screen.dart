// lib/screens/results_screen.dart
// Screening results dashboard with risk banner, score breakdown, reason list, recommendations, flexion chart, extracted markers, and SQLite persistence.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gait_features.dart';
import '../models/patient_record.dart';
import '../services/database_helper.dart';
import '../services/scoring_service.dart';
import '../translations.dart';
import '../widgets/flexion_chart.dart';
import '../widgets/language_toggle.dart';
import 'patient_details_screen.dart';

class ResultsScreen extends StatefulWidget {
  final String lang;
  final ValueChanged<String> onLanguageChanged;
  final String patientId;
  final String name;
  final int age;
  final String sex;
  final String occupation;
  final String visitDate;
  final int womacPainWalking;
  final int womacPainStairs;
  final int womacStiffness;
  final int womacRising;
  final int womacSquatting;
  final int womacTotal;
  final GaitFeatures features;

  const ResultsScreen({
    super.key,
    required this.lang,
    required this.onLanguageChanged,
    required this.patientId,
    required this.name,
    required this.age,
    required this.sex,
    required this.occupation,
    required this.visitDate,
    required this.womacPainWalking,
    required this.womacPainStairs,
    required this.womacStiffness,
    required this.womacRising,
    required this.womacSquatting,
    required this.womacTotal,
    required this.features,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late RiskScoreResult _riskResult;
  bool _savedToDb = false;

  @override
  void initState() {
    super.initState();
    _riskResult = ScoringService.scoreRisk(widget.features, widget.womacTotal);
    _autoSaveToDatabase();
  }

  Future<void> _autoSaveToDatabase() async {
    final nowStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final record = PatientRecord(
      timestamp: nowStr,
      visitDate: widget.visitDate,
      patientId: widget.patientId,
      name: widget.name,
      age: widget.age,
      sex: widget.sex,
      occupation: widget.occupation,
      womacPainWalking: widget.womacPainWalking,
      womacPainStairs: widget.womacPainStairs,
      womacStiffness: widget.womacStiffness,
      womacRising: widget.womacRising,
      womacSquatting: widget.womacSquatting,
      womacTotal: widget.womacTotal,
      romLeft: widget.features.romLeft,
      romRight: widget.features.romRight,
      romAsymmetry: widget.features.romAsymmetry,
      peakFlexionRight: widget.features.peakFlexionRight,
      cadence: widget.features.cadence,
      jerkLeft: widget.features.jerkLeft,
      jerkRight: widget.features.jerkRight,
      sitToStandTime: widget.features.sitToStandTime,
      inputSource: widget.features.inputSource,
      poseConfidence: widget.features.confidence,
      framesTracked: widget.features.framesTracked,
      gaitScore: _riskResult.gaitPoints,
      symptomScore: _riskResult.symptomPoints,
      riskBand: _riskResult.band,
      riskScore: _riskResult.totalScore,
    );

    try {
      await DatabaseHelper.instance.insertRecord(record);
      if (mounted) {
        setState(() => _savedToDb = true);
      }
    } catch (e) {
      debugPrint('Error saving record to SQLite: $e');
    }
  }

  Map<String, Color> _getRiskStyle(String band) {
    switch (band) {
      case 'Extreme':
        return {
          'bg': const Color(0xFFFEF2F2),
          'border': const Color(0xFFFCA5A5),
          'text': const Color(0xFFB91C1C),
        };
      case 'High':
        return {
          'bg': const Color(0xFFFFF7ED),
          'border': const Color(0xFFFDBA74),
          'text': const Color(0xFFC2410C),
        };
      case 'Moderate':
        return {
          'bg': const Color(0xFFFFFBEB),
          'border': const Color(0xFFFCD34D),
          'text': const Color(0xFFB45309),
        };
      case 'Low':
      default:
        return {
          'bg': const Color(0xFFECFDF5),
          'border': const Color(0xFF86EFAC),
          'text': const Color(0xFF15803D),
        };
    }
  }

  String _getRiskBandLabel(String band, String lang) {
    switch (band) {
      case 'Extreme':
        return t('risk_extreme', lang);
      case 'High':
        return t('risk_high', lang);
      case 'Moderate':
        return t('risk_moderate', lang);
      case 'Low':
      default:
        return t('risk_low', lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final style = _getRiskStyle(_riskResult.band);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('app_title', lang),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade700,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: LanguageToggle(
              currentLang: widget.lang,
              onLanguageChanged: widget.onLanguageChanged,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Header Summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID: ${widget.patientId}  |  ${widget.age} ${t("age", lang)} (${widget.sex})',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                        if (_savedToDb)
                          const Chip(
                            avatar: Icon(Icons.check, size: 16, color: Colors.green),
                            label: Text('Saved Offline', style: TextStyle(fontSize: 11)),
                            backgroundColor: Color(0xFFECFDF5),
                          ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.sensors, size: 16, color: Colors.teal),
                        const SizedBox(width: 6),
                        Text(
                          '${t("data_source", lang)}: ',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.features.inputSource,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Risk Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: style['bg'],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: style['border']!, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    _getRiskBandLabel(_riskResult.band, lang).toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: style['text'],
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${t("total_score", lang)}: ${_riskResult.totalScore} / 12',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: style['text'],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Signal Quality Metric
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          t('confidence', lang),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(widget.features.confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 24, width: 1, color: Colors.grey.shade300),
                    Column(
                      children: [
                        Text(
                          t('frames_analyzed', lang),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.features.framesTracked}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Score Breakdown Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('score_breakdown', lang),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSubScoreBox(
                            t('gait_subscore', lang),
                            '${_riskResult.gaitPoints} / 6',
                            Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSubScoreBox(
                            t('symptom_subscore', lang),
                            '${_riskResult.symptomPoints} / 6',
                            Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Why this score
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          t('why_score', lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_riskResult.reasons.isEmpty)
                      const Text(
                        'No significant OA risk indicators identified.',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Column(
                        children: _riskResult.reasons
                            .map(
                              (reason) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16)),
                                    Expanded(
                                      child: Text(
                                        reason,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Recommended next steps
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_services_outlined, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          t('next_steps', lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _riskResult.recommendations
                          .map(
                            (rec) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 18, color: Colors.teal),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      rec,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Knee Flexion Angle Chart
            FlexionChart(
              leftTrajectory: widget.features.leftTrajectory,
              rightTrajectory: widget.features.rightTrajectory,
              lang: lang,
            ),
            const SizedBox(height: 14),

            // Extracted Markers Table
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('gait_markers', lang),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                      children: [
                        _buildTableRow(t('marker_rom_l', lang),
                            '${widget.features.romLeft.toStringAsFixed(1)}°'),
                        _buildTableRow(t('marker_rom_r', lang),
                            '${widget.features.romRight.toStringAsFixed(1)}°'),
                        _buildTableRow(t('marker_asymmetry', lang),
                            '${(widget.features.romAsymmetry * 100).toStringAsFixed(1)}%'),
                        _buildTableRow(t('marker_peak_r', lang),
                            '${widget.features.peakFlexionRight.toStringAsFixed(1)}°'),
                        _buildTableRow(t('marker_cadence', lang),
                            '${widget.features.cadence.toStringAsFixed(1)}'),
                        _buildTableRow(t('marker_sts_time', lang),
                            '${widget.features.sitToStandTime.toStringAsFixed(1)}s'),
                        _buildTableRow(t('marker_jerk_l', lang),
                            widget.features.jerkLeft.toStringAsFixed(3)),
                        _buildTableRow(t('marker_jerk_r', lang),
                            widget.features.jerkRight.toStringAsFixed(3)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Diagnostic Disclaimer Alert
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t('disclaimer', lang),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Restart screening button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => PatientDetailsScreen(
                      currentLang: widget.lang,
                      onLanguageChanged: widget.onLanguageChanged,
                    ),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                t('restart_screening', lang),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSubScoreBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String val) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
