class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role; // admin | manager | staff
  final bool isBanned;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.password = '',
    this.role = 'staff',
    this.isBanned = false,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      password: map['password'] as String? ?? '',
      role: map['role'] as String? ?? 'staff',
      isBanned: (map['is_banned'] as int?) == 1,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'is_banned': isBanned ? 1 : 0,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? role,
    bool? isBanned,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      role: role ?? this.role,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get roleDisplay {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'manager':
        return 'Quản lý';
      case 'staff':
        return 'Nhân viên';
      default:
        return role;
    }
  }
}
