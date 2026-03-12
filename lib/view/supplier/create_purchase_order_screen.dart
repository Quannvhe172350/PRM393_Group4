import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../models/purchase_order.dart';
import '../../repositories/purchase_order_repository.dart';

class CreatePurchaseOrderScreen extends StatefulWidget {
  final Supplier supplier;

  const CreatePurchaseOrderScreen({super.key, required this.supplier});

  @override
  State<CreatePurchaseOrderScreen> createState() =>
      _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState
    extends State<CreatePurchaseOrderScreen> {
  final PurchaseOrderRepository _repo = PurchaseOrderRepository();
  final Map<String, int> _quantities = {};

  List<CatalogItem> get _availableItems =>
      widget.supplier.catalogItems.where((c) => c.available).toList();

  double get _totalAmount => _availableItems.fold(0.0, (sum, item) {
        final qty = _quantities[item.sku] ?? 0;
        return sum + (qty * item.wholesalePrice);
      });

  int get _selectedCount =>
      _quantities.values.where((q) => q > 0).length;

  void _submitOrder() {
    final selectedItems = _availableItems
        .where((item) => (_quantities[item.sku] ?? 0) > 0)
        .map((item) => POItem(
              sku: item.sku,
              productName: item.productName,
              quantity: _quantities[item.sku]!,
              unitPrice: item.wholesalePrice,
            ))
        .toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final order = _repo.createOrder(
      supplierId: widget.supplier.id,
      supplierName: widget.supplier.name,
      items: selectedItems,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Order Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PO ID: ${order.id}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Items: ${order.items.length}'),
            Text(
                'Total: \$${order.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            const Text(
                'The purchase order has been sent to the supplier.',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700]),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Create Purchase Order',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Supplier info banner
          Container(
            width: double.infinity,
            color: Colors.green[50],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[700],
                  child: Text(
                    widget.supplier.name[0],
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.supplier.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(widget.supplier.email,
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Items & Quantities',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text('$_selectedCount selected',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          // Items list
          Expanded(
            child: _availableItems.isEmpty
                ? const Center(
                    child: Text(
                        'No available items in catalog.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _availableItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = _availableItems[i];
                      final qty = _quantities[item.sku] ?? 0;
                      final subtotal = qty * item.wholesalePrice;

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        'SKU: ${item.sku}  •  \$${item.wholesalePrice.toStringAsFixed(0)}/unit',
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12)),
                                    if (subtotal > 0)
                                      Text(
                                        'Subtotal: \$${subtotal.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: qty > 0
                                        ? () => setState(() =>
                                            _quantities[item.sku] = qty - 1)
                                        : null,
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      '$qty',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    onPressed: () => setState(() =>
                                        _quantities[item.sku] = qty + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Bottom summary + submit
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '\$${_totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      'Submit Purchase Order',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: _submitOrder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
