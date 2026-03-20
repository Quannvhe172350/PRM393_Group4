class Product {
  String id;
  String barcode;
  String name;
  double price;
  int quantity;
  String category;
  String description;
  String imageUrl;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
    required this.quantity,
    this.category = '',
    this.description = '',
    this.imageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
