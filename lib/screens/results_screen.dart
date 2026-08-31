// lib/screens/results_screen.dart
// Screening results dashboard with risk banner, score breakdown, differential diagnosis triage, flexion chart & markers table.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gait_features.dart';
import '../models/patient_record.dart';
import '../services/database_helper.dart';
import '../services/scoring_service.dart';
import '../theme/app_theme.dart';
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
  final ComorbidityInputs? comorbidities;
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
    this.comorbidities,
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
    _riskResult = ScoringService.scoreRisk(
      widget.features,
      widget.womacTotal,
      comorbidities: widget.comorbidities,
    );
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
          'bg': AppTheme.riskExtremeBg,
          'border': AppTheme.riskExtremeBorder,
          'text': AppTheme.riskExtremeText,
        };
      case 'High':
        return {
          'bg': AppTheme.riskHighBg,
          'border': AppTheme.riskHighBorder,
          'text': AppTheme.riskHighText,
        };
      case 'Moderate':
        return {
          'bg': AppTheme.riskModerateBg,
          'border': AppTheme.riskModerateBorder,
          'text': AppTheme.riskModerateText,
        };
      case 'Low':
      default:
        return {
          'bg': AppTheme.riskLowBg,
          'border': AppTheme.riskLowBorder,
          'text': AppTheme.riskLowText,
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
    final diffResult = _riskResult.differentialResult;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('app_title', lang),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryNavy,
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Header Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${widget.patientId}  |  ${widget.age} ${t("age", lang)} (${widget.sex})',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                        if (_savedToDb)
                          const Chip(
                            avatar: Icon(Icons.check, size: 16, color: Colors.green),
                            label: Text('Saved Offline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            backgroundColor: Color(0xFFECFDF5),
                          ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.sensors, size: 18, color: AppTheme.electricTeal),
                        const SizedBox(width: 8),
                        Text(
                          '${t("data_source", lang)}: ',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.features.inputSource,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.electricTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Risk Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: style['bg'],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: style['border']!, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    _getRiskBandLabel(_riskResult.band, lang).toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: style['text'],
                      letterSpacing: 1.2,
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
            const SizedBox(height: 16),

            // Screenshot-Matching Knee Flexion Trajectory Chart & Extracted Markers Dashboard
            FlexionChart(
              features: widget.features,
              lang: lang,
            ),
            const SizedBox(height: 16),

            // Differential Diagnosis & Comorbidity Triage Card
            if (diffResult.warnings.isNotEmpty) ...[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFFDBA74), width: 1.5),
                ),
                color: const Color(0xFFFFF7ED),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.biotech, color: Color(0xFFC2410C)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t('diff_diagnosis_header', lang),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC2410C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: diffResult.warnings.map((warn) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFC2410C)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    warn,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF9A3412),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Score Breakdown Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSubScoreBox(
                            t('gait_subscore', lang),
                            '${_riskResult.gaitPoints} / 6',
                            AppTheme.leftKneeDarkBlue,
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
            const SizedBox(height: 16),

            // Why this score
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline, color: AppTheme.electricTeal),
                        const SizedBox(width: 8),
                        Text(
                          t('why_score', lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.electricTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_riskResult.reasons.isEmpty)
                      const Text('No significant OA risk indicators identified.', style: TextStyle(color: Colors.grey))
                    else
                      Column(
                        children: _riskResult.reasons
                            .map(
                              (reason) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Expanded(
                                      child: Text(reason, style: const TextStyle(fontSize: 14)),
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
            const SizedBox(height: 16),

            // Recommended next steps
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_services_outlined, color: AppTheme.electricTeal),
                        const SizedBox(width: 8),
                        Text(
                          t('next_steps', lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.electricTeal,
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
                                  const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.electricTeal),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(rec, style: const TextStyle(fontSize: 14)),
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
            const SizedBox(height: 16),

            // Diagnostic Disclaimer Alert
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
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
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
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
        borderRadius: BorderRadius.circular(12),
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
}
