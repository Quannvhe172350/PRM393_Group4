import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../providers/customer_provider.dart';
import 'customer_home_screen.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});
  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showRegister = false;

  // Register fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _regPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_phoneController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập SĐT và mật khẩu');
      return;
    }
    setState(() => _isLoading = true);
    final success = await context.read<CustomerProvider>().login(
      _phoneController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerHomeScreen()));
    } else if (mounted) {
      _showSnack('SĐT hoặc mật khẩu không đúng');
    }
  }

  Future<void> _register() async {
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (_nameController.text.trim().isEmpty || phone.isEmpty) {
      _showSnack('Vui lòng nhập họ tên và SĐT');
      return;
    }

    final phoneExp = RegExp(r'^(0|\+84)[0-9]{9}$');
    if (!phoneExp.hasMatch(phone)) {
      _showSnack('Số điện thoại không hợp lệ (10 số, bắt đầu bằng 0 hoặc +84)');
      return;
    }

    if (email.isNotEmpty) {
      final emailExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailExp.hasMatch(email)) {
        _showSnack('Email không hợp lệ');
        return;
      }
    }
    if (_regPasswordController.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập mật khẩu');
      return;
    }
    if (_regPasswordController.text != _confirmPasswordController.text) {
      _showSnack('Mật khẩu xác nhận không khớp');
      return;
    }
    setState(() => _isLoading = true);
    final customer = Customer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _regPasswordController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
    );
    final success = await context.read<CustomerProvider>().register(customer);
    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerHomeScreen()));
    } else if (mounted) {
      _showSnack('SĐT đã tồn tại hoặc lỗi đăng ký');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(30)),
                child: const Icon(Icons.shopping_cart, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Khách hàng', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(_showRegister ? 'Tạo tài khoản mới' : 'Đăng nhập', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, 10))]),
                child: Column(children: [
                  // SĐT - dùng chung cho cả login & register
                  TextField(controller: _phoneController, keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: 'Số điện thoại', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),

                  if (!_showRegister) ...[
                    // === LOGIN FORM ===
                    const SizedBox(height: 12),
                    TextField(controller: _passwordController, obscureText: true,
                      decoration: InputDecoration(labelText: 'Mật khẩu', prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  ],

                  if (_showRegister) ...[
                    // === REGISTER FORM ===
                    const SizedBox(height: 12),
                    TextField(controller: _nameController,
                      decoration: InputDecoration(labelText: 'Họ tên *', prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                    TextField(controller: _regPasswordController, obscureText: true,
                      decoration: InputDecoration(labelText: 'Mật khẩu *', prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                    TextField(controller: _confirmPasswordController, obscureText: true,
                      decoration: InputDecoration(labelText: 'Xác nhận mật khẩu *', prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                    TextField(controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                    TextField(controller: _addressController,
                      decoration: InputDecoration(labelText: 'Địa chỉ', prefixIcon: const Icon(Icons.location_on), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _isLoading ? null : (_showRegister ? _register : _login),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_showRegister ? 'ĐĂNG KÝ' : 'ĐĂNG NHẬP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )),
                  TextButton(
                    onPressed: () => setState(() => _showRegister = !_showRegister),
                    child: Text(_showRegister ? 'Đã có tài khoản? Đăng nhập' : 'Chưa có tài khoản? Đăng ký'),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text('Quay lại', style: TextStyle(color: Colors.white)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
