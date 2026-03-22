import 'package:flutter/material.dart';

import '../../db/app_database.dart';
import '../../models/user.dart';

/// Màn hình chi tiết User - Admin có thể: xem, sửa, set role (staff→manager), ban/unban.
/// Admin không được sửa/ban tài khoản Admin khác.
class AdminUserDetailScreen extends StatefulWidget {
  final int userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late Future<User?> _userFuture;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userFuture = AppDatabase.instance.getUserById(widget.userId);
    _userFuture.then((user) {
      if (user == null) return;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = await AppDatabase.instance.getUserById(widget.userId);
    if (user == null || user.role == 'admin') return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập đầy đủ tên, email, SĐT'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final emailExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailExp.hasMatch(email)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email không hợp lệ'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final phoneExp = RegExp(r'^(0|\+84)[0-9]{9}$');
    if (!phoneExp.hasMatch(phone)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số điện thoại không hợp lệ'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final updated = user.copyWith(
      name: name,
      email: email,
      phone: phone,
    );
    await AppDatabase.instance.updateUser(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thông tin'), backgroundColor: Colors.green),
    );
    _userFuture = AppDatabase.instance.getUserById(widget.userId);
    setState(() {});
  }

  Future<void> _promoteToManager() async {
    final user = await AppDatabase.instance.getUserById(widget.userId);
    if (user == null || user.role != 'staff') return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thăng cấp lên Quản lý'),
        content: Text('Xác nhận thăng cấp "${user.name}" từ Nhân viên lên Quản lý?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    await AppDatabase.instance.updateUserRole(widget.userId, 'manager');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thăng cấp lên Quản lý'), backgroundColor: Colors.green),
    );
    _userFuture = AppDatabase.instance.getUserById(widget.userId);
    setState(() {});
  }

  Future<void> _demoteToStaff() async {
    final user = await AppDatabase.instance.getUserById(widget.userId);
    if (user == null || user.role != 'manager') return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hạ vai trò'),
        content: Text('Xác nhận hạ vai trò "${user.name}" từ Quản lý xuống Nhân viên?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    await AppDatabase.instance.updateUserRole(widget.userId, 'staff');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã hạ xuống Nhân viên'), backgroundColor: Colors.green),
    );
    _userFuture = AppDatabase.instance.getUserById(widget.userId);
    setState(() {});
  }

  Future<void> _banUser() async {
    final user = await AppDatabase.instance.getUserById(widget.userId);
    if (user == null || user.role == 'admin') return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Khóa tài khoản'),
        content: Text('Bạn có chắc muốn khóa tài khoản "${user.name}"? Tài khoản bị khóa sẽ không thể đăng nhập.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Khóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    await AppDatabase.instance.banUser(widget.userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã khóa tài khoản'), backgroundColor: Colors.red),
    );
    _userFuture = AppDatabase.instance.getUserById(widget.userId);
    setState(() {});
  }

  Future<void> _unbanUser() async {
    final user = await AppDatabase.instance.getUserById(widget.userId);
    if (user == null) return;

    await AppDatabase.instance.unbanUser(widget.userId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã mở khóa tài khoản'), backgroundColor: Colors.green),
    );
    _userFuture = AppDatabase.instance.getUserById(widget.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Tài khoản'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Không tìm thấy tài khoản'));
          }

          final canEdit = user.role != 'admin';
          final isBanned = user.isBanned;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBanned)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.block, color: Colors.red, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tài khoản này đang bị khóa',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                TextField(
                  controller: _nameController,
                  readOnly: !canEdit,
                  decoration: InputDecoration(
                    labelText: 'Họ tên',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  readOnly: !canEdit,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  readOnly: !canEdit,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Vai trò: ${user.roleDisplay}', style: TextStyle(fontWeight: FontWeight.bold, color: _getRoleColor(user.role))),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (canEdit) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _save,
                      icon: const Icon(Icons.save, size: 20),
                      label: const Text('Lưu thông tin'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (user.role == 'staff')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _promoteToManager,
                        icon: const Icon(Icons.arrow_upward, size: 20),
                        label: const Text('Thăng cấp lên Quản lý'),
                      ),
                    ),
                  if (user.role == 'manager')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _demoteToStaff,
                        icon: const Icon(Icons.arrow_downward, size: 20),
                        label: const Text('Hạ xuống Nhân viên'),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (isBanned)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _unbanUser,
                        icon: const Icon(Icons.lock_open, size: 20),
                        label: const Text('Mở khóa tài khoản'),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _banUser,
                        icon: const Icon(Icons.block, size: 20),
                        label: const Text('Khóa tài khoản'),
                      ),
                    ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: 10),
                        Expanded(child: Text('Không thể sửa hoặc khóa tài khoản Admin khác.', style: TextStyle(color: Colors.black87))),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
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
