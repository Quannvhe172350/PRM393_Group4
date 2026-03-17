import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final List<Category> _categories = [
    Category(id: '1', name: 'Đồ uống', description: 'Nước giải khát, sữa, nước ép'),
    Category(id: '2', name: 'Bánh', description: 'Bánh mì, bánh ngọt, bánh snack'),
    Category(id: '3', name: 'Trái cây', description: 'Trái cây tươi trong và ngoài nước'),
    Category(id: '4', name: 'Thực phẩm', description: 'Thực phẩm khô, đông lạnh'),
    Category(id: '5', name: 'Gia vị', description: 'Nước mắm, muối, đường, bột ngọt'),
    Category(id: '6', name: 'Đồ dùng', description: 'Đồ dùng gia đình, vệ sinh'),
  ];

  List<Category> get categories => List.unmodifiable(_categories);

  int get totalCategories => _categories.length;

  Category? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
