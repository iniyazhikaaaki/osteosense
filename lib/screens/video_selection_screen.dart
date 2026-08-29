// lib/screens/video_selection_screen.dart
// Video selection screen using image_picker with visible "Connect knee sensor (coming soon)" stub button.

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../translations.dart';
import '../widgets/language_toggle.dart';
import 'processing_screen.dart';

class VideoSelectionScreen extends StatefulWidget {
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

  const VideoSelectionScreen({
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
  });

  @override
  State<VideoSelectionScreen> createState() => _VideoSelectionScreenState();
}

class _VideoSelectionScreenState extends State<VideoSelectionScreen> {
  XFile? _selectedVideo;
  bool _useImpairedPreset = false;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _selectedVideo = video);
    }
  }

  void _startAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessingScreen(
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
          videoPath: _selectedVideo?.path,
          useImpairedPreset: _useImpairedPreset,
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
          t('upload_video', lang),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal.shade700,
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
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.videocam_outlined, size: 56, color: Colors.teal),
                    const SizedBox(height: 12),
                    Text(
                      t('gait_instructions', lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.file_upload_outlined),
                      label: Text(t('upload_video', lang)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    if (_selectedVideo != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.teal),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${t("video_selected", lang)} ${_selectedVideo!.name}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Demo gait simulation preset selector (for quick testing/demo)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text(
                  'Simulate Impaired Gait Test Video',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Generates severe ROM reduction signal for demonstration',
                  style: TextStyle(fontSize: 12),
                ),
                value: _useImpairedPreset,
                activeColor: Colors.teal,
                onChanged: (val) => setState(() => _useImpairedPreset = val),
              ),
            ),
            const SizedBox(height: 16),

            // Stub Button for Knee Band BLE Sensor (per Section 2 & 3 of brief)
            Tooltip(
              message: 'Hardware BLE Sensor Integration Workstream',
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bluetooth_disabled, color: Colors.grey),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          t('connect_sensor', lang),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

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
                    onPressed: _startAnalysis,
                    icon: const Icon(Icons.analytics_outlined),
                    label: Text(
                      t('submit', lang),
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
