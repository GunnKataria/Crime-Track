import 'package:flutter/material.dart';
import 'package:crime_management_system/models/suspect.dart';

class SuspectCard extends StatelessWidget {
  final Suspect suspect;
  final VoidCallback onTap;

  const SuspectCard({
    Key? key,
    required this.suspect,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'wanted':
        return Colors.red;
      case 'in custody':
        return Colors.blue;
      case 'cleared':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: suspect.imagePath != null
                    ? AssetImage(suspect.imagePath!)
                    : null,
                child: suspect.imagePath == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.grey,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(suspect.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        suspect.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suspect.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suspect.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (suspect.criminalHistory != null) ...[
                      Text(
                        'Criminal History: ${suspect.criminalHistory!.length > 50 ? '${suspect.criminalHistory!.substring(0, 50)}...' : suspect.criminalHistory}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Related to ${suspect.relatedCrimeIds.length} crime(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
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
