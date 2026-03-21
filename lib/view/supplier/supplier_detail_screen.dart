import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../models/supplier_product.dart';
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
  List<SupplierProduct> _catalog = [];
  List<PurchaseOrder> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final supplierProducts = await _db.getSupplierProducts(widget.supplier.id!);
    final orders = await _db.getPurchaseOrders(supplierId: widget.supplier.id!);

    setState(() {
      _catalog = supplierProducts;
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
    if (_catalog.isEmpty) return const Center(child: Text('Nhà cung cấp chưa có sản phẩm nào.'));
    return ListView.builder(
      itemCount: _catalog.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final sp = _catalog[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sp.productName ?? 'SP #${sp.productId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (sp.productDescription != null && sp.productDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(sp.productDescription!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('Giá: ${sp.supplyPrice.toStringAsFixed(0)}đ', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text('Tồn kho NCC: ${sp.supplierQuantity}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
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
          child: _orders.isEmpty
              ? const Center(child: Text('Chưa có đơn hàng nào.'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final o = _orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text('Đơn hàng: ${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Ngày: ${o.orderDate.toString().split(' ')[0]} | Tổng: ${o.totalAmount.toStringAsFixed(0)}đ'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: _getStatusColor(o.status), borderRadius: BorderRadius.circular(8)),
                              child: Text(o.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            if (o.status == 'pending')
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                tooltip: 'Hủy đơn hàng',
                                onPressed: () => _cancelOrder(o),
                              ),
                          ],
                        ),
                        onTap: () => _showOrderDetail(o),
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
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _cancelOrder(PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: Text('Bạn có chắc muốn hủy đơn hàng "${order.id}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Không')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _db.updatePurchaseOrderStatus(order.id, 'cancelled');
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã hủy đơn hàng ${order.id}'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Hủy đơn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingTab() {
     final shippingOrders = _orders.where((o) => o.status == 'pending' || o.status == 'shipped').toList();
     if (shippingOrders.isEmpty) return const Center(child: Text('Không có đơn hàng liên quan đến giao hàng.'));

     return ListView.builder(
       itemCount: shippingOrders.length,
       padding: const EdgeInsets.all(16),
       itemBuilder: (context, index) {
         final o = shippingOrders[index];
         final isShipped = o.status == 'shipped';
         return Card(
           child: ListTile(
             title: Text('Đơn hàng: ${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
             subtitle: Text('Tổng: ${o.totalAmount.toStringAsFixed(0)}đ'),
             trailing: Container(
               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
               decoration: BoxDecoration(
                 color: isShipped ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Text(
                 isShipped ? 'Đã gửi hàng' : 'Chờ NCC gửi',
                 style: TextStyle(color: isShipped ? Colors.blue : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
               ),
             ),
             onTap: () => _showOrderDetail(o),
           ),
         );
       },
     );
  }

  Widget _buildPaymentTab() {
     final paymentOrders = _orders.where((o) => o.status == 'shipped' || o.status == 'completed').toList();
     if (paymentOrders.isEmpty) return const Center(child: Text('Không có đơn hàng cần thanh toán.'));

     return ListView.builder(
       itemCount: paymentOrders.length,
       padding: const EdgeInsets.all(16),
       itemBuilder: (context, index) {
         final o = paymentOrders[index];
         final isPaid = o.status == 'completed';
         return Card(
           child: ListTile(
             title: Text('Đơn hàng: ${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
             subtitle: Text('Tổng: ${o.totalAmount.toStringAsFixed(0)}đ'),
             trailing: isPaid
                 ? Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                     decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                     child: const Text('Đã thanh toán', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                   )
                 : ElevatedButton(
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                     onPressed: () async {
                        // Cập nhật trạng thái
                        await _db.updatePurchaseOrderStatus(o.id, 'completed');
                        // Tăng tồn kho cho từng sản phẩm trong đơn
                        final items = await _db.getPurchaseOrderItems(o.id);
                        for (final item in items) {
                          final productId = item['product_id'] as int;
                          final qty = item['quantity'] as int;
                          await _db.increaseProductStock(productId, qty);
                        }
                        _loadData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã thanh toán & nhập kho đơn ${o.id}'), backgroundColor: Colors.green),
                          );
                        }
                     }, child: const Text('Thanh toán')),
             onTap: () => _showOrderDetail(o),
           ),
         );
       },
     );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CHI TIẾT ĐƠN HÀNG
  // ═══════════════════════════════════════════════════════════════════

  void _showOrderDetail(PurchaseOrder order) async {
    final items = await _db.getPurchaseOrderItems(order.id);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Chi tiết đơn hàng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _infoRow('Mã đơn', order.id),
              _infoRow('Ngày đặt', order.orderDate.toString().split(' ')[0]),
              _infoRow('Trạng thái', order.status.toUpperCase()),
              _infoRow('Tổng tiền', '${order.totalAmount.toStringAsFixed(0)}đ'),
              const SizedBox(height: 12),
              const Divider(),
              const Text('Danh sách sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('Không có sản phẩm nào.'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            child: ListTile(
                              title: Text(item['product_name'] ?? 'SP #${item['product_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('SL: ${item['quantity']} x ${(item['unit_price'] as num).toDouble().toStringAsFixed(0)}đ'),
                              trailing: Text('${(item['subtotal'] as num).toDouble().toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:', style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
