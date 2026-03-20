import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final inStock = product.quantity > 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(product.name), backgroundColor: Colors.orange, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image area
          Container(
            width: double.infinity, height: 220,
            color: Colors.orange.withValues(alpha: 0.08),
            child: Center(child: Icon(Icons.shopping_bag, size: 80, color: Colors.orange.withValues(alpha: 0.4))),
          ),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Name
            Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Category
            if (product.category.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(product.category, style: const TextStyle(color: Colors.orange, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            // Price
            Text('${_fmt(product.price)}đ', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            // Stock
            Row(children: [
              Icon(inStock ? Icons.check_circle : Icons.cancel, color: inStock ? Colors.green : Colors.red, size: 18),
              const SizedBox(width: 6),
              Text(inStock ? 'Còn hàng (${product.quantity})' : 'Hết hàng',
                style: TextStyle(color: inStock ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 16),
            // Barcode
            if (product.barcode != null && product.barcode!.isNotEmpty) ...[
              Row(children: [
                const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Mã vạch: ${product.barcode}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ]),
              const SizedBox(height: 12),
            ],
            // Description
            if (product.description != null && product.description!.isNotEmpty) ...[
              const Text('Mô tả', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(product.description!, style: TextStyle(color: Colors.grey[700], height: 1.5)),
              const SizedBox(height: 20),
            ],
          ])),
        ]),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))]),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: inStock ? Colors.orange : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: inStock ? () {
              context.read<CartProvider>().addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã thêm ${product.name} vào giỏ hàng'), duration: const Duration(seconds: 1), backgroundColor: Colors.green),
              );
            } : null,
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(inStock ? 'THÊM VÀO GIỎ HÀNG' : 'HẾT HÀNG', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
