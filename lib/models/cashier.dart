class Cashier {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final int? counterNumber;
  final String shift;
  final double? salary;
  final String? hireDate;
  final String? createdAt;
  final String? updatedAt;

  Cashier({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.password = '',
    this.counterNumber,
    this.shift = 'morning',
    this.salary,
    this.hireDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Cashier.fromMap(Map<String, dynamic> map) {
    return Cashier(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      password: map['password'] as String? ?? '',
      counterNumber: map['counter_number'] as int?,
      shift: map['shift'] as String? ?? 'morning',
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
      'counter_number': counterNumber,
      'shift': shift,
      'salary': salary,
      'hire_date': hireDate,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  Cashier copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    int? counterNumber,
    String? shift,
    double? salary,
    String? hireDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return Cashier(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      counterNumber: counterNumber ?? this.counterNumber,
      shift: shift ?? this.shift,
      salary: salary ?? this.salary,
      hireDate: hireDate ?? this.hireDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
