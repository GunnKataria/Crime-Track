import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/crime.dart';
import 'package:crime_management_system/models/evidence.dart';
import 'package:crime_management_system/providers/crime_provider.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:crime_management_system/widgets/file_preview_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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
  
  // File upload related variables
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedFileType;
  
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
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final status = await Permission.photos.request();
      if (status.isGranted) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1800,
          maxHeight: 1800,
        );
        
        if (pickedFile != null) {
          // Copy the file to app's documents directory for persistence
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = path.basename(pickedFile.path);
          final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
          
          setState(() {
            _selectedFilePath = savedImage.path;
            _selectedFileName = fileName;
            _selectedFileType = 'image';
            _hasEvidence = true;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission to access photos denied')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.path != null) {
          // Copy the file to app's documents directory for persistence
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = file.name;
          final savedFile = await File(file.path!).copy('${appDir.path}/$fileName');
          
          String fileType = 'document';
          final extension = path.extension(fileName).toLowerCase();
          
          if (['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
            fileType = 'image';
          } else if (['.mp4', '.mov', '.avi'].contains(extension)) {
            fileType = 'video';
          } else if (['.mp3', '.wav', '.aac'].contains(extension)) {
            fileType = 'audio';
          } else if (['.pdf', '.doc', '.docx', '.txt'].contains(extension)) {
            fileType = 'document';
          }
          
          setState(() {
            _selectedFilePath = savedFile.path;
            _selectedFileName = fileName;
            _selectedFileType = fileType;
            _hasEvidence = true;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }
  
  void _showFilePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Pick a Document'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_hasEvidence || _selectedFilePath == null) {
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
        status: 'pending_verification', 
        reportedBy: user.id,
        evidenceIds: [],
        witnessIds: [],
        suspectIds: [],
        latitude: 0.0, 
        longitude: 0.0, // Would be set from map in a real app
        isAnonymous: _isAnonymous,
        createdAt: DateTime.now(),
        assignedOfficer: '',
        isVerified: false,
      );
      
      // Create the evidence
      if (_hasEvidence && _evidenceDescriptionController.text.isNotEmpty && _selectedFilePath != null) {
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
          imagePath: _selectedFilePath,
          fileType: _selectedFileType,
          fileName: _selectedFileName,
        );
        
        
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
                    if (!value) {
                      _selectedFilePath = null;
                      _selectedFileName = null;
                      _selectedFileType = null;
                    }
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
                
                // File upload section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Evidence File',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedFilePath != null) ...[
                      FilePreviewWidget(
                        filePath: _selectedFilePath,
                        fileType: _selectedFileType,
                        fileName: _selectedFileName,
                        height: 200,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Remove', style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              setState(() {
                                _selectedFilePath = null;
                                _selectedFileName = null;
                                _selectedFileType = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: InkWell(
                          onTap: _showFilePickerOptions,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to upload evidence file',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Photos, videos, documents, etc.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showFilePickerOptions,
                        icon: const Icon(Icons.upload_file),
                        label: Text(_selectedFilePath == null ? 'Upload Evidence File' : 'Change File'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                    ),
                  ],
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
