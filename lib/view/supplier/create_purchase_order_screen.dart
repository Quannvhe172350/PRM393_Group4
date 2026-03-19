import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../models/product.dart';
import '../../db/app_database.dart';

class CreatePurchaseOrderScreen extends StatefulWidget {
  final Supplier supplier;
  const CreatePurchaseOrderScreen({super.key, required this.supplier});

  @override
  State<CreatePurchaseOrderScreen> createState() => _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends State<CreatePurchaseOrderScreen> {
  final AppDatabase _db = AppDatabase.instance;
  List<Product> _products = [];
  // Key là product.id (String), value là số lượng
  Map<String, int> _quantities = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await _db.getProducts();
    setState(() {
      _products = data;
      _isLoading = false;
    });
  }

  void _submit() async {
    final poId = 'PO-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 100000}';
    double total = 0;
    List<Map<String, dynamic>> items = [];

    for (final entry in _quantities.entries) {
      final qty = entry.value;
      if (qty <= 0) continue;

      final prod = _products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => throw Exception('Không tìm thấy sản phẩm: ${entry.key}'),
      );
      total += prod.price * qty;
      items.add({
        'po_id': poId,
        'product_id': int.parse(prod.id),
        'quantity': qty,
        'unit_price': prod.price,
        'subtotal': prod.price * qty,
      });
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 sản phẩm'), backgroundColor: Colors.orange),
      );
      return;
    }

    final poMap = {
      'id': poId,
      'supplier_id': int.parse(widget.supplier.id),
      'order_date': DateTime.now().toIso8601String(),
      'total_amount': total,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _db.insertPurchaseOrder(poMap, items);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã tạo đơn hàng $poId thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _quantities.values.where((q) => q > 0).length;
    final total = _quantities.entries
        .where((e) => e.value > 0)
        .fold(0.0, (sum, e) {
          final prod = _products.firstWhere((p) => p.id == e.key, orElse: () => _products.first);
          return sum + prod.price * e.value;
        });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn hàng'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary bar
                if (selectedCount > 0)
                  Container(
                    color: Colors.indigo.shade50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Đã chọn $selectedCount sản phẩm', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Tổng: ${total.toStringAsFixed(0)}đ', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      final q = _quantities[p.id] ?? 0;
                      return ListTile(
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Giá: ${p.price.toStringAsFixed(0)}đ | Kho: ${p.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: q > 0
                                  ? () => setState(() => _quantities[p.id] = q - 1)
                                  : null,
                            ),
                            SizedBox(
                              width: 30,
                              child: Text('$q', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () => setState(() => _quantities[p.id] = q + 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Gửi đơn hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _submit,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
