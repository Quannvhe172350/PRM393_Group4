import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.quantity < 10).length;

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await AppDatabase.instance.getProducts();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Product? getById(int id) {
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

  List<Product> getByCategory(int categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  List<Product> getLowStockProducts({int threshold = 10}) {
    return _products.where((p) => p.quantity < threshold).toList();
  }

  Future<void> addProduct(Product product) async {
    await AppDatabase.instance.insertProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await AppDatabase.instance.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await AppDatabase.instance.deleteProduct(id);
    await loadProducts();
  }

  Future<void> updateStock(int productId, int newQuantity) async {
    await AppDatabase.instance.updateProductQuantity(productId, newQuantity);
    await loadProducts();
  }
}
