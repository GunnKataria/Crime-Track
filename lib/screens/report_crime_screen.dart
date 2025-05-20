import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/crime.dart';
import 'package:crime_management_system/models/evidence.dart';
import 'package:crime_management_system/providers/crime_provider.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class ReportCrimeScreen extends ConsumerStatefulWidget {
  const ReportCrimeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportCrimeScreen> createState() => _ReportCrimeScreenState();
}

class _ReportCrimeScreenState extends ConsumerState<ReportCrimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _evidenceDescriptionController = TextEditingController();
  
  String _selectedCrimeType = 'theft';
  bool _isAnonymous = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedEvidenceType = 'photo';
  
  bool _isSubmitting = false;
  bool _hasEvidence = false;
  
  final List<String> _crimeTypes = [
    'theft',
    'assault',
    'vandalism',
    'burglary',
    'fraud',
    'homicide',
    'other',
  ];
  
  final List<String> _evidenceTypes = [
    'photo',
    'video',
    'document',
    'physical',
    'audio',
  ];
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _evidenceDescriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_hasEvidence) {
      _showNoEvidenceDialog();
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final user = ref.read(authProvider);
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to report a crime')),
        );
        return;
      }
      
      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final crimeId = const Uuid().v4();
      
      // Create the crime with pending verification status
      final crime = Crime(
        id: crimeId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        dateTime: dateTime,
        type: _selectedCrimeType,
        status: 'pending_verification', // New status for verification
        reportedBy: user.id,
        evidenceIds: [],
        witnessIds: [],
        suspectIds: [],
        latitude: 0.0, // Would be set from map in a real app
        longitude: 0.0, // Would be set from map in a real app
        isAnonymous: _isAnonymous,
        createdAt: DateTime.now(),
        assignedOfficer: '',
        isVerified: false,
      );
      
      // Create the evidence
      if (_hasEvidence && _evidenceDescriptionController.text.isNotEmpty) {
        final evidenceId = const Uuid().v4();
        final evidence = Evidence(
          id: evidenceId,
          crimeId: crimeId,
          description: _evidenceDescriptionController.text.trim(),
          type: _selectedEvidenceType,
          status: 'collected',
          collectedAt: DateTime.now(),
          collectedBy: user.name,
          storageLocation: 'Citizen Submission',
          imagePath: null, // Would be set from image picker in a real app
        );
        
        // Add evidence
        await ref.read(evidenceProvider.notifier).addEvidence(evidence);
        
        // Update crime with evidence ID
        final updatedCrime = crime.copyWith(
          evidenceIds: [evidenceId],
        );
        
        await ref.read(crimeProvider.notifier).addCrime(updatedCrime);
      } else {
        await ref.read(crimeProvider.notifier).addCrime(crime);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crime reported successfully. It will be verified by an officer.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reporting crime: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  void _showNoEvidenceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Evidence Required'),
        content: const Text(
          'You must provide evidence to report a crime. This helps officers verify your case. '
          'Without evidence, we recommend visiting or calling your nearest police station.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Crime'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crime Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief title of the incident',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Crime Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCrimeType,
                items: _crimeTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.substring(0, 1).toUpperCase() + type.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCrimeType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where did the incident occur?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Provide details about what happened',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Evidence Section
              const Text(
                'Evidence Information (Required)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Providing evidence helps officers verify your case. Without sufficient evidence, your case may require in-person follow-up.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('I have evidence to submit'),
                subtitle: const Text('Photos, videos, documents, or other evidence'),
                value: _hasEvidence,
                onChanged: (value) {
                  setState(() {
                    _hasEvidence = value;
                  });
                },
              ),
              if (_hasEvidence) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Evidence Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedEvidenceType,
                  items: _evidenceTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.substring(0, 1).toUpperCase() + type.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedEvidenceType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _evidenceDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Evidence Description',
                    hintText: 'Describe the evidence you are submitting',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_hasEvidence && (value == null || value.isEmpty)) {
                      return 'Please describe your evidence';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // In a real app, this would open an image picker or file picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File upload would be implemented in a real app')),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Evidence File'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Report Anonymously'),
                subtitle: const Text('Your identity will not be disclosed'),
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Submit Report',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: All reports are subject to verification by law enforcement officers. '
                'If your evidence is insufficient, you may be asked to visit your local police station.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
