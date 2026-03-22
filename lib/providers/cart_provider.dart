import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';

/// Giỏ hàng tạm (in-memory)
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

  /// Thêm SP vào giỏ
  void addToCart(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  /// Cập nhật số lượng
  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  /// Xóa SP khỏi giỏ
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Xóa toàn bộ giỏ hàng
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Checkout: tạo Order trong DB, cộng/trừ loyalty points
  Future<int> checkout(int customerId, {int pointsUsed = 0}) async {
    if (_items.isEmpty) throw Exception('Giỏ hàng trống');

    final discount = pointsUsed * 100;
    final finalAmount = (totalAmount - discount) < 0 ? 0.0 : (totalAmount - discount);

    final order = Order(
      customerId: customerId,
      totalAmount: finalAmount,
      status: 'pending',
    );

    final orderItems = _items.map((item) => OrderItem(
      productId: item.product.id!,
      quantity: item.quantity,
      unitPrice: item.product.price,
      subtotal: item.product.price * item.quantity,
    )).toList();

    final orderId = await AppDatabase.instance.createOrder(order, orderItems);

    if (pointsUsed > 0) {
      await AppDatabase.instance.deductCustomerLoyaltyPoints(customerId, pointsUsed);
    }

    // Cộng loyalty points (1 điểm / 1.000đ) dựa trên số tiền thực trả
    final points = (finalAmount / 1000).floor();
    if (points > 0) {
      await AppDatabase.instance.updateCustomerLoyaltyPoints(customerId, points);
    }

    clearCart();
    return orderId;
  }
}

/// Class lưu thông tin 1 item trong giỏ hàng
class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
