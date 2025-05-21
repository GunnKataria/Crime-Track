import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/witness_provider.dart';

class EditWitnessScreen extends ConsumerStatefulWidget {
  final String witnessId;

  const EditWitnessScreen({
    Key? key,
    required this.witnessId,
  }) : super(key: key);

  @override
  ConsumerState<EditWitnessScreen> createState() => _EditWitnessScreenState();
}

class _EditWitnessScreenState extends ConsumerState<EditWitnessScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactInfoController;
  late TextEditingController _statementController;
  
  late String _selectedCredibility;
  late bool _isAnonymous;
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  final List<String> _credibilityRatings = [
    'high',
    'medium',
    'low',
  ];
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _contactInfoController = TextEditingController();
    _statementController = TextEditingController();
    
    
    _selectedCredibility = 'medium';
    _isAnonymous = false;
    
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWitnessData();
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _contactInfoController.dispose();
    _statementController.dispose();
    super.dispose();
  }
  
  Future<void> _loadWitnessData() async {
    setState(() {
      _isLoading = true;
    });
    
    final witness = ref.read(witnessProvider.notifier).getWitnessById(widget.witnessId);
    
    if (witness != null) {
      _nameController.text = witness.isAnonymous ? '' : witness.name;
      _contactInfoController.text = witness.isAnonymous ? '' : witness.contactInfo;
      _statementController.text = witness.statement;
      _selectedCredibility = witness.credibilityRating;
      _isAnonymous = witness.isAnonymous;
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _updateWitness() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final witness = ref.read(witnessProvider.notifier).getWitnessById(widget.witnessId);
      
      if (witness == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Witness not found')),
        );
        return;
      }
      
      final updatedWitness = witness.copyWith(
        name: _isAnonymous ? 'Anonymous Witness' : _nameController.text.trim(),
        contactInfo: _isAnonymous ? 'N/A' : _contactInfoController.text.trim(),
        statement: _statementController.text.trim(),
        credibilityRating: _selectedCredibility,
        isAnonymous: _isAnonymous,
      );
      
      await ref.read(witnessProvider.notifier).updateWitness(updatedWitness);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Witness updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating witness: $e')),
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
        title: const Text('Edit Witness'),
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
                      'Witness Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Anonymous Witness'),
                      subtitle: const Text('Protect the identity of the witness'),
                      value: _isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymous = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (!_isAnonymous) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Full name of the witness',
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
                      TextFormField(
                        controller: _contactInfoController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Information',
                          hintText: 'Phone number, email, etc.',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact information';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Credibility Rating',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCredibility,
                      items: _credibilityRatings.map((rating) {
                        return DropdownMenuItem(
                          value: rating,
                          child: Text(rating.substring(0, 1).toUpperCase() + rating.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCredibility = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _statementController,
                      decoration: const InputDecoration(
                        labelText: 'Statement',
                        hintText: 'What the witness saw or heard',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a statement';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _updateWitness,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Update Witness',
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
        title: const Text('Delete Witness'),
        content: const Text('Are you sure you want to delete this witness? This action cannot be undone.'),
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
              await ref.read(witnessProvider.notifier).deleteWitness(widget.witnessId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Witness deleted successfully')),
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
