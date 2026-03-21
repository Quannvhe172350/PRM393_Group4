import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  int get totalOrders => _orders.length;

  int get pendingOrders => _orders.where((o) => o.status == 'pending').length;
  int get completedOrders => _orders.where((o) => o.status == 'completed').length;

  double get totalRevenue => _orders
      .where((o) => o.status == 'completed')
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  OrderProvider() {
    // Để cho UI gọi load dữ liệu khi cần
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await AppDatabase.instance.getOrders();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Order?> getOrderDetail(int id) async {
    return await AppDatabase.instance.getOrderById(id);
  }

  List<Order> getByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  Future<void> updateStatus(int orderId, String status) async {
    if (status == 'cancelled') {
      await AppDatabase.instance.cancelOrder(orderId);
    } else {
      await AppDatabase.instance.updateOrderStatus(orderId, status);
    }
    await loadOrders();
  }

  Future<void> deleteOrder(int id) async {
    await AppDatabase.instance.deleteOrder(id);
    await loadOrders();
  }
}
