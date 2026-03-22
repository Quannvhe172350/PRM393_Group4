import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/manager.dart';
import '../models/supplier.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  Manager? _currentManager;
  Supplier? _currentSupplier;

  User? get currentUser => _currentUser;
  Manager? get currentManager => _currentManager;
  Supplier? get currentSupplier => _currentSupplier;

  void loginAsUser(User user) {
    _currentUser = user;
    _currentManager = null;
    _currentSupplier = null;
    notifyListeners();
  }

  void loginAsManager(Manager manager) {
    _currentUser = null;
    _currentManager = manager;
    _currentSupplier = null;
    notifyListeners();
  }

  void loginAsSupplier(Supplier supplier) {
    _currentUser = null;
    _currentManager = null;
    _currentSupplier = supplier;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _currentManager = null;
    _currentSupplier = null;
    notifyListeners();
  }
}
