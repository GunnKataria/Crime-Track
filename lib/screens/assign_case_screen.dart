import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/crime_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';

class AssignCaseScreen extends ConsumerStatefulWidget {
  final String crimeId;

  const AssignCaseScreen({
    Key? key,
    required this.crimeId,
  }) : super(key: key);

  @override
  ConsumerState<AssignCaseScreen> createState() => _AssignCaseScreenState();
}

class _AssignCaseScreenState extends ConsumerState<AssignCaseScreen> {
  bool _isAssigning = false;
  
  Future<void> _assignToMe() async {
    setState(() {
      _isAssigning = true;
    });
    
    try {
      final user = ref.read(authProvider);
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to assign a case')),
        );
        return;
      }
      
      final crime = ref.read(crimeProvider.notifier).getCrimeById(widget.crimeId);
      
      if (crime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case not found')),
        );
        return;
      }
      
      final updatedCrime = crime.copyWith(
        assignedOfficer: user.id,
        status: crime.status == 'open' ? 'investigating' : crime.status,
      );
      
      await ref.read(crimeProvider.notifier).updateCrime(updatedCrime);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Case assigned successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning case: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final crime = ref.watch(crimeProvider.notifier).getCrimeById(widget.crimeId);
    final user = ref.watch(authProvider);
    
    if (crime == null || user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Assign Case'),
        ),
        body: const Center(
          child: Text('Case or user not found'),
        ),
      );
    }
    
    final isAlreadyAssigned = crime.assignedOfficer.isNotEmpty;
    final isAssignedToMe = crime.assignedOfficer == user.id;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Case'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Case Assignment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Case: ${crime.title}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${crime.status.substring(0, 1).toUpperCase() + crime.status.substring(1)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Assignment: ${isAlreadyAssigned ? (isAssignedToMe ? "Assigned to you" : "Assigned to another officer") : "Not assigned"}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isAssignedToMe) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This case is already assigned to you',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Return to Case',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ] else if (isAlreadyAssigned) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.orange,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This case is already assigned to another officer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Reassigning the case will remove it from their workload',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAssigning ? null : _assignToMe,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isAssigning
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Reassign to Me',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ] else ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_ind,
                        color: Colors.blue,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This case is not currently assigned to any officer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Assigning the case to yourself will make you responsible for the investigation',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAssigning ? null : _assignToMe,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isAssigning
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Assign to Me',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
