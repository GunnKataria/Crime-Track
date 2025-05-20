import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/witness_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:crime_management_system/screens/edit_witness_screen.dart';

class WitnessDetailScreen extends ConsumerWidget {
  final String witnessId;

  const WitnessDetailScreen({
    Key? key,
    required this.witnessId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final witness = ref.watch(witnessProvider.notifier).getWitnessById(witnessId);
    final isOfficer = ref.read(authProvider.notifier).isOfficer;
    
    if (witness == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Witness Details'),
        ),
        body: const Center(
          child: Text('Witness not found'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Witness Details'),
        actions: [
          if (isOfficer)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditWitnessScreen(witnessId: witness.id),
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
            // Witness header
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
                          backgroundImage: witness.imagePath != null
                              ? AssetImage(witness.imagePath!)
                              : null,
                          child: witness.imagePath == null
                              ? Icon(
                                  witness.isAnonymous ? Icons.person_off : Icons.person,
                                  size: 40,
                                  color: Colors.grey[600],
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                witness.isAnonymous ? 'Anonymous Witness' : witness.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCredibilityColor(witness.credibilityRating),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${witness.credibilityRating.toUpperCase()} CREDIBILITY',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (witness.isAnonymous) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'ANONYMOUS',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
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
            
            // Contact information (if not anonymous)
            if (!witness.isAnonymous) ...[
              const Text(
                'Contact Information',
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
                          Icon(
                            Icons.contact_phone,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              witness.contactInfo,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Witness statement
            const Text(
              'Witness Statement',
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
                  witness.statement,
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
                      'This witness is related to ${witness.relatedCrimeIds.length} case(s)',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: witness.relatedCrimeIds.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.folder),
                          title: Text('Case ID: ${witness.relatedCrimeIds[index]}'),
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
  
  Color _getCredibilityColor(String credibility) {
    switch (credibility.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
