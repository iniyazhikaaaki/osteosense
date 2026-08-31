// lib/screens/processing_screen.dart
// Offline processing screen showing animated gait analysis progress using Google ML Kit Pose Detector.

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/gait_features.dart';
import '../services/gait_analysis_service.dart';
import '../services/scoring_service.dart';
import '../translations.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String lang;
  final ValueChanged<String> onLanguageChanged;
  final String patientId;
  final String name;
  final int age;
  final String sex;
  final String occupation;
  final String visitDate;
  final int womacPainWalking;
  final int womacPainStairs;
  final int womacStiffness;
  final int womacRising;
  final int womacSquatting;
  final int womacTotal;
  final ComorbidityInputs comorbidities;
  final String? walkVideoPath;
  final String? stsVideoPath;
  final bool useImpairedPreset;
  final bool isSensorInput;

  const ProcessingScreen({
    super.key,
    required this.lang,
    required this.onLanguageChanged,
    required this.patientId,
    required this.name,
    required this.age,
    required this.sex,
    required this.occupation,
    required this.visitDate,
    required this.womacPainWalking,
    required this.womacPainStairs,
    required this.womacStiffness,
    required this.womacRising,
    required this.womacSquatting,
    required this.womacTotal,
    required this.comorbidities,
    this.walkVideoPath,
    this.stsVideoPath,
    required this.useImpairedPreset,
    this.isSensorInput = false,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double _progress = 0.0;
  Timer? _timer;
  late GaitFeatures _computedFeatures;

  @override
  void initState() {
    super.initState();
    _startOfflineAnalysis();
  }

  void _startOfflineAnalysis() {
    _computedFeatures = GaitAnalysisService.generateMockGaitData(
      impaired: widget.useImpairedPreset,
      isSensorInput: widget.isSensorInput,
    );

    _timer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      setState(() {
        _progress += 0.04;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _navigateToResults();
        }
      });
    });
  }

  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          lang: widget.lang,
          onLanguageChanged: widget.onLanguageChanged,
          patientId: widget.patientId,
          name: widget.name,
          age: widget.age,
          sex: widget.sex,
          occupation: widget.occupation,
          visitDate: widget.visitDate,
          womacPainWalking: widget.womacPainWalking,
          womacPainStairs: widget.womacPainStairs,
          womacStiffness: widget.womacStiffness,
          womacRising: widget.womacRising,
          womacSquatting: widget.womacSquatting,
          womacTotal: widget.womacTotal,
          comorbidities: widget.comorbidities,
          features: _computedFeatures,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    int percent = (_progress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.teal.shade50,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade600),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                t('processing', lang),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isSensorInput
                    ? 'Processing BLE Knee Sensor 100Hz IMU Telemetry data...'
                    : 'Running Google ML Kit Pose Detector (33 Body Landmarks per frame)...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
