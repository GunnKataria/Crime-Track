import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/crime.dart';
import 'package:crime_management_system/providers/crime_provider.dart';
import 'package:intl/intl.dart';

class EditCrimeScreen extends ConsumerStatefulWidget {
  final String crimeId;

  const EditCrimeScreen({
    Key? key,
    required this.crimeId,
  }) : super(key: key);

  @override
  ConsumerState<EditCrimeScreen> createState() => _EditCrimeScreenState();
}

class _EditCrimeScreenState extends ConsumerState<EditCrimeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  
  late String _selectedCrimeType;
  late String _selectedStatus;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _isAnonymous;
  
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  final List<String> _crimeTypes = [
    'theft',
    'assault',
    'vandalism',
    'burglary',
    'fraud',
    'homicide',
    'other',
  ];
  
  final List<String> _crimeStatuses = [
    'open',
    'investigating',
    'closed',
  ];
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    
    // Default values that will be overridden when data loads
    _selectedCrimeType = 'theft';
    _selectedStatus = 'open';
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _isAnonymous = false;
    
    // Load crime data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCrimeData();
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCrimeData() async {
    setState(() {
      _isLoading = true;
    });
    
    final crime = ref.read(crimeProvider.notifier).getCrimeById(widget.crimeId);
    
    if (crime != null) {
      _titleController.text = crime.title;
      _descriptionController.text = crime.description;
      _locationController.text = crime.location;
      _selectedCrimeType = crime.type;
      _selectedStatus = crime.status;
      _selectedDate = crime.dateTime;
      _selectedTime = TimeOfDay(
        hour: crime.dateTime.hour,
        minute: crime.dateTime.minute,
      );
      _isAnonymous = crime.isAnonymous;
    }
    
    setState(() {
      _isLoading = false;
    });
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
  
  Future<void> _updateCrime() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final crime = ref.read(crimeProvider.notifier).getCrimeById(widget.crimeId);
      
      if (crime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crime not found')),
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
      
      final updatedCrime = crime.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        dateTime: dateTime,
        type: _selectedCrimeType,
        status: _selectedStatus,
        isAnonymous: _isAnonymous,
      );
      
      await ref.read(crimeProvider.notifier).updateCrime(updatedCrime);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crime updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating crime: $e')),
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
        title: const Text('Edit Crime'),
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
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedStatus,
                      items: _crimeStatuses.map((status) {
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
                                DateFormat('MM/dd/yyyy').format(_selectedDate),
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
                    const SizedBox(height: 16),
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
                        onPressed: _isSubmitting ? null : _updateCrime,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Update Crime',
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
