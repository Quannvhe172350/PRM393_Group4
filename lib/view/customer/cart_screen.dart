import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/customer_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final customer = Provider.of<CustomerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng (${cart.totalQuantity})'),
        backgroundColor: Colors.orange, foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(icon: const Icon(Icons.delete_sweep), onPressed: () => _confirmClear(context, cart)),
        ],
      ),
      body: cart.items.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Giỏ hàng trống', style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text('Hãy thêm sản phẩm vào giỏ hàng', style: TextStyle(color: Colors.grey)),
            ]))
          : Column(children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                        // Product icon
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.shopping_bag, color: Colors.orange),
                        ),
                        const SizedBox(width: 12),
                        // Info
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('${_fmt(item.product.price)}đ', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ])),
                        // Quantity controls
                        Column(children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            _qtyBtn(Icons.remove, () => cart.updateQuantity(item.product.id!, item.quantity - 1)),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            _qtyBtn(Icons.add, () => cart.updateQuantity(item.product.id!, item.quantity + 1)),
                          ]),
                          const SizedBox(height: 4),
                          Text('${_fmt(item.product.price * item.quantity)}đ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                        ]),
                      ])),
                    );
                  },
                ),
              ),
              // Bottom checkout bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))]),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Tổng cộng:', style: TextStyle(fontSize: 16)),
                    Text('${_fmt(cart.totalAmount)}đ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: customer.isLoggedIn ? () => _checkout(context, cart, customer) : null,
                      icon: const Icon(Icons.payment),
                      label: const Text('ĐẶT HÀNG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
              ),
            ]),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 18, color: Colors.orange),
      ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(context: context, builder: (dc) => AlertDialog(
      title: const Text('Xóa giỏ hàng'), content: const Text('Xóa tất cả sản phẩm trong giỏ?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc), child: const Text('Hủy')),
        TextButton(onPressed: () { cart.clearCart(); Navigator.pop(dc); }, child: const Text('Xóa', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _checkout(BuildContext context, CartProvider cart, CustomerProvider customer) async {
    try {
      final orderId = await cart.checkout(customer.currentCustomer!.id!);
      await customer.refresh();
      if (context.mounted) {
        showDialog(context: context, builder: (dc) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 28), SizedBox(width: 8), Text('Đặt hàng thành công!')]),
          content: Text('Mã đơn hàng: #$orderId\nĐơn hàng đang chờ xử lý.'),
          actions: [TextButton(onPressed: () => Navigator.pop(dc), child: const Text('OK'))],
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
