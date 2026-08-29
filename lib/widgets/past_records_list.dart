// lib/widgets/past_records_list.dart
// Collapsible past records section querying SQLite database by Patient ID.

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

  @override
  void didUpdateWidget(covariant PastRecordsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId && widget.patientId.isNotEmpty) {
      _loadRecords();
    }
  }

  Future<void> _loadRecords() async {
    if (widget.patientId.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final list = await DatabaseHelper.instance.getRecordsByPatientId(widget.patientId.trim());
      setState(() => _records = list);
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
          if (expanded) _loadRecords();
        },
        leading: const Icon(Icons.history, color: Colors.teal),
        title: Text(
          t('past_records', widget.lang),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else if (widget.patientId.trim().isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                t('enter_patient_id', widget.lang),
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else if (_records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                t('no_records', widget.lang),
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
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${t("visit_date", widget.lang)}: ${rec.visitDate}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: riskColor),
                        ),
                        child: Text(
                          rec.riskBand,
                          style: TextStyle(
                            color: riskColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${t("womac_score", widget.lang)}: ${rec.womacTotal}/20  |  ${t("total_score", widget.lang)}: ${rec.riskScore}/12\nROM Left: ${rec.romLeft}° | ROM Right: ${rec.romRight}°',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
