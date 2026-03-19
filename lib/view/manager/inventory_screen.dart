import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final allProducts = productProvider.products;
    final lowStock = productProvider.getLowStockProducts(threshold: 15);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tồn kho'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Tất cả (${allProducts.length})'),
            Tab(text: 'Sắp hết (${lowStock.length})'),
          ],
        ),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProductList(allProducts, productProvider),
                _buildProductList(lowStock, productProvider),
              ],
            ),
    );
  }

  Widget _buildProductList(List products, ProductProvider provider) {
    if (products.isEmpty) {
      return const Center(child: Text('Không có sản phẩm', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: products.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final product = products[index];
        final stockLevel = product.quantity < 10 ? 'critical' : (product.quantity < 20 ? 'low' : 'ok');

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
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: stockLevel == 'critical' ? Colors.red
                        : stockLevel == 'low' ? Colors.orange
                        : Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        'Tồn kho: ${product.quantity}',
                        style: TextStyle(
                          color: product.quantity < 10 ? Colors.red : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (product.category.isNotEmpty)
                        Text(product.category, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),

                // Quick stock update buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.remove, color: Colors.red, size: 18),
                      ),
                      onPressed: product.quantity > 0
                          ? () => provider.updateStock(product.id!, product.quantity - 1)
                          : null,
                    ),
                    Text('${product.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.green, size: 18),
                      ),
                      onPressed: () => provider.updateStock(product.id!, product.quantity + 1),
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
}
