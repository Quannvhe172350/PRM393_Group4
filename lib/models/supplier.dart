class Supplier {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? createdAt;

  Supplier({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  Supplier copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
