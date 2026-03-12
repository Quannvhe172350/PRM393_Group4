enum POStatus { pending, confirmed, shipped, completed }

class POItem {
  final String sku;
  final String productName;
  final int quantity;
  final double unitPrice;

  POItem({
    required this.sku,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;
}

class PurchaseOrder {
  final String id;
  final String supplierId;
  final String supplierName;
  List<POItem> items;
  POStatus status;
  final DateTime createdAt;
  bool shippingConfirmed;
  bool paymentAdviceSent;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    this.status = POStatus.pending,
    DateTime? createdAt,
    this.shippingConfirmed = false,
    this.paymentAdviceSent = false,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  String get statusLabel {
    switch (status) {
      case POStatus.pending:
        return 'Pending';
      case POStatus.confirmed:
        return 'Confirmed';
      case POStatus.shipped:
        return 'Shipped';
      case POStatus.completed:
        return 'Completed';
    }
  }
}
