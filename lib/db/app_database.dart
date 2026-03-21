import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cashier.dart';
import '../models/category.dart';
import '../models/customer.dart';
import '../models/manager.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../models/purchase_order.dart';
import '../models/supplier.dart';
import '../models/supplier_product.dart';
import '../models/user.dart';

class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  static const _dbName = 'supermarket.db';
  static const _dbVersion = 4;

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

  // ═══════════════════════════════════════════════════════════════════
  //  SCHEMA CREATION
  // ═══════════════════════════════════════════════════════════════════

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Thêm cột password cho bảng customers
      await db.execute("ALTER TABLE $tableCustomers ADD COLUMN password TEXT NOT NULL DEFAULT ''");
    }
    if (oldVersion < 4) {
      // Thêm tài khoản nhân viên Demo
      await db.insert(tableUsers, {
        'name': 'Nhân viên Demo',
        'email': 'staff@supermarket.com',
        'phone': '0900000011',
        'password': '123456',
        'role': 'staff',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String()
      });
    }
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    // ── Users (admin / general staff) ──
    await db.execute('''
      CREATE TABLE $tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL DEFAULT '',
        role TEXT NOT NULL DEFAULT 'staff',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ── Customers ──
    await db.execute('''
      CREATE TABLE $tableCustomers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT NOT NULL,
        password TEXT NOT NULL DEFAULT '',
        address TEXT,
        loyalty_points INTEGER NOT NULL DEFAULT 0,
        membership_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ── Managers ──
    await db.execute('''
      CREATE TABLE $tableManagers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL DEFAULT '',
        department TEXT,
        salary REAL,
        hire_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ── Cashiers ──
    await db.execute('''
      CREATE TABLE $tableCashiers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL DEFAULT '',
        counter_number INTEGER,
        shift TEXT NOT NULL DEFAULT 'morning',
        salary REAL,
        hire_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ── Categories ──
    await db.execute('''
      CREATE TABLE $tableCategories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // ── Products ──
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        category_id INTEGER,
        image_url TEXT,
        barcode TEXT UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES $tableCategories (id)
          ON DELETE SET NULL
      )
    ''');

    // ── Suppliers ──
    await db.execute('''
      CREATE TABLE $tableSuppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // ── Orders ──
    await db.execute('''
      CREATE TABLE $tableOrders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        cashier_id INTEGER,
        order_date TEXT NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES $tableCustomers (id)
          ON DELETE SET NULL,
        FOREIGN KEY (cashier_id) REFERENCES $tableCashiers (id)
          ON DELETE SET NULL
      )
    ''');

    // ── Order Items ──
    await db.execute('''
      CREATE TABLE $tableOrderItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES $tableOrders (id)
          ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES $tableProducts (id)
          ON DELETE RESTRICT
      )
    ''');

    // ── Supplier-Product ──
    await db.execute('''
      CREATE TABLE $tableSupplierProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplier_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        supply_price REAL NOT NULL,
        last_supply_date TEXT,
        FOREIGN KEY (supplier_id) REFERENCES $tableSuppliers (id)
          ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES $tableProducts (id)
          ON DELETE CASCADE
      )
    ''');

    // ── Purchase Orders ──
    await db.execute('''
      CREATE TABLE $tablePurchaseOrders (
        id TEXT PRIMARY KEY,
        supplier_id INTEGER NOT NULL,
        order_date TEXT NOT NULL,
        total_amount REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (supplier_id) REFERENCES $tableSuppliers (id)
          ON DELETE CASCADE
      )
    ''');

    // ── Purchase Order Items ──
    await db.execute('''
      CREATE TABLE $tablePurchaseOrderItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        po_id TEXT NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (po_id) REFERENCES $tablePurchaseOrders (id)
          ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES $tableProducts (id)
          ON DELETE RESTRICT
      )
    ''');

    await _seedData(db);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SEED DATA
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // ── Users ──
    final users = [
      {'name': 'Admin', 'email': 'admin@supermarket.com', 'phone': '0900000000', 'password': '123456', 'role': 'admin', 'created_at': now, 'updated_at': now},
      {'name': 'Nguyen Van A', 'email': 'a@example.com', 'phone': '0900000001', 'password': '123456', 'role': 'staff', 'created_at': now, 'updated_at': now},
      {'name': 'Nhân viên Demo', 'email': 'staff@supermarket.com', 'phone': '0900000011', 'password': '123456', 'role': 'staff', 'created_at': now, 'updated_at': now},
    ];
    for (final u in users) {
      await db.insert(tableUsers, u);
    }

    // ── Customers ──
    final customers = [
      {'name': 'Pham Van D', 'email': 'pvd@gmail.com', 'phone': '0912345678', 'address': '12 Nguyễn Huệ, Quận 1, TP.HCM', 'loyalty_points': 150, 'membership_date': now, 'created_at': now, 'updated_at': now},
      {'name': 'Hoang Thi E', 'email': 'hte@gmail.com', 'phone': '0987654321', 'address': '45 Lê Lợi, Quận 3, TP.HCM', 'loyalty_points': 80, 'membership_date': now, 'created_at': now, 'updated_at': now},
      {'name': 'Vo Minh F', 'email': 'vmf@gmail.com', 'phone': '0901122334', 'address': '78 Trần Hưng Đạo, Quận 5, TP.HCM', 'loyalty_points': 0, 'membership_date': now, 'created_at': now, 'updated_at': now},
      {'name': 'Dang Thi G', 'email': 'dtg@gmail.com', 'phone': '0909988776', 'address': '100 Điện Biên Phủ, Bình Thạnh, TP.HCM', 'loyalty_points': 320, 'membership_date': now, 'created_at': now, 'updated_at': now},
      {'name': 'Bui Van H', 'phone': '0933445566', 'loyalty_points': 50, 'membership_date': now, 'created_at': now, 'updated_at': now},
    ];
    for (final c in customers) {
      await db.insert(tableCustomers, c);
    }

    // ── Managers ──
    final managers = [
      {'name': 'Tran Thi B', 'email': 'b@supermarket.com', 'phone': '0900000002', 'password': '123456', 'department': 'Quản lý chung', 'salary': 20000000.0, 'hire_date': '2023-01-15', 'created_at': now, 'updated_at': now},
      {'name': 'Le Van C', 'email': 'c@supermarket.com', 'phone': '0900000003', 'password': '123456', 'department': 'Kho hàng', 'salary': 18000000.0, 'hire_date': '2023-06-01', 'created_at': now, 'updated_at': now},
    ];
    for (final m in managers) {
      await db.insert(tableManagers, m);
    }

    // ── Cashiers ──
    final cashiers = [
      {'name': 'Nguyen Thi K', 'email': 'k@supermarket.com', 'phone': '0911000001', 'password': '123456', 'counter_number': 1, 'shift': 'morning', 'salary': 10000000.0, 'hire_date': '2024-03-01', 'created_at': now, 'updated_at': now},
      {'name': 'Pham Van L', 'email': 'l@supermarket.com', 'phone': '0911000002', 'password': '123456', 'counter_number': 2, 'shift': 'afternoon', 'salary': 10000000.0, 'hire_date': '2024-03-15', 'created_at': now, 'updated_at': now},
      {'name': 'Ho Thi M', 'email': 'm@supermarket.com', 'phone': '0911000003', 'password': '123456', 'counter_number': 3, 'shift': 'evening', 'salary': 10500000.0, 'hire_date': '2024-05-10', 'created_at': now, 'updated_at': now},
    ];
    for (final c in cashiers) {
      await db.insert(tableCashiers, c);
    }

    // ── Categories ──
    final categories = [
      {'name': 'Thực phẩm', 'description': 'Đồ ăn, thực phẩm tươi sống', 'created_at': now},
      {'name': 'Đồ uống', 'description': 'Nước ngọt, nước suối, sữa', 'created_at': now},
      {'name': 'Đồ gia dụng', 'description': 'Dụng cụ nhà bếp, vệ sinh', 'created_at': now},
      {'name': 'Bánh kẹo', 'description': 'Bánh, kẹo, snack', 'created_at': now},
      {'name': 'Chăm sóc cá nhân', 'description': 'Dầu gội, sữa tắm, kem đánh răng', 'created_at': now},
    ];
    for (final c in categories) {
      await db.insert(tableCategories, c);
    }

    // ── Products ──
    final products = [
      {'name': 'Gạo ST25', 'description': 'Gạo ST25 loại 5kg', 'price': 120000.0, 'quantity': 50, 'category_id': 1, 'barcode': '8934563001001', 'created_at': now, 'updated_at': now},
      {'name': 'Mì Hảo Hảo', 'description': 'Mì tôm chua cay', 'price': 4000.0, 'quantity': 200, 'category_id': 1, 'barcode': '8934563001002', 'created_at': now, 'updated_at': now},
      {'name': 'Coca Cola 330ml', 'description': 'Lon Coca Cola 330ml', 'price': 10000.0, 'quantity': 150, 'category_id': 2, 'barcode': '8934563001003', 'created_at': now, 'updated_at': now},
      {'name': 'Sữa Vinamilk 1L', 'description': 'Sữa tươi tiệt trùng 1 lít', 'price': 32000.0, 'quantity': 80, 'category_id': 2, 'barcode': '8934563001004', 'created_at': now, 'updated_at': now},
      {'name': 'Nước rửa chén Sunlight', 'description': 'Nước rửa chén Sunlight 750ml', 'price': 28000.0, 'quantity': 60, 'category_id': 3, 'barcode': '8934563001005', 'created_at': now, 'updated_at': now},
      {'name': 'Bánh Oreo', 'description': 'Bánh quy Oreo socola', 'price': 18000.0, 'quantity': 100, 'category_id': 4, 'barcode': '8934563001006', 'created_at': now, 'updated_at': now},
      {'name': 'Dầu gội Clear', 'description': 'Dầu gội Clear mát lạnh 650ml', 'price': 95000.0, 'quantity': 40, 'category_id': 5, 'barcode': '8934563001007', 'created_at': now, 'updated_at': now},
      {'name': 'Trứng gà (vỉ 10)', 'description': 'Trứng gà ta vỉ 10 quả', 'price': 35000.0, 'quantity': 70, 'category_id': 1, 'barcode': '8934563001008', 'created_at': now, 'updated_at': now},
      {'name': 'Pepsi 1.5L', 'description': 'Chai Pepsi 1.5 lít', 'price': 15000.0, 'quantity': 90, 'category_id': 2, 'barcode': '8934563001009', 'created_at': now, 'updated_at': now},
      {'name': 'Kem đánh răng P/S', 'description': 'Kem đánh răng P/S 180g', 'price': 30000.0, 'quantity': 55, 'category_id': 5, 'barcode': '8934563001010', 'created_at': now, 'updated_at': now},
    ];
    for (final p in products) {
      await db.insert(tableProducts, p);
    }

    // ── Suppliers ──
    final suppliers = [
      {'name': 'Vinamilk', 'email': 'contact@vinamilk.com', 'phone': '02838155555', 'address': 'Quận 7, TP.HCM', 'created_at': now},
      {'name': 'Coca-Cola Vietnam', 'email': 'info@coca-cola.vn', 'phone': '02838221234', 'address': 'Quận 2, TP.HCM', 'created_at': now},
      {'name': 'Unilever Vietnam', 'email': 'contact@unilever.vn', 'phone': '02838234567', 'address': 'Quận 1, TP.HCM', 'created_at': now},
      {'name': 'Acecook Vietnam', 'email': 'info@acecook.vn', 'phone': '02838345678', 'address': 'Quận Bình Tân, TP.HCM', 'created_at': now},
    ];
    for (final s in suppliers) {
      await db.insert(tableSuppliers, s);
    }

    // ── Supplier-Product ──
    final supplierProducts = [
      {'supplier_id': 1, 'product_id': 4, 'supply_price': 28000.0, 'last_supply_date': now},
      {'supplier_id': 2, 'product_id': 3, 'supply_price': 7500.0, 'last_supply_date': now},
      {'supplier_id': 2, 'product_id': 9, 'supply_price': 11000.0, 'last_supply_date': now},
      {'supplier_id': 3, 'product_id': 5, 'supply_price': 22000.0, 'last_supply_date': now},
      {'supplier_id': 3, 'product_id': 7, 'supply_price': 75000.0, 'last_supply_date': now},
      {'supplier_id': 3, 'product_id': 10, 'supply_price': 24000.0, 'last_supply_date': now},
      {'supplier_id': 4, 'product_id': 2, 'supply_price': 3000.0, 'last_supply_date': now},
    ];
    for (final sp in supplierProducts) {
      await db.insert(tableSupplierProducts, sp);
    }

    // ── Sample Orders (customer_id=1 → Pham Van D, cashier_id=1 → Nguyen Thi K) ──
    final orderId1 = await db.insert(tableOrders, {
      'customer_id': 1,
      'cashier_id': 1,
      'order_date': now,
      'total_amount': 188000.0,
      'status': 'completed',
      'created_at': now,
      'updated_at': now,
    });
    await db.insert(tableOrderItems, {'order_id': orderId1, 'product_id': 1, 'quantity': 1, 'unit_price': 120000.0, 'subtotal': 120000.0});
    await db.insert(tableOrderItems, {'order_id': orderId1, 'product_id': 4, 'quantity': 2, 'unit_price': 32000.0, 'subtotal': 64000.0});
    await db.insert(tableOrderItems, {'order_id': orderId1, 'product_id': 2, 'quantity': 1, 'unit_price': 4000.0, 'subtotal': 4000.0});

    // customer_id=2 → Hoang Thi E, cashier_id=2 → Pham Van L
    final orderId2 = await db.insert(tableOrders, {
      'customer_id': 2,
      'cashier_id': 2,
      'order_date': now,
      'total_amount': 63000.0,
      'status': 'pending',
      'created_at': now,
      'updated_at': now,
    });
    await db.insert(tableOrderItems, {'order_id': orderId2, 'product_id': 8, 'quantity': 1, 'unit_price': 35000.0, 'subtotal': 35000.0});
    await db.insert(tableOrderItems, {'order_id': orderId2, 'product_id': 5, 'quantity': 1, 'unit_price': 28000.0, 'subtotal': 28000.0});

    // customer_id=4 → Dang Thi G, cashier_id=3 → Ho Thi M
    final orderId3 = await db.insert(tableOrders, {
      'customer_id': 4,
      'cashier_id': 3,
      'order_date': now,
      'total_amount': 145000.0,
      'status': 'completed',
      'created_at': now,
      'updated_at': now,
    });
    await db.insert(tableOrderItems, {'order_id': orderId3, 'product_id': 7, 'quantity': 1, 'unit_price': 95000.0, 'subtotal': 95000.0});
    await db.insert(tableOrderItems, {'order_id': orderId3, 'product_id': 9, 'quantity': 2, 'unit_price': 15000.0, 'subtotal': 30000.0});
    await db.insert(tableOrderItems, {'order_id': orderId3, 'product_id': 6, 'quantity': 1, 'unit_price': 18000.0, 'subtotal': 18000.0});
  }

  // ═══════════════════════════════════════════════════════════════════
  //  USER CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<List<User>> getUsers() async {
    final db = await database;
    final maps = await db.query(tableUsers, orderBy: 'name');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(tableUsers, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(tableUsers, where: 'email = ?', whereArgs: [email], limit: 1);
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> authenticate(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      tableUsers,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert(tableUsers, user.toMap());
  }

  Future<int> updateUser(User user) async {
    if (user.id == null) throw ArgumentError('User id is required for update');
    final db = await database;
    final map = user.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableUsers, map, where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete(tableUsers, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CUSTOMER CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<Customer?> authenticateCustomer(String phone, String password) async {
    final db = await database;
    final maps = await db.query(
      tableCustomers,
      where: 'phone = ? AND password = ?',
      whereArgs: [phone, password],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final maps = await db.query(tableCustomers, orderBy: 'name');
    return maps.map((e) => Customer.fromMap(e)).toList();
  }

  Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final maps = await db.query(tableCustomers, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  Future<Customer?> getCustomerByPhone(String phone) async {
    final db = await database;
    final maps = await db.query(tableCustomers, where: 'phone = ?', whereArgs: [phone], limit: 1);
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await database;
    final maps = await db.query(
      tableCustomers,
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name',
    );
    return maps.map((e) => Customer.fromMap(e)).toList();
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return db.insert(tableCustomers, customer.toMap());
  }

  Future<int> updateCustomer(Customer customer) async {
    if (customer.id == null) throw ArgumentError('Customer id is required for update');
    final db = await database;
    final map = customer.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableCustomers, map, where: 'id = ?', whereArgs: [customer.id]);
  }

  Future<int> updateCustomerLoyaltyPoints(int customerId, int points) async {
    final db = await database;
    return db.rawUpdate('''
      UPDATE $tableCustomers
      SET loyalty_points = loyalty_points + ?, updated_at = ?
      WHERE id = ?
    ''', [points, DateTime.now().toIso8601String(), customerId]);
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return db.delete(tableCustomers, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  MANAGER CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Manager>> getManagers() async {
    final db = await database;
    final maps = await db.query(tableManagers, orderBy: 'name');
    return maps.map((e) => Manager.fromMap(e)).toList();
  }

  Future<Manager?> getManagerById(int id) async {
    final db = await database;
    final maps = await db.query(tableManagers, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Manager.fromMap(maps.first);
  }

  Future<Manager?> authenticateManager(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      tableManagers,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Manager.fromMap(maps.first);
  }

  Future<int> insertManager(Manager manager) async {
    final db = await database;
    return db.insert(tableManagers, manager.toMap());
  }

  Future<int> updateManager(Manager manager) async {
    if (manager.id == null) throw ArgumentError('Manager id is required for update');
    final db = await database;
    final map = manager.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableManagers, map, where: 'id = ?', whereArgs: [manager.id]);
  }

  Future<int> deleteManager(int id) async {
    final db = await database;
    return db.delete(tableManagers, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CASHIER CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Cashier>> getCashiers() async {
    final db = await database;
    final maps = await db.query(tableCashiers, orderBy: 'name');
    return maps.map((e) => Cashier.fromMap(e)).toList();
  }

  Future<Cashier?> getCashierById(int id) async {
    final db = await database;
    final maps = await db.query(tableCashiers, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Cashier.fromMap(maps.first);
  }

  Future<List<Cashier>> getCashiersByShift(String shift) async {
    final db = await database;
    final maps = await db.query(tableCashiers, where: 'shift = ?', whereArgs: [shift], orderBy: 'counter_number');
    return maps.map((e) => Cashier.fromMap(e)).toList();
  }

  Future<Cashier?> authenticateCashier(String email, String password) async {
    final db = await database;
    final maps = await db.query(
      tableCashiers,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Cashier.fromMap(maps.first);
  }

  Future<int> insertCashier(Cashier cashier) async {
    final db = await database;
    return db.insert(tableCashiers, cashier.toMap());
  }

  Future<int> updateCashier(Cashier cashier) async {
    if (cashier.id == null) throw ArgumentError('Cashier id is required for update');
    final db = await database;
    final map = cashier.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableCashiers, map, where: 'id = ?', whereArgs: [cashier.id]);
  }

  Future<int> deleteCashier(int id) async {
    final db = await database;
    return db.delete(tableCashiers, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CATEGORY CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query(tableCategories, orderBy: 'name');
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final maps = await db.query(tableCategories, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return db.insert(tableCategories, category.toMap());
  }

  Future<int> updateCategory(Category category) async {
    if (category.id == null) throw ArgumentError('Category id is required for update');
    final db = await database;
    return db.update(tableCategories, category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return db.delete(tableCategories, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  PRODUCT CRUD
  // ═══════════════════════════════════════════════════════════════════

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

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name
      FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      WHERE p.category_id = ?
      ORDER BY p.name
    ''', [categoryId]);
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name
      FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      WHERE p.id = ?
      LIMIT 1
    ''', [id]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name
      FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      WHERE p.barcode = ?
      LIMIT 1
    ''', [barcode]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name
      FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      WHERE p.name LIKE ? OR p.barcode LIKE ?
      ORDER BY p.name
    ''', ['%$query%', '%$query%']);
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT p.*, c.name AS category_name
      FROM $tableProducts p
      LEFT JOIN $tableCategories c ON p.category_id = c.id
      WHERE p.quantity <= ?
      ORDER BY p.quantity ASC
    ''', [threshold]);
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return db.insert(tableProducts, product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    if (product.id == null) throw ArgumentError('Product id is required for update');
    final db = await database;
    final map = product.toMap();
    map['updated_at'] = DateTime.now().toIso8601String();
    return db.update(tableProducts, map, where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> updateProductQuantity(int productId, int newQuantity) async {
    final db = await database;
    return db.update(
      tableProducts,
      {'quantity': newQuantity, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete(tableProducts, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SUPPLIER CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Supplier>> getSuppliers() async {
    final db = await database;
    final maps = await db.query(tableSuppliers, orderBy: 'name');
    return maps.map((e) => Supplier.fromMap(e)).toList();
  }

  Future<Supplier?> getSupplierById(int id) async {
    final db = await database;
    final maps = await db.query(tableSuppliers, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return Supplier.fromMap(maps.first);
  }

  Future<int> insertSupplier(Supplier supplier) async {
    final db = await database;
    return db.insert(tableSuppliers, supplier.toMap());
  }

  Future<int> updateSupplier(Supplier supplier) async {
    if (supplier.id == null) throw ArgumentError('Supplier id is required for update');
    final db = await database;
    return db.update(tableSuppliers, supplier.toMap(), where: 'id = ?', whereArgs: [supplier.id]);
  }

  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return db.delete(tableSuppliers, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SUPPLIER-PRODUCT CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<List<SupplierProduct>> getSupplierProducts(int supplierId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT sp.*, p.name AS product_name
      FROM $tableSupplierProducts sp
      JOIN $tableProducts p ON sp.product_id = p.id
      WHERE sp.supplier_id = ?
      ORDER BY p.name
    ''', [supplierId]);
    return maps.map((e) => SupplierProduct.fromMap(e)).toList();
  }

  Future<List<SupplierProduct>> getProductSuppliers(int productId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT sp.*, s.name AS supplier_name
      FROM $tableSupplierProducts sp
      JOIN $tableSuppliers s ON sp.supplier_id = s.id
      WHERE sp.product_id = ?
      ORDER BY s.name
    ''', [productId]);
    return maps.map((e) => SupplierProduct.fromMap(e)).toList();
  }

  Future<int> insertSupplierProduct(SupplierProduct sp) async {
    final db = await database;
    return db.insert(tableSupplierProducts, sp.toMap());
  }

  Future<int> deleteSupplierProduct(int id) async {
    final db = await database;
    return db.delete(tableSupplierProducts, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  ORDER CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<List<Order>> getOrders({String? status}) async {
    final db = await database;
    String sql = '''
      SELECT o.*, cu.name AS customer_name, cu.phone AS customer_phone, ca.name AS cashier_name
      FROM $tableOrders o
      LEFT JOIN $tableCustomers cu ON o.customer_id = cu.id
      LEFT JOIN $tableCashiers ca ON o.cashier_id = ca.id
    ''';
    List<dynamic> args = [];
    if (status != null) {
      sql += ' WHERE o.status = ?';
      args.add(status);
    }
    sql += ' ORDER BY o.created_at DESC';
    final maps = await db.rawQuery(sql, args);
    return maps.map((e) => Order.fromMap(e)).toList();
  }

  Future<Order?> getOrderById(int id) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT o.*, cu.name AS customer_name, cu.phone AS customer_phone, ca.name AS cashier_name
      FROM $tableOrders o
      LEFT JOIN $tableCustomers cu ON o.customer_id = cu.id
      LEFT JOIN $tableCashiers ca ON o.cashier_id = ca.id
      WHERE o.id = ?
      LIMIT 1
    ''', [id]);
    if (maps.isEmpty) return null;
    final order = Order.fromMap(maps.first);
    final items = await getOrderItems(id);
    return order.copyWith(items: items);
  }

  Future<List<Order>> getOrdersByCustomer(int customerId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT o.*, cu.name AS customer_name, cu.phone AS customer_phone, ca.name AS cashier_name
      FROM $tableOrders o
      LEFT JOIN $tableCustomers cu ON o.customer_id = cu.id
      LEFT JOIN $tableCashiers ca ON o.cashier_id = ca.id
      WHERE o.customer_id = ?
      ORDER BY o.created_at DESC
    ''', [customerId]);
    return maps.map((e) => Order.fromMap(e)).toList();
  }

  Future<List<Order>> getOrdersByCashier(int cashierId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT o.*, cu.name AS customer_name, cu.phone AS customer_phone, ca.name AS cashier_name
      FROM $tableOrders o
      LEFT JOIN $tableCustomers cu ON o.customer_id = cu.id
      LEFT JOIN $tableCashiers ca ON o.cashier_id = ca.id
      WHERE o.cashier_id = ?
      ORDER BY o.created_at DESC
    ''', [cashierId]);
    return maps.map((e) => Order.fromMap(e)).toList();
  }

  Future<List<OrderItem>> getOrderItems(int orderId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT oi.*, p.name AS product_name
      FROM $tableOrderItems oi
      JOIN $tableProducts p ON oi.product_id = p.id
      WHERE oi.order_id = ?
      ORDER BY oi.id
    ''', [orderId]);
    return maps.map((e) => OrderItem.fromMap(e)).toList();
  }

  Future<int> createOrder(Order order, List<OrderItem> items) async {
    final db = await database;
    int orderId = 0;
    await db.transaction((txn) async {
      orderId = await txn.insert(tableOrders, order.toMap());
      for (final item in items) {
        final itemMap = item.copyWith(orderId: orderId).toMap();
        await txn.insert(tableOrderItems, itemMap);
        await txn.rawUpdate('''
          UPDATE $tableProducts
          SET quantity = quantity - ?, updated_at = ?
          WHERE id = ?
        ''', [item.quantity, DateTime.now().toIso8601String(), item.productId]);
      }
    });
    return orderId;
  }

  Future<int> updateOrderStatus(int orderId, String status) async {
    final db = await database;
    return db.update(
      tableOrders,
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> cancelOrder(int orderId) async {
    final db = await database;
    await db.transaction((txn) async {
      final items = await txn.rawQuery(
        'SELECT * FROM $tableOrderItems WHERE order_id = ?',
        [orderId],
      );
      for (final item in items) {
        await txn.rawUpdate('''
          UPDATE $tableProducts
          SET quantity = quantity + ?, updated_at = ?
          WHERE id = ?
        ''', [item['quantity'], DateTime.now().toIso8601String(), item['product_id']]);
      }
      await txn.update(
        tableOrders,
        {'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [orderId],
      );
    });
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return db.delete(tableOrders, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  REPORT QUERIES
  // ═══════════════════════════════════════════════════════════════════

  Future<double> getTotalRevenue() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(total_amount), 0) AS revenue
      FROM $tableOrders
      WHERE status = 'completed'
    ''');
    return (result.first['revenue'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTotalOrderCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS cnt FROM $tableOrders');
    return (result.first['cnt'] as int?) ?? 0;
  }

  Future<int> getTotalProductCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS cnt FROM $tableProducts');
    return (result.first['cnt'] as int?) ?? 0;
  }

  Future<int> getTotalCustomerCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS cnt FROM $tableCustomers');
    return (result.first['cnt'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts({int limit = 5}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT p.name, SUM(oi.quantity) AS total_sold, SUM(oi.subtotal) AS total_revenue
      FROM $tableOrderItems oi
      JOIN $tableProducts p ON oi.product_id = p.id
      JOIN $tableOrders o ON oi.order_id = o.id
      WHERE o.status = 'completed'
      GROUP BY oi.product_id
      ORDER BY total_sold DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, dynamic>>> getRevenueByCategory() async {
    final db = await database;
    return db.rawQuery('''
      SELECT c.name AS category_name, SUM(oi.subtotal) AS revenue
      FROM $tableOrderItems oi
      JOIN $tableProducts p ON oi.product_id = p.id
      JOIN $tableCategories c ON p.category_id = c.id
      JOIN $tableOrders o ON oi.order_id = o.id
      WHERE o.status = 'completed'
      GROUP BY c.id
      ORDER BY revenue DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getRevenueByCashier() async {
    final db = await database;
    return db.rawQuery('''
      SELECT ca.name AS cashier_name, COUNT(o.id) AS order_count, SUM(o.total_amount) AS revenue
      FROM $tableOrders o
      JOIN $tableCashiers ca ON o.cashier_id = ca.id
      WHERE o.status = 'completed'
      GROUP BY o.cashier_id
      ORDER BY revenue DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getTopCustomers({int limit = 5}) async {
    final db = await database;
    return db.rawQuery('''
      SELECT cu.name, cu.phone, cu.loyalty_points, COUNT(o.id) AS order_count, SUM(o.total_amount) AS total_spent
      FROM $tableCustomers cu
      JOIN $tableOrders o ON o.customer_id = cu.id
      WHERE o.status = 'completed'
      GROUP BY cu.id
      ORDER BY total_spent DESC
      LIMIT ?
    ''', [limit]);
  }

  // ═══════════════════════════════════════════════════════════════════
  //  PURCHASE ORDER CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<List<PurchaseOrder>> getPurchaseOrders({required int supplierId}) async {
    final db = await database;
    final maps = await db.query(
      tablePurchaseOrders,
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => PurchaseOrder.fromMap(m)).toList();
  }

  Future<void> insertPurchaseOrder(Map<String, dynamic> poMap, List<Map<String, dynamic>> items) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(tablePurchaseOrders, poMap);
      for (final item in items) {
        await txn.insert(tablePurchaseOrderItems, item);
      }
    });
  }

  Future<int> updatePurchaseOrderStatus(String poId, String status) async {
    final db = await database;
    return db.update(
      tablePurchaseOrders,
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [poId],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  PRODUCT STOCK HELPERS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> decreaseProductStock(int productId, int quantity) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE $tableProducts
      SET quantity = quantity - ?, updated_at = ?
      WHERE id = ?
    ''', [quantity, DateTime.now().toIso8601String(), productId]);
  }

  Future<void> updateSupplierProductCatalog(int supplierId, int productId, {double? price, int? quantity}) async {
    final db = await database;
    if (price != null) {
      await db.rawUpdate('''
        UPDATE $tableProducts SET price = ?, updated_at = ? WHERE id = ?
      ''', [price, DateTime.now().toIso8601String(), productId]);
    }
    if (quantity != null) {
      await db.rawUpdate('''
        UPDATE $tableProducts SET quantity = ?, updated_at = ? WHERE id = ?
      ''', [quantity, DateTime.now().toIso8601String(), productId]);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  UTILITY
  // ═══════════════════════════════════════════════════════════════════

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
