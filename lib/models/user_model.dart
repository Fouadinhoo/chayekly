class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role; // 'client', 'admin', 'engineer'
  final String? email;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      role: map['role'],
      email: map['email'],
    );
  }
}