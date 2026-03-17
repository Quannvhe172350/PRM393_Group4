class Employee {
  String id;
  String name;
  String email;
  String phone;
  String role;
  double salary;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'staff',
    this.salary = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'salary': salary,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'staff',
      salary: (map['salary'] ?? 0).toDouble(),
    );
  }
}
