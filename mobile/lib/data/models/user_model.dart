// lib/data/models/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt,
    };
  }

  UserModel copyWith({String? name, String? email}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt,
    );
  }
}