import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/evidence.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:intl/intl.dart';

class EditEvidenceScreen extends ConsumerStatefulWidget {
  final String evidenceId;

  const EditEvidenceScreen({
    Key? key,
    required this.evidenceId,
  }) : super(key: key);

  @override
  ConsumerState<EditEvidenceScreen> createState() => _EditEvidenceScreenState();
}

class _EditEvidenceScreenState extends ConsumerState<EditEvidenceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _storageLocationController;
  
  late String _selectedType;
  late String _selectedStatus;
  late DateTime _collectedDate;
  
  bool _isLoading = true;
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
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _storageLocationController = TextEditingController();
    
    // Default values that will be overridden when data loads
    _selectedType = 'photo';
    _selectedStatus = 'collected';
    _collectedDate = DateTime.now();
    
    // Load evidence data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvidenceData();
    });
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _storageLocationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadEvidenceData() async {
    setState(() {
      _isLoading = true;
    });
    
    final evidence = ref.read(evidenceProvider.notifier).getEvidenceById(widget.evidenceId);
    
    if (evidence != null) {
      _descriptionController.text = evidence.description;
      _storageLocationController.text = evidence.storageLocation;
      _selectedType = evidence.type;
      _selectedStatus = evidence.status;
      _collectedDate = evidence.collectedAt;
    }
    
    setState(() {
      _isLoading = false;
    });
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
  
  Future<void> _updateEvidence() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final evidence = ref.read(evidenceProvider.notifier).getEvidenceById(widget.evidenceId);
      
      if (evidence == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evidence not found')),
        );
        return;
      }
      
      final updatedEvidence = evidence.copyWith(
        description: _descriptionController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        collectedAt: _collectedDate,
        storageLocation: _storageLocationController.text.trim(),
      );
      
      await ref.read(evidenceProvider.notifier).updateEvidence(updatedEvidence);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evidence updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating evidence: $e')),
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
        title: const Text('Edit Evidence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          DateFormat('MM/dd/yyyy').format(_collectedDate),
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
                        onPressed: _isSubmitting ? null : _updateEvidence,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Update Evidence',
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
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Evidence'),
        content: const Text('Are you sure you want to delete this evidence? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(evidenceProvider.notifier).deleteEvidence(widget.evidenceId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evidence deleted successfully')),
                );
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
