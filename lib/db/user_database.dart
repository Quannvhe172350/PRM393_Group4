import '../models/user.dart';
import 'app_database.dart';

/// Backward-compatible wrapper that delegates to [AppDatabase].
/// Existing screens (UserListScreen, UserDetailScreen) can continue
/// using UserDatabase.instance without changes.
class UserDatabase {
  UserDatabase._internal();

  static final UserDatabase instance = UserDatabase._internal();

  final _db = AppDatabase.instance;

  Future<List<User>> getUsers() => _db.getUsers();

  Future<User?> getUserById(int id) => _db.getUserById(id);

  Future<int> insertUser(User user) => _db.insertUser(user);

  Future<int> updateUser(User user) => _db.updateUser(user);

  Future<int> deleteUser(int id) => _db.deleteUser(id);

  Future<int> banUser(int id) => _db.banUser(id);

  Future<int> unbanUser(int id) => _db.unbanUser(id);

  Future<int> updateUserRole(int id, String role) => _db.updateUserRole(id, role);
}
