import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/category_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final supplierProvider = Provider.of<SupplierProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo Thống kê'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng doanh thu', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatPrice(orderProvider.totalRevenue)}đ',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Từ ${orderProvider.completedOrders} đơn hàng hoàn thành',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Overview stats
            const Text('Tổng quan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildOverviewCard('Sản phẩm', '${productProvider.totalProducts}', Icons.shopping_bag, Colors.orange),
                _buildOverviewCard('Danh mục', '${categoryProvider.totalCategories}', Icons.category, Colors.indigo),
                _buildOverviewCard('Đơn hàng', '${orderProvider.totalOrders}', Icons.receipt, Colors.blue),
                _buildOverviewCard('Nhà cung cấp', '${supplierProvider.totalSuppliers}', Icons.local_shipping, Colors.red),
                _buildOverviewCard('Nhân viên', '${employeeProvider.totalEmployees}', Icons.people, Colors.purple),
                _buildOverviewCard('Tổng lương', _formatPriceShort(employeeProvider.totalSalary), Icons.payments, Colors.teal),
              ],
            ),
            const SizedBox(height: 24),

            // Order status breakdown
            const Text('Trạng thái Đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _buildStatusBar(orderProvider),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildStatusDot(Colors.orange, 'Chờ xử lý: ${orderProvider.pendingOrders}'),
                const SizedBox(width: 12),
                _buildStatusDot(Colors.blue, 'Đang xử lý: ${orderProvider.getByStatus('processing').length}'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildStatusDot(Colors.green, 'Hoàn thành: ${orderProvider.completedOrders}'),
                const SizedBox(width: 12),
                _buildStatusDot(Colors.red, 'Đã hủy: ${orderProvider.getByStatus('cancelled').length}'),
              ],
            ),
            const SizedBox(height: 24),

            // Top products by quantity
            const Text('Sản phẩm tồn kho cao nhất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...(() {
              final sorted = productProvider.products.toList()
                ..sort((a, b) => b.quantity.compareTo(a.quantity));
              return sorted.take(5).map((p) => _buildTopProductItem(p.name, p.quantity, p.category));
            })(),

            const SizedBox(height: 24),

            // Low stock warning
            if (productProvider.lowStockCount > 0) ...[
              const Text('⚠️ Cảnh báo Hết hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 12),

              ...productProvider.getLowStockProducts(threshold: 15)
                  .map((p) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.red.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Chỉ còn ${p.quantity} sản phẩm'),
                      trailing: Text('${p.quantity}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  )),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatusBar(OrderProvider provider) {
    final total = provider.totalOrders;
    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          if (provider.pendingOrders > 0)
            Expanded(
              flex: provider.pendingOrders,
              child: Container(height: 12, color: Colors.orange),
            ),
          if (provider.getByStatus('processing').isNotEmpty)
            Expanded(
              flex: provider.getByStatus('processing').length,
              child: Container(height: 12, color: Colors.blue),
            ),
          if (provider.completedOrders > 0)
            Expanded(
              flex: provider.completedOrders,
              child: Container(height: 12, color: Colors.green),
            ),
          if (provider.getByStatus('cancelled').isNotEmpty)
            Expanded(
              flex: provider.getByStatus('cancelled').length,
              child: Container(height: 12, color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTopProductItem(String name, int quantity, String category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if (category.isNotEmpty) Text(category, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
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

  String _formatPriceShort(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }
}
