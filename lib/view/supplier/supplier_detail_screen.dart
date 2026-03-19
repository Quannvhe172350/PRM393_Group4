import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../models/product.dart';
import '../../models/purchase_order.dart';
import '../../db/app_database.dart';
import 'create_purchase_order_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final Supplier supplier;
  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  final AppDatabase _db = AppDatabase.instance;
  List<Product> _catalog = [];
  List<PurchaseOrder> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final allProducts = await _db.getProducts();
    final orders = await _db.getPurchaseOrders(supplierId: int.parse(widget.supplier.id));

    setState(() {
      _catalog = allProducts;
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Catalog Update', icon: Icon(Icons.edit_note)),
              Tab(text: 'Purchase Orders', icon: Icon(Icons.receipt_long)),
              Tab(text: 'Shipping Confirmation', icon: Icon(Icons.local_shipping)),
              Tab(text: 'Payment Advice', icon: Icon(Icons.payment)),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildCatalogTab(),
                  _buildOrdersTab(),
                  _buildShippingTab(),
                  _buildPaymentTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildCatalogTab() {
    return ListView.builder(
      itemCount: _catalog.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final product = _catalog[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Giá: ${product.price.toStringAsFixed(0)}đ | Kho: ${product.quantity}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.indigo),
              onPressed: () => _showEditDialog(product),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(Product product) {
    final priceController = TextEditingController(text: product.price.toString());
    final qtyController = TextEditingController(text: product.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật Catalog'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá mới (VNĐ)')),
            TextField(controller: qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tồn kho')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              await _db.updateSupplierProductCatalog(
                int.parse(widget.supplier.id),
                int.parse(product.id),
                price: double.tryParse(priceController.text),
                quantity: int.tryParse(qtyController.text),
              );
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Purchase Order'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () async {
              final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePurchaseOrderScreen(supplier: widget.supplier)));
              if (res == true) _loadData();
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final o = _orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Đơn hàng: ${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Ngày: ${o.orderDate.toString().split(' ')[0]} | Tổng: ${o.totalAmount.toStringAsFixed(0)}đ'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _getStatusColor(o.status), borderRadius: BorderRadius.circular(8)),
                    child: Text(o.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'shipped': return Colors.blue;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildShippingTab() {
     final pending = _orders.where((o) => o.status == 'pending').toList();
     if (pending.isEmpty) return const Center(child: Text('Không có đơn hàng chờ giao.'));

     return ListView.builder(
       itemCount: pending.length,
       padding: const EdgeInsets.all(16),
       itemBuilder: (context, index) {
         final o = pending[index];
         return Card(
           child: ListTile(
             title: Text(o.id),
             subtitle: Text('Tổng: ${o.totalAmount.toStringAsFixed(0)}đ'),
             trailing: ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
               onPressed: () async {
                  await _db.updatePurchaseOrderStatus(o.id, 'shipped');
                  _loadData();
               }, child: const Text('Confirm')),
           ),
         );
       },
     );
  }

  Widget _buildPaymentTab() {
     final shipped = _orders.where((o) => o.status == 'shipped').toList();
     if (shipped.isEmpty) return const Center(child: Text('Không có đơn hàng cần thanh toán.'));

     return ListView.builder(
       itemCount: shipped.length,
       padding: const EdgeInsets.all(16),
       itemBuilder: (context, index) {
         final o = shipped[index];
         return Card(
           child: ListTile(
             title: Text(o.id),
             subtitle: Text('Tổng: ${o.totalAmount.toStringAsFixed(0)}đ'),
             trailing: ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
               onPressed: () async {
                  await _db.updatePurchaseOrderStatus(o.id, 'completed');
                  _loadData();
               }, child: const Text('Send Advice')),
           ),
         );
       },
     );
  }
}
