import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;
    final lowStock = productProvider.getLowStockProducts(threshold: 15);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Tồn kho'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Tất cả', icon: Icon(Icons.inventory_2)),
              Tab(text: 'Sắp hết', icon: Icon(Icons.warning_amber)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All products inventory
            _buildInventoryList(context, products, productProvider),
            // Low stock products
            lowStock.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 64, color: Colors.green),
                        SizedBox(height: 12),
                        Text('Tất cả sản phẩm đều đủ hàng!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _buildInventoryList(context, lowStock, productProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryList(BuildContext context, List products, ProductProvider provider) {
    return ListView.builder(
      itemCount: products.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final product = products[index];
        final stockLevel = product.quantity < 10
            ? 'critical'
            : product.quantity < 20
                ? 'low'
                : 'normal';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Stock indicator
                Container(
                  width: 8,
                  height: 60,
                  decoration: BoxDecoration(
                    color: stockLevel == 'critical'
                        ? Colors.red
                        : stockLevel == 'low'
                            ? Colors.orange
                            : Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (product.category.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(product.category, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${_formatPrice(product.price)}đ',
                            style: const TextStyle(color: Colors.teal, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quantity with update buttons
                Column(
                  children: [
                    Text(
                      'Kho: ${product.quantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: stockLevel == 'critical'
                            ? Colors.red
                            : stockLevel == 'low'
                                ? Colors.orange
                                : Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStockButton(Icons.remove, Colors.red, () {
                          if (product.quantity > 0) {
                            provider.updateStock(product.id, product.quantity - 1);
                          }
                        }),
                        const SizedBox(width: 4),
                        _buildStockButton(Icons.add, Colors.green, () {
                          provider.updateStock(product.id, product.quantity + 1);
                        }),
                        const SizedBox(width: 4),
                        _buildStockButton(Icons.edit, Colors.teal, () {
                          _showUpdateStockDialog(context, product, provider);
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockButton(IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, dynamic product, ProductProvider provider) {
    final controller = TextEditingController(text: product.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật: ${product.name}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Số lượng mới',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              final qty = int.tryParse(controller.text);
              if (qty != null && qty >= 0) {
                provider.updateStock(product.id, qty);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã cập nhật ${product.name}: $qty'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
