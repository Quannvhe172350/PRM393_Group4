class PurchaseOrder {
  final String id;
  final int supplierId;
  final String? supplierName; // Joined from DB
  final DateTime orderDate;
  String status; // 'pending', 'shipped', 'completed', 'cancelled'
  final double totalAmount;
  List<PurchaseOrderItem>? items;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    this.supplierName,
    required this.orderDate,
    this.status = 'pending',
    required this.totalAmount,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory PurchaseOrder.fromMap(Map<String, dynamic> map) {
    return PurchaseOrder(
      id: map['id'] ?? '',
      supplierId: map['supplier_id'] ?? 0,
      supplierName: map['supplier_name'],
      orderDate: DateTime.parse(map['order_date'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? 'pending',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
    );
  }

  PurchaseOrder copyWith({
    String? id,
    int? supplierId,
    String? supplierName,
    DateTime? orderDate,
    String? status,
    double? totalAmount,
    List<PurchaseOrderItem>? items,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
    );
  }
}

class PurchaseOrderItem {
  final int? id;
  final String poId;
  final int productId;
  final String? productName; // Joined from DB
  final int quantity;
  final double unitPrice;
  final double subtotal;

  PurchaseOrderItem({
    this.id,
    required this.poId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'po_id': poId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory PurchaseOrderItem.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderItem(
      id: map['id'],
      poId: map['po_id'] ?? '',
      productId: map['product_id'] ?? 0,
      productName: map['product_name'],
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unit_price'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }
}
