import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/crime_provider.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:crime_management_system/providers/witness_provider.dart';
import 'package:crime_management_system/providers/suspect_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:crime_management_system/widgets/evidence_card.dart';
import 'package:crime_management_system/widgets/witness_card.dart';
import 'package:crime_management_system/widgets/suspect_card.dart';
import 'package:crime_management_system/screens/add_evidence_screen.dart';
import 'package:crime_management_system/screens/add_witness_screen.dart';
import 'package:crime_management_system/screens/add_suspect_screen.dart';
import 'package:crime_management_system/screens/assign_case_screen.dart';
import 'package:crime_management_system/screens/edit_crime_screen.dart';
import 'package:crime_management_system/screens/evidence_detail_screen.dart';
import 'package:crime_management_system/screens/witness_detail_screen.dart';
import 'package:crime_management_system/screens/suspect_detail_screen.dart';
import 'package:crime_management_system/screens/case_verification_screen.dart';
import 'package:intl/intl.dart';

class CrimeDetailScreen extends ConsumerWidget {
  final String crimeId;

  const CrimeDetailScreen({
    Key? key,
    required this.crimeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final crime = ref.watch(crimeProvider.notifier).getCrimeById(crimeId);
  final evidences = ref.watch(evidenceProvider.notifier).getEvidencesByCrimeId(crimeId);
  final witnesses = ref.watch(witnessProvider.notifier).getWitnessesByCrimeId(crimeId);
  final suspects = ref.watch(suspectProvider.notifier).getSuspectsByCrimeId(crimeId);
  final isOfficer = ref.read(authProvider.notifier).isOfficer;
  final currentUser = ref.read(authProvider);
  
  if (crime == null) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crime Details'),
      ),
      body: const Center(
        child: Text('Crime not found'),
      ),
    );
  }
  
  final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');
  final isAssignedToMe = currentUser != null && crime.assignedOfficer == currentUser.id;
  final isPendingVerification = crime.status == 'pending_verification';
  final isInsufficientEvidence = crime.status == 'insufficient_evidence';
  
  return Scaffold(
    appBar: AppBar(
      title: const Text('Crime Details'),
      actions: [
        if (isOfficer) ...[
          if (isPendingVerification)
            IconButton(
              icon: const Icon(Icons.verified_user),
              tooltip: 'Verify Case',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaseVerificationScreen(crimeId: crime.id),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCrimeScreen(crimeId: crime.id),
                ),
              );
            },
          ),
        ],
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crime header
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
                          color: _getStatusColor(crime.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(crime.status),
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
                          crime.type,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    crime.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          crime.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(crime.dateTime),
                        style: TextStyle(
                          color: Colors.grey[600],
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
                    crime.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  
                  // Show verification status banner
                  if (isPendingVerification) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pending_actions,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Pending Verification',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This case is awaiting verification by an officer. Once verified, investigation will begin.',
                            style: TextStyle(
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Show insufficient evidence banner
                  if (isInsufficientEvidence) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Insufficient Evidence',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The evidence provided is not sufficient to proceed with an investigation. Please visit your nearest police station for follow-up.',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          if (crime.verificationNotes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Officer Notes: ${crime.verificationNotes}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Case details (only for officers)
          if (isOfficer && !isPendingVerification) ...[
            const Text(
              'Case Details',
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
                                'Case ID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(crime.id),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reported On',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(DateFormat('MMM d, yyyy').format(crime.createdAt)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assigned Officer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(crime.assignedOfficer.isEmpty ? 'Not assigned' : 
                                   isAssignedToMe ? 'Assigned to you' : crime.assignedOfficer),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reported By',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(crime.isAnonymous ? 'Anonymous' : crime.reportedBy),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (crime.verificationNotes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Verification Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(crime.verificationNotes),
                    ],
                    const SizedBox(height: 16),
                    // Fixed the overflow issue by changing Row to Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            // Adding isCollapsed: true can help with internal Row issues
                            isCollapsed: false,
                            // Adding contentPadding can reduce internal padding
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          ),
                          value: crime.status,
                          items: const [
                            DropdownMenuItem(
                              value: 'open',
                              child: Text('Open'),
                            ),
                            DropdownMenuItem(
                              value: 'investigating',
                              child: Text('Investigating'),
                            ),
                            DropdownMenuItem(
                              value: 'closed',
                              child: Text('Closed'),
                            ),
                            DropdownMenuItem(
                              value: 'insufficient_evidence',
                              child: Text('Insufficient Evidence'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              final updatedCrime = crime.copyWith(status: value);
                              ref.read(crimeProvider.notifier).updateCrime(updatedCrime);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_ind),
                          label: Text(isAssignedToMe ? 'Assigned to Me' : 'Assign to Me'),
                          onPressed: isAssignedToMe ? null : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssignCaseScreen(crimeId: crime.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Evidence section
          if (isOfficer || evidences.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Evidence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isOfficer && !isPendingVerification)
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Evidence'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEvidenceScreen(crimeId: crime.id),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (evidences.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No evidence recorded yet'),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: evidences.length,
                itemBuilder: (context, index) {
                  return EvidenceCard(
                    evidence: evidences[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EvidenceDetailScreen(evidenceId: evidences[index].id),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
          
          const SizedBox(height: 24),
          
          // Witnesses section
          if ((isOfficer && !isPendingVerification) || witnesses.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Witnesses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isOfficer && !isPendingVerification)
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Witness'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWitnessScreen(crimeId: crime.id),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (witnesses.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No witnesses recorded yet'),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: witnesses.length,
                itemBuilder: (context, index) {
                  return WitnessCard(
                    witness: witnesses[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WitnessDetailScreen(witnessId: witnesses[index].id),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
          
          const SizedBox(height: 24),
          
          // Suspects section
          if ((isOfficer && !isPendingVerification) || suspects.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suspects',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isOfficer && !isPendingVerification)
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Suspect'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddSuspectScreen(crimeId: crime.id),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (suspects.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No suspects identified yet'),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suspects.length,
                itemBuilder: (context, index) {
                  return SuspectCard(
                    suspect: suspects[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuspectDetailScreen(suspectId: suspects[index].id),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'pending_verification':
      return Colors.purple;
    case 'open':
      return Colors.red;
    case 'investigating':
      return Colors.orange;
    case 'closed':
      return Colors.green;
    case 'insufficient_evidence':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

// Add this helper method which is referenced in the code but wasn't included
String _getStatusText(String status) {
  switch (status) {
    case 'pending_verification':
      return 'Pending Verification';
    case 'open':
      return 'Open';
    case 'investigating':
      return 'Investigating';
    case 'closed':
      return 'Closed';
    case 'insufficient_evidence':
      return 'Insufficient Evidence';
    default:
      return 'Unknown';
  }
}
  
  

}
