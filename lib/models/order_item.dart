class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  // Joined field (not stored in DB)
  final String? productName;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.productName,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as int?,
      orderId: map['order_id'] as int? ?? 0,
      productId: map['product_id'] as int? ?? 0,
      quantity: map['quantity'] as int? ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      productName: map['product_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    int? quantity,
    double? unitPrice,
    double? subtotal,
    String? productName,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      productName: productName ?? this.productName,
    );
  }
}
