import 'order_item.dart';

class Order {
  final int? id;
  final int? customerId;
  final int? cashierId;
  final String orderDate;
  final double totalAmount;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  // Joined fields (not stored in DB)
  final String? customerName;
  final String? customerPhone;
  final String? cashierName;
  final List<OrderItem>? items;

  Order({
    this.id,
    this.customerId,
    this.cashierId,
    required this.orderDate,
    this.totalAmount = 0.0,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerPhone,
    this.cashierName,
    this.items,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int?,
      cashierId: map['cashier_id'] as int?,
      orderDate: map['order_date'] as String? ?? '',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      cashierName: map['cashier_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'cashier_id': cashierId,
      'order_date': orderDate,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
      'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
    };
  }

  Order copyWith({
    int? id,
    int? customerId,
    int? cashierId,
    String? orderDate,
    double? totalAmount,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? customerName,
    String? customerPhone,
    String? cashierName,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      cashierId: cashierId ?? this.cashierId,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      cashierName: cashierName ?? this.cashierName,
      items: items ?? this.items,
    );
  }
}
