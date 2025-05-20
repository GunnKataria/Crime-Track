class Crime {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String type;
  final String status; // 'pending_verification', 'open', 'investigating', 'closed', 'insufficient_evidence'
  final String reportedBy;
  final List<String> evidenceIds;
  final List<String> witnessIds;
  final List<String> suspectIds;
  final double latitude;
  final double longitude;
  final bool isAnonymous;
  final DateTime createdAt;
  final String assignedOfficer;
  final String verificationNotes; // Notes from officer during verification
  final bool isVerified; // Whether the case has been verified

  Crime({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.type,
    required this.status,
    required this.reportedBy,
    required this.evidenceIds,
    required this.witnessIds,
    required this.suspectIds,
    required this.latitude,
    required this.longitude,
    required this.isAnonymous,
    required this.createdAt,
    required this.assignedOfficer,
    this.verificationNotes = '',
    this.isVerified = false,
  });

  factory Crime.fromJson(Map<String, dynamic> json) {
    return Crime(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      dateTime: DateTime.parse(json['dateTime']),
      type: json['type'],
      status: json['status'],
      reportedBy: json['reportedBy'],
      evidenceIds: List<String>.from(json['evidenceIds']),
      witnessIds: List<String>.from(json['witnessIds']),
      suspectIds: List<String>.from(json['suspectIds']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isAnonymous: json['isAnonymous'],
      createdAt: DateTime.parse(json['createdAt']),
      assignedOfficer: json['assignedOfficer'],
      verificationNotes: json['verificationNotes'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'status': status,
      'reportedBy': reportedBy,
      'evidenceIds': evidenceIds,
      'witnessIds': witnessIds,
      'suspectIds': suspectIds,
      'latitude': latitude,
      'longitude': longitude,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'assignedOfficer': assignedOfficer,
      'verificationNotes': verificationNotes,
      'isVerified': isVerified,
    };
  }

  Crime copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? dateTime,
    String? type,
    String? status,
    String? reportedBy,
    List<String>? evidenceIds,
    List<String>? witnessIds,
    List<String>? suspectIds,
    double? latitude,
    double? longitude,
    bool? isAnonymous,
    DateTime? createdAt,
    String? assignedOfficer,
    String? verificationNotes,
    bool? isVerified,
  }) {
    return Crime(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      status: status ?? this.status,
      reportedBy: reportedBy ?? this.reportedBy,
      evidenceIds: evidenceIds ?? this.evidenceIds,
      witnessIds: witnessIds ?? this.witnessIds,
      suspectIds: suspectIds ?? this.suspectIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      assignedOfficer: assignedOfficer ?? this.assignedOfficer,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
