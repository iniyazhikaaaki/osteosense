// lib/models/gait_features.dart
// Decoupled gait features data structure. Accepts inputs from video pose analysis or BLE hardware sensor.

class GaitFeatures {
  final double romLeft;
  final double romRight;
  final double romAsymmetry;
  final double peakFlexionRight;
  final double cadence;
  final double jerkLeft;
  final double jerkRight;
  final List<double> leftTrajectory;
  final List<double> rightTrajectory;
  final double confidence;
  final int framesTracked;

  GaitFeatures({
    required this.romLeft,
    required this.romRight,
    required this.romAsymmetry,
    required this.peakFlexionRight,
    required this.cadence,
    required this.jerkLeft,
    required this.jerkRight,
    this.leftTrajectory = const [],
    this.rightTrajectory = const [],
    this.confidence = 0.92,
    this.framesTracked = 150,
  });

  Map<String, dynamic> toMap() {
    return {
      'Flexion ROM left (deg)': romLeft,
      'Flexion ROM right (deg)': romRight,
      'ROM asymmetry': romAsymmetry,
      'Peak flexion right (deg)': peakFlexionRight,
      'Cadence (steps/min)': cadence,
      'Jerk left': jerkLeft,
      'Jerk right': jerkRight,
    };
  }

  factory GaitFeatures.fromMap(Map<String, dynamic> map) {
    return GaitFeatures(
      romLeft: (map['Flexion ROM left (deg)'] as num).toDouble(),
      romRight: (map['Flexion ROM right (deg)'] as num).toDouble(),
      romAsymmetry: (map['ROM asymmetry'] as num).toDouble(),
      peakFlexionRight: (map['Peak flexion right (deg)'] as num).toDouble(),
      cadence: (map['Cadence (steps/min)'] as num).toDouble(),
      jerkLeft: (map['Jerk left'] as num).toDouble(),
      jerkRight: (map['Jerk right'] as num).toDouble(),
    );
  }
}
