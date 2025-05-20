import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/crime_provider.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:crime_management_system/widgets/evidence_card.dart';
import 'package:crime_management_system/screens/evidence_detail_screen.dart';
import 'package:intl/intl.dart';

class CaseVerificationScreen extends ConsumerStatefulWidget {
  final String crimeId;

  const CaseVerificationScreen({
    Key? key,
    required this.crimeId,
  }) : super(key: key);

  @override
  ConsumerState<CaseVerificationScreen> createState() => _CaseVerificationScreenState();
}

class _CaseVerificationScreenState extends ConsumerState<CaseVerificationScreen> {
  final _notesController = TextEditingController();
  bool _isVerifying = false;
  String _verificationDecision = 'approve'; // 'approve' or 'reject'
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _submitVerification() async {
    setState(() {
      _isVerifying = true;
    });
    
    try {
      final crime = ref.read(crimeProvider.notifier).getCrimeById(widget.crimeId);
      
      if (crime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case not found')),
        );
        return;
      }
      
      final user = ref.read(authProvider);
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to verify cases')),
        );
        return;
      }
      
      // Update the crime based on verification decision
      final updatedCrime = crime.copyWith(
        status: _verificationDecision == 'approve' ? 'open' : 'insufficient_evidence',
        verificationNotes: _notesController.text.trim(),
        isVerified: true,
        assignedOfficer: _verificationDecision == 'approve' ? user.id : '',
      );
      
      await ref.read(crimeProvider.notifier).updateCrime(updatedCrime);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _verificationDecision == 'approve'
                  ? 'Case approved and opened for investigation'
                  : 'Case rejected due to insufficient evidence'
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying case: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final crime = ref.watch(crimeProvider.notifier).getCrimeById(widget.crimeId);
    final evidences = crime != null 
        ? ref.watch(evidenceProvider.notifier).getEvidencesByCrimeId(crime.id) 
        : [];
    
    if (crime == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Case Verification'),
        ),
        body: const Center(
          child: Text('Case not found'),
        ),
      );
    }
    
    final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case Information
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
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PENDING VERIFICATION',
                            style: TextStyle(
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
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Evidence Section
            const Text(
              'Evidence to Verify',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (evidences.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('No evidence submitted with this case'),
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
            
            const SizedBox(height: 24),
            
            // Verification Form
            const Text(
              'Verification Decision',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Is the evidence sufficient to open an investigation?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RadioListTile<String>(
                      title: const Text('Yes, approve and open case'),
                      subtitle: const Text('The evidence is sufficient to proceed with an investigation'),
                      value: 'approve',
                      groupValue: _verificationDecision,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _verificationDecision = value;
                          });
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('No, reject due to insufficient evidence'),
                      subtitle: const Text('The citizen will be notified to visit or contact the nearest police station'),
                      value: 'reject',
                      groupValue: _verificationDecision,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _verificationDecision = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Verification Notes',
                        hintText: 'Add notes about your verification decision',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _submitVerification,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _verificationDecision == 'approve' ? Colors.green : Colors.red,
                        ),
                        child: _isVerifying
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _verificationDecision == 'approve'
                                    ? 'Approve Case'
                                    : 'Reject Case',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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
}
