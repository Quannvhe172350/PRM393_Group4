class Customer {
  final int? id;
  final String name;
  final String? email;
  final String phone;
  final String password;
  final String? address;
  final int loyaltyPoints;
  final bool isBanned;
  final String? membershipDate;
  final String? createdAt;
  final String? updatedAt;

  Customer({
    this.id,
    required this.name,
    this.email,
    required this.phone,
    this.password = '',
    this.address,
    this.loyaltyPoints = 0,
    this.isBanned = false,
    this.membershipDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String? ?? '',
      password: map['password'] as String? ?? '',
      address: map['address'] as String?,
      loyaltyPoints: map['loyalty_points'] as int? ?? 0,
      isBanned: (map['is_banned'] as int?) == 1,
      membershipDate: map['membership_date'] as String?,
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
      'address': address,
      'loyalty_points': loyaltyPoints,
      'is_banned': isBanned ? 1 : 0,
      'membership_date': membershipDate ?? DateTime.now().toIso8601String(),
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  Customer copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? address,
    int? loyaltyPoints,
    bool? isBanned,
    String? membershipDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      address: address ?? this.address,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      isBanned: isBanned ?? this.isBanned,
      membershipDate: membershipDate ?? this.membershipDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
