// lib/services/pose_detection_service.dart
// Real On-Device Offline Pose Detection & Gait Marker Extractor using Google ML Kit Pose Detection (BlazePose 33 Landmarks).

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/gait_features.dart';

class PosePoint {
  final double x;
  final double y;
  final double likelihood;
  PosePoint(this.x, this.y, this.likelihood);
}

class AnnotatedFrameData {
  final int frameIndex;
  final List<PosePoint> landmarks;
  final double leftFlexion;
  final double rightFlexion;
  final double confidence;

  AnnotatedFrameData({
    required this.frameIndex,
    required this.landmarks,
    required this.leftFlexion,
    required this.rightFlexion,
    required this.confidence,
  });
}

class PoseDetectionService {
  /// Calculate joint angle at point B between vectors B->A (hip) and B->C (ankle) in degrees.
  static double calculateFlexionAngle(PosePoint a, PosePoint b, PosePoint c) {
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

    // Flexion: 0 = straight leg, higher = more bent
    return (180.0 - angleDeg).clamp(-15.0, 130.0);
  }

  /// 1D Moving average smoothing
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

  /// Count steps using adaptive thresholding with refractory gap
  static int countSteps(List<double> signal, double fps) {
    if (signal.length < 10) return 0;

    double mean = signal.reduce((a, b) => a + b) / signal.length;
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

  /// Standard deviation of 3rd order difference signal (Jerk metric)
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

  /// Extract ML Kit Pose landmarks from InputImage
  static Future<PoseLandmarkResult?> processSingleImage(InputImage inputImage) async {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.single,
      model: PoseDetectionModel.accurate,
    );
    final poseDetector = PoseDetector(options: options);

    try {
      final poses = await poseDetector.processImage(inputImage);
      if (poses.isEmpty) return null;

      final pose = poses.first;
      final landmarks = pose.landmarks;

      final lHip = landmarks[PoseLandmarkType.leftHip];
      final lKnee = landmarks[PoseLandmarkType.leftKnee];
      final lAnkle = landmarks[PoseLandmarkType.leftAnkle];

      final rHip = landmarks[PoseLandmarkType.rightHip];
      final rKnee = landmarks[PoseLandmarkType.rightKnee];
      final rAnkle = landmarks[PoseLandmarkType.rightAnkle];

      if (lHip == null || lKnee == null || lAnkle == null || rHip == null || rKnee == null || rAnkle == null) {
        return null;
      }

      final ptLHip = PosePoint(lHip.x, lHip.y, lHip.likelihood);
      final ptLKnee = PosePoint(lKnee.x, lKnee.y, lKnee.likelihood);
      final ptLAnkle = PosePoint(lAnkle.x, lAnkle.y, lAnkle.likelihood);

      final ptRHip = PosePoint(rHip.x, rHip.y, rHip.likelihood);
      final ptRKnee = PosePoint(rKnee.x, rKnee.y, rKnee.likelihood);
      final ptRAnkle = PosePoint(rAnkle.x, rAnkle.y, rAnkle.likelihood);

      double flexL = calculateFlexionAngle(ptLHip, ptLKnee, ptLAnkle);
      double flexR = calculateFlexionAngle(ptRHip, ptRKnee, ptRAnkle);
      double avgConf = (lHip.likelihood + lKnee.likelihood + lAnkle.likelihood + rHip.likelihood + rKnee.likelihood + rAnkle.likelihood) / 6.0;

      return PoseLandmarkResult(
        leftFlexion: flexL,
        rightFlexion: flexR,
        confidence: avgConf,
        leftHip: ptLHip,
        leftKnee: ptLKnee,
        leftAnkle: ptLAnkle,
        rightHip: ptRHip,
        rightKnee: ptRKnee,
        rightAnkle: ptRAnkle,
      );
    } catch (e) {
      debugPrint('ML Kit Pose Detector Error: $e');
      return null;
    } finally {
      poseDetector.close();
    }
  }

  /// Process complete frame-by-frame video angle signals into GaitFeatures
  static GaitFeatures processAngleSignals({
    required List<double> leftAngles,
    required List<double> rightAngles,
    required double avgConfidence,
    double fps = 30.0,
    double sitToStandTime = 2.1,
    String inputSource = 'Google ML Kit Pose Detection (Offline BlazePose)',
  }) {
    List<double> left = leftAngles.map((x) => x.clamp(-15.0, 130.0)).toList();
    List<double> right = rightAngles.map((x) => x.clamp(-15.0, 130.0)).toList();

    left = smoothSignal(left);
    right = smoothSignal(right);

    double romL = left.reduce(max) - left.reduce(min);
    double romR = right.reduce(max) - right.reduce(min);
    double asymmetry = (romL - romR).abs() / max(romL, max(romR, 1e-6));
    double peakR = right.reduce(max);

    double duration = left.length / fps;
    int stepsL = countSteps(left, fps);
    int stepsR = countSteps(right, fps);
    double cadence = duration > 0 ? ((stepsL + stepsR) / duration) * 60.0 : 0.0;

    double jerkL = computeJerk(left);
    double jerkR = computeJerk(right);

    return GaitFeatures(
      romLeft: romL,
      romRight: romR,
      romAsymmetry: asymmetry,
      peakFlexionRight: peakR,
      cadence: cadence,
      jerkLeft: jerkL,
      jerkRight: jerkR,
      sitToStandTime: sitToStandTime,
      inputSource: inputSource,
      leftTrajectory: left,
      rightTrajectory: right,
      confidence: avgConfidence,
      framesTracked: left.length,
    );
  }
}

class PoseLandmarkResult {
  final double leftFlexion;
  final double rightFlexion;
  final double confidence;
  final PosePoint leftHip;
  final PosePoint leftKnee;
  final PosePoint leftAnkle;
  final PosePoint rightHip;
  final PosePoint rightKnee;
  final PosePoint rightAnkle;

  PoseLandmarkResult({
    required this.leftFlexion,
    required this.rightFlexion,
    required this.confidence,
    required this.leftHip,
    required this.leftKnee,
    required this.leftAnkle,
    required this.rightHip,
    required this.rightKnee,
    required this.rightAnkle,
  });
}
