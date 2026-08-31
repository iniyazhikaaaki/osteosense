// test/scoring_service_test.dart
// Unit tests verifying scoring service and Differential Diagnosis evaluation.

import 'package:flutter_test/flutter_test.dart';
import 'package:osteosense/models/gait_features.dart';
import 'package:osteosense/services/scoring_service.dart';

void main() {
  group('OsteoSense Scoring & Differential Diagnosis Unit Tests', () {
    test('Normal Gait & Low WOMAC -> Low Risk Band', () {
      final features = GaitFeatures(
        romLeft: 38.0,
        romRight: 36.0,
        romAsymmetry: 0.055,
        peakFlexionRight: 41.0,
        cadence: 105.0,
        jerkLeft: 0.12,
        jerkRight: 0.14,
      );

      final result = ScoringService.scoreRisk(features, 2);

      expect(result.gaitPoints, equals(0));
      expect(result.symptomPoints, equals(0));
      expect(result.totalScore, equals(0));
      expect(result.band, equals('Low'));
      expect(result.reasons, isEmpty);
      expect(result.recommendations, isNotEmpty);
    });

    test('Severe ROM & High Asymmetry & WOMAC -> Extreme Risk', () {
      final features = GaitFeatures(
        romLeft: 18.0,
        romRight: 38.0,
        romAsymmetry: 0.52,
        peakFlexionRight: 43.0,
        cadence: 98.0,
        jerkLeft: 0.45,
        jerkRight: 0.12,
      );

      final result = ScoringService.scoreRisk(features, 16);

      expect(result.gaitPoints, equals(6));
      expect(result.symptomPoints, equals(6));
      expect(result.totalScore, equals(12));
      expect(result.band, equals('Extreme'));
    });

    test('Differential Diagnosis Engine detects RA & Lumbar Radiculopathy flags', () {
      final comorbidities = ComorbidityInputs(
        longMorningStiffness: true,
        bilateralHands: true,
        radiatingNumbness: true,
      );

      final diffResult = ScoringService.evaluateDifferential(comorbidities);

      expect(diffResult.warnings.length, equals(2));
      expect(diffResult.warnings[0], contains('Inflammatory Polyarthritis Overlap'));
      expect(diffResult.warnings[1], contains('Neuropathic / Radicular Gait Overlap'));
    });
  });
}
