import 'package:flutter/material.dart';
import 'package:crime_management_system/models/witness.dart';

class WitnessCard extends StatelessWidget {
  final Witness witness;
  final VoidCallback onTap;

  const WitnessCard({
    Key? key,
    required this.witness,
    required this.onTap,
  }) : super(key: key);

  Color _getCredibilityColor(String credibility) {
    switch (credibility.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
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
                backgroundImage: witness.imagePath != null
                    ? AssetImage(witness.imagePath!)
                    : null,
                child: witness.imagePath == null
                    ? Icon(
                        witness.isAnonymous ? Icons.person_off : Icons.person,
                        color: Colors.grey[600],
                      )
                    : null,
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
                            color: _getCredibilityColor(witness.credibilityRating),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${witness.credibilityRating.toUpperCase()} CREDIBILITY',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (witness.isAnonymous)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ANONYMOUS',
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
                      witness.isAnonymous ? 'Anonymous Witness' : witness.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (!witness.isAnonymous) ...[
                      Text(
                        'Contact: ${witness.contactInfo}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'Statement: ${witness.statement.length > 100 ? '${witness.statement.substring(0, 100)}...' : witness.statement}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
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
