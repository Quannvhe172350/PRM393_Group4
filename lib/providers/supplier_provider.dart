import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/supplier.dart';

class SupplierProvider extends ChangeNotifier {
  List<Supplier> _suppliers = [];
  bool _isLoading = false;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  int get totalSuppliers => _suppliers.length;

  SupplierProvider() {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _suppliers = await AppDatabase.instance.getSuppliers();
    } catch (e) {
      debugPrint('Error loading suppliers: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  List<Supplier> searchSuppliers(String query) {
    if (query.isEmpty) return _suppliers;
    return _suppliers
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()) ||
            (s.email?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (s.phone?.contains(query) ?? false))
        .toList();
  }

  Future<void> addSupplier(Supplier supplier) async {
    await AppDatabase.instance.insertSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await AppDatabase.instance.updateSupplier(supplier);
    await loadSuppliers();
  }

  Future<void> deleteSupplier(int id) async {
    await AppDatabase.instance.deleteSupplier(id);
    await loadSuppliers();
  }
}
