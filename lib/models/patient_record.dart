// lib/models/patient_record.dart
// Patient screening record model for SQLite persistence.

class PatientRecord {
  final int? id;
  final String timestamp;
  final String visitDate;
  final String patientId;
  final String name;
  final int age;
  final String sex;
  final String occupation;

  // WOMAC Lite Scores
  final int womacPainWalking;
  final int womacPainStairs;
  final int womacStiffness;
  final int womacRising;
  final int womacSquatting;
  final int womacTotal;

  // Gait Features
  final double romLeft;
  final double romRight;
  final double romAsymmetry;
  final double peakFlexionRight;
  final double cadence;
  final double jerkLeft;
  final double jerkRight;
  final double poseConfidence;
  final int framesTracked;

  // Computed Assessment Results
  final int gaitScore;
  final int symptomScore;
  final String riskBand;
  final int riskScore;

  PatientRecord({
    this.id,
    required this.timestamp,
    required this.visitDate,
    required this.patientId,
    required this.name,
    required this.age,
    required this.sex,
    required this.occupation,
    required this.womacPainWalking,
    required this.womacPainStairs,
    required this.womacStiffness,
    required this.womacRising,
    required this.womacSquatting,
    required this.womacTotal,
    required this.romLeft,
    required this.romRight,
    required this.romAsymmetry,
    required this.peakFlexionRight,
    required this.cadence,
    required this.jerkLeft,
    required this.jerkRight,
    required this.poseConfidence,
    required this.framesTracked,
    required this.gaitScore,
    required this.symptomScore,
    required this.riskBand,
    required this.riskScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'visit_date': visitDate,
      'patient_id': patientId,
      'name': name,
      'age': age,
      'sex': sex,
      'occupation': occupation,
      'womac_pain_walking': womacPainWalking,
      'womac_pain_stairs': womacPainStairs,
      'womac_stiffness': womacStiffness,
      'womac_rising': womacRising,
      'womac_squatting': womacSquatting,
      'womac_total': womacTotal,
      'rom_left': romLeft,
      'rom_right': romRight,
      'rom_asymmetry': romAsymmetry,
      'peak_flexion_right': peakFlexionRight,
      'cadence': cadence,
      'jerk_left': jerkLeft,
      'jerk_right': jerkRight,
      'pose_confidence': poseConfidence,
      'frames_tracked': framesTracked,
      'gait_score': gaitScore,
      'symptom_score': symptomScore,
      'risk_band': riskBand,
      'risk_score': riskScore,
    };
  }

  factory PatientRecord.fromMap(Map<String, dynamic> map) {
    return PatientRecord(
      id: map['id'] as int?,
      timestamp: map['timestamp'] as String? ?? '',
      visitDate: map['visit_date'] as String? ?? '',
      patientId: map['patient_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      age: (map['age'] as num? ?? 0).toInt(),
      sex: map['sex'] as String? ?? '',
      occupation: map['occupation'] as String? ?? '',
      womacPainWalking: (map['womac_pain_walking'] as num? ?? 0).toInt(),
      womacPainStairs: (map['womac_pain_stairs'] as num? ?? 0).toInt(),
      womacStiffness: (map['womac_stiffness'] as num? ?? 0).toInt(),
      womacRising: (map['womac_rising'] as num? ?? 0).toInt(),
      womacSquatting: (map['womac_squatting'] as num? ?? 0).toInt(),
      womacTotal: (map['womac_total'] as num? ?? 0).toInt(),
      romLeft: (map['rom_left'] as num? ?? 0.0).toDouble(),
      romRight: (map['rom_right'] as num? ?? 0.0).toDouble(),
      romAsymmetry: (map['rom_asymmetry'] as num? ?? 0.0).toDouble(),
      peakFlexionRight: (map['peak_flexion_right'] as num? ?? 0.0).toDouble(),
      cadence: (map['cadence'] as num? ?? 0.0).toDouble(),
      jerkLeft: (map['jerk_left'] as num? ?? 0.0).toDouble(),
      jerkRight: (map['jerk_right'] as num? ?? 0.0).toDouble(),
      poseConfidence: (map['pose_confidence'] as num? ?? 0.0).toDouble(),
      framesTracked: (map['frames_tracked'] as num? ?? 0).toInt(),
      gaitScore: (map['gait_score'] as num? ?? 0).toInt(),
      symptomScore: (map['symptom_score'] as num? ?? 0).toInt(),
      riskBand: map['risk_band'] as String? ?? 'Low',
      riskScore: (map['risk_score'] as num? ?? 0).toInt(),
    );
  }
}
