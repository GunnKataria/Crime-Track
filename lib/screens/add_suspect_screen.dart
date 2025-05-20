import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/suspect.dart';
import 'package:crime_management_system/providers/suspect_provider.dart';
import 'package:uuid/uuid.dart';

class AddSuspectScreen extends ConsumerStatefulWidget {
  final String crimeId;

  const AddSuspectScreen({
    Key? key,
    required this.crimeId,
  }) : super(key: key);

  @override
  ConsumerState<AddSuspectScreen> createState() => _AddSuspectScreenState();
}

class _AddSuspectScreenState extends ConsumerState<AddSuspectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _criminalHistoryController = TextEditingController();
  
  String _selectedStatus = 'wanted';
  bool _isSubmitting = false;
  
  final List<String> _suspectStatuses = [
    'wanted',
    'in custody',
    'cleared',
  ];
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _criminalHistoryController.dispose();
    super.dispose();
  }
  
  Future<void> _submitSuspect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final suspect = Suspect(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        relatedCrimeIds: [widget.crimeId],
        criminalHistory: _criminalHistoryController.text.trim().isEmpty 
            ? null 
            : _criminalHistoryController.text.trim(),
        imagePath: null, // Would be set from image picker in a real app
      );
      
      await ref.read(suspectProvider.notifier).addSuspect(suspect);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suspect added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding suspect: $e')),
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
        title: const Text('Add Suspect'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Suspect Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Full name of the suspect',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: _selectedStatus,
                items: _suspectStatuses.map((status) {
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Physical description, identifying marks, etc.',
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
              TextFormField(
                controller: _criminalHistoryController,
                decoration: const InputDecoration(
                  labelText: 'Criminal History (Optional)',
                  hintText: 'Previous arrests, convictions, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitSuspect,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Add Suspect',
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
