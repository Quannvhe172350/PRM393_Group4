import 'package:flutter/material.dart';
import '../models/supplier.dart';

class SupplierProvider extends ChangeNotifier {
  final List<Supplier> _suppliers = [
    Supplier(id: '1', name: 'Vinamilk', contactPerson: 'Nguyễn Thanh Tùng', phone: '028 38 255 555', email: 'contact@vinamilk.com', address: 'TP. Hồ Chí Minh'),
    Supplier(id: '2', name: 'Vissan', contactPerson: 'Trần Minh Đức', phone: '028 38 163 628', email: 'info@vissan.com.vn', address: 'TP. Hồ Chí Minh'),
    Supplier(id: '3', name: 'Masan Consumer', contactPerson: 'Phạm Hồng Sơn', phone: '028 62 563 862', email: 'info@masanconsumer.com', address: 'TP. Hồ Chí Minh'),
    Supplier(id: '4', name: 'TH True Milk', contactPerson: 'Lê Thị Mai', phone: '024 32 188 222', email: 'info@thtruemilk.vn', address: 'Nghệ An'),
  ];

  List<Supplier> get suppliers => List.unmodifiable(_suppliers);

  int get totalSuppliers => _suppliers.length;

  Supplier? getById(String id) {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Supplier> searchSuppliers(String query) {
    if (query.isEmpty) return _suppliers;
    return _suppliers
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()) ||
                       s.contactPerson.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void addSupplier(Supplier supplier) {
    _suppliers.add(supplier);
    notifyListeners();
  }

  void updateSupplier(Supplier supplier) {
    final index = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      _suppliers[index] = supplier;
      notifyListeners();
    }
  }

  void deleteSupplier(String id) {
    _suppliers.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
