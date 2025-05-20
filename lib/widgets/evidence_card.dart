import 'package:flutter/material.dart';
import 'package:crime_management_system/models/evidence.dart';
import 'package:intl/intl.dart';

class EvidenceCard extends StatelessWidget {
  final Evidence evidence;
  final VoidCallback onTap;

  const EvidenceCard({
    Key? key,
    required this.evidence,
    required this.onTap,
  }) : super(key: key);

  IconData _getEvidenceTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'photo':
        return Icons.photo;
      case 'video':
        return Icons.videocam;
      case 'document':
        return Icons.description;
      case 'physical':
        return Icons.inventory;
      case 'audio':
        return Icons.mic;
      default:
        return Icons.folder;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'collected':
        return Colors.blue;
      case 'analyzed':
        return Colors.orange;
      case 'stored':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: evidence.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          evidence.imagePath!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        _getEvidenceTypeIcon(evidence.type),
                        size: 32,
                        color: Colors.grey[600],
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(evidence.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            evidence.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            evidence.type.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      evidence.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Collected by: ${evidence.collectedBy}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Date: ${dateFormat.format(evidence.collectedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
