class Witness {
  final String id;
  final String name;
  final String contactInfo;
  final String statement;
  final String credibilityRating; // high, medium, low
  final bool isAnonymous;
  final List<String> relatedCrimeIds;
  final String? imagePath;

  Witness({
    required this.id,
    required this.name,
    required this.contactInfo,
    required this.statement,
    required this.credibilityRating,
    required this.isAnonymous,
    required this.relatedCrimeIds,
    this.imagePath,
  });

  factory Witness.fromJson(Map<String, dynamic> json) {
    return Witness(
      id: json['id'],
      name: json['name'],
      contactInfo: json['contactInfo'],
      statement: json['statement'],
      credibilityRating: json['credibilityRating'],
      isAnonymous: json['isAnonymous'],
      relatedCrimeIds: List<String>.from(json['relatedCrimeIds']),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactInfo': contactInfo,
      'statement': statement,
      'credibilityRating': credibilityRating,
      'isAnonymous': isAnonymous,
      'relatedCrimeIds': relatedCrimeIds,
      'imagePath': imagePath,
    };
  }

  Witness copyWith({
    String? id,
    String? name,
    String? contactInfo,
    String? statement,
    String? credibilityRating,
    bool? isAnonymous,
    List<String>? relatedCrimeIds,
    String? imagePath,
  }) {
    return Witness(
      id: id ?? this.id,
      name: name ?? this.name,
      contactInfo: contactInfo ?? this.contactInfo,
      statement: statement ?? this.statement,
      credibilityRating: credibilityRating ?? this.credibilityRating,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      relatedCrimeIds: relatedCrimeIds ?? this.relatedCrimeIds,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
