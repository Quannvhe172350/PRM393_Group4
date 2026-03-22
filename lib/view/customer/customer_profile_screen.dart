import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/cart_provider.dart';
import '../../db/app_database.dart';
import '../widgets/change_password_dialog.dart';
import '../../utils/hash_helper.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerProv = Provider.of<CustomerProvider>(context);
    final customer = customerProv.currentCustomer;

    if (customer == null) {
      return const Scaffold(body: Center(child: Text('Chưa đăng nhập')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản'), backgroundColor: Colors.orange, foregroundColor: Colors.white, automaticallyImplyLeading: false),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        // Avatar
        CircleAvatar(radius: 45, backgroundColor: Colors.orange.withValues(alpha: 0.1), child: Text(
          customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.orange),
        )),
        const SizedBox(height: 12),
        Text(customer.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(customer.phone, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),

        // Loyalty card
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Điểm thưởng', style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(height: 4),
              Text('🎁 Loyalty Points', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
            Text('${customer.loyaltyPoints}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 24),

        // Info cards
        _infoTile(Icons.person, 'Họ tên', customer.name),
        _infoTile(Icons.phone, 'Số điện thoại', customer.phone),
        _infoTile(Icons.email, 'Email', customer.email ?? 'Chưa cập nhật'),
        _infoTile(Icons.location_on, 'Địa chỉ', customer.address ?? 'Chưa cập nhật'),
        _infoTile(Icons.receipt, 'Đơn hàng', '${customerProv.orders.length} đơn'),
        const SizedBox(height: 20),

        // Edit button
        SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () => _showEditDialog(context, customerProv),
          icon: const Icon(Icons.edit, color: Colors.orange),
          label: const Text('Chỉnh sửa thông tin', style: TextStyle(color: Colors.orange)),
        )),
        const SizedBox(height: 12),

        // Change password button
        SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => ChangePasswordDialog(
                onChangePassword: (currentPass, newPass) async {
                  if (customer.password != HashHelper.hashPassword(currentPass)) return false;
                  final hashedNewPass = HashHelper.hashPassword(newPass);
                  await AppDatabase.instance.updateCustomerPassword(customer.id!, hashedNewPass);
                  // Update customer in provider memory
                  await customerProv.updateProfile(customer.copyWith(password: hashedNewPass));
                  return true;
                },
              )
            );
          },
          icon: const Icon(Icons.lock, color: Colors.orange),
          label: const Text('Đổi mật khẩu', style: TextStyle(color: Colors.orange)),
        )),
        const SizedBox(height: 12),

        // Logout button
        SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            customerProv.logout();
            context.read<CartProvider>().clearCart();
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          },
          icon: const Icon(Icons.logout),
          label: const Text('ĐĂNG XUẤT'),
        )),
      ])),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.orange, size: 20)),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
    ]));
  }

  void _showEditDialog(BuildContext context, CustomerProvider prov) {
    final c = prov.currentCustomer!;
    final nameCtrl = TextEditingController(text: c.name);
    final emailCtrl = TextEditingController(text: c.email ?? '');
    final addressCtrl = TextEditingController(text: c.address ?? '');

    showDialog(context: context, builder: (dc) => AlertDialog(
      title: const Text('Chỉnh sửa thông tin'), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 10),
        TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 10),
        TextField(controller: addressCtrl, decoration: InputDecoration(labelText: 'Địa chỉ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc), child: const Text('Hủy')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () async {
            await prov.updateProfile(c.copyWith(
              name: nameCtrl.text.trim(),
              email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
              address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
            ));
            if (dc.mounted) Navigator.pop(dc);
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
