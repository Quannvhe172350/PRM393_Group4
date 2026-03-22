import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/customer_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _usePoints = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final customer = Provider.of<CustomerProvider>(context);

    final customerObj = customer.currentCustomer;
    final loyaltyPoints = customerObj?.loyaltyPoints ?? 0;
    
    // Calculate max points can use
    final maxPointsNeeded = (cart.totalAmount / 100).ceil();
    final pointsToUse = min(loyaltyPoints, maxPointsNeeded);
    final discount = _usePoints ? (pointsToUse * 100) : 0;
    final finalTotal = cart.totalAmount - discount < 0 ? 0.0 : cart.totalAmount - discount;

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
                  if (customer.isLoggedIn && loyaltyPoints > 0)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Dùng $pointsToUse điểm (-${_fmt(pointsToUse * 100.0)}đ)',
                            style: const TextStyle(fontSize: 14, color: Colors.teal, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Switch(
                          value: _usePoints,
                          activeColor: Colors.teal,
                          onChanged: (val) {
                            setState(() {
                              _usePoints = val;
                            });
                          },
                        ),
                      ],
                    ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Tổng cộng:', style: TextStyle(fontSize: 16)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_usePoints && discount > 0)
                          Text('${_fmt(cart.totalAmount)}đ', style: const TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                        Text('${_fmt(finalTotal)}đ', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ]
                    )
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      onPressed: customer.isLoggedIn ? () => _checkout(context, cart, customer, _usePoints ? pointsToUse : 0, finalTotal) : null,
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

  void _checkout(BuildContext context, CartProvider cart, CustomerProvider customer, int pointsUsed, double finalTotal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _QRPaymentDialog(
        totalAmount: finalTotal,
        onPaid: () async {
          Navigator.pop(ctx); // Đóng dialog QR
          // Simulate payment verification
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (!context.mounted) return;
          Navigator.pop(context); // Đóng loading

          try {
            final orderId = await cart.checkout(customer.currentCustomer!.id!, pointsUsed: pointsUsed);
            await customer.refresh();
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (dc) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Text('Đặt hàng thành công!')
                  ]),
                  content: Text('Mã đơn hàng: #$orderId\nĐơn hàng đã được thanh toán và đang chờ xử lý.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(dc), child: const Text('OK'))],
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
            }
          }
        },
      ),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _QRPaymentDialog extends StatelessWidget {
  final double totalAmount;
  final VoidCallback onPaid;

  const _QRPaymentDialog({required this.totalAmount, required this.onPaid});

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Thanh toán mã QR', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Quét mã QR dưới đây bằng ứng dụng ngân hàng hoặc ví điện tử:'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2, size: 150, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Text(
            'Tổng tiền: ${_fmt(totalAmount)}đ',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPaid,
          child: const Text('Đã thanh toán'),
        ),
      ],
    );
  }
}
