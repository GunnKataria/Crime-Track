class Evidence {
  final String id;
  final String crimeId;
  final String description;
  final String type;
  final String status;
  final DateTime collectedAt;
  final String collectedBy;
  final String storageLocation;
  final String? imagePath; // Local path to the image/file
  final String? fileType; // Type of file (image, pdf, doc, etc.)
  final String? fileName; // Name of the file

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
    this.fileType,
    this.fileName,
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
      fileType: json['fileType'],
      fileName: json['fileName'],
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
      'fileType': fileType,
      'fileName': fileName,
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
    String? fileType,
    String? fileName,
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
      fileType: fileType ?? this.fileType,
      fileName: fileName ?? this.fileName,
    );
  }
}
