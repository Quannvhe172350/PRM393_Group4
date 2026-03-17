class Product {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final int quantity;
  final int? categoryId;
  final String? imageUrl;
  final String? barcode;
  final String? createdAt;
  final String? updatedAt;

  // Joined field (not stored in DB)
  final String? categoryName;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.quantity = 0,
    this.categoryId,
    this.imageUrl,
    this.barcode,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 0,
      categoryId: map['category_id'] as int?,
      imageUrl: map['image_url'] as String?,
      barcode: map['barcode'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      categoryName: map['category_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category_id': categoryId,
      'image_url': imageUrl,
      'barcode': barcode,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    int? categoryId,
    String? imageUrl,
    String? barcode,
    String? createdAt,
    String? updatedAt,
    String? categoryName,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
