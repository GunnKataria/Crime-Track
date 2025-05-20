import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/evidence.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
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
    
    final dateFormat = DateFormat('MMMM d, yyyy');
    
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
            // Evidence header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (evidence.imagePath != null) ...[
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            evidence.imagePath!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getEvidenceTypeIcon(evidence.type),
                            size: 64,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            evidence.type.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
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
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Collection details
            const Text(
              'Collection Details',
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Collected By',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(evidence.collectedBy),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Collection Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(dateFormat.format(evidence.collectedAt)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Storage Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(evidence.storageLocation),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Case information
            const Text(
              'Case Information',
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
                    const Text(
                      'Related Case',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text('Case ID: ${evidence.crimeId}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to case detail screen
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getEvidenceTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'photo':
        return Icons.photo;
      case 'video':
        return Icons.videocam;
      case 'document':
        return Icons.description;
      case 'physical':
        return Icons.inventory;
      case 'audio':
        return Icons.mic;
      default:
        return Icons.folder;
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'collected':
        return Colors.blue;
      case 'analyzed':
        return Colors.orange;
      case 'stored':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
