import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:crime_management_system/widgets/file_preview_widget.dart';
import 'package:crime_management_system/screens/edit_evidence_screen.dart';
import 'package:intl/intl.dart';

class EvidenceDetailScreen extends ConsumerWidget {
  final String evidenceId;

  const EvidenceDetailScreen({
    Key? key,
    required this.evidenceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidence = ref.watch(evidenceProvider.notifier).getEvidenceById(evidenceId);
    final isOfficer = ref.read(authProvider.notifier).isOfficer;
    
    if (evidence == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Evidence Details'),
        ),
        body: const Center(
          child: Text('Evidence not found'),
        ),
      );
    }
    
    final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidence Details'),
        actions: [
          if (isOfficer)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEvidenceScreen(evidenceId: evidence.id),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Evidence file preview
            if (evidence.imagePath != null && evidence.imagePath!.isNotEmpty) ...[
              const Text(
                'Evidence File',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              FilePreviewWidget(
                filePath: evidence.imagePath,
                fileType: evidence.fileType,
                fileName: evidence.fileName,
                height: 300,
              ),
              const SizedBox(height: 24),
            ],
            
            // Evidence details
            const Text(
              'Evidence Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTypeColor(evidence.type),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            evidence.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(evidence.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            evidence.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      evidence.description,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Collection Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Collected By', evidence.collectedBy),
                    _buildDetailRow('Collected On', dateFormat.format(evidence.collectedAt)),
                    _buildDetailRow('Storage Location', evidence.storageLocation),
                    if (evidence.fileName != null)
                      _buildDetailRow('File Name', evidence.fileName!),
                    _buildDetailRow('Evidence ID', evidence.id),
                    _buildDetailRow('Related Case ID', evidence.crimeId),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Actions for officers
            if (isOfficer) ...[
              const Text(
                'Evidence Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Update Status',
                          border: OutlineInputBorder(),
                        ),
                        value: evidence.status,
                        items: const [
                          DropdownMenuItem(
                            value: 'collected',
                            child: Text('Collected'),
                          ),
                          DropdownMenuItem(
                            value: 'processing',
                            child: Text('Processing'),
                          ),
                          DropdownMenuItem(
                            value: 'analyzed',
                            child: Text('Analyzed'),
                          ),
                          DropdownMenuItem(
                            value: 'archived',
                            child: Text('Archived'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            final updatedEvidence = evidence.copyWith(status: value);
                            ref.read(evidenceProvider.notifier).updateEvidence(updatedEvidence);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Evidence'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditEvidenceScreen(evidenceId: evidence.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'photo':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'document':
        return Colors.orange;
      case 'physical':
        return Colors.green;
      case 'audio':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'collected':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'analyzed':
        return Colors.blue;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
