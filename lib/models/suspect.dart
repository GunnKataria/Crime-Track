class Suspect {
  final String id;
  final String name;
  final String description;
  final String status; // wanted, in custody, cleared
  final List<String> relatedCrimeIds;
  final String? criminalHistory;
  final String? imagePath;

  Suspect({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.relatedCrimeIds,
    this.criminalHistory,
    this.imagePath,
  });

  factory Suspect.fromJson(Map<String, dynamic> json) {
    return Suspect(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      relatedCrimeIds: List<String>.from(json['relatedCrimeIds']),
      criminalHistory: json['criminalHistory'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'relatedCrimeIds': relatedCrimeIds,
      'criminalHistory': criminalHistory,
      'imagePath': imagePath,
    };
  }

  Suspect copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    List<String>? relatedCrimeIds,
    String? criminalHistory,
    String? imagePath,
  }) {
    return Suspect(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      relatedCrimeIds: relatedCrimeIds ?? this.relatedCrimeIds,
      criminalHistory: criminalHistory ?? this.criminalHistory,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
