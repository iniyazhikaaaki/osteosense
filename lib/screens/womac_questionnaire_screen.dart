// lib/screens/womac_questionnaire_screen.dart
// WOMAC-lite symptom questionnaire screen with comorbidity screening for Differential Diagnosis.

import 'package:flutter/material.dart';
import '../services/scoring_service.dart';
import '../translations.dart';
import '../widgets/language_toggle.dart';
import 'video_selection_screen.dart';

class WomacQuestionnaireScreen extends StatefulWidget {
  final String lang;
  final ValueChanged<String> onLanguageChanged;
  final String patientId;
  final String name;
  final int age;
  final String sex;
  final String occupation;
  final String visitDate;

  const WomacQuestionnaireScreen({
    super.key,
    required this.lang,
    required this.onLanguageChanged,
    required this.patientId,
    required this.name,
    required this.age,
    required this.sex,
    required this.occupation,
    required this.visitDate,
  });

  @override
  State<WomacQuestionnaireScreen> createState() => _WomacQuestionnaireScreenState();
}

class _WomacQuestionnaireScreenState extends State<WomacQuestionnaireScreen> {
  int _painWalking = 0;
  int _painStairs = 0;
  int _stiffness = 0;
  int _rising = 0;
  int _squatting = 0;

  // Comorbidity screening switches
  bool _longMorningStiffness = false;
  bool _bilateralHands = false;
  bool _suddenSwelling = false;
  bool _radiatingNumbness = false;
  bool _lockingSensation = false;

  int get _womacTotal => _painWalking + _painStairs + _stiffness + _rising + _squatting;

  void _proceedToVideoSelection() {
    final comorbidities = ComorbidityInputs(
      longMorningStiffness: _longMorningStiffness,
      bilateralHands: _bilateralHands,
      suddenSwelling: _suddenSwelling,
      radiatingNumbness: _radiatingNumbness,
      lockingSensation: _lockingSensation,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoSelectionScreen(
          lang: widget.lang,
          onLanguageChanged: widget.onLanguageChanged,
          patientId: widget.patientId,
          name: widget.name,
          age: widget.age,
          sex: widget.sex,
          occupation: widget.occupation,
          visitDate: widget.visitDate,
          womacPainWalking: _painWalking,
          womacPainStairs: _painStairs,
          womacStiffness: _stiffness,
          womacRising: _rising,
          womacSquatting: _squatting,
          womacTotal: _womacTotal,
          comorbidities: comorbidities,
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String titleKey,
    required int currentValue,
    required ValueChanged<int> onChanged,
  }) {
    final lang = widget.lang;
    final severityOptions = [
      {'val': 0, 'key': 'severity_none'},
      {'val': 1, 'key': 'severity_mild'},
      {'val': 2, 'key': 'severity_moderate'},
      {'val': 3, 'key': 'severity_severe'},
      {'val': 4, 'key': 'severity_extreme'},
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(titleKey, lang),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: severityOptions.map((opt) {
                  final val = opt['val'] as int;
                  final isSelected = currentValue == val;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text('${opt['val']} - ${t(opt['key'] as String, lang)}'),
                      selected: isSelected,
                      selectedColor: Colors.teal.shade600,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        if (selected) onChanged(val);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('womac_score', lang),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F172A),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: LanguageToggle(
              currentLang: widget.lang,
              onLanguageChanged: widget.onLanguageChanged,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // WOMAC Score Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('womac_score', lang),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_womacTotal / 20',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildQuestionCard(
              titleKey: 'pain_walking',
              currentValue: _painWalking,
              onChanged: (val) => setState(() => _painWalking = val),
            ),
            _buildQuestionCard(
              titleKey: 'pain_stairs',
              currentValue: _painStairs,
              onChanged: (val) => setState(() => _painStairs = val),
            ),
            _buildQuestionCard(
              titleKey: 'stiffness',
              currentValue: _stiffness,
              onChanged: (val) => setState(() => _stiffness = val),
            ),
            _buildQuestionCard(
              titleKey: 'rising',
              currentValue: _rising,
              onChanged: (val) => setState(() => _rising = val),
            ),
            _buildQuestionCard(
              titleKey: 'squatting',
              currentValue: _squatting,
              onChanged: (val) => setState(() => _squatting = val),
            ),
            const SizedBox(height: 12),

            // Comorbidity & Differential Diagnosis Triage Panel
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.biotech_outlined, color: Colors.teal),
                        const SizedBox(width: 8),
                        Text(
                          t('diff_screening_title', lang),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(t('morning_stiffness_long', lang), style: const TextStyle(fontSize: 13)),
                      value: _longMorningStiffness,
                      activeThumbColor: Colors.teal,
                      onChanged: (val) => setState(() => _longMorningStiffness = val),
                    ),
                    SwitchListTile(
                      title: Text(t('bilateral_hands', lang), style: const TextStyle(fontSize: 13)),
                      value: _bilateralHands,
                      activeThumbColor: Colors.teal,
                      onChanged: (val) => setState(() => _bilateralHands = val),
                    ),
                    SwitchListTile(
                      title: Text(t('sudden_swelling', lang), style: const TextStyle(fontSize: 13)),
                      value: _suddenSwelling,
                      activeThumbColor: Colors.teal,
                      onChanged: (val) => setState(() => _suddenSwelling = val),
                    ),
                    SwitchListTile(
                      title: Text(t('radiating_numbness', lang), style: const TextStyle(fontSize: 13)),
                      value: _radiatingNumbness,
                      activeThumbColor: Colors.teal,
                      onChanged: (val) => setState(() => _radiatingNumbness = val),
                    ),
                    SwitchListTile(
                      title: Text(t('locking_sensation', lang), style: const TextStyle(fontSize: 13)),
                      value: _lockingSensation,
                      activeThumbColor: Colors.teal,
                      onChanged: (val) => setState(() => _lockingSensation = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(t('back', lang)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _proceedToVideoSelection,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      t('next', lang),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
