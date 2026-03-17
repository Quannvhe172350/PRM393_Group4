class Customer {
  final int? id;
  final String name;
  final String? email;
  final String phone;
  final String? address;
  final int loyaltyPoints;
  final String? membershipDate;
  final String? createdAt;
  final String? updatedAt;

  Customer({
    this.id,
    required this.name,
    this.email,
    required this.phone,
    this.address,
    this.loyaltyPoints = 0,
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
      address: map['address'] as String?,
      loyaltyPoints: map['loyalty_points'] as int? ?? 0,
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
      'address': address,
      'loyalty_points': loyaltyPoints,
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
    String? address,
    int? loyaltyPoints,
    String? membershipDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      membershipDate: membershipDate ?? this.membershipDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
