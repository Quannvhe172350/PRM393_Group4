import 'order_item.dart';

class Order {
  String id;
  String customerName;
  List<OrderItem> items;
  double totalAmount;
  String status; // pending, processing, completed, cancelled
  DateTime orderDate;

  Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    DateTime? orderDate,
  }) : orderDate = orderDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      customerName: map['customerName'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      orderDate: map['orderDate'] != null
          ? DateTime.parse(map['orderDate'])
          : DateTime.now(),
    );
  }
}
