class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool emailVerified;
  final bool profileComplete;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.emailVerified,
    required this.profileComplete,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user',
      emailVerified: json['email_verified'] ?? false,
      profileComplete: json['profile_complete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'email_verified': emailVerified,
    'profile_complete': profileComplete,
  };
}
