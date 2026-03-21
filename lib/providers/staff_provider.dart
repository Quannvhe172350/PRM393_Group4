import 'package:flutter/material.dart';
import '../db/app_database.dart';
import '../models/manager.dart';
import '../models/cashier.dart';

/// Provider quản lý nhân sự: Managers + Cashiers
class StaffProvider extends ChangeNotifier {
  List<Manager> _managers = [];
  List<Cashier> _cashiers = [];
  bool _isLoading = false;

  List<Manager> get managers => _managers;
  List<Cashier> get cashiers => _cashiers;
  bool get isLoading => _isLoading;
  int get totalStaff => _managers.length + _cashiers.length;

  double get totalSalary {
    double sum = 0;
    for (final m in _managers) {
      sum += m.salary ?? 0;
    }
    for (final c in _cashiers) {
      sum += c.salary ?? 0;
    }
    return sum;
  }

  StaffProvider() {
    // Để cho UI gọi load dữ liệu khi cần
  }

  Future<void> loadStaff() async {
    _isLoading = true;
    notifyListeners();
    try {
      _managers = await AppDatabase.instance.getManagers();
      _cashiers = await AppDatabase.instance.getCashiers();
    } catch (e) {
      debugPrint('Error loading staff: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Tìm kiếm trong cả managers + cashiers
  List<dynamic> searchStaff(String query) {
    if (query.isEmpty) return [..._managers, ..._cashiers];
    final q = query.toLowerCase();
    final List<dynamic> results = [];
    results.addAll(_managers.where((m) =>
        m.name.toLowerCase().contains(q) || m.email.toLowerCase().contains(q)));
    results.addAll(_cashiers.where((c) =>
        c.name.toLowerCase().contains(q) || c.email.toLowerCase().contains(q)));
    return results;
  }

  // ── Manager CRUD ──
  Future<void> addManager(Manager manager) async {
    await AppDatabase.instance.insertManager(manager);
    await loadStaff();
  }

  Future<void> updateManager(Manager manager) async {
    await AppDatabase.instance.updateManager(manager);
    await loadStaff();
  }

  Future<void> deleteManager(int id) async {
    await AppDatabase.instance.deleteManager(id);
    await loadStaff();
  }

  // ── Cashier CRUD ──
  Future<void> addCashier(Cashier cashier) async {
    await AppDatabase.instance.insertCashier(cashier);
    await loadStaff();
  }

  Future<void> updateCashier(Cashier cashier) async {
    await AppDatabase.instance.updateCashier(cashier);
    await loadStaff();
  }

  Future<void> deleteCashier(int id) async {
    await AppDatabase.instance.deleteCashier(id);
    await loadStaff();
  }
}
