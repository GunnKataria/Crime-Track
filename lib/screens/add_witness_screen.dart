import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/witness.dart';
import 'package:crime_management_system/providers/witness_provider.dart';
import 'package:uuid/uuid.dart';

class AddWitnessScreen extends ConsumerStatefulWidget {
  final String crimeId;

  const AddWitnessScreen({
    Key? key,
    required this.crimeId,
  }) : super(key: key);

  @override
  ConsumerState<AddWitnessScreen> createState() => _AddWitnessScreenState();
}

class _AddWitnessScreenState extends ConsumerState<AddWitnessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _statementController = TextEditingController();
  
  String _selectedCredibility = 'medium';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  
  final List<String> _credibilityRatings = [
    'high',
    'medium',
    'low',
  ];
  
  @override
  void dispose() {
    _nameController.dispose();
    _contactInfoController.dispose();
    _statementController.dispose();
    super.dispose();
  }
  
  Future<void> _submitWitness() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final witness = Witness(
        id: const Uuid().v4(),
        name: _isAnonymous ? 'Anonymous Witness' : _nameController.text.trim(),
        contactInfo: _isAnonymous ? 'N/A' : _contactInfoController.text.trim(),
        statement: _statementController.text.trim(),
        credibilityRating: _selectedCredibility,
        isAnonymous: _isAnonymous,
        relatedCrimeIds: [widget.crimeId],
        imagePath: null, // Would be set from image picker in a real app
      );
      
      await ref.read(witnessProvider.notifier).addWitness(witness);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Witness added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding witness: $e')),
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
        title: const Text('Add Witness'),
      ),
      body: SingleChildScrollView(
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
                  onPressed: _isSubmitting ? null : _submitWitness,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Add Witness',
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
