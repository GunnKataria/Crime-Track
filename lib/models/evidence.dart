class Evidence {
  final String id;
  final String crimeId;
  final String description;
  final String type; // photo, video, document, physical
  final String status; // collected, analyzed, stored
  final DateTime collectedAt;
  final String collectedBy;
  final String storageLocation;
  final String? imagePath;

  Evidence({
    required this.id,
    required this.crimeId,
    required this.description,
    required this.type,
    required this.status,
    required this.collectedAt,
    required this.collectedBy,
    required this.storageLocation,
    this.imagePath,
  });

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      id: json['id'],
      crimeId: json['crimeId'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
      collectedAt: DateTime.parse(json['collectedAt']),
      collectedBy: json['collectedBy'],
      storageLocation: json['storageLocation'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crimeId': crimeId,
      'description': description,
      'type': type,
      'status': status,
      'collectedAt': collectedAt.toIso8601String(),
      'collectedBy': collectedBy,
      'storageLocation': storageLocation,
      'imagePath': imagePath,
    };
  }

  Evidence copyWith({
    String? id,
    String? crimeId,
    String? description,
    String? type,
    String? status,
    DateTime? collectedAt,
    String? collectedBy,
    String? storageLocation,
    String? imagePath,
  }) {
    return Evidence(
      id: id ?? this.id,
      crimeId: crimeId ?? this.crimeId,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      collectedAt: collectedAt ?? this.collectedAt,
      collectedBy: collectedBy ?? this.collectedBy,
      storageLocation: storageLocation ?? this.storageLocation,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
