import 'package:flutter/material.dart';
import '../models/product.dart';

//quan thêm barcode
class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      barcode: '12345678',
      name: 'Sữa tươi Vinamilk',
      price: 32000,
      quantity: 50,
      category: 'Đồ uống',
      description: 'Sữa tươi tiệt trùng 1L',
    ),
    Product(
      id: '2',
      barcode: '982653777',
      name: 'Bánh mì sandwich',
      price: 25000,
      quantity: 30,
      category: 'Bánh',
      description: 'Bánh mì sandwich nguyên cám',
    ),
    Product(
      id: '3',
      barcode: '986526374',
      name: 'Táo Fuji',
      price: 65000,
      quantity: 40,
      category: 'Trái cây',
      description: 'Táo Fuji nhập khẩu Nhật Bản',
    ),
    Product(
      id: '4',
      barcode: '427846544',
      name: 'Cam sành',
      price: 35000,
      quantity: 35,
      category: 'Trái cây',
      description: 'Cam sành Việt Nam',
    ),
    Product(
      id: '5',
      barcode: '543547388',
      name: 'Trứng gà',
      price: 42000,
      quantity: 60,
      category: 'Thực phẩm',
      description: 'Trứng gà ta (hộp 10 quả)',
    ),
    Product(
      id: '6',
      barcode: '3747766355',
      name: 'Nước mắm Nam Ngư',
      price: 28000,
      quantity: 45,
      category: 'Gia vị',
      description: 'Nước mắm Nam Ngư 500ml',
    ),
    Product(
      id: '7',
      barcode: '7455289403',
      name: 'Gạo ST25',
      price: 120000,
      quantity: 20,
      category: 'Thực phẩm',
      description: 'Gạo ST25 túi 5kg',
    ),
    Product(
      id: '8',
      barcode: '6399475267',
      name: 'Coca Cola',
      price: 12000,
      quantity: 100,
      category: 'Đồ uống',
      description: 'Coca Cola lon 330ml',
    ),
  ];

  List<Product> get products => List.unmodifiable(_products);

  int get totalProducts => _products.length;

  int get lowStockCount => _products.where((p) => p.quantity < 10).length;

  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Product> getByCategory(String category) {
    if (category.isEmpty) return _products;
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> getLowStockProducts({int threshold = 10}) {
    return _products.where((p) => p.quantity < threshold).toList();
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updateStock(String id, int newQuantity) {
    final product = getById(id);
    if (product != null) {
      product.quantity = newQuantity;
      notifyListeners();
    }
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
