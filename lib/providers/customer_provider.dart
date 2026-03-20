import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/customer.dart';
import '../models/order.dart';

/// Provider quản lý phiên đăng nhập và dữ liệu Customer
class CustomerProvider extends ChangeNotifier {
  Customer? _currentCustomer;
  List<Order> _orders = [];
  bool _isLoading = false;

  Customer? get currentCustomer => _currentCustomer;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentCustomer != null;
  int get loyaltyPoints => _currentCustomer?.loyaltyPoints ?? 0;

  /// Đăng nhập bằng SĐT + mật khẩu
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final customer = await AppDatabase.instance.authenticateCustomer(phone, password);
      if (customer != null) {
        _currentCustomer = customer;
        await loadOrders();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error login customer: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Kiểm tra SĐT đã tồn tại chưa
  Future<bool> phoneExists(String phone) async {
    final existing = await AppDatabase.instance.getCustomerByPhone(phone);
    return existing != null;
  }

  /// Đăng ký tài khoản mới (có mật khẩu)
  Future<bool> register(Customer customer) async {
    try {
      final existing = await AppDatabase.instance.getCustomerByPhone(customer.phone);
      if (existing != null) return false;

      await AppDatabase.instance.insertCustomer(customer);
      // Đăng nhập ngay sau khi đăng ký
      final created = await AppDatabase.instance.authenticateCustomer(customer.phone, customer.password);
      if (created != null) {
        _currentCustomer = created;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error register customer: $e');
    }
    return false;
  }

  /// Load đơn hàng của customer
  Future<void> loadOrders() async {
    if (_currentCustomer?.id == null) return;
    try {
      _orders = await AppDatabase.instance.getOrdersByCustomer(_currentCustomer!.id!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading customer orders: $e');
    }
  }

  /// Cập nhật thông tin
  Future<void> updateProfile(Customer updated) async {
    await AppDatabase.instance.updateCustomer(updated);
    _currentCustomer = updated;
    notifyListeners();
  }

  /// Refresh dữ liệu customer từ DB
  Future<void> refresh() async {
    if (_currentCustomer?.id == null) return;
    _currentCustomer = await AppDatabase.instance.getCustomerById(_currentCustomer!.id!);
    await loadOrders();
  }

  /// Đăng xuất
  void logout() {
    _currentCustomer = null;
    _orders = [];
    notifyListeners();
  }
}
