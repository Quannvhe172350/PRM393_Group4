class Supplier {
  String id;
  String name;
  String contactPerson;
  String phone;
  String email;
  String address;

  Supplier({
    required this.id,
    required this.name,
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty && id != '0') 'id': int.tryParse(id),
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: (map['id'] ?? '').toString(),
      name: map['name'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
