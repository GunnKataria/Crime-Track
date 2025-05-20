import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/suspect.dart';
import 'package:crime_management_system/providers/suspect_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:crime_management_system/screens/edit_suspect_screen.dart';

class SuspectDetailScreen extends ConsumerWidget {
  final String suspectId;

  const SuspectDetailScreen({
    Key? key,
    required this.suspectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suspect = ref.watch(suspectProvider.notifier).getSuspectById(suspectId);
    final isOfficer = ref.read(authProvider.notifier).isOfficer;
    
    if (suspect == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Suspect Details'),
        ),
        body: const Center(
          child: Text('Suspect not found'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suspect Details'),
        actions: [
          if (isOfficer)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSuspectScreen(suspectId: suspect.id),
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
            // Suspect header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: suspect.imagePath != null
                              ? AssetImage(suspect.imagePath!)
                              : null,
                          child: suspect.imagePath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suspect.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(suspect.status),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  suspect.status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  suspect.description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Criminal history
            const Text(
              'Criminal History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  suspect.criminalHistory ?? 'No criminal history recorded',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Related cases
            const Text(
              'Related Cases',
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
                    Text(
                      'This suspect is related to ${suspect.relatedCrimeIds.length} case(s)',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: suspect.relatedCrimeIds.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.folder),
                          title: Text('Case ID: ${suspect.relatedCrimeIds[index]}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to case detail screen
                          },
                        );
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
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'wanted':
        return Colors.red;
      case 'in custody':
        return Colors.blue;
      case 'cleared':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
