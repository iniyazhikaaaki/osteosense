// lib/widgets/past_records_list.dart
// Interactive Patient History & Records Manager displaying past analysis records from local SQLite DB.

import 'package:flutter/material.dart';
import '../models/patient_record.dart';
import '../services/database_helper.dart';
import '../translations.dart';

class PastRecordsList extends StatefulWidget {
  final String patientId;
  final String lang;

  const PastRecordsList({
    super.key,
    required this.patientId,
    required this.lang,
  });

  @override
  State<PastRecordsList> createState() => _PastRecordsListState();
}

class _PastRecordsListState extends State<PastRecordsList> {
  List<PatientRecord> _records = [];
  bool _isLoading = false;
  bool _isExpanded = false;
  bool _showAllPatients = false;

  @override
  void didUpdateWidget(covariant PastRecordsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId && !_showAllPatients) {
      _loadRecords();
    }
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      if (_showAllPatients) {
        final list = await DatabaseHelper.instance.getAllRecords();
        setState(() => _records = list);
      } else if (widget.patientId.trim().isNotEmpty) {
        final list = await DatabaseHelper.instance.getRecordsByPatientId(widget.patientId.trim());
        setState(() => _records = list);
      } else {
        final list = await DatabaseHelper.instance.getAllRecords();
        setState(() => _records = list);
      }
    } catch (e) {
      debugPrint('Error loading patient records: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getRiskColor(String band) {
    switch (band) {
      case 'Extreme':
        return Colors.red.shade700;
      case 'High':
        return Colors.orange.shade800;
      case 'Moderate':
        return Colors.amber.shade800;
      case 'Low':
      default:
        return Colors.green.shade700;
    }
  }

  void _showRecordDetailsModal(PatientRecord rec) {
    final riskColor = _getRiskColor(rec.riskBand);
    final lang = widget.lang;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.history_edu, color: Colors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${rec.name} (${rec.patientId})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: riskColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t("risk_band", lang)}: ${rec.riskBand}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: riskColor, fontSize: 15),
                    ),
                    Text(
                      '${t("total_score", lang)}: ${rec.riskScore}/12',
                      style: TextStyle(fontWeight: FontWeight.bold, color: riskColor, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('• Visit Date: ${rec.visitDate}', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('• Demographics: ${rec.age} y/o ${rec.sex} | ${rec.occupation}'),
              Text('• Data Source: ${rec.inputSource}'),
              const Divider(height: 20),
              Text(t('score_breakdown', lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('WOMAC Pain Walking: ${rec.womacPainWalking}/4 | Stairs: ${rec.womacPainStairs}/4'),
              Text('WOMAC Stiffness: ${rec.womacStiffness}/4 | Rising: ${rec.womacRising}/4 | Squatting: ${rec.womacSquatting}/4'),
              Text('Total WOMAC-lite: ${rec.womacTotal}/20', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Divider(height: 20),
              Text(t('gait_markers', lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Flexion ROM Left: ${rec.romLeft.toStringAsFixed(1)}°'),
              Text('Flexion ROM Right: ${rec.romRight.toStringAsFixed(1)}°'),
              Text('ROM Asymmetry: ${rec.romAsymmetry.toStringAsFixed(3)}'),
              Text('Peak Flexion Right: ${rec.peakFlexionRight.toStringAsFixed(1)}°'),
              Text('Cadence: ${rec.cadence.toStringAsFixed(1)} steps/min'),
              Text('Sit-to-Stand Transition: ${rec.sitToStandTime.toStringAsFixed(1)} sec'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('back', lang)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
          if (expanded) _loadRecords();
        },
        leading: const Icon(Icons.history_toggle_off, color: Colors.teal),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t('past_records', widget.lang),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                setState(() => _showAllPatients = !_showAllPatients);
                _loadRecords();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade300),
                ),
                child: Text(
                  _showAllPatients ? 'All Patients' : 'Current Patient',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                ),
              ),
            ),
          ],
        ),
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else if (_records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.patientId.trim().isEmpty && !_showAllPatients
                    ? t('enter_patient_id', widget.lang)
                    : t('no_records', widget.lang),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _records.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final rec = _records[index];
                final riskColor = _getRiskColor(rec.riskBand);

                return ListTile(
                  onTap: () => _showRecordDetailsModal(rec),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${rec.name} (${rec.patientId}) - ${rec.visitDate}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: riskColor),
                        ),
                        child: Text(
                          rec.riskBand,
                          style: TextStyle(
                            color: riskColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'WOMAC: ${rec.womacTotal}/20  |  Score: ${rec.riskScore}/12  |  ROM: L ${rec.romLeft.toStringAsFixed(1)}° / R ${rec.romRight.toStringAsFixed(1)}°\n(Tap to view complete analysis modal)',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.teal),
                );
              },
            ),
        ],
      ),
    );
  }
}
