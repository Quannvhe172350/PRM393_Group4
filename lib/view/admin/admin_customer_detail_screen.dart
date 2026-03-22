import 'package:flutter/material.dart';

import '../../db/app_database.dart';
import '../../models/customer.dart';

/// Màn hình chi tiết Customer - Admin xem và sửa thông tin khách hàng.
class AdminCustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const AdminCustomerDetailScreen({super.key, required this.customerId});

  @override
  State<AdminCustomerDetailScreen> createState() =>
      _AdminCustomerDetailScreenState();
}

class _AdminCustomerDetailScreenState extends State<AdminCustomerDetailScreen> {
  late Future<Customer?> _customerFuture;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customerFuture = AppDatabase.instance.getCustomerById(widget.customerId);
    _customerFuture.then((c) {
      if (c == null) return;
      _nameController.text = c.name;
      _emailController.text = c.email ?? '';
      _phoneController.text = c.phone;
      _addressController.text = c.address ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final c = await AppDatabase.instance.getCustomerById(widget.customerId);
    if (c == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập tên và SĐT'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final updated = Customer(
      id: c.id,
      name: name,
      email: email.isEmpty ? null : email,
      phone: phone,
      password: c.password,
      address: address.isEmpty ? null : address,
      loyaltyPoints: c.loyaltyPoints,
      membershipDate: c.membershipDate,
      createdAt: c.createdAt,
    );
    await AppDatabase.instance.updateCustomer(updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu thông tin'), backgroundColor: Colors.green),
    );
    _customerFuture = AppDatabase.instance.getCustomerById(widget.customerId);
    setState(() {});
  }

  Future<void> _banCustomer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Khóa tài khoản'),
        content: const Text(
          'Bạn có chắc muốn khóa tài khoản khách hàng này? Tài khoản bị khóa sẽ không thể đăng nhập.',
        ),
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

    await AppDatabase.instance.banCustomer(widget.customerId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã khóa tài khoản'), backgroundColor: Colors.red),
    );
    _customerFuture = AppDatabase.instance.getCustomerById(widget.customerId);
    setState(() {});
  }

  Future<void> _unbanCustomer() async {
    await AppDatabase.instance.unbanCustomer(widget.customerId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã mở khóa tài khoản'), backgroundColor: Colors.green),
    );
    _customerFuture = AppDatabase.instance.getCustomerById(widget.customerId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Khách hàng'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Customer?>(
        future: _customerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final customer = snapshot.data;
          if (customer == null) {
            return const Center(child: Text('Không tìm thấy khách hàng'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customer.isBanned)
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
                  decoration: InputDecoration(
                    labelText: 'Họ tên *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Điểm tích lũy: ${customer.loyaltyPoints}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
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
                if (customer.isBanned)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _unbanCustomer,
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
                      onPressed: _banCustomer,
                      icon: const Icon(Icons.block, size: 20),
                      label: const Text('Khóa tài khoản'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
