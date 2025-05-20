import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/models/evidence.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:crime_management_system/providers/crime_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:crime_management_system/widgets/file_preview_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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
  
  String _selectedEvidenceType = 'photo';
  DateTime _collectedDate = DateTime.now();
  TimeOfDay _collectedTime = TimeOfDay.now();
  
  bool _isSubmitting = false;
  
  // File upload related variables
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _selectedFileType;
  
  final List<String> _evidenceTypes = [
    'photo',
    'video',
    'document',
    'physical',
    'audio',
  ];
  
  @override
  void initState() {
    super.initState();
    _storageLocationController.text = 'Police Station';
  }
  
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
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _collectedTime,
    );
    
    if (picked != null && picked != _collectedTime) {
      setState(() {
        _collectedTime = picked;
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
      
      // Combine date and time
      final collectedAt = DateTime(
        _collectedDate.year,
        _collectedDate.month,
        _collectedDate.day,
        _collectedTime.hour,
        _collectedTime.minute,
      );
      
      final evidenceId = const Uuid().v4();
      
      // Create the evidence
      final evidence = Evidence(
        id: evidenceId,
        crimeId: widget.crimeId,
        description: _descriptionController.text.trim(),
        type: _selectedEvidenceType,
        status: 'collected',
        collectedAt: collectedAt,
        collectedBy: user.name,
        storageLocation: _storageLocationController.text.trim(),
        imagePath: _selectedFilePath,
        fileType: _selectedFileType,
        fileName: _selectedFileName,
      );
      
      // Add evidence
      await ref.read(evidenceProvider.notifier).addEvidence(evidence);
      
      // Update crime with evidence ID
      final crime = ref.read(crimeProvider.notifier).getCrimeById(widget.crimeId);
      if (crime != null) {
        final updatedEvidenceIds = [...crime.evidenceIds, evidenceId];
        final updatedCrime = crime.copyWith(
          evidenceIds: updatedEvidenceIds,
        );
        await ref.read(crimeProvider.notifier).updateCrime(updatedCrime);
      }
      
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
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the evidence',
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
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Collected Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_collectedDate.day}/${_collectedDate.month}/${_collectedDate.year}',
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
                          labelText: 'Collected Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_collectedTime.hour}:${_collectedTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _storageLocationController,
                decoration: const InputDecoration(
                  labelText: 'Storage Location',
                  hintText: 'Where is the evidence stored',
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
