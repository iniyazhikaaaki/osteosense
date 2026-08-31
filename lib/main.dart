// lib/main.dart
// Main entry point for OsteoSense Flutter app with aesthetic medical design system.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/patient_details_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('osteosense_language') ?? 'en';
  runApp(OsteoSenseApp(initialLang: savedLang));
}

class OsteoSenseApp extends StatefulWidget {
  final String initialLang;
  const OsteoSenseApp({super.key, required this.initialLang});

  @override
  State<OsteoSenseApp> createState() => _OsteoSenseAppState();
}

class _OsteoSenseAppState extends State<OsteoSenseApp> {
  late String _currentLang;

  @override
  void initState() {
    super.initState();
    _currentLang = widget.initialLang;
  }

  Future<void> _updateLanguage(String langCode) async {
    setState(() => _currentLang = langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('osteosense_language', langCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OsteoSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: PatientDetailsScreen(
        currentLang: _currentLang,
        onLanguageChanged: _updateLanguage,
      ),
    );
  }
}
