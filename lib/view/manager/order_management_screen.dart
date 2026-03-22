import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../db/app_database.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = _selectedStatus == 'all'
        ? orderProvider.orders
        : orderProvider.getByStatus(_selectedStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status filter chips
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Chờ xử lý', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đang xử lý', 'processing'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hoàn thành', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đã hủy', 'cancelled'),
                ],
              ),
            ),
          ),

          // Order count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${orders.length} đơn hàng', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                Text('Doanh thu: ${_formatPrice(orderProvider.totalRevenue)}đ',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),

          // Order list
          Expanded(
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(child: Text('Không có đơn hàng', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: orders.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) => _buildOrderCard(context, orders[index], orderProvider),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.blue, fontSize: 12)),
      selected: isSelected,
      onSelected: (selected) => setState(() => _selectedStatus = status),
      backgroundColor: Colors.white,
      selectedColor: Colors.blue.shade700,
      checkmarkColor: Colors.white,
      side: const BorderSide(color: Colors.white),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, OrderProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status).withValues(alpha: 0.1),
          child: Icon(Icons.receipt, color: _getStatusColor(order.status)),
        ),
        title: Text(order.customerName ?? 'Khách #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${_formatPrice(order.totalAmount)}đ • ${_getStatusText(order.status)}',
          style: TextStyle(color: _getStatusColor(order.status), fontSize: 12)),
        children: [
          FutureBuilder<Order?>(
            future: AppDatabase.instance.getOrderById(order.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
              }
              final detailedOrder = snapshot.data;
              if (detailedOrder == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (detailedOrder.items.isNotEmpty) ...[
                      const Text('Chi tiết:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...detailedOrder.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item.productName ?? 'SP #${item.productId}'} x${item.quantity}', style: const TextStyle(fontSize: 13))),
                            Text('${_formatPrice(item.subtotal)}đ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                      const Divider(),
                    ],
                    // Status actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (order.status == 'pending')
                          TextButton.icon(
                            onPressed: () => provider.updateStatus(order.id!, 'processing'),
                            icon: const Icon(Icons.play_arrow, size: 18, color: Colors.blue),
                            label: const Text('Xử lý', style: TextStyle(color: Colors.blue)),
                          ),
                        if (order.status == 'processing')
                          TextButton.icon(
                            onPressed: () => provider.updateStatus(order.id!, 'completed'),
                            icon: const Icon(Icons.check, size: 18, color: Colors.green),
                            label: const Text('Hoàn thành', style: TextStyle(color: Colors.green)),
                          ),
                        if (order.status != 'cancelled' && order.status != 'completed')
                          TextButton.icon(
                            onPressed: () => provider.updateStatus(order.id!, 'cancelled'),
                            icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                            label: const Text('Hủy', style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Chờ xử lý';
      case 'processing': return 'Đang xử lý';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      default: return status;
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
