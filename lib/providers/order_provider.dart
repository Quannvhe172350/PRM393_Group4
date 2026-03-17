import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [
    Order(
      id: '1',
      customerName: 'Nguyễn Văn A',
      items: [
        OrderItem(productId: '1', productName: 'Sữa tươi Vinamilk', quantity: 2, price: 32000),
        OrderItem(productId: '8', productName: 'Coca Cola', quantity: 3, price: 12000),
      ],
      totalAmount: 100000,
      status: 'completed',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Order(
      id: '2',
      customerName: 'Trần Thị B',
      items: [
        OrderItem(productId: '3', productName: 'Táo Fuji', quantity: 1, price: 65000),
        OrderItem(productId: '5', productName: 'Trứng gà', quantity: 2, price: 42000),
      ],
      totalAmount: 149000,
      status: 'processing',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Order(
      id: '3',
      customerName: 'Lê Văn C',
      items: [
        OrderItem(productId: '7', productName: 'Gạo ST25', quantity: 1, price: 120000),
        OrderItem(productId: '6', productName: 'Nước mắm Nam Ngư', quantity: 2, price: 28000),
      ],
      totalAmount: 176000,
      status: 'pending',
      orderDate: DateTime.now(),
    ),
  ];

  List<Order> get orders => List.unmodifiable(_orders);

  int get totalOrders => _orders.length;

  int get pendingOrders => _orders.where((o) => o.status == 'pending').length;

  int get completedOrders => _orders.where((o) => o.status == 'completed').length;

  double get totalRevenue => _orders
      .where((o) => o.status == 'completed')
      .fold(0.0, (sum, order) => sum + order.totalAmount);

  Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Order> getByStatus(String status) {
    if (status.isEmpty || status == 'all') return _orders;
    return _orders.where((o) => o.status == status).toList();
  }

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(String id, String newStatus) {
    final order = getById(id);
    if (order != null) {
      order.status = newStatus;
      notifyListeners();
    }
  }

  void deleteOrder(String id) {
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
