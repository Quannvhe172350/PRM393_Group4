import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeProvider extends ChangeNotifier {
  final List<Employee> _employees = [
    Employee(id: '1', name: 'Nguyễn Văn Minh', email: 'minh@supermarket.com', phone: '0901234567', role: 'Quản lý', salary: 15000000),
    Employee(id: '2', name: 'Trần Thị Hoa', email: 'hoa@supermarket.com', phone: '0912345678', role: 'Thu ngân', salary: 8000000),
    Employee(id: '3', name: 'Lê Hoàng Nam', email: 'nam@supermarket.com', phone: '0923456789', role: 'Nhân viên kho', salary: 7500000),
    Employee(id: '4', name: 'Phạm Thị Lan', email: 'lan@supermarket.com', phone: '0934567890', role: 'Thu ngân', salary: 8000000),
    Employee(id: '5', name: 'Võ Đức Thắng', email: 'thang@supermarket.com', phone: '0945678901', role: 'Bảo vệ', salary: 6500000),
  ];

  List<Employee> get employees => List.unmodifiable(_employees);

  int get totalEmployees => _employees.length;

  double get totalSalary => _employees.fold(0.0, (sum, e) => sum + e.salary);

  Employee? getById(String id) {
    try {
      return _employees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Employee> searchEmployees(String query) {
    if (query.isEmpty) return _employees;
    return _employees
        .where((e) => e.name.toLowerCase().contains(query.toLowerCase()) ||
                       e.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void updateEmployee(Employee employee) {
    final index = _employees.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      _employees[index] = employee;
      notifyListeners();
    }
  }

  void deleteEmployee(String id) {
    _employees.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
