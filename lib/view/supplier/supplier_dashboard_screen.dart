import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/supplier.dart';
import '../../models/supplier_product.dart';
import '../../models/product.dart';
import '../../models/purchase_order.dart';
import '../../providers/auth_provider.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/change_password_dialog.dart';
import '../../db/app_database.dart';

class SupplierDashboardScreen extends StatefulWidget {
  final Supplier supplier;
  const SupplierDashboardScreen({super.key, required this.supplier});

  @override
  State<SupplierDashboardScreen> createState() => _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  final AppDatabase _db = AppDatabase.instance;
  List<SupplierProduct> _catalog = [];
  List<PurchaseOrder> _orders = [];
  bool _isLoading = true;

  void _showProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final supplier = auth.currentSupplier ?? widget.supplier;
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        initialName: supplier.name,
        initialPhone: supplier.phone ?? '',
        initialEmail: supplier.email,
        initialAddress: supplier.address,
        showAddress: true,
        onSave: (name, phone, email, address) async {
          final updated = supplier.copyWith(name: name, phone: phone, email: email, address: address);
          await AppDatabase.instance.updateSupplier(updated);
          auth.loginAsSupplier(updated);
        },
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final supplier = auth.currentSupplier ?? widget.supplier;
    showDialog(
      context: context,
      builder: (_) => ChangePasswordDialog(
        onChangePassword: (currentPass, newPass) async {
          if (supplier.password != currentPass) return false;
          await AppDatabase.instance.updateSupplierPassword(supplier.id!, newPass);
          auth.loginAsSupplier(supplier.copyWith(password: newPass));
          return true;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Chỉ lấy sản phẩm thuộc nhà cung cấp đang đăng nhập
    final supplierProducts = await _db.getSupplierProducts(widget.supplier.id!);
    final orders = await _db.getPurchaseOrders(supplierId: widget.supplier.id!);

    debugPrint('SUPPLIER_DEBUG: supplier.id=${widget.supplier.id}, supplier.name=${widget.supplier.name}');
    debugPrint('SUPPLIER_DEBUG: catalog count=${supplierProducts.length}, orders count=${orders.length}');
    for (final o in orders) {
      debugPrint('SUPPLIER_DEBUG: order=${o.id}, supplierId=${o.supplierId}, status=${o.status}, total=${o.totalAmount}');
    }

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
          title: Text('Chào, ${widget.supplier.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Tài khoản',
              onSelected: (value) {
                if (value == 'profile') {
                  _showProfile(context);
                } else if (value == 'password') {
                  _showChangePassword(context);
                } else if (value == 'logout') {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'profile', child: Text('Chỉnh sửa thông tin')),
                const PopupMenuItem(value: 'password', child: Text('Đổi mật khẩu')),
                const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
              ],
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Cập nhật Catalog', icon: Icon(Icons.edit_note)),
              Tab(text: 'Đơn đặt hàng', icon: Icon(Icons.receipt_long)),
              Tab(text: 'Giao hàng', icon: Icon(Icons.local_shipping)),
              Tab(text: 'Thanh toán', icon: Icon(Icons.payment)),
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
    return Column(
      children: [
        // Nút thêm sản phẩm
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Thêm sản phẩm vào catalog'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: _showAddProductDialog,
            ),
          ),
        ),
        // Danh sách sản phẩm hiện tại
        Expanded(
          child: _catalog.isEmpty
              ? const Center(child: Text('Chưa có sản phẩm nào.'))
              : ListView.builder(
                  itemCount: _catalog.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final sp = _catalog[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
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
                                        child: Text('Tồn kho của bạn: ${sp.supplierQuantity}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.indigo),
                              onPressed: () => _showEditDialog(sp),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(sp),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final qtyController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm sản phẩm mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên sản phẩm *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá cung cấp (VNĐ) *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số lượng tồn kho',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim());
              final qty = int.tryParse(qtyController.text.trim()) ?? 0;

              if (name.isEmpty || price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tên và giá hợp lệ'), backgroundColor: Colors.orange),
                );
                return;
              }

              // 1. Tạo sản phẩm mới trong bảng Products
              final now = DateTime.now().toIso8601String();
              final newProduct = Product(
                name: name,
                description: descController.text.trim(),
                price: price, // Supermarket's selling price (default to supply price initially)
                quantity: 0, // Tồn kho của siêu thị ban đầu luôn là 0
                createdAt: now,
                updatedAt: now,
              );
              final productId = await _db.insertProduct(newProduct);

              // 2. Liên kết sản phẩm mới với nhà cung cấp
              await _db.insertSupplierProduct(SupplierProduct(
                supplierId: widget.supplier.id!,
                productId: productId,
                supplyPrice: price,
                supplierQuantity: qty, // Tồn kho của nhà cung cấp
                lastSupplyDate: now,
              ));

              if (dialogContext.mounted) Navigator.pop(dialogContext);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã thêm sản phẩm "$name" vào catalog!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  void _showEditDialog(SupplierProduct sp) {
    final nameController = TextEditingController(text: sp.productName ?? '');
    final descController = TextEditingController(text: sp.productDescription ?? '');
    final priceController = TextEditingController(text: sp.supplyPrice.toString());
    final qtyController = TextEditingController(text: sp.supplierQuantity.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cập nhật sản phẩm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên sản phẩm *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Giá cung cấp (VNĐ) *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Số lượng tồn kho', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim());
              final qty = int.tryParse(qtyController.text.trim()) ?? 0;

              if (name.isEmpty || price == null || price <= 0) return;

              // Cập nhật thông tin sản phẩm trong bảng Products (giữ nguyên tồn kho siêu thị)
              final updatedProduct = Product(
                id: sp.productId,
                name: name,
                description: descController.text.trim(),
                price: price,
                quantity: sp.productQuantity ?? 0,
                updatedAt: DateTime.now().toIso8601String(),
              );
              await _db.updateProduct(updatedProduct);

              // Cập nhật giá cung cấp trong bảng supplier_products
              await _db.updateSupplierProductCatalog(
                widget.supplier.id!,
                sp.productId,
                price: price,
                quantity: qty,
              );

              if (dialogContext.mounted) Navigator.pop(dialogContext);
              _loadData();
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(SupplierProduct sp) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${sp.productName}" khỏi catalog?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (sp.id != null) {
                await _db.deleteSupplierProduct(sp.id!);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa "${sp.productName}" khỏi catalog'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  ĐƠN ĐẶT HÀNG
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildOrdersTab() {
    if (_orders.isEmpty) return const Center(child: Text('Chưa có đơn hàng nào.'));
    return ListView.builder(
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
    );
  }

  void _cancelOrder(PurchaseOrder order) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn hàng: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Tổng: ${order.totalAmount.toStringAsFixed(0)}đ'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Lý do hủy đơn *',
                hintText: 'Nhập lý do hủy đơn hàng...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Không')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập lý do hủy'), backgroundColor: Colors.orange),
                );
                return;
              }
              await _db.updatePurchaseOrderStatus(order.id, 'cancelled');
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã hủy đơn ${order.id}. Lý do: $reason'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Xác nhận hủy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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


  // ═══════════════════════════════════════════════════════════════════
  //  GIAO HÀNG
  // ═══════════════════════════════════════════════════════════════════

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
             title: Text('Đơn hàng: ${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
             subtitle: Text('Tổng: ${o.totalAmount.toStringAsFixed(0)}đ'),
             trailing: ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
               onPressed: () async {
                  await _db.updatePurchaseOrderStatus(o.id, 'shipped');
                  _loadData();
               }, child: const Text('Xác nhận gửi')),
             onTap: () => _showOrderDetail(o),
           ),
         );
       },
     );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  THANH TOÁN
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPaymentTab() {
     final paymentOrders = _orders.where((o) => o.status == 'shipped' || o.status == 'completed').toList();
     if (paymentOrders.isEmpty) return const Center(child: Text('Không có đơn hàng liên quan đến thanh toán.'));

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
             trailing: Container(
               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
               decoration: BoxDecoration(
                 color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Text(
                 isPaid ? 'Đã thanh toán' : 'Chờ thanh toán',
                 style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
               ),
             ),
             onTap: () => _showOrderDetail(o),
           ),
         );
       },
     );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CHI TIẾT ĐƠN HÀNG (DÙNG CHUNG)
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
              // Header
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text('Chi tiết đơn hàng', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Info
              _infoRow('Mã đơn', order.id),
              _infoRow('Ngày đặt', order.orderDate.toString().split(' ')[0]),
              _infoRow('Trạng thái', order.status.toUpperCase()),
              _infoRow('Tổng tiền', '${order.totalAmount.toStringAsFixed(0)}đ'),
              const SizedBox(height: 12),
              const Divider(),
              const Text('Danh sách sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              // Items list
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
