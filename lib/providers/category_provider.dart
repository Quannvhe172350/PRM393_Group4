import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  int get totalCategories => _categories.length;

  CategoryProvider() {
    // Để cho UI gọi load dữ liệu khi cần
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await AppDatabase.instance.getCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Category? getById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addCategory(Category category) async {
    await AppDatabase.instance.insertCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await AppDatabase.instance.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await AppDatabase.instance.deleteCategory(id);
    await loadCategories();
  }
}
