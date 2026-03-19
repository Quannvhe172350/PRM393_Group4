import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../db/app_database.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/staff_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double _dbRevenue = 0;
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _revenueByCategory = [];
  bool _loadingReports = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    final db = AppDatabase.instance;
    final revenue = await db.getTotalRevenue();
    final top = await db.getTopSellingProducts(limit: 5);
    final byCat = await db.getRevenueByCategory();
    setState(() {
      _dbRevenue = revenue;
      _topProducts = top;
      _revenueByCategory = byCat;
      _loadingReports = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProv = Provider.of<ProductProvider>(context);
    final categoryProv = Provider.of<CategoryProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);
    final supplierProv = Provider.of<SupplierProvider>(context);
    final staffProv = Provider.of<StaffProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo & Thống kê'), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: _loadingReports
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Revenue card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💰 Tổng doanh thu', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text('${_fmt(_dbRevenue)}đ', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Từ ${orderProv.completedOrders} đơn hoàn thành', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 20),

          // Overview stats
          const Text('📊 Tổng quan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _statsGrid(productProv, categoryProv, orderProv, supplierProv, staffProv),
          const SizedBox(height: 20),

          // Order status
          const Text('📦 Trạng thái đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _orderStatusSection(orderProv),
          const SizedBox(height: 20),

          // Revenue by category
          if (_revenueByCategory.isNotEmpty) ...[
            const Text('📂 Doanh thu theo danh mục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._revenueByCategory.map((cat) => _barItem(
              cat['category_name'] as String? ?? 'N/A',
              (cat['revenue'] as num?)?.toDouble() ?? 0,
              _dbRevenue > 0 ? ((cat['revenue'] as num?)?.toDouble() ?? 0) / _dbRevenue : 0,
              Colors.indigo,
            )),
            const SizedBox(height: 20),
          ],

          // Top selling
          if (_topProducts.isNotEmpty) ...[
            const Text('🏆 Top sản phẩm bán chạy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(_topProducts.length, (i) {
              final p = _topProducts[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.amber.withValues(alpha: 0.2), child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
                  title: Text(p['name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Đã bán: ${p['total_sold']}'),
                  trailing: Text('${_fmt((p['total_revenue'] as num?)?.toDouble() ?? 0)}đ', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],

          // Low stock alerts
          if (productProv.lowStockCount > 0) ...[
            const Text('⚠️ Cảnh báo tồn kho', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withValues(alpha: 0.2))),
              child: Column(children: productProv.getLowStockProducts().map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(p.name, style: const TextStyle(fontSize: 13)),
                  Text('Còn ${p.quantity}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
              )).toList()),
            ),
          ],
          const SizedBox(height: 30),
        ])),
    );
  }

  Widget _statsGrid(ProductProvider pp, CategoryProvider cp, OrderProvider op, SupplierProvider sp, StaffProvider stp) {
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.2,
      children: [
        _statCard('Sản phẩm', '${pp.totalProducts}', Icons.shopping_bag, Colors.orange),
        _statCard('Danh mục', '${cp.totalCategories}', Icons.category, Colors.indigo),
        _statCard('Đơn hàng', '${op.totalOrders}', Icons.receipt, Colors.blue),
        _statCard('Nhà CC', '${sp.totalSuppliers}', Icons.local_shipping, Colors.red),
        _statCard('Nhân viên', '${stp.totalStaff}', Icons.people, Colors.purple),
        _statCard('Quỹ lương', _fmtShort(stp.totalSalary), Icons.monetization_on, Colors.teal),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 6)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        Text(title, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ]),
    );
  }

  Widget _orderStatusSection(OrderProvider op) {
    final statuses = {'pending': 'Chờ xử lý', 'processing': 'Đang xử lý', 'completed': 'Hoàn thành', 'cancelled': 'Đã hủy'};
    final colors = {'pending': Colors.orange, 'processing': Colors.blue, 'completed': Colors.green, 'cancelled': Colors.red};
    final total = op.totalOrders > 0 ? op.totalOrders : 1;
    return Column(children: statuses.entries.map((e) {
      final count = op.getByStatus(e.key).length;
      return _barItem(e.value, count.toDouble(), count / total, colors[e.key]!);
    }).toList());
  }

  Widget _barItem(String label, double value, double ratio, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(value >= 1000 ? _fmt(value) : value.toInt().toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: ratio.clamp(0, 1), backgroundColor: color.withValues(alpha: 0.1), color: color, minHeight: 8)),
    ]));
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  String _fmtShort(double v) => v >= 1000000 ? '${(v / 1000000).toStringAsFixed(1)}M' : v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}K' : v.toStringAsFixed(0);
}
