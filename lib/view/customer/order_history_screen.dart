import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../db/app_database.dart';
import '../../models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerProv = Provider.of<CustomerProvider>(context);
    final orders = customerProv.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của bạn'),
        backgroundColor: Colors.orange, foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => customerProv.loadOrders())],
      ),
      body: customerProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có đơn hàng', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ]))
              : ListView.builder(
                  itemCount: orders.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) => _orderCard(context, orders[index]),
                ),
    );
  }

  Widget _orderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12), elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: _statusColor(order.status).withValues(alpha: 0.1),
          child: Icon(Icons.receipt, color: _statusColor(order.status)),
        ),
        title: Text('Đơn #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_fmt(order.totalAmount)}đ', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          Text(_statusText(order.status), style: TextStyle(color: _statusColor(order.status), fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
        children: [
          FutureBuilder<Order?>(
            future: AppDatabase.instance.getOrderById(order.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
              }
              final detail = snapshot.data;
              if (detail == null || detail.items.isEmpty) {
                return const Padding(padding: EdgeInsets.all(16), child: Text('Không có chi tiết'));
              }
              return Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(
                children: [
                  ...detail.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text('${item.productName ?? 'SP #${item.productId}'} x${item.quantity}', style: const TextStyle(fontSize: 13))),
                      Text('${_fmt(item.subtotal)}đ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ]),
                  )),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Tổng:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_fmt(detail.totalAmount)}đ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  ]),
                ],
              ));
            },
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s) => switch (s) { 'pending' => Colors.orange, 'processing' => Colors.blue, 'completed' => Colors.green, 'cancelled' => Colors.red, _ => Colors.grey };
  String _statusText(String s) => switch (s) { 'pending' => 'Chờ xử lý', 'processing' => 'Đang xử lý', 'completed' => 'Hoàn thành', 'cancelled' => 'Đã hủy', _ => s };
  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
