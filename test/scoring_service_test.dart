// test/scoring_service_test.dart
// Unit tests verifying exact alignment between Python reference scoring rules and Dart implementation.

import 'package:flutter_test/flutter_test.dart';
import 'package:osteosense/models/gait_features.dart';
import 'package:osteosense/services/scoring_service.dart';

void main() {
  group('OsteoSense Scoring Service Unit Tests', () {
    test('Normal Gait & Low WOMAC -> Low Risk Band', () {
      final features = GaitFeatures(
        romLeft: 38.0,
        romRight: 36.0,
        romAsymmetry: 0.055, // < 0.20 threshold
        peakFlexionRight: 41.0,
        cadence: 105.0,
        jerkLeft: 0.12,
        jerkRight: 0.14,
      );

      final result = ScoringService.scoreRisk(features, 2); // WOMAC 2 < 5

      expect(result.gaitPoints, equals(0));
      expect(result.symptomPoints, equals(0));
      expect(result.totalScore, equals(0));
      expect(result.band, equals('Low'));
      expect(result.reasons, isEmpty);
      expect(result.recommendations, isNotEmpty);
    });

    test('Severe ROM reduction & High Asymmetry & High WOMAC -> Extreme Risk', () {
      final features = GaitFeatures(
        romLeft: 18.0, // < 20 deg -> +3 gait points
        romRight: 38.0,
        romAsymmetry: 0.52, // >= 0.50 -> +3 gait points
        peakFlexionRight: 43.0,
        cadence: 98.0,
        jerkLeft: 0.45,
        jerkRight: 0.12,
      );

      final result = ScoringService.scoreRisk(features, 16); // WOMAC >= 15 -> +6 symptom points

      expect(result.gaitPoints, equals(6));
      expect(result.symptomPoints, equals(6));
      expect(result.totalScore, equals(12));
      expect(result.band, equals('Extreme'));
      expect(result.reasons.length, equals(3));
      expect(result.reasons[0], contains('range severely reduced'));
      expect(result.reasons[1], contains('Severe left-right asymmetry'));
      expect(result.reasons[2], contains('Severe reported pain and stiffness'));
    });

    test('Moderate Gait & Moderate Symptoms -> Moderate/High Risk Band', () {
      final features = GaitFeatures(
        romLeft: 23.0, // < 25 deg -> +2 gait points
        romRight: 32.0,
        romAsymmetry: 0.28, // >= 0.20 -> +1 gait point
        peakFlexionRight: 37.0,
        cadence: 102.0,
        jerkLeft: 0.25,
        jerkRight: 0.18,
      );

      final result = ScoringService.scoreRisk(features, 7); // WOMAC >= 5 -> +2 symptom points

      expect(result.gaitPoints, equals(3));
      expect(result.symptomPoints, equals(2));
      expect(result.totalScore, equals(5));
      expect(result.band, equals('High'));
    });
  });
}
