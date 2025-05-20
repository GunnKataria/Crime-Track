enum UserRole { citizen, officer, admin }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String badgeNumber; // For officers
  final String department; // For officers
  final String? imagePath;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.badgeNumber = '',
    this.department = '',
    this.imagePath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.byName(json['role']),
      badgeNumber: json['badgeNumber'] ?? '',
      department: json['department'] ?? '',
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'badgeNumber': badgeNumber,
      'department': department,
      'imagePath': imagePath,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? badgeNumber,
    String? department,
    String? imagePath,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      department: department ?? this.department,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
