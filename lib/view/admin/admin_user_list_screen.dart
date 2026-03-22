import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/change_password_dialog.dart';

import '../../db/app_database.dart';
import '../../models/customer.dart';
import '../../models/user.dart';
import 'admin_user_detail_screen.dart';
import 'admin_user_create_screen.dart';
import 'admin_customer_detail_screen.dart';

/// Màn hình quản lý User - chỉ dành cho Admin.
/// Tab Staff: danh sách staff + manager. Tab Customer: danh sách customer.
class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<User>> _usersFuture;
  late Future<List<Customer>> _customersFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        initialName: user.name,
        initialPhone: user.phone,
        initialEmail: user.email,
        onSave: (name, phone, email, _) async {
          final updated = user.copyWith(name: name, phone: phone, email: email);
          await AppDatabase.instance.updateUser(updated);
          auth.loginAsUser(updated);
        },
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;
    showDialog(
      context: context,
      builder: (_) => ChangePasswordDialog(
        onChangePassword: (currentPass, newPass) async {
          if (user.password != currentPass) return false;
          await AppDatabase.instance.updateUserPassword(user.id!, newPass);
          auth.loginAsUser(user.copyWith(password: newPass));
          return true;
        },
      ),
    );
  }

  void _loadData() {
    _usersFuture = AppDatabase.instance.getUsers();
    _customersFuture = AppDatabase.instance.getCustomers();
    setState(() {});
  }

  Future<void> _refresh() async {
    _loadData();
    await Future.wait([_usersFuture, _customersFuture]);
  }

  List<User> _filterStaff(List<User> users) {
    final staffAndManager = users.where((u) => u.role == 'staff' || u.role == 'manager').toList();
    if (_searchQuery.trim().isEmpty) return staffAndManager;
    final q = _searchQuery.trim().toLowerCase();
    return staffAndManager.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          u.phone.contains(q);
    }).toList();
  }

  List<Customer> _filterCustomers(List<Customer> customers) {
    if (_searchQuery.trim().isEmpty) return customers;
    final q = _searchQuery.trim().toLowerCase();
    return customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          (c.email?.toLowerCase().contains(q) ?? false) ||
          c.phone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tài khoản'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Tài khoản',
            onSelected: (value) {
              if (value == 'profile') {
                _showProfile(context);
              } else if (value == 'password') {
                _showChangePassword(context);
              } else if (value == 'logout') {
                context.read<AuthProvider>().logout();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Chỉnh sửa thông tin')),
              const PopupMenuItem(value: 'password', child: Text('Đổi mật khẩu')),
              const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Staff', icon: Icon(Icons.badge, size: 20)),
            Tab(text: 'Customer', icon: Icon(Icons.person, size: 20)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.teal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, email, SĐT...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _StaffListTab(
                  usersFuture: _usersFuture,
                  filterFn: _filterStaff,
                  searchQuery: _searchQuery,
                  onRefresh: _refresh,
                  onTapUser: (user) async {
                    if (user.id == null) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminUserDetailScreen(userId: user.id!),
                      ),
                    );
                    _refresh();
                  },
                ),
                _CustomerListTab(
                  customersFuture: _customersFuture,
                  filterFn: _filterCustomers,
                  searchQuery: _searchQuery,
                  onRefresh: _refresh,
                  onTapCustomer: (customer) async {
                    if (customer.id == null) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminCustomerDetailScreen(customerId: customer.id!),
                      ),
                    );
                    _refresh();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUserCreateScreen(),
                  ),
                );
                _refresh();
              },
              backgroundColor: Colors.teal,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('Tạo tài khoản', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}

class _StaffListTab extends StatelessWidget {
  final Future<List<User>> usersFuture;
  final List<User> Function(List<User>) filterFn;
  final String searchQuery;
  final VoidCallback onRefresh;
  final void Function(User) onTapUser;

  const _StaffListTab({
    required this.usersFuture,
    required this.filterFn,
    required this.searchQuery,
    required this.onRefresh,
    required this.onTapUser,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final users = filterFn(snapshot.data ?? []);

        if (users.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isEmpty ? 'Chưa có staff/manager nào' : 'Không tìm thấy kết quả',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return _UserCard(user: users[index], onTap: () => onTapUser(users[index]));
            },
          ),
        );
      },
    );
  }
}

class _CustomerListTab extends StatelessWidget {
  final Future<List<Customer>> customersFuture;
  final List<Customer> Function(List<Customer>) filterFn;
  final String searchQuery;
  final VoidCallback onRefresh;
  final void Function(Customer) onTapCustomer;

  const _CustomerListTab({
    required this.customersFuture,
    required this.filterFn,
    required this.searchQuery,
    required this.onRefresh,
    required this.onTapCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Customer>>(
      future: customersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        final customers = filterFn(snapshot.data ?? []);

        if (customers.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isEmpty ? 'Chưa có khách hàng nào' : 'Không tìm thấy kết quả',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              return _CustomerCard(
                customer: customers[index],
                onTap: () => onTapCustomer(customers[index]),
              );
            },
          ),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(user.role);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: user.isBanned
                    ? Colors.grey.withValues(alpha: 0.3)
                    : roleColor.withValues(alpha: 0.2),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: user.isBanned ? Colors.grey : roleColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: user.isBanned ? Colors.grey : null,
                              decoration: user.isBanned ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (user.isBanned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('BỊ KHÓA', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(user.email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(user.roleDisplay, style: TextStyle(fontSize: 11, color: roleColor, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Text(user.phone, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.purple;
      case 'staff':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: customer.isBanned
                    ? Colors.grey.withValues(alpha: 0.3)
                    : Colors.orange.withValues(alpha: 0.2),
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: customer.isBanned ? Colors.grey : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: customer.isBanned ? Colors.grey : null,
                              decoration: customer.isBanned ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (customer.isBanned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('BỊ KHÓA', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email ?? customer.phone,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (customer.loyaltyPoints > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${customer.loyaltyPoints} điểm', style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w600)),
                          ),
                        if (customer.loyaltyPoints > 0) const SizedBox(width: 8),
                        Text(customer.phone, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
