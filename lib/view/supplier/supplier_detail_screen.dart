import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../models/purchase_order.dart';
import '../../repositories/purchase_order_repository.dart';
import 'create_purchase_order_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PurchaseOrderRepository _poRepo = PurchaseOrderRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PurchaseOrder> get _orders =>
      _poRepo.getBySupplierId(widget.supplier.id);

  void _refreshState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.supplier.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.green[200],
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Catalog'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Purchase Orders'),
            Tab(icon: Icon(Icons.local_shipping), text: 'Shipping'),
            Tab(icon: Icon(Icons.payment), text: 'Payment'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CatalogTab(supplier: widget.supplier, onUpdated: _refreshState),
          _PurchaseOrderTab(
            orders: _orders,
            supplier: widget.supplier,
            onRefresh: _refreshState,
          ),
          _ShippingTab(orders: _orders, onRefresh: _refreshState),
          _PaymentTab(orders: _orders, onRefresh: _refreshState),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// TAB 1: CATALOG UPDATE
// ─────────────────────────────────────────
class _CatalogTab extends StatefulWidget {
  final Supplier supplier;
  final VoidCallback onUpdated;

  const _CatalogTab({required this.supplier, required this.onUpdated});

  @override
  State<_CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<_CatalogTab> {
  @override
  Widget build(BuildContext context) {
    final items = widget.supplier.catalogItems;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
              const SizedBox(width: 6),
              Text(
                'Tap a row to update price or availability',
                style: TextStyle(color: Colors.blue[600], fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('No catalog items.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.available
                              ? Colors.green[50]
                              : Colors.red[50],
                          child: Icon(
                            item.available
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: item.available
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        title: Text(item.productName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            'SKU: ${item.sku}  •  Price: \$${item.wholesalePrice.toStringAsFixed(0)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _showEditDialog(context, item, i),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showEditDialog(
      BuildContext context, CatalogItem item, int index) {
    final priceCtrl =
        TextEditingController(text: item.wholesalePrice.toStringAsFixed(0));
    bool available = item.available;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Update: ${item.productName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Wholesale Price',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Available'),
                value: available,
                activeColor: Colors.green,
                onChanged: (v) => setDialogState(() => available = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700]),
              onPressed: () {
                final newPrice =
                    double.tryParse(priceCtrl.text) ?? item.wholesalePrice;
                setState(() {
                  widget.supplier.catalogItems[index] = item.copyWith(
                    wholesalePrice: newPrice,
                    available: available,
                  );
                });
                widget.onUpdated();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catalog updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// TAB 2: PURCHASE ORDERS
// ─────────────────────────────────────────
class _PurchaseOrderTab extends StatelessWidget {
  final List<PurchaseOrder> orders;
  final Supplier supplier;
  final VoidCallback onRefresh;

  const _PurchaseOrderTab({
    required this.orders,
    required this.supplier,
    required this.onRefresh,
  });

  Color _statusColor(POStatus s) {
    switch (s) {
      case POStatus.pending:
        return Colors.orange;
      case POStatus.confirmed:
        return Colors.blue;
      case POStatus.shipped:
        return Colors.purple;
      case POStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Create Purchase Order',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CreatePurchaseOrderScreen(supplier: supplier),
                  ),
                );
                onRefresh();
              },
            ),
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? const Center(
                  child: Text('No purchase orders yet.',
                      style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final po = orders[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  po.id,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(po.status)
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    po.statusLabel,
                                    style: TextStyle(
                                      color: _statusColor(po.status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${po.items.length} items  •  Total: \$${po.totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13),
                            ),
                            Text(
                              'Created: ${po.createdAt.day}/${po.createdAt.month}/${po.createdAt.year}',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12),
                            ),
                            const Divider(height: 16),
                            ...po.items.map((item) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.fiber_manual_record,
                                          size: 8, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                          child: Text(item.productName)),
                                      Text(
                                          'x${item.quantity}  \$${item.totalPrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13)),
                                    ],
                                  ),
                                )),
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
}

// ─────────────────────────────────────────
// TAB 3: SHIPPING CONFIRMATION
// ─────────────────────────────────────────
class _ShippingTab extends StatelessWidget {
  final List<PurchaseOrder> orders;
  final VoidCallback onRefresh;

  const _ShippingTab({required this.orders, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final pendingShipping = orders
        .where((o) => !o.shippingConfirmed && o.status != POStatus.completed)
        .toList();
    final confirmed = orders.where((o) => o.shippingConfirmed).toList();
    final repo = PurchaseOrderRepository();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pendingShipping.isNotEmpty) ...[
          const Text('⏳ Awaiting Shipping Confirmation',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...pendingShipping.map((po) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(Icons.local_shipping,
                        color: Colors.orange),
                  ),
                  title: Text(po.id,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${po.items.length} items • \$${po.totalAmount.toStringAsFixed(0)}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      repo.confirmShipping(po.id);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Shipping confirmed for ${po.id}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Confirm',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (confirmed.isNotEmpty) ...[
          const Text('✅ Shipping Confirmed',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...confirmed.map((po) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: Colors.green[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
                  title: Text(po.id,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Status: ${po.statusLabel} • \$${po.totalAmount.toStringAsFixed(0)}'),
                ),
              )),
        ],
        if (pendingShipping.isEmpty && confirmed.isEmpty)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No shipping records found.',
                style: TextStyle(color: Colors.grey)),
          )),
      ],
    );
  }
}

// ─────────────────────────────────────────
// TAB 4: PAYMENT ADVICE
// ─────────────────────────────────────────
class _PaymentTab extends StatelessWidget {
  final List<PurchaseOrder> orders;
  final VoidCallback onRefresh;

  const _PaymentTab({required this.orders, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final unpaid = orders
        .where((o) => o.shippingConfirmed && !o.paymentAdviceSent)
        .toList();
    final paid = orders.where((o) => o.paymentAdviceSent).toList();
    final repo = PurchaseOrderRepository();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unpaid.isNotEmpty) ...[
          const Text('💳 Pending Payment Advice',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...unpaid.map((po) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.payment, color: Colors.blue),
                  ),
                  title: Text(po.id,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Amount: \$${po.totalAmount.toStringAsFixed(0)}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      repo.sendPaymentAdvice(po.id);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Payment advice sent for ${po.id}'),
                          backgroundColor: Colors.blue[700],
                        ),
                      );
                    },
                    child: const Text('Send Advice',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              )),
          const SizedBox(height: 16),
        ],
        if (paid.isNotEmpty) ...[
          const Text('✅ Payment Advice Sent',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...paid.map((po) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.check_circle, color: Colors.blue),
                  ),
                  title: Text(po.id,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '\$${po.totalAmount.toStringAsFixed(0)} • Completed'),
                ),
              )),
        ],
        if (unpaid.isEmpty && paid.isEmpty)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
                'No payment records yet.\nConfirm shipping first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
          )),
      ],
    );
  }
}
