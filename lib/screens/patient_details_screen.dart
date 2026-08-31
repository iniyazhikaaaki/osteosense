// lib/screens/patient_details_screen.dart
// Home Screen: Patient details registration, language toggle, 100% Offline badge, and SQLite past records lookup.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../translations.dart';
import '../widgets/language_toggle.dart';
import '../widgets/past_records_list.dart';
import 'womac_questionnaire_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String currentLang;
  final ValueChanged<String> onLanguageChanged;

  const PatientDetailsScreen({
    super.key,
    required this.currentLang,
    required this.onLanguageChanged,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _visitDateController = TextEditingController();
  String _selectedSex = 'Male';

  @override
  void initState() {
    super.initState();
    _visitDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _visitDateController.dispose();
    super.dispose();
  }

  void _proceedToQuestionnaire() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WomacQuestionnaireScreen(
            lang: widget.currentLang,
            onLanguageChanged: widget.onLanguageChanged,
            patientId: _patientIdController.text.trim(),
            name: _nameController.text.trim(),
            age: int.tryParse(_ageController.text.trim()) ?? 0,
            sex: _selectedSex,
            occupation: _occupationController.text.trim(),
            visitDate: _visitDateController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.currentLang;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.health_and_safety, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              t('app_title', lang),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '100% Offline Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryNavy,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: LanguageToggle(
              currentLang: widget.currentLang,
              onLanguageChanged: widget.onLanguageChanged,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Patient Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Local Storage Only',
                              style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _patientIdController,
                        decoration: InputDecoration(
                          labelText: '${t("patient_id", lang)} *',
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return t('enter_patient_id', lang);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '${t("name", lang)} *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return t('enter_name', lang);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '${t("age", lang)} *',
                                prefixIcon: const Icon(Icons.cake),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return t('enter_age', lang);
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSex,
                              decoration: InputDecoration(
                                labelText: t('sex', lang),
                                prefixIcon: const Icon(Icons.wc),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              items: [
                                DropdownMenuItem(value: 'Male', child: Text(t('male', lang))),
                                DropdownMenuItem(value: 'Female', child: Text(t('female', lang))),
                                DropdownMenuItem(value: 'Other', child: Text(t('other', lang))),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSex = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _occupationController,
                        decoration: InputDecoration(
                          labelText: t('occupation', lang),
                          prefixIcon: const Icon(Icons.work),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _visitDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: t('visit_date', lang),
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PastRecordsList(
                patientId: _patientIdController.text,
                lang: lang,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _proceedToQuestionnaire,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  t('next', lang),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
