// test/scoring_service_test.dart
// Unit tests verifying 70% Video Gait / 30% Questionnaire weighted scoring service.

import 'package:flutter_test/flutter_test.dart';
import 'package:osteosense/models/gait_features.dart';
import 'package:osteosense/services/scoring_service.dart';

void main() {
  group('OsteoSense Weighted Scoring Unit Tests', () {
    test('Normal Video Gait & Low WOMAC -> Low Risk (0/12)', () {
      final features = GaitFeatures(
        romLeft: 42.0,
        romRight: 40.5,
        romAsymmetry: 0.035,
        peakFlexionRight: 44.0,
        cadence: 112.0,
        jerkLeft: 0.12,
        jerkRight: 0.14,
      );

      final result = ScoringService.scoreRisk(features, 0);

      expect(result.gaitPoints, equals(0));
      expect(result.symptomPoints, equals(0));
      expect(result.totalScore, equals(0));
      expect(result.band, equals('Low'));
      expect(result.reasons, isEmpty);
      expect(result.recommendations, isNotEmpty);
    });

    test('Severe Video Gait ROM & WOMAC -> Extreme Risk (11/12)', () {
      final features = GaitFeatures(
        romLeft: 12.5,
        romRight: 21.1,
        romAsymmetry: 0.405,
        peakFlexionRight: 21.7,
        cadence: 127.2,
        jerkLeft: 0.44,
        jerkRight: 0.433,
      );

      final result = ScoringService.scoreRisk(features, 16);

      expect(result.gaitPoints, equals(7));
      expect(result.symptomPoints, equals(4));
      expect(result.totalScore, equals(11));
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
