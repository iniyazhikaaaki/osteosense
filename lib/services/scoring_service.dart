// lib/services/scoring_service.dart
// Port of the reference scoring engine to Dart with calibrated clinical thresholds & Differential Diagnosis Engine.

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
  static const int gaitScoreMax = 6;
  static const int symptomScoreMax = 6;
  static const int totalScoreMax = 12;

  static const Map<String, List<String>> recommendationsMap = {
    'Low': [
      'Normal knee biomechanics & symptom profile — No Osteoarthritis detected.',
      'Maintain general joint health with low-impact exercise (walking, swimming, cycling).',
      'Rescreen in 6-12 months or if new symptoms develop.',
    ],
    'Moderate': [
      'Start a structured physiotherapy program focused on quadriceps and hamstring strengthening.',
      'Hot/cold contrast therapy for stiffness — warm compress before activity, ice after.',
      'Reduce high-impact loading (running, deep squats) until symptoms ease.',
      'Rescreen in 4-6 weeks to track trend.',
    ],
    'High': [
      'Refer to an orthopedic specialist for clinical evaluation and imaging (X-ray / MRI).',
      'Intensive supervised physiotherapy; consider knee offloading support.',
      'Discuss intra-articular options if conservative treatment stalls.',
      'Weight management referral if applicable to reduce joint load.',
    ],
    'Extreme': [
      'Urgent orthopedic surgical consultation for total knee evaluation.',
      'Interim pain management & mobility aid assessment to reduce fall risk.',
      'Pre- and post-intervention physiotherapy as advised by specialist.',
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
          "Knee flexion range severely reduced (${worstRom.toStringAsFixed(0)}°)");
    } else if (worstRom < 26) {
      points += 2;
      reasons.add(
          "Knee flexion range moderately reduced (${worstRom.toStringAsFixed(0)}°)");
    } else if (worstRom < 32) {
      points += 1;
      reasons.add(
          "Knee flexion range mildly reduced (${worstRom.toStringAsFixed(0)}°)");
    }

    double asymmetry = features.romAsymmetry;
    if (asymmetry >= 0.45) {
      points += 3;
      reasons.add(
          "Severe left-right gait asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    } else if (asymmetry >= 0.30) {
      points += 2;
      reasons.add(
          "Marked left-right gait asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    } else if (asymmetry >= 0.15) {
      points += 1;
      reasons.add(
          "Mild left-right gait asymmetry (${(asymmetry * 100).toStringAsFixed(0)}%)");
    }

    return GaitScoreResult(points, reasons);
  }

  static SymptomScoreResult scoreSymptoms(int womac) {
    if (womac >= 16) {
      return SymptomScoreResult(
          6, ["Severe reported pain and stiffness (WOMAC-lite $womac/20)"]);
    } else if (womac >= 11) {
      return SymptomScoreResult(4,
          ["Moderate-to-high reported symptoms (WOMAC-lite $womac/20)"]);
    } else if (womac >= 6) {
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

    List<String> combinedReasons = []
      ..addAll(gaitRes.reasons)
      ..addAll(sympRes.reasons);

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
