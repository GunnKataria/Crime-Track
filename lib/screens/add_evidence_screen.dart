import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/evidence.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class AddEvidenceScreen extends ConsumerStatefulWidget {
  final String crimeId;

  const AddEvidenceScreen({
    Key? key,
    required this.crimeId,
  }) : super(key: key);

  @override
  ConsumerState<AddEvidenceScreen> createState() => _AddEvidenceScreenState();
}

class _AddEvidenceScreenState extends ConsumerState<AddEvidenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _storageLocationController = TextEditingController();
  
  String _selectedType = 'photo';
  String _selectedStatus = 'collected';
  DateTime _collectedDate = DateTime.now();
  bool _isSubmitting = false;
  
  final List<String> _evidenceTypes = [
    'photo',
    'video',
    'document',
    'physical',
    'audio',
  ];
  
  final List<String> _evidenceStatuses = [
    'collected',
    'analyzed',
    'stored',
  ];
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _storageLocationController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _collectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _collectedDate) {
      setState(() {
        _collectedDate = picked;
      });
    }
  }
  
  Future<void> _submitEvidence() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final user = ref.read(authProvider);
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to add evidence')),
        );
        return;
      }
      
      final evidence = Evidence(
        id: const Uuid().v4(),
        crimeId: widget.crimeId,
        description: _descriptionController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        collectedAt: _collectedDate,
        collectedBy: user.name,
        storageLocation: _storageLocationController.text.trim(),
        imagePath: null, // Would be set from image picker in a real app
      );
      
      await ref.read(evidenceProvider.notifier).addEvidence(evidence);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evidence added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding evidence: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Evidence'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Evidence Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Detailed description of the evidence',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedType,
                      items: _evidenceTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.substring(0, 1).toUpperCase() + type.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedStatus,
                      items: _evidenceStatuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.substring(0, 1).toUpperCase() + status.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Collection Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_collectedDate.day}/${_collectedDate.month}/${_collectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _storageLocationController,
                decoration: const InputDecoration(
                  labelText: 'Storage Location',
                  hintText: 'Where the evidence is stored',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a storage location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEvidence,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Add Evidence',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
