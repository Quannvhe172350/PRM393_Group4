import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../db/app_database.dart';

class SupplierProvider with ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;
  List<Supplier> _suppliers = [];
  bool _isLoading = false;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;

  Future<void> fetchSuppliers() async {
    _isLoading = true;
    notifyListeners();
    _suppliers = await _db.getSuppliers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _db.insertSupplier(supplier);
    await fetchSuppliers();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _db.updateSupplier(supplier);
    await fetchSuppliers();
  }

  int get totalSuppliers => _suppliers.length;

  String generateId() {
    return (DateTime.now().millisecondsSinceEpoch % 100000).toString();
  }

  Future<void> deleteSupplier(String id) async {
    await _db.deleteSupplier(int.parse(id));
    await fetchSuppliers();
  }

  List<Supplier> searchSuppliers(String query) {
    if (query.isEmpty) return _suppliers;
    return _suppliers
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
