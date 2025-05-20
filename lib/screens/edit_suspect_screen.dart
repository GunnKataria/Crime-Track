import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/suspect_provider.dart';

class EditSuspectScreen extends ConsumerStatefulWidget {
  final String suspectId;

  const EditSuspectScreen({
    Key? key,
    required this.suspectId,
  }) : super(key: key);

  @override
  ConsumerState<EditSuspectScreen> createState() => _EditSuspectScreenState();
}

class _EditSuspectScreenState extends ConsumerState<EditSuspectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _criminalHistoryController;
  
  late String _selectedStatus;
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  final List<String> _suspectStatuses = [
    'wanted',
    'in custody',
    'cleared',
  ];
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _criminalHistoryController = TextEditingController();
    
    // Default values that will be overridden when data loads
    _selectedStatus = 'wanted';
    
    // Load suspect data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuspectData();
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _criminalHistoryController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSuspectData() async {
    setState(() {
      _isLoading = true;
    });
    
    final suspect = ref.read(suspectProvider.notifier).getSuspectById(widget.suspectId);
    
    if (suspect != null) {
      _nameController.text = suspect.name;
      _descriptionController.text = suspect.description;
      _criminalHistoryController.text = suspect.criminalHistory ?? '';
      _selectedStatus = suspect.status;
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _updateSuspect() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final suspect = ref.read(suspectProvider.notifier).getSuspectById(widget.suspectId);
      
      if (suspect == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suspect not found')),
        );
        return;
      }
      
      final updatedSuspect = suspect.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        criminalHistory: _criminalHistoryController.text.trim().isEmpty 
            ? null 
            : _criminalHistoryController.text.trim(),
      );
      
      await ref.read(suspectProvider.notifier).updateSuspect(updatedSuspect);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Suspect updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating suspect: $e')),
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
        title: const Text('Edit Suspect'),
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
                        onPressed: _isSubmitting ? null : _updateSuspect,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Update Suspect',
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
        title: const Text('Delete Suspect'),
        content: const Text('Are you sure you want to delete this suspect? This action cannot be undone.'),
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
              await ref.read(suspectProvider.notifier).deleteSuspect(widget.suspectId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Suspect deleted successfully')),
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
