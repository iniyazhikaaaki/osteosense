// lib/services/scoring_service.dart
// Port of the Python reference scoring engine (Section 6 of brief) to Dart.

import '../models/gait_features.dart';

class GaitScoreResult {
  final int points;
  final List<String> reasons;
  GaitScoreResult(this.points, this.reasons);
}

class SymptomScoreResult {
  final int points;
  final List<String> reasons;
  SymptomScoreResult(this.points, this.reasons);
}

class RiskScoreResult {
  final String band; // Low, Moderate, High, Extreme
  final int totalScore;
  final int gaitPoints;
  final int symptomPoints;
  final List<String> reasons;
  final List<String> recommendations;

  RiskScoreResult({
    required this.band,
    required this.totalScore,
    required this.gaitPoints,
    required this.symptomPoints,
    required this.reasons,
    required this.recommendations,
  });
}

class ScoringService {
  static const int gaitScoreMax = 6;
  static const int symptomScoreMax = 6;
  static const int totalScoreMax = 12;

  static const Map<String, List<String>> recommendationsMap = {
    'Low': [
      'No significant gait or symptom impairment detected — continue normal activity.',
      'General joint health: maintain a healthy weight, stay active with low-impact exercise (walking, cycling, swimming).',
      'Rescreen in 6-12 months, or sooner if pain or stiffness develops.',
    ],
    'Moderate': [
      'Start a structured physiotherapy program focused on quadriceps and hamstring strengthening and flexibility.',
      'Hot/cold contrast therapy for stiffness — warm compress before activity, ice after, 10-15 minutes each.',
      'Reduce high-impact loading (running, deep squats, stairs) until symptoms ease.',
      'Over-the-counter analgesics as needed, under medical guidance.',
      'Rescreen in 4-6 weeks to track trend.',
    ],
    'High': [
      'Refer to an orthopedic specialist for clinical evaluation.',
      'Imaging recommended (X-ray / MRI) to assess joint space narrowing and confirm severity.',
      'Intensive supervised physiotherapy; consider a knee brace or offloading support.',
      'Discuss intra-articular options (corticosteroid or hyaluronic acid injection) if conservative treatment stalls.',
      'Weight management referral if applicable — reduces joint load significantly.',
    ],
    'Extreme': [
      'Urgent orthopedic surgical consultation — evaluate candidacy for arthroscopy, osteotomy, or total knee replacement depending on imaging and severity.',
      'Pain management referral in the interim.',
      'Mobility aid assessment (cane / walker) to reduce fall risk and joint strain.',
      'Continue physiotherapy pre- and post-intervention as advised by the specialist.',
    ],
  };

  static GaitScoreResult scoreGait(GaitFeatures features) {
    int points = 0;
    List<String> reasons = [];

    double worstRom = features.romLeft < features.romRight
        ? features.romLeft
        : features.romRight;

    if (worstRom < 20) {
      points += 3;
      reasons.add(
          "Knee flexion range severely reduced (${worstRom.toStringAsFixed(0)} deg)");
    } else if (worstRom < 25) {
      points += 2;
      reasons.add(
          "Knee flexion range moderately reduced (${worstRom.toStringAsFixed(0)} deg)");
    } else if (worstRom < 30) {
      points += 1;
      reasons.add(
          "Knee flexion range mildly reduced (${worstRom.toStringAsFixed(0)} deg)");
    }

    double asymmetry = features.romAsymmetry;
    if (asymmetry >= 0.50) {
      points += 3;
      reasons.add(
          "Severe left-right asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    } else if (asymmetry >= 0.35) {
      points += 2;
      reasons.add(
          "Marked left-right asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    } else if (asymmetry >= 0.20) {
      points += 1;
      reasons.add(
          "Mild left-right asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    }

    return GaitScoreResult(points, reasons);
  }

  static SymptomScoreResult scoreSymptoms(int womac) {
    if (womac >= 15) {
      return SymptomScoreResult(
          6, ["Severe reported pain and stiffness (WOMAC-lite $womac/20)"]);
    } else if (womac >= 10) {
      return SymptomScoreResult(4,
          ["Moderate-to-high reported symptoms (WOMAC-lite $womac/20)"]);
    } else if (womac >= 5) {
      return SymptomScoreResult(
          2, ["Mild reported symptoms (WOMAC-lite $womac/20)"]);
    }
    return SymptomScoreResult(0, []);
  }

  static RiskScoreResult scoreRisk(GaitFeatures features, int womac) {
    final gait = scoreGait(features);
    final symptom = scoreSymptoms(womac);
    final total = gait.points + symptom.points;
    final reasons = [...gait.reasons, ...symptom.reasons];

    String band;
    if (total >= 8) {
      band = "Extreme";
    } else if (total >= 5) {
      band = "High";
    } else if (total >= 2) {
      band = "Moderate";
    } else {
      band = "Low";
    }

    final recommendations = recommendationsMap[band] ?? [];

    return RiskScoreResult(
      band: band,
      totalScore: total,
      gaitPoints: gait.points,
      symptomPoints: symptom.points,
      reasons: reasons,
      recommendations: recommendations,
    );
  }
}
