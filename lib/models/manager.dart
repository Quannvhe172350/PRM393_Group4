class Manager {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String? department;
  final double? salary;
  final String? hireDate;
  final String? createdAt;
  final String? updatedAt;

  Manager({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.password = '',
    this.department,
    this.salary,
    this.hireDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Manager.fromMap(Map<String, dynamic> map) {
    return Manager(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      password: map['password'] as String? ?? '',
      department: map['department'] as String?,
      salary: (map['salary'] as num?)?.toDouble(),
      hireDate: map['hire_date'] as String?,
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
      'department': department,
      'salary': salary,
      'hire_date': hireDate,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  Manager copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? department,
    double? salary,
    String? hireDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return Manager(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      department: department ?? this.department,
      salary: salary ?? this.salary,
      hireDate: hireDate ?? this.hireDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
