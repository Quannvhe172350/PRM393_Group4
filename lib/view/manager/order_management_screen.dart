import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.getByStatus(_filterStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all', orderProvider.totalOrders),
                  const SizedBox(width: 8),
                  _buildFilterChip('Chờ xử lý', 'pending', orderProvider.pendingOrders),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đang xử lý', 'processing', orderProvider.getByStatus('processing').length),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hoàn thành', 'completed', orderProvider.completedOrders),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đã hủy', 'cancelled', orderProvider.getByStatus('cancelled').length),
                ],
              ),
            ),
          ),

          // Order list
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text('Không có đơn hàng nào', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: orders.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(context, order, orderProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status, int count) {
    final isSelected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, OrderProvider provider) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
          child: Icon(Icons.receipt, color: _getStatusColor(order.status)),
        ),
        title: Text('#${order.id} - ${order.customerName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(dateFormat.format(order.orderDate), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _formatPrice(order.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          // Order items
          ...order.items.map((item) => ListTile(
            dense: true,
            leading: const Icon(Icons.shopping_bag_outlined, size: 20),
            title: Text(item.productName, style: const TextStyle(fontSize: 13)),
            subtitle: Text('${_formatPrice(item.price)} x ${item.quantity}', style: const TextStyle(fontSize: 12)),
            trailing: Text(_formatPrice(item.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          )),
          const Divider(height: 1),
          // Status update buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (order.status == 'pending')
                  _buildStatusButton('Xử lý', Colors.blue, () {
                    provider.updateOrderStatus(order.id, 'processing');
                  }),
                if (order.status == 'processing')
                  _buildStatusButton('Hoàn thành', Colors.green, () {
                    provider.updateOrderStatus(order.id, 'completed');
                  }),
                if (order.status != 'completed' && order.status != 'cancelled')
                  _buildStatusButton('Hủy', Colors.red, () {
                    provider.updateOrderStatus(order.id, 'cancelled');
                  }),
                _buildStatusButton('Xóa', Colors.grey, () {
                  _showDeleteDialog(context, order, provider);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showDeleteDialog(BuildContext context, Order order, OrderProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đơn hàng'),
        content: Text('Bạn có chắc muốn xóa đơn hàng #${order.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              provider.deleteOrder(order.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
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
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
  }
}
