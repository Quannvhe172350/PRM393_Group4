import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' hide Category;

import '../models/cashier.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/manager.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../models/supplier_product.dart';
import '../models/user.dart';
import '../models/purchase_order.dart';

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  static const _dbName = 'supermarket.db';
  static const _dbVersion = 3;

  static const tableUsers = 'users';
  static const tableCustomers = 'customers';
  static const tableManagers = 'managers';
  static const tableCashiers = 'cashiers';
  static const tableCategories = 'categories';
  static const tableProducts = 'products';
  static const tableSuppliers = 'suppliers';
  static const tableOrders = 'orders';
  static const tableOrderItems = 'order_items';
  static const tableSupplierProducts = 'supplier_products';
  static const tablePurchaseOrders = 'purchase_orders';
  static const tablePurchaseOrderItems = 'purchase_order_items';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ═══════════════════════════════
  //  SCHEMA UPGRADE
  // ═══════════════════════════════
  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tablePurchaseOrders (
          id TEXT PRIMARY KEY,
          supplier_id INTEGER NOT NULL,
          order_date TEXT NOT NULL,
          total_amount REAL NOT NULL DEFAULT 0,
          status TEXT NOT NULL DEFAULT 'pending',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (supplier_id) REFERENCES $tableSuppliers (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tablePurchaseOrderItems (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          po_id TEXT NOT NULL,
          product_id INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          subtotal REAL NOT NULL,
          FOREIGN KEY (po_id) REFERENCES $tablePurchaseOrders (id) ON DELETE CASCADE,
          FOREIGN KEY (product_id) REFERENCES $tableProducts (id) ON DELETE RESTRICT
        )
      ''');
      await _seedSupplierData(db);
    }
  }

  // ═══════════════════════════════
  //  SCHEMA CREATION
  // ═══════════════════════════════
  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE $tableUsers (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE, phone TEXT NOT NULL,
      password TEXT NOT NULL DEFAULT '', role TEXT NOT NULL DEFAULT 'staff',
      created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableCustomers (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      email TEXT, phone TEXT NOT NULL, address TEXT,
      loyalty_points INTEGER NOT NULL DEFAULT 0, membership_date TEXT NOT NULL,
      created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableManagers (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE, phone TEXT NOT NULL,
      password TEXT NOT NULL DEFAULT '', department TEXT,
      salary REAL, hire_date TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableCashiers (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE, phone TEXT NOT NULL,
      password TEXT NOT NULL DEFAULT '', counter_number INTEGER,
      shift TEXT NOT NULL DEFAULT 'morning', salary REAL, hire_date TEXT,
      created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableCategories (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE,
      description TEXT, created_at TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableProducts (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      description TEXT, price REAL NOT NULL, quantity INTEGER NOT NULL DEFAULT 0,
      category_id INTEGER, image_url TEXT, barcode TEXT UNIQUE,
      created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES $tableCategories (id) ON DELETE SET NULL)''');

    await db.execute('''CREATE TABLE $tableSuppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      email TEXT, phone TEXT, address TEXT, created_at TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableOrders (
      id INTEGER PRIMARY KEY AUTOINCREMENT, customer_id INTEGER, cashier_id INTEGER,
      order_date TEXT NOT NULL, total_amount REAL NOT NULL DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'pending', created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
      FOREIGN KEY (customer_id) REFERENCES $tableCustomers (id) ON DELETE SET NULL,
      FOREIGN KEY (cashier_id) REFERENCES $tableCashiers (id) ON DELETE SET NULL)''');

    await db.execute('''CREATE TABLE $tableOrderItems (
      id INTEGER PRIMARY KEY AUTOINCREMENT, order_id INTEGER NOT NULL,
      product_id INTEGER NOT NULL, quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL, subtotal REAL NOT NULL,
      FOREIGN KEY (order_id) REFERENCES $tableOrders (id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES $tableProducts (id) ON DELETE RESTRICT)''');

    await db.execute('''CREATE TABLE $tablePurchaseOrders (
      id TEXT PRIMARY KEY, supplier_id INTEGER NOT NULL,
      order_date TEXT NOT NULL, total_amount REAL NOT NULL DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'pending', created_at TEXT NOT NULL, updated_at TEXT NOT NULL,
      FOREIGN KEY (supplier_id) REFERENCES $tableSuppliers (id) ON DELETE CASCADE)''');

    await db.execute('''CREATE TABLE $tablePurchaseOrderItems (
      id INTEGER PRIMARY KEY AUTOINCREMENT, po_id TEXT NOT NULL,
      product_id INTEGER NOT NULL, quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL, subtotal REAL NOT NULL,
      FOREIGN KEY (po_id) REFERENCES $tablePurchaseOrders (id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES $tableProducts (id) ON DELETE RESTRICT)''');

    await db.execute('''CREATE TABLE $tableSupplierProducts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      supplier_id INTEGER NOT NULL, product_id INTEGER NOT NULL,
      supply_price REAL NOT NULL, last_supply_date TEXT,
      FOREIGN KEY (supplier_id) REFERENCES $tableSuppliers (id) ON DELETE CASCADE,
      FOREIGN KEY (product_id) REFERENCES $tableProducts (id) ON DELETE CASCADE)''');

    await _seedData(db);
  }

  // ═══════════════════════════════
  //  SEED DATA
  // ═══════════════════════════════
  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert(tableUsers, {'name': 'Admin', 'email': 'admin@supermarket.com', 'phone': '0900000000', 'password': '123456', 'role': 'admin', 'created_at': now, 'updated_at': now});
    await db.insert(tableUsers, {'name': 'Nguyen Van A', 'email': 'a@example.com', 'phone': '0900000001', 'password': '123456', 'role': 'staff', 'created_at': now, 'updated_at': now});

    await db.insert(tableManagers, {'name': 'Tran Thi B', 'email': 'b@supermarket.com', 'phone': '0900000002', 'password': '123456', 'department': 'Quản lý chung', 'salary': 20000000.0, 'hire_date': '2023-01-15', 'created_at': now, 'updated_at': now});

    await db.insert(tableCashiers, {'name': 'Nguyen Thi K', 'email': 'k@supermarket.com', 'phone': '0911000001', 'password': '123456', 'counter_number': 1, 'shift': 'morning', 'salary': 10000000.0, 'hire_date': '2024-03-01', 'created_at': now, 'updated_at': now});

    await db.insert(tableCustomers, {'name': 'Pham Van D', 'email': 'pvd@gmail.com', 'phone': '0912345678', 'address': 'Quận 1, TP.HCM', 'loyalty_points': 150, 'membership_date': now, 'created_at': now, 'updated_at': now});
    await db.insert(tableCustomers, {'name': 'Hoang Thi E', 'email': 'hte@gmail.com', 'phone': '0987654321', 'address': 'Quận 3, TP.HCM', 'loyalty_points': 80, 'membership_date': now, 'created_at': now, 'updated_at': now});

    await db.insert(tableCategories, {'name': 'Thực phẩm', 'description': 'Đồ ăn', 'created_at': now});
    await db.insert(tableCategories, {'name': 'Đồ uống', 'description': 'Nước giải khát', 'created_at': now});
    await db.insert(tableCategories, {'name': 'Đồ gia dụng', 'description': 'Dụng cụ nhà bếp', 'created_at': now});
    await db.insert(tableCategories, {'name': 'Bánh kẹo', 'description': 'Bánh, kẹo, snack', 'created_at': now});
    await db.insert(tableCategories, {'name': 'Chăm sóc cá nhân', 'description': 'Dầu gội, sữa tắm', 'created_at': now});

    await db.insert(tableProducts, {'name': 'Gạo ST25', 'price': 120000.0, 'quantity': 50, 'category_id': 1, 'barcode': '8934563001001', 'created_at': now, 'updated_at': now});
    await db.insert(tableProducts, {'name': 'Mì Hảo Hảo', 'price': 4000.0, 'quantity': 200, 'category_id': 1, 'barcode': '8934563001002', 'created_at': now, 'updated_at': now});
    await db.insert(tableProducts, {'name': 'Coca Cola 330ml', 'price': 10000.0, 'quantity': 150, 'category_id': 2, 'barcode': '8934563001003', 'created_at': now, 'updated_at': now});
    await db.insert(tableProducts, {'name': 'Sữa Vinamilk 1L', 'price': 32000.0, 'quantity': 80, 'category_id': 2, 'barcode': '8934563001004', 'created_at': now, 'updated_at': now});
    await db.insert(tableProducts, {'name': 'Nước rửa chén Sunlight', 'price': 28000.0, 'quantity': 60, 'category_id': 3, 'barcode': '8934563001005', 'created_at': now, 'updated_at': now});
    await db.insert(tableProducts, {'name': 'Bánh Oreo', 'price': 18000.0, 'quantity': 100, 'category_id': 4, 'barcode': '8934563001006', 'created_at': now, 'updated_at': now});
    await db.insert(tableProducts, {'name': 'Dầu gội Clear', 'price': 95000.0, 'quantity': 40, 'category_id': 5, 'barcode': '8934563001007', 'created_at': now, 'updated_at': now});
    await db.insert(tableProducts, {'name': 'Trứng gà (vỉ 10)', 'price': 35000.0, 'quantity': 70, 'category_id': 1, 'barcode': '8934563001008', 'created_at': now, 'updated_at': now});
    await db.insert(tableProducts, {'name': 'Pepsi 1.5L', 'price': 15000.0, 'quantity': 90, 'category_id': 2, 'barcode': '8934563001009', 'created_at': now, 'updated_at': now});
    await db.insert(tableProducts, {'name': 'Kem đánh răng P/S', 'price': 30000.0, 'quantity': 55, 'category_id': 5, 'barcode': '8934563001010', 'created_at': now, 'updated_at': now});

    await _seedSupplierData(db);

    await db.insert(tableSupplierProducts, {'supplier_id': 1, 'product_id': 4, 'supply_price': 28000.0, 'last_supply_date': now});
    await db.insert(tableSupplierProducts, {'supplier_id': 2, 'product_id': 3, 'supply_price': 7500.0, 'last_supply_date': now});
    await db.insert(tableSupplierProducts, {'supplier_id': 3, 'product_id': 5, 'supply_price': 22000.0, 'last_supply_date': now});
  }

  Future<void> _seedSupplierData(Database db) async {
    final now = DateTime.now().toIso8601String();
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableSuppliers')) ?? 0;
    if (count == 0) {
      await db.insert(tableSuppliers, {'name': 'Vinamilk', 'email': 'contact@vinamilk.com', 'phone': '02838155555', 'address': 'Quận 7, TP.HCM', 'created_at': now});
      await db.insert(tableSuppliers, {'name': 'Coca-Cola Vietnam', 'email': 'info@coca-cola.vn', 'phone': '02838221234', 'address': 'Quận 2, TP.HCM', 'created_at': now});
      await db.insert(tableSuppliers, {'name': 'Unilever Vietnam', 'email': 'contact@unilever.vn', 'phone': '02838234567', 'address': 'Quận 1, TP.HCM', 'created_at': now});
      await db.insert(tableSuppliers, {'name': 'Acecook Vietnam', 'email': 'info@acecook.vn', 'phone': '02838345678', 'address': 'Quận Bình Tân, TP.HCM', 'created_at': now});
    }
  }

  // ═══════════════════════════════
  //  USER CRUD
  // ═══════════════════════════════
  Future<List<User>> getUsers() async {
    final db = await database;
    return (await db.query(tableUsers, orderBy: 'name')).map((e) => User.fromMap(e)).toList();
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(tableUsers, where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(tableUsers, where: 'email = ?', whereArgs: [email], limit: 1);
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }

  Future<User?> authenticate(String email, String password) async {
    final db = await database;
    final maps = await db.query(tableUsers, where: 'email = ? AND password = ?', whereArgs: [email, password], limit: 1);
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }

  Future<int> insertUser(User user) async => (await database).insert(tableUsers, user.toMap());

  Future<int> updateUser(User user) async {
    final db = await database;
    final map = user.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableUsers, map, where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async => (await database).delete(tableUsers, where: 'id = ?', whereArgs: [id]);

  // ═══════════════════════════════
  //  CUSTOMER CRUD
  // ═══════════════════════════════
  Future<List<Customer>> getCustomers() async {
    final db = await database;
    return (await db.query(tableCustomers, orderBy: 'name')).map((e) => Customer.fromMap(e)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final maps = await db.query(tableCustomers, where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isEmpty ? null : Customer.fromMap(maps.first);
  }

  Future<Customer?> getCustomerByPhone(String phone) async {
    final db = await database;
    final maps = await db.query(tableCustomers, where: 'phone = ?', whereArgs: [phone], limit: 1);
    return maps.isEmpty ? null : Customer.fromMap(maps.first);
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await database;
    return (await db.query(tableCustomers, where: 'name LIKE ? OR phone LIKE ?', whereArgs: ['%$query%', '%$query%'], orderBy: 'name')).map((e) => Customer.fromMap(e)).toList();
  }

  Future<int> insertCustomer(Customer customer) async => (await database).insert(tableCustomers, customer.toMap());

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    final map = customer.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableCustomers, map, where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<int> updateCustomerLoyaltyPoints(int customerId, int points) async {
    final db = await database;
    return db.rawUpdate('UPDATE $tableCustomers SET loyalty_points = loyalty_points + ?, updated_at = ? WHERE id = ?', [points, DateTime.now().toIso8601String(), customerId]);
  }

  Future<int> deleteCustomer(int id) async => (await database).delete(tableCustomers, where: 'id = ?', whereArgs: [id]);

  // ═══════════════════════════════
  //  MANAGER CRUD
  // ═══════════════════════════════
  Future<List<Manager>> getManagers() async {
    final db = await database;
    return (await db.query(tableManagers, orderBy: 'name')).map((e) => Manager.fromMap(e)).toList();
  }

  Future<Manager?> getManagerById(int id) async {
    final db = await database;
    final maps = await db.query(tableManagers, where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isEmpty ? null : Manager.fromMap(maps.first);
  }

  Future<Manager?> authenticateManager(String email, String password) async {
    final db = await database;
    final maps = await db.query(tableManagers, where: 'email = ? AND password = ?', whereArgs: [email, password], limit: 1);
    return maps.isEmpty ? null : Manager.fromMap(maps.first);
  }

  Future<int> insertManager(Manager manager) async => (await database).insert(tableManagers, manager.toMap());

  Future<int> updateManager(Manager manager) async {
    final db = await database;
    final map = manager.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableManagers, map, where: 'id = ?', whereArgs: [manager.id]);
  }

  Future<int> deleteManager(int id) async => (await database).delete(tableManagers, where: 'id = ?', whereArgs: [id]);

  // ═══════════════════════════════
  //  CASHIER CRUD
  // ═══════════════════════════════
  Future<List<Cashier>> getCashiers() async {
    final db = await database;
    return (await db.query(tableCashiers, orderBy: 'name')).map((e) => Cashier.fromMap(e)).toList();
  }

  Future<Cashier?> getCashierById(int id) async {
    final db = await database;
    final maps = await db.query(tableCashiers, where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isEmpty ? null : Cashier.fromMap(maps.first);
  }

  Future<List<Cashier>> getCashiersByShift(String shift) async {
    final db = await database;
    return (await db.query(tableCashiers, where: 'shift = ?', whereArgs: [shift], orderBy: 'counter_number')).map((e) => Cashier.fromMap(e)).toList();
  }

  Future<Cashier?> authenticateCashier(String email, String password) async {
    final db = await database;
    final maps = await db.query(tableCashiers, where: 'email = ? AND password = ?', whereArgs: [email, password], limit: 1);
    return maps.isEmpty ? null : Cashier.fromMap(maps.first);
  }

  Future<int> insertCashier(Cashier cashier) async => (await database).insert(tableCashiers, cashier.toMap());

  Future<int> updateCashier(Cashier cashier) async {
    final db = await database;
    final map = cashier.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableCashiers, map, where: 'id = ?', whereArgs: [cashier.id]);
  }

  Future<int> deleteCashier(int id) async => (await database).delete(tableCashiers, where: 'id = ?', whereArgs: [id]);

  // ═══════════════════════════════
  //  CATEGORY CRUD
  // ═══════════════════════════════
  Future<List<Category>> getCategories() async {
    final db = await database;
    return (await db.query(tableCategories, orderBy: 'name')).map((e) => Category.fromMap(e)).toList();
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final maps = await db.query(tableCategories, where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isEmpty ? null : Category.fromMap(maps.first);
  }

  Future<int> insertCategory(Category category) async => (await database).insert(tableCategories, category.toMap());

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return db.update(tableCategories, category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async => (await database).delete(tableCategories, where: 'id = ?', whereArgs: [id]);

  // ═══════════════════════════════
  //  PRODUCT CRUD
  // ═══════════════════════════════
  Future<List<Product>> getProducts() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name
      FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      ORDER BY p.name
    ''');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      WHERE p.id = ? LIMIT 1
    ''', [id]);
    return maps.isEmpty ? null : Product.fromMap(maps.first);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      WHERE p.barcode = ? LIMIT 1
    ''', [barcode]);
    return maps.isEmpty ? null : Product.fromMap(maps.first);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      WHERE p.name LIKE ? OR p.barcode LIKE ? ORDER BY p.name
    ''', ['%$query%', '%$query%']);
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      WHERE p.quantity <= ? ORDER BY p.quantity ASC
    ''', [threshold]);
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> insertProduct(Product product) async => (await database).insert(tableProducts, product.toMap());

  Future<int> updateProduct(Product product) async {
    final db = await database;
    final map = product.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableProducts, map, where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> updateProductQuantity(int productId, int newQuantity) async {
    final db = await database;
    return db.update(tableProducts, {'quantity': newQuantity, 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [productId]);
  }

  Future<int> deleteProduct(int id) async => (await database).delete(tableProducts, where: 'id = ?', whereArgs: [id]);

  // ═══════════════════════════════
  //  SUPPLIER CRUD
  // ═══════════════════════════════
  Future<List<Supplier>> getSuppliers() async {
    final db = await database;
    return (await db.query(tableSuppliers, orderBy: 'name')).map((e) => Supplier.fromMap(e)).toList();
  }

  Future<Supplier?> getSupplierById(int id) async {
    final db = await database;
    final maps = await db.query(tableSuppliers, where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isEmpty ? null : Supplier.fromMap(maps.first);
  }

  Future<int> insertSupplier(Supplier supplier) async => (await database).insert(tableSuppliers, supplier.toMap());

  Future<int> updateSupplier(Supplier supplier) async {
    final db = await database;
    return db.update(
      tableSuppliers,
      {
        'name': supplier.name,
        'phone': supplier.phone,
        'email': supplier.email,
        'address': supplier.address,
      },
      where: 'id = ?',
      whereArgs: [int.tryParse(supplier.id)],
    );
  }

  Future<int> deleteSupplier(int id) async => (await database).delete(tableSuppliers, where: 'id = ?', whereArgs: [id]);

  // ═══════════════════════════════
  //  ORDER CRUD
  // ═══════════════════════════════
  Future<List<Order>> getOrders() async {
    final db = await database;
    return (await db.query(tableOrders, orderBy: 'order_date DESC')).map((e) => Order.fromMap(e)).toList();
  }

  Future<Order?> getOrderById(int id) async {
    final db = await database;
    final maps = await db.query(tableOrders, where: 'id = ?', whereArgs: [id], limit: 1);
    return maps.isEmpty ? null : Order.fromMap(maps.first);
  }

  Future<int> insertOrder(Order order) async => (await database).insert(tableOrders, order.toMap());

  Future<int> insertOrderItem(OrderItem item) async => (await database).insert(tableOrderItems, item.toMap());

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await database;
    return (await db.query(tableOrderItems, where: 'order_id = ?', whereArgs: [orderId])).map((e) => OrderItem.fromMap(e)).toList();
  }

  Future<int> updateOrder(Order order) async {
    final db = await database;
    final map = order.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableOrders, map, where: 'id = ?', whereArgs: [order.id]);
  }

  Future<int> deleteOrder(int id) async => (await database).delete(tableOrders, where: 'id = ?', whereArgs: [id]);

  // ═══════════════════════════════
  //  PURCHASE ORDER CRUD
  // ═══════════════════════════════

  /// Returns List<PurchaseOrder> for a given supplier.
  /// Called from supplier_detail_screen.dart as: getPurchaseOrders(supplierId: ...)
  Future<List<PurchaseOrder>> getPurchaseOrders({required int supplierId}) async {
    final db = await database;
    final maps = await db.query(tablePurchaseOrders, where: 'supplier_id = ?', whereArgs: [supplierId], orderBy: 'created_at DESC');
    return maps.map((m) => PurchaseOrder.fromMap(m)).toList();
  }

  /// Called from create_purchase_order_screen.dart as: insertPurchaseOrder(poMap, items)
  Future<int> insertPurchaseOrder(Map<String, dynamic> poMap, List<Map<String, dynamic>> items) async {
    final db = await database;
    return await db.transaction((txn) async {
      final res = await txn.insert(tablePurchaseOrders, poMap);
      for (var item in items) {
        await txn.insert(tablePurchaseOrderItems, item);
      }
      return res;
    });
  }

  Future<int> updatePurchaseOrderStatus(String poId, String status) async {
    final db = await database;
    return db.update(tablePurchaseOrders, {'status': status, 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [poId]);
  }

  /// Cập nhật catalog: đặt giá và số lượng tồn kho mới cho sản phẩm.
  /// Gọi từ supplier_detail_screen khi nhấn "Lưu" trong dialog Cập nhật Catalog.
  Future<int> updateSupplierProductCatalog(int supplierId, int productId, {double? price, int? quantity}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // Cập nhật giá và số lượng trong bảng products
    if (price != null && quantity != null) {
      await db.update(
        tableProducts,
        {'price': price, 'quantity': quantity, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [productId],
      );
    } else if (price != null) {
      await db.update(tableProducts, {'price': price, 'updated_at': now}, where: 'id = ?', whereArgs: [productId]);
    } else if (quantity != null) {
      await db.update(tableProducts, {'quantity': quantity, 'updated_at': now}, where: 'id = ?', whereArgs: [productId]);
    }

    // Cập nhật hoặc thêm mới vào bảng supplier_products (giá nhập của nhà cung cấp)
    if (price != null) {
      final exists = await db.query(tableSupplierProducts,
          where: 'supplier_id = ? AND product_id = ?', whereArgs: [supplierId, productId]);
      if (exists.isNotEmpty) {
        return db.update(
          tableSupplierProducts,
          {'supply_price': price, 'last_supply_date': now},
          where: 'supplier_id = ? AND product_id = ?',
          whereArgs: [supplierId, productId],
        );
      } else {
        return db.insert(tableSupplierProducts, {
          'supplier_id': supplierId,
          'product_id': productId,
          'supply_price': price,
          'last_supply_date': now,
        });
      }
    }
    return 0;
  }

  // ═══════════════════════════════
  //  STATS / REPORTS
  // ═══════════════════════════════
  Future<int> getTotalOrdersCount() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableOrders')) ?? 0;
  }

  Future<double> getTotalRevenue() async {
    final db = await database;
    final res = await db.rawQuery("SELECT SUM(total_amount) as total FROM $tableOrders WHERE status = 'completed'");
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
