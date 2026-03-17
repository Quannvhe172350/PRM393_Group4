import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';

class UserDatabase {
  UserDatabase._internal();

  static final UserDatabase instance = UserDatabase._internal();

  static const _dbName = 'app_database.db';
  static const _dbVersion = 1;
  static const _tableUser = 'users';

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
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableUser(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');

    await _seedInitialUsers(db);
  }

  Future<void> _seedInitialUsers(Database db) async {
    final users = [
      User(name: 'Nguyen Van A', email: 'a@example.com', phone: '0900000001'),
      User(name: 'Tran Thi B', email: 'b@example.com', phone: '0900000002'),
      User(name: 'Le Van C', email: 'c@example.com', phone: '0900000003'),
    ];

    for (final user in users) {
      await db.insert(_tableUser, user.toMap());
    }
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final maps = await db.query(_tableUser, orderBy: 'name');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps =
        await db.query(_tableUser, where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return db.insert(_tableUser, user.toMap());
  }

  Future<int> updateUser(User user) async {
    if (user.id == null) {
      throw ArgumentError('User id is required for update');
    }
    final db = await database;
    return db.update(
      _tableUser,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete(
      _tableUser,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

