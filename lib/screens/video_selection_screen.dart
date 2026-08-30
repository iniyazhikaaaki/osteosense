// lib/screens/video_selection_screen.dart
// Video & Sensor selection screen supporting built-in camera recording (Walk + Sit-to-Stand) and BLE Knee Sensor Telemetry.

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
  XFile? _walkVideo;
  XFile? _stsVideo;
  bool _useImpairedPreset = false;
  bool _isSensorConnected = false;
  int _selectedInputTab = 0; // 0 = Camera Pose Analysis, 1 = BLE Knee Sensor

  Future<void> _pickVideo(ImageSource source, bool isWalkVideo) async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 30),
    );

    if (video != null) {
      setState(() {
        if (isWalkVideo) {
          _walkVideo = video;
        } else {
          _stsVideo = video;
        }
      });
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
          walkVideoPath: _walkVideo?.path,
          stsVideoPath: _stsVideo?.path,
          useImpairedPreset: _useImpairedPreset,
          isSensorInput: _selectedInputTab == 1,
        ),
      ),
    );
  }

  Widget _buildVideoInputCard({
    required String titleKey,
    required IconData icon,
    required XFile? selectedFile,
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
  }) {
    final lang = widget.lang;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t(titleKey, lang),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCameraTap,
                    icon: const Icon(Icons.videocam_outlined),
                    label: Text(t('record_camera', lang)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGalleryTap,
                    icon: const Icon(Icons.folder_open),
                    label: Text(t('pick_gallery', lang)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedFile != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.teal, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${t("video_selected", lang)} ${selectedFile.name}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            // Segmented input selector tab
            Container(
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedInputTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedInputTab == 0 ? Colors.teal.shade700 : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            t('camera_tab', lang),
                            style: TextStyle(
                              color: _selectedInputTab == 0 ? Colors.white : Colors.teal.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedInputTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedInputTab == 1 ? Colors.teal.shade700 : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            t('sensor_tab', lang),
                            style: TextStyle(
                              color: _selectedInputTab == 1 ? Colors.white : Colors.teal.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedInputTab == 0) ...[
              Text(
                t('gait_instructions', lang),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
              ),
              const SizedBox(height: 12),
              _buildVideoInputCard(
                titleKey: 'walk_video_title',
                icon: Icons.directions_walk,
                selectedFile: _walkVideo,
                onCameraTap: () => _pickVideo(ImageSource.camera, true),
                onGalleryTap: () => _pickVideo(ImageSource.gallery, true),
              ),
              _buildVideoInputCard(
                titleKey: 'sts_video_title',
                icon: Icons.airline_seat_recline_extra,
                selectedFile: _stsVideo,
                onCameraTap: () => _pickVideo(ImageSource.camera, false),
                onGalleryTap: () => _pickVideo(ImageSource.gallery, false),
              ),
            ] else ...[
              // BLE Knee Sensor Telemetry Connector Panel
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        _isSensorConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                        size: 48,
                        color: _isSensorConnected ? Colors.teal : Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t('sensor_input_title', lang),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSensorConnected
                            ? t('sensor_connected', lang)
                            : 'Connect ESP32 + MPU6050 BLE Knee Band for live 100Hz IMU joint telemetry',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _isSensorConnected = !_isSensorConnected);
                        },
                        icon: Icon(_isSensorConnected ? Icons.check_circle : Icons.bluetooth),
                        label: Text(
                          _isSensorConnected
                              ? 'Sensor Stream Active'
                              : t('sensor_connect_btn', lang),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSensorConnected ? Colors.teal.shade700 : Colors.teal.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            // Simulation Preset Switcher
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                title: const Text(
                  'Simulate Impaired Gait & Sit-to-Stand Test',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: const Text(
                  'Generates reduced ROM & prolonged transition time signal',
                  style: TextStyle(fontSize: 11),
                ),
                value: _useImpairedPreset,
                activeThumbColor: Colors.teal,
                onChanged: (val) => setState(() => _useImpairedPreset = val),
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
