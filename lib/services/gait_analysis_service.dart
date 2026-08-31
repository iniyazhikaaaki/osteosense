// lib/services/gait_analysis_service.dart
// Offline gait & mobility analysis engine generating realistic 650-frame trajectories matching clinical reference data.

import 'dart:math';
import '../models/gait_features.dart';

class Point2D {
  final double x;
  final double y;
  Point2D(this.x, this.y);
}

class GaitAnalysisService {
  /// Calculate joint angle at point B between segments B->A and B->C in degrees.
  static double calculateFlexionAngle(Point2D a, Point2D b, Point2D c) {
    double v1x = a.x - b.x;
    double v1y = a.y - b.y;
    double v2x = c.x - b.x;
    double v2y = c.y - b.y;

    double norm1 = sqrt(v1x * v1x + v1y * v1y);
    double norm2 = sqrt(v2x * v2x + v2y * v2y);

    double denom = norm1 * norm2;
    if (denom == 0) return 0.0;

    double dot = v1x * v2x + v1y * v2y;
    double cosine = (dot / denom).clamp(-1.0, 1.0);
    double angleDeg = acos(cosine) * (180.0 / pi);

    return (180.0 - angleDeg).clamp(-15.0, 130.0);
  }

  /// Simple moving average filter over a 1D signal array
  static List<double> smoothSignal(List<double> signal, {int window = 5}) {
    if (signal.length < window) return List.from(signal);
    List<double> smoothed = List.filled(signal.length, 0.0);
    int halfWin = window ~/ 2;

    for (int i = 0; i < signal.length; i++) {
      double sum = 0.0;
      int count = 0;
      for (int j = i - halfWin; j <= i + halfWin; j++) {
        if (j >= 0 && j < signal.length) {
          sum += signal[j];
          count++;
        }
      }
      smoothed[i] = sum / count;
    }
    return smoothed;
  }

  /// Counts upward threshold crossings with adaptive refractory gap
  static int countSteps(List<double> signal, double fps) {
    if (signal.length < 10) return 0;

    double sum = signal.reduce((a, b) => a + b);
    double mean = sum / signal.length;

    double variance = signal
            .map((x) => pow(x - mean, 2))
            .reduce((a, b) => a + b) /
        signal.length;
    double std = sqrt(variance);

    double threshold = mean + 0.5 * std;
    List<int> crossingIdxs = [];

    for (int i = 0; i < signal.length - 1; i++) {
      if (signal[i] <= threshold && signal[i + 1] > threshold) {
        crossingIdxs.add(i + 1);
      }
    }

    if (crossingIdxs.isEmpty) return 0;

    int minGap = max(1, (fps * 0.4).toInt());
    int count = 1;
    int lastIdx = crossingIdxs[0];

    for (int i = 1; i < crossingIdxs.length; i++) {
      if (crossingIdxs[i] - lastIdx >= minGap) {
        count++;
        lastIdx = crossingIdxs[i];
      }
    }
    return count;
  }

  /// Compute standard deviation of 3rd order difference signal (Jerk metric)
  static double computeJerk(List<double> signal) {
    if (signal.length <= 4) return 0.0;

    List<double> diff1 = [];
    for (int i = 0; i < signal.length - 1; i++) {
      diff1.add(signal[i + 1] - signal[i]);
    }
    List<double> diff2 = [];
    for (int i = 0; i < diff1.length - 1; i++) {
      diff2.add(diff1[i + 1] - diff1[i]);
    }
    List<double> diff3 = [];
    for (int i = 0; i < diff2.length - 1; i++) {
      diff3.add(diff2[i + 1] - diff2[i]);
    }

    double mean = diff3.reduce((a, b) => a + b) / diff3.length;
    double variance = diff3
            .map((x) => pow(x - mean, 2))
            .reduce((a, b) => a + b) /
        diff3.length;
    return sqrt(variance);
  }

  /// Extract complete GaitFeatures from 650-frame left & right flexion signals
  static GaitFeatures computeFeatures(
    List<double> rawLeft,
    List<double> rawRight, {
    double fps = 30.0,
    double confidence = 0.94,
    double sitToStandTime = 2.4,
    String inputSource = 'Camera AI Pose Analysis',
  }) {
    List<double> left = rawLeft.map((x) => x.clamp(-15.0, 130.0)).toList();
    List<double> right = rawRight.map((x) => x.clamp(-15.0, 130.0)).toList();

    left = smoothSignal(left);
    right = smoothSignal(right);

    double maxL = left.reduce(max);
    double minL = left.reduce(min);
    double romL = maxL - minL;

    double maxR = right.reduce(max);
    double minR = right.reduce(min);
    double romR = maxR - minR;

    double maxRom = max(romL, max(romR, 1e-6));
    double asymmetry = (romL - romR).abs() / maxRom;

    double duration = right.isNotEmpty ? right.length / fps : 1.0;
    int stepsL = countSteps(left, fps);
    int stepsR = countSteps(right, fps);
    double cadence = duration > 0 ? ((stepsL + stepsR) / duration) * 60 : 0.0;

    double jerkL = computeJerk(left);
    double jerkR = computeJerk(right);

    return GaitFeatures(
      romLeft: double.parse(romL.toStringAsFixed(1)),
      romRight: double.parse(romR.toStringAsFixed(1)),
      romAsymmetry: double.parse(asymmetry.toStringAsFixed(3)),
      peakFlexionRight: double.parse(maxR.toStringAsFixed(1)),
      cadence: double.parse(cadence.toStringAsFixed(1)),
      jerkLeft: double.parse(jerkL.toStringAsFixed(3)),
      jerkRight: double.parse(jerkR.toStringAsFixed(3)),
      sitToStandTime: double.parse(sitToStandTime.toStringAsFixed(1)),
      inputSource: inputSource,
      leftTrajectory: left,
      rightTrajectory: right,
      confidence: confidence,
      framesTracked: left.length,
    );
  }

  /// Synthesizes realistic 650-frame gait trajectory matching the reference screenshot
  static GaitFeatures generateMockGaitData({
    bool impaired = false,
    bool isSensorInput = false,
  }) {
    int totalFrames = 650;
    List<double> left = [];
    List<double> right = [];
    Random rnd = Random(101);

    // Baseline ROM matching screenshot ranges (Left ~12.5 deg, Right ~21.1 deg in impaired mode)
    double baseRomL = impaired ? 12.5 : 38.0;
    double baseRomR = impaired ? 21.1 : 36.0;

    for (int i = 0; i < totalFrames; i++) {
      double phase = i / 18.0; // Stride cycle frequency

      // Primary swing peak + secondary stance harmonic ripple
      double waveL = sin(phase) * sin(phase) * baseRomL + sin(phase * 2.5) * 1.8;
      double waveR = sin(phase + pi / 2) * sin(phase + pi / 2) * baseRomR + cos(phase * 2.2) * 2.1;

      // Physiological gait noise & micro-jitter
      double noiseL = (rnd.nextDouble() - 0.5) * 1.2;
      double noiseR = (rnd.nextDouble() - 0.5) * 1.2;

      double valL = (waveL + noiseL).clamp(0.0, 30.0);
      double valR = (waveR + noiseR).clamp(0.0, 30.0);

      left.add(valL);
      right.add(valR);
    }

    double stsTime = impaired ? 4.2 : 2.1;
    String sourceStr = isSensorInput
        ? 'BLE Knee Sensor (100Hz IMU)'
        : 'Camera AI Pose Analysis';

    return computeFeatures(
      left,
      right,
      fps: 30.0,
      confidence: isSensorInput ? 0.99 : 0.95,
      sitToStandTime: stsTime,
      inputSource: sourceStr,
    );
  }
}
