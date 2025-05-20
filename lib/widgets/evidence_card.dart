import 'package:flutter/material.dart';
import 'package:crime_management_system/models/evidence.dart';
import 'package:crime_management_system/widgets/file_preview_widget.dart';
import 'package:intl/intl.dart';

class EvidenceCard extends StatelessWidget {
  final Evidence evidence;
  final VoidCallback? onTap;

  const EvidenceCard({
    Key? key,
    required this.evidence,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the evidence file if available
            if (evidence.imagePath != null && evidence.imagePath!.isNotEmpty)
              FilePreviewWidget(
                filePath: evidence.imagePath,
                fileType: evidence.fileType,
                fileName: evidence.fileName,
                height: 180,
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTypeColor(evidence.type),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          evidence.type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    evidence.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Collected by: ${evidence.collectedBy}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(evidence.collectedAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Storage: ${evidence.storageLocation}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'photo':
        return Colors.blue;
      case 'video':
        return Colors.red;
      case 'document':
        return Colors.orange;
      case 'physical':
        return Colors.green;
      case 'audio':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'collected':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'analyzed':
        return Colors.blue;
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
