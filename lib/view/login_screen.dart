import 'package:flutter/material.dart';
import '../db/app_database.dart';
import 'home_screen.dart';
import 'manager/manager_dashboard_screen.dart';

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
      // Xác thực Manager từ DB
      final manager = await AppDatabase.instance.authenticateManager(email, password);
      if (manager != null) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ManagerDashboardScreen()));
        }
        return;
      }

      // Xác thực User (admin/staff) từ DB
      final user = await AppDatabase.instance.authenticate(email, password);
      if (user != null) {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }
        return;
      }

      // Không tìm thấy tài khoản
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email hoặc mật khẩu không đúng"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
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
          gradient: LinearGradient(
            colors: [Color(0xFF009688), Color(0xFF00796B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.store, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text("Supermarket", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text("Management System", style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 40),

                // Login card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Mật khẩu", prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: _isLoading ? null : login,
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("ĐĂNG NHẬP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Column(children: [
                        Text('Tài khoản mẫu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 4),
                        Text('Manager: b@supermarket.com / 123456', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Admin: admin@supermarket.com / 123456', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ]),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
