import 'package:flutter/material.dart';
import '../db/app_database.dart';
import 'home_screen.dart';
import 'manager/manager_dashboard_screen.dart';
import 'manager/employee_management_screen.dart';
import 'customer/customer_login_screen.dart';
import 'staff/barcode_screen.dart';
import 'supplier/supplier_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập email và mật khẩu")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final manager = await AppDatabase.instance.authenticateManager(email, password);
      if (manager != null) {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ManagerDashboardScreen()));
        return;
      }

      final user = await AppDatabase.instance.authenticate(email, password);
      if (user != null) {
        if (mounted) {
          if (user.role == 'staff') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BarcodeScreen()));
          } else if (user.role == 'admin') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EmployeeManagementScreen(isAdmin: true)));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          }
        }
        return;
      }

      final supplier = await AppDatabase.instance.authenticateSupplier(email, password);
      if (supplier != null) {
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SupplierDashboardScreen(supplier: supplier)));
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email hoặc mật khẩu không đúng"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF009688), Color(0xFF00796B)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(30)),
                  child: const Icon(Icons.store, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text("Supermarket", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text("Management System", style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 40),

                // Staff/Manager login
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: Column(children: [
                    const Text('Đăng nhập Nhân viên', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(controller: emailController, decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 16),
                    TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Mật khẩu", prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 24),
                    SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _isLoading ? null : login,
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("ĐĂNG NHẬP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Column(children: [
                        Text('Tài khoản mẫu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Manager: b@supermarket.com / 123456', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Admin: admin@supermarket.com / 123456', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Staff: staff@supermarket.com / 123456', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Supplier: supplier@supermarket.com / 123456', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ]),
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                // Customer login button
                SizedBox(width: double.infinity, height: 50, child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerLoginScreen()));
                  },
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: const Text('ĐĂNG NHẬP KHÁCH HÀNG', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
