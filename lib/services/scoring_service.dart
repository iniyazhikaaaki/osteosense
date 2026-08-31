// lib/services/scoring_service.dart
// Weighted clinical scoring engine prioritizing MediaPipe BlazePose Video Gait Analysis (70% weightage) over WOMAC questionnaire (30% weightage).

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

class ComorbidityInputs {
  final bool longMorningStiffness;
  final bool bilateralHands;
  final bool suddenSwelling;
  final bool radiatingNumbness;
  final bool lockingSensation;

  ComorbidityInputs({
    this.longMorningStiffness = false,
    this.bilateralHands = false,
    this.suddenSwelling = false,
    this.radiatingNumbness = false,
    this.lockingSensation = false,
  });
}

class DifferentialDiagnosisResult {
  final List<String> warnings;
  final List<String> clinicalNotes;

  DifferentialDiagnosisResult({
    required this.warnings,
    required this.clinicalNotes,
  });
}

class RiskScoreResult {
  final String band; // Low, Moderate, High, Extreme
  final int totalScore;
  final int gaitPoints;
  final int symptomPoints;
  final List<String> reasons;
  final List<String> recommendations;
  final DifferentialDiagnosisResult differentialResult;

  RiskScoreResult({
    required this.band,
    required this.totalScore,
    required this.gaitPoints,
    required this.symptomPoints,
    required this.reasons,
    required this.recommendations,
    required this.differentialResult,
  });
}

class ScoringService {
  static const int gaitScoreMax = 8; // Primary weightage (70%)
  static const int symptomScoreMax = 4; // Secondary weightage (30%)
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

  /// Primary Gait Sub-Score (0-8) derived from MediaPipe BlazePose Video Joint Tracking.
  /// Carries 70% primary diagnostic weightage.
  static GaitScoreResult scoreGait(GaitFeatures features) {
    int points = 0;
    List<String> reasons = [];

    double worstRom = features.romLeft < features.romRight
        ? features.romLeft
        : features.romRight;

    if (worstRom < 20) {
      points += 4;
      reasons.add(
          "Knee flexion range severely restricted (${worstRom.toStringAsFixed(0)}°)");
    } else if (worstRom < 25) {
      points += 3;
      reasons.add(
          "Knee flexion range moderately restricted (${worstRom.toStringAsFixed(0)}°)");
    } else if (worstRom < 30) {
      points += 2;
      reasons.add(
          "Knee flexion range mildly restricted (${worstRom.toStringAsFixed(0)}°)");
    } else if (worstRom < 35) {
      points += 1;
      reasons.add(
          "Knee flexion range slightly restricted (${worstRom.toStringAsFixed(0)}°)");
    }

    double asymmetry = features.romAsymmetry;
    if (asymmetry >= 0.45) {
      points += 4;
      reasons.add(
          "Severe left-right gait asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    } else if (asymmetry >= 0.35) {
      points += 3;
      reasons.add(
          "Marked left-right gait asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    } else if (asymmetry >= 0.20) {
      points += 2;
      reasons.add(
          "Moderate left-right gait asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    } else if (asymmetry >= 0.10) {
      points += 1;
      reasons.add(
          "Mild left-right gait asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    }

    return GaitScoreResult(points, reasons);
  }

  /// Secondary Questionnaire Sub-Score (0-4) from WOMAC-lite (0-20) total.
  /// Carries 30% secondary diagnostic weightage.
  static SymptomScoreResult scoreSymptoms(int womac) {
    if (womac >= 15) {
      return SymptomScoreResult(
          4, ["High reported symptoms (WOMAC-lite $womac/20)"]);
    }
    if (womac >= 10) {
      return SymptomScoreResult(
          3, ["Moderate reported symptoms (WOMAC-lite $womac/20)"]);
    }
    if (womac >= 5) {
      return SymptomScoreResult(
          2, ["Mild reported symptoms (WOMAC-lite $womac/20)"]);
    }
    return SymptomScoreResult(0, []);
  }

  /// Differential Diagnosis Engine for differentiating Osteoarthritis from RA, Gout, Neuropathy, or Meniscal Tear
  static DifferentialDiagnosisResult evaluateDifferential(ComorbidityInputs inputs) {
    List<String> warnings = [];
    List<String> notes = [];

    if (inputs.longMorningStiffness || inputs.bilateralHands) {
      warnings.add(
          'Inflammatory Polyarthritis Overlap (Rheumatoid Arthritis suspected): Order RF, Anti-CCP, ESR/CRP blood panel.');
      notes.add(
          'Morning stiffness > 60 mins or bilateral small joint pain suggests systemic inflammatory arthritis rather than isolated mechanical OA.');
    }

    if (inputs.suddenSwelling) {
      warnings.add(
          'Acute Crystal Arthropathy Overlap (Gout / Pseudogout suspected): Order serum uric acid check & joint fluid analysis.');
      notes.add(
          'Sudden hot, red, acute joint swelling is characteristic of microcrystalline flares (uric acid / CPPD) rather than chronic OA wear.');
    }

    if (inputs.radiatingNumbness) {
      warnings.add(
          'Neuropathic / Radicular Gait Overlap: Perform lumbar spine neurological assessment (L3-L5 radiculopathy).');
      notes.add(
          'Radiating numbness or tingling suggests nerve root compression or peripheral neuropathy confounding gait mechanics.');
    }

    if (inputs.lockingSensation) {
      warnings.add(
          'Structural Meniscal / Ligamentous Injury Overlap: Order knee MRI & McMurray test.');
      notes.add(
          'True mechanical knee locking or catch indicates a meniscus tear or loose body requiring structural MRI evaluation.');
    }

    return DifferentialDiagnosisResult(warnings: warnings, clinicalNotes: notes);
  }

  /// Composite Risk Score Prioritizing MediaPipe BlazePose Video Output (70% weightage):
  /// Total < 3: Low Risk (Green - Normal Healthy Knee)
  /// Total 3 - 5: Moderate Risk (Yellow - Early/Mild OA)
  /// Total 6 - 8: High Risk (Orange - Significant OA)
  /// Total >= 9: Extreme Risk (Red - Severe OA)
  static RiskScoreResult scoreRisk(
    GaitFeatures features,
    int womac, {
    ComorbidityInputs? comorbidities,
  }) {
    final gaitRes = scoreGait(features);
    final sympRes = scoreSymptoms(womac);
    final diffRes = evaluateDifferential(comorbidities ?? ComorbidityInputs());

    int total = gaitRes.points + sympRes.points;

    String band;
    if (total >= 9) {
      band = 'Extreme';
    } else if (total >= 6) {
      band = 'High';
    } else if (total >= 3) {
      band = 'Moderate';
    } else {
      band = 'Low';
    }

    List<String> combinedReasons = [
      ...gaitRes.reasons,
      ...sympRes.reasons,
    ];

    List<String> recs = recommendationsMap[band] ?? [];

    return RiskScoreResult(
      band: band,
      totalScore: total,
      gaitPoints: gaitRes.points,
      symptomPoints: sympRes.points,
      reasons: combinedReasons,
      recommendations: recs,
      differentialResult: diffRes,
    );
  }
}
