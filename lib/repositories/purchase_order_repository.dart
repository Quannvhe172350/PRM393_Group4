import '../models/purchase_order.dart';

class PurchaseOrderRepository {
  // Singleton pattern
  static final PurchaseOrderRepository _instance =
      PurchaseOrderRepository._internal();
  factory PurchaseOrderRepository() => _instance;
  PurchaseOrderRepository._internal();

  // Mock data
  final List<PurchaseOrder> _orders = [
    PurchaseOrder(
      id: 'PO-2024-001',
      supplierId: 'S001',
      supplierName: 'Fresh Farm Co.',
      status: POStatus.shipped,
      shippingConfirmed: true,
      paymentAdviceSent: false,
      createdAt: DateTime(2024, 3, 1),
      items: [
        POItem(sku: 'FF001', productName: 'Organic Milk 1L', quantity: 100, unitPrice: 18000),
        POItem(sku: 'FF002', productName: 'Free-range Eggs (10pcs)', quantity: 50, unitPrice: 35000),
      ],
    ),
    PurchaseOrder(
      id: 'PO-2024-002',
      supplierId: 'S002',
      supplierName: 'Green Valley Produce',
      status: POStatus.pending,
      createdAt: DateTime(2024, 3, 5),
      items: [
        POItem(sku: 'GV001', productName: 'Apple Fuji 1kg', quantity: 80, unitPrice: 55000),
        POItem(sku: 'GV002', productName: 'Orange Valencia 1kg', quantity: 60, unitPrice: 40000),
      ],
    ),
    PurchaseOrder(
      id: 'PO-2024-003',
      supplierId: 'S001',
      supplierName: 'Fresh Farm Co.',
      status: POStatus.completed,
      shippingConfirmed: true,
      paymentAdviceSent: true,
      createdAt: DateTime(2024, 2, 20),
      items: [
        POItem(sku: 'FF003', productName: 'Butter 200g', quantity: 40, unitPrice: 45000),
      ],
    ),
  ];

  int _nextOrderNum = 4;

  List<PurchaseOrder> getAll() => List.unmodifiable(_orders);

  List<PurchaseOrder> getBySupplierId(String supplierId) =>
      _orders.where((o) => o.supplierId == supplierId).toList();

  PurchaseOrder? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  PurchaseOrder createOrder({
    required String supplierId,
    required String supplierName,
    required List<POItem> items,
  }) {
    final id = 'PO-2024-${_nextOrderNum.toString().padLeft(3, '0')}';
    _nextOrderNum++;
    final order = PurchaseOrder(
      id: id,
      supplierId: supplierId,
      supplierName: supplierName,
      items: items,
    );
    _orders.add(order);
    return order;
  }

  bool confirmShipping(String orderId) {
    final order = getById(orderId);
    if (order == null) return false;
    order.shippingConfirmed = true;
    order.status = POStatus.shipped;
    return true;
  }

  bool sendPaymentAdvice(String orderId) {
    final order = getById(orderId);
    if (order == null) return false;
    order.paymentAdviceSent = true;
    order.status = POStatus.completed;
    return true;
  }

  bool updateStatus(String orderId, POStatus status) {
    final order = getById(orderId);
    if (order == null) return false;
    order.status = status;
    return true;
  }
}
