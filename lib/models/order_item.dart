class OrderItem {
  String? orderId;
  String productId;
  String productName;
  int quantity;
  double price;

  OrderItem({
    this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toMap() {
    return {
      if (orderId != null) 'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      orderId: map['orderId'],
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  OrderItem copyWith({
    String? orderId,
    String? productId,
    String? productName,
    int? quantity,
    double? price,
  }) {
    return OrderItem(
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
