// lib/widgets/language_toggle.dart
// Language toggle button for switching between English (en) and Hindi (hi).

import 'package:flutter/material.dart';

class LanguageToggle extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onLanguageChanged;

  const LanguageToggle({
    super.key,
    required this.currentLang,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChoiceChip(
            label: const Text(
              'English',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            selected: currentLang == 'en',
            selectedColor: Colors.teal,
            labelStyle: TextStyle(
              color: currentLang == 'en' ? Colors.white : Colors.teal.shade900,
            ),
            onSelected: (selected) {
              if (selected) onLanguageChanged('en');
            },
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          ChoiceChip(
            label: const Text(
              'हिन्दी',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            selected: currentLang == 'hi',
            selectedColor: Colors.teal,
            labelStyle: TextStyle(
              color: currentLang == 'hi' ? Colors.white : Colors.teal.shade900,
            ),
            onSelected: (selected) {
              if (selected) onLanguageChanged('hi');
            },
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
